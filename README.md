# ros2-jazzy-realsense-yoloros

ROS2 Jazzy + Intel RealSense SDK + YOLO ROS 통합 Docker 환경

## 구성

| 항목 | 내용 |
|------|------|
| Base Image | `ros:jazzy-ros-base` (Ubuntu 24.04) |
| RealSense SDK | librealsense2 + ros2 wrapper (apt) |
| YOLO | [mgonzs13/yolo_ros](https://github.com/mgonzs13/yolo_ros) |
| YOLO 엔진 | ultralytics (YOLOv3 ~ v12, YOLO-World, YOLOE 지원) |
| 시각화 | RViz2, rqt |
| 기타 도구 | gedit, nautilus |

## 사전 요구사항

- Docker 설치
- Intel RealSense 카메라 (D400 시리즈 등)
- (선택) NVIDIA GPU + [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

### WSL2 환경인 경우

WSL2에서는 USB가 자동으로 넘어오지 않으므로 `usbipd`를 사용해야 합니다.

**Windows PowerShell (관리자):**

```powershell
# 1. usbipd 설치 (최초 1회)
winget install usbipd

# 2. USB 장치 목록 확인
usbipd list

# 3. RealSense의 BUSID를 찾아서 바인드 & 연결
usbipd bind --busid <BUSID>
usbipd attach --wsl --busid <BUSID>
```

**WSL 터미널에서 확인:**

```bash
lsusb | grep -i real
# Intel RealSense가 보이면 성공
```

> 카메라가 안 잡히면 `sudo modprobe uvcvideo` 실행 후 다시 확인

## 빌드

```bash
git clone https://github.com/ingon-kim/ros2-realsense-SDK-yolo.git
cd ros2-realsense-SDK-yolo
docker build -t ros2-jazzy-realsense-yoloros .
```

## 실행

```bash
chmod +x run.sh
./run.sh
```

컨테이너에 진입하면 `/ros2_ws` 디렉토리에서 시작됩니다.

> GPU가 없으면 `run.sh`에서 `--gpus all` 줄을 제거하세요.

## 사용법

### 한방 실행 (RealSense + YOLO + RViz2)

컨테이너 안에서:

```bash
# GPU 모드 (기본)
launch_all

# CPU 모드
launch_all_cpu
```

### 개별 실행

터미널을 여러 개 열어서 각각 실행할 수도 있습니다.

**터미널 1 — RealSense 카메라:**

```bash
launch_rs
# 또는
ros2 launch realsense2_camera rs_launch.py enable_color:=true enable_depth:=true
```

**터미널 2 — YOLO 탐지 (추가 터미널 접속):**

```bash
# 호스트에서 같은 컨테이너에 접속
docker exec -it $(docker ps -q) bash

# GPU
launch_yolo
# CPU
launch_yolo_cpu
# 또는 직접 지정
ros2 launch yolo_bringup yolo.launch.py \
  model:=yolov8n.pt \
  device:=cuda:0 \
  input_image_topic:=/camera/camera/color/image_raw
```

**터미널 3 — RViz2 시각화:**

```bash
docker exec -it $(docker ps -q) bash
rviz2
```

RViz2 설정:
- Fixed Frame → `camera_link`
- Add → Image → Topic: `/camera/camera/color/image_raw` (원본)
- Add → Image → Topic: `/yolo/dbg_image` (탐지 결과)

### YOLO 모델 변경

기본 모델은 `yolov8n.pt` (nano, 가장 가벼움) 입니다. 다른 모델을 사용하려면:

```bash
# 예: YOLOv8 medium
ros2 launch yolo_bringup yolo.launch.py model:=yolov8m.pt device:=cuda:0 input_image_topic:=/camera/camera/color/image_raw

# 예: YOLOv11 nano
ros2 launch yolo_bringup yolov11.launch.py model:=yolo11n.pt device:=cuda:0 input_image_topic:=/camera/camera/color/image_raw

# 예: segmentation
ros2 launch yolo_bringup yolo.launch.py model:=yolov8n-seg.pt device:=cuda:0 input_image_topic:=/camera/camera/color/image_raw

# 예: pose estimation
ros2 launch yolo_bringup yolo.launch.py model:=yolov8n-pose.pt device:=cuda:0 input_image_topic:=/camera/camera/color/image_raw
```

> 모델이 로컬에 없으면 자동 다운로드됩니다. CPU 환경에서는 반드시 `device:=cpu`를 지정하세요.

## 등록된 Alias

| alias | 동작 |
|-------|------|
| `launch_all` | RealSense + YOLO(GPU) + RViz2 통합 실행 |
| `launch_all_cpu` | 위와 동일 (CPU 모드) |
| `launch_rs` | RealSense만 실행 |
| `launch_yolo` | YOLO만 실행 (GPU) |
| `launch_yolo_cpu` | YOLO만 실행 (CPU) |
| `eb` | `gedit ~/.bashrc` |
| `sb` | `source ~/.bashrc` |
| `cle` | `clear` |
| `nt` | `nautilus` |

## 주요 토픽

| 토픽 | 설명 |
|------|------|
| `/camera/camera/color/image_raw` | RealSense 컬러 이미지 |
| `/camera/camera/depth/image_rect_raw` | RealSense 깊이 이미지 |
| `/yolo/detections` | YOLO 탐지 결과 |
| `/yolo/tracking` | YOLO 트래킹 결과 |
| `/yolo/dbg_image` | YOLO 디버그 이미지 (바운딩 박스 포함) |

## 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| `No device detected` | USB가 컨테이너에 안 넘어옴 | WSL: `usbipd attach` 실행, `run.sh`에서 `-v /dev:/dev` 확인 |
| RViz에서 "No tf data" | Fixed Frame이 `map`으로 설정됨 | `camera_link`으로 변경 |
| YOLO Activating에서 멈춤 | `device:=cuda:0`인데 GPU 없음 | `device:=cpu`로 변경 |
| YOLO 모델 다운로드 실패 | 컨테이너 내 네트워크 문제 | 호스트에서 모델 다운 후 볼륨 마운트 |
| `/yolo/dbg_image` No Image | yolo_node가 inactive 상태 | `ros2 lifecycle get /yolo/yolo_node`로 확인 |

## Docker Hub

```bash
docker tag ros2-jazzy-realsense-yoloros <your-dockerhub-id>/ros2-jazzy-realsense-yoloros:latest
docker push <your-dockerhub-id>/ros2-jazzy-realsense-yoloros:latest
```

<img width="1777" height="270" alt="image" src="https://github.com/user-attachments/assets/79fd6eb9-37e0-46c9-964f-6be34624ea2d" />


## 참고

- [mgonzs13/yolo_ros](https://github.com/mgonzs13/yolo_ros) — YOLO ROS2 wrapper (YOLOv3~v12, World, YOLOE 지원)
- [IntelRealSense/realsense-ros](https://github.com/IntelRealSense/realsense-ros) — RealSense ROS2 wrapper
