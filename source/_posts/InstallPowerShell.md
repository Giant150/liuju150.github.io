---
layout: post
title: 'Ubuntu20.4安装PowerShell'
subtitle: ''
tags:
  - 随笔
  - Ubuntu
  - PowerShell
date: 2020-08-19 17:10:20
---

## 安装命令

``` sh
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
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
