---
layout: post
title: '使用IIS部署WebDAV'
subtitle: '使用WebDAV可以把服务器目录映射为本地虚拟硬盘'
tags:
  - 随笔
date: 2021-08-17 16:18:43
---

## 服务器开启WebDAV

在服务器安装IIS的同时
要启用Windows身份验证与WebDAV发布
![WebDAV](1.png)

如果不是服务器版本,参照下图
![WebDAV](2.png)

## 在IIS中新建WebDAV网站

配置好本地目录与端口
![WebDAV](3.png)

## 启用Windows身份验证

![WebDAV](4.png)
![WebDAV](5.png)

## 配置WebDAV

1.添加创作规则
2.启用WebDAV

![WebDAV](6.png)
![WebDAV](7.png)
![WebDAV](8.png)

## 开放防火墙端口

因为我们才配置的网站端口为8000
所以我们把防火墙的入站规则允许8000端口通过
![WebDAV](9.png)

到这里,服务器的配置就已经全部完成

## 客户机器配置映射

1.打开文件资源管理器,选择"此电脑"
2.打开"计算机"菜单,选择"映射网络驱动器"
3.在打开的界面输入服务器IIS的地址,如:http://10.76.99.13:8000
4.勾选“使用其它凭据连接”
5.点完成后，会要求输入服务器Windows的用户名密码，并勾选“记住我的凭据”

![WebDAV](10.png)
![WebDAV](11.png)

## 最终效果

最后我们就成功的把服务器的目录映射成为本的一个虚拟盘了
![WebDAV](12.png)

## 扩展使用

如果要把服务器的其它目录也添加到映射。
不用再重新创建IIS站点
只用在这个站点下面“添加虚拟目录”就可以了
![WebDAV](13.png)
