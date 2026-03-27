# ros2-jazzy-realsense-yoloros

ROS2 Jazzy + RealSense SDK + yolo_ros 도커 이미지

## 구성

| 항목 | 내용 |
|---|---|
| Base | `ros:jazzy-ros-base` (Ubuntu 24.04) |
| RealSense SDK | librealsense2 (apt) |
| yolo_ros | [mgonzs13/yolo_ros](https://github.com/mgonzs13/yolo_ros) |
| YOLO 엔진 | ultralytics |

## 빌드

```bash
docker build -t ros2-jazzy-realsense-yoloros .
```

## 실행

```bash
chmod +x run.sh
./run.sh
```

GPU 없이 실행하려면 `run.sh` 에서 `--gpus all` 줄을 제거하세요.

## Docker Hub 업로드

```bash
docker tag ros2-jazzy-realsense-yoloros <your-dockerhub-id>/ros2-jazzy-realsense-yoloros:latest
docker push <your-dockerhub-id>/ros2-jazzy-realsense-yoloros:latest
```
