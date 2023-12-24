# libunwind



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
https://github.com/libunwind/libunwind/releases
```



# 3 安装流程

源码目录中，提供了 cmake 的脚本，不过 `libunwind-1.8.3` 的 `CMakeLists.txt` 脚本中有以下判断。

说明当前版本的 cmake 仅支持 Visual Studio 环境下编译。

```cmake
if ("${CMAKE_GENERATOR}" MATCHES "^Visual Studio.*$")
	# ...
endif ()
```

因此，这里使用 automake 编译。



## 3.1 x86_64

源码目录下默认是没有 `configure` 文件的，不过有 `configure.ac` 文件，所以可以通过以下流程安装。

```shell
autoreconf -i
./configure \
--prefix=$HOME/.local/x64_ubuntu-24/libunwind-1.8.3 \
--disable-tests

# gcc-15.2.0 编译 libunwind-1.8.3 的测试模块会报错，可以禁用测试模块编译。

make -j16
make install

# Environment
vim ~/.bash_profile

if [[ "$docker_host" == *"ubuntu24"* ]]; then
    dir_prefix="${dir_prefix_local}/x64_ubuntu-24/libunwind-1.8.3"
    export LD_LIBRARY_PATH=${dir_prefix}/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${dir_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH
fi

source ~/.bash_profile
```



## 3.2 aarch64

aarch64 平台，如 hi3519dv500，配置如下：

```shell
./configure \
--prefix=$HOME/.local/hi3519dv500/libunwind-1.8.3 \
--host=aarch64-linux-gnu \
CC=aarch64-linux-gnu-hi3519dv500-v2-gcc \
CXX=aarch64-linux-gnu-hi3519dv500-v2-g++
```



# 4 使用说明

## 4.1 代码

这里，用 c 编写一个正向打印函数调用关系的函数，打印格式为 `func_a -> func_b -> func_c`。

```c
#include <libunwind.h>
#include <stdbool.h>
#include <stdio.h>

static inline void print_call_chain() {
  unw_cursor_t cursor;
  unw_context_t context;
  unw_getcontext(&context);
  unw_init_local(&cursor, &context);

#define MAX_DEPTH 100
  char names[MAX_DEPTH][256];
  int depth = 0;
  while (depth < MAX_DEPTH && unw_step(&cursor) > 0) {
    unw_word_t offset;
    if (unw_get_proc_name(&cursor, names[depth], sizeof(names[depth]),
                          &offset) == 0) {
      names[depth][sizeof(names[depth]) - 1] = '\0';
      depth++;
    }
  }
#undef MAX_DEPTH

  bool first = true;
  for (int i = depth - 1; i >= 0; i--) {
    if (first) {
      fprintf(stderr, "%s", names[i]);
      first = false;
    } else {
      fprintf(stderr, " -> %s", names[i]);
    }
  }
  fprintf(stderr, " -> %s\n", __func__);
}
```



## 4.1 编译

使用 unwind 的静态库编译上述代码。

### 4.1.1 x86_64 平台

这里，x86_64 平台的 `libunwind.pc` 文件中有：

```shell
Libs.private: -llzma -lz
```

所以编译命令参考如下 (`-lz` 一般可以不加)：

```shell
gcc \
-o main \
main.c \
-L./lib/x86 \
-lunwind-x86_64 \
-lunwind \
-llzma \
-lz
```

编译是，注意库的前后依赖关系。

`-lunwind-x86_64` 和 `-lunwind` 顺序不能调换。



### 4.1.2 aarch64 平台

以 hi3519dv500 为例，其编译命令参考如下：

```shell
aarch64-linux-gnu-hi3519dv500-v2-gcc \
-o main \
main.c \
-L./lib/hi3519dv500 \
-lunwind-aarch64 \
-lunwind
```

