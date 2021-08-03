---
layout: post
title: '使用Excel做数据导入导出操作'
subtitle: '在WMS中如果有数据要做批量维护的情况下,使用Excel做导出导入'
header-img: "img/bg1.jpg"
tags:
  - WMS
date: 2021-08-03 10:05:30
---

## 创建模型

如下图所示,在Api项目的Models文件夹下创建导入导出模型
![导入导出](1.png)

实体定义如下图
![导入导出](2.png)

ExcelExporter:Excel导出定义
ExcelImporter:Excel导入定义

ExporterHeader:导出时Excel的表头 Format说明:"@"是表示文本,"#,###.00"表示2位小数的千分位数字,"YYYY-MM-DD"日期格式
ImporterHeader:导入时Excel对应的表头
>当手写属性的时候，可以用gieprop的快捷方式生成代码片段

![导入导出](3.png)
对于导出来说,一秀会写构造函数来实现数据实体与导出实体的转换。
这样在导出的时候，就可以直接Map

## 接口定义与实现

在对应的Business层定义导入导出接口
原则：Business接口只返回与接收Entity实体数据，不接收导入导出实体数据
导入导出实体数据转换为Entity实体在Api层实现
可以根据业务需求定义接口
![导入导出](4.png)
![导入导出](6.png)

## Api接口

![导入导出](7.png)
![导入导出](8.png)

## 前端功能实现

导出
![导入导出](9.png)
![导入导出](10.png)

导入

```html
<a-upload v-action:Import
@change="handleDetailImport" :showUploadList="false" name="file" :action="uploadConfig.action" 
:data="uploadConfig.data" :headers="uploadConfig.headers">
  <a-button type="primary" icon="import" size="small">导入</a-button>
</a-upload>
```

![导入导出](11.png)
