---
layout: post
title: '为模型添加通用扩展属性'
subtitle: '当有客户有自定义扩展属性的时候,又不方便修改表的情况下使用'
header-img: "img/bg1.jpg"
tags:
  - WMS
date: 2021-06-18 09:59:22
---

## 扩展属性介绍

在系统开发过程中,模型定义的字段大多只是通用业务字段
而当在实施过程中,项目有些属性在模型中未定义,又不方便修改业务模型的情况下
通过配置扩展属性,就可以把特定项目的一些非业务属性维护进系统

## 扩展属性使用

### 扩展类型

我们在通用扩展实体(ExpandEntity)中.为系统定义了扩展实体
分别为String,Enum,Int,Num,Date几个大类,每个大类有6个扩展字段,共30个扩展字段

### 新增扩展实体

在实体类项目中.新建类然后使用代码片段关键字gexpand
就会生成如下图的实体类
![扩展实体](1.png)

然后在业表实体下增加相应的配置,并在相应的DGbContex里增加对应的扩展实体
![扩展实体](2.png)

### 增加扩展实体配置

配置主要是告诉前端.我要扩展哪些字段

主要是增加CF_Enum,CF_EnumItem表数据
注意:CF_EnumItem.Name为前端显示标签名称
注意:CF_EnumItem.Code为对应扩展表字段名称
注意:如果要配置ExpEnum类型的字段,那么要在CF_EnumItem.Config中配置对应的枚举编码

![扩展实体](4.png)
![扩展实体](3.png)

### 重写Business的AddOrUpdateAsync方法

因为扩展表与主表是的关系是一对一的关系
所以要重写保存数据方法
要重新
![扩展实体](5.png)
![扩展实体](6.png)

到这里，后端的代码就已经写完了。然后可以做一下数据迁移。
把新的扩展实体与数据更新到数据库

### 前端代码

1. 先定义扩展配置，并把扩展配置加载
![扩展实体](7.png)

2. 然后引用扩展输入组件，并通过配置的扩展属性把组件显示在界面上
![扩展实体](8.png)

### 最终效果

![扩展实体](9.png)