
# Objetivos de la práctica

Los objetivos formativos de esta práctica se centran en que el alumno adquiera los
siguientes conocimientos y habilidades:

- Conocimiento de la infraestructura de cómputo para Big Data y su despliegue en
plataformas de cloud computing.
- Manejo del sistema HDFS.
- Conocimiento de frameworks para el procesamiento de los datos de gran volumen
y aplicación de técnicas de Minería de Datos para la extracción de conocimiento.
- Uso de las herramientas básicas proporcionadas por la MLLib de Spark. 

# Recursos disponibles

Los recursos que se proporcionan al alumnado para abordar la práctica están recopilados
en [Sesión 9](../session9) y [Sesión 10 y 11](../sessionX):

- HDFS [Sesión 9](../session9)
	- Manejo y gestión de ficheros en HDFS vs. Local
	- Operaciones básicas para el trabajo con ficheros en HDFS.

- Plataforma SPARK [Sesión 10 y 11](../sessionX)
	- Spark submit y PySpark
	- Spark Shell (para Python, Scala y R).
	- DataFrames y el uso/gestión de SparkDataFrames. Componentes del framework
que proporciona Spark para el trabajo con datos: Biblioteca de componentes.
	- Consultas a datos usando SparkSQL.
	- Implementación de flujos de trabajo Spark para Minería de Datos con MLLib.
	
- Materiales adicionales generados por Manuel Parra:
	- https://github.com/manuparra/taller_SparkR
	- https://github.com/manuparra/TallerH2S
	- https://github.com/manuparra/taller-bigdata-con-r
	- https://github.com/manuparra/starting-bigdata-aws
	
Para el desarrollo de la práctica se usará o bien una instalación en local o en el servidor de práctivas sobre docker, o bien el cluster ulises.ugr.es (mejor que hadoop.ugr.es), que provee de HDFS y Spark ya preparado y listo para trabajar sobre él, y que proporciona todas las herramientas para el procesamiento. El siguiente paso natural sería probarlo sobre plataformas cloud con más recursos: Azure, DataBricks, ... (pero esto escapa el contenido de la asignatura).

# Descripción de la práctica

En el desarrollo de esta práctica se estudiarán y pondrán en uso diferentes métodos y
técnicas de procesamiento de datos para grandes volúmenes de datos. En concreto, el
objetivo final será la resolución de un problema de clasificación a través del desarrollo de distintos modelos. Este trabajo implica el diseño conceptual, la programación y el
despliegue de distintos modelos, apoyándose en los métodos implementados en la
biblioteca MLlib. Para ello habrá que usar hábilmente distintas herramientas de los
ecosistemas de Hadoop y Spark, desplegadas sobre distintos escenarios. Una vez
diseñados e implementados se comparará el rendimiento de los distintos clasificadores
para identificar cuál resulta ser el más adecuado para el problema en cuestión realizando
un estudio empírico comparativo.

El problema a considerar es la realización de distintas tareas de análisis de datos sobre un conjunto de datos concreto. Más concretamente, el conjunto define un problema de
clasificación y se trata de construir varios clasificadores que los resuelvan. **TODO Está disponible en el directorio de HDFS que se especifica en el mensaje de PRADO que acompaña a esta memoria.**

Para la realización de las tareas es necesario tener en cuenta las siguientes indicaciones:

- Se usarán como lenguajes de programación Scala, Python, Java o R.
- **Si el problema de clasificación no está equilibrado (diferente número de instancias de
las distintas clases) es necesario preprocesarlo para paliar este inconveniente con
alguna técnica como ROS o RUS (random oversampling or random undersampling).**
- Aplicar al menos 3 técnicas de construcción de clasificadores (Naive Bayes, RF, LR,
SVM, ...) de la MLlib de Spark. La lista de todos los algoritmos está disponible [aquí](https://spark.apache.org/docs/latest/ml-classification-regression.html).
- Es necesario probar al menos 2 parametrizaciones de cada uno de los algoritmos.
- Para evaluar los clasificadores construidos se realizará un breve estudio
experimental. Se trata de construir clasificadores (sobre partición de
entrenamiento) y evaluarlos (sobre partición de prueba). Los resultados se
recogerán en una tabla que incluirá todos los modelos y combinaciones de hiper
parámetros consideradas.
- Finalmente, analizar los resultados obtenidos. Identificar qué algoritmo y
parametrización obtiene mejores resultados.

# Ejemplo de plantilla para la práctica 3

Si vais a implementar la práctica en Python, os recomendamos comenzar cualquier desarrollo desde PySpark, copiando y pegando comandos para ir interactuando con las variables resultantes y haciendo vuestras propias pruebas. Asumiendo que utilizáis PySpark, no hemos creado ninguna variable SparkContext y hemos utilizado la variable por defecto de SparkSession de PySpark `spark`. 

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


# Entrega y evaluación de la práctica

El trabajo realizado en esta práctica es evaluable y formará otra parte de la
calificación de la asignatura de Prácticas. Los detalles de la entrega y evaluación se
incluyen a continuación.

## Instrucciones de entrega

Para la entrega de esta práctica. Se subirá la documentación a PRADO en la actividad "Práctica 3 Spark" en un único fichero en formato zip, con el siguiente contenido.

1. Documentación en formato PDF, que debe incluir las siguientes partes:

	- Portada, con autor, DNI (ID), curso, asignatura.
	- Introducción / Descripción de la práctica.
	- Resolución del problema de clasificación (sin código completo, solo los extractos más representativos). Explica cada una de las tareas, cómo la has resuelto, además del flujo de procesamiento que usas.
		- Detalla los pasos que has tenido en cuenta para cada tarea de procesado y métodos utilizados.
		- Los resultados de los clasificadores para cada parametrización.
		- Conclusiones
		
2. Se aportará el código fuente desarrollado, debidamente organizado y empaquetado o dentro del fichero .zip a través de la entrega en prado o indicando vuestro repositorio github. El código debe estar bien organizado y explicado a través de la correspondiente
documentación.

## Criterios de evaluación

1. Se valorará la completitud y calidad de la documentación que se aporta con la
práctica.
2. Se valorará la capacidad de diseñar un flujo de trabajo automatizado con Spark.
3. Se valorarán las mejoras introducidas en el código para incrementar el rendimiento
de la clasificación.
4. Se valorarán las propuestas sobre el preprocesamiento de los datos antes de la
aplicación de los métodos de ML.

## Plazos de entrega

Plazo de entrega en PRADO: Hasta el 16 de Mayo de 2025 a las 23:59 hrs.

## Defensa de la práctica

Será después de la entrega en horario de clase de prácticas, el día 19 de Mayo de 2025. El profesor irá indicando en clase cuándo se realizará cada defensa. 




