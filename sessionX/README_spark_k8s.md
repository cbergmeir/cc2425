# Running Spark with Kubernetes

## Build the custom spark image

Use the following Dockerfile (inside a subfolder `spark`):

```
FROM docker.io/bitnami/spark:3.3.0

USER root
RUN apt-get update && apt-get install -y python3 python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# (Optional) Ensure pyspark is installed if needed. In many cases, Spark's PySpark is already included,
# but if you need a specific version or extra Python packages, do so here:
# RUN pip3 install pyspark==3.3.0

RUN pip3 install numpy

USER 1001

```

Build and load into minikube:

```
docker build -t my-custom-spark:latest ./spark
minikube image load my-custom-spark:latest
minikube image ls
```

The image needs to show as: `docker.io/library/my-custom-spark:latest`

## Spin up services

Then, use the yaml files from [here](spark_k8s.zip) to spin up the services:

```
kubectl apply -f pv-pvcs.yaml
kubectl apply -f hadoop-namenode.yaml
kubectl apply -f hadoop-datanode.yaml
kubectl apply -f spark-deployment.yaml
```

Check they are running:

```
kubectl get pods
```

## Make a file in HDFS

Connect to namenode:

```
kubectl exec -it namenode-<podID> -- bash
```

Create test file in HDFS:

```
hdfs dfs -mkdir -p /test
echo "Hello HDFS" > /tmp/sample.txt
hdfs dfs -put /tmp/sample.txt /test
hdfs dfs -ls /test
hdfs dfs -cat /test/sample.txt
```

## Test that Spark is working and can access HDFS

Run pyspark:

```
kubectl exec -it spark-<podID> -- pyspark
```

Test that it is working:

```python
# Simple test in PySpark shell
rdd = sc.parallelize([1, 2, 3, 4])
print(rdd.map(lambda x: x * x).collect())

# Example: reading a file from HDFS
text_rdd = sc.textFile("hdfs://namenode:8020/test/sample.txt")
print(text_rdd.count())
```

## TODO NOT WORKING YET Run one config for all different users

### Install helm and spark-operator

download from the original web page and unzip.

Then, do:

Add the Helm repository

```
helm repo add spark-operator https://kubeflow.github.io/spark-operator
helm repo update
```

Install the operator into the spark-operator namespace and wait for deployments to be ready

```
helm install spark-operator spark-operator/spark-operator \
    --namespace spark-operator --create-namespace --wait
```

Create an example application in the default namespace

```
kubectl apply -f https://raw.githubusercontent.com/kubeflow/spark-operator/refs/heads/master/examples/spark-pi.yaml
```

Get the status of the application

```
kubectl get sparkapp spark-pi
``` 

### Create the yaml for the user

Use [this script here](setup_user_namespace.sh) to set up a user, for example user test00:

```
./setup_user_namespace.sh test00
```

The user and all of its pods etc. can be deleted with

```
kubectl delete namespace test00
```

The sh script generates a kubeconfig yaml file. You can now connect as this user by using this yaml file as follows.

```
export KUBECONFIG=~/spark_operator/kubeconfigs/test00-kubeconfig
```

You can go back to the normal user by:

```
unset KUBECONFIG
```

### Run Pyspark for this user

First, publish the my-custom-spark docker image to dockerhub, and replace the url in the commmand below.

You can run Pyspark with the following commands

**TODO: This is currently not working, it doesn't get resources assigned**

```
USER_NS=user-test00
IMG=docker.io/cbergmeir/my-custom-spark:latest

kubectl delete pod pyspark-shell -n "${USER_NS}" --ignore-not-found

kubectl run pyspark-shell \
  --namespace="${USER_NS}" \
  --image="${IMG}" \
  --restart=Never -it \
  --overrides='{"spec":{"serviceAccountName":"spark"}}' \
  -- /opt/bitnami/spark/bin/pyspark \
       --master k8s://https://kubernetes.default.svc:443 \
       --conf spark.kubernetes.namespace=${USER_NS} \
       --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
       --conf spark.kubernetes.container.image=${IMG} \
       --conf spark.kubernetes.authenticate.caCertFile=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
       --conf spark.executor.instances=1 \
       --conf spark.executor.cores=1 \
       --conf spark.executor.memory=1g \
       --conf spark.kubernetes.executor.request.cores=0.5 \
       --conf spark.hadoop.fs.defaultFS=hdfs://namenode.default:8020
```

