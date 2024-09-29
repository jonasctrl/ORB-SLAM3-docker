FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libgtk2.0-dev \
    pkg-config \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    python3-dev \
    python3-numpy \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libglew-dev \
    libboost-all-dev \
    libssl-dev \
    libeigen3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libopenjp2-7-dev \ 
    libdc1394-dev \  
    libepoxy-dev \  
    wget \
    unzip \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install Pangolin
RUN mkdir -p /opt/pangolin_build && \
    cd /opt/pangolin_build && \
    git clone https://github.com/stevenlovegrove/Pangolin.git && \
    cd Pangolin && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          .. && \
    make -j$(nproc) && \
    make install && \
    rm -rf /opt/pangolin_build

# Install OpenCV 4.6.0
RUN mkdir -p /opt/opencv_build && \
    cd /opt/opencv_build && \
    git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout 4.6.0 && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D WITH_CUDA=OFF \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          .. && \
    make -j$(nproc) && \
    make install && \
    rm -rf /opt/opencv_build

# Install ORB-SLAM3
RUN mkdir -p /opt/orb_slam3 && \
    cd /opt/orb_slam3 && \
    git clone https://github.com/UZ-SLAMLab/ORB_SLAM3.git && \
    cd ORB_SLAM3 && \
    sed -i 's/++11/++14/g' CMakeLists.txt && \
    chmod +x build.sh && \
        ./build.sh

# Set the working directory
WORKDIR /opt/orb_slam3/ORB_SLAM3
CMD ["bash"]
