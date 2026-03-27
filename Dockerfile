FROM ros:jazzy-ros-base

# ──────────────────────────────────────────
# 1. 기본 패키지 설치
# ──────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    gnupg2 \
    lsb-release \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    libusb-1.0-0-dev \
    gedit \
    nautilus \
  && rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────
# 2. RealSense SDK + ROS2 래퍼 apt 설치
# ──────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    ros-jazzy-librealsense2* \
    ros-jazzy-realsense2-camera \
    ros-jazzy-realsense2-description \
  && rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────
# 3. rosdep 초기화
# ──────────────────────────────────────────
RUN rosdep init || true && \
    rosdep update

# ──────────────────────────────────────────
# 4. yolo_ros clone
# ──────────────────────────────────────────
RUN mkdir -p /ros2_ws/src && \
    cd /ros2_ws/src && \
    git clone https://github.com/mgonzs13/yolo_ros.git

# ──────────────────────────────────────────
# 5. ultralytics 설치 + rosdep 의존성 해결
# ──────────────────────────────────────────
RUN pip3 install --break-system-packages --ignore-installed 'numpy<2' ultralytics lap

RUN apt-get update && \
    cd /ros2_ws && \
    . /opt/ros/jazzy/setup.sh && \
    rosdep install --from-paths src --ignore-src -r -y && \
    rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────
# 6. yolo_ros 빌드
# ──────────────────────────────────────────
RUN cd /ros2_ws && \
    . /opt/ros/jazzy/setup.sh && \
    colcon build

# ──────────────────────────────────────────
# 7. 추가 도구 설치
# ──────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    ros-jazzy-rviz2 \
    ros-jazzy-rqt \
    ros-jazzy-rqt-common-plugins \
  && rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────
# 8. YOLO 모델 사전 다운로드
# ──────────────────────────────────────────
RUN cd /ros2_ws && \
    python3 -c "from ultralytics import YOLO; YOLO('yolov8n.pt')"

# ──────────────────────────────────────────
# 9. 통합 launch 파일 복사
# ──────────────────────────────────────────
COPY launch/all.launch.py /ros2_ws/launch/all.launch.py

# ──────────────────────────────────────────
# 10. 환경변수 + alias 설정
# ──────────────────────────────────────────
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "source /ros2_ws/install/setup.bash" >> /root/.bashrc && \
    echo "" >> /root/.bashrc && \
    echo "# aliases" >> /root/.bashrc && \
    echo "alias eb='gedit ~/.bashrc'" >> /root/.bashrc && \
    echo "alias sb='source ~/.bashrc'" >> /root/.bashrc && \
    echo "alias cle='clear'" >> /root/.bashrc && \
    echo "alias nt='nautilus'" >> /root/.bashrc && \
    echo "" >> /root/.bashrc && \
    echo "# launch shortcuts" >> /root/.bashrc && \
    echo "alias launch_all='ros2 launch /ros2_ws/launch/all.launch.py'" >> /root/.bashrc && \
    echo "alias launch_all_cpu='ros2 launch /ros2_ws/launch/all.launch.py device:=cpu'" >> /root/.bashrc && \
    echo "alias launch_rs='ros2 launch realsense2_camera rs_launch.py enable_color:=true enable_depth:=true'" >> /root/.bashrc && \
    echo "alias launch_yolo='ros2 launch yolo_bringup yolo.launch.py model:=yolov8n.pt device:=cuda:0 input_image_topic:=/camera/camera/color/image_raw'" >> /root/.bashrc && \
    echo "alias launch_yolo_cpu='ros2 launch yolo_bringup yolo.launch.py model:=yolov8n.pt device:=cpu input_image_topic:=/camera/camera/color/image_raw'" >> /root/.bashrc

WORKDIR /ros2_ws

CMD ["/bin/bash"]
