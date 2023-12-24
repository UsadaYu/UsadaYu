# LLVM



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
https://github.com/llvm/llvm-project/releases
```

注意下载时下载 `source code`，其它都是一些子模块，安装起来会比较麻烦。



# 3 安装流程

## 3.1 官方参考文档

这里的 cmake 配置可以参考：

```
https://llvm.org/docs/CMake.html
```



## 3.2 构建前置说明

在非标准或自定义的环境中，系统的默认路径总是和自定义的路径存在差异。

如编译 llvm 的是自定义的 gcc，或者是 `built with customized gcc` 的 clang，那么编译时可能总会遇到各种问题。

关于此，llvm 的构建阶段，有一个 cmake 选项是 `GCC_INSTALL_PREFIX`。

这个选项会告诉 llvm 的构建脚本一些 gcc 的信息，如 gcc 的库路径，编译选项等等。

但是，llvm 官方希望废弃这个选项，`llvm-21.1.8` 中，`clang/CMakeLists.txt` 中有如下内容：

```cmake
set(USE_DEPRECATED_GCC_INSTALL_PREFIX OFF CACHE BOOL "Temporary workaround before GCC_INSTALL_PREFIX is completely removed")
set(GCC_INSTALL_PREFIX "" CACHE PATH "Directory where gcc is installed." )
set(DEFAULT_SYSROOT "" CACHE STRING
  "Default <path> to all compiler invocations for --sysroot=<path>." )
if(GCC_INSTALL_PREFIX AND NOT USE_DEPRECATED_GCC_INSTALL_PREFIX)
  message(FATAL_ERROR "GCC_INSTALL_PREFIX is deprecated and will be removed. Use "
    "configuration files (https://clang.llvm.org/docs/UsersManual.html#configuration-files)"
    "to specify the default --gcc-install-dir= or --gcc-triple=. --gcc-toolchain= is discouraged. "
    "See https://github.com/llvm/llvm-project/pull/77537 for detail.")
endif()
```

大致意思是，clang 可以依赖 gcc，但依赖信息不再在构建和编译链接时决定，而是安装后走用户自定义配置文件。

不过这样会带来一个比较大的问题。

llvm 编译一般分为两个阶段：

* 一阶段 (Host Build)。编译时会使用用户自定义的编译器，如 gcc。
* 二阶段 (Runtimes Build)。clang 开始自举编译，即使用刚刚编译好的 clang/clang++ 编译 runtimes。

若使用 `GCC_INSTALL_PREFIX` ，那么关于 gcc 的信息，会被硬编码进 clang 编译器中，

关于 gcc 的一些选项也自然传递到了第二阶段。

这里有一个关键点是，截至 `llvm-21.1.8`，二阶段的编译链接选项都无法通过常规的方式传递。

如 `CMAKE_EXE_LINKER_FLAGS`, `CMAKE_SHARED_LINKER_FLAGS` 等等在编译二阶段通常都不起作用。

如果需要强制透传，可能需要使用一些 llvm 的内置选项。会比较麻烦，视版本而定。

如果 `GCC_INSTALL_PREFIX` 选项被废弃，二阶段编译链接时就可能发生一系列错误。



这也就是官方所说的，不使用 `GCC_INSTALL_PREFIX`，而走配置文件。

不过难道以后编译 llvm 到一半，还需要手动添加配置，然后才能进入二阶段？

这显然不可能，llvm 官方目前更倾向改进 clang 在一阶段构建时的默认推导能力，

即在一阶段编译时，不使用 `GCC_INSTALL_PREFIX` 也可以自动定位到正确的 gcc 信息。

实际上官方很早就提到要废弃 `GCC_INSTALL_PREFIX`，但是目前迟迟没有完全实现，估计阻力不小。

关于这点，可以参考一篇论坛的讨论帖子：

```
https://discourse.llvm.org/t/add-gcc-install-dir-deprecate-gcc-toolchain-and-remove-gcc-install-prefix/65091
```



## 3.3 安装

```shell
cmake \
-S ./llvm \
-B build \
-G "Ninja" \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_C_COMPILER=gcc \
-DCMAKE_CXX_COMPILER=g++ \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/x64_ubuntu-24/llvm-21.1.8 \
-DLLVM_ENABLE_PROJECTS="bolt;clang;clang-tools-extra;lld;lldb;mlir;polly" \
-DLLVM_ENABLE_RUNTIMES="compiler-rt;libc;libcxx;libcxxabi;libunwind;libclc;openmp" \
-DUSE_DEPRECATED_GCC_INSTALL_PREFIX=ON \
-DGCC_INSTALL_PREFIX=$HOME/.local/x64_ubuntu-24/gcc-15.2.0 \
-DLLDB_ENABLE_CURSES=OFF

# llvm 编译得比较慢，构建时尽量使用 Ninja。
# 上述，一些可以自行参考官方文档决定。
# libclc: OpenCL 内核支持库，程序运行在 GPU 等环境时可能需要，通常的 C/C++ 开发不需要。
# openmp: OpenMP 多线程运行时库，开发 CPU 多线程并行程序时使用。
# `-DLLVM_ENABLE_RUNTIMES=all` 使能所有 `LLVM_ENABLE_RUNTIMES` 选项。
# 一些选项如 `libc` 对 glibc 版本有一定的要求，自行决定安装即可。

# 若 `GCC_INSTALL_PREFIX` 还未被废弃，在官方没有提供更好的方法之前，强烈建议启用此选项，可以避免很多麻烦。
# llvm 是一个庞大的工程，编译可能会出现一些文件或工具冲突的情况。
# 因此构建时可指定 `CMAKE_IGNORE_PATH` 参数忽略一些搜索目录。

ccmake ./build

cmake --build ./build/ --target install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/llvm-21.1.8"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=${dir_prefix}/lib/x86_64-unknown-linux-gnu:$LD_LIBRARY_PATH
    export PATH=${dir_prefix}/bin:$PATH
    export CMAKE_PREFIX_PATH=${dir_prefix}:$CMAKE_PREFIX_PATH
fi

source ~/.bash_profile

# Verify
clang --version
clang++ --version
```



## 3.4 配置

如果 clang 是基于 gcc 的，若没有在编译时指定 `GCC_INSTALL_PREFIX` 等参数，可能需要手动添加配置文件。



### 3.4.1 说明

clang 需要找到 gcc 的位置以获取一些信息，可以通过如下命令查看：

```shell
clang -v -E -x c++ /dev/null
```

举个例子，若本地安装了交叉工具链等，clang 可能会默认搜索交叉工具链下错误的 gcc 路径。

解决上述问题有两个办法：

* (1) 每次使用 clang 编译时都手动指定参数；
* (2) 走配置文件，无需每次编译都手动指定参数。

---

关于配置文件中的 gcc 选项，官方不建议使用 `--gcc-toolchain`，`--gcc-install-dir` 或 `--gcc-triple` 是更好的选择。

---



### 3.4.2 官方配置说明

#### 3.4.2.1 配置文件

```
https://clang.llvm.org/docs/UsersManual.html#configuration-files
```



#### 3.4.2.2 命令选项

```
https://clang.llvm.org/docs/ClangCommandLineReference.html
```



### 3.4.3 配置

如果需要通过配置文件配置 llvm 的一些参数，首先需要在 llvm 可执行文件的目录下建立配置文件。

clang

```shell
vim "$(dirname $(which clang))/clang.cfg"

--gcc-install-dir=/home/usadayu/.local/x64_ubuntu-24/gcc-15.2.0/lib/gcc/x86_64-pc-linux-gnu/15.2.0
```



clang++

```shell
vim "$(dirname $(which clang))/clang++.cfg"

--gcc-install-dir=/home/usadayu/.local/x64_ubuntu-24/gcc-15.2.0/lib/gcc/x86_64-pc-linux-gnu/15.2.0
```



如果需要指定 `--gcc-toolchain`，类似如下：

```shell
--gcc-toolchain=/home/usadayu/.local/x64_ubuntu-24/gcc-15.2.0
```

但不建议使用，未来也可能废弃。
