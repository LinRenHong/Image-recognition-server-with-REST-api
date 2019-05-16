# RESTful-server-image-recognition

## Quick Start
1. Because I use Git LFS to push model to my GitHub, so you can download the model from my [model_data](https://github.com/LinRenHong/RESTful-server-image-recognition/blob/master/Server/model_data/yolo.h5).

2. Replace Server/model_data/yolo.h5 with yolo.h5 you downloaded from my [model_data](https://github.com/LinRenHong/RESTful-server-image-recognition/blob/master/Server/model_data/yolo.h5).

3. Change directory to Server/ and use `pip` to install necesssary packages of python.
```
cd Server/
sudo pip install -r requirements.txt
```

4. Run the server (Default `IP` and `port` of server is `0.0.0.0:5050`, and your can modify them in YoloServer.py).
```
python YoloServer.py
```

5. Use `ifconfig | grep inet` to find your ip.

6. Use Xcode to open `REST Image Identify(Yolo)/REST Image Identify.xcodeproj`.

7. Select `ViewController.swift` and modify the two variables, `SERVER_IP = "YOUR_SERVER_IP"` and `SERVER_PORT = "YOUR_SERVER_PORT"` <- default port of server is `5050`.

8. Run the app on your iOS device.
