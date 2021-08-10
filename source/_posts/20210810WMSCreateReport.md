---
layout: post
title: 'WMS报表开发流程'
subtitle: '此示例为物料汇总报表'
header-img: "img/bg1.jpg"
tags:
  - WMS
date: 2021-08-10 11:38:10
---

## 修改文件总览

![报表开发](1.png) ![报表开发](2.png)

## 建立查询实体与视图模型

1.查询实体就是在前端界面上，有哪些查询条件 (查询实体QueryModel:QM)
2.视图模型就是在前端界面上，列表要显示哪些数据 (视图模型ViewModel:QM)

```c#
namespace Giant.Models
{
    /// <summary>
    /// 物料汇总报表查询实体
    /// </summary>
    public class Rpt_InvSkuQM : BaseQM
    {
        /// <summary>
        /// 仓库ID
        /// </summary>
        [Required]
        public string WhseId { get; set; }
        /// <summary>
        /// 货主Id
        /// </summary>
        public string StorerId { get; set; }
        /// <summary>
        /// 物料Id
        /// </summary>
        public string SkuId { get; set; }
    }
}
```

```c#
namespace Giant.Models
{
    /// <summary>
    /// 物料汇总报表实体
    /// </summary>
    public class Rpt_InvSkuVM
    {
        /// <summary>
        /// 仓库ID
        /// </summary>
        [Required]
        public string WhseId { get; set; }
        /// <summary>
        /// 货主Id
        /// </summary>
        public string StorerId { get; set; }
        /// <summary>
        /// 货主编码
        /// </summary>
        public string StorerCode { get; set; }
        /// <summary>
        /// 货主名称
        /// </summary>
        public string StorerName { get; set; }
        /// <summary>
        /// 物料Id
        /// </summary>
        public string SkuId { get; set; }
        /// <summary>
        /// 物料编码
        /// </summary>
        public string SkuCode { get; set; }
        /// <summary>
        /// 物料名称
        /// </summary>
        public string SkuName { get; set; }
        /// <summary>
        /// 库存数量
        /// </summary>
        public decimal Qty { get; set; }
        /// <summary>
        /// 可用数量
        /// </summary>
        public decimal QtyUse { get; set; }
        /// <summary>
        /// 已分配
        /// </summary>
        public decimal QtyAllocated { get; set; }
        /// <summary>
        /// 已拣货
        /// </summary>
        public decimal QtyPicked { get; set; }
    }
}
```

## 编写数据获取接口

因为我们前端要显示分页，所以我们还是以分页查询条件为主
数据导出也是同一个接口，只不过导出数据的时候，我们把每页行数设置加大就可以了
基本上就实现一个接口，以查询实体为参数，以视图模型为返回结果

```c#
namespace Giant.IBusiness
{
    /// <summary>
    /// 物料汇总报表
    /// </summary>
    public interface IRpt_InvSkuBusiness : IBusRepository<Inv_Inventory>
    {
        /// <summary>
        /// 获取物料汇总数据
        /// </summary>
        /// <param name="query">查询数据</param>
        /// <returns></returns>
        Task<PageResult<Rpt_InvSkuVM>> GetSummaryAsync(PageInput<Rpt_InvSkuQM> query);
    }
}
```

```C#
namespace Giant.Business
{
    /// <summary>
    /// 物料汇总报表
    /// </summary>
    public class Rpt_InvSkuBusiness : BusRepository<Inv_Inventory>, IRpt_InvSkuBusiness, IScopedDependency
    {
        private IServiceProvider SvcProvider { get; set; }
        public Rpt_InvSkuBusiness(GDbContext context, IServiceProvider svcProvider)
            : base(context)
        {
            this.SvcProvider = svcProvider;
        }

        /// <summary>
        /// 获取物料汇总数据
        /// </summary>
        /// <param name="query">查询数据</param>
        /// <returns></returns>
        public async Task<PageResult<Rpt_InvSkuVM>> GetSummaryAsync(PageInput<Rpt_InvSkuQM> query)
        {
            var invQuery = this.GetQueryable(true);
            var search = query.Search;
            if (!search.WhseId.IsNullOrEmpty())
                invQuery = invQuery.Where(w => w.WhseId == search.WhseId);
            if (!search.StorerId.IsNullOrEmpty())
                invQuery = invQuery.Where(w => w.StorerId == search.StorerId);
            if (!search.SkuId.IsNullOrEmpty())
                invQuery = invQuery.Where(w => w.SkuId == search.SkuId);

            var q = from inv in invQuery
                    group inv by new { inv.WhseId, inv.StorerId, inv.SkuId } into g
                    select new { g.Key.WhseId, g.Key.StorerId, g.Key.SkuId, Qty = g.Sum(s => s.Qty), QtyAllocated = g.Sum(s => s.QtyAllocated), QtyPicked = g.Sum(s => s.QtyPicked) } into i
                    join storer in this.GetQueryable<Bas_Storer>(true) on i.StorerId equals storer.Id
                    join sku in this.GetQueryable<Bas_Sku>(true) on i.SkuId equals sku.Id
                    select new Rpt_InvSkuVM()
                    {
                        WhseId = i.WhseId,
                        StorerId = i.StorerId,
                        StorerCode = storer.Code,
                        StorerName = storer.Name,
                        SkuId = i.SkuId,
                        SkuCode = sku.Code,
                        SkuName = sku.Name,
                        Qty = i.Qty,
                        QtyUse = i.Qty - i.QtyAllocated - i.QtyPicked,
                        QtyAllocated = i.QtyAllocated,
                        QtyPicked = i.QtyPicked
                    };
            var result = await q.GetPageResultAsync(query);
            return result;
        }
    }
}
```

## 创建导出模型

导出模型在API层创建，设置好Excel要显示哪些列

```C#
namespace Giant.Api
{
    /// <summary>
    /// 物料汇总
    /// </summary>
    [ExcelExporter(Name = "物料汇总", TableStyle = OfficeOpenXml.Table.TableStyles.Medium23, AutoFitAllColumn = true)]
    [ExcelImporter(SheetName = "物料汇总", IsLabelingError = true)]
    public class Rpt_InvSkuIEM
    {
        /// <summary>
        /// 货主编码 
        /// </summary>
        [ExporterHeader(DisplayName = "货主编码", Format = "@")]
        [ImporterHeader(Name = "货主编码")]
        public string StorerCode { get; set; }
        /// <summary>
        /// 货主名称 
        /// </summary>
        [ExporterHeader(DisplayName = "货主名称", Format = "@")]
        [ImporterHeader(Name = "货主名称")]
        public string StorerName { get; set; }
        /// <summary>
        /// 物料编码 
        /// </summary>
        [ExporterHeader(DisplayName = "物料编码", Format = "@")]
        [ImporterHeader(Name = "物料编码")]
        public string SkuCode { get; set; }
        /// <summary>
        /// 物料名称 
        /// </summary>
        [ExporterHeader(DisplayName = "物料名称", Format = "@")]
        [ImporterHeader(Name = "物料名称")]
        public string SkuName { get; set; }
        /// <summary>
        /// 库存数量 
        /// </summary>
        [ExporterHeader(DisplayName = "库存数量", Format = "#,###.00")]
        [ImporterHeader(Name = "库存数量")]
        public decimal Qty { get; set; }
        /// <summary>
        /// 可用数量 
        /// </summary>
        [ExporterHeader(DisplayName = "可用数量", Format = "#,###.00")]
        [ImporterHeader(Name = "可用数量")]
        public decimal QtyUse { get; set; }
        /// <summary>
        /// 已分配 
        /// </summary>
        [ExporterHeader(DisplayName = "已分配", Format = "#,###.00")]
        [ImporterHeader(Name = "已分配")]
        public decimal QtyAllocated { get; set; }
        /// <summary>
        /// 已拣货 
        /// </summary>
        [ExporterHeader(DisplayName = "已拣货", Format = "#,###.00")]
        [ImporterHeader(Name = "已拣货")]
        public decimal QtyPicked { get; set; }

        public Rpt_InvSkuIEM() { }
        public Rpt_InvSkuIEM(Giant.Models.Rpt_InvSkuVM model)
        {
            this.StorerCode = model.StorerCode;
            this.StorerName = model.StorerName;
            this.SkuCode = model.SkuCode;
            this.SkuName = model.SkuName;
            this.Qty = model.Qty;
            this.QtyUse = model.QtyUse;
            this.QtyAllocated = model.QtyAllocated;
            this.QtyPicked = model.QtyPicked;
        }
    }
}
```

## 发步API接口

api接口我们就公开两个
1.前端显示分布数据接口
2.前端数据导出接口

```C#
namespace Giant.Api.Controllers
{
    /// <summary>
    /// 物料汇总报表
    /// </summary>
    public class Rpt_InvSkuController : BaseController
    {
        public IRpt_InvSkuBusiness Bus { get; set; }
        public IServiceProvider SvcProvider { get; set; }
        public Rpt_InvSkuController(IRpt_InvSkuBusiness bus, IServiceProvider svcProvider)
        {
            this.Bus = bus;
            this.SvcProvider = svcProvider;
        }

        /// <summary>
        /// 获取物料汇总数据
        /// </summary>
        /// <param name="query">查询数据</param>
        /// <returns></returns>
        [HttpPost]
        public Task<PageResult<Rpt_InvSkuVM>> GetSummaryAsync(PageInput<Rpt_InvSkuQM> query)
        {
            return this.Bus.GetSummaryAsync(query);
        }

        /// <summary>
        /// 导出库存数据
        /// </summary>
        /// <param name="query">库存查询条件</param>
        /// <returns></returns>
        [HttpPost]
        public async Task<string> ExportAsync(Rpt_InvSkuQM query)
        {
            var data = await this.Bus.GetSummaryAsync(new PageInput<Rpt_InvSkuQM>()
            {
                Search = query,
                PageNo = 1,
                PageSize = 1000,
                SortField = "SkuCode",
                SortOrder = "asc"
            });
            var exportData = data.Data.Select(s => new Rpt_InvSkuIEM(s)).ToList();
            var exportSvc = this.SvcProvider.GetRequiredService<Magicodes.ExporterAndImporter.Core.IExporter>();
            var hostSvc = this.SvcProvider.GetRequiredService<Microsoft.AspNetCore.Hosting.IWebHostEnvironment>();
            var dirPath = Path.Combine(hostSvc.WebRootPath, "Export", "Rpt_InvSku", DateTime.Now.ToString("yyyyMM"));
            if (!Directory.Exists(dirPath))
                Directory.CreateDirectory(dirPath);
            var filePath = Path.Combine(dirPath, $"Rpt_InvSku{DateTime.Now.ToString("yyMMddHHmmss")}.xlsx");
            await exportSvc.Export(filePath, exportData);
            var webPath = filePath.Replace(hostSvc.WebRootPath, "").Replace("\\", "/");
            return webPath;
        }
    }
}
```

## 前端API调用方法

```js
import request from '@/utils/request'
/**
 * Rpt_InvSku API接口服务
 */
export default {
    /**
     * 获取物料汇总数据
     * @param {Object} parameter 查询参数
     * @returns 汇总数据
     */
     GetSummary(parameter) {
        return request({
            url: '/api/Rpt_InvSku/GetSummary',
            method: 'post',
            data: parameter
        })
    },
    /**
     * 导出数据
     * @param {Object} query 查询条件
     * @returns excel文件地址
     */
    Export(query) {
        return request({
            url: '/api/Rpt_InvSku/Export',
            method: 'post',
            data: query
        })
    }
}
```

## 前端界面

```html
<template>
  <a-card :bordered="false">
    <div class="table-page-search-wrapper">
      <a-form layout="inline">
        <a-row :gutter="48">
          <a-col :md="6" :sm="24">
            <a-form-item label="货主">
              <StorerSelect v-model="queryParam.StorerId" :type="['Storer']"></StorerSelect>
            </a-form-item>
          </a-col>
          <a-col :md="6" :sm="24">
            <a-form-item label="物料">
              <SkuSelect v-model="queryParam.SkuId" :storer="queryParam.StorerId"></SkuSelect>
            </a-form-item>
          </a-col>
          <a-col :md="6" :sm="24">
            <span class="table-page-search-submitButtons">
              <a-button type="primary" v-action:Query @click="()=>{this.$refs.table.refresh()}">查询</a-button>
              <a-button style="margin-left: 8px" @click="resetSearchForm()">重置</a-button>
              <a-button style="margin-left: 8px" v-action:Export icon="export" @click="handleExport()">导出</a-button>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <s-table ref="table" size="default" rowKey="SkuId" :columns="columns" :data="loadData" :rowSelection="rowSelection" showPagination="auto">
    </s-table>
  </a-card>
</template>

<script>
import { mapGetters } from 'vuex'
import moment from 'moment'
import { STable } from '@/components'
import MainSvc from '@/api/Rpt/Rpt_InvSkuSvc'
import EnumSelect from '@/components/CF/EnumSelect'
import EnumName from '@/components/CF/EnumName'
import StorerSelect from '@/components/Bas/StorerSelect'
import SkuSelect from '@/components/Bas/SkuSelect'
import LocSelect from '@/components/Bas/LocSelect'

const columns = [
  { title: '货主编码', dataIndex: 'StorerCode', sorter: true },
  { title: '货主名称', dataIndex: 'StorerName', sorter: true },
  { title: '物料编码', dataIndex: 'SkuCode', sorter: true },
  { title: '物料名称', dataIndex: 'SkuName', sorter: true },
  { title: '库存数量', dataIndex: 'Qty', sorter: true },
  { title: '可用数量', dataIndex: 'QtyUse' },
  { title: '已分配', dataIndex: 'QtyAllocated' },
  { title: '已拣货', dataIndex: 'QtyPicked' }
]

export default {
  components: {
    STable,
    MainSvc,
    EnumSelect,
    EnumName,
    StorerSelect,
    SkuSelect,
    LocSelect
  },
  data() {
    this.columns = columns
    return {
      // create model
      visible: false,
      confirmLoading: false,
      mdl: null,
      // 高级搜索 展开/关闭
      advanced: false,
      // 查询参数
      queryParam: { WhseId: '', StorerId: '', SkuId: '' },
      // 加载数据方法 必须为 Promise 对象
      loadData: parameter => {
        this.queryParam.WhseId = this.defaultWhseId
        var _query = Object.assign({}, { ...this.queryParam })
        for (const key in _query) {
          if (moment.isMoment(_query[key])) {
            _query[key] = _query[key].format('YYYY-MM-DD')
          }
        }
        const requestParameters = Object.assign({ sortField: 'SkuCode', sortOrder: 'asc', Search: _query }, parameter)
        console.log('loadData request parameters:', requestParameters)
        return MainSvc.GetSummary(requestParameters)
      },
      selectedRowKeys: [],
      selectedRows: []
    }
  },
  filters: {
  },
  created() {
    this.resetSearchForm()
  },
  computed: {
    ...mapGetters({
      defaultWhseId: 'whseId',
      defaultStorerId: 'storerId'
    }),
    rowSelection() {
      return {
        selectedRowKeys: this.selectedRowKeys,
        onChange: this.onSelectChange
      }
    }
  },
  methods: {
    moment,
    onSelectChange(selectedRowKeys, selectedRows) {
      this.selectedRowKeys = selectedRowKeys
      this.selectedRows = selectedRows
    },
    resetSearchForm() {
      this.queryParam = { WhseId: this.defaultWhseId, StorerId: this.defaultStorerId, SkuId: '' }
    },
    handleExport() {
      this.queryParam.WhseId = this.defaultWhseId
      var _query = Object.assign({}, { ...this.queryParam })
      for (const key in _query) {
        if (moment.isMoment(_query[key])) {
          _query[key] = _query[key].format('YYYY-MM-DD')
        }
      }
      MainSvc.Export(_query).then(result => {
        if (result.Success) {
          var fileName = result.Data.substring(result.Data.lastIndexOf('/') + 1)
          var filePath = `${process.env.VUE_APP_API_BASE_URL}${result.Data}`
          console.log('handleExport', fileName, filePath)
          try {
            var elem = document.createElement('a')
            elem.download = fileName
            elem.href = filePath
            elem.style.display = 'none'
            document.body.appendChild(elem)
            elem.click()
            document.body.removeChild(elem)
          } catch (e) {
            this.$message.error('下载异常！')
          }
        } else {
          this.$message.error(result.Msg)
        }
      })
    }
  }
}
</script>
```

## 注意事项

1.界面创建好后，要在Sys_Menu创建菜单
2.创建2个操作权限，一个查询，一个导出

```C#
builder.HasData(new Sys_Action() { Id = "50101", MenuId = "501", Name = "查询", Code = "Query", CreateUserId = "1", ModifyUserId = "1" });
builder.HasData(new Sys_Action() { Id = "50102", MenuId = "501", Name = "导出", Code = "Export", CreateUserId = "1", ModifyUserId = "1" });
```

3.给默认角色授权

## 最终效果

![报表开发](3.png)
![报表开发](4.png)