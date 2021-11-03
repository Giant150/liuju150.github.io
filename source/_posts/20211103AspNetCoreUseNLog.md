---
layout: post
title: '在Asp.Net Core中使用NLog记录日志'
subtitle: '使用NLog把日志写入数据库并按天自动分表'
tags:
  - 随笔
date: 2021-11-03 15:46:27
---

## 前言

最近用Asp.net Core开发程序的时候
因为时间的关系，就没有过多的去关注日志方面的功能
都是直接用系统的ILogger先记录着，然后看日志的时候就先在命令行看日志
在开发阶段没有什么问题，但是到了系统上线后
总不能一直在命令行看日志。总要把日志输出到一个方便查看的地方

## 开始

直接引用NLog.Web.AspNetCore组件
然后编写nlog.config文件放到程序的根目录

```xml
<?xml version="1.0" encoding="utf-8" ?>
<nlog xmlns="http://www.nlog-project.org/schemas/NLog.xsd"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      autoReload="true"
      internalLogLevel="Info"
      internalLogFile="${basedir}\..\Log\${date:format=yyyyMM}\WMSAPI-internal.txt">
  <extensions>
    <add assembly="NLog.Web.AspNetCore"/>
  </extensions>
  <!-- 定义变量当前应用程序名称 -->
  <variable name="AppName" value="WMSAPI" />
  <!-- 日志输出目标 -->
  <targets>
    <!-- 把日志记录到文件(通用) -->
    <target xsi:type="File" name="allfile" fileName="${basedir}\..\Log\${date:format=yyyyMM}\${var:AppName}-all-${shortdate}.txt" encoding="UTF-8"
            archiveFileName="${basedir}\..\Log\${date:format=yyyyMM}\${var:AppName}-all-${shortdate}.{#}.txt" archiveAboveSize="10485760"
            layout="${longdate}|${event-properties:item=EventId_Id:whenEmpty=0}|${uppercase:${level}}|${logger}|${message} ${exception:format=tostring}" />

    <!-- 把日志输出到文件 (Asp.Net Core) -->
    <target xsi:type="File" name="ownFile-web" fileName="${basedir}\..\Log\${date:format=yyyyMM}\${var:AppName}-own-${shortdate}.txt" encoding="UTF-8"
            archiveFileName="${basedir}\..\Log\${date:format=yyyyMM}\${var:AppName}-own-${shortdate}.{#}.txt" archiveAboveSize="10485760"
            layout="${longdate}|${event-properties:item=EventId_Id:whenEmpty=0}|${uppercase:${level}}|${logger}|${message} ${exception:format=tostring}|url: ${aspnet-request-url}|action: ${aspnet-mvc-action}|${callsite}| body: ${aspnet-request-posted-body}" />

    <!--把日志输出到控制台 -->
    <target xsi:type="Console" name="lifetimeConsole" layout="${level:truncate=4:tolower=true}: ${logger}[0]${newline}      ${message}${exception:format=tostring}" />

    <!--把日志输出到数据库 -->
    <target xsi:type="Database" name="database" dbProvider="MySqlConnector.MySqlConnection, MySqlConnector">
      <connectionString>${configsetting:item=ConnectionStrings.GDbContext}</connectionString>
      <install-command ignoreFailures="true">
        <text>
          <!-- NOTE: call LogManager.Configuration.Install(new InstallationContext()); to execute this query. -->
          CREATE TABLE IF NOT EXISTS `Sys_Log${date:format=yyyyMMdd}`  (
          `Id` bigint NOT NULL AUTO_INCREMENT,
          `CreateTime` datetime NOT NULL,
          `AppName` varchar(50) NOT NULL,
          `Level` varchar(50) NOT NULL,
          `Logger` varchar(1024) NULL DEFAULT NULL,
          `Msg` text NULL,
          `Exception` text NULL,
          `UserId` varchar(50) NULL DEFAULT NULL,
          `Url` varchar(1024) NULL DEFAULT NULL,
          `IP` varchar(255) NULL DEFAULT NULL,
          PRIMARY KEY (`Id`) USING BTREE
          );
        </text>
      </install-command>
      <commandText>
        INSERT INTO `Sys_Log${date:format=yyyyMMdd}`(`CreateTime`, `AppName`, `Level`, `Logger`, `Msg`, `Exception`, `UserId`, `Url`, `IP`) VALUES (@CreateTime, @AppName, @Level, @Logger, @Msg, @Exception, @UserId, @Url, @IP);
      </commandText>
      <parameter name="@CreateTime" layout="${longdate}" />
      <parameter name="@AppName" layout="${var:AppName}" />
      <parameter name="@Level" layout="${level}" />
      <parameter name="@Logger" layout="${logger}" allowDbNull="true" />
      <parameter name="@Msg" layout="${message}" allowDbNull="true" />
      <parameter name="@Exception" layout="${exception:format=tostring}" allowDbNull="true" />
      <parameter name="@UserId" layout="${aspnet-user-claim:userId}" allowDbNull="true" />
      <parameter name="@Url" layout="${aspnet-request-url}" allowDbNull="true" />
      <parameter name="@IP" layout="${aspnet-request-ip}" allowDbNull="true" />
    </target>
  </targets>

  <!-- 日志输出规则 -->
  <rules>
    <!--All logs, including from Microsoft-->
    <!--<logger name="*" minlevel="Trace" writeTo="allfile" />-->

    <!--Output hosting lifetime messages to console target for faster startup detection -->
    <logger name="Microsoft.Hosting.Lifetime" minlevel="Info" writeTo="lifetimeConsole, ownFile-web, database" final="true" />
    <logger name="Microsoft.EntityFrameworkCore.Model.Validation" maxlevel="Error" final="true" />

    <!--Skip non-critical Microsoft logs and so log only own logs (BlackHole) -->
    <logger name="Microsoft.*" maxlevel="Info" final="true" />
    <logger name="System.Net.Http.*" maxlevel="Info" final="true" />

    <logger name="*" minlevel="Trace" writeTo="ownFile-web, database" />
  </rules>
</nlog>
```

可以看到我们定义了4个输出目标，前2个是文件，一个是控制台，一个是数据库

### 输出到文件基本定义

fileName：输出的文件名
archiveFileName，archiveAboveSize这两个参数是当文件超过archiveAboveSize大小的时候
就对文件进行分割，然后分割的文件名是用archiveFileName来定义
layout就是日志文件内容，其中以${}闭合的内容就是NLog提供的参数
具体可以参考
[https://nlog-project.org/config/?tab=layout-renderers](https://nlog-project.org/config/?tab=layout-renderers)

```xml
<target xsi:type="File" name="ownFile-web" fileName="${basedir}\..\Log\${date:format=yyyyMM}\${var:AppName}-own-${shortdate}.txt" encoding="UTF-8"
            archiveFileName="${basedir}\..\Log\WMSAPI-own-${shortdate}.{#}.txt" archiveAboveSize="10485760"
            layout="${longdate}|${event-properties:item=EventId_Id:whenEmpty=0}|${uppercase:${level}}|${logger}|${message} ${exception:format=tostring}|url: ${aspnet-request-url}|action: ${aspnet-mvc-action}|${callsite}| body: ${aspnet-request-posted-body}" />
```

### 输出到数据库基本定义

dbProvider：使用数据库组件
connectionString：连接字符串
install-command：安装脚本（用这个来自动创建表）
commandText：日志插入到数据表的脚本
parameter：插入脚本的参数

```xml
    <target xsi:type="Database" name="database" dbProvider="MySqlConnector.MySqlConnection, MySqlConnector">
      <connectionString>${configsetting:item=ConnectionStrings.GDbContext}</connectionString>
      <install-command ignoreFailures="true">
        <text>
          <!-- NOTE: call LogManager.Configuration.Install(new InstallationContext()); to execute this query. -->
          CREATE TABLE IF NOT EXISTS `Sys_Log${date:format=yyyyMMdd}`  (
          `Id` bigint NOT NULL AUTO_INCREMENT,
          `CreateTime` datetime NOT NULL,
          `AppName` varchar(50) NOT NULL,
          `Level` varchar(50) NOT NULL,
          `Logger` varchar(1024) NULL DEFAULT NULL,
          `Msg` text NULL,
          `Exception` text NULL,
          `UserId` varchar(50) NULL DEFAULT NULL,
          `Url` varchar(1024) NULL DEFAULT NULL,
          `IP` varchar(255) NULL DEFAULT NULL,
          PRIMARY KEY (`Id`) USING BTREE
          );
        </text>
      </install-command>
      <commandText>
        INSERT INTO `Sys_Log${date:format=yyyyMMdd}`(`CreateTime`, `AppName`, `Level`, `Logger`, `Msg`, `Exception`, `UserId`, `Url`, `IP`) VALUES (@CreateTime, @AppName, @Level, @Logger, @Msg, @Exception, @UserId, @Url, @IP);
      </commandText>
      <parameter name="@CreateTime" layout="${longdate}" />
      <parameter name="@AppName" layout="${var:AppName}" />
      <parameter name="@Level" layout="${level}" />
      <parameter name="@Logger" layout="${logger}" allowDbNull="true" />
      <parameter name="@Msg" layout="${message}" allowDbNull="true" />
      <parameter name="@Exception" layout="${exception:format=tostring}" allowDbNull="true" />
      <parameter name="@UserId" layout="${aspnet-user-claim:userId}" allowDbNull="true" />
      <parameter name="@Url" layout="${aspnet-request-url}" allowDbNull="true" />
      <parameter name="@IP" layout="${aspnet-request-ip}" allowDbNull="true" />
    </target>
```

可以看到我们这里通过install-command编写的建表SQL脚本
表名是Sys_Log${date:format=yyyyMMdd}，这样我们创建出来的表名就是Sys_Log20211103(根据日间格式化)
但是NLog不会自动帮我们运行这个建表脚本，要我们在代码里调用
LogManager.Configuration.Install(new InstallationContext());
这个方法，他才会运行install-command里面的脚本。

因为我们是按天来进行分表的，那就相当于我每天要运行一次
LogManager.Configuration.Install(new InstallationContext());

所以我就写了一个定时的HostedService。来每天自动运行NLog的Install方法

```C#
    public class LogHostedService : IHostedService, IAsyncDisposable
    {
        private Timer RunTimer { get; set; }
        public Task StartAsync(CancellationToken cancellationToken)
        {
            LogManager.Configuration.Install(new NLog.Config.InstallationContext());//启动后执行一次
            this.RunTimer = new Timer(LogInstall, null, DateTime.Now.AddDays(1).Date - DateTime.Now, TimeSpan.FromDays(1));
            return Task.CompletedTask;
        }
        public void LogInstall(object state)
        {
            LogManager.Configuration.Install(new NLog.Config.InstallationContext());//每天0点执行一次
        }
        public Task StopAsync(CancellationToken cancellationToken)
        {
            this.RunTimer?.Change(Timeout.Infinite, 0);
            return Task.CompletedTask;
        }

        public ValueTask DisposeAsync()
        {
            return this.RunTimer.DisposeAsync();
        }
    }
```

这样就会在系统启动时和每天的0点的时候，创建当天的日志表
然后我们的插入语句INSERT INTO `Sys_Log${date:format=yyyyMMdd}`
就会自动插入到每天的日志表里面

### 代码启用NLog

我们在Program.cs文件里使用UseNLog()启用NLog组件

```C#
        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                })
                .UseNLog();
```

然后在Startup.cs里启用HostedService来定时创建每天的日志表

```C#
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddHostedService<LogHostedService>();//每天自动创建日志表
        }
```

## 成果

![NLog](1.png)
