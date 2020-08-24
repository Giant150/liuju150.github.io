---
layout: post
title: '使用PowerShell自动部署ASP.Net Core到Ubuntu'
subtitle: ''
tags:
  - 随笔
  - NetCore
  - Ubuntu
  - PowerShell
date: 2020-08-21 15:03:04
---

```powershell
Write-Host 'Build Starting' -ForegroundColor Yellow
# 发布程序到指定目录
$CurPath=(Resolve-Path .).Path
$OutputPath=$CurPath+"\bin\publish\"
Remove-Item -Path $OutputPath -Force -Recurse
Invoke-Command -ScriptBlock {param($o) dotnet publish -o $o -c "Release" --no-self-contained -r linux-arm64 -v m --nologo "05.Coldairarrow.Api.csproj"} -ArgumentList $OutputPath
Write-Host 'Build Completed' -ForegroundColor Green

# 把发布后的程序打包压缩
Write-Host 'Compress Starting' -ForegroundColor Yellow
$CurDateString=Get-Date -Format "yyyyMMddHHmmss"
$ZIPFileName="WMSAPI"+$CurDateString+".zip"
$ZIPFilePath=$CurPath+"\"+$ZIPFileName
$CompressPath=$OutputPath+"*"
Compress-Archive -Path $CompressPath -DestinationPath $ZIPFilePath
Write-Host 'Compress Completed' -ForegroundColor Green

# 使用PowerShell连接到Ubuntu的SSH服务
Write-Host 'Deploy Starting' -ForegroundColor Yellow
$Session = New-PSSession -HostName 10.76.20.51 -UserName giant -KeyFilePath "C:\Users\Administrator\id_rsa"
$Session
Write-Host 'Successfully connected to the server' -ForegroundColor Green
Write-Host 'Start copying files to the server' -ForegroundColor Yellow
# 把程序压缩包复制到Ubuntu服务器
$RemotePath="/home/giant/ZEQPWMS/"
Copy-Item $ZIPFilePath -Destination $RemotePath -ToSession $Session
Write-Host 'Copy files completed' -ForegroundColor Green
Write-Host 'Start Expand files on the server' -ForegroundColor Yellow
$RemoteDestinationPath=$RemotePath+"WMSAPI/"
$RemoteZipPath=$RemotePath+$ZIPFileName
Invoke-Command -Session $Session -ScriptBlock {param($p) chmod 777 $p -R} -ArgumentList $RemotePath

# 解压程序包到指定目录
Invoke-Command -Session $Session -ScriptBlock {param($p) Remove-Item -Path $p -Recurse -Force} -ArgumentList $RemoteDestinationPath
Invoke-Command -Session $Session -ScriptBlock {param($p,$dp) Expand-Archive -Path $p -DestinationPath $dp} -ArgumentList $RemoteZipPath,$RemoteDestinationPath

Invoke-Command -Session $Session -ScriptBlock {param($p) chmod 777 $p -R} -ArgumentList $RemotePath
# 这里因为我是测试环境，所以把生成环境的配置文件删除
$ConfigProductionFile=$RemoteDestinationPath+"appsettings.Production.json"
Invoke-Command -Session $Session -ScriptBlock {param($p) Remove-Item -Path $p -Force} -ArgumentList $ConfigProductionFile
Write-Host 'Expand Completed' -ForegroundColor Green
# 删除本的压缩包
Remove-Item -Path $ZIPFilePath
Write-Host 'Disconnected from server' -ForegroundColor Yellow
Write-Host 'Deploy Completed' -ForegroundColor Green
```

![自动部署ASP.Net Core到Ubuntu](1.png)
