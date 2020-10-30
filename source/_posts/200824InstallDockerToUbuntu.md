---
layout: post
title: 'Ubuntu安装Docker'
subtitle: ''
header-img: "img/docker.png"
tags:
  - 随笔
  - Docker
  - Ubuntu
date: 2020-08-24 10:11:23
---

## 安装代码

```sh
#安装依赖:
sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common

#信任Docker的GPG公钥:
curl -fsSL https://repo.huaweicloud.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

#对于amd64架构的计算机，添加软件仓库:
sudo add-apt-repository "deb [arch=amd64] https://repo.huaweicloud.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

#更新索引文件并安装
sudo apt-get update
sudo apt-get install docker-ce

#测试是否安装成功
sudo docker run hello-world
```

### 安装依赖

![安装依赖](1.png)

### 信任Docker的GPG公钥/添加软件仓库

![信任Docker的GPG公钥](2.png)

### 更新索引文件并安装

![信任Docker的GPG公钥](3.png)
![信任Docker的GPG公钥](4.png)

### 测试是否安装成功

![信任Docker的GPG公钥](5.png)

## 方式二

脚本安装是最推荐的方式，只需要输入下面的命令，等待自动安装好即可。
sudo curl -fsSL https://get.docker.com | sh

## Docker镜像加速

创建或修改 /etc/docker/daemon.json

```bash
{
    "registry-mirrors": [
        "https://hub-mirror.c.163.com",
        "https://1nj0zren.mirror.aliyuncs.com",
        "http://f1361db2.m.daocloud.io",
        "https://registry.docker-cn.com"
    ]
}
```

```bash
#重启Docker
service docker restart
#检查加速器是否生效
docker info
```

## 卸载Docker

```bash
#查看 Docker 的磁盘使用情况（类似于 Linux 上的 df 命令）：
docker system df
#清理磁盘，删除关闭的容器、无用的数据卷和网络，以及 dangling 镜像（即无 tag 的镜像）
docker system prune

#批量删除所有的孤儿 volume（即没有任何容器用到的 volume）
docker volume rm $(docker volume ls -q)

#清理后可以查看下目前使用的所有 volume：
docker volume ls

#使用 docker inspect 命令可以查看某个 volume 的具体信息，比如挂载在本机的那个目录路径下：
docker inspect edgex_log-data

# 卸载
sudo apt-get purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```
