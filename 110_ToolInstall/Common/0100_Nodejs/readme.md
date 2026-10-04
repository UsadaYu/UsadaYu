# Nodejs

# 1 环境

## 1.1 Windows11

# 2 官方地址

```
https://nodejs.org/zh-cn/download
```

# 3 安装流程

Windows 平台下载 `msi` 文件后安装，让其默认添加 `PATH` 等环境变量。

打开 CMD，使用如下命令简单检查：

```shell
node -v
npm -v
```

## 3.1 环境变量

通过以下命令查看：

```shell
# 当前全局路径
npm config get prefix

# 当前缓存路径
npm config get cache
```

设置环境变量：

```shell
npm config set prefix "D:\070_Code\160_Nodejs\node_global"

npm config set cache "D:\070_Code\160_Nodejs\node_cache"
```

编辑 Windows 系统环境变量 `PATH`，变量值：

```
D:\070_Code\160_Nodejs\node_global
```

编辑 Windows 系统环境变量 `NODE_PATH`，变量值：

```
D:\070_Code\160_Nodejs\node_global\node_modules
```

## 3.2 测试

```shell
npm install -g express
npm install -g eslint
```

## 3.3 问题

### 3.3.1 环境变量指向错误

如果不甚乱操作，导致 `prefiX` 和 `cache`  指向 C 盘的 `AppData` 目录。

那么，尝试如下流程。

打开 `C:\Users\UsadaYu\` 目录（user 目录）下的 `.npmrc` 的文件，如果存在的话。

清空里面的内容，或添加/修改为：

```
prefix=D:\070_Code\160_Nodejs\node_global
cache=D:\070_Code\160_Nodejs\node_cache
```

### 3.3.2 多个可执行文件

如果执行了：

```shell
npm install -g npm
```

那么，`node_global` 目录下可能又会出现不同版本的可执行文件。

将 `npm`、`npm.cmd`、`npx`、`npx.cmd` 这几个文件全部删除即可。

# 4 pnpm

## 4.1 安装

`npm install -g pnpm` 安装后，可能会出现如下警告：

```
npm warn install-scripts pnpm@12.14.0 (preinstall: node install.js; postinstall: node install.js)
```

为了允许脚本全局安装，命令如下：

```shell
npm install -g --allow-scripts=pnpm pnpm

# 验证
pnpm --version
```

## 4.2 配置

同样为了防止 `pnpm` 将文件堆积到 C 盘，可以做如下配置：

```shell
# 设置全局包的安装位置（以后 pnpm install -g 就会去这里）
pnpm config set global-dir "D:\070_Code\160_Nodejs\pnpm_global"

# 设置全局缓存位置
pnpm config set cache-dir "D:\070_Code\160_Nodejs\pnpm_cache"

# 设置 pnpm 的硬链接核心仓库（Store）
# 这个 Store 必须和项目代码在同一个盘，这样才能发挥 pnpm 不占空间的秒级安装优势
pnpm config set store-dir "D:\070_Code\160_Nodejs\pnpm_store"
```

