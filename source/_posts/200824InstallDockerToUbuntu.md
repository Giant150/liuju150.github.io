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
