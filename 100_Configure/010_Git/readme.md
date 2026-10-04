# 1 Github SSH

以仓库管理员的身份配置 github 环境。

## 1.1 配置身份

```shell
git config --global user.email "xxx@gmail.com"
git config --global user.name "UsadaYu"

# check
git config get user.email
git config get user.name
```

## 1.2 ssh clone

每次在 https clone 的本地仓 `git push` 时，那个 username 和 password 感觉格外 `薛定谔`。

所以我一般倾向于用 ssh clone。

想用 ssh clone 仓库，首先需要在本地生成一个 ssh 的密钥。

可以通过如下方式实现：

```shell
ssh-keygen -t ed25519 -C "xxx@gmail.com"
```

将生成的密钥复制：

```shell
cat $HOME/.ssh/id_ed25519.pub

# 私钥文件权限一般只有 Owner 所有，如果进行过其他错误的权限操作可以改回来
# 将私钥文件的权限收紧一些，以免后续报 `too open` 之类的错误
chmod 600 $HOME/.ssh/id_ed25519
chmod 700 $HOME/.ssh
```

打开 github，按如下顺序，将密钥复制进去即可。

* Settings
* SSH and GPG keys
* New SSH key

## 1.3 ssh key confirm

如何确认 ssh 的密钥确实已添加到 github 了呢？

可以通过以下方式确认：

```shell
ssh -T git@github.com

# 打印类似如下信息则表示成功
Hi UsadaYu! You've successfully authenticated...
```

## 1.4 port config

在中国大陆的网络环境下，github 的 22 端口经常被干扰或被直接封禁。

比如这个和密钥相关的 IP：`20.205.243.166`，它的 22 端口一般来说是无了。嗯，真是遥遥领先。

此时 `git clone` 很可能出现如下情况：

```shell
Connection closed by 20.205.243.166 port 22
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

通过下述两种方式可以解决上述问题。

* (1) 使用 https clone。
* (2) 继续使用 ssh clone，但换用 443 端口。

这里说明一下 `方法 (2)` 的配置流程。

编辑或新建文件 `~/.ssh/config`。

```shell
vi ~/.ssh/config
chmod 600 $HOME/.ssh/config

# 添加内容
Host github.com
  Hostname ssh.github.com
  Port 443
  User git
```

接着用 ssh clone 一般就没问题了。

# 2 Git Line-endings

Windows 平台换行符为 `\r\n`；Linux/Unix 平台换行符为 `\n`。

## 2.1 项目

对于项目，可以统一文本文件以 `\n` 结尾。在根目录下创建 `.gitattributes` 文件，内容如下：

```shell
* text=auto eol=lf

# Windows specific files should retain windows line-endings
*.bat text eol=crlf
*.ps1 text eol=crlf
*.sln text eol=crlf

# Unix/Linux specific files should use LF line-endings
*.sh text eol=lf
```

## 2.2 本地配置

### 2.2.1 Windows

提交时，换行转为 `LF (\n)`；检出时，换行转为 `CRLF (\r\n)`；

```shell
git config --global core.autocrlf true

# 若需要保持 LF，如 WSL 等环境，可将 `core.autocrlf` 设置为 `false`
```

### 2.2.2 Unix

提交时，换行转为 `LF (\n)`；检出时，换行保持 `LF (\n)`；

```shell
git config --global core.autocrlf input
```

## 2.3 对于现有项目

若项目本身文本文件的换行符比较凌乱，可以通过如下方式统一。

创建 `.gitattributes` 后，运行如下命令：

```shell
git rm --cached -r .
git add .
git commit -m "Uniform line-endings"
```

