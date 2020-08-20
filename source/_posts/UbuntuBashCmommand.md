---
layout: post
title: 'Ubuntu命令'
subtitle: ''
tags:
  - 随笔
  - Ubuntu
date: 2020-08-20 10:02:57
---

## 开关机命令

### 重启命令

1、reboot
2、shutdown -r now 立刻重启
3、shutdown -r 10 过10分钟自动重启
4、shutdown -r 20:35 在时间为20:35时候重启

如果是通过shutdown命令设置重启的话，可以用shutdown -c命令取消重启

### 关机命令

1、halt   立刻关机（一般加-p 关闭电源）
2、poweroff 立刻关机
3、shutdown -h now 立刻关机
4、shutdown -h 10 10分钟后自动关机

### 查看IP

``` bash
ip addr
```

## SSH

sudo service ssh status 查看服务状态
sudo service ssh stop  关闭服务
sudo service ssh restart  重启服务
