---
layout: post
title: 'SSMS表设计器显示说明(注释)字段'
subtitle: 'SQL Server Management Studio'
tags:
  - 随笔
  - SqlServer
date: 2020-09-14 11:23:00
---

## SSMS表设计器默认

当我们新建表/设计表 的时候，SSMS会帮我们打开默认表设计器
如下图。只会显示“列名”，“数据类型”，“允许Null值”这三个列
![SSMS默认表设计器](1.png)

但是大多数的时候，我们还要修改表字段的“默认值”，“说明/注释”
每次都要到设计器下面的“列属性”里去找默认值/说明
然后去修改。不能直接在设计器主界面修改。
所以我们希望在表设计器后面加上“默认值”，“说明”字段，这样加快设计

## 修改方法

打开“注册表编辑器”
找到以下项
“HKEY_CURRENT_USER\SOFTWARE\Microsoft\SQL Server Management Studio\14.0\DataProject”
这里面14.0是SSMS的版本，不同的版本这个值不同。
然后找到以下两个字符串的配置项
SSVPropViewColumnsSQL70
SSVPropViewColumnsSQL80
这两个项的默认值都是1,2,6;
把这两个项目都修改为1,2,6,7,17;
>注意：在修改注册表后，要重启SSMS。表设计器效果才会出来
>注意：在修改注册表后，要重启SSMS。表设计器效果才会出来
>注意：在修改注册表后，要重启SSMS。表设计器效果才会出来

字段对应值索引为：

1. Column Name
2. Data Type
3. Length
4. Precision
5. Scale
6. Allow Nulls
7. Default Value
8. Identity
9. Identity Seed
10. Identity Increment
11. Row GUID
12. Nullable
13. Condensed Type
14. Not for Replication
15. Formula
16. Collation
17. Description

![SSMS默认表设计器](2.png)

## 修改后的效果

![SSMS默认表设计器](3.png)

>注意：在修改注册表后，要重启SSMS。表设计器效果才会出来
>注意：在修改注册表后，要重启SSMS。表设计器效果才会出来
>注意：在修改注册表后，要重启SSMS。表设计器效果才会出来
