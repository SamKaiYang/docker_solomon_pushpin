#!/bin/bash
# ref: https://www.e-learn.cn/content/wangluowenzhang/1623072
# `python-catkin-tools` is needed for catkin tool
# `python3-dev` and `python3-catkin-pkg-modules` is needed to build cv_bridge
# `python3-numpy` and `python3-yaml` is cv_bridge dependencies
# `ros-kinetic-cv-bridge` is needed to install a lot of cv_bridge deps. Probaply you already have it installed.
sudo apt-get install -y python-catkin-tools python3-dev python3-catkin-pkg-modules python3-numpy python3-yaml ros-melodic-cv-bridge
# Create catkin workspace
cd ../../
mkdir catkin_workspace
cd catkin_workspace
catkin init
# Instruct catkin to set cmake variables
catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so
# Instruct catkin to install built packages into install place. It is $CATKIN_WORKSPACE/install folder
catkin config --install
# Clone cv_bridge src
mkdir src && cd src
git clone -b melodic https://github.com/ros-perception/vision_opencv.git

cd ..
# Build
catkin build cv_bridge
# Extend environment with new package
source install/setup.bash --extend
