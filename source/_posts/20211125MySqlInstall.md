---
layout: post
title: 'MySql数据库安装'
subtitle: '在Windows下以命令行方式安装'
tags:
  - 随笔
  - MySql
date: 2021-11-25 17:10:38
---

## 目录

1. 下载MySql
2. 配置文件
3. 安装MySql

## 下载MySql

[MySql下载地址](https://dev.mysql.com/downloads/mysql/)
下载哪下图所示的文件
![MySql](1.png)

下载后,我们把文件解压到D:/mysql下面,如下图所示
![MySql](2.png)

## 配置MySql

我们在D:/mysql文件夹下新建my.ini
内容如下

```ini
[mysql]
default-character-set=utf8mb4
[mysqld]
port=3306
basedir="D:/mysql/"
datadir="D:/Database/"
character-set-server=utf8mb4
default-storage-engine=INNODB
lower_case_table_names=2
```

>注意:my.ini的文件编码最好用ANSI
>注意:我们是把数据文件存放在D:/Database/目录,所以要在D:/盘下面新建Database目录

我们把D:/mysql/bin目录添加进环境变量
如下图
![MySql](3.png)
![MySql](4.png)

## 安装MySql

以管理员方式运行cmd

```cmd
#进入D:/mysql目录
D:
cd mysql
#初始化mysql
mysqld --initialize --console
#把mysql安装成功windows服务
mysqld --install
#启动MySql服务
net start MySql
#用命令行登录MySql,密码输入初始化显示的密码
mysql -u root -p
#修改初始root密码
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '新密码';
#切换到mysql数据库
use mysql;
#修改root帐号可以外网访问
update user set host='%' where user='root';
#刷新权限
flush privileges;
```

第一次安装的时候,可能会出现很多
由于找不到 MSVCP140.dll，无法继续执行代码。重新安装程序可能会解决此问题
这是因为系统没有安装C++运行时环境,我们可以搜索"c++ redistributable"关键字,下载微软运行时
[下载Visual C++ Redistributable Latest](https://aka.ms/vs/17/release/vc_redist.x64.exe)
![MySql](5.png)
![MySql](6.png)

在运行mysqld --initialize --console的时候,在输出的地方会显示root的初始密码
如下图,最后那个0zy1w:PBcK((就是root的初始密码
![MySql](7.png)

完整初始化命令显示如下图
![MySql](8.png)

到此,我们MySql就已经安装好了.
如果是在云服务器,要通过外网访问
那就要把服务器和云的网络都把3306端口打开.（不建议这样做，有安全风险）
这样我们就可以在任意地方访问MySql服务了

![MySql](9.png)
