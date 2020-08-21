---
layout: post
title: '使用PowerShell操作Ubuntu'
subtitle: ''
tags:
  - 随笔
  - Ubuntu
  - PowerShell
date: 2020-08-19 17:10:20
---

## 安装PowerShell

[安装PowerShell帮助文档](https://docs.microsoft.com/zh-cn/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7)

``` sh
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt-get update

# Enable the "universe" repositories
sudo add-apt-repository universe

# Install PowerShell
sudo apt-get install -y powershell

# Start PowerShell
pwsh
```

## 通过 SSH 进行 PowerShell 远程处理

[通过 SSH 进行 PowerShell 远程处理](https://docs.microsoft.com/zh-cn/powershell/scripting/learn/remoting/ssh-remoting-in-powershell-core?view=powershell-7)

``` sh
# 安装SSH
sudo apt install openssh-client
sudo apt install openssh-server

# 编辑 /etc/ssh 位置中的 sshd_config 文件。
# 确保已启用密码身份验证：
PasswordAuthentication yes
# 添加 PowerShell 子系统条目：
Subsystem powershell /usr/bin/pwsh -sshs -NoLogo -NoProfile

# 启用密钥身份验证（可选）
PubkeyAuthentication yes
```

## 重启 sshd 服务

``` sh
sudo service sshd restart
```

## 通过PowerShell 连接 Ubuntu

[通过PowerShell 连接 Ubuntu](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-pssession?view=powershell-7#example-12--create-a-session-using-ssh)

``` sh
New-PSSession -HostName UserA@LinuxServer01
```

![PowerShell连接Ubuntu](1.png)


## PowerShell使用密钥文件连接Ubuntu

1.先在Windows打开PowerShell输入ssh-keygen.exe生成公/私密钥
![PowerShell使用密钥文件连接Ubuntu](2.png)

2.把公钥复制到Ubuntu
![PowerShell把公钥复制到Ubuntu](3.png)

3.修改Ubuntu SSH配置
#打开RSA认证
RSAAuthentication yes
#公钥认证
pubkeyAuthentication yes
#Root权限登录
permitROOTlogin yes
#添加公钥文件
AuthorizedKeysFile .ssh/hncsie-liuju.pub

![Ubuntu SSH配置](5.png)

4.重启sshd服务sudo service sshd restart

![PowerShell连接Ubuntu](4.png)



## 参考文档

sshd.exe，它是远程所管理的系统上必须运行的 SSH 服务器组件
ssh.exe，它是在用户的本地系统上运行的 SSH 客户端组件
ssh-keygen.exe，为 SSH 生成、管理和转换身份验证密钥
ssh-agent.exe，存储用于公钥身份验证的私钥
ssh-add.exe，将私钥添加到服务器允许的列表中
ssh-keyscan.exe，帮助从许多主机收集公用 SSH 主机密钥
sftp.exe，这是提供安全文件传输协议的服务，通过 SSH 运行
scp.exe 是在 SSH 上运行的文件复制实用工具