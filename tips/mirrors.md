# 软件仓库镜像

一部分软件仓库镜像地址被墙，导致软件无法下载，可以通过修改软件源地址解决。
一般按 [校园网联合镜像站](https://help.mirrors.cernet.edu.cn/) 指南做配置替换。
但有些比如 Dockerfile 中硬编码的地址不好修改，就要借助一些魔法 🪄

建议提前对镜像站点测速，选择速度最快的镜像源。

- [chsrc](https://github.com/RubyMetric/chsrc) 集成自动测速和换源，非常推荐使用
- [docker-mirror-hammal](https://github.com/enihsyou/docker-mirror-hammal) 我开发的 Docker 镜像代理，验证拉取 blobs 的速度，填补 chsrc 缺失的 docker 镜像测速功能

## Visual Studio Code Dev Containers

修改 `.vscode/extensions/ms-vscode-remote.remote-containers-0.397.0/scripts/bootstrap.Dockerfile` (版本号可能不同)
添加一行修改软件源地址的命令。

```diff
RUN echo "@old https://dl-cdn.alpinelinux.org/alpine/v3.15/main" >> /etc/apk/repositories
+ # Explicitly set a mirror to avoid network issues behind the Firewall
+ RUN <<EOF
+ sed -i 's/dl-cdn.alpinelinux.org/mirrors.cernet.edu.cn/g' /etc/apk/repositories
+ echo "registry=https://registry.npmmirror.com" >> /etc/npmrc
+ EOF
```

> 完整路径格式来自[这里](https://github.com/microsoft/vscode/issues/3884)长这样，根据版本有不同。
> Windows: `%USERPROFILE%\.vscode[-variant]\extensions\`
> Linux, macOS: `$HOME/.vscode[-variant]/extensions/`

## Docker

我的设置可以参考 [`daemon.json`](../cli-app/docker/daemon.json) 文件，其他建议了解

- [南京大学开源镜像系列](https://doc.nju.edu.cn/books/e1654)，如 `ghcr.nju.edu.cn`
- [镜像加速服务状态监控](https://status.daocloud.io/status/docker) DaoCloud 大好人，在我这边连接速度最快

## Language

### fnm - Node

[NodeJS Release 软件仓库镜像使用帮助](https://help.mirrors.cernet.edu.cn/nodejs-release/)

```powershell
[Environment]::SetEnvironmentVariable("FNM_NODE_DIST_MIRROR", "https://mirrors.cernet.edu.cn/nodejs-release/", "User")
```

### npm - Node

```powershell
npm config set registry https://registry.npmmirror.com
```
