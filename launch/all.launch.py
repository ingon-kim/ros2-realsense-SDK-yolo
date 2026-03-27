from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription, DeclareLaunchArgument
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory
import os


def generate_launch_description():

    yolo_model = LaunchConfiguration("model")
    yolo_device = LaunchConfiguration("device")

    model_cmd = DeclareLaunchArgument(
        "model", default_value="yolov8n.pt", description="YOLO model name or path"
    )
    device_cmd = DeclareLaunchArgument(
        "device", default_value="cuda:0", description="Device (cuda:0 or cpu)"
    )

    # RealSense
    realsense_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(
                get_package_share_directory("realsense2_camera"),
                "launch",
                "rs_launch.py",
            )
        ),
        launch_arguments={
            "enable_color": "true",
            "enable_depth": "true",
        }.items(),
    )

    # YOLO
    yolo_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(
                get_package_share_directory("yolo_bringup"),
                "launch",
                "yolo.launch.py",
            )
        ),
        launch_arguments={
            "model": yolo_model,
            "device": yolo_device,
            "input_image_topic": "/camera/camera/color/image_raw",
        }.items(),
    )

    # RViz2
    rviz2_node = Node(
        package="rviz2",
        executable="rviz2",
        name="rviz2",
        output="screen",
    )

    return LaunchDescription(
        [
            model_cmd,
            device_cmd,
            realsense_launch,
            yolo_launch,
            rviz2_node,
        ]
    )
