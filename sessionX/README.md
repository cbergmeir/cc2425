# Session 10, 11: Spark y Práctica 3

textos originales de Manuel Parra: manuelparra@decsai.ugr.es and José Manuel Benítez: j.m.benitez@decsai.ugr.es

Con contribuciones de Carlos Cano: carloscano@ugr.es

Contenido:

* [Introducción a Spark](#introducción-a-spark)
* [Spark context](#spark-context)
* [Ejecución en modo local, standalone o YARN](#ejecución-en-modo-local-standalone-o-yarn)
   * [Instalación de un entorno de prueba sencillo](#instalación-de-un-entorno-de-prueba-sencillo)
* [Trabajar con Spark](#trabajar-con-spark)
   * [Enviar un trabajo al cluster](#enviar-un-trabajo-al-cluster)
   * [PySpark, o como utilizar Spark desde Python](#pyspark-o-como-utilizar-spark-desde-python)
      * [En hadoop.ugr.es (NO LO USAMOS DE MOMENTO)](#en-hadoopugres-no-lo-usamos-de-momento)
      * [En local o en el servidor de prácticas](#en-local-o-en-el-servidor-de-prácticas)
      * [En hadoop.ugr.es (NO LO USAMOS DE MOMENTO)](#en-hadoopugres-no-lo-usamos-de-momento-1)
      * [En local o en el servidor de prácticas](#en-local-o-en-el-servidor-de-prácticas-1)
   * [Consola interactiva PySpark](#consola-interactiva-pyspark)
   * [Trabajo con RDDs / SparkDataFrames](#trabajo-con-rdds--sparkdataframes)
   * [Carga de datos desde CSV](#carga-de-datos-desde-csv)
   * [Manipulación de los datos con SparkSQL](#manipulación-de-los-datos-con-sparksql)
   * [MLlib](#mllib)
* [Referencias](#referencias)


# Introducción a Spark

Desde su lanzamiento, Apache Spark ha sido adoptado rápidamente por empresas de una amplia gama de industrias y prácticamente se ha convertido en el estándar de-facto para el procesamiento de datos de gran volumen. Empresas de Internet tan conocidas como Netflix, Yahoo y eBay han desplegado Spark a escala masiva, procesando colectivamente múltiples petabytes de datos en clusters de más de 8.000 nodos. Se ha convertido rápidamente en la mayor comunidad de código abierto en Big Data, con más de 1.000 colaboradores de más de 250 organizaciones.

Entre las características de Spak cabe mencionar:
- Velocidad: Diseñado de abajo hacia arriba para el rendimiento, **Spark puede llegar a ser 100 veces más rápido que Hadoop para el procesamiento de datos a gran escala** explotando el uso de memoria y otras optimizaciones. Spark también es rápido cuando los datos se almacenan en el disco, y actualmente tiene el récord mundial de ordenación a gran escala en disco.
- Facilidad de uso: Spark tiene APIs fáciles de usar para operar en grandes conjuntos de datos. Esto incluye una colección de más de 100 operadores para transformar datos y API de marcos de datos familiares para manipular datos semiestructurados. Un ejemplo sencillo en Python de la expresividad de su API puede verse en este código, que permite consultar datos de una forma muy flexible (lee un json, selecciona los datos con `age>21` y luego devuelve la columna (path en json / key) `name.first` ):
```
df = spark.read.json("logs.json")
df.where("age > 21").select("name.first").show()
```
- Un motor unificado: Spark viene empaquetado con bibliotecas de nivel superior, incluyendo soporte para consultas SQL, transmisión de datos, aprendizaje automático y procesamiento de gráficos. Estas bibliotecas estándar aumentan la productividad de los desarrolladores y pueden combinarse perfectamente para crear flujos de trabajo complejos.
- Funciona en cualquier plataforma: Tiene soporte para HDFS Hadoop, Apache Mesos, Kubernetes, Cassandra, Hbase, etc.

Para la ejecución de aplicaciones de Python/R/Scala en Spark necesitamos contar con los siguientes elementos: 

# Spark context

Punto de entrada principal para la funcionalidad de Spark. Un SparkContext representa la conexión a un cluster de Spark, y puede ser usado para crear RDDs, acumuladores y variables en ese cluster. El SparkContext se define dentro de un script, por ejemplo, el siguiente código en python : 
```
conf = SparkConf().setAppName("Word Count - Python").set("spark.hadoop.yarn.resourcemanager.address", "hadoop-master:8032")
sc = SparkContext(conf=conf)
```
utiliza un objeto `SparkConf` que representa los parámetros de configuración del `SparkContext`. En este caso, la variable `sc` representa un Spark context en python sobre Hadoop YARN en hadoop-master:8032. 

Otro ejemplo, utilizando directamente los propios parámetros de `SparkContext` en lugar de un objeto `SparkConf`:  
```
sc = pyspark.SparkContext(master='local[*]', appName="Word Count")
```
En este caso `sc` representa un Spark context de una shell Spark ejecutando como master en el nodo local con tantas hebras como cores disponibles haya en el nodo (`local[2]` utilizaría 2 cores, `local[*]` tantos como haya disponibles).

![Spark architecture](spark.png)

# Ejecución en modo local, standalone o YARN

Para que Spark funcione necesita recursos. En el modo autónomo (standalone) se inician los workers y el maestro de Spark y la capa de almacenamiento puede ser cualquiera --- HDFS, Sistema de Archivos, Cassandra etc. En el modo YARN se pide al clúster YARN-Hadoop que administre la asignación de recursos y la gestión del mismo resulta más eficiente. En el modo local todas las tareas relacionadas con el trabajo de Spark se ejecutan en la misma JVM. 

## Instalación de un entorno de prueba sencillo

En local o en el servidor de prácticas puedes instalar un entorno sencillo con docker. Usamos la configuración de HDFS que ya hemos visto en la [Sesión 9](../session9) y añadimos un contenedor de Spark al que instalamos un Python. El fichero `docker-compose.yaml` que vamos a usar es el siguiente:

```
services:
  namenode:
    image: docker.io/bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8
    container_name: namenode
    hostname: namenode
    ports:
      - "9870:9870"
    environment:
      - CLUSTER_NAME=test
      - HDFS_CONF_dfs_namenode_datanode_registration_ip___hostname___check=false
    volumes:
      - namenode:/hadoop/dfs/name
      - ~/data:/data  # Host path : Container path
    networks:
      - hadoop

  datanode:
    image: docker.io/bde2020/hadoop-datanode:2.0.0-hadoop3.2.1-java8
    container_name: datanode
    hostname: datanode
    ports:
      - "9864:9864"
    environment:
      - CLUSTER_NAME=test
      - CORE_CONF_fs_defaultFS=hdfs://namenode:8020
    volumes:
      - datanode:/hadoop/dfs/data
    depends_on:
      - namenode
    networks:
      - hadoop

  spark:
    # Build our custom Python-enabled Spark image
    build: ./spark  # The folder containing your Dockerfile (FROM bitnami/spark...)
    container_name: spark
    # Provide any environment configs Spark might need to locate HDFS
    environment:
      - CORE_CONF_fs_defaultFS=hdfs://namenode:8020
    # We let this container spin up so we can exec in
    depends_on:
      - namenode
      - datanode

volumes:
  namenode:
  datanode:

networks:
  hadoop:  
```

Y el fichero Dockerfile (dentro de una carpeta que llamamos `spark`), es el siguiente:

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

**Si trabajas subre el servidor de prácticas tienes que cambiar los puertos de la instalación a puertos que tienes asignado**

Luego, te puedes conectar con `docker exec -it spark bash`

# Trabajar con Spark

## Enviar un trabajo al cluster

La sintaxis es la siguiente:
```
spark-submit
--class <main-class> 
--master <master-url> 
--deploy-mode <deploy-mode> 
--conf <key>=<value>
....
<application-jar> [application-arguments]
```

## PySpark, o como utilizar Spark desde Python

Os proponemos ahora un ejemplo práctico en Python utilizando la biblioteca PySpark. Os recomendamos consultar la documentación de PySpark y los ejemplos en el siguiente enlace: https://spark.apache.org/docs/latest/api/python/

Para un primer ejemplo, os proponemos seguir los siguientes pasos: 

1.- Descargamos un conjunto de datos (en nuestra cuenta, fuera de los contenedores):
```
wget https://raw.githubusercontent.com/mattf/joyce/master/james-joyce-ulysses.txt 
```

2. Mover el fichero al contenedor `namenode`:

El `namenode` tiene una carpeta `/data` que se monta desde `~/data`

2.- Mover el fichero a hdfs:
```
hdfs dfs -put james-joyce-ulysses.txt /user/your-username 
```

3.- Crear un fichero `wordcount.py` con el siguiente código fuente: 
```
import pyspark 
 
if __name__ == "__main__":

  input_file = "" 	#path to your input file here
  output_folder = "" 	#path to your output folder here
  
  # create Spark context with Spark configuration
  sc = pyspark.SparkContext(master='local[*]', appName="Word Count")
 
  # read in text file and split each document into words
  words = sc.textFile(input_file).flatMap(lambda line: line.split(" "))

  # count the occurrence of each word
  wordCounts = words.map(lambda word: (word, 1)).reduceByKey(lambda a,b:a +b)
 
  wordCounts.saveAsTextFile(output_folder)
  
  sc.stop()
```
En este ejemplo, tras crear un Spark context, se lee el archivo de texto de entrada usando la variable `SparkContext` y se crea un mapa plano de palabras `words`, que es de tipo PythonRDD.
```
words = sc.textFile(input_file).flatMap(lambda line: line.split(" "))
```
Al final de la línea de código se especifica que se dividen las palabras usando un solo espacio como separador.

Luego mapearemos cada palabra a un par clave:valor de palabra:1, siendo 1 el número de ocurrencias:
```
words.map(lambda word: (word, 1))
```
Después agregamos en el resultado todos los pares con la misma clave (la palabra). La agregación es la suma en este caso: 
```
reduceByKey(lambda a,b:a +b)
```
Y el resultado se almacena en formato de texto en el directorio especificado: 
```
wordCounts.saveAsTextFile(output_folder)
```
	
4.- Editar el código fuente del programa y modificar los datos de entrada (`input_file`) y salida (`output_folder`) sobre HDFS. En cada ejecución será siempre obligatorio actualizar el directorio de salida ya que Spark por defecto no sobrescribe resultados y el proceso termina en error cuando lo intenta.

### En hadoop.ugr.es (NO LO USAMOS DE MOMENTO)
Si tus datos de entrada y tu carpeta de salida están en HDFS en ulises.ugr.es, debes especificar la ruta a los datos utilizando los siguientes nombres de dominio: 
```
  input_file = "hdfs://ulises.imuds.es:8020/user/your-username/james-joyce-ulysses.txt"
  output_folder = "hdfs://ulises.imuds.es:8020/user/your-username/wc_joyce/"
```
El nombre de dominio `ulises.imuds.es` (o IP `192.168.3.100`) es el nombre (y la IP) del servidor HDFS en la red interna del cluster. 

### En local o en el servidor de prácticas

Debes especificar la ruta a los datos utilizando los siguientes nombres de dominio: 
```
  input_file = "hdfs://namenode:8020/user/your-username/james-joyce-ulysses.txt"
  output_folder = "hdfs://namenode:8020/user/your-username/wc_joyce/"
```

5.- Enviar el programa a ejecución.

Para enviar el programa a ejecución debemos invocar el comando `spark-submit` tal y como se describe en [Enviar un trabajo al cluster](#enviar-un-trabajo-al-cluster). Para ello, debemos conocer la ruta al binario `spark-submit` y la URL del master del cluster Spark. Dependiendo de la máquina en la que ejecutemos los comandos, estos parámetros varían: 

### En hadoop.ugr.es (NO LO USAMOS DE MOMENTO)

Desde ulises.ugr.es:
```
/opt/spark-3.0.1-bin-hadoop2.7/bin/spark-submit --master spark://ulises:7077 --total-executor-cores 5 --executor-memory 1g wordcount.py
```

Desde hadoop.ugr.es:
```
/opt/spark-2.2.0/bin/spark-submit --master spark://hadoop-master:7077 --total-executor-cores 5 --executor-memory 1g wordcount.py

```

### En local o en el servidor de prácticas

Conectarse al contenedor de spark: `docker exec -it spark bash`, y luego ejecutar:

TODO: CHEQUEAR.

```
spark-submit --master spark://namenode:7077 --total-executor-cores 5 --executor-memory 1g wordcount.py
```

6.- ¿Dónde están los resultados?
Los resultados de la ejecución están dentro de la carpeta HDFS destino que se ha indicado en `saveAsTextFile()`. Al ver los ficheros generados usando: 

```
hdfs dfs -ls directorio_destino
```

aparece lo siguiente:`part-00000 part-00001 part-00002 ...`

Cada uno de los ficheros contiene los pares claves (palabra) - valor (suma del número de ocurrencias). Por ejemplo, si mostramos el contenido de uno de estos ficheros: 
```
$ hdfs dfs -cat /user/CCSA2223/tu-usuario/wc_joyce/part-00968
('said:', 27)
('narrowly', 1)
('butter,', 5)
("o'er", 9)
('narrow', 4)
('Five,', 2)
('dog.', 5)
('did?', 2)
...
```

Si queremos unir todo el conjunto de resultados hay que usar la función `-getmerge` de HDFS, que fusiona los resultados de las partes de la salida de datos:
```
hdfs dfs -getmerge /user/your-username/wc_joyce ./james-joyce-ulysses-wordcount-result.txt
```


Para que el propio programa devuelva los datos ya procesados, debemos tener en cuenta que estamos trabajando con datos que están distribuidos y han de ser *recogidos* de los nodos donde se encuentran.

En el siguiente ejemplo podemos ver como hacer la misma función que el comando anterior, pero usando `.collect()` para recolectar los datos y mostrarlos en pantalla o guardarlos en un fichero de nuevo. Hay que tener cuidado con `collect()`, pues convierte un RDD a un objeto python equivalente, por lo que está limitado a los recursos del nodo.

```
import pyspark 
 
if __name__ == "__main__":

  input_file = "" #your input file here
  output_folder = "" # your output folder here
  
  # create Spark context with Spark configuration
  sc = pyspark.SparkContext(master='local[*]', appName="Word Count")
 
  # read in text file and split each document into words
  words = sc.textFile(input_file).flatMap(lambda line: line.split(" "))

  # count the occurrence of each word
  wordCounts = words.map(lambda word: (word, 1)).reduceByKey(lambda a,b:a +b)
 
  output = wordCounts.collect()		#use with care
  
  for (word, count) in output:
    print("%s: %i" % (word, count))  
  
  sc.stop()
```

## Consola interactiva PySpark

En ocasiones es muy útil realizar pruebas con nuestro código antes de enviar el trabajo a Spark con `spark-submit`. La consola interactiva PySpark es un shell de Python con el contexto ya disponible para trabajar en Spark usando la variable spark que lo controla:

Desde hadoop.ugr.es:
```
/opt/spark-2.2.0/bin/pyspark --master spark://hadoop-master:7077
```
Desde ulises.ugr.es: 
```
$ pyspark
```

Desde local o el servidor de prácticas:

```
docker exec -it spark bash
pyspark
```

O directamente:

```
docker exec -it spark pyspark
```

Lo que debemos ver es lo siguiente:

```
Python 2.7.17 (default, Mar  8 2023, 18:40:28) 
[GCC 7.5.0] on linux2
Type "help", "copyright", "credits" or "license" for more information.
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /__ / .__/\_,_/_/ /_/\_\   version 2.3.2.3.1.0.0-78
      /_/

Using Python version 2.7.17 (default, Mar  8 2023 18:40:28)
SparkSession available as 'spark'.
```

Dentro del entorno interactivo pyspark utilizaremos la variable que se nos indica `spark` para referirnos a la sesión Spark y al SparkContext. Es decir, **dentro de PySpark no debes definir un nuevo contexto Spark**, porque ya hay uno definido y solo puede haber uno activo a la vez -- por tanto, **dentro de PySpark no puedes ejecutar este comando**: 
```
  # create Spark context with Spark configuration, do not run this from within PySpark
  sc = pyspark.SparkContext(master='local[*]', appName="Word Count")
```
En los siguientes *snippets* de código utilizaremos indistintamente `sc` como SparkContext por defecto o `spark` como SparkSession por defecto, según si ese *snippet* ha sido copiado desde un comando ejecutado en la shell interactiva de PySpark o desde un script lanzado luego con `spark-submit. Más sobre SparkSession y SparkContext en el siguiente enlace: https://towardsdatascience.com/sparksession-vs-sparkcontext-vs-sqlcontext-vs-hivecontext-741d50c9486a

## Trabajo con RDDs / SparkDataFrames

Resilient Distributed Datasets -RDD- (concepto que sustenta los fundamentos de Apache Spark), pueden residir tanto en disco como en memoria principal.

Cuando cargamos un conjunto de datos para ser procesado en Spark (por ejemplo proveniente de una fuente externa como los archivos de un directorio de un HDFS, o de una estructura de datos que haya sido previamente generada en nuestro programa), la estructura que usamos internamente para volcar dichos datos es un RDD. Al volcarlo a un RDD, en función de cómo tengamos configurado nuestro entorno de trabajo en Spark, la lista de entradas que componen nuestro dataset será dividida en un número concreto de particiones (se "paralelizará" (`paralelize`)), cada una de ellas almacenada en uno de los nodos de nuestro clúster para procesamiento de Big Data. Esto explica el apelativo de "distributed" de los RDD.

A partir de aquí, entrará en juego otra de las características básicas de estos RDD, y es que son inmutables. Una vez que hemos creado un RDD, éste no cambiará, sino que cada transformación (map, filter, flatMap, etc.) que apliquemos sobre él generará un nuevo RDD. Esto por ejemplo facilita mucho las tareas de procesamiento concurrente, ya que si varios procesos están trabajando sobre un mismo RDD el saber que no va a cambiar simplifica la gestión de dicha concurrencia. Cada definición de un nuevo RDD no está generando realmente copias de los datos. Cuando vamos aplicando sucesivas transformaciones de los datos, lo que estamos componiendo es una "receta" que se aplica a los datos para conseguir las transformaciones.

Ejemplo de RDD simple:
```
#Lista general en Python:
lista = ['uno','dos','dos','tres','cuatro']
#Creamos el RDD de la lista:
listardd = sc.parallelize(lista)
#Recolectamos los datos del RDD para convertirlo de nuevo en Obj Py
print(listardd.collect())
```

Las diferencias más importantes entre un RDD y un Dataframe son las siguientes:
- Tanto RDD como los dataframes provienen de datasets (listas, datos csv,...)
- Los RDD necesitan ser subidos a HDFS previamente, los dataframes pueden ser
cargados en memoria directamente desde un archivo como, por ejemplo, un .csv
- Los RDD son un tipo de estructura de datos especial de Apache Spark, mientras que
los dataframes son una clase especial de R.
- Los RDD son inmutables (su edición va generando el DAG), mientras que los
dataframes admiten operaciones sobre los propios datos, es decir, podemos
cambiarlos en memoria.
- Los RDD se encuentran distribuidos entre los cluster, los dataframes en un único
cluster o máquina.
- Los RDD son tolerantes a fallos.

Para aprender a manejar Dataframes y RDDS en PySpark podemos consultar los manuales de referencia de PySpark: 
- Dataframes: https://mybinder.org/v2/gh/apache/spark/bf45fad170?filepath=python%2Fdocs%2Fsource%2Fgetting_started%2Fquickstart_df.ipynb
- RDDs: https://spark.apache.org/docs/latest/api/python/reference/api/pyspark.RDD.html#pyspark.RDD

También es importante matizar que, tal y como se especifica en la documentación de PySpark:
 
> Note that the RDD API is a low-level API which can be difficult to use and you do not get the benefit of Spark’s automatic query optimization capabilities. We recommend using DataFrames instead of RDDs as it allows you to express what you want more easily and lets Spark automatically construct the most efficient query for you.

Es decir, PySpark recomienda el uso de APIs de usuario/programadores sobre Dataframes en lugar de RDDs, ya que Spark puede representar los dataframes en los RDDs mejor optimizados y dejando el uso explícito de RDDs para usuarios expertos. Es por esto que para la biblioteca de referencia en Machine Learning sobre Spark, MLlib, se recomienda directamente el uso de Dataframes: 
https://spark.apache.org/docs/latest/ml-guide.html


## Carga de datos desde CSV 

Descarga este dataset de COVID-19:
```
wget https://opendata.ecdc.europa.eu/covid19/casedistribution/csv/
```
cámbiale el nombre a `covid19.csv` y muévelo a HDFS.

Para cargar como un CSV dentro de SPARK como un DataFrame
```
df = spark.read.csv("hdfs://ulises.imuds.es:8020/user/your-username/covid19.csv",header=True,sep=",",inferSchema=True);
df.printSchema() 
```
Una vez hecho esto, `df` contiene un DataFrame para ser utilizado con toda la funcionalidad de Spark.

## Manipulación de los datos con SparkSQL

Una vez creado el DataFrame es posible transformarlo en otro componente que permite el acceso al mismo mediante una sintaxis basada en SQL (ver https://spark.apache.org/docs/2.2.0/sql-programming-guide.html)

Usando la variable anterior:
```
df.createOrReplaceTempView("test")
sqlDF = spark.sql("SELECT * FROM test") 
sqlDF.show()

sqlDF = spark.sql("SELECT * FROM test WHERE countriesAndTerritories='Spain'")
sqlDF.show()
```
Desempolva tus habilidades con SQL para hacer las consultas que desees sobre el conjunto de datos y guardar los resultados en el DataFrame correspondiente. 

## MLlib
 MLlib es la biblioteca de Machine Learning sobre Spark. Puedes ver si todo está instalado correctamente con un ejemplo sencillo como lo siguiente:
 
```python
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.linalg import Vectors
from pyspark.sql import Row

# Create SparkSession
from pyspark.sql import SparkSession
spark = SparkSession.builder.getOrCreate()

# Properly format data with Vectors
data = [
    Row(label=0.0, features=Vectors.dense([0.0, 1.1, 0.1])),
    Row(label=1.0, features=Vectors.dense([2.0, 1.0, -1.0])),
    Row(label=0.0, features=Vectors.dense([2.0, 1.3, 1.0])),
    Row(label=1.0, features=Vectors.dense([0.0, 1.2, -0.5]))
]
df = spark.createDataFrame(data)

# Train model
lr = LogisticRegression(maxIter=10, regParam=0.01)
model = lr.fit(df)

# Predict
result = model.transform(df)
result.select("features", "label", "prediction").show()
```

Luego, puedes consultar la documentación para ver ejemplos más complejos: 
 - MLlib: https://spark.apache.org/docs/latest/ml-guide.html
 - MLlib desde PySpark: https://spark.apache.org/docs/latest/api/python/reference/pyspark.ml.html



# Referencias
Podéis encontrar multitud de ejemplos y tutoriales guiados para el análisis de datos con técnicas de ML utilizando Spark:
- Python: https://github.com/gogundur/Pyspark-Logistic-Regression/blob/master/Pyspark/Pyspark%20Classification.ipynb
- Python: https://dl.acm.org/doi/pdf/10.1145/3309129.3309133
- Scala: https://medium.com/rahasak/logistic-regression-with-apache-spark-b7ec4c98cfcd


<!--

# SparkR

API SparkR: https://spark.apache.org/docs/2.2.0/api/R/

## How to connect


```
ssh <yourID>@hadoop.ugr.es
```

## Start R shell for Spark

Run the next command:

```
R
```

## Create the Spark Environment


```

if (nchar(Sys.getenv("SPARK_HOME")) < 1) {
  Sys.setenv(SPARK_HOME = "/opt/spark-2.2.0/")
}

library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))

sparkR.session(master = "local[*]", sparkConfig = list(spark.driver.memory = "1g"),enableHiveSupport=FALSE)

```



## Close the Spark Session


```
sparkR.session.stop()
```

## Spark Session parameters

```
Property Name                   Property group          spark-submit equivalent
spark.master                    Application Properties  --master
spark.yarn.keytab               Application Properties  --keytab
spark.yarn.principal            Application Properties  --principal
spark.driver.memory             Application Properties  --driver-memory
spark.driver.extraClassPath     Runtime Environment     --driver-class-path
spark.driver.extraJavaOptions   Runtime Environment     --driver-java-options
spark.driver.extraLibraryPath   Runtime Environment     --driver-library-path

```

## Creating SparkDataFrames

With a SparkSession, applications can create SparkDataFrames from a local R data frame, from a Hive table, or from other data sources.

### From local data frames

The simplest way to create a data frame is to convert a local R data frame into a SparkDataFrame. Specifically we can use as.DataFrame or createDataFrame and pass in the local R data frame to create a SparkDataFrame. As an example, the following creates a SparkDataFrame based using the faithful dataset from R.

```
df <- as.DataFrame(faithful)
```

Show data in df:

```
head(df)
```

### From Data Sources

SparkR supports operating on a variety of data sources through the SparkDataFrame interface.

SparkR supports reading JSON, CSV and Parquet files natively, and through packages available from sources like Third Party Projects, you can find data source connectors for popular file formats like Avro.

```
data1 <- read.df("my_file.json", "json")
data2 <- read.df("my_file.csv", "csv")
...
```

### How to read/write from/to hdfs


Read as DataFrame ``/user/mp2019/5000_ECBDL14_10tst.data``:

```
df5000 <- read.df("hdfs://hadoop-master/user/mp2019/5000_ECBDL14_10tst.data", source="csv")

```

Check data:

```
summary(df5000)
```

Explain the data: From _c0 to _c9 (data), class variable: _c10.

## SparkDataFrame Operations

Create the SparkDataFrame

```
df <- as.DataFrame(faithful)
```

Get basic information about the SparkDataFrame

``
df
``

Select only the "eruptions" column

```
select(df, df$eruptions)
``

Show:

```
head(select(df, df$eruptions))
``


Filter the SparkDataFrame to only retain rows with wait times shorter than 50 mins

```
filter(df, df$waiting < 50)
```

Show first results

```
head(filter(df, df$waiting < 50))
```

## Grouping and Aggregation

SparkR data frames support a number of commonly used functions to aggregate data after grouping. 


We use the `n` operator to count the number of times each waiting time appears

```
head(summarize(groupBy(df, df$waiting), count = n(df$waiting)))
```

## Operating on Columns

SparkR also provides a number of functions that can directly applied to columns for data processing and during aggregation.

```
df$waiting_secs <- df$waiting * 60
```

## SparkSQL

```
df5000 <- read.df("hdfs://hadoop-master/user/mp2019/5000_ECBDL14_10tst.data", source="csv")
```

Check summary:

```
summary(df5000)
```

Convert to SparkSQLObject:

```
createOrReplaceTempView(df5000, "df5000sql")

```

Use the next sentence:

```
results <- sql("SELECT _c0  FROM df5000sql")
```

Check results:

```
head(results)
```


```
results <- sql("SELECT max(_c0)  FROM df5000sql")

```

**Question:**

What is the pair of columns more correlated?

Check SQL functions: https://spark.apache.org/docs/2.3.0/api/sql/index.html

**5 minutes**


**How many records of each class are there?**

```
results <- sql("SELECT count(*),_c10  FROM df5000sql group by _c10")
```

## Machine learning

SparkR supports the following machine learning algorithms currently:

- Classification
  - spark.logit: Logistic Regression
  - spark.mlp: Multilayer Perceptron (MLP)
  - spark.naiveBayes: Naive Bayes
  - spark.svmLinear: Linear Support Vector Machine
- Regression
  - spark.survreg: Accelerated Failure Time (AFT) Survival Model
  - spark.glm or glm: Generalized Linear Model (GLM)
  - spark.isoreg: Isotonic Regression
- Tree
  - spark.gbt: Gradient Boosted Trees for Regression and Classification
  - spark.randomForest: Random Forest for Regression and Classification
- Clustering
  - spark.bisectingKmeans: Bisecting k-means
  - spark.gaussianMixture: Gaussian Mixture Model (GMM)
  - spark.kmeans: K-Means
  - spark.lda: Latent Dirichlet Allocation (LDA)
- Collaborative Filtering
  - spark.als: Alternating Least Squares (ALS)
- Frequent Pattern Mining
  - spark.fpGrowth : FP-growth
- Statistics
  - spark.kstest: Kolmogorov-Smirnov Test

Under the hood, SparkR uses MLlib to train the model. Please refer to the corresponding section of MLlib user guide for example code. Users can call summary to print a summary of the fitted model, predict to make predictions on new data, and write.ml/read.ml to save/load fitted models. SparkR supports a subset of the available R formula operators for model fitting, including ‘~’, ‘.’, ‘:’, ‘+’, and ‘-‘.

## Let see some examples

+Info: https://spark.apache.org/docs/2.2.0/ml-classification-regression.html

Before start, check the columns types:

```
summary(df5000)
```

Result:

```
SparkDataFrame[summary:string, _c0:string, _c1:string, _c2:string, _c3:string, _c4:string, _c5:string, _c6:string, _c7:string, _c8:string, _c9:string, _c10:string]
```

ALL TYPES are STRING :(

Solution: Infer Scheme !

```
df5000 <- read.df("hdfs://hadoop-master/user/mp2019/5000_ECBDL14_10tst.data", source="csv",  inferSchema = "true", header="true")
```

Check again:

```
summary(df5000)
```

### First example

```
training <- df5000
test <- df5000
```

```
model = spark.logit(training, f1 ~ class, maxIter = 10, regParam = 0.3, elasticNetParam = 0.8)

```

See the model:

```
summary(model)
```

-->


