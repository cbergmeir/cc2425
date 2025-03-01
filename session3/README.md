
<h1>Session 3: Singularity</h1>

- [Session 3 Singularity](#session-3-singularity)
  * [Introduction to Singularity](#session-3-singularity)
    + [Docker vs. Singularity](#Docker-vs.-Singularity)
  * [Installing and Set-up Singularity](#installing-and-set-up-singularity)
  * [Starting with Singularity containers](#starting-with-singularity-containers)
    + [The Singularity container image](#the-singularity-container-image)
      - [Supported container formats](#supported-container-formats)
      - [Supported Unified Resource Identifiers (URIs)](#supported-unified-resource-identifiers--uris-)
      - [Copying, sharing, branching, and distributing your image](#copying--sharing--branching--and-distributing-your-image)
    + [Preparing the work environment](#preparing-the-work-environment)
    + [The Singularity Usage Workflow](#the-singularity-usage-workflow)
    + [Singularity Commands](#singularity-commands)
    + [Run a test](#run-a-test)
    + [Using an image for SKA training](#using-an-image-for-ska-training)
    + [Pulling the new image](#pulling-the-new-image)
    + [Entering the images from a shell](#entering-the-images-from-a-shell)
    + [Executing command from a container](#executing-command-from-a-container)
    + [Running a container](#running-a-container)
    + [Build images](#build-images)
    + [Downloading a container from Docker Hub](#downloading-a-container-from-docker-hub)
    + [Building containers from Singularity definition files](#building-containers-from-singularity-definition-files)




# Session 3 Singularity


In this tutorial we will work with a containerization system called Singularity, which has many features that make it interesting for workflow development and long-term reproducibility.

We will cover the following:

- Why Singularity
- Preparing the working environment
- Basic use of Singularity
- Your own Container Hub
- Creating our first container
- Share your work


Singularity is a container platform (like Docker, PodMan, Moby, LXD, ... among other). It allows you to create and run containers that package up pieces of software in a way that is portable and reproducible. You can build a container using Singularity on your laptop, and then run it on many of the largest HPC clusters in the world, local university or company clusters, a single server, in the cloud, or on a workstation down the hall. Your container is a single file, and you don’t have to worry about how to install all the software you need on each different operating system.


**Advantages:**

- Easy to learn and use (relatively speaking)
- Approved for HPC (installed on some of the biggest HPC systems in the world)
- Can convert Docker containers to Singularity and run containers directly from Docker Hub
- [SingularityHub](https://cloud.sylabs.io/)


**Disadvantages:**

- Less mature than Docker
- Smaller user community
- Under very active development 

Singularity is focused for scientific software running in an HPC environent. 

### Aims

- Mobility of Compute
- Reproducibility
- User Freedom
- Support on Existing Traditional HPC

## Docker vs. Singularity

Given the popularity of Docker, why do we need *another* container platform? 

Let's first check what expert users say about Docker and what use cases are best for Singularity: 
https://pythonspeed.com/articles/containers-filesystem-data-processing/
https://www.reddit.com/r/docker/comments/7y2yp2/why_is_singularity_used_as_opposed_to_docker_in/
https://biohpc.cornell.edu/doc/singularity_v3.pdf

Here is a compilation of the facts we found. 

### Docker

Docker is currently the most widely used container software. It has several strengths and weaknesses that make it a good choice for some projects but not for others.

**philosophy**

Docker is built for running multiple containers on a single system and it allows containers to share common software features for efficiency. It also seeks to fully isolate each container from all other containers and from the host system.

Docker assumes that you will be a root user. Or that it will be OK for you to elevate your privileges if you are not a root user. See https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface for details.

**strengths**

- Mature software with a large user community
- Docker Hub!
    - A place to build and host your containers
    - Fully integrated into core Docker
    - Over 100,000 pre-built containers
    - Provides an ecosystem for container orchestration
- Rich feature set

**weaknesses**

- Difficult to learn
    - Hidden innards
    - Complex container model (layers)
- Not architected with security in mind
- Not built for HPC (but good for cloud)

Docker shines for DevOPs teams providing cloud-native micro-services to users. 

### Singularity

Singularity is a relatively new container software invented by Greg Kurtzer while at Lawrence Berkley National labs and now developed by his company Sylabs. It was developed with security, scientific software, and HPC systems in mind.

**philosophy**

Singularity assumes (more or less) that each application will have its own container. It does not seek to fully isolate containers from one another or the host system.

Singularity assumes that you will have a build system where you are the root user, but that you will also have a production system where you may or may not be the root user.

**strengths**

- Easy to learn and use (relatively speaking)
- Approved for HPC (installed on some of the biggest HPC systems in the world)
- Can convert Docker containers to Singularity and run containers directly from Docker Hub
- Singularity Container Services!
    - A place to build and share your containers securely

**weaknesses**

- Younger and less mature than Docker
- Smaller user community (as of now)
- Under active development (must keep up with new changes)

Singularity shines for scientific software running in an HPC environent. 

While Docker focuses on **isolation**, Singularity focuses on **integration**. 

We will use Singularity for the remainder of the class.

## Installing and Set-up Singularity (not needed on our server)

Here we will install the latest tagged release from GitHub. If you prefer to install a different version or to install Singularity in a different location, see these [Singularity docs](https://docs.sylabs.io/guides/latest/admin-guide/installation.html#).

We're going to compile Singularity from source code. First we'll need to make sure we have some development tools and libraries installed so that we can do that. On Ubuntu, run these commands to make sure you have all the necessary packages installed.

```
$ sudo apt-get update

$ sudo apt-get install -y build-essential libssl-dev uuid-dev libgpgme11-dev \
    squashfs-tools libseccomp-dev wget pkg-config git cryptsetup debootstrap
```

On CentOS, these commmands should get you up to speed.

```
$ sudo yum -y update 

$ sudo yum -y groupinstall 'Development Tools'

$ sudo yum -y install wget epel-release

$ sudo yum -y install debootstrap.noarch squashfs-tools openssl-devel \
    libuuid-devel gpgme-devel libseccomp-devel cryptsetup-luks
```

Singularity v3.0 was completely re-written in Go. We will need to install the Go language so that we can compile Singularity. This procedure consists of downloading Go in a compressed archive, extracting it to /usr/local/go and placing the appropriate directory in our PATH. For more details, check out the Go Downloads page.

```
$ wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz

$ sudo tar --directory=/usr/local -xzvf go1.13.linux-amd64.tar.gz

$ export PATH=/usr/local/go/bin:$PATH
```

Next we'll download a compressed archive of the source code (using the the wget command). Then we'll extract the source code from the archive (with the tar command).

```
$ wget https://github.com/singularityware/singularity/releases/download/v3.5.3/singularity-3.5.3.tar.gz

$ tar -xzvf singularity-3.5.3.tar.gz
```

Finally it's time to build and install!

```
$ cd singularity

$ ./mconfig

$ cd builddir

$ make

$ sudo make install
```


If everything went according to plan, you now have a working installation of Singularity. Simply typing singularity will give you a summary of all the commands you can use. Typing singularity help <command> will give you more detailed information about running an individual command.

You can test your installation like so:

```
$ singularity run library://godlovedc/funny/lolcow
```

You should see something like the following.

```
INFO:    Downloading library image
 _______________________________________
/ Excellent day for putting Slinkies on \
\ an escalator.                         /
 ---------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

Your cow will likely say something different (and be more colorful), but as long as you see a cow your installation is working properly.

This command downloads and "runs" a container from Singularity Container Library. (We'll be talking more about what it means to "run" a container later on in the class.)

In a following exercise, we will learn how to build a similar container from scratch. But right now, we are going to use this container to execute a bunch of basic commands and just get a feel for what it's like to use Singularity.

## Starting with Singularity containers


### The Singularity container image

Singularity makes use of a container image file, which physically includes the container. 

#### Supported container formats

- `squashfs`: the default container format is a compressed read-only file system that is widely used for things like live CDs/USBs and cell phone OS’s
- `ext3`: (also called writable) a writable image file containing an ext3 file system that was the default container format prior to Singularity version 2.4
- `directory`: (also called sandbox) standard Unix directory containing a root container image
- `tar.gz`: zlib compressed tar archive
- `tar.bz2`: bzip2 compressed tar archive
- `tar`: uncompressed tar archive


#### Supported Unified Resource Identifiers (URIs)

Singularity also supports several different mechanisms for obtaining the images using a standard URI format.

- `shub://` Singularity Hub is the registry for Singularity containers like DockerHub.
- `docker://` Singularity can pull Docker images from a Docker registry.
- `instance://` A Singularity container running as service, called an instance, can be referenced with this URI.


#### Copying, sharing, branching, and distributing your image

A primary goal of Singularity is mobility. The single file image format makes mobility easy. Because Singularity images are single files, they are easily copied and managed. You can copy the image to create a branch, share the image and distribute the image as easily as copying any other file you control!


### Preparing the work environment

You will need a Linux system to run Singularity natively. Options for using Singularity on Mac and Windows machines, along with alternate Linux installation options are discussed in the installation guides.

So after this part we assume that you have Singularity installed for your system.

### The Singularity Usage Workflow

There are generally two groups of actions you must implement on a container; management (building your container) and usage.

![Workflow](https://sylabs.io/guides/2.5/user-guide/_images/flow.png)

On the left side, you have your build environment: a laptop, workstation, or a server that you control. Here you will (optionally):

- develop and test containers using --sandbox (build into a writable directory) or --writable (build into a writable ext3 image)
- build your production containers with a squashfs filesystem.

And on the right side, a consumer profile for containers.


### Singularity Commands

To work with the Singularity there are really only a few commands that provide us with all the operations:

- `build` : Build a container on your user endpoint or build environment
- `exec` : Execute a command to your container
- `inspect` : See labels, run and test scripts, and environment variables
- `pull` : pull an image from Docker or Singularity Hub
- `run` : Run your image as an executable
- `shell` : Shell into your image

### Run a test

Go to the environment where you have Singularity installed to do some tests. You can test your installation like so:

```
vagrant@ska-training:~$ singularity pull docker://godlovedc/lolcow
```

This command will simply download an image that already exists in Docker (`docker://godlovedc/lolcow` from DockerHub: [lol docker](https://hub.docker.com/r/godlovedc/lolcow) ), and store it as a local file with SIF format.


Confirms you have a file named: `lolcow_latest.sif`: 

```
ls -l lolcow_latest.sif
```

Then, we execute the image as an executable, simply typing: 

```
vagrant@ska-training:~$ singularity run lolcow_latest.sif
 ____________________
< Beware of Bigfoot! >
 --------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

### Using an image for SKA training

We have prepared an image that is available in the Singularity image repository ( [link here](https://cloud.sylabs.io/library/manuparra/ska/skatrainingplot) ). This container image contains the following:

- It creates a python framework that includes the python libraries: `scipy`, `numpy` and `mathplotlib`.
- It includes a python application that draws a plot in a output file.

### Pulling the new image

This download takes about 300 MBytes.

```
vagrant@ska-training:~$ singularity pull library://manuparra/ska/skatrainingplot:latest
```

After that you will see a new file named `skatrainingplot_latest.sif` with the downloaded image.


### Entering the images from a shell

The shell command allows you to open a new shell within your container and interact with it as though it were a small virtual machine. This would be very similar to what you do with docker and run a shell with bash (`docker run .... /bin/bash`):

```
vagrant@ska-training:~$  singularity shell skatrainingplot_latest.sif
```

Once executed you will be connected to the container (you will see a new prompt):

```
Singularity skatrainingplot_latest.sif:~> 

```

From here you can interact with container, and  you are the *same user* as you are on the host system.

```
Singularity skatrainingplot_latest.sif:~> whoami

vagrant

Singularity skatrainingplot_latest.sif:~> id

uid=900(vagrant) gid=900(vagrant) groups=900(vagrant),27(sudo)

```

**NOTE**

If you use Singularity with the shell option and an image from `library://`, `docker://`, and `shub://` URIs this creates an ephemeral container that disappears when the shell is exited.

### Executing command from a container

The exec command allows you to execute a custom command within a container by specifying the image file. For instance, to execute the cowsay program within the `skatrainingplot_latest.sif` container:

To do that, type `exit` from Singularity container and you will return to your host machine. Here, we can execute commands within the container, but not entering on the container. Executing something and then exiting at the same time 

```
vagrant@ska-training:~$ singularity exec skatrainingplot_latest.sif python3
Python 3.8.10 (default, Nov 26 2021, 20:14:08) 
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.

``` 
This way you are running `python3` from the container with all the libraries that the container has provided. And once we exit the python shell we return to the host. 

Type `CTRL+D` to exit from the python3 shell, and you will return to your host machine.

This is very interesting because we can run something in the container environment that does something, in this case the container provides specific libraries, which are not on the host machine. To try this, we run the following on the host machine:

```
vagrant@ska-training:~$ python3
Python 3.6.9 (default, Dec  8 2021, 21:08:43) 
[GCC 8.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ModuleNotFoundError: No module named 'numpy'

```
You can see that we haven't installed `numpy`, so we can't use `numpy`.

Now we execute `python3` within the container:

```
vagrant@ska-training:~$ singularity exec skatrainingplot_latest.sif python3
Python 3.8.10 (default, Nov 26 2021, 20:14:08) 
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy

```

Our container has `numpy` and other libraries installed, so you can use them.

In this way we could use the container to execute a script that we have created and run it with all the environment that enables the container, in this case some libraries in some specific versions. 
This is important because it allows to isolate the host environment with our development, with this we could have different containers with different library versions for example. To test it, we create a `python` file in our host machine:

```
vi test.py
```

And we add the following content:

```
import numpy as np
a = np.arange(15).reshape(3, 5)
print(a)
```

Then we can execute it typing the following:


```
vagrant@ska-training:~$  singularity exec skatrainingplot_latest.sif python3 test.py
[[ 0  1  2  3  4]
 [ 5  6  7  8  9]
 [10 11 12 13 14]]

```

If we try it on our host machine:

```
vagrant@ska-training:~ $ python3 test.py 
Traceback (most recent call last):
  File "test.py", line 1, in <module>
    import numpy as np
ModuleNotFoundError: No module named 'numpy'
```


### Running a container

Singularity containers can execute runscripts. That is, they allow that when calling them from Singularity with the exec option, they execute a script that defines the actions a container should perform when someone runs it.

In this example for `lolcow_latest.sif` you can see a message, that is generated because for this container the developer has created a start point when you call Singularity with the option `run`.

```
vagrant@ska-training:~$ singularity run lolcow_latest.sif
 _____________________________________
/ You have been selected for a secret \
\ mission.                            /
 -------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

`run` also works with the `library://`, `docker://`, and `shub://` URIs. This creates an ephemeral container that runs and then disappears.

Now we try with our container. **Don't worry if you get some errors in the following or the files are not generated, we will later generate our own version of the container that fixes these issues.**:

```
vagrant@ska-training:~/builkd$ singularity run skatrainingplot_latest.sif 
-----------------------------------------------
SKA training: Git and Containers
Plot generated in example.png by default, please provide an output plot file
```

And now you can see that this command has generated an image called `example.png`.

With this option we can run an application already predefined in the container, but this is not always the default option and depends on how the container was built.

```
vagrant@ska-training:~/builkd$ singularity run skatrainingplot_latest.sif myplotforska.png
-----------------------------------------------
SKA training: Git and Containers
Plot generated in myplotforska.png file.
```

This command has generated an image called `myplotforska.png`.


**It is important to comment that a key feature is that from the container we have access to the host files in a transparent way.**

For instance:

```
vagrant@ska-training:~$ singularity shell skatrainingplot_latest.sif 
```

And then if you type `ls -l`, you will see your own files from the folder you were. *You are in the container* :smile:. 

So here, you can create a file:

```
Singularity skatrainingplot_latest.sif :~> echo "This is a SKA training" > hello.txt
```

You can see the file created inside the container but it is also in your host folder.

```
Singularity skatrainingplot_latest.sif :~> exit
vagrant@ska-training:~$ ls -l
...
hello.txt
...
```

**By default Singularity bind mounts `/home/$USER`, `/tmp`, and `$PWD` into your container at runtime.**

### Build images

And now the question is, how can I create my own container with my software?

With `build` option you can convert containers between the formats supported by Singularity. And you can use it in conjunction with a Singularity definition file to create a container from scratch and customize it to fit your needs.


### Downloading a container from Docker Hub

You can use build to download layers from Docker Hub and assemble them into Singularity containers.

```
$ singularity build lolcow.sif docker://godlovedc/lolcow
```

### Building containers from Singularity definition files

Singularity definition files,  can be used as the target when building a container. Using the Docker equivalence, these would be the Dockerfiles we use to build an image.

Here you can see an example of a definition file `lolcow.def`:

```
Bootstrap: docker
From: ubuntu:16.04

%post
    export DEBIAN_FRONTEND=noninteractive
    apt-get update || true
    apt-get install -y fortune cowsay lolcat || true
    dpkg --configure -a || true

%environment
    export LC_ALL=C
    export PATH=/usr/games:$PATH

%runscript
    fortune | cowsay | lolcat
```

We can build it with:

```
$ singularity build --fakeroot lolcow.sif lolcow.def
```

Now we can see how the test container we have made for ska is built (`skatraining.def`):

```
Bootstrap: docker
From: ubuntu:20.04

%post
export DEBIAN_FRONTEND=noninteractive
apt-get update || true
apt-get install -y vim python3 python3-pip || true
dpkg --configure -a || true
pip3 install matplotlib
pip3 install scipy
pip3 install numpy

cat > /plot.py << EOF
import numpy as np
import sys
from scipy.interpolate import splprep, splev

import matplotlib.pyplot as plt
from matplotlib.path import Path
from matplotlib.patches import PathPatch

plotname = sys.argv[1] if len(sys.argv) > 1 else "example.png"

N = 400
t = np.linspace(0, 3 * np.pi, N)
r = 0.5 + np.cos(t)
x, y = r * np.cos(t), r * np.sin(t)
fig, ax = plt.subplots()
ax.plot(x, y)
plt.xlabel("X value")
plt.ylabel("Y value")
plt.savefig(plotname)
print("-----------------------------------------------")
print("SKA training: Git and Containers")
print("Plot generated in " + plotname + " file.")
print("-----------------------------------------------")
EOF

%runscript
  if [ $# -ne 1 ]; then
        echo "-----------------------------------------------"   
        echo "SKA training: Git and Containers"   
        echo "Plot generated in example.png by default, please provide an output plot file"
  fi
  python3 /plot.py $1
```

Then we build with:

```
$ singularity build --fakeroot skatraining.sif skatraining.def
```

We now explain each of the components of the build file:

- Where the image comes from and what is the component:
```
Bootstrap: docker
From: ubuntu:20.04
```

- What will be done in the image to build it. In our case include some packages and libraries, and add a python file that makes some plots.
```
%post
```


- What we will execute when the container is called with the `run` option.
```
%runscript
```

And this is all for now with containers. In the following training sessions we will go deeper into the use of containers.

### Exercises to train

- Create a Singularity container for this Python App: https://github.com/scottbrady91/Python-Email-Verification-Script and run it to test that it works. Make it portable so the Singularity container downloads the git repository.   














