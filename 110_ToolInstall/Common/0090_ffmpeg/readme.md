# ffmpeg

# 1 环境

## 1.1 Linux

### 1.1.1 Centos-7

* glibc version：2.17

* Compiler：gcc-15.2.0

### 1.1.2 Ubuntu-24

* glibc version：2.39

* Compiler：gcc-15.2.0

### 1.1.3 Windows-Mingw64-gcc/clang

* cygwin version: 3.5.7

* Compiler：gcc-14.2.0

### 1.1.4 Windows-Mingw64-msvc

* Compiler：cl-19.42.34436

# 2 说明

官方实际上提供了 ffmpeg 的库与可执行文件，组件也还是比较齐全的。

官方地址如下：

```
https://github.com/BtbN/FFmpeg-Builds/releases
```

当然也可以选择自行编译。

在 Windows 安装时，可以选择使用 mingw64。

# 3 安装依赖

安装之前，建议添加一些组件。

## 3.1 libx264

 `libx264`，使 ffmpeg 支持对 h264 的软编。

### 3.1.1 源码地址

```
https://www.videolan.org/developers/x264.html
```

### 3.1.2 安装流程

```shell
./configure \
--prefix=$HOME/.local/x64_ubuntu-24/x264 \
--enable-static \
--enable-shared \
--enable-pic

make -j8
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/x264"
    export LD_LIBRARY_PATH=${dir_prefix}/lib/:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile

# Verify
x264 --version
```

在 Windows 下编译可能出现线程报错：

```
/usr/lib/gcc/x86_64-pc-msys/13.3.0/../../../../x86_64-pc-msys/bin/ld: common/win32thread.o:win32thread.c:(.text+0x60): undefined reference to `_beginthreadex'
collect2: error: ld returned 1 exit status
make: *** [Makefile:287: libx264-165.dll] Error 1
make: *** Waiting for unfinished jobs....
```

为了避免此问题，可以按照如下方式配置：

```shell
./configure \
--prefix=$HOME/.local/mingw64/x264 \
--enable-static \
--enable-shared \
--enable-pic \
--disable-thread
```

## 3.2 libx265

`libx265`，使 ffmpeg 支持对 h265(hevc) 的软编。

### 3.2.1 源码地址

```
https://bitbucket.org/multicoreware/x265_git/downloads/
```

### 3.2.2 安装流程

libx265 源码目录下已经存在 build 目录，是各平台的安装脚本。

这里可以不使用他提供的 build，使用 cmake 自行构建。

```shell
cmake \
-G Ninja \
-S ./source \
-B build_custom
```

如果构建时出现类似如下 cmake 版本报错：

```shell
CMake Error at CMakeLists.txt:10 (cmake_policy):
  Policy CMP0025 may not be set to OLD behavior because this version of CMake
  no longer supports it.  The policy was introduced in CMake version 3.0.0,
  and use of NEW behavior is now required.

  Please either update your CMakeLists.txt files to conform to the new
  behavior or use an older version of CMake that still supports the old
  behavior.  Run cmake --help-policy CMP0025 for more information.

CMake Error at CMakeLists.txt:16 (cmake_policy):
  Policy CMP0054 may not be set to OLD behavior because this version of CMake
  no longer supports it.  The policy was introduced in CMake version 3.1.0,
  and use of NEW behavior is now required.

  Please either update your CMakeLists.txt files to conform to the new
  behavior or use an older version of CMake that still supports the old
  behavior.  Run cmake --help-policy CMP0054 for more information.
```

可以修改 `source/CMakeLists.txt`：

```cmake
# 原脚本
cmake_policy(SET CMP0025 OLD)
cmake_policy(SET CMP0054 OLD)

# 修改
cmake_policy(SET CMP0025 NEW)
cmake_policy(SET CMP0054 NEW)
```

如果构建时提示 cmake 版本过新，可以添加此选项：`-DCMAKE_POLICY_VERSION_MINIMUM=3.5`。

```shell
cmake \
-S ./source \
-B build_custom \
-G Ninja \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/x64_ubuntu-24/x265_4.1 \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5

# 自定义选项，如使能 `ENABLE_ASSEMBLY` 等。
cmake \
--build ./build_custom/ \
--target edit_cache

cmake --build ./build_custom/ --target install

# 在 mingw64 上，使用多线程编译在链接时可能会报错，可以尝试单线程编译。

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/x265_4.1"
    export LD_LIBRARY_PATH=${dir_prefix}/lib/:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile

# Verify
x265 --version
```

## 3.3 libsvtav1

`libsvtav1`，使 ffmpeg 支持对 av1 的软编。

### 3.3.1 源码地址

```
https://github.com/Fawkex/SVT-AV1-Binaries/releases
```

### 3.3.2 安装流程

libsvtav1 源码目录下同样已经存在 build 目录。

这里也不使用他提供的 build，使用 cmake 自行构建。

如果构建时提示 cmake 版本过新，同样可以添加此选项：`-DCMAKE_POLICY_VERSION_MINIMUM=3.5`。

```shell
cmake \
-S . \
-B build_custom \
-G Ninja \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/x64_ubuntu-24/SVT-AV1-19 \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5

# 自定义选项，如使能 `ENABLE_NASM` 等。
cmake \
--build ./build_custom/ \
--target edit_cache

cmake --build ./build_custom/ --target install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/SVT-AV1-19"
    export LD_LIBRARY_PATH=${dir_prefix}/lib/:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile

# Verify
SvtAv1DecApp
SvtAv1EncApp --version
SvtAv1EncApp --help
```

# 4 gcc/clang ffmpeg

## 4.1 源码地址

```
https://ffmpeg.org/download.html
```

## 4.2 安装

### 4.2.1 x86_x64 环境编译

```shell
./configure \
--prefix=$HOME/.local/x64_ubuntu-24/ffmpeg-8.0 \
--enable-pic \
--enable-shared \
--enable-gpl \
--enable-libx264 \
--enable-libx265 \
--enable-libsvtav1

make -j8
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/ffmpeg-8.0"
    export LD_LIBRARY_PATH=${dir_prefix}/lib/:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
    export PATH=${dir_prefix}/bin/:$PATH
fi

source ~/.bash_profile

# Verify
ffmpeg -version
ffprobe -version
```

### 4.2.2 Enable cuda

如果有 cuda 环境，可以使能 nvcc 编译，使 ffmpeg 获得 NVIDIA GPU 的加速。

配置可以参考如下网站：

```
https://docs.nvidia.com/video-technologies/video-codec-sdk/11.1/ffmpeg-with-nvidia-gpu/index.html
```

```shell
./configure \
--prefix=$HOME/.local/mingw64/ffmpeg-8.0-cuda \
--enable-shared \
--enable-gpl \
--enable-libx264 \
--enable-libx265 \
--enable-libsvtav1 \
--enable-nonfree \
--enable-cuda-nvcc \
--enable-libnpp \
--extra-cflags=-I/d/070_Code/200_CUDA/v12.9.0/include \
--extra-ldflags=-L/d/070_Code/200_CUDA/v12.9.0/lib/x64

make -j32 && make install
```

### 4.2.3 交叉编译

以 arm64 为例。

```shell
./configure \
--prefix=$HOME/.local/hi3519dv500/ffmpeg-8.0 \
--cross-prefix=aarch64-linux-gnu-hi3519dv500-v2- \
--target-os=linux \
--arch=arm64 \
--enable-pic \
--enable-shared \
--enable-libx264 \
--enable-libx265 \
--enable-libsvtav1
```

# 5 msvc ffmpeg

不太建议用 msvc 编译 ffmpeg，如果不得已的话，尽量用有英文语言包的 msvc 编译器。

如果是非英文的 msvc 编译器，会比较麻烦。

这里，以中文的 msvc 编译器为例。

---

我使用的是 `ffmpeg-8.0` 版本，后续也许构建脚本会优化，就不需要这么麻烦了。

---

## 5.1 环境

首先需要确保环境中的编译器和链接器可被找到，及 `cl` 和 `link`。

具体可以参考：

```
https://trac.ffmpeg.org/wiki/CompilationGuide/MSVC
```

文中有提到，尽量使用和 `cl` 配套的微软链接器。

## 5.2 依赖

### 5.2.1 libx264

```shell
CC=cl CXX=cl ./configure \
--prefix=$HOME/.local/mingw64-msvc/x264 \
--enable-static \
--disable-swscale

make -j8 && make install
```

### 5.2.2 libx265

```shell
cmake \
-S ./source \
-B build_custom \
-DCMAKE_C_COMPILER=cl \
-DCMAKE_CXX_COMPILER=cl \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/mingw64-msvc/X265-4.1

cmake --build build_custom --config Release --parallel 8 --target install

# 安装后，将 lib 目录下的 `libx265.lib` 文件复制一份，并改名为 `x265.lib`，否则 ffmpeg 可能无法找到
```

### 5.2.3 libsvtav1

```shell
cmake \
-S . \
-B build_custom \
-DCMAKE_C_COMPILER=cl \
-DCMAKE_CXX_COMPILER=cl \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/mingw64-msvc/SVT-AV1-19

cmake --build build_custom --config Release --parallel 8 --target install
```

## 5.3 ffmpeg

### 5.3.1 配置

#### 5.3.1.1 cl 编译器

对于无英文语言包的 msvc 环境，需要额外做一些配置修改。

打开 `configure` 文件，找到多处 `Microsoft`。

脚本中通过编译器的打印确认编译器为 `cl`，其中有：

```shell
grep -q ^Microsoft
```

这个打印在英文的 msvc 环境中是可以的，因为 `cl` 编译器会将 `Microsoft` 作为打印的开头。

然而在非英文的 msvc 环境中，`Microsoft` 未必是打印的开头，所以可以改为：

```shell
grep -q Microsoft
```

如果 msvc 有英文语言包，那么脚本前的 `VSLANG=1033` 会生效，就可以不用做修改了。

#### 5.3.1.2 cc_ident

`configure` 脚本会基于编译器的打印，在源码根目录下生成 `config.h` 文件。

此文件中，会有 `CC_IDENT` 宏定义，`cl` 不允许里面出现中文。

这里，进一步在 `configure` 文件中做修改。

原内容：

```shell
if VSLANG=1033 $_cc -nologo- 2>&1 | grep -q Microsoft; then
	# Depending on the tool (cl.exe or link.exe), the version number
	# is printed on the first line of stderr or stdout
	_ident=$(VSLANG=1033 $_cc 2>&1 | grep Microsoft | head -n1 | tr -d '\r')
else
	_ident=$($_cc --version 2>/dev/null | head -n1 | tr -d '\r')
fi
```

此时，`_ident` 带有中文内容。

这里做修改：

```shell
# add function
sanitize_string() {
    local input="$1"
    local result=$(echo "$input" | tr -dc '[:print:]' | tr -d '\200-\377')
	
    if [ -z "$result" ]; then
        result="unknown"
    fi
    
    echo "$result"
}

# change `_ident` in `probe_cc` function
_ident=$(sanitize_string "$_ident")
echo "_ident: $_ident"
```

### 5.3.2 安装

```shell
./configure \
--cc=cl \
--cxx=cl \
--prefix=$HOME/.local/mingw64-msvc/ffmpeg-8.0 \
--enable-shared \
--enable-gpl \
--enable-libx264 \
--enable-libx265 \
--enable-libsvtav1 \
--arch=x86_64 \
--target-os=win64 \
--toolchain=msvc

make -j8 && make install
```
