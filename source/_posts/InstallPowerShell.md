---
layout: post
title: 'Ubuntu18.04安装PowerShell'
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
