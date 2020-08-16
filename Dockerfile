#要訪問CUDA開發工具，您應該使用devel映像。這些是相關的標籤：
# 1.nvidia/cuda:10.2-devel-ubuntu18.04
# 2.nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
FROM nvidia/cuda:10.2-devel-ubuntu18.04
#指定docker image存放位置
VOLUME ["/storage"]
MAINTAINER sam tt00621212@gmail.com

# root mode
USER root
# environment
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive
# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics


ARG SSH_PRIVATE_KEY

COPY ./opencvbuild /Documents/docker_pushpin/opencvbuild
COPY ./cmake-3.12.1 /Documents/docker_pushpin/cmake-3.12.1
COPY ./yolov4_ws /Documents/yolov4_ws
COPY ./flycapture /Documents/flycapture
WORKDIR /
RUN apt-get update &&  apt-get install -y --no-install-recommends make g++ && \
# Dockerfile for OpenCV with CUDA C++, Python 2.7 / 3.6 development 
# Pulling CUDA-CUDNN image from nvidia
# Basic toolchain 
    apt-get update && \
        apt-get install -y \
        build-essential \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libcurl4-openssl-dev \
        zlib1g-dev \
        nano \
        gedit \
        vim && \
    apt-get autoremove -y && \
    #set debconf-utils
    apt-get install software-properties-common -y &&\
    apt-get update &&\
    add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" &&\
    apt-get  update &&\
    apt install libjasper1 libjasper-dev -y && \
    apt-get update &&  apt-get install --assume-yes apt-utils  && \
    apt-get -y install debconf-utils && \
    #setting system clock
    apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime && \
    echo “Asia/Taipei” > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    export DEBIAN_FRONTEND=noninteractive && \
# solve Error debconf
    apt-get install dialog apt-utils -y && \
    echo '* libraries/restart-without-asking boolean true' |  debconf-set-selections && \
# Fix not find lsb-release
    apt-get update && apt-get install -y lsb-release && apt-get clean all && \
# Fix add-apt-repository: command not found error
    apt-get install -y software-properties-common && \
# Install ROS melodic
    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    apt update && \
    apt install -y ros-melodic-desktop-full && \
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc && \
    /bin/bash -c "source ~/.bashrc" && \
    apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential && \
    rosdep init && \
    rosdep update

    # update cmake 3.12.1
WORKDIR /Documents/docker_pushpin/cmake-3.12.1
RUN cmake . && \
    make -j8 && \
    sudo make install && \
    sudo update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force && \
    # Install opencv 3.2.0
    apt-get purge -y libopencv* && \
    apt-get install -y build-essential && \
    apt-get install -y cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev && \
    apt-get install -y python-dev python-numpy python3-dev python3-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev 

WORKDIR /Documents/docker_pushpin/opencvbuild/opencv-3.2.0
RUN mkdir -p build
WORKDIR /Documents/docker_pushpin/opencvbuild/opencv-3.2.0/build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local/ -DINSTALL_PYTHON_EXAMPLES=ON -DINSTALL_C_EXAMPLES=ON -DPYTHON_EXCUTABLE=/usr/bin/python -DOPENCV_EXTRA_MODULES_PATH=/Documents/docker_pushpin/opencvbuild/opencv_contrib-3.2.0/modules -DWITH_CUDA=OFF -DWITH_CUFFT=OFF -DWITH_CUBLAS=OFF -DWITH_TBB=ON -DWITH_V4L=ON -DWITH_QT=OFF -DWITH_GTK=ON -DWITH_OPENGL=ON -DENABLE_PRECOMPILED_HEADERS=OFF -DBUILD_EXAMPLES=ON .. && \
    make -j12 && \
    make install && \
    # source cuda 
    echo "export PATH=/usr/local/cuda/bin:$PATH" >> ~/.bashrc && \
    echo "export PATH=/usr/local/cuda-10.2/bin${PATH:+:${PATH}}" >> ~/.bashrc && \
    echo "export LD_LIBRARY_PATH=/usr/local/cuda/64:$LD_LIBRARY_PATH" >> ~/.bashrc && \
    #1.10
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc  
    #--
SHELL ["/bin/bash","-c"]
RUN source ~/.bashrc && \
# build ros yolo v4
    #---for cam show
    apt-get install -y ros-melodic-image-view && \
    apt-get install -y ros-melodic-usb-cam && \
    # add realsense package
    sudo apt-get update &&\
    #1.10
    sudo apt-get install -y libraw1394-11 libgtkmm-2.4-dev libglademm-2.4-dev libgtkglextmm-x11-1.2-dev libusb-1.0-0 &&\ 
    apt --fix-broken install && \
    #--
    apt-get update && \
    apt-get install ros-melodic-ddynamic-reconfigure
#1.10
WORKDIR /Documents/flycapture
RUN sudo sh install_flycapture.sh
#--
# set the version of the realsense library
ENV LIBREALSENSE_VERSION 2.36.0
ENV LIBREALSENSE_ROS_VERSION 2.2.15
# set working directory
RUN mkdir -p /code
WORKDIR /code
# install dependencies
RUN apt update && \
  DEBIAN_FRONTEND=noninteractive apt install -y \
  wget \
  python-rosinstall \
  python-catkin-tools \
  ros-melodic-jsk-tools \
  ros-melodic-rgbd-launch \
  ros-melodic-image-transport-plugins \
  ros-melodic-image-transport \
  libusb-1.0-0 \
  libusb-1.0-0-dev \
  freeglut3-dev \
  libgtk-3-dev \
  libglfw3-dev && \
  # clear cache
  rm -rf /var/lib/apt/lists/*
# install librealsense
RUN cd /tmp && \
  wget https://github.com/IntelRealSense/librealsense/archive/v${LIBREALSENSE_VERSION}.tar.gz && \
  tar -xvzf v${LIBREALSENSE_VERSION}.tar.gz && \
  rm v${LIBREALSENSE_VERSION}.tar.gz && \
  mkdir -p librealsense-${LIBREALSENSE_VERSION}/build && \
  cd librealsense-${LIBREALSENSE_VERSION}/build && \
  cmake .. && \
  make && \
  make install && \
  rm -rf librealsense-${LIBREALSENSE_VERSION}
# install ROS package
RUN mkdir -p /code/src && \
  cd /code/src/ && \
  wget https://github.com/IntelRealSense/realsense-ros/archive/${LIBREALSENSE_ROS_VERSION}.tar.gz && \
  tar -xvzf ${LIBREALSENSE_ROS_VERSION}.tar.gz && \
  rm ${LIBREALSENSE_ROS_VERSION}.tar.gz && \
  mv realsense-ros-${LIBREALSENSE_ROS_VERSION}/realsense2_camera ./ && \
  rm -rf realsense-${LIBREALSENSE_ROS_VERSION}
# build ROS package
RUN . /opt/ros/melodic/setup.sh && \
  catkin build


#1.10--
WORKDIR /Documents/yolov4_ws/src/rs_d435i
RUN sudo apt-get update && \
  apt-get install -y python3-pip python3-dev build-essential && \
  apt --fix-broken install && \
  #apt-get install -y python3-catkin-pkg && \
  pip3 install catkin_pkg
# SHELL ["/bin/bash","-c"]
# RUN source create_catkin_ws.sh
#--
WORKDIR /Documents/yolov4_ws/src/darknet_ros/darknet_ros/yolo_network_config/weights
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights

#1.10
WORKDIR /Documents/yolov4_ws
#RUN /bin/bash -c 'catkin_make'
#--
# 使用者新增
RUN useradd -ms/bin/bash iclab

USER iclab
WORKDIR /home/iclab

