# CMake

# 1 环境

## 1.1 Linux

### 1.1.1 Centos-7

* glibc version：2.17

* Compiler：gcc-15.2.0

### 1.1.2 Ubuntu-24

* glibc version：2.39

* Compiler：gcc-15.2.0

# 2 Cmake

## 2.1 官方地址

```
https://cmake.org/download/
```

官方提供了源码和已经编译的各平台的可执行文件。

## 2.2 安装流程

源码目录中，提供了 automake 的 `configure` 文件，也提供了 `CMakeLists.txt` 文件，这里用 cmake 构建编译。

```shell
cmake \
-S . \
-B build \
-G Ninja \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/x86_64/cmake-4.2.0

# 这里配置 `CMAKE_BUILD_TYPE` 为 `Release`。
# 如果是有 gui 界面的环境（或 qt 配置），可以使能 `BUILD_QtDialog`。
cmake --build build --target edit_cache

cmake --build build/ --target install

# Environment
vim ~/.bash_profile

export PATH=$HOME/.local/x86_64/cmake-4.2.0/bin:$PATH

source ~/.bash_profile

# Verify
cmake --version
```

## 2.3 配置说明

cmake 是支持使用 gui 界面（或类 gui 界面）配置编译参数的，一般在构建类 `nmake` 脚本时命令如下：

```shell
cmake --build build/ --target edit_cache
```

官方提供的预编译二进制文件版本一般都没有问题，如果是像上述自行手动编译的，那么可能会有如下报错：

```
Running CMake cache editor...
Error opening terminal: xterm.
```

产生这种情况一般是环境变量或库的缺失导致的，可以通过如下步骤检查：

### 2.3.1 ncurses 库

这个库用于使用文本生成类 gui 界面，可以通过如下命令检查是否已经安装。

#### 2.3.1.1 Debian / Ubuntu

```shell
dpkg -l | grep ncurses
```

#### 2.3.1.2 Centos

```shell
rpm -qa | grep ncurses
```

#### 2.3.1.3 Arch

```shell
pacman -Q | grep ncurses
```

### 2.3.2 环境变量

检查如下两个环境变量，如果有为空的环境变量，说明环境变量缺失。

```shell
echo $TERM
echo $TERMINFO
```

若环境变量缺失，通过如下方式配置：

#### 2.3.2.1 搜索 terminfo 路径

```shell
whereis terminfo
```

打印如下：

```
terminfo: /etc/terminfo /lib/terminfo /usr/share/terminfo
```

详细看看哪个目录下有正确的文件，比如我的在 `/usr/share/terminfo` 下。

```shell
ls /usr/share/terminfo

# 打印
a  A  b  c  d  e  E  g  h  j  k  l  m  n  p  r  s  t  v  w  x
```

#### 2.3.2.2 变量配置

配置环境变量如下：

```shell
vim ~/.bash_profile

export TERM=vt100
export TERMINFO=/usr/share/terminfo

source ~/.bash_profile
```

此时再次查看环境变量，显示如下即可：

```shell
echo $TERM ; echo $TERMINFO

# 打印
xterm
/usr/share/terminfo
```
