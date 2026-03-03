# GoogleTest

# 1 环境

## 1.1 Linux

### 1.1.1 Centos-7

* glibc version：2.17

* Compiler：gcc-15.2.0

### 1.1.2 Ubuntu-24

* glibc version：2.39

* Compiler：gcc-15.2.0

# 2 源码地址

```
https://github.com/google/googletest/releases
```

# 3 安装流程

```shell
cmake \
-S . \
-B build \
-G Ninja \
-DBUILD_SHARED_LIBS=ON \
-DCMAKE_INSTALL_PREFIX=$HOME/.local/x64_ubuntu-24/googletest-1.17.0

cmake --build build --target install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/googletest-1.17.0"
    export LD_LIBRARY_PATH=${dir_prefix}/lib64/:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib64/pkgconfig:$PKG_CONFIG_PATH
    export CMAKE_PREFIX_PATH=${dir_prefix}:$CMAKE_PREFIX_PATH
fi

source ~/.bash_profile
```
