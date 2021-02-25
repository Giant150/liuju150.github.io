---
layout: post
title: 'EF Core的Code First模式'
subtitle: '使用Entity Framework Core的Code First生成实体，并迁移到数据库'
header-img: "img/dotnet.jpg"
tags:
  - 随笔
  - NetCore
date: 2021-02-25 09:25:34
---

## Entity Framework Core

Entity Framework (EF) Core 是轻量化、可扩展、开源和跨平台版的常用 Entity Framework 数据访问技术。
EF Core 可用作对象关系映射程序 (O/RM)，这可以实现以下两点：
使 .NET 开发人员能够使用 .NET 对象处理数据库。
无需再像通常那样编写大部分数据访问代码。

EF 支持以下模型开发方法：

- Database First:先有数据库，后有实体模型。从现有数据库生成模型。对模型手动编码，使其符合数据库。
- Code First：创建模型后，使用 EF 迁移从模型创建数据库。 模型发生变化时，迁移可让数据库不断演进。先有实体模型，后生成数据库

## 创建模型

### 通用模型

数据表，都会有主键字段。为了满足此需求，所以我们建立一个通用的泛型模型BaseEntity

```C#
    /// <summary>
    /// 通用基本模型
    /// </summary>
    /// <typeparam name="K">主键类型</typeparam>
    public class BaseEntity<K>
    {
        /// <summary>
        /// Id,主键
        /// </summary>
        public K Id { get; set; }
    }
    /// <summary>
    /// 通用模型
    /// </summary>
    public class BaseEntity : BaseEntity<string>
    {

    }
```

为了让系统知道我们的Id字段是主键，我们增加了对通用模型的配置
EF可以有两种方法来配置实体，一种是使用数据批注(Attribute)
还有一种是Fluent API，就是通过代码来对模型配置
本示例使用Fluent API来配置
因为有些特殊情况是不能使用数据批注(Attribute)来满足要求
比如多主键，多外键，关联等情况。

```C#
    /// <summary>
    /// 默认实体配置
    /// OnModelCreating
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <typeparam name="K"></typeparam>
    public class BaseEntityTypeConfig<T, K> : IEntityTypeConfiguration<T>
        where T : BaseEntity<K>
    {
        public virtual void Configure(EntityTypeBuilder<T> builder)
        {
            #region 主外键关系
            builder.HasKey(k => k.Id);//设置主键
            #endregion

            #region 字段属性:最大长度,是否必需,默认值
            
            #endregion

            #region 备注
            builder.Property(p => p.Id).HasComment("主键");//设置备注
            #endregion
        }
    }

    public class BaseEntityTypeConfig<T> : BaseEntityTypeConfig<T, string>, IEntityTypeConfiguration<T>
        where T : BaseEntity
    {
        public override void Configure(EntityTypeBuilder<T> builder)
        {
            base.Configure(builder);

            #region 主外键关系

            #endregion

            #region 字段属性:最大长度,是否必需,默认值
            builder.Property(p => p.Id).HasMaxLength(50);//设置主键最大长度50
            #endregion

            #region 备注

            #endregion
        }
    }
```

对于业务实体，一般我们又会有些其它通过字段，比如创建人，创建时间，修改人，修改时间，是否删除等公共字段
所以我们创建了BusEntity通用业务模型

```C#
    /// <summary>
    /// 业务实体基类
    /// </summary>
    /// <typeparam name="K">主键类型</typeparam>
    public class BusEntity<K> : BaseEntity<K>
    {
        /// <summary>
        /// 是否删除
        /// </summary>
        public bool Deleted { get; set; }
        /// <summary>
        /// 创建人
        /// </summary>
        public K CreateUserId { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        public DateTime CreateTime { get; set; }
        /// <summary>
        /// 修改人
        /// </summary>
        public K ModifyUserId { get; set; }
        /// <summary>
        /// 修改时间
        /// </summary>
        public DateTime ModifyTime { get; set; }
    }
    /// <summary>
    /// 业务实体基类
    /// </summary>
    public class BusEntity : BusEntity<string>
    { }
```

对于基本业务实体基类用以下配置

```C#
    /// <summary>
    /// 默认实体配置
    /// OnModelCreating
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <typeparam name="K"></typeparam>
    public class BusEntityTypeConfig<T, K> : BaseEntityTypeConfig<T, K>, IEntityTypeConfiguration<T>
        where T : BusEntity<K>
    {
        public override void Configure(EntityTypeBuilder<T> builder)
        {
            base.Configure(builder);
            builder.HasQueryFilter(q => q.Deleted == false);//查询自动过滤已经删除的记录

            #region 主外键关系

            #endregion

            #region 字段属性:最大长度,是否必需,默认值
            builder.Property(p => p.Deleted).HasDefaultValue(false);//把是否删除设置为默认False
            builder.Property(p => p.CreateUserId).HasMaxLength(50);//把创建人设置为默认值
            builder.Property(p => p.ModifyUserId).HasMaxLength(50);//把修改人设置为默认值
            builder.Property(p => p.CreateTime).HasDefaultValueSql("getdate()").ValueGeneratedOnAdd();//把创建时间设置默认值并在增加的时候更新值
            builder.Property(p => p.ModifyTime).HasDefaultValueSql("getdate()").ValueGeneratedOnAddOrUpdate();//把修改时间设置默认值并在增加和修改的时候更新值
            #endregion

            #region 备注
            builder.Property(p => p.Deleted).HasComment("是否删除");
            builder.Property(p => p.CreateUserId).HasComment("创建人");
            builder.Property(p => p.CreateTime).HasComment("创建时间");
            builder.Property(p => p.ModifyUserId).HasComment("修改人");
            builder.Property(p => p.ModifyTime).HasComment("修改时间");
            #endregion
        }
    }

    public class BusEntityTypeConfig<T> : BusEntityTypeConfig<T, string>, IEntityTypeConfiguration<T>
        where T : BusEntity
    {
        public override void Configure(EntityTypeBuilder<T> builder)
        {
            base.Configure(builder);

            #region 主外键关系

            #endregion

            #region 字段属性:最大长度,是否必需,默认值
            builder.Property(p => p.Id).HasMaxLength(50);
            #endregion

            #region 备注

            #endregion
        }
    }
```

### 业务模型

接下来我们有了通用模型基类。那么我们就可以来创建具体的业务模型
比如说我们的组织架构模型
我们使用两个局部类来定义，
第一个局部类定义基本属性
第二个局部类定义关联关系
然后对模型进行配置

```C#
    /// <summary>
    /// 组织架构
    /// </summary>
    public partial class Sys_Org : BusEntity
    {
        /// <summary>
        /// 上级组织
        /// </summary>
        public string ParentId { get; set; }
        /// <summary>
        /// 名称
        /// </summary>
        public string Name { get; set; }
    }
    public partial class Sys_Org : BusEntity
    {
        /// <summary>
        /// 上级组织
        /// </summary>
        public Sys_Org Parent { get; set; }
        /// <summary>
        /// 下级组织
        /// </summary>
        public List<Sys_Org> Childs { get; set; }
    }

    /// <summary>
    /// 实体配置
    /// OnModelCreating
    /// </summary>
    public class Sys_OrgTypeConfig : BusEntityTypeConfig<Sys_Org>, IEntityTypeConfiguration<Sys_Org>
    {
        public override void Configure(EntityTypeBuilder<Sys_Org> builder)
        {
            base.Configure(builder);

            #region 主外键关系
            builder.HasOne(p => p.Parent).WithMany(p => p.Childs).HasForeignKey(p => p.ParentId);
            #endregion

            #region 字段属性:最大长度,是否必需,默认值
            builder.Property(p => p.Name).HasMaxLength(50).IsRequired();
            #endregion

            #region 备注
            builder.Property(p => p.ParentId).HasComment("上级组织");
            builder.Property(p => p.Name).HasComment("名称");
            #endregion
        }
    }
```

```C#
    /// <summary>
    /// 系统用户
    /// </summary>
    public partial class Sys_User : BusEntity
    {
        /// <summary>
        /// 工号、编码
        /// </summary>
        public string Code { get; set; }
        /// <summary>
        /// 名称
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// 用户名
        /// </summary>
        public string UserName { get; set; }
        /// <summary>
        /// 密码
        /// </summary>
        public string Password { get; set; }

        /// <summary>
        /// 状态
        /// </summary>
        public string Status { get; set; }

        /// <summary>
        /// 所属组织
        /// </summary>
        public string OrgId { get; set; }

        /// <summary>
        /// 性别
        /// </summary>
        public string Sex { get; set; }
    }
    public partial class Sys_User : BusEntity
    {
        /// <summary>
        /// 所属组织
        /// </summary>
        public Sys_Org Org { get; set; }
    }
    /// <summary>
    /// 实体配置
    /// OnModelCreating
    /// </summary>
    public class Sys_UserTypeConfig : BusEntityTypeConfig<Sys_User>, IEntityTypeConfiguration<Sys_User>
    {
        public override void Configure(EntityTypeBuilder<Sys_User> builder)
        {
            base.Configure(builder);

            #region 主外键关系
            builder.HasOne(p => p.Org).WithMany().HasForeignKey(p => p.OrgId);
            #endregion

            #region 字段属性:最大长度,是否必需,默认值
            builder.Property(p => p.Code).HasMaxLength(50);
            builder.Property(p => p.Name).HasMaxLength(50).IsRequired();
            builder.Property(p => p.UserName).HasMaxLength(50).IsRequired();
            builder.Property(p => p.Password).HasMaxLength(100).IsRequired();
            builder.Property(p => p.Status).HasMaxLength(50).IsRequired();
            builder.Property(p => p.OrgId).HasMaxLength(50);
            builder.Property(p => p.Sex).HasMaxLength(50);
            #endregion

            #region 备注
            builder.Property(p => p.Code).HasComment("编码");
            builder.Property(p => p.Name).HasComment("名称");
            builder.Property(p => p.UserName).HasComment("用户名");
            builder.Property(p => p.Password).HasComment("密码");
            builder.Property(p => p.Status).HasComment("状态");
            builder.Property(p => p.OrgId).HasComment("所属组织");
            builder.Property(p => p.Sex).HasComment("性别");
            #endregion
        }
    }
```

### 创建数据库上下文Context

有了数据模型，接下来我们创建数据库上下文Context
OnConfiguring用来配置数据连接字符串
OnModelCreating是创建模型是对模型的配置
因为上面我们对每个模型都做了配置(实现了IEntityTypeConfiguration)
所以在这里我们只要把具体的配置配置应用到Context就行了
我们使用modelBuilder.ApplyConfigurationsFromAssembly
就可以把所有实现了IEntityTypeConfiguration的模型配置全部应用到数据库上下文

```C#
    public class GDbContext : DbContext
    {
        /// <summary>
        /// Context配置
        /// </summary>
        /// <param name="optionsBuilder"></param>
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            base.OnConfiguring(optionsBuilder);
            optionsBuilder.UseSqlServer("Data Source=x.x.x.x;Initial Catalog=数据库名称;User Id=用户名;Password=密码;APP=系统名称;Pooling=true;");
        }

        /// <summary>
        /// 模型创建
        /// </summary>
        /// <param name="modelBuilder"></param>
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.ApplyConfigurationsFromAssembly(this.GetType().Assembly);
        }

        /// <summary>
        /// 组织架构
        /// </summary>
        public DbSet<Sys_Org> Sys_Org { get; set; }
        /// <summary>
        /// 用户
        /// </summary>
        public DbSet<Sys_User> Sys_User { get; set; }
    }
```

所有代码结构如下
![CodeFirst](1.png)

## 迁移数据库

专业名称叫迁移，通用解释就是把实体模型生成为数据表
我们在OnConfiguring中已经配置了使用SqlServer数据库（当然也支持其它所有类型数据库：如MySql,Oracle,Sqlite等其它数据库）
使用迁移，必需安装Microsoft.EntityFrameworkCore.Tools工具集
接下来我们在“程序包管理控制台”输入Add-Migration FirstInit   (FirstInit:自定义名称)
系统会自动帮我们生成迁移代码
![CodeFirst](2.png)
![CodeFirst](3.png)

```C#
    public partial class FirstInit : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Sys_Org",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, comment: "主键"),
                    ParentId = table.Column<string>(type: "nvarchar(50)", nullable: true, comment: "上级组织"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, comment: "名称"),
                    Deleted = table.Column<bool>(type: "bit", nullable: false, defaultValue: false, comment: "是否删除"),
                    CreateUserId = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, comment: "创建人"),
                    CreateTime = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "getdate()", comment: "创建时间"),
                    ModifyUserId = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, comment: "修改人"),
                    ModifyTime = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "getdate()", comment: "修改时间")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sys_Org", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Sys_Org_Sys_Org_ParentId",
                        column: x => x.ParentId,
                        principalTable: "Sys_Org",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Sys_User",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, comment: "主键"),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, comment: "编码"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, comment: "名称"),
                    UserName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, comment: "用户名"),
                    Password = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false, comment: "密码"),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false, comment: "状态"),
                    OrgId = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, comment: "所属组织"),
                    Sex = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, comment: "性别"),
                    Deleted = table.Column<bool>(type: "bit", nullable: false, defaultValue: false, comment: "是否删除"),
                    CreateUserId = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, comment: "创建人"),
                    CreateTime = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "getdate()", comment: "创建时间"),
                    ModifyUserId = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true, comment: "修改人"),
                    ModifyTime = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "getdate()", comment: "修改时间")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sys_User", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Sys_User_Sys_Org_OrgId",
                        column: x => x.OrgId,
                        principalTable: "Sys_Org",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Sys_Org_ParentId",
                table: "Sys_Org",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_Sys_User_OrgId",
                table: "Sys_User",
                column: "OrgId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Sys_User");

            migrationBuilder.DropTable(
                name: "Sys_Org");
        }
    }
```

### 更新到数据库

我们通过Update-Database命令更新到数据库
![CodeFirst](5.png)
![CodeFirst](6.png)

### 生成SQL脚本更新到生产数据库

有时候我们系统已经在运行了。开始也不可能直接连接生产数据库
那么我们修改了模型，可以通过生成SQL脚本，来更新数据库

```cmd
#起始迁移点(没有写0)
#结束迁移点
Script-Migration -From 0 -To 20210225022927_FirstInit
```

![CodeFirst](7.png)

```sql
IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [Sys_Org] (
    [Id] nvarchar(50) NOT NULL,
    [ParentId] nvarchar(50) NULL,
    [Name] nvarchar(50) NOT NULL,
    [Deleted] bit NOT NULL DEFAULT CAST(0 AS bit),
    [CreateUserId] nvarchar(50) NULL,
    [CreateTime] datetime2 NOT NULL DEFAULT (getdate()),
    [ModifyUserId] nvarchar(50) NULL,
    [ModifyTime] datetime2 NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK_Sys_Org] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Sys_Org_Sys_Org_ParentId] FOREIGN KEY ([ParentId]) REFERENCES [Sys_Org] ([Id]) ON DELETE NO ACTION
);
DECLARE @defaultSchema AS sysname;
SET @defaultSchema = SCHEMA_NAME();
DECLARE @description AS sql_variant;
SET @description = N'主键';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_Org', 'COLUMN', N'Id';
SET @description = N'上级组织';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_Org', 'COLUMN', N'ParentId';
SET @description = N'名称';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_Org', 'COLUMN', N'Name';
SET @description = N'是否删除';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_Org', 'COLUMN', N'Deleted';
SET @description = N'创建人';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_Org', 'COLUMN', N'CreateUserId';
SET @description = N'创建时间';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_Org', 'COLUMN', N'CreateTime';
SET @description = N'修改人';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_Org', 'COLUMN', N'ModifyUserId';
SET @description = N'修改时间';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_Org', 'COLUMN', N'ModifyTime';
GO

CREATE TABLE [Sys_User] (
    [Id] nvarchar(50) NOT NULL,
    [Code] nvarchar(50) NULL,
    [Name] nvarchar(50) NOT NULL,
    [UserName] nvarchar(50) NOT NULL,
    [Password] nvarchar(100) NOT NULL,
    [Status] nvarchar(50) NOT NULL,
    [OrgId] nvarchar(50) NULL,
    [Sex] nvarchar(50) NULL,
    [Deleted] bit NOT NULL DEFAULT CAST(0 AS bit),
    [CreateUserId] nvarchar(50) NULL,
    [CreateTime] datetime2 NOT NULL DEFAULT (getdate()),
    [ModifyUserId] nvarchar(50) NULL,
    [ModifyTime] datetime2 NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK_Sys_User] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Sys_User_Sys_Org_OrgId] FOREIGN KEY ([OrgId]) REFERENCES [Sys_Org] ([Id]) ON DELETE NO ACTION
);
DECLARE @defaultSchema AS sysname;
SET @defaultSchema = SCHEMA_NAME();
DECLARE @description AS sql_variant;
SET @description = N'主键';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'Id';
SET @description = N'编码';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'Code';
SET @description = N'名称';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'Name';
SET @description = N'用户名';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'UserName';
SET @description = N'密码';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'Password';
SET @description = N'状态';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'Status';
SET @description = N'所属组织';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'OrgId';
SET @description = N'性别';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'Sex';
SET @description = N'是否删除';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'Deleted';
SET @description = N'创建人';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'CreateUserId';
SET @description = N'创建时间';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'CreateTime';
SET @description = N'修改人';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'ModifyUserId';
SET @description = N'修改时间';
EXEC sp_addextendedproperty 'MS_Description', @description, 'SCHEMA', @defaultSchema, 'TABLE', N'Sys_User', 'COLUMN', N'ModifyTime';
GO

CREATE INDEX [IX_Sys_Org_ParentId] ON [Sys_Org] ([ParentId]);
GO

CREATE INDEX [IX_Sys_User_OrgId] ON [Sys_User] ([OrgId]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20210225022927_FirstInit', N'5.0.3');
GO

COMMIT;
GO

```

这样的话。就只要把这个脚本放到生产环境去运行，
那么得到的结果也是和Update-Database结果是一样的


