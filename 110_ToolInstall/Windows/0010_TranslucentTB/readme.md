# TranslucentTB

# 1 环境

## 1.1 Windows 11

# 2 引言

如果希望将 Windows 底部的任务栏设置为透明，Windows10 可以通过修改注册表选项实现，但 Windows11 似乎不行。

不过 TranslucentTB 这款软件实现了相同的功能。

# 3 官方地址

浏览器上其实可以直接通过 Windows 的商店下载，考虑到网络问题，尤其是某些公司中，这里下载 portable 版本。

源码地址：

```
https://github.com/TranslucentTB/TranslucentTB
```

Release 地址：

```
https://github.com/TranslucentTB/TranslucentTB/releases
```

这里下载 `portable-x64` 的压缩包与 `winui-x64.appx`，后者是前者的依赖，否则运行程序时会报错。

# 4 安装

双击 `winui-x64.appx` 即可安装，然后再解压 `portable-x64` 的压缩包，运行里面的 `exe` 文件即可。

# 5 开机自启动

如果软件默认不是开机自启动的，则可以按照如下步骤配置：

(1) win + r，输入：

```powershell
shell:startup
```

(2) 此时打开了一个文件夹，将需要自启动的程序添加进去即可。注意，这里必须使用快捷方式，懂得自然懂。
