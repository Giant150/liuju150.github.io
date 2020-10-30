---
layout: post
title: '免费申请HTTPS证书'
subtitle: '免费申请Lets Encrypt支持所有子域名的通配符证书'
header-img: "img/win.jpg"
tags:
  - 随笔
date: 2020-10-30 13:48:01
---

## 前言

在阿里云买了一个域名giantliu.cn
部署了自己的博客系统 [https://www.giantliu.cn/](https://www.giantliu.cn/)
所有用https证书是Let's Encrypt免费申请的
因为申请的免费证书有效期是3个月，今天正好原来的过期了
这里要重新申请新的证书。所以在这里记录一下
![Free Let's Encrypt SSL](2.png)
![Free Let's Encrypt SSL](3.png)

## 目录

1.[安装Certbot](#安装Certbot)
2.[申请证书](#申请证书)
3.[转换证书格式](#转换证书格式)
4.[安装证书](#安装证书)

## 安装Certbot

Certbot是辅助申请Let's Encrypt证书的工作
打开Certbot官网 [官网地址](https://certbot.eff.org/)
第一步是选择申请证书的种类，这样Certbot可以根据选择的种类
来帮助你在不同的环境里申请证书

这里我选择None of the above On Windows
![Free Let's Encrypt SSL](6.png)

然后下面会提示我们申请证书的步骤

![Free Let's Encrypt SSL](7.png)
![Free Let's Encrypt SSL](8.png)
![Free Let's Encrypt SSL](9.png)
![Free Let's Encrypt SSL](10.png)

这里主要的步骤是在要在C盘创建一个目录C:\Certbot并且当前用户有权限操作
然后下载Certbot安装文件 [下载地址](https://dl.eff.org/certbot-beta-installer-win32.exe)
下载后安装
![Free Let's Encrypt SSL](11.png)
然后我们以管理员方式运行命令行

```cmd
certbot --help
```

如果出现以下信息，就表示Certbot安装成功了
![Free Let's Encrypt SSL](12.png)

## 申请证书

因为我们要申请的证书是通配符证书
这样我只要申请了giantliu.cn的通配符证书后
那以giantliu.cn的所有子域都可以用这一个证书

输入以下命令

```cmd
#以下命令表以以DNS的方式验证giantliu.cn的域名来申请通配符证书
#通配符证书的域名为*.giantliu.cn
certbot certonly -d *.giantliu.cn --manual --preferred-challenges dns
```

输入命令后，会出现几个要互交的地方
1.输入你的email地址:邮件地址
2.阅读服务说明书并同意:A
3.步是别人要用共享你的邮件地址，给你推送相关信息：Y
4.问你是不是有这个域名的所有权
因为它要你解析一个TXT记录到固定地址来验证你是有这个域名的所有权的：Y
然后最下面就是要你解释一个TXT记录到_acme-challenge.giantliu.cn
值为：amJUh7UHWPm-CXCTaKtYIinUR3dYpmPWmgxKsnryZLo

到了这一步后，不要急于按回车结束
因为你还没有解析记录，不然会申请不成功的

![Free Let's Encrypt SSL](13.png)

接下来，因为我的域名解析是在阿里云做的，
所以我跑到阿里云的域名解析那里添加了一条TXT记录

![Free Let's Encrypt SSL](14.png)

添加的记录并不一定马上解析成功，所以我们要验证这个TXT记录是不是已经生效
我们打开一个新的命令行，输入以下命令
查询看得到的值是不是正确，如果与结果一至
那么我们就可以在原来的申请证书的命令行按回车继续我们的申请

```cmd
nslookup -qt=TXT _acme-challenge.giantliu.cn
```

![Free Let's Encrypt SSL](15.png)

按下回车后，Certbot会去验证我们的DNS记录
然后如果验证成功，会把申请到的证书保存到我们的
C:\Certbot\live\giantliu.cn

![Free Let's Encrypt SSL](16.png)
![Free Let's Encrypt SSL](17.png)

## 转换证书格式

因为我的博客服务器是用的IIS
而IIS所使用的证书为pfx，所以我们要把申请的证书pem格式转换成pfx格式

我们输入以下openssl命令（要安装openssl工具）

```cmd
openssl pkcs12 -export -out giantliu.pfx -inkey privkey.pem -in fullchain.pem -certfile cert.pem
```

![Free Let's Encrypt SSL](18.png)
![Free Let's Encrypt SSL](19.png)

## 安装证书

然后我们把转换后的证书giantliu.pfx复制到服务器
点右键安装证书，一直下一步到密码
![Free Let's Encrypt SSL](20.png)

然后输入证书密码，输入刚刚用openssl转换时输入的密码
然后一直下一步，直到完成
![Free Let's Encrypt SSL](21.png)

这样证书就已经导入到服务器了
然后在IIS管理器里面就可以看到我才申请的证书
![Free Let's Encrypt SSL](22.png)
接下来就可以把原来的网站绑定的证书换成新的证书
然后再看来我的博客，
HTTPS又回来了
![Free Let's Encrypt SSL](23.png)
