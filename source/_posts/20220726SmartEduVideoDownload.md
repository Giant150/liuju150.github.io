---
layout: post
title: '国家中小学智慧教育平台视频课程下载'
subtitle: '批量下载课程视频'
tags:
  - 随笔
date: 2022-07-26 10:07:53
---

## 工具下载

链接：https://pan.baidu.com/s/1zCW4wyuzkjnAfQz3zeisBQ 
提取码：1234

## 前言

最近家里有一台10年前的老电视机，因为不能连接无线网络。
家里也没有用有线电视机顶盒了。只能播放一些本地视频了。
再加上小孩子现在正在放暑假，所以想搞些学习视频给他看一下。
正好有国家中小学智慧教育平台，里面的同步课程视频都是可以免费看的。
所以我打算把他全部下载到U盘里在电视机上播放。
![智慧教育](1.png)

## 开始

一个学期一门课程的同步课程视频大约有50~80个视频，如果一个个下载的话。没个半天是搞不完的。
但是一个学期不只有一门课，就算只下语文数学的话，那一天时间就全完在这上面了。
这到还不是重点，重点是一天都在做重复的劳动
打开一个课程，然后找到视频下载地址，然后用下载工具把视频下载下来。
重复这个动作大约百来次，每次要等个几分钟下载。
做为一个程序员的我，这个是接受不了的。
所以我就打算写个程序，可以批量把所有视频批量下载。
![智慧教育](2.png)

## 分析视频下载地址

打开第一个课程，我们发现有个请求地址为
https://s-file-1.ykt.cbern.com.cn/zxx/s_course/v1/x_class_hour_activity/89306b9d-db26-4db5-9f39-54865d43314b/resources.json
返回的内容为视频的下载地址
![智慧教育](3.png)


一看就知道89306b9d-db26-4db5-9f39-54865d43314b这个Id为此课程的Id
如果我要批量下载的话。那么我就要找到当前学科的所有课程Id
这样的话，我就能找到所有的视频地址
于是，我又在网络请求里找到了一个这样的地址
https://s-file-1.ykt.cbern.com.cn/zxx/s_course/v2/activity_sets/75f96245-8136-457e-b8dd-626fe960d131/fulls.json
这个地址返回的是当前课程的所有信息，所以通过这个就可以找到一门课程的所有视频Id了
![智慧教育](4.png)

当然找到这里，就能完成我所有的需求了。
我只要找到这个课程的目录把对应的课程信息fulls.json拿到
就可以找到所有视频的Id，然后通过每个视频Id去请求对应视频的resources.json
就可以拿到所有的视频地址了。

## 下载视频

我们通过分析下载的视频地址为
https://r3-ndr.ykt.cbern.com.cn/edu_product/65/video/17b72ffb547a11eb96b8fa20200c3759/5bf35e06793611b4383bdf3bf9b550ea.1280.720.false/5bf35e06793611b4383bdf3bf9b550ea.1280.720.m3u8
像这样的m3u8格式地址。这样的地址并不能下载为完整的mp4格式视频
因为m3u8是视频的分片格式，把一个视频文件分片了很多小片段，
片段内容记录到了m3u8文件里，所以我们要把m3u8里的每一个分片都下载下来，
然后再合成一个mp4文件
所以我们就请出了在GitHub上最火的m3u8视频下载器
https://github.com/nilaoda/N_m3u8DL-CLI
通过这个工具只要传一个m3u8地址，他就会自动帮你下载所有分片
最后合成一个mp4视频。

## One More Time

都已经做到了可以拿到一门课程就可以把课程的所有视频批量下载
那进一步是不是可以把所有课程信息都拿下来，是不是就可以下载全部视频了。
所以通过分析，我们又发现了一个牛B接口
https://s-file-1.ykt.cbern.com.cn/zxx/api_static/tag_views/trees/sync-course.json
通过这个接口，我们可以知道所有学段、年级、学科、版本、册次信息
这样我们就可以知道所有课程了。
![智慧教育](5.png)

## 结束

最后根据以上信息，花一天天时间，就完成了国家中小学智慧教育平台视频所有课程批量下载工具
第一步选择要下载的课程
![智慧教育](6.png)

选择好之后，工具会自动帮你分析出所有视频的下载的址
并按对应的学科、单元、课程创建对应的视频目录与文件
![智慧教育](7.png)
这样所有的视频都下载完成后
就可以保存到U盘，放到我的老电视机上播放了。

```C#
static async Task Main(string[] args)
    {
        //var courseUrl = "https://s-file-1.ykt.cbern.com.cn/zxx/api_static/tag_views/trees/sync-course.json";
        var httpClient = new HttpClient();

        var tagJson = await File.ReadAllTextAsync("tag.json");
        var tags = JsonSerializer.Deserialize<tag_view>(tagJson);
        Console.WriteLine(tags.tag_view_name);
        var group = tags.tag_tree.FirstOrDefault();
        var selectedTags = new List<string>();
        do
        {
            Console.WriteLine($"请选择{group.tag_group_name}");
            for (int i = 0; i < group.tags.Count; i++)
            {
                Console.WriteLine($"\t{i + 1}:{group.tags[i].tag_name}");
            }
            var readKey = Console.ReadKey();
            var index = int.Parse(readKey.KeyChar.ToString());
            var tag = group.tags[index - 1];
            Console.WriteLine($"您选择的是{tag.tag_name}");
            selectedTags.Add(tag.tag_code);
            group = group.tags[index - 1].children.FirstOrDefault();
        }
        while (group != null);

        Console.WriteLine(String.Join(',', selectedTags));

        var libJson = await File.ReadAllTextAsync("libraries.json");
        var libraries = JsonSerializer.Deserialize<List<librariesModel>>(libJson);

        var selectedLib = libraries.FirstOrDefault(w => w.catalog_ids.Except(selectedTags).Count() == 0);

        if (selectedLib == null)
        {
            Console.WriteLine("未找到课程");
            return;
        }
        Console.WriteLine($"{selectedLib.title}");

        var courseUrl = $"https://s-file-1.ykt.cbern.com.cn/zxx/s_course/v2/business_courses/{selectedLib.resource_id}/course_relative_infos/zh-CN.json";
        var courseJson = await httpClient.GetStringAsync(courseUrl);
        var course = JsonSerializer.Deserialize<course>(courseJson);

        var activityUrl = $"https://s-file-1.ykt.cbern.com.cn/zxx/s_course/v2/activity_sets/{course.course_detail.activity_set_id}/fulls.json";
        var activityJson = await httpClient.GetStringAsync(activityUrl);
        var activity = JsonSerializer.Deserialize<activityModel>(activityJson);

        var rootPath = AppDomain.CurrentDomain.BaseDirectory;
        var activeSetPath = Path.Combine(rootPath, activity.activity_set_name);
        if (!Directory.Exists(activeSetPath)) Directory.CreateDirectory(activeSetPath);
        Console.WriteLine($"{activity.activity_set_name}");
        foreach (var catalog in activity.nodes)
        {
            var catalogPath = Path.Combine(activeSetPath, $"{catalog.order_no}.{catalog.node_name}");
            if (!Directory.Exists(catalogPath)) Directory.CreateDirectory(catalogPath);
            Console.WriteLine($"{catalog.order_no}.{catalog.node_name}");
            foreach (var active in catalog.child_nodes)
            {
                //var activePath = Path.Combine(catalogPath, $"{active.order_no}.{active.node_name}");
                //if (!Directory.Exists(activePath)) Directory.CreateDirectory(activePath);
                var mp4Path= Path.Combine(catalogPath, $"{active.order_no}.{active.node_name}.mp4");
                if (File.Exists(mp4Path)) continue;

                var resourceUrl = $"https://s-file-1.ykt.cbern.com.cn/zxx/s_course/v1/x_class_hour_activity/{active.node_id}/resources.json";
                var resourceJson = await httpClient.GetStringAsync(resourceUrl);
                var listResource = JsonSerializer.Deserialize<List<resourcesModel>>(resourceJson);
                var resource = listResource.FirstOrDefault(w => w.resource_type == "video");
                var videoUrl = resource.video_extend.urls.Last().urls.FirstOrDefault();
                Console.WriteLine($"{Environment.NewLine}{active.node_name}{Environment.NewLine}{videoUrl}");

                var fileName = $"{active.order_no}.{active.node_name}";
                var dlargs = $"\"{videoUrl}\" --workDir \"{catalogPath}\" --saveName \"{fileName}\" --enableDelAfterDone ";
                ProcessStartInfo dlProcessInfo = new ProcessStartInfo(Path.Combine(rootPath, "N_m3u8DL-CLI_v3.0.1.exe"), dlargs);
                //dlProcessInfo.CreateNoWindow = true;
                dlProcessInfo.WorkingDirectory = rootPath;
                var p = new Process();
                p.StartInfo = dlProcessInfo;
                p.Start();
                await p.WaitForExitAsync();
            }
        }
        Console.WriteLine("下载完成,按任意键结束");
        Console.ReadKey();
    }
```

![智慧教育](0.png)
