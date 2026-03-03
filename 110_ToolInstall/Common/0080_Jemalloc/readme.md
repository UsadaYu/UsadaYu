# Jemalloc

# 1 环境

## 1.1 Linux

### 1.1.1 Centos-7

* glibc version：2.17

* Compiler：gcc-15.2.0

### 1.1.2 Ubuntu-24

* glibc version：2.39

* Compiler：gcc-15.2.0

# 2 源码地址

截止至 2025-10-30，官方的 `release` 版本以及很久没更新了。

不过下载 `dev` 分支一直在更新，下载 `dev` 分支其实也差不多。

```
https://github.com/jemalloc/jemalloc/tree/dev
```

# 3 安装流程

* `--enable-prof` 表示启用堆分析和泄漏检测功能。

* `--build` 指定当前系统环境，不指定也可以。

* `--host` 表示交叉编译的工具链，如果不使用 `--host` 只指定编译工具，会提示：

```shell
*If you meant to cross compile, use `--host'.*
```

x86_64 环境下可不指定 `--host` 参数。

## 3.1 非交叉编译

```shell
./autogen.sh

./configure \
--prefix=$HOME/.local/x64_ubuntu-24/jemalloc-dev \
--enable-prof

make -j8
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/jemalloc-dev"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile
```

## 3.2 交叉编译

交叉编译 aarch64、arm32 等平台。

hi3519dv500 平台：

```shell
./autogen.sh

./configure \
--prefix=$HOME/.local/hi3519dv500/jemalloc-dev \
--enable-prof \
--build=x86_64-unknown-linux-gnu \
--host=aarch64-linux-gnu \
CC=aarch64-linux-gnu-hi3519dv500-v2-gcc \
CXX=aarch64-linux-gnu-hi3519dv500-v2-g++

make -j8
make install
```

hi3516dv300 平台：

```shell
./autogen.sh

./configure \
--prefix=$HOME/.local/hi3516dv300/jemalloc-dev \
--enable-prof \
--build=x86_64-unknown-linux-gnu \
--host=arm-himix200v002-linux \
CC=arm-himix200v002-linux-gcc \
CXX=arm-himix200v002-linux-g++

make -j8
make install
```

sd3403v100 平台：

```shell
./autogen.sh

./configure \
--prefix=$HOME/.local/sd3403v100/jemalloc-dev \
--enable-prof \
--host=aarch64-linux-gnu \
CC=aarch64-himix210-linux-sd3403v100-v1-gcc \
CXX=aarch64-himix210-linux-sd3403v100-v1-g++

make -j8
make install
```
