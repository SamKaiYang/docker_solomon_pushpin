#!/bin/bash
# ref: https://www.e-learn.cn/content/wangluowenzhang/1623072
# `python-catkin-tools` is needed for catkin tool
# `python3-dev` and `python3-catkin-pkg-modules` is needed to build cv_bridge
# `python3-numpy` and `python3-yaml` is cv_bridge dependencies
# `ros-kinetic-cv-bridge` is needed to install a lot of cv_bridge deps. Probaply you already have it installed.
#sudo apt-get install -y python-catkin-tools python3-dev python3-catkin-pkg python3-catkin-pkg-modules python3-numpy python3-yaml ros-melodic-cv-bridge
sudo apt-get install -y python-catkin-tools python3-dev python3-catkin-pkg-modules python3-numpy python3-yaml ros-melodic-cv-bridge
# Create catkin workspace
cd ../../
#docker fail fix
#mkdir catkin_workspace
cd catkin_workspace
catkin init
# Instruct catkin to set cmake variables
catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so
# Instruct catkin to install built packages into install place. It is $CATKIN_WORKSPACE/install folder
catkin config --install
# Clone cv_bridge src
#docker fail fix
#git clone -b melodic https://github.com/ros-perception/vision_opencv.git src/vision_opencv

# Find version of cv_bridge in your repository
#docker fail fix
#apt-cache show ros-melodic-cv-bridge | grep Version
# Checkout right version in git repo. In our case it is 1.13.0
cd src/vision_opencv/
cp cv_bridge/CMakeLists.txt ../

#git checkout 1.13.0
mv ../CMakeLists.txt cv_bridge
cd ../../
# Build
catkin build cv_bridge
# Extend environment with new package
source install/setup.bash --extend