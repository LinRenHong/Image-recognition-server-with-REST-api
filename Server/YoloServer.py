# coding=UTF-8

from yolo import YOLO
from PIL import Image
import numpy as np
import flask
import io
import json
import base64
import requests
from bs4 import BeautifulSoup
from keras.applications import ResNet50
from keras.preprocessing.image import img_to_array
from keras.applications import imagenet_utils


app = flask.Flask(__name__)
yolo = None
model = None


def hrefCrawler(target):
    Searchengine_url = 'https://www.google.com.tw/search'
    
    # 查詢參數
    Keywords = {'q': target}
    result = ""
    
    x = requests.get(Searchengine_url, params=Keywords)
    
    if x.status_code == requests.codes.ok:
        
        soup = BeautifulSoup(x.text, 'html.parser')
        
        # print(soup.prettify())
        
        term = soup.select('div.g > h3.r > a[href^="/url"]')
        for r in term:
            # 標題
            #print(r.text)
            result += r.text + "\n"
            # 網址
            #print(r.get('href'))
            result += r.get('href').split('/url?q=')[1].split('&')[0] + "\n\n"
        
        return result


def load_model():
    # load the pre-trained Keras model (here we are using a model
    # pre-trained on ImageNet and provided by Keras, but you can
    # substitute in your own networks just as easily)
    global model
    model = ResNet50(weights="imagenet")


def prepare_image(image, target):
    # if the image mode is not RGB, convert it
    if image.mode != "RGB":
        image = image.convert("RGB")

    # resize the input image and preprocess it
    image = image.resize(target)
    image = img_to_array(image)
    image = np.expand_dims(image, axis=0)
    image = imagenet_utils.preprocess_input(image)
    
    # return the processed image
    return image



@app.route("/predict", methods=["POST"])
def predict():
    # initialize the data dictionary that will be returned from the view
    result = {"success": False}
    
    # ensure an image was properly uploaded to our endpoint
    if flask.request.method == "POST":
        if flask.request.data != b'':
            data = flask.request.data
            data = data.decode('utf-8')
            dictionary = json.loads(data)
            
            if "image" in dictionary:
                image = dictionary['image'].encode('utf-8')
                image = base64.decodebytes(image)
            else:
                return flask.jsonify(result)
        else:
            return flask.jsonify(result)


        # read the image in PIL format
        image = Image.open(io.BytesIO(image))

        # Use Yolo to do object detect
        yoloResult = yolo.detect_image(image)

        # convert PIL.Image object to bytes
        buffer = io.BytesIO()
        yoloResult.save(buffer , format='JPEG')
        img_Bytes = buffer.getvalue()

        # convert bytes to base64
        img_b64 = base64.b64encode(img_Bytes)

        # convert base64 to string, because json can't transfer 'Bytes' object
        img_str = img_b64.decode('utf-8')
        result["result"] = img_str
        
        image = prepare_image(image, target=(224, 224))
        preds = model.predict(image)
        classificationResults = imagenet_utils.decode_predictions(preds)
        
        result["predictions"] = []
        for (imagenetID, label, prob) in classificationResults[0]:
            r = {"label": label, "probability": float(prob)}
            result["predictions"].append(r)
        
        crawlerResult = hrefCrawler(result["predictions"][0]["label"])
        print(crawlerResult)
        result["href"] = crawlerResult
        
        result["success"] = True
        
        # return the data dictionary as a JSON response
        return flask.jsonify(result)
    else:
        print("Not Succeess")
        return flask.jsonify(result)





if __name__ == '__main__':
    load_model()
    yolo = YOLO()
    
    # here must be modify, YOUR_IP and YOUR_PORT
    app.run("0.0.0.0", port = 5050)
