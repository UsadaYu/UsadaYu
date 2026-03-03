# Yolo & Onnx & Onnxruntime

# 1 环境

## 1.1 Linux

### 1.1.1 Centos-7

* glibc version：2.17

* Compiler：gcc-15.2.0

### 1.1.2 Ubuntu-24

* glibc version：2.39

* Compiler：gcc-15.2.0

### 1.1.3 Windows-Minw64-msvc

* Compiler：cl-19.44.35214

# 2 说明

如果希望使用开源的模型对图像或视频做目标检测，那么 yolo 是不错的选择。

yolo 本身是直接支持 python 的；当然也可以通过一些方式被 C++ 调用。

# 3 Yolo 的使用与安装

## 3.1 官方地址

如下是 yolo12 模型的下载地址

```
https://docs.ultralytics.com/zh/models/yolo12/#supported-tasks-and-modes
```

## 3.2 前置说明

### 3.2.1 基础依赖

安装一些依赖模块。

```shell
pip install opencv-python
pip install ultralytics
```

### 3.2.2 GPU 环境（可选）

如果希望使用 GPU，也可以配置相关的 GPU 环境：

以 Nvidia 的 GPU 为例：

```shell
# 查看 GPU 型号和显存信息
nvidia-smi

# 打印类似如下信息，说明显卡正常可用
Tue Aug 12 20:03:08 2025
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 576.02                 Driver Version: 576.02         CUDA Version: 12.9     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                  Driver-Model | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4080 ...  WDDM  |   00000000:01:00.0 Off |                  N/A |
| N/A   33C    P8              1W /  160W |     110MiB /  12282MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

# 检查 PyTorch 是否支持 CUDA，如果是 CPU-only 的 PyTorch，那么通过如下命令安装支持 CUDA 的 PyTorch
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

通过上述方式安装好 GPU 版本的 PyTorch 后，可以写一个小脚本检查 GPU 是否已支持使用：

```python
import torch
print(torch.cuda.is_available())      # 打印 `True`
print(torch.cuda.get_device_name(0))  # 显示 GPU 名称
```

## 3.3 运行

有 GPU 等硬件环境可以选择 yolo12l、yolo12x 等模型。

我尝试了下用 4080 跑了下 yolo12x 模型，速度还是挺快的，正常的视频一般在几十毫秒一帧。

CPU 环境下可以选择轻量级的模型。

```python
import time
import cv2
import torch
from ultralytics import YOLO

print("torch.cuda.is_available():", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU device count:", torch.cuda.device_count())
    try:
        print("Current GPU name:", torch.cuda.get_device_name(0))
    except Exception:
        pass

model = YOLO("./model/yolo12x.pt")

if torch.cuda.is_available():
    model.to("cuda")
    # model.to("cuda:0")
    device = "cuda:0"
else:
    device = "cpu"

class_names = model.names
print(f"The model can recognize categories:\n{class_names}")

video_path = "./trump&powell_1280-720_30fps.mp4"
cap = cv2.VideoCapture(video_path)
if not cap.isOpened():
    raise IOError(f"The video file cannot be opened: {video_path}")

start_time = time.time()
while cap.isOpened():
    print(f"Gaps: {1000 * (time.time() - start_time):.1f} ms")
    start_time = time.time()

    success, frame = cap.read()
    if not success:
        print("The video stream has ended")
        break

    results = model(frame, device=device)

    # 当 stream=False 时，results[0] 即当前图像的全部结果
    result = results[0]
    for box in result.boxes:
        xyxy = box.xyxy[0].cpu().numpy().astype(int)
        x1, y1, x2, y2 = xyxy
        confidence = float(box.conf[0].cpu().numpy())
        class_id = int(box.cls[0].cpu().numpy())
        class_name = class_names[class_id]
        print(
            f"Class name: {class_name}, "
            f"Coordinate: (x1={x1}, y1={y1}, x2={x2}, y2={y2}), "
            f"Confidence: {confidence:.2f}",
            flush=True,
        )

cap.release()
cv2.destroyAllWindows()
```

运行上述脚本，可以看到类似这样的打印：

```shell
0: 384x640 3 persons, 2 ties, 31.6ms
Speed: 0.7ms preprocess, 31.6ms inference, 0.9ms postprocess per image at shape (1, 3, 384, 640)
Class name: person, Coordinate: (x1=676, y1=119, x2=1046, y2=710), Confidence: 0.94
Class name: person, Coordinate: (x1=175, y1=81, x2=600, y2=710), Confidence: 0.93
Class name: tie, Coordinate: (x1=459, y1=296, x2=555, y2=700), Confidence: 0.92
Class name: tie, Coordinate: (x1=847, y1=366, x2=912, y2=711), Confidence: 0.90
Class name: person, Coordinate: (x1=102, y1=268, x2=130, y2=372), Confidence: 0.42
Gaps: 30.7 ms
```

我这里就是将结果打印了一下，有兴趣的可以用 `opencv` 画上目标框、种类、置信度等信息。

# 3 onnx 导出

如果对 python 的运行速度不满意，yolo 也提供了 C/C++ 接口。

首先需要将 yolo 的 `pt` 文件转化为 `onnx` 文件。转化方式如下。

## 3.1 前置说明

安装一些依赖模块。

```shell
# 选择合适的 onnx 版本
pip install onnx==1.17.0

pip install onnxslim

# onnxruntime 的作用一般是校验，实际上不安装也可以，转化时没有此模块可能会发出警告
# onnxruntime 模块可能对 python 版本有要求，依据实际情况安装即可，不安装一般也没问题
pip install onnxruntime
```

## 3.2 导出方式

可以直接使用如下命令进行模型转换：

```shell
yolo export model=yolo12n.pt format=onnx
```

也可以编写一个简单的小脚本：

```python
from ultralytics import YOLO

model = YOLO("./model/yolo12n.pt")

# format="onnx": 导出为 ONNX 格式
# imgsz=640: 模型的输入图像尺寸，根据需求调整
# opset=12: 一个比较通用的版本，ONNX Runtime 兼容性好
# simplify=True: 使用 onnx-simplifier 工具简化模型结构，有助于提高推理速度
model.export(format="onnx", imgsz=640, opset=12, simplify=True)
```

## 3.3 注意事项

* 导出时指定的 imgsz（例如 640）决定了 onnx 模型的固定输入尺寸，如：`[1, 3, 640, 640]`

* 使用 C++ 进行推理时，任何图像都需要预处理到上述设定的尺寸

# 4 onnxruntime

## 4.1 前置说明

### 4.1.1 onnxruntime

在 C/C++ 环境下，可以选择 `onnxruntime` 加载 onnx 模型。

`onnxuntime` 是微软公司出品的开源库。

### 4.1.2 open-cv

对图像的一些高级处理可以使用 `open-cv`。

## 4.2 注意事项

需要明确的是，非常不建议使用纯 C 语言。原因如下：

---

`onnxruntime` 虽然提供了 C API，但其 C++ API (onnxruntime_cxx_api.h) 更加友好易用。

---

C++ 的 `std::vector` 等动态数组处理模型输入输出这种大小可变的数据更友好，可以替代 Python 中的 `NumPy`。

---

open-cv 是一个 C++ 库。虽然它也有 C 的接口，但高版本的 open-cv（2.x 后）已基本全面转向 C++。

---

## 4.3 onnxruntime 官方地址

```
https://github.com/microsoft/onnxruntime/releases
```

## 4.4 Linux onnxruntime

### 4.4.1 环境配置

源码安装时，onnxruntime 的 cmake 脚本在构建时会拉取一些 github 上的依赖库。

如果无法直接拉取，可以通过如下方式解决：

打开 onnxruntime 工程， `cmake` 目录下有一个 `deps.txt` 文件，这个文件记录了所有需要拉取的依赖库。

将这些依赖库手动下载后放置到本地目录下，以 `abseil_cpp` 为例：

```shell
# abseil_cpp;https://github.com/abseil/abseil-cpp/archive/refs/tags/20240722.0.zip;36ee53eb1466fb6e593fc5c286680de31f8a494a

abseil_cpp;file:///home/usadayu/deps/abseil-cpp-20240722.0.zip;36ee53eb1466fb6e593fc5c286680de31f8a494a
```

同时我也尝试了在本地安装这些依赖库，但是发现了一些问题，如 `abseil_cpp`。

我安装到本地后，cmake 会搜寻到 `abseil_cpp` 的安装目录以及 cmake 配置。

但是编译时发现编译命令没有将相关头文件包含进去，可能报错：

```shell
fatal error: absl/container/inlined_vector.h: No such file or directory
```

建议不要死磕，让 onnxruntime 自行取搜寻源码并编译好点。

### 4.4.2 安装流程

```shell
cmake \
-S ./cmake \
-B build \
-G Ninja \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/x64_ubuntu-24/onnxruntime-1.22.1 \
-Donnxruntime_BUILD_SHARED_LIB=ON

# `onnxruntime_BUILD_SHARED_LIB` 将所有库（以及依赖库）编译成一个动态库。这个一定要开启，否则后续比较麻烦
# 若默认 python 是 2.x 版本，可以在 cmake 高级选项中将 `PYTHON_EXECUTABLE` 改为 python3 的路径
cmake --build build --target edit_cache

cmake --build build --target install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/onnxruntime-1.22.1"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
    export CMAKE_PREFIX_PATH=${dir_prefix}:$CMAKE_PREFIX_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile

# Verify
onnx_test_runner -h
```

## 4.5 Windows onnxruntime

### 4.5.1 安装流程

Windows 中安装 onnxruntime，我大概尝试了一下，只能用 `msvc` 安装。

粗略地翻了下构建脚本和代码，微软对 Windows 的 gcc/clang 等编译器未做任何适配。

不过安装后，对 onnxruntime 的 API 调用，可以用 clang/clang++ 编译。

如此，安装流程如下：

```shell
cmake \
-DCMAKE_C_COMPILER=cl \
-DCMAKE_CXX_COMPILER=cl \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/mingw64/onnxruntime-1.23.1 \
-Donnxruntime_BUILD_SHARED_LIB=ON \
-DBUILD_SHARED_LIBS=OFF \
-DONNX_USE_MSVC_STATIC_RUNTIME=OFF \
-Dprotobuf_MSVC_STATIC_RUNTIME=OFF \
-Donnxruntime_BUILD_UNIT_TESTS=OFF \
-S ./cmake \
-B build

cmake --build build/ --target install --config Release --parallel 32
```

## 4.6 Windows CUDA onnxruntime

如果希望编译 CUDA 版本的 onnxruntime，需要确认有 CUDA 环境。

安装 CUDA 的版本建议不要太新，否则用 `nvcc` 编译时，可能会出现一些奇怪的问题。

关于 CUDA 与 onnxruntime 的版本，尽量用官方推荐的版本，以避免一些编译链接问题。

### 4.6.1 CUDA 环境

#### 4.6.1.1 CUDA Toolkit

```
https://developer.nvidia.com/cuda-downloads
```

验证：

```shell
nvcc --version
```

#### 4.6.1.2 CUDNN

```
https://developer.nvidia.com/cudnn
```

### 4.6.2 架构

通过如下命令查看当前 GPU 支持的架构：

```shell
nvcc --help | findstr "compute_"
```

按照官方推荐于本地环境自行选择即可，这里我选择的是 `compute_89`。

#### 4.5.2.3 安装

```shell
cmake \
-S ./cmake \
-B build \
-DCMAKE_C_COMPILER=cl \
-DCMAKE_CXX_COMPILER=cl \
\
-Donnxruntime_USE_CUDA=ON \
-DCMAKE_CUDA_ARCHITECTURES=89 \
-Donnxruntime_CUDA_HOME=/d/070_Code/200_CUDA/v12.9.0 \
\
-Donnxruntime_CUDNN_HOME=/d/070_Code/201_CUDAA/v9.15/ \
-DCUDNN_INCLUDE_DIR=/d/070_Code/201_CUDAA/v9.15/include/12.9 \
-Dcudnn_LIBRARY=/d/070_Code/201_CUDAA/v9.15/lib/12.9/x64/cudnn.lib \
\
-DCMAKE_INSTALL_PREFIX=$HOME/.local/mingw64/onnxruntime-1.23.1-cuda \
-Donnxruntime_BUILD_SHARED_LIB=ON \
-DBUILD_SHARED_LIBS=OFF \
-DONNX_USE_MSVC_STATIC_RUNTIME=OFF \
-Dprotobuf_MSVC_STATIC_RUNTIME=OFF \
-Donnxruntime_BUILD_UNIT_TESTS=OFF

# 1. nvcc 编译时会消耗大量的内存，线程数量一定要配置的少一些！

# 2. 编译大概率会报一些小错误，可能需要手动解决。
# 比如 2025-05-12 的 `abseil-cpp`，`function_ref.h` 和 `raw_hash_set.h` 文件存在警告视为错误的情况。
cmake --build build/ --target install --config Release --parallel 8
```
