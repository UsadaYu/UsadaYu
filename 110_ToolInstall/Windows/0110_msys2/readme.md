# Msys2

# 1 环境

## 1.1 Windows 11

# 2 官方地址

```
https://www.msys2.org/
```

# 3 注意事项

按流程安装完毕后，程序的目录下，会提供多个和可执行文件。分别为：

mingw32、mingw64、msys2。

## 3.1 mingw32

32 位原生 Windows 程序，使用 `i686-w64-mingw32` 工具链。

## 3.2 mingw64

64 位原生 Windows 程序，使用 `x86_64-w64-mingw32` 工具链。

## 3.3 msys2

模拟 Unix-like 环境，依赖 `msys-2.0.dll`。

# 4 环境配置

## 4.1 环境隔离

值得注意的是，上述三个可执行文件打开后，指向的目录是相同的，但是它们是不同的环境。

所以，在 mingw64 中编译的文件不一定能在 msys2 环境下运行。

其实程序本身，通过目录来隔离了三种环境。

比如，可执行文件。msys2 的可执行文件在 `/usr/bin` 目录下，mingw64 的可执行文件在 `/mingw64/bin` 目录下。

因此，在自行操作时，一般用选择一种环境长期使用即可，当然，环境变量还是需要区分的。

通过如下方式可以实现环境变量的隔离，打开 `~/.bash_profile` 文件，按如下方式分别配置环境变量即可。

```shell
# ~/.bash_profile

case "$MSYSTEM" in
  MINGW64)
    source ~/.bashrc.mingw64  # 加载 MinGW64 的配置
    ;;
  MINGW32)
    source ~/.bashrc.mingw32  # 加载 MinGW32 的配置
    ;;
  MSYS)
    source ~/.bashrc.msys     # 加载 MSYS 的配置
    ;;
esac
```

## 4.2 环境初始化

更换下载源

```
sed -i "s#mirror.msys2.org/#mirrors.ustc.edu.cn/msys2/#g" /etc/pacman.d/mirrorlist*
```

初始化，安装后窗口会关闭，打开程序后再来一次即可

```shell
pacman -Syu
```

更新基础软件包

```shell
pacman -Su
```

## 4.3 工具安装

### 4.3.1 不区分平台的工具

一些基础工具不依赖环境，如 git，automake，bash 类命令，sed，grep 等。这些工具默认安装在 `/usr/bin` 目录下。

```shell
pacman -S autoconf
pacman -S automake
pacman -S m4
pacman -S git
```

### 4.3.2 msys2

msys2 的工具同样默认安装在 `/usr/bin` 目录下。

对于 `msys2`，不需要加前缀，如下：

```shell
pacman -S libtool
pacman -S make
pacman -S gcc
pacman -S python python-pip
```

### 4.3.3 mingw64

mingw64 的工具默认安装在 `/mingw64/bin` 目录下。

需要注意的是，如果没有安装 mingw64 的工具，环境变量指引系统使用 `/usr/bin` 目录下的工具。

所以，在进行操作时，确保安装了正确的工具与依赖，以免使用了错误的软件。

对于 `mingw64`，大多数工具，安装时需要在前面加上前缀 `mingw-w64-x86_64`，如下：

```shell
pacman -S mingw-w64-x86_64-toolchain
pacman -S mingw-w64-x86_64-libtool
pacman -S mingw-w64-x86_64-make
pacman -S mingw-w64-x86_64-cmake mingw-w64-x86_64-cmake-gui
pacman -S mingw-w64-x86_64-clang
pacman -S mingw-w64-x86_64-gdb
pacman -S mingw-w64-x86_64-yasm
pacman -S mingw-w64-x86_64-nasm
pacman -S mingw-w64-x86_64-python mingw-w64-x86_64-python-pip
```

### 4.3.4 关于 pip

如果 python 是用 `pacman` 安装的，那么安装 python 其它模块时可能也需要用 `pacman`。

例如 msys2，安装 `setuptools` 命令如下：

```shell
pacman -S python-setuptools
```

不过 `pacman` 的模块可能不像官方提供的那么齐全。

若想用 pip 安装，那么一开始就不建议使用 `pacman` 安装 python。
