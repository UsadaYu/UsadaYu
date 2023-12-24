# Gnu Tool Install



# 1 环境

## 1.1 Linux

### 1.1.1 Centos-7

* glibc version：2.17

* Compiler：gcc-15.2.0



### 1.1.2 Ubuntu-24

* glibc version：2.39

* Compiler：gcc-15.2.0



# 2 binutils

## 2.1 binutils 源码地址

```
https://sourceware.org/pub/binutils/releases/
```



## 2.2 安装流程

```shell
./configure \
--prefix=$HOME/.local/x64_ubuntu-24/binutils-2.45

make -j16
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/binutils-2.45"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile

# Verify
ld -v
```



# 3 gcc

## 3.1 安装文档与源码地址

### 3.1.1 gcc 官方指定依赖

```
https://gcc.gnu.org/install/prerequisites.html
```



### 3.1.2 gmp

```
https://gmplib.org/
```



### 3.1.3 mpfr

```
https://www.mpfr.org/mpfr-current/
```



### 3.1.4 mpc

```
https://www.multiprecision.org/mpc/download.html
```



### 3.1.5 gcc

gcc 源码镜像地址，官方提供了 mirrors，任意选择一个下载。

```
https://gcc.gnu.org/mirrors.html
```



## 3.2 安装流程

### 3.2.1 gmp 安装

```shell
./configure \
--prefix=$HOME/.local/x64_ubuntu-24/gmp-6.3.0

make -j16
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/gmp-6.3.0"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
fi

source ~/.bash_profile
```



### 3.2.2 mpfr 安装

```shell
./configure \
--prefix=$HOME/.local/x64_ubuntu-24/mpfr-4.2.2/ \
--with-gmp=$HOME/.local/x64_ubuntu-24/gmp-6.3.0/

make -j16
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/mpfr-4.2.2"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
fi

source ~/.bash_profile
```



### 3.2.3 mpc 安装

```shell
./configure \
--prefix=$HOME/.local/x64_ubuntu-24/mpc-1.3.1/ \
--with-gmp=$HOME/.local/x64_ubuntu-24/gmp-6.3.0/ \
--with-mpfr=$HOME/.local/x64_ubuntu-24/mpfr-4.2.2/

make -j16
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/mpc-1.3.1"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
fi

source ~/.bash_profile
```



### 3.1.3 gcc 安装

```shell
./configure --prefix=$HOME/.local/x64_ubuntu-24/gcc-15.2.0/ \
--with-gmp=$HOME/.local/x64_ubuntu-24/gmp-6.3.0/ \
--with-mpfr=$HOME/.local/x64_ubuntu-24/mpfr-4.2.2/ \
--with-mpc=$HOME/.local/x64_ubuntu-24/mpc-1.3.1/

# 64 位安装可能会提示添加 `--disable-multilib` 选项。
# 或者也可以自行添加依赖的库。

make -j32
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/gcc-15.2.0"
    export LD_LIBRARY_PATH=${dir_prefix}/lib64:$LD_LIBRARY_PATH
    export PATH=${dir_prefix}/bin:$PATH
    
    export CC=${dir_prefix}/bin/gcc
    export ASM=${dir_prefix}/bin/gcc
    export CXX=${dir_prefix}/bin/g++
fi

source ~/.bash_profile

# Verify
gcc --version
g++ --version
```



# 4 gdb

## 4.1 gdb 源码地址

```
https://sourceware.org/pub/gdb/releases/?C=M;O=D
```



## 4.2 安装流程

```shell
./configure --prefix=$HOME/.local/x64_ubuntu-24/gdb-16.3 \
--with-gmp=$HOME/.local/x64_ubuntu-24/gmp-6.3.0/ \
--with-mpfr=$HOME/.local/x64_ubuntu-24/mpfr-4.2.2/ \
--with-mpc=$HOME/.local/x64_ubuntu-24/mpc-1.3.1/

make -j16
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/gdb-16.3"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile

# Verify
gdb --version
gdbserver --version
```



# 5 glibc

## 5.1 glibc 源码地址

```
https://ftp.gnu.org/gnu/libc/
```



## 5.2 安装流程

### 5.2.1 安装错误

glibc 的 automake 会检查一些工具版本，环境等，此时可能会遇到以下几个问题。



#### 5.2.1.1 make 版本错误

提示 make 版本过低。

于是我通过源码安装了 make，可是还是显示 make 版本过低。

从 config.log 日志可以看到环境变量 `MAKE=gmake`，所以需要将 MAKE 变量改为 make，或安装高版本 gmake。



#### 5.2.1.2 动态库环境变量错误

报错：

```
*** LD_LIBRARY_PATH shouldn't contain the current directory when building glibc
```

检查了下我的环境变量，其实没有问题，不过末尾多加了一个符号 `:`，这在编译 glibc 时是不允许的。

因此将末尾的 `:` 去掉就行



### 5.2.2 glibc 安装

```shell
mkdir -p build
cd build

MAKE=make ../configure \
--prefix=$HOME/.local/x64_ubuntu-24/glibc-2.40

make -j8
make install
```



### 5.2.3 自定义 glibc 的使用

#### 5.2.3.1 关于 ld-linux-x86-64.so.2

glibc 安装后，其中有一个动态库为：`ld-linux-x86-64.so.2`，Linux 下这个库用于加载其它动态库。

在 Linux 下，大部分可执行文件都会依赖其它动态库。

比如 ./main 程序，通过以下命令查看它依赖的动态库：

```shell
/bin/ldd ./main
```

这个命令不仅可以打印出 ./main 依赖的动态库，同时可以递归地将依赖库的依赖库打印出来。

举个例子，./main 依赖 `libavformat.so.61`，`libavformat.so.61` 依赖 `libz.so.1`，那么 ldd 会将其全部打印显示。

如果仅需查看 ./main 的依赖，而无需递归地打印其依赖的依赖，那么可以使用以下命令：

```shell
objdump -p ./main | grep NEEDED
```

或

```shell
readelf -d ./main
```



稍加尝试，可以发现几乎所有可执行文件多少都会依赖其它动态库，基础的命令如 ls、vim 也不例外。

因此 `ld-linux-x86-64.so.2` 的重要性不言而喻，

如果 `ld-linux-x86-64.so.2` 出问题，一般能用的命令只剩 `pwd` 和 `cd` 了。



需要注意的是，默认情况下，可执行文件都会优先寻找 `/lib64/ld-linux-x86-64.so.2` 这个动态库。

如果 glibc 不安装在根目录下，那么自安装的 `ld-linux-x86-64.so.2` 不可以直接使用。

网上说，可以通过修改 `LD_PRELOAD` 环境变量指定  `ld-linux-x86-64.so.2` 的路径，思路就是：

```shell
export LD_PRELOAD=${dir_prefix}/lib/ld-linux-x86-64.so.2
```

不过我试了下，在我的环境下，这种修改方式只会产生无尽的 `Segmentation fault`。



#### 5.2.3.2 使用自定义的 glibc

和所有开源库一样，安装 glibc 后，安装目录下有 `bin; lib; include` 等几个目录。

这里尽量不要直接把这些目录添加到环境变量中，尤其是 lib 目录，绝对不可以添加到 `LD_LIBRARY_PATH`。

因为这样自安装的库会覆盖 `/lib64` 目录下的库，比如 `libc.so` 文件；

但是 `ld-linux-x86-64.so.2` 文件的环境变量不是通过 `LD_LIBRARY_PATH` 指定的。

如果这样做，那么 `/lib64/ld-linux-x86-64.so.2` 会寻找自安装的 `libc.so` 文件，版本大概率不匹配。

比如此时运行 vim 命令就可能出现如下错误：

```
vim: /lib64/ld-linux-x86-64.so.2: version `GLIBC_2.35' not found
```



那么如果没有 root 权限，又的确要使用 glibc 该怎么办？

一般来说，下载新版本的 glibc 无非是希望编译时程序可以依赖新一些新版本的库，如 `pthread.so`。

直接链接自安装的 glibc 库是没有用的，因为这样会导致运行时 `ld-linux-x86-64.so.2` 和自安装的库版本不匹配。

所以这一般需要借助一些工具来实现。

这里我使用的是 `patchelf`。



##### 5.2.3.2.1 patchelf 源码地址

```
https://github.com/NixOS/patchelf
```



##### 5.2.3.2.2 patchelf release 地址

```
https://github.com/NixOS/patchelf/releases
```



##### 5.2.3.2.3 patchelf 的使用

对于一个已经编译的程序，使用以下命令可以指定其 `ld-linux-x86-64.so.2` 的路径。

```shell
patchelf --set-interpreter $HOME/.local/x64_ubuntu-24/glibc-2.40/lib/ld-linux-x86-64.so.2 ./main
```

因为 `ld-linux-x86-64.so.2` 改变了，所以其它一些依赖的动态库路径需要额外指定。

`ld-linux-x86-64.so.2` 默认是从它自身同级目录下搜索其它动态库。

所以使用 `patchelf` 后，需要保证依赖库在 `ld-linux-x86-64.so.2` 的同级目录下或在 `LD_LIBRARY_PATH` 中。



# 6 libtool

## 6.1 libtool 源码地址

```
https://github.com/autotools-mirror/libtool/tags
```



## 6.2 安装流程

```shell
./configure \
--prefix=$HOME/.local/x64_ubuntu-24/libtool-2.5.4

make -j16
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/libtool-2.5.4"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile

# Verify
libtool --version
libtoolize --version
```

