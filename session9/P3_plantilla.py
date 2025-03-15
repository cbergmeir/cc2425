# You can run these commands in Spark using two different alternatives: 
# A- from an interactive environment with "pyspark", copy and paste the commands and play with them
# B- Once your script is ready, run it from the command line with spark-submit: /opt/spark-2.2.0/bin/spark-submit --master spark://hadoop-master:7077 --total-executor-cores 5 --executor-memory 1g script.py
#       For option B, you need to include in your script a definition of a spark context as described in https://github.com/ccano/cc2223/blob/main/session8/README.md#ejemplo-de-plantilla-para-la-práctica-3

# Import required libraries. Check out pyspark.sql and pyspark.ml
from pyspark.sql.functions import isnan, when, count, col
#from pyspark.ml... import ...


# Read the data stored in HDFS
df = spark.read.csv("hdfs://ulises.imuds.es:8020/user/CCSA2223/ccano/train.csv",header=True,sep=",",inferSchema=True);

# Show sample data
df.show(3)

# Show schema (columns types)
df.printSchema()

# ¿does the dataset have imbalanced classes? if so, we would need to deal with an imbalance classification problem (using ROS or RUS)
df.groupby("type").count().show()

# ¿do we have Null values? if so, we would need to deal with them
df.select([count(when(isnan(c), c)).alias(c) for c in df.columns]).head()

# Data preprocessing and normalization: 
# - Add new column "class" with a double casting from column "type" for ML methods (so instead of classes "galaxy"/"star" we have classes "0.0/1.0")
# - Create a feature vector with a selected subset of the attributes (see VectorAssembler) 
# - Normalization 
# - Split the data set into training and test (80%/20%)

# Create the ML model and train it on the training dataset  
# - Choose different configuration sets for the ML model parameters
# - Compute areaUnderROC and/or other performance metrics for evaluating the best configuration
# - Predict performance on the test data (see BinaryClassificationEvaluator class)
# - Save the results to a file
# - Save the best model to a file 
# - Repeat this process with different configuration parameters and with different ML models. 

