#!/bin/bash

xhost +local:docker
export DISPLAY=:1.0
sudo docker run --net=host --privileged --rm -it --name orbslam3_cam -v /dev/:/dev -v /tmp/.X11-unix:/tmp/.X11-unix:ro -e DISPLAY=$DISPLAY orbslam3_wrapper /workspace/build/ORBWrapper /workspace/Vocabulary/ORBvoc.txt /workspace/config/default_camera_config.yaml