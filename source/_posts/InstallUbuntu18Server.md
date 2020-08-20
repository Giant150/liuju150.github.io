---
layout: post
title: '在Hyper-V中安装Ubuntu Server 18.04'
subtitle: ''
tags:
  - 随笔
  - Hyper-V
  - Ubuntu
date: 2020-08-20 08:40:32
---

## 新建虚拟机

设置虚拟机名称和安装位置
![虚拟机配置](1.png)
设置虚机的代数/我的机器只支持第一代，如果机器可以，最好设置为第二代
![虚拟机配置](2.png)
分配内存，这里设置4GB内存
![虚拟机配置](3.png)
选择网络
![虚拟机配置](4.png)
配置虚拟硬盘大小与位置
![虚拟机配置](5.png)
选择Ubuntu安装包ISO
![虚拟机配置](6.png)
虚拟机配置汇总
![虚拟机配置](7.png)
修改CPU处理核心数量
![虚拟机配置](8.png)

## 安装Ubuntu

选择语言，这里选择中文
![安装Ubuntu](9.png)
选择安装Ubuntu服务器版
![安装Ubuntu](10.png)
选择系统默认语言，默认为English
![安装Ubuntu](11.png)
因为我这个安装包不是最新的，所以有升级，这里选择默认配置
![安装Ubuntu](12.png)
键盘配置
![安装Ubuntu](13.png)
网络配置，这里用的DHCP自动分配IP地址，也可以配置固定IP地址
![安装Ubuntu](14.png)
设置代理服务器地址，没有默认为空
![安装Ubuntu](15.png)
这里设置镜像服务器位置，本机修改为华为云的镜像站
[https://repo.huaweicloud.com/ubuntu/](https://mirrors.huaweicloud.com/)
![安装Ubuntu](16.png)
文件系统配置，都选择默认
![安装Ubuntu](17.png)
选择硬盘
![安装Ubuntu](18.png)
硬盘信息汇总
![安装Ubuntu](19.png)
确认格式化硬盘
![安装Ubuntu](20.png)
配置用户名/密码
![安装Ubuntu](21.png)
SSH配置，是否安装SSH Server
![安装Ubuntu](22.png)
选配安装组件
![安装Ubuntu](23.png)
等待安装
![安装Ubuntu](24.png)
安装完成
![安装Ubuntu](25.png)
