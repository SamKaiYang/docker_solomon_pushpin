#FROM nvidia/cuda:10.2-runtime-ubuntu18.04
#要訪問CUDA開發工具，您應該使用devel映像。這些是相關的標籤：
# 1.nvidia/cuda:10.2-devel-ubuntu18.04
# 2.nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
FROM nvidia/cuda:10.2-devel-ubuntu18.04
#指定docker image存放位置
VOLUME ["/storage"]
MAINTAINER sam tt00621212@gmail.com

#root模式
USER root
#環境
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive

ARG SSH_PRIVATE_KEY

COPY ./opencvbuild /Documents/docker_pushpin/opencvbuild
#COPY ./darknet /Documents/docker_pushpin/darknet
COPY ./cmake-3.12.1 /Documents/docker_pushpin/cmake-3.12.1
COPY ./yolov4_ws /Documents/yolov4_ws
COPY myscript /Documents/myscript
COPY ./flycapture /Documents/flycapture
RUN  apt-get update &&  apt-get install -y --no-install-recommends make g++
# Dockerfile for OpenCV with CUDA C++, Python 2.7 / 3.6 development 
# Pulling CUDA-CUDNN image from nvidia
# Basic toolchain 
RUN apt-get update && \
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
    apt-get autoremove -y
WORKDIR /
# 2020/07/24 add 
RUN apt-get install software-properties-common -y &&\
    apt-get update &&\
    add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" &&\
    apt-get  update &&\
    apt install libjasper1 libjasper-dev -y

RUN  apt-get update &&  apt-get install --assume-yes apt-utils  && \
     apt-get -y install debconf-utils && \
    #setting system clock
     apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime && \
    echo “Asia/Taipei” > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    export DEBIAN_FRONTEND=noninteractive
#solve Error debconf
RUN apt-get install dialog apt-utils -y
RUN echo '* libraries/restart-without-asking boolean true' |  debconf-set-selections
#Fix not find lsb-release
RUN apt-get update && apt-get install -y lsb-release && apt-get clean all
#Fix add-apt-repository: command not found error
RUN  apt-get install -y software-properties-common
#--------Install ROS melodic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    apt update && \
    apt install -y ros-melodic-desktop-full && \
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc && \
    /bin/bash -c "source ~/.bashrc" && \
    apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential && \
    rosdep init && \
    rosdep update

#-----update cmake 3.12.1
WORKDIR /Documents/docker_pushpin/cmake-3.12.1
RUN cmake . && \
    make -j8 && \
    sudo make install && \
    sudo update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force

#----------------Install opencv 3.2.0
RUN  apt-get purge -y libopencv* && \
     apt-get install -y build-essential && \
     apt-get install -y cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev && \
     apt-get install -y python-dev python-numpy python3-dev python3-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev 

WORKDIR /Documents/docker_pushpin/opencvbuild/opencv-3.2.0
RUN mkdir -p build
WORKDIR /Documents/docker_pushpin/opencvbuild/opencv-3.2.0/build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local/ -DINSTALL_PYTHON_EXAMPLES=ON -DINSTALL_C_EXAMPLES=ON -DPYTHON_EXCUTABLE=/usr/bin/python -DOPENCV_EXTRA_MODULES_PATH=/Documents/docker_pushpin/opencvbuild/opencv_contrib-3.2.0/modules -DWITH_CUDA=OFF -DWITH_CUFFT=OFF -DWITH_CUBLAS=OFF -DWITH_TBB=ON -DWITH_V4L=ON -DWITH_QT=OFF -DWITH_GTK=ON -DWITH_OPENGL=ON -DENABLE_PRECOMPILED_HEADERS=OFF -DBUILD_EXAMPLES=ON ..
RUN make -j12
RUN  make install

# Recent version of Eigen C++ - the folder inside the zip  is some kind of hash
# ENV EIGEN_VERSION="3.3.5"
# ENV EIGEN_SUBPATH="b3f3d4950030"
# RUN mkdir /temp \ 
# && wget http://bitbucket.org/eigen/eigen/get/${EIGEN_VERSION}.zip -O /temp/eigen-${EIGEN_VERSION}.zip \
# && unzip /temp/eigen-${EIGEN_VERSION}.zip \
# && cd /eigen-eigen-${EIGEN_SUBPATH}\
# && mkdir build\
# && cd build\
# && cmake .. \
# -DCMAKE_INSTALL_PREFIX=/usr/local\
# && make install\
# && rm -rf /temp\
# && rm -rf /eigen-eigen-${EIGEN_SUBPATH}
#----source cuda 
RUN echo "export PATH=/usr/local/cuda/bin:$PATH" >> ~/.bashrc && \
    echo "export PATH=/usr/local/cuda-10.2/bin${PATH:+:${PATH}}" >> ~/.bashrc && \
    echo "export LD_LIBRARY_PATH=/usr/local/cuda/64:$LD_LIBRARY_PATH" >> ~/.bashrc && \
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
SHELL ["/bin/bash","-c"]
RUN source ~/.bashrc


#----build ros yolo v4
#WORKDIR /Documents/docker_pushpin/darknet
#RUN cmake .
#RUN make
    #---for cam show
RUN apt-get install -y ros-melodic-image-view && \
    apt-get install -y ros-melodic-usb-cam
#WORKDIR /Documents/yolov4_ws
#RUN /bin/bash -c 'catkin_make'



#----add realsense package
WORKDIR /Documents/flycapture
RUN sudo sh install_flycapture.sh
WORKDIR /Documents/yolov4_ws/src/rs_d435i
SHELL ["/bin/bash","-c"]
RUN source create_catkin_ws.sh
WORKDIR /Documents/yolov4_ws/src/darknet_ros/darknet_ros/yolo_network_config/weight
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights

# #使用者新增
RUN useradd -ms/bin/bash iclab

USER iclab
WORKDIR /home/iclab

