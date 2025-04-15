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
