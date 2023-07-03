---
layout: post
title: 'WebAPI公开接口请求签名验证'
subtitle: '对于没有身份认证的公开接口做合法签名验证'
tags:
  - Asp.Net
date: 2023-07-01 10:07:20
---

## 前言

现在的系统后端开发的时候,会公开很多API接口
对于要登录认证后才能访问的接口,这样的请求验证就由身份认证模块完成
但是也有些接口是对外公开的,没有身份认证的接口
我们怎么保证接口的请求是合法的,有效的.
这样我们一般就是对请求的合法性做签名验证.

## 实现原理

为保证接口安全，每次请求必带以下header

| header名 | 类型 | 描述 |
| AppId | string | 应用Id |
| Ticks | string | 时间戳为1970年1月1日到现在时间的毫秒数（UTC时间） |
| RequestId | string | GUID字符串,作为请求唯一标志,防止重复请求 |
| Sign| string | 签名,签名算法如下 |

1. 拼接字符串"{AppId}{Ticks}{RequestId}{AppSecret}"
2. 把拼接后的字符串计算MD5值,此MD5值为请求Header的Sign参数传入
3. 后端把对应APP配置好(AppId,AppSecret),并提供给客户端

## 后端验证实现

### 验证AppId

1. 先验证AppId是不是有,没有就直接返回失败
2. 如果有的话,就去缓存里取AppID对应的配置(如果缓存里没有,就去配置文件里取)
3. 如果没有对应AppId的配置,说明不是正确的请求,返回失败

```c#
        model.AppId = context.Request.Headers["AppId"];
        if (String.IsNullOrEmpty(model.AppId))
        {
            await this.ResponseValidFailedAsync(context, 501);
            return;
        }
        var cacheSvc = context.RequestServices.GetRequiredService<IMemoryCache>();
        var cacheAppIdKey = $"RequestValidSign:APPID:{model.AppId}";
        var curConfig = cacheSvc.GetOrCreate<AppConfigModel>(cacheAppIdKey, (e) =>
        {
            e.SlidingExpiration = TimeSpan.FromHours(1);
            var configuration = context.RequestServices.GetRequiredService<IConfiguration>();
            var listAppConfig = configuration.GetSection(AppConfigModel.ConfigSectionKey).Get<AppConfigModel[]>();
            return listAppConfig.SingleOrDefault(x => x.AppId == model.AppId);
        });
        if (curConfig == null)
        {
            await this.ResponseValidFailedAsync(context, 502);
            return;
        }
```

### 验证时间戳

1. 验证时间戳是不是有在请求头里传过来，没有就返回失败
2. 验证时间戳与当前时间比较，如果不在过期时间(5分钟)之内的请求，就返回失败
3. 时间戳为1970年1月1日到现在时间的毫秒数（UTC时间）

```c#
            var ticksString = context.Request.Headers["Ticks"].ToString();
            if (String.IsNullOrEmpty(ticksString))
            {
                await this.ResponseValidFailedAsync(context, 503);
                return;
            }
            model.Ticks = long.Parse(context.Request.Headers["Ticks"].ToString());
            var diffTime = DateTime.UtcNow - (new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc).AddMilliseconds(model.Ticks));
            var expirTime = TimeSpan.FromSeconds(300);//过期时间
            if (diffTime > expirTime)
            {
                await this.ResponseValidFailedAsync(context, 504);
                return;
            }
```

### 验证请求ID

1. 验证请求ID是不是有在请求头里传过来，没有就返回失败
2. 验证请求ID是不是已经在缓存里存在，如果存在就表示重复请求，那么就返回失败
3. 如果请求ID在缓存中不存在，那么就表示正常的请求，同时把请求ID添加到缓存

```c#
            model.RequestId = context.Request.Headers["RequestId"];
            if (String.IsNullOrEmpty(model.RequestId))
            {
                await this.ResponseValidFailedAsync(context, 505);
                return;
            }
            var cacheKey = $"RequestValidSign:RequestId:{model.AppId}:{model.RequestId}";
            if (cacheSvc.TryGetValue(cacheKey, out _))
            {
                await this.ResponseValidFailedAsync(context, 506);
                return;
            }
            else
                cacheSvc.Set(cacheKey, model.RequestId, expirTime);
```

### 验证签名

1.验证签名是否正常
2.签名字符串是$"{AppId}{Ticks}{RequestId}{AppSecret}"组成
3.然后把签名字符串做MD5，再与请求传过来的Sign签名对比
4.如果一至就表示正常请求，请求通过。如果不一至，返回失败

```c#
    public bool Valid()
    {
        var validStr = $"{AppId}{Ticks}{RequestId}{AppSecret}";
        return validStr.ToMD5String() == Sign;
    }

            model.Sign = context.Request.Headers["Sign"];
            if (!model.Valid())
            {
                await this.ResponseValidFailedAsync(context, 507);
                return;
            }
```

## 源代码

我们把所有代码写成一个Asp.Net Core的中间件

```c#
/// <summary>
/// 请求签名验证
/// </summary>
public class RequestValidSignMiddleware
{
    private readonly RequestDelegate _next;

    public RequestValidSignMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var model = new RequestValidSignModel();
        //1.先验证AppId是不是有,没有就直接返回失败
        //2.如果有的话,就去缓存里取AppID对应的配置(如果缓存里没有,就去配置文件里取)
        //3.如果没有对应AppId的配置,说明不是正确的请求,返回失败
        model.AppId = context.Request.Headers["AppId"];
        if (String.IsNullOrEmpty(model.AppId))
        {
            await this.ResponseValidFailedAsync(context, 501);
            return;
        }
        var cacheSvc = context.RequestServices.GetRequiredService<IMemoryCache>();
        var cacheAppIdKey = $"RequestValidSign:APPID:{model.AppId}";
        var curConfig = cacheSvc.GetOrCreate<AppConfigModel>(cacheAppIdKey, (e) =>
        {
            e.SlidingExpiration = TimeSpan.FromHours(1);
            var configuration = context.RequestServices.GetRequiredService<IConfiguration>();
            var listAppConfig = configuration.GetSection(AppConfigModel.ConfigSectionKey).Get<AppConfigModel[]>();
            return listAppConfig.SingleOrDefault(x => x.AppId == model.AppId);
        });
        if (curConfig == null)
        {
            await this.ResponseValidFailedAsync(context, 502);
            return;
        }
        //1.把缓存/配置里面的APP配置取出来,拿到AppSecret
        //2.如果请求里附带了AppSecret(调试用),那么就只验证AppSecret是否正确
        //3.传过来的AppSecret必需是Base64编码后的
        //4.然后比对传过来的AppSecret是否与配置的AppSecret一至,如果一至就通过,不一至就返回失败

        //5.如果请求里没有附带AppSecret,那么走其它验证逻辑.
        model.AppSecret = curConfig.AppSecret;
        var headerSecret = context.Request.Headers["AppSecret"].ToString();
        if (!String.IsNullOrEmpty(headerSecret))
        {
            var secretBuffer = new byte[1024];
            var secretIsBase64 = Convert.TryFromBase64String(headerSecret, new Span<byte>(secretBuffer), out var bytesWritten);
            if (secretIsBase64 && Encoding.UTF8.GetString(secretBuffer, 0, bytesWritten) == curConfig.AppSecret)
                await _next(context);
            else
            {
                await this.ResponseValidFailedAsync(context, 508);
                return;
            }
        }
        else
        {
            //1.验证时间戳是不是有在请求头里传过来，没有就返回失败
            //2.验证时间戳与当前时间比较，如果不在过期时间(5分钟)之内的请求，就返回失败
            //时间戳为1970年1月1日到现在时间的毫秒数（UTC时间）
            var ticksString = context.Request.Headers["Ticks"].ToString();
            if (String.IsNullOrEmpty(ticksString))
            {
                await this.ResponseValidFailedAsync(context, 503);
                return;
            }
            model.Ticks = long.Parse(context.Request.Headers["Ticks"].ToString());
            var diffTime = DateTime.UtcNow - (new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc).AddMilliseconds(model.Ticks));
            var expirTime = TimeSpan.FromSeconds(300);//过期时间
            if (diffTime > expirTime)
            {
                await this.ResponseValidFailedAsync(context, 504);
                return;
            }
            //1.验证请求ID是不是有在请求头里传过来，没有就返回失败
            //2.验证请求ID是不是已经在缓存里存在，如果存在就表示重复请求，那么就返回失败
            //3.如果请求ID在缓存中不存在，那么就表示正常的请求，同时把请求ID添加到缓存
            model.RequestId = context.Request.Headers["RequestId"];
            if (String.IsNullOrEmpty(model.RequestId))
            {
                await this.ResponseValidFailedAsync(context, 505);
                return;
            }
            var cacheKey = $"RequestValidSign:RequestId:{model.AppId}:{model.RequestId}";
            if (cacheSvc.TryGetValue(cacheKey, out _))
            {
                await this.ResponseValidFailedAsync(context, 506);
                return;
            }
            else
                cacheSvc.Set(cacheKey, model.RequestId, expirTime);
            //1.验证签名是否正常
            //2.签名字符串是$"{AppId}{Ticks}{RequestId}{AppSecret}"组成
            //3.然后把签名字符串做MD5，再与请求传过来的Sign签名对比
            //4.如果一至就表示正常请求，请求通过。如果不一至，返回失败
            model.Sign = context.Request.Headers["Sign"];
            if (!model.Valid())
            {
                await this.ResponseValidFailedAsync(context, 507);
                return;
            }
            await _next(context);
        }
    }
    /// <summary>
    /// 返回验证失败
    /// </summary>
    /// <param name="context"></param>
    /// <param name="status"></param>
    /// <returns></returns>
    public async Task ResponseValidFailedAsync(HttpContext context, int status)
    {
        context.Response.StatusCode = 500;
        await context.Response.WriteAsJsonAsync(new ComResult() { Success = false, Status = status, Msg = "请求签名验证失败" }, Extention.DefaultJsonSerializerOptions, context.RequestAborted);
    }
}
public class AppConfigModel
{
    public const string ConfigSectionKey = "AppConfig";
    /// <summary>
    /// 应用Id
    /// </summary>
    public string AppId { get; set; }
    /// <summary>
    /// 应用密钥
    /// </summary>
    public string AppSecret { get; set; }
}
public class RequestValidSignModel : AppConfigModel
{
    /// <summary>
    /// 前端时间戳
    /// Date.now()
    /// 1970 年 1 月 1 日 00:00:00 (UTC) 到当前时间的毫秒数
    /// </summary>
    public long Ticks { get; set; }
    /// <summary>
    /// 请求ID
    /// </summary>
    public string RequestId { get; set; }
    /// <summary>
    /// 签名
    /// </summary>
    public string Sign { get; set; }
    public bool Valid()
    {
        var validStr = $"{AppId}{Ticks}{RequestId}{AppSecret}";
        return validStr.ToMD5String() == Sign;
    }
}
```

### 中间件注册扩展

写一个中间件的扩展,这样我们在Program里可以方便的使用/停用中间件

```c#
/// <summary>
/// 中间件注册扩展
/// </summary>
public static class RequestValidSignMiddlewareExtensions
{
    public static IApplicationBuilder UseRequestValidSign(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RequestValidSignMiddleware>();
    }
}

///Program.cs
app.UseRequestValidSign();
```

### 与Swagger结合

我们一般对外提供在线的Swagger文档
如果我们增加了请求验证的Header,那么所有接口文档里面都要把验证的Header添加到在线文档里面

```c#
/// <summary>
/// 请求签名验证添加Swagger请求头
/// </summary>
public class RequestValidSignSwaggerOperationFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        if (operation.Parameters == null)
            operation.Parameters = new List<OpenApiParameter>();

        operation.Parameters.Add(new OpenApiParameter
        {
            Name = "AppId",
            In = ParameterLocation.Header,
            Required = true,
            Description = "应用ID",
            Schema = new OpenApiSchema
            {
                Type = "string"
            }
        });
        operation.Parameters.Add(new OpenApiParameter
        {
            Name = "Ticks",
            In = ParameterLocation.Header,
            Required = true,
            Description = "时间戳",
            Example = new OpenApiString(((long)(DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).TotalMilliseconds).ToString()),
            Schema = new OpenApiSchema
            {
                Type = "string"
            }
        });
        operation.Parameters.Add(new OpenApiParameter
        {
            Name = "RequestId",
            In = ParameterLocation.Header,
            Required = true,
            Description = "请求ID",
            Example = new OpenApiString(Guid.NewGuid().ToString()),
            Schema = new OpenApiSchema
            {
                Type = "string"
            }
        });
        operation.Parameters.Add(new OpenApiParameter
        {
            Name = "Sign",
            In = ParameterLocation.Header,
            Required = true,
            Description = "请求签名",
            //{AppId}{Ticks}{RequestId}{AppSecret}
            Example = new OpenApiString("MD5({AppId}{Ticks}{RequestId}{AppSecret})"),
            Schema = new OpenApiSchema
            {
                Type = "string"
            }
        });
        operation.Parameters.Add(new OpenApiParameter
        {
            Name = "AppSecret",
            In = ParameterLocation.Header,
            Description = "应用密钥(调试用)",
            Example = new OpenApiString("BASE64({AppSecret})"),
            Schema = new OpenApiSchema
            {
                Type = "string"
            }
        });
    }
}

///在Program.cs里添加Swagger请求验证Header
builder.Services.AddSwaggerGen(c =>
{
    c.OperationFilter<RequestValidSignSwaggerOperationFilter>();
});
```

![请求验证](1.png)

## 客户端调用实现

我们如果用HttpClient调用的话,就要在调用请求前
设置后请求头,AppId,Ticks,RequestId,Sign

```c#
        public async Task<string> GetIPAsync(CancellationToken token)
        {
            this.SetSignHeader();
            var result = await Client.GetStringAsync("/Get", token);
            return result;
        }
        public void SetSignHeader()
        {
            this.Client.DefaultRequestHeaders.Clear();
            var ticks = ((long)(DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).TotalMilliseconds).ToString();
            var requestId = Guid.NewGuid().ToString();
            var signString = $"{this.Config.AppId}{ticks}{requestId}{this.Config.AppSecret}";
            var sign = this.GetMD5(signString);
            this.Client.DefaultRequestHeaders.Add("AppId", this.Config.AppId);
            this.Client.DefaultRequestHeaders.Add("Ticks", ticks);
            this.Client.DefaultRequestHeaders.Add("RequestId", requestId);
            this.Client.DefaultRequestHeaders.Add("Sign", sign);
        }
        public string GetMD5(string value)
        {
            using (MD5 md5 = MD5.Create())
            {
                byte[] inputBytes = Encoding.UTF8.GetBytes(value);
                byte[] hashBytes = md5.ComputeHash(inputBytes);

                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < hashBytes.Length; i++)
                {
                    sb.Append(hashBytes[i].ToString("x2"));
                }
                return sb.ToString();
            }
        }
```

## 最终效果

当我们没有传签名参数的时候,返回失败
![请求验证](2.png)

当我们把签名参数都传正确后,返回正确
![请求验证](3.png)
