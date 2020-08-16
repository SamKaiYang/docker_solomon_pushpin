# 這個映像檔內包含
1. Ubuntu 18.04
2. ROS melodic
3. yolo v4 ROS package
4. OpenCV3.2
5. Cuda 10.2
6. Realsense SDK & library

# Now create a script to run the image called run_my_image.bash

```
XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

nvidia-docker run -it \
    --user=root \
    --net=host \
    --rm --ipc=host \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --runtime=nvidia \
    --privileged \
    --volume=/dev:/dev \
    samkaiyang/ubuntu_solomon:($tag_version))\
    /bin/bash
```
# Make the script executable
```
chmod a+x run_my_image.bash
```
# Execute the script
```
./run_my_image.bash
```
# If you want to add multiple terminals, you can enter the following commands in the new terminal
```
docker exec -it --user root ($CONTAINER ID) /bin/bash
```
# Run yolov4 use realsense Pre-work(open docker container)
```
cd /Documents/yolov4_ws/src/rs_d435i
source create_catkin_ws.sh
cd /Documents/yolov4_ws
catkin_make
```
# Run yolov4 use realsense(open docker container)
```
source devel/setup.bash
roslaunch darknet_ros yolo_v4.launch
```
-open the new terminal(open docker container)
```
cd /Documents/yolov4_ws
source devel/setup.bash
roslaunch realsense2_camera rs_rgbd.launch align_depth:=true filters:=pointcloud
```