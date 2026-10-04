# Paperclip

# 1 环境

## 1.1 Windows 11

# 2 官方地址

```
https://github.com/paperclipai/paperclip/releases
```

# 3 安装

## 3.1 安装依赖

* 需要 javascript 环境。

* 需要 cargo，网站如下：

  ```
  https://rustup.rs/
  ```

* 可以选择安装 gemini 等：

  ```
  npm install -g gemini
  ```

## 3.2 环境配置与使用

### 3.2.1 配置文件

在项目根目录创建 `.env` 文件，并将密钥写入，如：

```
GEMINI_API_KEY=AQ.xxxxxxxxxxxxx
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
```

终端使用 Mingw64，所以打开根目录下的 `.npmrc` 文件，添加如下内容：

```
script-shell=D:\msys2\usr\bin\bash.exe
```

### 3.2.2 Modules

Windows 环境下，最好不要直接解压，因为可能在解压后创建一些链接文件，虽然大概率用不到。

以 Mingw64 环境为例。要创建链接，那么需要以管理员身份运行终端，然后解压：

```shell
unzip paperclip-2026.1012.0.zip
```

`npm` 安装 modules 时，也可能创建一些链接，所以同样以管理员身份运行终端：

```shell
cd paperclip-2026.1012.0

npm install

pnpm install
```

### 3.2.3 启动

```shell
pnpm dev

# 等待终端打印，如：127.0.0.1:3100。然后用浏览器访问
```

## 3.3 报错

### 3.3.1 旧的进程没退出

报错：

```
FATAL: pre-existing shared memory block is still in use
HINT: Check if there are any old server processes still running, and terminate them.
```

解决方法：

```shell
# 在 Mingw64 中运行此命令，杀掉残留进程
taskkill //F //IM postgres.exe

# 检查是否有任何进程仍在占用 54329 或 54330 端口
netstat -ano | grep -E "54329|54330"

# 如果仍有 PID 残留，用此命令杀掉进程
taskkill //F //PID <pid>
```

### 3.3.2 tsx 不存在

这种一般都是其他问题导致的报错。

用以下方法检查，是否为 tsx 的问题：

```shell
# 重新安装依赖，确保 tsx 存在
pnpm install

# 验证 tsx 是否能被找到，如果版本打印正确，那么证明 tsx 没问题
pnpm --filter @paperclipai/server exec tsx --version
```

