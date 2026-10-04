# Termux

# 1 基础模块配置

```shell
pkg update && pkg upgrade
```

```shell
pkg install build-essential
pkg install clang
pkg install git
pkg install libopenblas
pkg install make
pkg install pkg-config

pkg install python
pkg install python-lxml
pkg install python-numpy

pkg install tur-repo

pkg update
```

```shell
# export CFLAGS="-Wno-deprecated-declarations -Wno-unreachable-code"

pip install pandas
pip install pyahocorasick
pip install setuptools
```

```shell
# 通过此命令授予应用必要的权限
termux-setup-storage
```

# 2 更改界面配色

```shell
mkdir -p ~/.termux
```

```shell
# 类似 vim
nano ~/.termux/colors.properties

# 添加以下内容，即为白底（米色）黑字
background = #ebe8d9
foreground = #000000

# 保存：组合键 ctrl + O
# 确认文件名：回车键 Enter
# 退出：组合键 ctrl + X

# 刷新界面
termux-reload-settings
```

# 3 自启动

## 3.1 应用自启动

以 `sshd` 为例。

### 3.1.1 .bashrc

在脚本中追加啊如下命令，每次打开 Termux 就会自动运行 `sshd`。

```shell
echo "sshd" >> ~/.bashrc
```

### 3.1.2 termux-services

官方推荐使用 `termux-services` 进程管理框架来管理 `sshd`

```shell
pkg install termux-services

# 可能需要重启 Termux

# 启用 sshd 服务
sv-enable sshd

# 停用 sshd 服务
sv-disable sshd

# 配置后重启 Termux 即可生效
```

## 3.2 Termux 自启动

可查阅有关 `Termux:Boot` 的文档。

# 4 将手机挂载到 Windows 

## 4.1 手机端 Termux

```shell
# 如果没有 openssh 则安装
pkg install openssh

# 记下用户名，通常是 u0_aXXXX
whoami

# 设置连接密码
passwd
```

### 4.1.1 网络

要挂载的话，必须保证手机和电脑处于同一网段，不然要互通有点麻烦。

常用的方式是让**电脑和手机连同一个 WLAN** 或者**手机给电脑开热点**。

```shell
ifconfig

# 查看手机的局域网 IP 地址（inet），通常有几下几种打印
inet 127.0.0.1 # 回环
inet 198.18.0.1 # 可能是 Proxy 地址
inet 192.168.10.4 # 通常是住宅 WLAN
inet 10.21.196.184 # 可能是为手机数据流量分配的地址
inet 10.84.125.204 # 可能是为手机热点分配的地址
```

### 4.1.2 开启 OpenSSH 服务端进程

```shell
sshd

# 可以通过 pgrep 查看进程是否已启动
pgrep sshd
```

**Termux 的 SSH 默认端口是 8022 而不是 22**

## 4.2 Windows 端

### 4.2.1 下载 rclone 和 WinFsp

rclone 下载地址：

```
https://rclone.org/downloads/
```

WinFsp 下载地址：

```
https://winfsp.dev/rel/
```

下载安装后添加目录到环境变量。

### 4.2.2 ssh 测试

```shell
# WLAN 地址
ssh u0_a493@192.168.10.4 -p 8022

# 开启热点后，使用手机地址
ssh u0_a493@10.21.196.184 -p 8022
```

### 4.2.3 rclone 配置

```shell
rclone config

# 建立一个新的 remote，例如命名为 Android-Termux
```

> name: 建立任意名称（如 Android-Termux-Hotspot 或 Android-Termux-WLAN）
>
> Storage: 选择 `SSH/SFTP (sftp)` 的索引
>
> Host: 手机的地址（来自 `ifconfig`）
>
> User: 用户名（来自 `whoami`）
>
> Port: 8022
>
> SSH password: SSH 密码（来自 `passwd`）
>
> 其余都可走默认

### 4.2.3 rclone 测试

```shell
rclone lsd Android-Termux-WLAN:
```

### 4.2.4 挂载命令

```shell
# - (1) 将 `/storage/emulated/0/Pictures` 目录挂载到本地 X 盘
#
# - (2) 挂载的目录范围不要过大
#
# - (3) 挂载的权限和手机一样，都在沙盒内，不如接 USB 权限大。访问速度看网速，通常不太快

rclone mount Android-Termux-WLAN:/storage/emulated/0/Pictures X: --vfs-cache-mode full
```
