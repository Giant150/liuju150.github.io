---
layout: post
title: '桌面置顶显示服务器信息'
subtitle: '机器名,系统版本,登录用户,内存,CPU,磁盘,IP'
header-img: "img/win.jpg"
tags:
  - 随笔
date: 2021-01-29 11:10:34
---

## 前言

在手头上做的项目很多，管理的服务器也很多。
一个项目最少也得2+以上的服务器。
在各个项目部署的时候，要来回切换不同的服务器。
搞着搞着就不知道当前远程在哪台服务器了。
所以希望在电脑桌面上可以很快的知道当前远程连接到了哪台服务器

## 设置背景桌面

最开始的时候，我们在每台服务器的背景桌面图片。
在图片上把当前服务器信息都做到图片上，
然后把这个图片设置为服务器的背景图片。
这样一远程到服务器上，就可以知道当前是哪台服务器了

然而这种方式有很大的弊端。
就是当我把一些应用最大化之后，背景图片就已经完全看不到了。
而且只能显示一些静态信息。比如机器名,系统版本,IP
还有就是我们99%的时间是看不到背景图片的。
所以这种方式有用，但是也很鸡肋。

## 实现功能

所以在休息的时候，自己有些WinForm的知识。
打算开发一个应用，可以在电脑桌面的右下角
实时显示当前服务器的信息。
比如机器名,系统版本,登录用户,内存,CPU,磁盘,IP
当有应用最大化后，这些信息也在最顶层显示出来
效果图如下
![ShowServerInfoInTop](1.png)
![ShowServerInfoInTop](2.png)

## 关键代码

### 设置Form

```C#
this.BackColor = System.Drawing.Color.White;//设置背景
this.ClientSize = new System.Drawing.Size(1024, 768);//界面大小
this.ControlBox = false;//不显示标题栏
this.Controls.Add(this.panel1);
this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;//无边框
this.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
this.MaximizeBox = false;
this.MinimizeBox = false;
this.Name = "Form1";
this.ShowIcon = false;
this.ShowInTaskbar = false;//不显示在任务栏
this.TopMost = true;//置顶
this.TransparencyKey = System.Drawing.Color.White;//透明
this.WindowState = System.Windows.Forms.FormWindowState.Maximized;//最大化显示
```

### 获取服务器信息

```C#
string strQuery = "select Caption,CSName,TotalVisibleMemorySize from win32_OperatingSystem";
SelectQuery queryOS = new SelectQuery(strQuery);
string Caption = "";
string CSName = "";
ulong TotalVisibleMemorySize = 0;
using (ManagementObjectSearcher searcher = new ManagementObjectSearcher(queryOS))
{
    using (var queryResult = searcher.Get())
    {
        foreach (var os in queryResult)
        {
            Caption = (string)os["Caption"];
            CSName = (string)os["CSName"];
            TotalVisibleMemorySize = (ulong)os["TotalVisibleMemorySize"];
        }
    }
}
return new OSInfoModel() { Caption = Caption, CSName = CSName, TotalVisibleMemorySize = TotalVisibleMemorySize };
```

获取更多服务器信息，请参考
[https://docs.microsoft.com/en-us/previous-versions/aa394084(v=vs.85)](https://docs.microsoft.com/en-us/previous-versions/aa394084(v=vs.85))

### 获取IP

```C#
var listIP = new List<String>();
foreach (NetworkInterface ni in NetworkInterface.GetAllNetworkInterfaces())
{
    if (ni.NetworkInterfaceType == NetworkInterfaceType.Wireless80211 || ni.NetworkInterfaceType == NetworkInterfaceType.Ethernet)
    {
        foreach (UnicastIPAddressInformation ip in ni.GetIPProperties().UnicastAddresses)
        {
            if (ip.Address.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
            {
                var ipStr = ip.Address.ToString();
                if (!(ipStr.StartsWith("169") || ipStr.EndsWith(".1") || ipStr.EndsWith(".255")))
                    listIP.Add(ipStr);
            }
        }
    }
}
return String.Join(Environment.NewLine, listIP);
```

### 获取动态信息

```C#
//获取CPU使用率
this.CpuPC = new PerformanceCounter("Processor", "% Processor Time", "_Total");
this.CpuPC.NextValue()
//获取可用内存
this.RamPC = new PerformanceCounter("Memory", "Available KBytes");
this.RamPC.NextValue()
//获取磁盘性能
this.DiskPC = new PerformanceCounter("PhysicalDisk", "% Idle Time", "_Total");
this.DiskPC.NextValue()
```

关于获取更多服务器性能信息。可参考“性能监视器"
![ShowServerInfoInTop](3.png)

## 下载

[源代码](https://github.com/LiuJu150/Giant.Tools)
[程序下载](ServerInfo.rar)
