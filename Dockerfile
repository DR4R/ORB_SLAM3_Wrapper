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
        python3-pip \
        libgl1-mesa-glx
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
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir numpy
RUN cd /opencv-${OPENCV_VERSION}/cmake_binary \
    && cmake -DCMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D WITH_TBB=OFF \
        -D WITH_IPP=OFF \
        -D WITH_1394=OFF \
        -D BUILD_WITH_DEBUG_INFO=OFF \
        -D BUILD_DOCS=OFF \
        -D BUILD_EXAMPLES=OFF \
        -D BUILD_TESTS=OFF \
        -D BUILD_PERF_TESTS=OFF \
        -D WITH_CUFFT=ON \
        -D WITH_QT=ON \
        -D WITH_GTK=ON \
        -D WITH_OPENGL=ON \
        -D WITH_V4L=ON \
        -D WITH_FFMPEG=ON \
        -D WITH_XINE=ON \
        -D BUILD_NEW_PYTHON_SUPPORT=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D INSTALL_PYTHON_EXAMPLES=OFF \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib-${OPENCV_VERSION}/modules \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D BUILD_EXAMPLES=OFF \
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
RUN cd /ORB_SLAM3 && sh build.sh

RUN mkdir /workspace
WORKDIR /workspace
COPY . .
RUN mkdir build && cd build && cmake .. && make -j$(nproc)
RUN ldconfig
RUN cd Vocabulary/ && tar zxvf ORBvoc.txt.tar.gz
ENV XDG_RUNTIME_DIR=/run/user/1001

CMD [ "/bin/bash" ]