---
layout: post
title: '部署Asp.Net Core到Docker'
subtitle: ''
tags:
  - NetCore
  - WMS
  - Docker
date: 2020-08-24 10:50:21
---

## Dockerfile

```ini
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
WORKDIR /app
COPY . .
EXPOSE 5000
ENTRYPOINT ["dotnet","Coldairarrow.Api.dll"]
```

## 拉取Asp.net Core的镜像

```bash
sudo docker pull mcr.microsoft.com/dotnet/core/aspnet:3.1
```

![拉取Asp.net Core的镜像](1.png)

## 构建镜像

```bash
sudo docker build -t wmsapi .
```

![构建镜像](2.png)

## 运行镜像

```bash
##在当前进程下运行
sudo docker run -it --rm -p 5000:5000 --name api wmsapi

##以守护进程方式运行
sudo docker run -d -p 5000:5000 --name api wmsapi
```

![运行镜像](3.png)

## 查看WMS接口运行状态

在浏览器输入：http://10.76.20.162:5000/swagger/
打开API界面，表示运行成功

![运行镜像](4.png)

## 参考文档

[ASP.NET Core 的 Docker 映像](https://docs.microsoft.com/zh-cn/aspnet/core/host-and-deploy/docker/building-net-docker-images?view=aspnetcore-3.1)
[Ubuntu Install Docker](https://docs.docker.com/engine/install/ubuntu/)
[ASP.NET Core Docker部署](https://www.cnblogs.com/savorboard/p/dotnetcore-docker.html)