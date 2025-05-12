#!/usr/bin/env bash
#
# Automate namespace + quota + RBAC + kubeconfig for a single Spark user
#
# Usage: ./setup_user_namespace.sh <username>
# Requires: kubectl, base64, jq (jq only if your cluster has multiple contexts)

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USER_NAME="$1"
NS="user-${USER_NAME}"
SA_NAME="spark"

echo ">>> Creating namespace ${NS}"
kubectl create namespace "${NS}" --dry-run=client -o yaml | kubectl apply -f -

#####################################################################
# 1. ResourceQuota & LimitRange
#####################################################################
echo ">>> Applying ResourceQuota and LimitRange"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: rq-spark
  namespace: ${NS}
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 16Gi
    limits.cpu: "6"
    limits.memory: 24Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: lr-defaults
  namespace: ${NS}
spec:
  limits:
  - type: Container
    default:
      cpu: "2"
      memory: 4Gi
    defaultRequest:
      cpu: "1"
      memory: 2Gi
EOF

#####################################################################
# 2. ServiceAccount + RBAC
#####################################################################
echo ">>> Creating ServiceAccount '${SA_NAME}'"
kubectl create serviceaccount "${SA_NAME}" -n "${NS}" --dry-run=client -o yaml | kubectl apply -f -

echo ">>> Creating Role / RoleBinding"
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: spark-role
  namespace: ${NS}
rules:
  - apiGroups: [""]
    resources: [pods, services, configmaps, persistentvolumeclaims, pods/log]
    verbs: [create, get, list, watch, delete]
  - apiGroups: ["apps"]
    resources: [deployments, replicasets]
    verbs: [create, get, list, watch, delete]
  - apiGroups: ["sparkoperator.k8s.io"]
    resources: [sparkapplications, sparkapplications/status]
    verbs: [create, get, list, watch, update, delete]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: spark-rolebinding
  namespace: ${NS}
subjects:
  - kind: ServiceAccount
    name: ${SA_NAME}
    namespace: ${NS}
roleRef:
  kind: Role
  name: spark-role
  apiGroup: rbac.authorization.k8s.io
EOF

#####################################################################
# 3. Build per‑user kubeconfig
#####################################################################
echo ">>> Building kubeconfig for ${USER_NAME}"
mkdir -p kubeconfigs

# pull cluster name & server from current context
CURRENT_CONTEXT=$(kubectl config current-context)

# cluster name referenced by that context:
CLUSTER_NAME=$(kubectl config view -o \
  jsonpath="{.contexts[?(@.name==\"${CURRENT_CONTEXT}\")].context.cluster}")

# API‑server URL for that cluster section:
SERVER=$(kubectl config view -o \
  jsonpath="{.clusters[?(@.name==\"${CLUSTER_NAME}\")].cluster.server}")

KCFG="kubeconfigs/${USER_NAME}-kubeconfig"

echo ">>> Generating a bound token"
TOKEN=$(kubectl -n "${NS}" create token "${SA_NAME}")

# ------------------------------------------------------------------
#  Grab the cluster’s CA – works for path *or* inline‑data
# ------------------------------------------------------------------
CA_CERT=$(kubectl config view --raw -o \
  jsonpath="{.clusters[?(@.name==\"${CLUSTER_NAME}\")].cluster.certificate-authority-data}")

if [[ -z "${CA_CERT}" ]]; then
  # fall back to file path, then base64‑encode the content
  CA_PATH=$(kubectl config view --raw -o \
    jsonpath="{.clusters[?(@.name==\"${CLUSTER_NAME}\")].cluster.certificate-authority}")
  if [[ -z "${CA_PATH}" ]]; then
    echo "ERROR: No CA data or path found for cluster ${CLUSTER_NAME}"
    exit 1
  fi
  if [[ ! -f "${CA_PATH}" ]]; then
    echo "ERROR: CA file ${CA_PATH} not found on local machine"
    exit 1
  fi
  CA_CERT=$(base64 -w0 < "${CA_PATH}")
fi


cat > "${KCFG}" <<EOF
apiVersion: v1
kind: Config
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority-data: ${CA_CERT}
    server: ${SERVER}
users:
- name: ${USER_NAME}
  user:
    token: ${TOKEN}
contexts:
- name: ${USER_NAME}-context
  context:
    cluster: ${CLUSTER_NAME}
    namespace: ${NS}
    user: ${USER_NAME}
current-context: ${USER_NAME}-context
EOF

echo ">>> Finished.  Kubeconfig for ${USER_NAME} written to ${KCFG}"
echo "    Hand that file to the user and tell them:"
echo "      export KUBECONFIG=\$(pwd)/${KCFG}"
echo "      kubectl get pods                 # should list only their own objects"

