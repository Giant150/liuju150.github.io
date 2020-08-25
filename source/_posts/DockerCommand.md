---
layout: post
title: 'Docker常用命令说明'
subtitle: ''
tags:
  - 随笔
  - Docker
date: 2020-08-24 12:34:38
---

## 查看当前已经安装的镜像

```bash
sudo docker images
```

## 查看当前已经生成的容器

```bash
sudo docker ps -a
```

![已经安装的镜像](info1.png)

## 拉取远程镜像

[dotnet core 镜像地址](https://hub.docker.com/_/microsoft-dotnet-core)

```bash
sudo docker pull mcr.microsoft.com/dotnet/core/aspnet:3.1
```

![拉取远程镜像](pull1.png)

## 移除所有的容器和镜像

```bash
docker kill $(docker ps -q) 
docker rm $(docker ps -a -q) 
docker rmi $(docker images -q -a)
```

## 删除所有的容器

```bash
docker kill $(docker ps -q)
docker rm $(docker ps -a -q)
```

## 清除单个容器

```bash
docker rm <container id>
```

## 清除单个镜像

```bash
docker rmi -f <image id>
```

## 构建镜像

```bash
#镜像名称：wmsapi
#路径：当前目录(.)
#Tag：latest
sudo docker build -t wmsapi .

#镜像名称：wmsapi
#路径：当前目录(.)
#Tag: 1.0
sudo docker build -t wmsapi:1.0 .
```

![构建镜像](build1.png)

## 运行构建的镜像

```bash
#容器名称：api
#镜像：wmsapi
#以守护进程运行：-d
#端口镜像:Docker内部端口:服务器端口 -p 5000:5000
#如果名称存在，就删除原来的：-rm
sudo docker run -rm -d -p 5000:5000 --name api wmsapi

#镜像版本：latest
sudo docker run -rm -d -p 5000:5000 --name api wmsapi:latest
```

## 查看容器

```bash
sudo docker ps -a
```

![查看容器](ps1.png)

## 启动容器

```bash
#启动容器
#api:容器名称
sudo docker start api

#停止容器
#api:容器名称
sudo docker stop api

#重启容器
#api:容器名称
sudo docker restart api
```

![启动容器](start1.png)

![停止容器](stop1.png)

![重启容器](restart1.png)
