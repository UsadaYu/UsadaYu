# Python

# 1 环境

## 1.1 Linux

### 1.1.1 Centos-7

* glibc version：2.17

* Compiler：gcc-15.2.0

### 1.1.2 Ubuntu-24

* glibc version：2.39

* Compiler：gcc-15.2.0

# 2 Python

## 2.1 安装文档与源码地址

### 2.1.1 libffi

```
https://sourceware.org/libffi/
```

### 2.1.2 openssl

```
https://www.openssl.org/source/
```

关于 `openssl`，强烈建议安装 `openssl-1.1.1` 系列的模块，否则，安装 python 后，还是可能提示：

```shell
Could not build the ssl module!
Python requires a OpenSSL 1.1.1 or newer
```

比如可以选择：

```
https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
```

### 2.1.3 zlib

```
https://www.zlib.net/
```

### 2.1.4 Python

```
https://www.python.org/ftp/python/
```

## 2.2 安装流程

### 2.2.1 libffi 安装

```shell
./configure \
--prefix=$HOME/.local/x64_ubuntu-24/libffi-3.4.5

make -j16
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/libffi-3.4.5"
    export LD_LIBRARY_PATH=${dir_prefix}/lib64:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
fi

source ~/.bash_profile
```

### 2.2.2 openssl 安装

```shell
./config \
--prefix=$HOME/.local/x64_ubuntu-24/openssl-1.1.1w

make -j16
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/openssl-1.1.1w"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile

# Verify
openssl version
```

### 2.2.3 zlib 安装

```shell
cmake \
-S . \
-B build \
-G Ninja \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/x64_ubuntu-24/zlib-1.3.1

cmake --build build --target install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/zlib-1.3.1"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/share/pkgconfig:$PKG_CONFIG_PATH
fi

source ~/.bash_profile
```

### 2.2.4 Python 安装

```shell
./configure \
--prefix=$HOME/.local/x64_ubuntu-24/Python-3.14.0 \
--with-openssl=$HOME/.local/x64_ubuntu-24/openssl-1.1.1w \
--enable-shared \
--enable-optimizations

make -j16
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/Python-3.14.0"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
    export PATH=${dir_prefix}/bin:$PATH
fi

source ~/.bash_profile
```

## 2.3 校验

```shell
# Check the path
which python3
which pip3

# Check the version
python3 --version
pip3 --version

# Write `Hello World`
python3
print("Hello World")
exit()

# pip install
pip3 install gcovr
pip3 install pyinstaller
pip3 list
```
