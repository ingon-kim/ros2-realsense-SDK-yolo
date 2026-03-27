#!/bin/bash

# ──────────────────────────────────────────
# ros2-jazzy-realsense-yoloros 실행 스크립트
# ──────────────────────────────────────────

IMAGE_NAME="ros2-jazzy-realsense-yoloros"

docker run -it \
  --privileged \
  --gpus all \
  --network=host \
  -v /dev:/dev \
  -e DISPLAY=:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /mnt/wslg:/mnt/wslg \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -e PULSE_SERVER=$PULSE_SERVER \
  $IMAGE_NAME
