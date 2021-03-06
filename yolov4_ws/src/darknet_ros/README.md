# Yolo v4使用在ROS架構方法

- yolov4 darknet下載
- 參數調整解釋
- usb_cam匯入
- 實際測試

## Prepare
- 軟體環境：Ubuntu18.04,ROS-melodic,OpenCV3.2(代碼中僅能使用3.2以下)

## How to used
### build
```
cd 自己的workspace/src
git clone https://github.com/SamKaiYang/darknet_ros.git
git clone https://github.com/bosch-ros-pkg/usb_cam.git
cd darknet_ros
git clone https://github.com/AlexeyAB/darknet.git
sudo apt-get install ros-melodic-image-view
sudo apt-get install ros-melodic-usb-cam
cd ../..
catkin_make
source devel/setup.bash
```
### Download weights
-下載yolo v4權重,請至此雲端下載
https://drive.google.com/file/d/1cewMfusmPjYWbrnuJRuKhPMwRe_b9PaT/view

-並請放置在
自己的workspace/src/darknet_ros/darknet_ros/yolo_network_config/weights

### 攝影機參數修改
- 修改影像輸入usb_cam-test.launch
路徑為自己的workspace/src/usb_cam/launch內
```
<param name="video_device" value="/dev/攝影機rgb影像位置" />
<param name="image_width" value="輸入影像寬" />
<param name="image_height" value="輸入影像高" />
```
### 實際運行
```
cd 自己的workspace/
source devel/setup.bash
roslaunch usb_cam usb_cam-test.launch
```

- 在開啟一個終端
```
cd 自己的workspace/
source devel/setup.bash
roslaunch darknet_ros yolo_v4.launch
```


