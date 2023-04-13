# Practice 2

Implementing facial recognition using Functions-as-a-Service


**Objectives of the practice:**

- Install and deploy a tool for container orchestration: Kubernetes.
- Deploy the functionality of the function catalogue and functions service through OpenWisk or OpenFaaS.
- Implement a scalable function that would become a component for biometric identitication of users based on face images. 

## Description of the practice


The main idea of the practice is to create one or more functions that allow you to:

- Capture/collect an image (e.g. from a URL) as input to the function.
- The function must detect the faces that appear
- The function should return the image with the detected faces framed in a rectangle.

For this you will need the following in terms of platforms/tools to install:

- Install microk8s (or minikube). 
- Install a RAS platform: OpenFaaS or OpenWisk on top of the Kubernetes platform above.

Having done this, you will then need to create the role within the platform and add it to the role platform catalog.

**For function development you can choose any language that is supported by the functions-as-a-service platform. If you want to use another language for function design, you will need to implement the function from a container.**

If you are using node.js, java, or other languages, check the following examples:

- R https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/R
- GoLang https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/java
- Java https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions
- Node https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/node
- Python https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/python


## Function design (template with Python)

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

Specifically for the OpenFaaS platform example, the function would be created in this way:

```
$ faas-cli new --lang python facesdetection-python
```

This creates three files for you:

```
facesdetection-python/handler.py
facesdetection-python/requirements.txt
facesdetection-python.yml
```

Let's edit the `handler.py` file:

```
def handle(req):
    ...
    ...
    ...
    
```

where you have to include the functionality of the function.


### Generic example function with Python

This is an example of code that detects faces using a pretrained classifier:

```
import cv2

# Load the cascade Classifier
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
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

> **Remember that the result of the image composition must be sent to the user or saved in the service so that it can be downloaded or viewed.**


##  Delivery of practice

The delivery of the practice consists of 3 parts:

1. Development and description of the steps to set up the platform for the FaaS functions service, in one of the existing platforms (OpenFaas, OpenWhisk, ...).
2. Implementation of the face detection function in the selected language (python, node.js, etc.).
3. Steps for the deployment of the implemented function within the selected OpenFaaS platform.

All these steps must be documented in the delivery of the practice. For the delivery, all the material must be packaged in a zip file and uploaded to PRADO by the  deadline set. Subsequently, the day after the delivery, a Pull Request will be made to the repository of the subject to store the practice 2 as it was done in the first practice.

The zip file must contain the following:

- Platform deployment material
- Implemented function and its code
- Script to deploy the function on the chosen platform.

Deadline for submission: 08-Jun-2022 23:59:00


## References 

- FaaS Examples and Function deployment: https://github.com/openfaas/faas/tree/master/sample-functions

