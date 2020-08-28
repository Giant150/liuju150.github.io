---
layout: post
title: '在Docker中安装MySql'
subtitle: ''
header-img: "img/docker.png"
tags:
  - 随笔
  - Docker
  - MySql
date: 2020-08-28 09:15:51
---

## 安装代码

```bash
#拉取MySql镜像
docker pull mysql
#运行MySql容器
#MYSQL_ROOT_PASSWORD：root用户密码
#p：端口映射 本地端口:容器端口
#d:守护方式运行
#character：字符集UTF-8
docker run --name wmsmysql -e MYSQL_ROOT_PASSWORD=ABCabc123 -p 33060:3306 -d mysql --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

## 网上资源

```bash
# docker 中下载 mysql
docker pull mysql

#启动
docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=Lzslov123! -d mysql

#进入容器
docker exec -it mysql bash

#登录mysql
mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Lzslov123!';

#添加远程登录用户
CREATE USER 'liaozesong'@'%' IDENTIFIED WITH mysql_native_password BY 'Lzslov123!';
GRANT ALL PRIVILEGES ON *.* TO 'liaozesong'@'%';
```

## 参考文档

[Docker MySql WMS](https://hub.docker.com/_/mysql)
{% post_link 200824InstallDockerToUbuntu %}
