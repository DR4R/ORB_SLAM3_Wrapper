#!/bin/bash

xhost +local:docker
export DISPLAY=:1.0
export NO_AT_BRIDGE=1
sudo docker run --net=host --privileged --rm -it --name orbslam3_cam -v /dev/:/dev -v $HOME/.Xauthority:/root/.Xauthority:ro -e DISPLAY=$DISPLAY orbslam3_wrapper /workspace/build/ORBWrapper /workspace/Vocabulary/ORBvoc.txt /workspace/config/default_camera_config.yaml