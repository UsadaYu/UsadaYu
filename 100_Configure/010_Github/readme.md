# Github Config

以仓库管理员的身份配置 github 环境。



# 1 ssh clone

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
```

打开 github，按如下顺序，将密钥复制进去即可。

* Settings
* SSH and GPG keys
* New SSH key



# 2 ssh key confirm

如何确认 ssh 的密钥确实已添加到 github 了呢？

可以通过以下方式确认：

```shell
ssh -T git@github.com

# 打印类似如下信息则表示成功
Hi UsadaYu! You've successfully authenticated...
```



# 3 port config

在中国大陆的网络环境下，github 的22端口经常被干扰或被直接封禁。

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

# 添加内容
Host github.com
  Hostname ssh.github.com
  Port 443
  User git
```

接着用 ssh clone 一般就没问题了。
