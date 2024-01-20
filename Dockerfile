FROM ubuntu:22.04

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libavformat-dev \
        libpq-dev \
        libgtk2.0-dev \
        libtbb2 libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libv4l-dev \
        libatk-adaptor \
        libcanberra-gtk-module \
        x11-apps \
        libgtk-3-dev \
        imagemagick \
        python3-pip
RUN apt-get update && apt-get install -y --no-install-recommends \
		cmake build-essential pkg-config python3-dev \
		libglew-dev libeigen3-dev libomp-dev \
		libboost-all-dev libboost-thread-dev libboost-filesystem-dev \
	    libboost-serialization-dev \
		opencl-dev ca-certificates \
		curl htop nano wget git unzip 

ENV OPENCV_VERSION="4.5.4"
WORKDIR /
RUN wget --output-document cv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
    && unzip cv.zip \
    && wget --output-document contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip \
    && unzip contrib.zip \
    && mkdir /opencv-${OPENCV_VERSION}/cmake_binary

# Install numpy, since1. it's required for OpenCV
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir numpy

RUN cd /opencv-${OPENCV_VERSION}/cmake_binary \
    && cmake -DBUILD_TIFF=ON \
        -DBUILD_opencv_java=OFF \
        -DWITH_CUDA=OFF \
        -DWITH_OPENGL=ON \
        -DWITH_OPENCL=ON \
        -DWITH_IPP=ON \
        -DWITH_TBB=ON \
        -DWITH_EIGEN=ON \
        -DWITH_V4L=ON \
        -DBUILD_TESTS=OFF \
        -DBUILD_PERF_TESTS=OFF \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib-${OPENCV_VERSION}/modules \
        -D OPENCV_ENABLE_NONFREE=ON \
        -DCMAKE_INSTALL_PREFIX=$(python -c "import sys; print(sys.prefix)") \
        -DPYTHON_EXECUTABLE=$(which python) \
        -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
        -DPYTHON_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
        .. \
    && make install \
    && rm /cv.zip /contrib.zip \
    && rm -r /opencv-${OPENCV_VERSION} /opencv_contrib-${OPENCV_VERSION}

RUN pip3 install --upgrade pip && pip install --no-cache-dir scipy matplotlib requests ipython numba jupyterlab rawpy opencv-python
RUN cd /tmp && git clone https://github.com/stevenlovegrove/Pangolin.git \
	&& cd Pangolin && mkdir build && cd build && cmake .. \
	&& make -j$(nproc) && make install \
	&& cd / && rm -rf /tmp/Pangolin
RUN git clone -b c++14_comp https://github.com/UZ-SLAMLab/ORB_SLAM3 /ORB_SLAM3
RUN cd /ORB_SLAM3 && mkdir build && cd build \
    cmake .. && make -j$(nproc)

RUN mkdir /workspace
WORKDIR /workspace
COPY . .
RUN mkdir build && cd build \
    cmake .. && make -j$(nproc)
RUN cd Vocabulary/ && tar zxvf ORBvoc.txt.tar.gz

CMD [ "/bin/bash" ]