# Practice 2

Implementing face recognition using Functions-as-a-Service


## Objectives of the practice: 

- Install and deploy a tool for container orchestration: Kubernetes.
- Deploy the functionality of the function catalogue and functions service through OpenFaaS.
- Deploy different available functions for FaaS for face recognition. 
- Implement a scalable function that would become a component for biometric identification of users based on face images. 

The main idea of the practice is to create one or more functions that allow you to:

- Capture/collect an image (e.g. from a URL) as input to the function.
- The function must detect the faces that appear
- The function should return the image with the detected faces framed in a rectangle.


## Installation requirements (not needed on the UGR server)

For this you will need the following in terms of platforms/tools to install:

- Install kubernetes (e.g. minikube). Detailed instructions available in [Session 4](../session4/)  
- Install a RAS platform: OpenFaaS on top of Kubernetes. Detailed instructions available in [Session 7](../session7/)


## How to deploy an available function as a service

OpenFaaS has a function template store with some functions already available. This store is implemented with a JSON manifest, which is kept in a public repository on GitHub. Pull Requests (PRs) can be sent to the file to extend and update it, and companies can even have their own stores. The Function Store can be accessed via the CLI using the root command `faas-cli store`. From there, you can search for a function with `faas-cli store list` and deploy the one you want with `faas-cli store deploy`.

A full list of the functions avilable can be obtained with: 
```
$ faas-cli store list

FUNCTION              AUTHOR       DESCRIPTION
nodeinfo              openfaas     NodeInfo
env                   openfaas     env
sleep                 openfaas     sleep
shasum                openfaas     shasum
figlet                openfaas     Figlet
curl                  openfaas     curl
printer               openfaas     printer
youtube-dl            openfaas     youtube-dl
sentimentanalysis     openfaas     SentimentAnalysis
hey                   openfaas     hey
nslookup              openfaas     nslookup
certinfo              stefanprodan SSL/TLS cert info
colorise              alexellis    Colorization
inception             alexellis    Inception
alpine                openfaas     alpine
face-detect-pigo      esimov       Face Detection with Pigo
ocr                   viveksyngh   Tesseract OCR
qrcode-go             alexellis    QR Code Generator - Go
nmap                  openfaas     Nmap Security Scanner
cows                  openfaas     ASCII Cows
text-to-speech        rorpage      OpenFaaS Text-to-Speech
mquery                rgee0        Docker Image Manifest Query
face-detect-opencv    alexellis    face-detect with OpenCV
face-blur             esimov       Face blur by Endre Simo
normalisecolor        alexellis    normalisecolor
coherent-line-drawing esimov       Line Drawing Generator from a photograph
openfaas-exif         servernull   Image EXIF Reader
openfaas-opennsfw     servernull   Open NSFW Model
identicon             rgee0        Identicon Generator
```
In order to search for some topic, you might use `grep`. For example, for searching for *face recognition* functions: 

```
$ faas-cli store list | grep face
face-detect-pigo      esimov       Face Detection with Pigo
face-detect-opencv    alexellis    face-detect with OpenCV
face-blur             esimov       Face blur by Endre Simo
```

We can see there are two functions for face recognition already available in the OpenFaaS Template Store. We can find more information on them with `faas-cli store inspect`: 
```
$ faas-cli store inspect face-detect-pigo
Title:       Face Detection with Pigo
Author:      esimov
Description: 
Detect faces in images using the Pigo face detection library. You provide an
image URI and the function draws boxes around the detected faces.

Image:    esimov/pigo-openfaas:0.1
Process:  
Repo URL: https://github.com/esimov/pigo-openfaas
Environment:
-  output_mode: image
-  input_mode:  url

Labels:
-  com.openfaas.ui.ext: jpg

$ faas-cli store inspect face-detect-opencv
Title:       face-detect with OpenCV
Author:      alexellis
Description: 
Detect faces in images. Send a URL as input and download a file with boxes drawn
around detected faces. From our friend Nic Jackson

Image:    alexellis2/facedetect:0.1
Process:  
Repo URL: https://github.com/alexellis/facedetect-openfaas
Environment:
-  output_mode: image
-  input_mode:  url

Labels:
-  com.openfaas.ui.ext: jpg


```
In these descriptions we can find the repositories, authors and some brief instructions on how both of these functions work. For example, they both take an URL of an image as input, and return an image file as output with boxes drawn around detected faces. 

To deploy these functions run: 
```
$ faas-cli store deploy face-detect-pigo

Deployed. 202 Accepted.
URL: http://127.0.0.1:8080/function/face-detect-pigo

$ faas-cli store deploy face-detect-opencv

Deployed. 202 Accepted.
URL: http://127.0.0.1:8080/function/face-detect-opencv
```

Here you get the URLs of the two functions. You can also see them now in the GUI OpenFaaS portal: `http://127.0.0.1:8080/ui/`. **On the UGR server, replace this with the correct URL and port, as shown in [Session 7](../session7/)**

You can run the functions in the UI by entering an URL for an image in the *Request body* field as shown in the following capture: 

![](invoke-face-detect.png)

and clicking on *INVOKE*. You can also run the function from the CLI with curl: 

```
curl -d https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCdio_Sf9aON6NjLHo5fXjG1HNZzWCaTsUjQ http://127.0.0.1:8080/function/face-detect-pigo -o test.png
```

where: 
- *-d* is for specifying that this URL is a data input for the second URL (the function)
- *-o* is for storing the output into a file (called *test.png* in this case) 

Evaluate both functions: `face-detect-pigo` and `face-detect-opencv` on some test images you can find online such as `https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCdio_Sf9aON6NjLHo5fXjG1HNZzWCaTsUjQ` to check if they work properly. 



## Developing your own functions for FaaS

**For function development you can choose any language that is supported by the functions-as-a-service platform. If you want to use another language for function design, you will need to implement the function from a container.**

If you are using node.js, java, or other languages, check the examples [here.](https://github.com/openfaas/faas/tree/master/sample-functions)

## My first function (template with Python)

Specifically for the OpenFaaS platform example, the function would be created in this way:

```
$ faas-cli new --lang python3-http facesdetection-python
```

This creates the following files for you:

```
stack.yaml
facesdetection-python/handler.py
facesdetection-python/handler_test.py
facesdetection-python/requirements.txt
facesdetection-python.yml
```

The `handler.py` file contains your code that responds to a function invocation:
```
def handle(event, context):
    return {
        "statusCode": 200,
        "body": "Hello from OpenFaaS!"
    }
```
Edit the `handler.py` file to the following so that it will print back the request to the user:

```
def handle(event, context):
    return {
        "statusCode": 200,
        "body": "Hello from OpenFaaS!"
        "Input event: {}".format(event)
        "Input context: {}".format(context)
    }
```


The `requirements.txt` file can be used to install pip modules at build time. Pip modules add support for add-ons like MySQL or Numpy (machine learning).


The `stack.yaml` contains information on how to build and deploy your function:

version: 1.0
provider:
  name: openfaas
  gateway: http://127.0.0.1:8080
functions:
  facesdetection-python:
    lang: python3-http
    handler: ./facesdetection-python
    image: yourRegistryPrefixWillBeHere/facesdetection-python:latest



The main fields we want to study here are:

- `lang`: The name of the template to build with.
- `handler`: The folder (not the file) where the handler code is to be found.
- `image`:  The Docker image name to build with its appropriate prefix for use with docker build / push. It is recommended that you change the tag on each change of your code, but you can also leave it as latest.

You can largely ignore the `provider` fields, which are optional, but they do allow you to hard-code an alternative gateway address other than the default.

Now, there are three parts to getting your function up and running both initially and for updating. Run the following from the folder where `stack.yaml` is located:

- `faas-cli build`: Create a local container image, and install any other files needed, like those in the requirements.txt file.
- `faas-cli push`: Transfer the function’s container image from our local Docker library up to the hosted registry.
- `faas-cli deploy`: Using the OpenFaaS REST API, create a Deployment inside the Kubernetes cluster and a new Pod to serve traffic.

All of those commands can be combined with the `faas-cli up` command for brevity both initially and for updating.

```
$ faas-cli up -f facesdetection-python.yml
```

Wait a few moments, and then you will see a URL printed `http://127.0.0.1:8080/function/facesdetection-python`

That’s it! You can now invoke your function using the UI, curl, your own separate application code, or the faas-cli. The curl command is as follows:

```
$ curl --data "Hello!" http://127.0.0.1:8080/function/facesdetection-python 
Input: Hello!
```

Now you have your first function deployed to OpenFaaS. This function echoes whatever message it gets as input (according to the code in `handler.py`). Now you need to change the code so it actually detects faces. 


### Face detection function with Python

For the design of the face recognition function you can use pre-trained models that allow you to do the detection without having to create a model from scratch. 

The pseudocode function could look like the following:

```
def function(input_URL)
  model=load_faces_models
  image=read_image_from_URL
  faces=detect_faces(model,image)
  imagefaces=add_detection_frames_to_the_original_image(faces, image)
  return imagefaces or save_image(output_URL)  
```

This is an example of code that detects faces using a pretrained classifier called `haarcascade_frontalface_default.xml` from the [OpenCV project](https://github.com/opencv/opencv/tree/4.x/data/haarcascades):

```
import cv2

# Load the cascade Classifier
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades +'haarcascade_frontalface_default.xml')
# Read the input image
img = cv2.imread('test.jpg')
# Convert into grayscale
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
# Detect faces
faces = face_cascade.detectMultiScale(gray, 1.1, 4)
# Draw rectangle around the faces
for (x, y, w, h) in faces:
    cv2.rectangle(img, (x, y), (x+w, y+h), (255, 0, 0), 2)
# Display the output
cv2.imshow('img', img)
```

**You should adapt this code so it takes the URL of an image, preforms the face detection on the image and the result is sent to the user or saved in the service so that it can be downloaded or viewed. Any modification to improve this code and the face detection precision will be taken into account for the evaluation of the assignment.** 

## Alternatives to Face Recognition

If you are interested in a different application to be provided as a service with OpenFaaS, please suggest your proposed application to the teacher for his approval. A hot alternative right now is Image Segmentation as FaaS with the [Segment Anything Model by META](https://github.com/facebookresearch/segment-anything), for example, but feel free to suggest any other useful application for your academic/research/professional context you would like to work on. 


##  Delivery of practice

The delivery of the practice consists of 3 parts:

1. Development and description of the steps to set up the platform for the FaaS functions service in OpenFaas (if you prefer some other existing platform for FaaS, please inform the teacher).
2. Implementation of the face detection function in the selected language (python, node.js, etc.). Any improvements of the basic face detection function provided should be described and will be taken into account for the evaluation of the practice. 
3. Steps for the deployment of the implemented function within the selected OpenFaaS platform.

All these steps must be documented in the delivery of the practice. For the delivery, all the material must be packaged in a zip file and uploaded to PRADO by the  deadline set. 

The zip file must contain the following:

- Platform deployment material
- Implemented functions with a detailed description of any improvements you added to the basic code to achieve a better  performance. 
- Script to deploy the function on OpenFaaS.

Deadline for submission: 21-May-2023 23:59:00


## References 

- FaaS Examples and Function deployment: https://github.com/openfaas/faas/tree/master/sample-functions
- OpenCV: https://github.com/opencv/opencv
