
# Práctica 1: Despliegue de servicio ownCloud

# Contenidos:
* [1. Objetivos de la práctica](#1-objetivos-de-la-práctica)
* [2. Descripción del trabajo a desarrollar en la práctica](#2-descripción-del-trabajo-a-desarrollar-en-la-práctica)
* [3. Características de cada servicio para despliegue con contenedores](#3-caracter%C3%ADsticas-de-cada-servicio-para-despliegue-con-contenedores)
   - [3.1. Despliegue y gestión de servicios de autenticación de usuarios con LDAP](#31-despliegue-y-gestión-de-servicios-de-autenticación-de-usuarios-con-ldap)
   - [3.2. Despliegue de ownCloud](#32-despliegue-de-owncloud)
   - [3.3. Despliegue de HAProxy](#33-despliegue-de-haproxy)
* [4. Entrega a través de PRADO. Documentación y evaluación de la práctica](#entrega-de-la-práctica-a-traves-de-prado-documentación-y-evaluación-de-la-práctica)
* [5. Referencias](#referencias)


## 1. Objetivos de la práctica
- Crear servicios interconectados usando contenedores.
- Conocer el despliegue de servicios en contenedores usando docker/podman, docker/podman-compose y kubernetes.
- **Se puede implementar con docker o podman, mi recomendación es usar podman**
- **Utilizad únicamente el rango de puertos por encima del puerto 20 000 que se os haya asignado si estáis utilizando el servidor.**
- Implementar distintas arquitecturas de servicios en contenedores en función de los requisitos del sistema. 
- Gestionar la escalabilidad de los servicios.
- Gestionar réplicas y herramientas de monitoreo y balanceo de carga. 
- Implementar una arquitectura de alta disponibilidad y uso concurrente por parte de múltiples usuarios. 
- Gestión de servicio de autenticación de usuarios. 
- Trabajar la persistencia de datos en contenedores. 

##  2. Descripción del trabajo a desarrollar en la práctica

###  2.1. Introducción

El despliegue de servicios en Cloud Computing es fundamental para poner en marcha funcionalidades que permitan tener aplicaciones y software además de infrastructuras con capacidades de soporte para múltiples usuarios y con posibilidades de escalado dinámico. Aprovechar los recursos que ofrece Cloud Computing de forma flexible es la clave para el correcto diseño de servicios y microservicios interconectados desplegados en la nube (mediante contenedores). 

ownCloud es una herramienta *open-source* de sincronización y compartición de ficheros en la nube. Una especie de Google Drive o Dropbox de código abierto, con un [gran soporte entre la comunidad](https://owncloud.com/getting-started/).

Puedes probar una demo de ownCloud [aquí](https://demo.owncloud.com).

**El objetivo de esta práctica es desplegar nuestro propio servicio de ownCloud**. Con este despliegue, estaremos dando servicio a una empresa ficticia. Según el tamaño de la empresa, sus necesidades y su infraestructura, se recomendarán distintas arquitecturas cloud para el despliegue de este servicio. De este modo, **un objetivo secundario de esta práctica es conseguir desplegar este servicio con distintas arquitecturas y empleando distintas soluciones tecnológicas del Cloud**.     

Para realizar este despliegue, se requiere que el estudiante utilice tecnologías Cloud basadas en contenedores utilizando los motores de contenerización y de orquestación de contenedores vistas en las sesiones anteriores: Docker/Podman, Docker/Podman-compose y Kubernetes. 

### 2.2. Tareas propuestas

**Tarea obligatoria para superar la práctica**: 

1.- Diseño y despliegue de un servicio Owncloud basado en contenedores según la arquitectura descrita en el Escenario 1 (Ver sección Tipos de arquitecturas de cloud propuestas). En particular, se requiere que este servicio incluya, al menos, 4 microservicios: 
- Servicio web ownCloud
- MariaDB
- Redis
- LDAP (autenticación de usuarios)


Para este despliegue puede utilizarse Docker/Podman y Docker/Podman-compose. 

**Tareas adicionales para conseguir la máxima puntuación en la práctica**: 

2.- Diseño y despliegue de un servicio Owncloud basado en contenedores, con alta disponibilidad e inspirado en la arquitectura descrita en el Escenario 2. En particular, se requiere que este servicio incluya: 
- Balanceo de carga con HAProxy u otra herramienta
- Servicio web ownCloud
- MariaDB
- Redis
- LDAP (autenticación de usuarios)
- Replicación de, al menos, uno de los microservicios anteriores (Servidor web, LDAP o MariaDB). 
Para este despliegue puede utilizarse Docker/Podman, Docker/Podman-compose o Kubernetes. 

3.- Diseño y despliegue de la tarea 1 o 2 utilizando escalonadamente Docker/Podman, Docker/Podman-compose y Kubernetes. 


### 2.3. Implementación y despliegue de los servicios con contenedores

El objetivo de esta práctica es que el alumno sea capaz de poner en marcha un sistema ownCloud en la nube con los servicios citados anteriormente.

Para esta implementación con contenedores, se sugiere realizar el despliegue de manera escalonada en cada una de las siguientes modalidades:

####  Docker/Podman

Para este despligue es necesario desarrollar cada uno de los contenedores de forma individual para que alberguen cada uno de los servicios indicados. En esta modalidad, los contenedores tienen que ejecutarse sin un orquestador, lo que requerirá que se cree un script para poder desplegar y también bajar todos los servicios. 

####  Docker/Podman-compose

Para este despliegue se requiere el uso de la herramienta de composición de servicios `docker compose` o `podman compose` que provee Docker o Podman. Al igual que la anterior, se requiere que se incluyan todos los sevicios dentro del fichero de descripción de servicios a desplegar en `docker compose`.

####  Kubernetes

Este tipo de despliegue permite automatizar gran parte de las tareas y del ciclo de vida de los servicios.
El servicio de HAProxy puede se sustituido por el equivalente en Kubernetes, que permite balancear la carga entre los diferentes contenedores de cada `namespace`. 

### 2.4. Tipos de arquitecturas de cloud propuestas

En esta sección se describen dos posibles arquitecturas de cloud para el despliegue del servicio en función del tamaño de la empresa y de los recursos TIC disponibles. Tomado de la web https://doc.owncloud.com/server/next/admin_manual/installation/deployment_recommendations.html . 

#### Escenario 1: Pequeña empresa o departamento - grupo de usuarios pequeño

Este escenario sería el más apropiado para este tipo de requisitos: 

- Número de usuarios: Hasta 150
- Almacenamiento: 100 GB - 10TB
- Disponibilidad: 
    * Fallo de un elemento conlleva la interrupción del servicio
    * Esquema de backups: nocturno con interrupción momentánea del servicio


##### Arquitectura cloud propuesta

Una máquina ejecutando la aplicación: la web, el servidor de BD y almacenamiento local. Otra máquina prestando el servicio de autenticación a través de LDAP. Como no tenemos disponibles más de una máquina, no hay problema en simularlo todo en la misma máquina. Este diagrama representaría la arquitectura propuesta: 

![Arquitectura propuesta para una pequeña empresa](https://doc.owncloud.com/server/next/admin_manual/_images/installation/deprecs-1.png)

Que incluye los siguientes 4 servicios: 
- Servicio web owncloud
- MariaDB
- Redis
- LDAP (autenticación de usuarios)

##### Balanceo de carga

No.

##### Base de datos

MariaDB


##### Autenticación

Autenticación de usuarios a través de uno o varios servidores LDAP. Para ello, desplegar un servicio de LDAP tal y como se explica en la sección [Despliegue y gestión de servicios de autenticación de usuarios con LDAP](#31-despliegue-y-gestión-de-servicios-de-autenticación-de-usuarios-con-ldap) y luego [integrar LDAP con ownCloud como se explica en la sección correspondiente] (#32-despliegue-de-owncloud). 

##### Almacenamiento

Local. 


#### Escenario 2: Empresa mediana

Este escenario sería el más apropiado para un volumen de usuarios y demás criterios en línea con los siguientes números: 
- Número de usuarios: 150 - 1,000
- Almacenamiento: Hasta 200TB.
- Disponibilidad: 
    * Cada componente es redundante y el sistema es robusto a caídas de componentes sin que se produzca interrupción del servicio
    * Backups sin interrupción del servicio


##### Arquitectura cloud propuesta

En un escenario real, se propondría una arquitectura en cloud con los siguientes elementos: 

* 2 a 4 servidores de aplicación
* Un cluster de dos servidores de BDs. 
* Almacenamiento en un servidor NFS. 
* Autenticación a través de servicio LDAP. 
* Servicio Redis para bloque de ficheros. 
* Balanceador de carga HAproxy. 

Este diagrama representaría la arquitectura propuesta: 

![Arquitectura propuesta para una mediana empresa](https://doc.owncloud.com/server/next/admin_manual/_images/installation/deprecs-2.png)

En un escenario simulado, como el que nos ocupa, bastará con implementar los siguientes servicios: 
- Balanceo de carga con HAProxy u otra herramienta
- Servicio web owncloud
- MariaDB
- Redis
- LDAP
- Replicación de servicio de, al menos, uno de los servicios anteriores. 

##### Balanceo de Carga

Un servicio HAProxy ejecutándose en un servidor dedicado que recibe todas las peticiones y las envía a los servidores de aplicación según corresponda. 

##### Base de datos

En un entorno real, se construiría un cluster de servicios MariaDB [con répicas](https://mariadb.com/kb/en/setting-up-replication/) y consideraríamos, además, un [monitor de configuración para MariaDB](https://mariadb.com/kb/en/mariadb-maxscale-22-automatic-failover-with-mariadb-monitor) para prevenir comportamiento ante caída de servicio. En nuestro caso, sin embargo, bastará con replicar uno de los servicios anteriores (MariaDB u otro servicio). 

##### Autenticación

Autenticación de usuario a través de uno o varios servidores LDAP. 

##### Almacenamiento

Para el almacenamiento en este tipo de sistemas exploraríamos opciones como IBM Elastic Storage, Amazon S3 o soluciones NetApp, por ejemplo. En cualquier caso, no se requerirá el uso de este tipo de servicios para la implementación de un prototipo en el escenario 2 y bastará con que utilicéis almacenamiento local. 

## 3. Características de cada servicio para despliegue con contenedores 

## 3.1. Despliegue y gestión de servicios de autenticación de usuarios con LDAP

LDAP es un protocolo ligero para acceder a servidores de directorios. Vale, ¿qué es un servidor de directorios? Es una base de datos jerárquica orientada a objetos.

El paquete openldap-client instala herramientas que se utilizan para añadir, modificar y eliminar entradas en un directorio LDAP. Estas herramientas incluyen las siguientes:

* ldapadd - Añade entradas a un directorio LDAP aceptando entradas a través de un archivo o entrada estándar; ldapadd es en realidad un enlace duro para ldapmodify -a.

* ldapdelete - Borra las entradas de un directorio LDAP aceptando la entrada del usuario en un intérprete de comandos de shell o a través de un archivo.

* ldapmodify - Modifica las entradas en un directorio LDAP, aceptando la entrada a través de un archivo o entrada estándar.

* ldappasswd - Establece la contraseña para un usuario LDAP.

* ldapsearch - Busca entradas en un directorio LDAP usando un shell prompt.

* ldapcompare - Abre una conexión con un servidor LDAP, se une y realiza una comparación usando parámetros especificados.

* ldapwhoami - Abre una conexión a un servidor LDAP, se une, y realiza una operación whoami.

* ldapmodrdn - Abre una conexión a un servidor LDAP, vincula y modifica las RDNs de entradas.


### Objetos y clases
Los datos en LDAP se almacenan en objetos. Estos objetos contienen varios atributos, que son básicamente un conjunto de pares clave/valor. Puesto que los datos en LDAP están estructurados, los objetos sólo pueden contener claves válidas y las claves válidas dependen de la clase del objeto. Las clases en LDAP pueden definir atributos obligatorios y opcionales y su tipo.


*Las clases se asignan a objetos utilizando el atributo objectClass. LDAP define por defecto algunas clases básicas, tipos y métodos de comparación, pero el administrador es libre de definir los suyos propios.*

### Atributos

Los datos mismos en un sistema LDAP se almacenan principalmente en elementos llamados atributos. Los atributos son básicamente pares clave-valor. A diferencia de otros sistemas, las claves tienen nombres predefinidos dictados por el objetoClases seleccionados para la entrada. Además, los datos de un atributo deben coincidir con el tipo definido en la definición inicial del atributo.

```
...
home: /home/carlos
...
```


### Entradas

Los atributos por sí mismos no son muy útiles. Para tener sentido, deben estar asociados con algo. Dentro de LDAP, se utilizan atributos dentro de una entrada. 

Una entrada es básicamente una colección de atributos bajo un nombre usado para describir algo.
```
# LDAP user entry example
dn: cn=carlos,dc=example,dc=org
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
cn: carlos
...
```

### DIT

Un DIT es simplemente la jerarquía que describe la relación entre las entradas existentes. 

Al crear, cada nueva entrada debe "engancharse" al DIT existente colocándose como hijo de una entrada existente.

Esto crea una estructura similar a un árbol que se utiliza para definir relaciones de ordenación y asignar significado.

### Distinguished name (dn). Nombre distinguido.

Funciona como una ruta completa de regreso a la raíz de los árboles de información de datos, o DITs.

Por ejemplo:

```
dn: cn=carlos,dc=example,dc=org
```

- cn: Common name

- (ou: organizational segment / Organizational Unit) (Opcional)

- dc = Domain Component

El padre directo es el nombre de dominio "example.org", que funciona como raiz de nuestro DIT. Si tuviéramos grupos de usuarios, habría que trazar la ruta desde el usuario a la raíz a través de estos grupos. Los grupos de usuarios se utilizan a menudo para las categorías generales bajo la entrada DIT de nivel superior, cosas como ``ou=personas, ou=grupos, y ou=inventario``` son los más comunes.


### Ejemplo de la estructura de LDAP

En el [manual de OpenLDAP](https://www.openldap.org/doc/admin21/intro.html) tenéis un par de imágenes con diferentes estructuras del DIT: 

![LDAPstruct](https://www.openldap.org/doc/admin21/intro_dctree.gif)

![LDAPstruct](https://www.openldap.org/doc/admin21/intro_tree.gif)

## Desplegando OpenLDAP

OpenLDAP es una implementación de código abierto de LDAP disponible aquí: https://www.openldap.org

Puedes desplegar openLDAP desde una de las muchas imágenes de Docker disponibles **(reemplazar el puerto 20389 con uno que se os haya asignado)**: 
```
docker run -d -p 20389:389 --name openldap-server -t osixia/openldap:1.5.0 
```


## Verificando el estado del directorio LDAP

Para comprobar el estado del directorio LDAP, prueba: 

```
ldapsearch -x -H ldap://localhost:20389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
```
o 
```
docker exec openldap-server ldapsearch -x -H ldap://localhost:20389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin

```

Donde ```-w ``` sirve para indicar el password del administrador ```admin```, por defecto es también ```admin```. 


Esto imprime por pantalla el listado de todos los objetos que cuelgan del servicio de directorio bajo el objeto  ```dc=example``` que está bajo el objeto raíz ```dc=org```:


```
...
w admin
# extended LDIF
#
# LDAPv3
# base <dc=example,dc=org> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# example.org
dn: dc=example,dc=org
objectClass: top
objectClass: dcObject
objectClass: organization
o: Example Inc.
dc: example

...
```
En este caso, solo el propio objeto example.org (```dc=example,dc=org```) cuelga de este directorio. 

El formato de ``ldapsearch`` es: 

``ldapsearch -H <host> -LL -b <Query node> -x``

La utilidad LDAP  ``ldaputility`` contiene muchas opciones y parámetros, para más información revisa el [manual](https://www.centos.org/docs/5/html/CDS/ag/8.0/Finding_Directory_Entries-Using_ldapsearch.html). 


### Añadir un nuevo usuario

Una manera de agregar nuevos objetos al directorio LDAP es a través de un archivo LDIF. El fichero ldif debe contener definiciones de todos los atributos necesarios para las entradas que desea crear.
Con este archivo ``ldif``, puede usar el comando ``ldapadd`` para importar las entradas al directorio como se explica a continuación. 

Crea un archivo ``<nombreUsuario>.ldif`` (en mi caso, este se llama ```carlos.ldif```) y copia este esqueleto, modifícalo e incluye tus datos (es decir, reemplaza ``cn=carlos`` por ``cn=<tu-usuario>``, ``uid=carlos`` por ``uid=<uid-tu-usuario>``, etc.).


```
dn: uid=carlos,dc=example,dc=org
cn: carloscano
uid: carlos
sn: 3
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
uidNumber: 501
gidNumber: 20
homeDirectory: /home/carlos
loginShell: /bin/bash
gecos: carlos
userPassword: {crypt}x
```

El nuevo objeto tiene ```uid:carlos``` y está colocado directamente bajo la rama ```dc=example,dc=org```. El password se generará automáticamente y aparecerá encriptado en las siguientes consultas. Veremos cómo cambiarlo más adelante. 

Para añadir el usuario en LDAP utilizamos:

```
ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin -c -f carlos.ldif
```

La opción ```-w admin```permite introducir directamente el password del administrador del servicio LDAP. Por defecto, el administrador tiene username ```admin``` y clave ```admin```. Si eliminas ``-w admin``, y lo cambias por ``-W`` preguntará la clave de admin de LDAP de forma interactiva. 

Para comprobar si el usuario se ha añadido con éxito, vamos a realizar la misma consulta anterior: 
```
$ ldapsearch -x -H ldap://localhost:20389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin

# extended LDIF
#
# LDAPv3
# base <dc=example,dc=org> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# example.org
dn: dc=example,dc=org
objectClass: top
objectClass: dcObject
objectClass: organization
o: Example Inc.
dc: example

# carlos, example.org
dn: uid=carlos,dc=example,dc=org
cn: carloscano
uid: carlos
sn: 3
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
uidNumber: 501
gidNumber: 20
homeDirectory: /home/carlos
loginShell: /bin/bash
gecos: carlos
userPassword:: e2NyeXB0fXg=
...
```

Vemos que el objeto ```uid=carlos``` ha sido creado y que está asociado a la rama ```dc=example,dc=org```del directorio LDAP. 


### Persistencia de datos

Después de añadir un nuevo usuario, echa abajo el contenedor correspondiente con 
```
docker rm -f <id contenedor>
````

Y vuelve a lanzarlo con 
```
docker run -d -p 20389:389 --name openldap-server -t osixia/openldap:1.5.0 
```

Lanza de nuevo la consulta: 
```
$ ldapsearch -x -H ldap://localhost:20389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
````

y comprueba si el usuario sigue existiendo. ¿Qué ocurre? 

**No hay persistencia de datos (los datos solo existen dentro del contenedor), así que cualquier modificación en los datos de la imagen se elimina cuando echamos abajo el servicio**. Para evitarlo, debemos montar volúmenes de datos permanentes para el directorio LDAP, de forma que cualquier cambio en los datos sea visible y persistente fuera del contenedor, incluso si el servicio se cayera o se interrumpiera. 

Para ello, creamos dos carpetas para almacenar datos de LDAP: 
```
sudo mkdir -p ./data/slapd/config
sudo mkdir ./data/slapd/database
```

Y concedemos los permisos adecuados sobre estas carpetas. En linux, hacemos un nuevo grupo docker y vinculamos nuestro usuario a este grupo. Las carpetas de datos serán propiedad de nuestro usuario y del grupo docker: 
```
sudo usermod -aG docker $USER
newgrp docker
sudo chmod 775 -R /path-que-quieras/data/slapd
sudo chown -R $USER:docker /path-que-quieras/data/slapd
```
En MacOS: 
```
sudo chmod -R 775 /path-que-quieras/data/slapd
sudo chown -R $USER /path-que-quieras/data/slapd
```
Ahora, montamos estas carpetas como volúmenes de datos permanentes al lanzar el contenedor **(reemplazar los puertos con unos que se os haya asignado)**: 

```
docker run -p 20389:389 -p 20636:636 --volume /path-completo-hasta/data/slapd/database:/var/lib/ldap --volume /path-completo-hasta/data/slapd/config:/etc/ldap/slapd.d --name openldap-server  --detach osixia/openldap:1.5.0 
```

Si tienes un firewall activo, debes permitir que los puertos 20389 y 20636 estén accesibles para que LDAP escuche las peticiones de servicio a través de ellos con el siguiente código. Si no tienes un firewall activo, omite este paso: 

```
##Si usas UFW
sudo ufw allow 20389/tcp
sudo ufw allow 20636/tcp
##Si usas Firewalld
sudo firewall-cmd --add-port=20389/tcp --permanent
sudo firewall-cmd --add-port=20636/tcp --permanent
sudo firewall-cmd --reload
```

Ahora, vuelve a crear el usuario que creaste antes. En mi caso, creo dos usuarios: carlos y billy (hago un fichero billy.ldif con igual estructura que la que se mostró para carlos.ldif pero con otros datos de usuario): 
```
ldapadd -x -w admin -D "cn=admin,dc=example,dc=org" -f billy.ldif
ldapadd -x -w admin -D "cn=admin,dc=example,dc=org" -f carlos.ldif
```
Compruebo que los usuarios se han creado bien: 
```
docker exec openldap-server ldapsearch -x -H ldap://localhost:20389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
```
echo abajo el servicio openldap con docker rm -f <containerID>, lo vuelvo a levantar y compruebo con la consulta que los usuarios siguen existiendo:
```
docker exec openldap-server ldapsearch -x -H ldap://localhost:20389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
```
Ahora sí, los datos persisten más allá del ámbito del contenedor. 


## Cambiar el Password de un usuario en LDAP

Para cambiar el password del usuario ```carlos```creado anteriormente: 
```
ldappasswd -s <new_user_password> -w admin -D "cn=admin,dc=example,dc=org" -x "uid=carlos,dc=example,dc=org"
```
Revisa: https://www.centos.org/docs/5/html/CDS/cli/8.0/Configuration_Command_File_Reference-Command_Line_Utilities-ldappasswd.html  para más información sobre el comando.

Ahora prueba:

```
ldapsearch -x -H ldap://localhost:20389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
```

Esto devolverá el directorio con el último usuario modificado.

### Modificando cuentas de usuario con LDAP: DELETE, MODIFY.

La sintaxis es la siguiente:

```
ldapmodify [ options ]

ldapmodify [ options ] < LDIFfile

ldapmodify [ options ] -f LDIFfile
```

LDIFfile es, de nuevo, un archivo de texto LDIF que contiene nuevas entradas o actualizaciones a entradas existentes en el directorio LDAP.

Por ejemplo, he creado el siguiente fichero LDIF ``carlos_modify.ldif``` para cambiar el atributo loginShell del usuario ```carlos```.

```
dn: cn=carlos,dc=example,dc=org
changetype: modify
replace: loginShell
loginShell: /bin/csh
```

Luego ejecuto los cambios: 

```
ldapmodify -x -D "cn=admin,dc=example,dc=org" -w admin -H ldap:// -f carlos_modify.ldif
```

Actualizará ``cn=carlos`` con un nuevo ``loginShell``, en este caso ``/bin/csh```.

Comprueba que los cambios se han hecho: 

```
...
# carlos, example.org
dn: uid=carlos,dc=example,dc=org
cn: carloscano
uid: carlos
sn: 3
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
uidNumber: 501
gidNumber: 20
homeDirectory: /home/carlos
loginShell: /bin/csh
gecos: carlos
userPassword:: e2NyeXB0fXg=
...

```

Añade una entrada a un usuario LDAP. Crea un nuevo fichero ``carlos_add_descrip.ldif`` y añade: 

```
dn: cn=carlos,ou=Users,dc=example,dc=org
changetype: modify
add: description
description: Carlos Cano
```

Ejecuta el siguiente comando:

```
ldapmodify -x -D "cn=admin,dc=example,dc=org" -w password -H ldap:// -f carlos_add_descrip.ldif
```

Ahora, comprueba los cambios:


```
ldapsearch -H ldap://localhost:20389 -LL -b ou=Users,dc=example,dc=org -x
```

Y finalmente borra la descripción. Crea un nuevo dichero i.e. ``carlos_del_descr.ldif``

```
dn: cn=carlos,ou=Users,dc=example,dc=org
changetype: modify
delete: description
``` 

Luego ejecuta: 

```
ldapmodify -x -D "cn=admin,dc=example,dc=org" -w password -H ldap:// -f carlos_del_descr.ldif
```

Comprueba:

```
ldapsearch -H ldap://localhost:20389 -LL -b ou=Users,dc=example,dc=org -x
```

Verifica si la entidad ya no está.


## Añadir una OU (organizational unit) a LDAP:

Crear un nuevo fichero ``ldif`` . i.e. ``add_new_ou.ldif`` con :

```
dn: ou=People,dc=example,dc=org
ou: People
objectClass: top
objectClass: organizationalUnit
description: Parent object of all PEOPLE accounts
```

Luego usa:

```
ldapadd -x -D cn=admin,dc=example,dc=org -w admin -c -f add_new_ou.ldif
```
Ahora tienes una nueva categoría "People" dentro del árbol asociado al directorio LDAP. 

## Buscando y encontrado dentro del DIT

Por ejemplo, si queremos encontrar todos los objetos almacenados bajo la categoría ``ou=People``

```
ldapsearch -H ldap://localhost:20389 -LL -b ou=People,dc=example,dc=org -x
```

Cualquier combinación de  ```ou```, ```dc```, ... está permitida para buscar dentro del DIT.



## 3.2. Despliegue de ownCloud

El despliegue de un servicio ownCloud requiere desplegar un frontend con la aplicación web y un backend para la Base de Datos (en mySQL o MariaDB, en nuestro caso, optaremos por MariaDB) y la gestión de memoria caché con Redis para mejorar el rendimiento del sistema. Ya conocéis cómo desplegar Redis (se trabajó en la sesión 4), así que nos centraremos en esta sección en cómo desplegar ownCloud y MariaDB. Las instrucciones siguientes despliegan los contenedores de forma individual con docker - podéis tomarlos como punto de partida para hacer despliegues con orquestadores de contenedores. 

### Despliegue de contenedor ownCloud

**(reemplazar el puerto 20080 con uno que se os haya asignado)**

```
docker pull owncloud
docker run -d -p 20080:80 owncloud:latest
```

### Despliegue de contenedor MariaDB

[MariaDB Server](https://hub.docker.com/_/mariadb) es un servicio de altas prestaciones para implementar bases de datos relacionales que proviene de MySQL. Para desplegar un contenedor con este servicio, proceder así: 
```
docker pull mariadb
docker run --detach --name mariadb --env MARIADB_USER=<nombre_usuario> --env MARIADB_PASSWORD=<contraseña> --env MARIADB_ROOT_PASSWORD=<contraseña-root>  mariadb:latest
````

Sin embargo, con este despliegue de MariaDB, [**¿Dónde se almacenan los datos de MariaDB?**](https://github.com/docker-library/docs/blob/master/mariadb/README.md#where-to-store-data)

Para que el almacenamiento de los datos en MariaDB sea **persistente**, es necesario crear un directorio local y compartir este directorio con el contenedor de docker en el que se despliega la imagen de MariaDB. Para ello, echad abajo el contenedor anterior y, en su lugar, desplegad este otro.  

```
$ mkdir <path_al_directorio_deseado>/MariaDB_data
$ docker run --detach --name mariadb -v <path_al_directorio_deseado>:/var/lib/mysql --env MARIADB_DATABASE=test --env MARIADB_USER=<nombre_usuario> --env MARIADB_PASSWORD=<contraseña> --env MARIADB_ROOT_PASSWORD=<contraseña_root>  mariadb:latest
```

### Integración de LDAP en Owncloud
Una vez lanzado el servicio web de Owncloud y su backend (MariaDB y Redis), podéis visualizar este tutorial para integrar Owncloud con un servicio de LDAP existente: 
https://www.youtube.com/watch?v=Jd0JImHj3fk
   
Este manual también puede resultaros de ayuda: https://doc.owncloud.com/server/next/admin_manual/configuration/user/user_auth_ldap.html
Y en esta web se explica con detenimiento el valor de los distintos campos en la integración de NextCloud (proyecto similar a OwnCloud) y LDAP: https://docs.nextcloud.com/server/22/admin_manual/configuration_user/user_auth_ldap.html

## 3.3. Despliegue de HAProxy

HAProxy es un [proxy inverso](https://www.cloudflare.com/es-es/learning/cdn/glossary/reverse-proxy/) gratuito que balanceo de carga y alta disponibilidad para aplicaciones basadas en HTTP y TCP. En los últimos años se ha convertido en un estándar *de-facto* y es muy popular en sitios web de mucho tráfico. En esta práctica, lo utilizaremos para repartir carga y construir una infraestructura de altas prestaciones atendiendo al Escenario 2. 

La configuración básica de HAProxy como balanceador requiere editar el archivo /etc/haproxy/haproxy.cfg para indicarle: 
- frontend: IPs y puertos que HAProxy tiene que escuchar para recibir peticiones.
- backend: cuáles son las máquinas o los servicios finales a los que redirigir las peticiones de entrada. 

El manual de uso describe cómo construir un fichero de [configuración de HAProxy](http://docs.haproxy.org/2.6/configuration.html#2) y en la red puedes ver [multitud de tutoriales](https://www.haproxy.com/blog/haproxy-configuration-basics-load-balance-your-servers/) y [ejemplos de ficheros de configuración](https://chase-seibert.github.io/blog/2011/02/26/haproxy-quickstart-w-full-example-config-file.html). 

Por ejemplo, este es un fichero sencillo de configuración: 
```
frontend http-in
    bind *:80
    default_backend testing
backend testing
    server  m1  ip_maquinaM1:80 maxconn 32
    server  m2  ip_maquinaM2:80 maxconn 32
    server  m3  ip_maquinaM3:80 maxconn 32
````

en el que definimos un front-end ```http-in``` y un backend ```testing```. Este balanceador espera conexiones entrantes por el puerto 80 desde cualquier IP para redirigirlas a tres máquinas servidoras que escuchan por el puerto 80. La forma de reparto de carga de trabajo por defecto es ```roundrobin```, pero puedes cambiar el algoritmo en la [configuración de HAProxy](https://www.digitalocean.com/community/tutorials/an-introduction-to-haproxy-and-load-balancing-concepts). **(reemplazar los puertos con unos que se os haya asignado)**

Siguiendo el ejemplo anterior, supongamos que tenemos tres répicas de una aplicación web dando servicio. A modo de ejemplo, utilizaremos la imagen de Docker ```jmalloc/echo-server``` para servir una aplicación web muy sencilla que simplemente responde con los detalles de la petición HTTP que recibe. Creamos una red puente de Docker y desplegamos tres de estos servicios con Docker: 

```
$ sudo docker network create --driver=bridge mynetwork
$ sudo docker run -d \
   --net mynetwork --name web1 jmalloc/echo-server:latest
   
$ sudo docker run -d \
   --net mynetwork --name web2 jmalloc/echo-server:latest
   
$ sudo docker run -d \
   --net mynetwork --name web3 jmalloc/echo-server:latest

$ sudo docker ps -a 

CONTAINER ID   IMAGE                                 COMMAND                  CREATED          STATUS                     PORTS                                                                                                                                  NAMES
e54dc1e8a748   jmalloc/echo-server:latest            "/bin/echo-server"       27 seconds ago   Up 26 seconds              8080/tcp                                                                                                                               web3
4636d35b8c55   jmalloc/echo-server:latest            "/bin/echo-server"       31 seconds ago   Up 29 seconds              8080/tcp                                                                                                                               web2
6bf5ecded52a   jmalloc/echo-server:latest            "/bin/echo-server"       34 seconds ago   Up 33 seconds              8080/tcp                                                                                                                               web1

```
Estos contenedores escuchan el puerto 8080. Para enrutar el tráfico hacia ellos repartiendo la carga de trabajo, vamos a colocarles un HAProxy delante. Creamos un fichero haproxy.cfg en el directorio de trabajo actual que contenga lo siguiente: 

```

global
  stats socket /var/run/api.sock user haproxy group haproxy mode 660 level admin expose-fd listeners
  log stdout format raw local0 info

defaults
  mode http
  timeout client 10s
  timeout connect 5s
  timeout server 10s
  timeout http-request 10s
  log global

frontend stats
  bind *:8404
  stats enable
  stats uri /
  stats refresh 10s

frontend myfrontend
  bind :80
  default_backend webservers

backend webservers
  server s1 web1:8080 check
  server s2 web2:8080 check
  server s3 web3:8080 check
```

Algunos detalles sobre este fichero de configuración: 
- Sección ```global``` la línea ```stats socket``` habilita el API de ejecución de HAProxy y  la recarga de HAProxy. No entraremos en detalle en el uso de estos parámetros (podéis encontrar más información en el manual de HAProxy, ya que no son parámetros imprescindibles para el correcto funcionamiento de este ejemplo. 
- El frontend llamado ```stats``` escucha en el puerto 8404 y habilita el Dashboard de estadísticas de HAProxy para medir el rendimiento del sistema y el reparto de carga. Es opcional también. 
- El frontend llamado ```myfrontend``` escucha el puerto 80 y reparte las peticiones a los servidores listados en el backend llamado ```webservers```. 
- El backend ```webservers```lista los servidores entre los que se reparten las peticiones desde el frontend ```myfrontend```. En lugar de especificar la dirección IP de cada servidor, utilizamos sus nombres web1, web2 y web3 porque hemos creado una red puente de Docker que permite hacer el routing DNS de los servicios por su nombre.

Ahora, creamos y ejecutamos un contenedor con HAProxy **(reemplazar los puertos con unos que se os haya asignado)**: 

```
$ sudo docker run -d \
   --name haproxy \
   --net mynetwork \
   -v $(pwd):/usr/local/etc/haproxy:ro \
   -p 80:80 \
   -p 8404:8404 \
   haproxytech/haproxy-alpine:2.4
```
```
$ sudo docker ps 
CONTAINER ID   IMAGE                                 COMMAND                  CREATED              STATUS                PORTS                                                                                                                                  NAMES
d9c3e714b7fb   haproxytech/haproxy-alpine:2.4        "/docker-entrypoint.…"   6 seconds ago        Up 5 seconds          0.0.0.0:80->80/tcp, 0.0.0.0:8404->8404/tcp                                                                                             haproxy
bba173ccae97   jmalloc/echo-server:latest            "/bin/echo-server"       52 seconds ago       Up 52 seconds         8080/tcp                                                                                                                               web3
cd6da8fd2328   jmalloc/echo-server:latest            "/bin/echo-server"       56 seconds ago       Up 55 seconds         8080/tcp                                                                                                                               web2
5ca725df4f1f   jmalloc/echo-server:latest            "/bin/echo-server"       About a minute ago   Up 59 seconds         8080/tcp                                                                                                                               web1
```
Para comprobar el funcionamiento de esta arquitectura, abre un navegador web en la dirección (http://localhost/) y comprueba que la aplicación web ```echo-server```está funcionando, obteniendo un mensaje similar a éste: 

```
Request served by 5ca725df4f1f

GET / HTTP/1.1

Host: localhost
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
Accept-Encoding: gzip, deflate, br
Accept-Language: es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3
Cookie: ocgkh74g5c4m=b74b66f327faaa2e68773ac34481e1b5; grafana_session=79f4c3721c108e17a0a15da5739e2a4e; 5d89dac18813e15aa2f75788275e3588=53aunj9p4rt45k4tctcgsjaj6b; oczzl3fon5pt=ee9491c851c45b7388bd7a7b4c0f3109; ocegefixbh9u=4a7c10e7e70159b88d80abe83e98b1e6; oc4fmp8ar920=gimslp19hqip3std70smnhh3tr; oc_sessionPassphrase=x6V52BnIMtXdf81pqW9%2FbXsErUpyBo14mZpEqIQ0W2HMwqLoxSMgIZAaSzOZpHyjJr3skgZ2f4HN3316bBs85BUDoBoaDHtuiujfo2RCLAxbJTimsN0LVRXEF2Y%2BoWmc
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: none
Sec-Fetch-User: ?1
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0

```
El código ```Request served by 5ca725df4f1f```hace referencia al contenedor que ha ofrecido el servicio, comprueba que coincide con uno de los contenedores desplegados para echo-server anteriormente. HAProxy irá repartiendo las peticiones recibidas entre los tres servidores con un enfoque ```round-robin``` (algoritmo por defecto). 

Puedes consultar las estadísticas de monitoreo de los tres servicios abriendo con tu navegador las estadísticas ofrecidas por HAProxy en (http://localhost:8404/). 

Puedes hacer cambios en el fichero de configuración haproxy.cfg y relanzar el servidor HAProxy sin afectar al servicio utilizando ```docker kill```: 
```
$ docker kill -s HUP haproxy
````

Para eliminar los contenedores y la red, procede así: 
```
$ docker stop web1 && docker rm web1
$ docker stop web2 && docker rm web2
$ docker stop web3 && docker rm web3
$ docker stop haproxy && docker rm haproxy
$ docker network rm mynetwork
```

En esta referencia puedes encontrar los típicos problemas que se presentan al desplegar HAProxy y cómo resolverlos: [Troubleshooting HAProxy Errors](https://www.digitalocean.com/community/tutorial_series/common-haproxy-errors)


# Entrega de la práctica a traves de PRADO. Documentación y evaluación de la práctica.

Para que la práctica sea evaluable debe ser entregada dentro del plazo requerido indicado en PRADO. Todas las prácticas que estén fuera de plazo no serán evaluadas y no podrán defenderse. Además de la entrega a través de PRADO, todos los estudiantes deben realizar una DEFENSA de la práctica, a la que serán convocados por el profesor en horario de clase. En dicha defensa, el estudiante desplegará los servicios solicitados por el profesor y justificará las decisiones tomadas y los detalles de configuración ante las preguntas del profesor. En caso de no justificar adecuadamente sus respuestas o no exhibir los conocimientos mínimos necesarios, la calificación de la práctica será *Suspenso*. 

El estudiante **deberá entregar un .zip con la documentación y todos los ficheros necesarios para el despliegue de los servicios que ha creado**. 

La **documentación** de la entrega debe contener:

- README.md: fichero en formato markdown llamado  que contenga la documentación de la práctica que incluya los siguientes apartados:

    - Nombre del alumno

    - Entorno de desarrollo y de producción utilizado. Especificar con detalle las versiones de sistema operativo, máquinas virtuales, gestor de contenedores, etc. 

    - Descripción de la práctica y problema a resolver

    - Servicios desplegados y su configuración. Incluye todos los detalles necesarios. Incluye las instrucciones para lanzar la provisión de servicios.

    - Conclusiones

    - Referencias bibliográficas y recursos utilizados


## Plazos de entrega

Plazo de entrega en PRADO: Hasta el 14 de Marzo de 2025 a las 23:59 hrs.

## Defensa de la práctica

Será después de la entrega en horario de clase de prácticas. El profesor irá indicando en clase cuándo se realizará cada defensa. 

## Criterios de evaluación

Esta práctica incluye una tarea obligatoria para superar la práctica y dos tareas adicionales para alcanzar la máxima calificación. La tarea obligatoria para superar la práctica es la Tarea 1 descrita en la Sección 2.2. Las tareas adicionales para alcanzar la máxima puntuación son las tareas 2 y 3 de la Sección 2.2. Los criterios de evaluación específicos que se tendrán en cuenta para estas tareas son:  

**Evaluación de la tarea obligatoria para superar la práctica**: 

 - Se evaluará si el estudiante despliega con éxito los servicios según la arquitectura descrita en el Escenario 1 con Docker o Docker-compose. 
 - Los ficheros de configuración y documentación deben incluir con todos los detalles necesarios. 
 - El despliegue de los servicios debe realizarse sin errores y los servicios deben funcionar correctamente. 
 - Se valorará que el estudiante cree al menos una nueva categoría de usuarios en LDAP y distintos usuarios nuevos para simular un entorno laboral pequeño pero realista. 

**Evaluación de las tareas adicionales para alcanzar la máxima calificación**: 

Se evaluará: 
 - Documentación que incluya una descripción completa de los despliegues y los detalles de configuración. 
 - Despliegue con éxito de servicios según la arquitectura expuesta en el Escenario 2 de la práctica. 
 - Uso de Docker-compose y Kubernetes para despliegue con éxito de servicios. Se valorará que se realice un despliegue con Docker-compose y el mismo despliegue con Kubernetes. 
 - Proveer de alta disponibilidad con la replicación de, al menos, uno de los servicios ofrecidos. 
 - Proveer de un proxy invertido con balanceo de carga con HAProxy, la funcionalidad incluida en Kubernetes u otra herramienta de balanceo de carga. 


# REFERENCIAS

## LDAP
- https://www.openldap.org/doc/admin26/quickstart.html
- https://computingforgeeks.com/run-openldap-server-in-docker-containers/#google_vignette
- https://github.com/osixia/docker-openldap

## HAProxy
- http://docs.haproxy.org/2.6/intro.html 
