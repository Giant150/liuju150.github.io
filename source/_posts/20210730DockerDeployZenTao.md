---
layout: post
title: 'Docker部署禅道系统'
subtitle: '禅道是专业的研发项目管理软件'
tags:
  - 随笔
date: 2021-07-30 17:01:59
---

## Docker命令

```bash
#摘取禅道镜像
sudo docker pull easysoft/zentao

#在宿主机创建数据目录zentaopms,mysqldata
#设置目录的读写权限
sudo mkdir zentaopms
sudo chmod 777 ./zentaopms
sudo mkdir mysqldata
sudo chmod 777 ./mysqldata

#创建容器并运行
sudo docker run --name zentao -p 80:80 -v /home/giant/www/zentaopms:/www/zentaopms -v /home/giant/www/mysqldata:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 -d easysoft/zentao

#修改防火墙
sudo ufw allow 80
```

## 参考引用

[https://www.zentao.net/book/zentaopmshelp/405.html](https://www.zentao.net/book/zentaopmshelp/405.html)
