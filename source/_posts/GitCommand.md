---
layout: post
title: 'Git命令说明'
subtitle: ''
header-img: "img/git.jpg"
tags:
  - 随笔
date: 2020-08-26 16:16:18
---

## Git同步源仓库代码

```cmd
git remote add upstream https://github.com/Coldairarrow/Colder.Admin.AntdVue.git
git fetch upstream
git merge upstream/master --allow-unrelated-histories

git pull origin master --allow-unrelated-histories
```

## 推送代码到远程分支仓库

```cmd
git push FangXuIT --force
#包括标签
git push FangXuIT --tags
```

![Git初始化](GitInit.png)
