# Ejemplo de plantilla para la práctica 3


Os recomendamos comenzar cualquier desarrollo desde PySpark, copiando y pegando comandos para ir interactuando con las variables resultantes y haciendo vuestras propias pruebas. Asumiendo que utilizáis PySpark, no hemos creado ninguna variable SparkContext y hemos utilizado la variable por defecto de SparkSession de PySpark `spark`. 

Podéis partir de un código similar al siguiente, y os recomendamos que consultéis las referencias abajo. Se os pide que vuestro código tenga, al menos, las siguientes etapas bien delimitadas: 

- Carga del dataset en un dataframe.
- Análisis exploratorio básico de los datos: ¿cuántas columnas hay?, ¿de qué tipo son?, ¿hay valores perdidos?, ¿cómo se distribuyen las clases?, etc. 
- Preprocesamiento y normalización de datos: selección de variables, transformación de variables (por ejemplo, de string a double, etc), normalización. 
- Particionamiento de los datos en dos conjuntos: entrenamiento y test (por ejemplo, 80%/20%).
- Elección de un modelo de ML para el problema. Establecer los parámetros del modelo y entrenarlo. 
- Evaluar la bondad del modelo de ML con los datos de entrenamiento y test (curvas ROC y área bajo curva ROC, por ejemplo). 
- Evaluar distintos modelos y parametrizaciones de los mismos y elegir el modelo con mejor métricas para el conjunto de test. 


```
from pyspark.ml.classification import LogisticRegression

# load your dataset into a DataFrame
df = spark.read.csv("hdfs://ulises.imuds.es:8020/user/your-username/covid19.csv",header=True,sep=",",inferSchema=True);
df.show()

# create a SQL view of your dataset for further filtering using SQL language
df.createOrReplaceTempView("sql_dataset")
sqlDF = spark.sql("SELECT campo1, campo3, ... campoX FROM sql_dataset") 
sqlDF.show()

# Create a ML model and apply the model to the dataset
lr = LogisticRegression(maxIter=10, regParam=0.3, elasticNetParam=0.8) 
lrModel = lr.fit(sqlDF)
lrModel.summary()

#df.collect() <- Do NOT collect since the resources for the node are limited for a big dataset!

sc.stop()

```

Después de jugar con este código, para enviar un script completo a `spark-submit`, es necesario que defináis al principio del código un SparkContext y lo utilicéis donde corresponda: 
```
# Whenever you want to run this code as a script submitted to pyspark-submit, first create Spark context with Spark configuration (the following code)
# and use `spark` and `sc` wherever approppriate in the rest of the code
from pyspark import SparkContext, SparkConf
conf = SparkConf().setAppName("Practica 3")
sc = SparkContext(conf=conf)
```

Podéis empezar a programar sobre [esta plantilla de ejemplo para la Práctica 3](P3_plantilla.py). 

