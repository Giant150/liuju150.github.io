---
layout: post
title: 'MySql数据库主从同步/双向同步'
subtitle: '主从同步,主主同步,双向同步,双机热备'
header-img: "img/bg1.jpg"
tags:
  - 随笔
date: 2021-06-24 13:12:16
---

## 前言

最近做个项目,买了两台服务器做双机热备
服务器1IP(Master):192.168.21.245
服务器2IP(Slave) : 192.168.21.244

## 配置Master

### 修改配置文件my.ini

1.找到MySql的配置文件my.ini,加入/修改为以下配置

```ini
server-id=1
log-bin=mysql-bin
binlog-ignore-db=mysql,information_schema
sync_binlog=1
binlog_checksum=none
binlog_format=mixed
auto-increment-increment=2
auto-increment-offset=1
slave-skip-errors=all
```

2.然后重启MySql服务
我们用root帐号来做主从同步(一般情况下最好新建一个帐号来做)
打开MySql命令行给帐号授主从同步权限

```shell
#授权
grant replication slave,replication client on *.* to root@'%' identified by "root password";
#刷新权限
flush privileges;
#锁定表,只能读取
FLUSH TABLES WITH READ LOCK;
#查看主数据库日志记录状态
show master status;
```

![MySql主从同步](1.png)

3.把主数据库备份,然后在从数据库还原.以达到两边数据一至

## 配置Slave数据库

1.找到MySql的配置文件my.ini,加入/修改为以下配置

```ini
server-id=2
log-bin=mysql-bin
binlog-ignore-db=mysql,information_schema
sync_binlog=1
binlog_checksum=none
binlog_format=mixed
auto-increment-increment=2
auto-increment-offset=2
slave-skip-errors=all
```

2.然后重启MySql服务
我们用root帐号来做主从同步(一般情况下最好新建一个帐号来做)
打开MySql命令行给帐号授主从同步权限

```shell
#授权
grant replication slave,replication client on *.* to root@'%' identified by "root password";
#刷新权限
flush privileges;
#查看主数据库日志记录状态
show master status;
#重置Slave同步状态 如果以前配置了同步的话
reset slave;
#停止同步
stop slave;
#配置从主服务器数据库同步master_log_file和master_log_pos参数是在主数据库中show master status查找出来
change master to master_host='192.168.21.245',master_user='root',master_password='root password',master_log_file='mysql-bin.000023',master_log_pos=440286;
#启用同步
start slave;
#查询同步状态
show slave status;
```

![MySql主从同步](2.png)

到这里的话,从数据库Slaver的数据会与主数据库Master同步已经成功了
如果用show slave statu显示如下状态,表示成功

```code
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.21.245
                  Master_User: root
                  Master_Port: 3306
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
```

## 主数据Master同步从数据库Slave的数据

同样在主数据库中运行以下命令

```shell
#解锁主数据库表
unlock tables;
#重置Slave同步状态 如果以前配置了同步的话
reset slave;
#停止同步
stop slave;
#配置从Slave服务器数据库同步 master_log_file和master_log_pos参数是在Slave数据库中show master status查找出来
change master to master_host='192.168.21.244',master_user='root',master_password='root password',master_log_file='mysql-bin.000024',master_log_pos=150;
#启用同步
start slave;
#查询同步状态
show slave status;
```

如果用show slave statu显示如下状态,表示成功

```code
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.21.244
                  Master_User: root
                  Master_Port: 3306
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
```

## 注意事项

今天配置同步的时候,用show slave status看到如下错误
The slave I/O thread stops because master and slave have equal MySQL server UUIDs; these UUIDs must be different for replication to work...
主要是我的data目录是复制过去的.所以在data目录下面auto.cnf里的server-uuid这个配置是一样的
所以我们要把两台服务器的auto.cnf里面的server-uuid值修改为不一样就可以了.
这个同my.ini里配置的server-id一样.不能重复.不然同步数据会报错
