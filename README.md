# RESTful-server-image-recognition

## Quick Start
1. Because I use Git LFS push yolo model to my GitHub, so download yolo model from my [model_data](https://github.com/LinRenHong/RESTful-server-image-recognition/blob/master/Server/model_data/yolo.h5).
2. Replace Server/model_data/yolo.h5 with you download yolo.h5 from my [model_data](https://github.com/LinRenHong/RESTful-server-image-recognition/blob/master/Server/model_data/yolo.h5).
3. Change directory to Server/ and use `pip` install necesssary packages of python.
```
cd Server/
sudo pip install -r requirements.txt
```
4. Run the server(Default ip and port of server is `0.0.0.0:5050`, and your can modify it).
```
python YoloServer.py
```
5. Use `ifconfig | grep inet` to find your ip.
6. Use Xcode to open `REST Image Identify(Yolo)/REST Image Identify.xcodeproj`.
7. Select `ViewController.swift` and modify the variables `SERVER_IP = "YOUR_SERVER_IP"` and `SERVER_PORT = "YOUR_SERVER_PORT"` <- default is `5050`.
8. Run the app on your iOS device.
