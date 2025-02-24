<h1>Session 2: Docker</h1>

- [Session 2 Docker](#session-2-docker)
  * [Introduction to containers](#introduction-to-containers)
    + [1. What are containers](#1-what-are-containers)
    + [2. How containers differ from VMs](#2How-containers-differ-from-virtual-machines)
    + [3. Why do you (and don't) need containers](#3-why-do-you--and-don-t--need-containers)
  * [Introduction to Docker](#introduction-to-docker)
    + [1. Running first Docker container](#1-running-first-docker-container)
    + [2. Managing Docker images](#2-managing-docker-images)
    + [3. Managing Docker containers](#3-managing-docker-containers)
    + [4. Working with Docker containers](#4-working-with-docker-containers)
    + [5. Creating a new Docker image](#5-Creating-a-new-Docker-image---Dockerfiles)

# Docker

## Introduction to containers

In this section we provide a very short introduction to the general idea behind containers. We briefly discuss the situations when containers can be a good choice for your problem and when other solutions might be more fitting. During this training course, we focus on two containerisation technologies: Docker and Singularity. You are most likely to see these two used in the research environment, with Singularity becoming the technology of choice for High Performance Computing development (although Docker is not going from that space anytime soon).

### 1. What are containers

You may hear people say they are "running an image" or "running a container". These terms are often used interchangeably, although (like with Docker), they can mean different things - container being the running image.

The most important feature of containers, and where their real strength comes from, is that unlike "regular" applications, they can and often do perform all their work in isolation from their host OS. Your containers do not have to know what the rest of your OS is up to. They don't even have to have access to the same files as your host OS, or share the same network  (again it is possible to achieve that). Containers put a layer between your existing host filesystem and whatever you are running inside them.

Briefly, a container allows you to stick an application and all of its dependencies into a single package. This makes your application portable, shareable, and reproducible.

Containers foster portability and reproducibility because they package ALL of an applications dependencies... including its own tiny operating system!

This means your application won't break when you port it to a new environment. Your app brings its environment with it.

Here are some examples of things you can do with containers:

- Package an analysis pipeline so that it runs on your laptop, in the cloud, and in a high performance computing (HPC) environment to produce the same result.
- Publish a paper and include a link to a container with all of the data and software that you used so that others can easily reproduce your results.
- Install and run an application that requires a complicated stack of dependencies with a few keystrokes.
- Create a pipeline or complex workflow where each individual program is meant to run on a different operating system.


### 2. How containers differ from virtual machines

You will often hear the expression that "containers are like VMs", or "like VMs, but lighter". This may make sense on the surface. At the end of the day, containers make use of virtualisation, **BUT** a different kind of virtualisation. There are fewer moving components in the case of containers and the end result might be the same for the end user.

Containers remove a lot of components of virtual machines though: they do not virtualise the hardware, they do not have to contain a fully-fledged guest OS to operate. They have to rely on the host OS instead. VMs sit on top of the underlying hardware, whereas containers sit on top of the host OS.

![VM vs container](Virtual-Machine-and-Container-Deployments.png)

NIST Special Publication 800-190, Application Container Security Guide - Scientific Figure on ResearchGate. Available from: https://www.researchgate.net/figure/Virtual-Machine-and-Container-Deployments_fig1_329973333 [accessed 28 Jan, 2023]

Virtual Machines install every last bit of an operating system (OS) right down to the core software that allows the OS to control the hardware (called the kernel). This means that VMs:

- Are complete in the sense that you can use a VM to interact with your computer via a different OS.
- Are extremely flexible. For instance you an install a Windows VM on a Mac using software like VirtualBox.
- Are slow and resource hungry. Every time you start a VM it has to bring up an entirely new OS.

Containers share a kernel with the host OS. This means that Containers:

- Are less flexible than VMs. For example, a Linux container must be run on a Linux host OS. (Although you can mix and match distributions.) In practice, containers are only extensively developed on Linux.
- Are much faster and lighter weight than VMs. A container may be just a few MB.
- Start and stop quickly and are suitable for running single apps.

Because of their differences, VMs and containers serve different purposes and should be favored under different circumstances.

- VMs are good for long running interactive sessions where you may want to use several different applications. (Checking email on Outlook and using Microsoft Word and Excel).
- Containers are better suited to running one or two applications, often non-interactively, in their own custom environments.

For a more in-depth explanation of the differences between VMs and containers, please [**see this website by the IBM Cloud Team**](https://www.ibm.com/cloud/blog/containers-vs-vms)

### 3. Why you do (and don't) need containers

* Containers will provide a reproducible work environment.
* They go beyond just sharing your code: you provide a fully-working software
with all its required dependencies (modules, libraries, etc.).
* You can build self-contained images that meet the particular needs of your
  project. No need to install software "just in case", or install something to
  be used just once.
* You are no longer tied to the software and library versions installed on your host system.
  Need python3, but only python2 is available? There is an image for that.
* Your software still depends on hardware you run it on - make sure your results are consistent across different hardware architectures.
* Not the best for sharing large amounts of data (same as you wouldn't use git to share a 10GB file).
* Additional safety concerns, as e.g. Docker gives extra power to the user "out of the box". There is potential to do some damage to the host OS by an inexperienced or malicious user if your containerisation technology of choice is not configured or used properly.


## Introduction to Docker 

In this section you will learn the basics of Docker, arguably one of the most popular containerisation technologies. Since its initial release in 2013, Docker has been widely adopted in many areas of research and the ‘industry‘. It is used to provide access to e-commerce and streaming services, machine learning platforms and scientific pipelines (CERN, SKA, NASA).

More generally, you should use it as a tool for distributing consistent software environments. Currently it is only one of many existing container technologies that researchers can choose from. Two popular alternatives are Singularity (covered later) and Podman. Some solutions offer better support for High Performance Computing, while others provide a low-level control of the environment. There really is something for everyone.

Below is how a typical Docker workflow will look like:

- Create a Dockerfile and mention the instructions to create your docker image
- Run docker build command which will build a docker image
- Now the docker image is ready to be used, use docker run command to create containers

![](https://geekflare.com/wp-content/uploads/2019/07/dockerfile.png)


In this section you will learn all these steps.

- [**How to start Docker containers**](#1-running-first-docker-container)
- [**How to manage your Docker images**](#2-managing-docker-images)
- [**How to manage your Docker containers**](#3-managing-docker-containers)
- [**How to work with Docker containers**](#4-working-with-docker-containers)
- [**How to build a Docker image**](5-Creating-a-new-Docker-image---Dockerfiles)

### 1. Running first Docker container

For our first example, we will run a short Docker command to download the *Hello World* of **Docker images** and start our very first **Docker container**.

```bash

$ docker container run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
b8dfde127a29: Pull complete 
Digest: sha256:9f6ad537c5132bcce57f7a0a20e317228d382c3cd61edae14650eec68b2b345c
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

```

#### **Let's examine the command and the generated output step by step.**

- **The command that we execute**
  
    ```bash
    $ docker container run hello-world
    ...
    ```

    instructs Docker that we would like to start a container using a `hello-world` image. This command can also be written as `docker run hello-world`, omitting the `container` part. This change was [**introduced in 2017**](https://www.docker.com/blog/whats-new-in-docker-1-13/) with a major overhaul of the Docker CLI (Command Line Interface). If the version of Docker installed on your machine comes from before these changes were introduced (we strongly recommend that you upgrade it due to security reasons), the full command will not work and you will have to use the short version. This section however is written with the new versions of Docker in mind and will **follow the convention of using the extended versions of the commands**.

- **The next few lines**

    ```docker
    Unable to find image 'hello-world:latest' locally
    latest: Pulling from library/hello-world
    b8dfde127a29: Pull complete 
    Digest: sha256:9f6ad537c5132bcce57f7a0a20e317228d382c3cd61edae14650eec68b2b345c
    Status: Downloaded newer image for hello-world:latest
    ```

    tells us that Docker was not able to find this image on our machine and has to download it from the external repository. If you have used this particular image in the past, you will not see any information about Docker trying to download the image.

    You could also separate the `docker container run ...` command above into two instructions:

    ```bash
    $ docker image pull hello-world
    $ docker container run hello-world
    ...
    ```

    In this case we are very explicit and tell Docker to first download (pull) the image from the external repository and then start the container based on that image. If you already have the image on your host machine, you can skip the `pull` command. In this case, including the `docker image pull` separately can be seen as a bit redundant as Docker takes care of any missing images with `docker container run`. You can however just pull the image and not run it at all, or pull it when you have access to the Internet and later start the container when you are offline.

- **The rest of the output**

    The rest of the output is the most interesting part. It is an
    innocent-looking list, but as items 3 and 4 from that list explain, that
    particular part of the output was generated INSIDE the container and only
    then sent back to the terminal for us to see. That means we have **successfully
    created and run our very first Docker container**.

### 2. Managing Docker images

- **Examine local images**

    How does Docker know whether it has to download the image or that the image is already present on your computer? Can you have this knowledge as well? Docker keeps track of all the images and layers that you download. There usually is a directory on your system which contains all the currently downloaded images and the associated SHA256 keys used to identify them. This ensures that the same layer or image is not downloaded twice and can be reused if necessary. For an in-depth description on how Docker stores images, please refer to [**this help guide**](https://docs.docker.com/storage/storagedriver/).

    The placement and structure of relevant directories can be different depending on your Docker installation and require root permissions to access. There is however a short command that lists all the locally available images:

    ```bash
    $ docker image ls
    ...
    ```

    Depending on how long (if at all) you have been using Docker for, the output will show only a single image that we have used above or multiple (as many as few tens of) images, as seen below (this is what I see when I run the above command on my work PC - **you will see something different**)

    ```docker
    REPOSITORY                 TAG                      IMAGE ID       CREATED         SIZE
    <none>                     <none>                   670fa2d9f98c   2 months ago    3.14GB
    <none>                     <none>                   2187b33a009b   2 months ago    714MB
    <none>                     <none>                   16b9ad7fc05d   2 months ago    3.12GB
    python                     3.7-alpine               6c59ae21a586   2 months ago    41.6MB
    redis                      alpine                   f7cdff500577   2 months ago    32.3MB
    ubuntu                     18.04                    3339fde08fc3   3 months ago    63.3MB
    nvidia/cuda                10.0-devel-ubuntu18.04   f1cb864ecfaf   3 months ago    2.24GB
    nvidia/cuda                10.2-devel-ubuntu18.04   5fe1e15ef79b   3 months ago    2.96GB
    hello-world                latest                   d1165f221234   3 months ago    13.3kB
    jupyter/scipy-notebook     latest                   dab5e9968512   7 months ago    2.7GB
    nvidia/cuda                9.2-cudnn7-devel         0a6a8962363e   8 months ago    2.88GB
    nvidia/cuda                9.2-base                 7def1f9b9d8d   9 months ago    80.8MB
    nvidia/cuda                9.2-base-ubuntu18.04     7def1f9b9d8d   9 months ago    80.8MB
    nvidia/cuda                9.2-devel-ubuntu18.04    b06eca0e3d4a   9 months ago    2.2GB
    cuda                       8.0-base-ubuntu16.04     f240c010c4f2   10 months ago   142MB
    ubuntu                     16.04                    005d2078bdfa   14 months ago   125MB
    rabbitmq                   3.8.2                    b8956a8129ef   16 months ago   151MB
    nvidia/cuda                9.2-devel-ubuntu16.04    1874839f75d5   19 months ago   2.35GB
    nvidia/cuda                10.0-base-ubuntu18.04    841d44dd4b3c   19 months ago   110MB
    ```

    If you know its name, you can list just a specific image:

    ```bash
    $ docker image ls hello-world
    ...
    ```

    or even use wildcards if you are not sure about the full image name (was it `nvidia/cuda` or `nvidia/CUDA`?):

    ```bash
    $ docker image ls nvidia/*
    REPOSITORY    TAG         IMAGE ID       CREATED        SIZE
    nvidia/cuda   10.1-base   bfa75f8b799e   6 months ago   105MB
    nvidia/cuda   9.2-base    5eabb7ffec15   6 months ago   80.7MB
    ```

    This is the default output that tells us that there are two images starting with `nvidia/` available locally on our machine, with the `9.2-base` and `10.1-base` tags. You can treat the tags as an extra bit of information about the version of the image. Next comes the image ID, which is a shortened version of the SHA256 key (or digest, using Docker vocabulary) used to identify the image and information on when the image was created. This information refers to when the image was first built and not pulled.

    We have used the most basic version of the image listing command, with the exception of using wildcards. For a complete reference and advanced examples, such as formatting and filtering, please visit [**this docker images reference**](https://docs.docker.com/engine/reference/commandline/images/). **Quick note:** the above document refers to a `docker images` command, which is *an alias* to the full `docker image ls` command. All the options however will work with both versions of this command. You can still use it as a reference for the `--format` and `--filter` options.

- **Remove the image**

    We made sure that the container was no longer running and then we removed it. What if we want to go one step further and want to get rid of the underlying image? Docker has a fairly intuitive command for that as well - instead of removing a container, we tell it to remove the image instead:

    ```bash
    $ docker image rm  hello-world
    Untagged: hello-world:latest
    Untagged: hello-world@sha256:9f6ad537c5132bcce57f7a0a20e317228d382c3cd61edae14650eec68b2b345c
    Deleted: sha256:d1165f2212346b2bab48cb01c1e39ee8ad1be46b87873d9ca7a4e434980a7726
    Deleted: sha256:f22b99068db93900abe17f7f5e09ec775c2826ecfe9db961fea68293744144bd
    ```

    In this case we use the **image name** and Docker prints out the confirmation that it was removed successfully.

### 3. Managing Docker containers

- **Examine currently running containers**

    In the same way we listed the images currently available locally on our machine, we can examine currently running containers:

    ```bash
    $ docker container ls
    CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
    ```

    We see nothing really useful. This means there are no containers running at this moment in time.

    When we launched our `hello-world` container above, it started, it did the job it was designed to do and it stopped immediately. In the case of the `hello-world` image, the designers decided it should print out a helpful output once the container is launched successfully, but that may not always be the case.

    We still have an option to check whether our container was started at all. We can force Docker to list *all* the containers with the extra `-a` option:

    ```bash
    $ docker container ls -a
    CONTAINER ID   IMAGE                   COMMAND                  CREATED        STATUS                    PORTS     NAMES
    7dd021096f75   hello-world             "/hello"                 3 hours ago    Exited (0) 3 hours ago              trusting_herschel
    ```

    In this case we actually get some useful information about our container we have just run. We see that we launched the container, it ran and it exited with code 0, meaning a successful, error-free execution. We can also see when the container was created and when it completed its execution. As you have seen, we get the results from the `hello-world` container pretty much immediately, and therefore the `CREATED` and `Exited` times are the same, but generally this is not the case.

    Every container has a "human-readable" name assigned to it at launch. It makes it easier to refer to the container using that name instead of the container ID, listed in the first column of the above output. These names are randomly generated from a list of adjectives and famous scientists and Docker does not guarantee the name will repeat for the same container (it is extremely unlikely your container will have the same name as the one listed above).

    It is therefore important to provide a name with the `run` command using the `--name` option to ensure reproducible and predictable deployment. This is especially important when you run multiple  containers at the same time, e.g. making it easy to differentiate front- and backend Node-based containers that can have the same underlying image, or rely on automatic scripts that require predictable names.

    If you are running containers right now, you will see them as "Up", as below

    ```bash
    $ docker container ls -a
    CONTAINER ID   IMAGE            COMMAND                  CREATED        STATUS         PORTS     NAMES
    f1d9fa05caae   rabbitmq:3.8.2   "docker-entrypoint.s…"   2 months ago   Up 5 minutes             rabid_rabbit
    ```

- **Remove the container**

    Exited containers can be thought of as being hibernated - they are not running, their internal state is saved and they can be woken up and run again. When we are satisfied with the results provided by our container launch,  we might need to remove it. We can do this with the help of `container rm` command:

    ```bash
    $ docker container rm trusting_herschel
    trusting_herschel
    ```

    Here we used the Docker-assigned name to remove the container. We can also use the container ID to achieve the same result. Make sure you replace the name above with the name or the container ID that you got by running the `docker container ls -a` command.

### 4. Working with Docker containers

Using a `hello-world` image is one thing, actually doing some work with containers is another. 

We are going to experiment with a much more useful image: an official Python 3.10.2 image based on Debian bullseye (it's a slimmed down version to be more specific - 123MB vs over 900MB for the 'traditional' bullseye).

Instead of just running the image, we will first pull it:

```bash
$ docker image pull python:3.10.2-slim-bullseye
3.10.2-slim-bullseye: Pulling from library/python
a2abf6c4d29d: Pull complete 
27003db43ed4: Pull complete 
a41b33cb9814: Pull complete 
6ed4b1851bbe: Pull complete 
51db3bf96e69: Pull complete 
Digest: sha256:e7adb53c5bb371c55148dfea3c4a72f34d047c87e89b8958f8da759abe9c3f1e
Status: Downloaded newer image for python:3.10.2-slim-bullseye
docker.io/library/python:3.10.2-slim-bullseye
```

If we just run it, we won't get any output like when using the `hello-world` image (we will also explicitly test whether the container is running):

```bash
$ docker container run --name python-test python:3.10.2-slim-bullseye

$ docker container ls -a
CONTAINER ID   IMAGE                         COMMAND                  CREATED          STATUS                      PORTS     NAMES
67b36e6034d2   python:3.10.2-slim-bullseye   "python3"                27 seconds ago   Exited (0) 22 seconds ago             python-test
```

The container exits immediately, just like the `hello-world` one. That's because by default, there is no work to be done. We can change that. We can remove the container like we have done before, but this time, we can use the name we have provided explicitly with `--name` flag (I used `python-test`, feel free to name your container something else, just make sure you change the name in the commands that use it).

```bash
$ docker container rm python-test
python-test
```

I removed this container because I want to reuse the name and also keep my Docker containers to bare minimum. We can use the same image to actually start executing some code from INSIDE the running container. We will start slowly, I want to find out a version of Python available inside the running container:

```bash
$ docker container run --name python-test python:3.10.2-slim-bullseye python3 --version
Python 3.10.2
```

That's the version we expected to see based on the image we're using. Most importantly, this is the version that is shipped inside this Python image and executed inside our container. You do not have to have Python installed on your host machine, or can have a completely different version (for example I am running 3.8.5 on my host) - Python inside your container is not even aware of that other version.

But let's do some actual work. We will do it in two ways. First we will launch a very simple script that you can download from [**here**](./script.py). On the command line, you can use `wget` to download it, but make sure to download the "raw" version. You do not have to be familiar with Python to understand what it does: we simply print out a welcome message and perform some very basic operations.

As we have mentioned before, containers by default do not know much about their host machine. Most importantly, they do not share any files with it, so they will not be able to find our Python script and run it. We therefore have to make it available inside the container.  We launch our image it with the additional options that *mount* the data inside the container:

```bash
$ docker container run --name python-test-2 --mount type=bind,source=$(pwd),target=/scripts python:3.10.2-slim-bullseye python3 /scripts/script.py
Welcome to Docker Python
8
We  are  done!
```

The `--mount` option may seem a bit verbose if you have not seen it before, but it should be fairly easy to understand. First we specify the `type=bind` to tell Docker to use a bind mount (it is not the only type of mount we can have, but we are not going to cover them here). We then provide two [key]:[value] pairs separated by a comma ( , ) that specify the source and target directory and/or file. As we are using distinctive keys, the order of the pairs is not important, but try to keep it in some order for consistency.

Here we make only a single file available inside the container, but it is also possible to make whole directories available and bound to a directory inside your container.

**IMPORTANT:** bind mounts do not create a copy of the data! Your data is shared between your host and container environments. Any changes that you make to your data on the host side, will be visible inside the container and vice versa. Be careful if you are manipulating any data that you cannot afford to corrupt - it might be safer to make a copy in this case!

Making data available inside your container at a runtime has some obvious drawbacks. With that approach, your data and your software are no longer placed in a single environment. You have to rely on your end-users to  provide their own data or to be able to access your data from external sources. This can also increase the development time for your software, as you have to take into account and prevent errors that users can introduce if their data does not meet your requirements. The decision on whether to include the data inside your image during the build time or as a mount during the runtime will be entirely up to you and will depend on your project and user requirements.

Second approach can be running our image *interactively*. In this case our container will behave like a usual Python CLI interpreter and we can treat it as such.

```bash
$ docker container run --name python-test-3 -it python:3.10.2-slim-bullseye
Python 3.10.2 (main, Jan 18 2022, 20:00:03) [GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print("I'm inside the container")
I'm inside the container
```

However, we are not limited to running just Python. This particular image comes with bash installed, so we can make use of it. We can launch an interactive bash session and treat this container like a regular terminal (albeit with many things missing):

```bash
$ docker container run --name python-test-4 -it python:3.10.2-slim-bullseye /bin/bash
root@2decf291ee44:/# pwd
/
root@2decf291ee44:/# ls -l
total 64
drwxr-xr-x   1 root root 4096 Jan 18 20:02 bin
drwxr-xr-x   2 root root 4096 Dec 11 17:25 boot
drwxr-xr-x   5 root root  360 Jan 22 23:36 dev
drwxr-xr-x   1 root root 4096 Jan 22 23:35 etc
drwxr-xr-x   2 root root 4096 Dec 11 17:25 home
...
```

This way you can use containers not just for one-off jobs, but also use them for interactive work.

**IMPORTANT:**  Launching our container the way we did just now may seem innocent enough, but comes with a **serious security problem** If you look closely at the command line prompt, we are listed as a user `root`, meaning we have administrative privileges inside the container. This becomes a very serious issue if we give our container access to any external resources such as host disks or network. We usually do not perform our day-to-day activities with privileged accounts and we shouldn't do that inside our containers either.

We can change this default behaviour by providing a `--user` flag to our `run` command:

```bash
$ docker container run --user 1000:1000 --name python-test-5 -it python:3.10.2-slim-bullseye /bin/bash
I have no name!@46023ae04069:/$
```

We have launched a new container with user ID 1000 and group ID 1000 (the format is `--user [user ID]:[group ID]`. As we have not created this user inside the container, Docker has no idea who that user is exactly, but we can still perform various tasks with the same permissions as the original user on the host OS.

### 5.  Creating a new Docker image - Dockerfiles

Dockerfile is a simple text file with a set of command or instruction. These commands/instructions are executed successively to perform actions on the base image to create a new docker image.

Dockerfile syntax

```
#Line blocks used for commenting

command argument argument1 ... 
```

Commands to use for the Dockerfile:

- `FROM` – Defines the base image to use and start the build process.

- `RUN` – It takes the command and its arguments to run it from the image.

- `CMD` – Similar function as a RUN command, but it gets executed only after the container is instantiated.

- `ENTRYPOINT` – It targets your default application in the image when the container is created.

- `ADD` – It copies the files from source to destination (inside the container).

- `ENV` – Sets environment variables.

Firstly, let’s create a Dockerfile (you can same this under the name `mydockerfile`, e.g., using vim):

```
    FROM centos:7
    MAINTAINER manuelparra

    LABEL Remarks="This is a dockerfile example for CentOS system"

    RUN yum -y update && yum -y install httpd && \
            yum clean all

    
    EXPOSE 80

    WORKDIR /root

```

This is just a Dockerfile to create a container with a simple HTTPD service (Apache).

To build it:

```
docker build -f mydockerfile . -t myfirstcontainer
```

Now we are going to create a more complex application from a Dockerfile that serves a nodejs application.

Our Dockerfile will be the next:

```
FROM debian
# Copy application files
COPY . /app
# Install required system packages
RUN apt-get update
RUN apt-get -y install imagemagick curl software-properties-common gnupg vim ssh
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get -y install nodejs
# Install NPM dependencies
RUN npm install --prefix /app
EXPOSE 80
CMD ["npm", "start", "--prefix", "app"]

```

Clone this [repository](https://github.com/juan131/dockerfile-best-practices) to have all the files that are used in the sentence COPY.

Then run:

```
docker build -f nodeapp . -t nodeapp
```

Once this command is executed, you will have the image stored in Docker ready to launch the container:

```
# See docker images
docker images
```

And now run the container with this image:

```
docker run -d -p 80:80 nodeapp
```

# Control how much memory and CPU the containers use

In Docker, you can **limit CPU and memory usage** using `docker run` flags. Here’s how you can do it:

---

## **1. Limit RAM Usage in Docker**
### **Hard Memory Limit (`--memory`)**
To restrict a container’s memory usage to **512MB**, use:

```bash
docker container run --memory=512m --name python-test-4 -it python:3.10.2-slim-bullseye
```

- The container **cannot exceed** 512MB.
- If the container tries to use more memory, the **Out-of-Memory (OOM) killer** may terminate it.

Other formats:
- `--memory=1g` → **1GB limit**
- `--memory=256m` → **256MB limit**

---

### **Soft Memory Limit (`--memory-reservation`)**
This is a **soft limit**: the container tries to stay within this limit but can exceed it **if needed**.

```bash
docker run -it --memory=1g --memory-reservation=512m python:3.10.2-slim-bullseye
```

- The container starts with **512MB**.
- If memory pressure increases, it **may** be reduced to **512MB**.

---

### **Disable Swap Usage (`--memory-swap`)**
By default, if a container reaches the memory limit, it can start using **swap space**. To **disable swap**, set:

```bash
docker run -it --memory=512m --memory-swap=512m python:3.10.2-slim-bullseye
```

- This **prevents** the container from using swap.
- If you want some swap, set it larger than `--memory`:

```bash
docker run -it --memory=512m --memory-swap=1g python:3.10.2-slim-bullseye
```

- This allows **512MB RAM + 512MB Swap = 1GB total**.

---

## **2. Limit CPU Usage in Docker**
### **Limit CPU Cores (`--cpus`)**
To restrict a container to **1.5 CPU cores**, use:

```bash
docker run -it --cpus=1.5 python:3.10.2-slim-bullseye
```

- If the system has **4 cores**, the container can only use **1.5**.

---

### **Control CPU Shares (`--cpu-shares`)**
This sets **relative priority** (not an absolute limit). Containers with **higher shares** get more CPU time.

```bash
docker run -it --cpu-shares=512 python:3.10.2-slim-bullseye
```

- Default is **1024**.
- A container with `512` gets **half the CPU time** of one with `1024`.

---

### **Restrict CPU Affinity (`--cpuset-cpus`)**
To **assign specific CPU cores**, use:

```bash
docker run -it --cpuset-cpus="0,1" python:3.10.2-slim-bullseye
```

- The container can **only run on cores 0 and 1**.
- this may not work on our practice server

---

## **3. Combining CPU & Memory Limits**
You can **combine these flags** for better resource control:

```bash
docker run -it --memory=1g --cpus=2 python:3.10.2-slim-bullseye
```

- **1GB RAM limit**.
- **Uses max 2 CPU cores**.

---

## **4. Check Resource Usage**
To monitor **CPU & Memory** in real time:

```bash
docker stats
```

This shows live stats for all running containers.

---

## **Summary Table**
| Flag | Docker Example | Description |
|------|---------------|-------------|
| `--memory=<size>` | `--memory=512m` | Max RAM usage |
| `--memory-reservation=<size>` | `--memory-reservation=256m` | Soft memory limit |
| `--memory-swap=<size>` | `--memory-swap=1g` | Total RAM + Swap |
| `--cpus=<num>` | `--cpus=1.5` | Limit CPU cores |
| `--cpu-shares=<num>` | `--cpu-shares=512` | Set CPU priority |
| `--cpuset-cpus="<cores>"` | `--cpuset-cpus="0,1"` | Restrict to certain CPU cores |

## Limit hard disk usage

Docker also has an option for limit hard disk space of a container, as follows:

```bash
docker run -it --storage-opt size=500m  python:3.10.2-slim-bullseye
```

However, this will work only if the file system has quotas enabled, which is not the case on our practice server.








# Podman instead of Docker

Podman is designed to be a drop-in replacement for Docker, providing a similar set of commands without the need for a daemon. This design enhances security and allows for rootless container management. Podman offers a Docker-compatible command-line interface, allowing for a seamless transition. To facilitate the transition, you can alias Docker commands to Podman:


```bash
alias docker=podman
```


This alias enables the use of familiar Docker commands with Podman. For example, running `docker ps` will execute `podman ps` under the hood.

## Running Containers with Podman

The basic commands for managing containers in Podman mirror those of Docker. Here are some common operations:

- **Pulling an image:**

  
```bash
  podman pull ubuntu:latest
  ```


- **Running a container:**

  
```bash
  podman run -it --name mycontainer ubuntu:latest
  ```


- **Listing running containers:**

  
```bash
  podman ps
  ```


- **Stopping a container:**

  
```bash
  podman stop mycontainer
  ```


- **Removing a container:**

  
```bash
  podman rm mycontainer
  ```


These commands function similarly to their Docker counterparts, making it straightforward for you to adapt.

**3. Enforcing Resource Constraints with Podman**

Podman allows you to set resource limits on containers to control their CPU and memory usage in a similar way to Docker. This is particularly useful in multi-tenant environments or when running resource-intensive applications.

- **Limiting CPU Usage:**

  To restrict a container to use a specific number of CPUs, use the `--cpus` flag:

  
```bash
  podman run -it --cpus=1.5 ubuntu:latest
  ```


  This command limits the container to 1.5 CPUs.

  Alternatively, you can set CPU shares to define the relative weight of CPU time allocated to the container:

  
```bash
  podman run -it --cpu-shares=512 ubuntu:latest
  ```


Again, by default, containers have a CPU share of 1024. Setting it to 512 reduces the container's CPU weight compared to others.

- **Restricting CPU Cores:**

  To assign specific CPU cores to a container, use the `--cpuset-cpus` flag:

  
```bash
  podman run -it --cpuset-cpus=0,1 ubuntu:latest
  ```


  This command restricts the container's execution to cores 0 and 1.

- **Managing Volume Mounts:**

  To mount a host directory into a container with specific permissions, use the `-v` flag:

  
```bash
  podman run -it -v /host/data:/container/data:ro,Z ubuntu:latest
  ```


  In this example, `/host/data` is mounted to `/container/data` inside the container as read-only (`ro`). The `Z` option relabels the volume for SELinux.


# Exercises to train
- Dockerize a Node.js application following the instructions here: https://docs.docker.com/get-started/02_our_app/
- Dockerize this Python App: https://github.com/scottbrady91/Python-Email-Verification-Script. 















