# MSVC

# 1 环境

## 1.1 Windows 11

# 2 说明

Visual Studio 体积较大，如果代码为了兼容 MSVC 编译，可以单独下载 MSVC 而非整个 Visual Studio。

安装时，一定要安装英文语言包，否则后续遇到一些中文编译报错，网上能找到的信息质量都不高。

---

截至 **2026-04-12**，因为微软一些莫名奇妙的限制，安装时可能总是碰到不理想的情况。

我感觉最好的安装流程应该如下（不同环境可能存在差异，但应该都差不多）。

(1) 用 `winsdksetup.exe` 单独先安装 `Kits`，这里是允许自定义目录的，随便安装个版本也行。

(2) 用 `vs_BuildTools` 安装各种组件，此时选择 `Kits` 他一般会安装到已经安装的 `Kits` 目录下。

(3) 用环境变量指引需要的版本即可。

---

直接用 `vs_BuildTools` 安装 `Kits`，它一般会将其默认安装到磁盘根目录下，如：`D:\Windows Kits`。

此时一些环境下用 `winsdksetup.exe` 安装时，因为一些奇怪的原因，可能出现安装无限套娃的情况。

所以如果已经安装了 `Kits`，也可以先卸载掉。

# 3 官方地址

(1) Windows Kits

```
https://learn.microsoft.com/zh-cn/windows/apps/windows-sdk/downloads
```

(2) vs_BuildTools

```
https://visualstudio.microsoft.com/zh-hans/downloads/
```

# 4 Windows Kits

---

关于其版本，截至 **2026-04-12**。

我试了下 2026 的版本，可以用，但一些工具对其支持性不太好，可能会出现找不到库等情况。

所以还是安装 2022 的版本稳妥一些，可以先安装后续在 `vs_BuildTools` 中修改。

---

某些环境下可能需要先修改其安装目录的权限。

找到打算安装 `Kits` 的目录：

**属性 -> 安全 -> SYSTEM**

检查 `SYSTEM` 的权限，直接勾上 `完全控制`。

如果没有 `SYSTEM` 项，那么：

**添加 -> 输入 SYSTEM -> 检查名称**

然后再运行 `winsdksetup.exe` 即可。

# 5 MSVC

因为中文的一些条目看起来云里雾里，不是很友好，所以强制用英文运行。

打开 `vs_BuildTools.exe` 所在的终端，使用如下命令启动。

```shell
vs_BuildTools.exe --locale en-US
```

这里可以选择 `X86_64 MSVC`, `Address Sanitizer`, `SDK`，其余套件自行选择。

其它比如 CMake，LLVM 这些个人感觉还是额外安装，不和 VS 捆在一起好一些。

# 6 Environment

添加上述所有安装的内容到环境变量，`INCLUDE`, `LIB`, `PATH`。如：

```shell
# --- MSVC ---
# INCLUDE
D:\070_Code\120_Microsoft\100_VisualStudio\BuildTools\VC\Tools\MSVC\14.50.35717\include

# LIB
D:\070_Code\120_Microsoft\100_VisualStudio\BuildTools\VC\Tools\MSVC\14.50.35717\lib\x64

# PATH
D:\070_Code\120_Microsoft\100_VisualStudio\BuildTools\VC\Tools\MSVC\14.50.35717\bin\Hostx64\x64

# --- Windows Kits ---
# INCLUDE
D:\070_Code\120_Microsoft\110_WindowsKits\Include\10.0.28000.0\cppwinrt
D:\070_Code\120_Microsoft\110_WindowsKits\Include\10.0.28000.0\shared
D:\070_Code\120_Microsoft\110_WindowsKits\Include\10.0.28000.0\ucrt
D:\070_Code\120_Microsoft\110_WindowsKits\Include\10.0.28000.0\um
D:\070_Code\120_Microsoft\110_WindowsKits\Include\10.0.28000.0\winrt

# LIB (The `ucrt_enclave` has removed a large number of standard functions.)
D:\070_Code\120_Microsoft\110_WindowsKits\Lib\10.0.28000.0\ucrt\x64
# D:\070_Code\120_Microsoft\110_WindowsKits\Lib\10.0.28000.0\ucrt_enclave\x64
D:\070_Code\120_Microsoft\110_WindowsKits\Lib\10.0.28000.0\um\x64

# PATH
D:\070_Code\120_Microsoft\110_WindowsKits\bin\10.0.28000.0\x64
D:\070_Code\120_Microsoft\110_WindowsKits\Debuggers\x64
D:\070_Code\120_Microsoft\110_WindowsKits\Windows Performance Toolkit
```
