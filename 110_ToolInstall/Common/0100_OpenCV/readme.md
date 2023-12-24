# OpenCV



# 1 环境

## 1.1 Linux

### 1.1.1 Centos-7

* glibc version：2.17

* Compiler：gcc-15.2.0



### 1.1.2 Ubuntu-24

* glibc version：2.39

* Compiler：gcc-15.2.0



# 2 官方地址

```
https://opencv.org/releases/
```

OpenCV 可能对 glibc 有一定的版本要求，选择适合自己环境的版本即可。



# 3 安装流程

OpenCV 依赖一些第三方库，具体参见 `3rdparty/readme.txt` 文件。

在我的环境下使用 cmake 构建时，报告了一些警告，缺失的模块如下。



## 3.1 IPPICV

OpenCV 的 cmake 会尝试从 github 上拉取 `ippicv` 这个库。

这是 Intel 发布的一套高性能图像处理加速库。

如果不添加实际上也不会报错，OpenCV 会使用自己内部的非优化通用版本。

但在 Intel 平台使用 OpenCV，还是建议将这个库安装上。

OpenCV-4.12.0 cmake 提示需要的版本如下：

```
https://raw.githubusercontent.com/opencv/opencv_3rdparty/767426b2a40a011eb2fa7f44c677c13e60e205ad/ippicv/ippicv_2022.1.0_lnx_intel64_20250130_general.tgz
```



OpenCV-4.12.0 的 cmake 脚本目前似乎无论如何都会尝试通过 url 寻找文件，即使本地已经安装了这个库。

所以这里使用本地的文件 url 代替网络 url。

打开 `3rdparty/ippicv.cmake` 文件，做如下更改：

```cmake
# 将 ippicv 的 tgz 压缩文件放入本地目录下 (如 /home/usadayu/deps/)，再修改相应的 url 路径

# 末尾的 `/` 不要遗漏
"file:///home/usadayu/deps/opencv-4.12.0/"
# "https://raw.githubusercontent.com/opencv/opencv_3rdparty/${IPPICV_COMMIT}/ippicv/"
```



## 3.2 ADE

同样，OpenCV 的 cmake 也会尝试从 github 上拉取这个库。

这个库是 OpenCV G-API (图像处理图谱引擎) 的一个辅助库。

如果不需要的话确实可以不用添加。



OpenCV cmake 提示需要的版本如下：

```
https://github.com/opencv/ade/archive/v0.1.2e.zip
```



类似的，这里也用本地的文件 url 代替网络 url。

打开 `modules/gapi/cmake/DownloadADE.cmake` 文件，做如下更改：

```cmake
# cmake 中要求的文件名是 `v0.1.2e.zip`，下载后的文件名是 `ade-0.1.2e.zip`
# 这里将 `ade-0.1.2e.zip` 重命名为 `v0.1.2e.zip` 即可
# 将 ade 的 zip 压缩文件放入本地目录下 (如 /home/usadayu/deps/)，再修改相应的 url 路径

# 末尾的 `/` 不要遗漏
"file:///home/usadayu/deps/opencv-4.12.0/"
# "https://github.com/opencv/ade/archive/"
```



## 3.3 ffmpeg

---

建议安装 ffmpeg 动态库，否则后续编译 opencv 可能会报错。

---

opencv-4.12.0 对 ffmpeg-8.0 编译时存在报错。

建议使用 ffmpeg-7.x 系列的版本。

ffmpeg-8.x 及以上版本以上废弃了一些函数，opencv 应该会在后续的更新中支持 ffmpeg 的改动。



关于 opencv-4.12.0 对 ffmpeg-8.0 编译报错的问题与解决方案，可以参考：

```
https://github.com/opencv/opencv/issues/27688
```

```
https://gitweb.gentoo.org/repo/gentoo.git/commit/?id=42f6b911587c4f79e92d779f8f1067222e34d833
```

---





## 3.4 OpenCV

```shell
cmake \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/x64_ubuntu-24/opencv-4.12.0 \
-DOPENCV_GENERATE_PKGCONFIG=ON \
-S . \
-B build

cmake --build ./build --target all -- -j16
cmake --build ./build --target install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/opencv-4.12.0"
    export LD_LIBRARY_PATH=${dir_prefix}/lib64:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib64/pkgconfig:$PKG_CONFIG_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile

# Verify
opencv_annotation -h
opencv_version
```

