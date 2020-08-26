---
layout: post
title: 'Ubuntu设置固定IP地址'
subtitle: ''
header-img: "img/ubuntu.jpg"
tags:
  - 随笔
  - Ubuntu
date: 2020-08-26 08:52:03
---

## Ubuntu基本信息

* 版本：18.04

![Ubuntu基本信息](1.png)

## 默认网络配置信息

* 配置文件：/etc/netplan/50-cloud-init.yaml

* 默认配置：DHCP 自动获取IP

```yaml
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        eth0:
            dhcp4: true
    version: 2
```

![Ubuntu默认网络配置信息](2.png)

## 设置为固定IP

* 修改后的配置文件：/etc/netplan/50-cloud-init.yaml

```yaml
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        eth0:
            dhcp4: false
            addresses: [10.76.20.162/24]
            gateway4: 10.76.20.1
            nameservers:
                addresses: [114.114.114.114,8.8.8.8]
    version: 2
```

![Ubuntu固定IP配置信息](3.png)

## 应用新的配置

```bash
#应用新的配置
netplan apply
```

```bash
#查看IP信息
ip addr
```

![Ubuntu IP信息](4.png)
