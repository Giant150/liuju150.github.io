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


## 防火墙

sudo ufw status 查看状态
sudo ufw enable 启用防火墙
sudo ufw allow 80 打开端口
sudo ufw reload 重新加载配置

## 文件操作

mkdir命令（创建目录）
cp命令（拷贝文件或目录）
mv命令（移动、重命名文件或目录）
rm命令（删除文件或目录）

## 启用root帐号

```bash
#给root帐号设置密码
sudo passwd root
#切换root帐号登录
su root
```

![root](root1.png)
