# MSVC



# 1 环境

## 1.1 Windows 11



# 2 说明

Visual Studio 体积较大，如果代码为了兼容 MSVC 编译，可以单独下载 MSVC 而非整个 Visual Studio。

安装时，一定要安装英文语言包，否则后续遇到一些中文编译报错，网上能找到的信息质量都不高。

# 3 官方地址

(1) vs_BuildTools

```
https://visualstudio.microsoft.com/zh-hans/downloads/
```

(2) Windows Kits

```
https://learn.microsoft.com/zh-cn/windows/apps/windows-sdk/downloads
```



# 4 MSVC

打开 `vs_BuildTools.exe` 所在的终端，因为中文的一些条目看起来云里雾里，不是很友好，所以强制用英文运行。

```
vs_BuildTools.exe --locale en-US
```



这里可以选择 `X86_64 MSVC`, `SDK`, `Address Sanitizer`，其余套件自行选择。

比如 CMake，LLVM 这些个人感觉还是额外安装，不和 VS 捆在一起好一些。

安装后，添加环境变量到 `INCLUDE`, `LIB`, `PATH` 即可。如：

```shell
# --- INCLUDE ---
D:\070_Code\120_Microsoft\Visual Studio\18\BuildTools\VC\Tools\MSVC\14.50.35717\include

# --- LIB ---
D:\070_Code\120_Microsoft\Visual Studio\18\BuildTools\VC\Tools\MSVC\14.50.35717\lib\x64

# --- PATH ---
D:\070_Code\120_Microsoft\Visual Studio\18\BuildTools\VC\Tools\MSVC\14.50.35717\bin\Hostx64\x64
```



# 5 Windows Kits

Kits 安装时，其访问目录的权限在一些环境可能需要修改一下。

找到打算安装 Kits 的目录：

**属性 -> 安全 -> SYSTEM**

检查 `SYSTEM` 的权限，直接勾上 `完全控制`。



如果没有 `SYSTEM` 项，那么：

**添加 -> 输入 SYSTEM -> 检查名称**



然后再运行 `winsdksetup.exe` 即可。



安装后，添加环境变量到 `INCLUDE`, `LIB`, `PATH` 即可。如：

```shell
# --- INCLUDE ---
D:\070_Code\120_Microsoft\Windows Kits\10\Include\10.0.26100.0\cppwinrt
D:\070_Code\120_Microsoft\Windows Kits\10\Include\10.0.26100.0\shared
D:\070_Code\120_Microsoft\Windows Kits\10\Include\10.0.26100.0\ucrt
D:\070_Code\120_Microsoft\Windows Kits\10\Include\10.0.26100.0\um
D:\070_Code\120_Microsoft\Windows Kits\10\Include\10.0.26100.0\winrt

# --- LIB ---
D:\070_Code\120_Microsoft\Windows Kits\10\Lib\10.0.26100.0\ucrt\x64
D:\070_Code\120_Microsoft\Windows Kits\10\Lib\10.0.26100.0\ucrt_enclave\x64
D:\070_Code\120_Microsoft\Windows Kits\10\Lib\10.0.26100.0\um\x64

# --- PATH ---
D:\070_Code\120_Microsoft\Windows Kits\10\bin\10.0.26100.0\x64
```

