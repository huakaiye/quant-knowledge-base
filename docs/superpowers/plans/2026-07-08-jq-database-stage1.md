# 聚宽数据库重构 · 阶段 1：核心 12 表口径切换 实现计划（A 代码开发部分）

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为阶段 1 的"核心 12 表口径切换"开发全部代码资产——12 张 `jq_v3_*` 新表 DDL、各表的聚宽数据拉取脚本、验证脚本、`data_routing.json` 路由切换脚本，全部 TDD 就绪并提交。代码完成后，数据拉取/验证/切换/回归（B 部分，运行手册见文末）由主控用凭证执行。

**Architecture:** 新表 DDL 严格对齐旧表 DB 物理列名（portal 靠 AS 别名转换，列名不符会 KeyError），追加 `source` 列标记聚宽来源。拉取脚本复用阶段 0 的 `JqFetcher`，按数据类型组织（行情/估值/财务/证券/指数/ST/净值），拉取结果落地 CSV 后用 `stream_import.py` 流式导入（需注册 TABLE_CONFIG）。验证脚本对每张新表查 ClickHouse 核对行数/覆盖/非空率/点对点。路由切换通过改 `data_routing.json` 的 `table` 字段实现（`resolve_table` 热加载），旧表保留 DB 物理表 + 路由归档条目。

**Tech Stack:** Python 3.10+（3.14.4）、pytest、jqdatasdk（阶段 0 的 JqFetcher）、clickhouse-driver（验证脚本直查）、pandas、tqdm

**执行位置：** 平台仓库 `E:\量化平台_V1.4.0`，分支 `feat/jq-database-overhaul`（阶段 0 已在该分支）。测试 `cd src && python -m pytest`。

**规格来源：** `docs/superpowers/specs/2026-07-08-jq-database-overhaul-design.md` §3（阶段 1）。

**关键核实结论（已确认，本计划硬基础）：**
1. **DDL 物理列名陷阱**：balance 用 `goodwill`(非 good_will)/`total_liabilities`(复数)/`total_equity_attr_parent`；fina_indicator 用 `inc_total_revenue_year_on_year`(非 inc_return)；cashflow 无 `subtotal_*` 物理列（portal 计算列）。新表必须沿用旧表物理列名。
2. **st_status 必须无 exchange 列**（3 列：trade_date/symbol/is_st），否则 portal `_symbol_only_clause` 失效。
3. **index_constituent 无 checked-in DDL**，新表 DDL 基于 portal SELECT 列 + import INSERT 列推断（见 Task 1）。
4. **stream_import TABLE_CONFIG**：新表必须注册，含 `columns`（CSV 头顺序=DDL 列顺序）+ `partition_col`。未注册则 `parser.error`。
5. **resolve_table 仅拒绝 status=removed**；legacy/deprecated 仍可读。切换靠改 `table` 字段值，旧表 DB 物理保留。
6. **portal 不 SELECT source 列**，新表加 source 列对 portal 无感（不破坏查询），仅用于行级来源标记。

## Global Constraints

- 新表 DB 物理列名必须逐字段对齐旧表（portal 无感切换的硬约束），聚宽额外数据作为新增列追加。
- `source` 列统一 `DEFAULT 'joinquant_api'`，标记聚宽 API 来源（区别于旧表 xtdata 口径）。
- 拉取脚本复用阶段 0 `JqFetcher`（`from quant_v2.jq_fetcher import JqFetcher, JqCredentials`），凭证通过环境变量/文件（绝不入库/不打印）。
- 分钟线全量拉取用**流式写 CSV**（按月分文件），不用 `fetch_panel` 的内存返回模式（防 OOM，最终审查 O-1）。
- 测试风格：pytest 纯函数式，手写 Fake 类注入，裸 assert，`cd src && python -m pytest`。
- 文档字符串简短中文，`from __future__ import annotations`，PEP 604 联合类型。
- 提交说明中文。提交只 add 显式文件（平台仓库有大量未跟踪遗留）。

## 文件结构

| 文件 | 职责 | 任务 |
| --- | --- | --- |
| `scripts/jq_v3/schema_v3.sql` | 12 张 jq_v3_* 新表 DDL | Task 1 |
| `scripts/jq_v3/__init__.py` | 包标记（空） | Task 1 |
| `scripts/jq_v3/common.py` | 拉取脚本公共工具（CSV writer、标的清单、聚宽代码转换） | Task 2 |
| `scripts/jq_v3/fetch_static.py` | 静态表拉取：trade_days、stock_info+industry、index_constituent | Task 3 |
| `scripts/jq_v3/fetch_valuation_financials.py` | 估值 + 四大财务表拉取（按月/按报告期分段） | Task 4 |
| `scripts/jq_v3/fetch_bars.py` | 日线 + 分钟线拉取（分钟线流式按月写 CSV） | Task 5 |
| `scripts/jq_v3/fetch_st_fundnav.py` | ST 状态 + 基金净值拉取 | Task 6 |
| `scripts/jq_v3/validate_v3.py` | 12 表验证脚本（行数/覆盖/非空率/点对点） | Task 7 |
| `scripts/jq_v3/switch_routing.py` | data_routing.json 路由切换脚本（含备份+回滚） | Task 8 |
| `src/tests/scripts/jq_v3/test_common.py` | 公共工具测试 | Task 2 |
| `src/tests/scripts/jq_v3/test_validate.py` | 验证脚本逻辑测试（注入 fake pool） | Task 7 |
| `src/tests/scripts/jq_v3/test_switch_routing.py` | 路由切换逻辑测试（注入 fake json） | Task 8 |
| `scripts/stream_import.py`（修改） | TABLE_CONFIG 注册 12 张 v3 表 | Task 1 |

---

## Task 1: 新表 DDL + stream_import 注册

创建 12 张 `jq_v3_*` 新表的 DDL 文件，并在 `stream_import.py` 注册 TABLE_CONFIG。这是所有后续拉取/导入的基础。

**Files:**
- Create: `E:\量化平台_V1.4.0\scripts\jq_v3\__init__.py`（空）
- Create: `E:\量化平台_V1.4.0\scripts\jq_v3\schema_v3.sql`
- Modify: `E:\量化平台_V1.4.0\scripts\stream_import.py`（TABLE_CONFIG 追加 12 条）
- Test: 通过 `clickhouse-client < schema_v3.sql` 建表后 `SHOW TABLES` 验证（本任务不写 pytest，建表是 SQL 操作；列名正确性由 Task 7 验证脚本 + 回归测试兜底）

**Interfaces:**
- Produces: 12 张新表（`jq_v3_bar_daily`, `jq_v3_bar_minute`, `jq_v3_valuation`, `jq_v3_fina_indicator`, `jq_v3_balance`, `jq_v3_income`, `jq_v3_cashflow`, `jq_v3_stock_info`, `jq_v3_trade_days`, `jq_v3_st_status`, `index_constituent_v3`, `jq_v3_fund_net_value`），列名对齐旧表 + source 列
- 供 Task 3-6 拉取脚本消费（作为写入目标），Task 7 验证脚本消费（作为验证对象），Task 8 路由切换消费（作为切换目标）

- [ ] **Step 1: 创建 jq_v3 包**

`scripts/jq_v3/__init__.py`（空文件）。

- [ ] **Step 2: 编写 schema_v3.sql**

`scripts/jq_v3/schema_v3.sql`——12 张表，每张对齐旧表物理列 + 追加 `source LowCardinality(String) DEFAULT 'joinquant_api'`。引擎/分区/ORDER BY 对齐旧表（见规格附录 A + 核实结论）。完整 DDL（逐字，注意物理列名陷阱）：

```sql
-- ============================================================
-- 聚宽数据库重构 阶段1：12 张 jq_v3_* 新表（聚宽原生口径）
-- 对齐旧表 DB 物理列名（portal 靠 AS 别名转换），追加 source 列
-- 建表：clickhouse-client --database quant < scripts/jq_v3/schema_v3.sql
-- ============================================================

-- 1. 日线（对齐 jq_bar_daily，factor 必填，wufu 依赖 use_real_price 还原）
CREATE TABLE IF NOT EXISTS quant.jq_v3_bar_daily
(
    symbol       LowCardinality(String),
    exchange     LowCardinality(String),
    datetime     Date,
    open_price   Decimal(18, 4),
    high_price   Decimal(18, 4),
    low_price    Decimal(18, 4),
    close_price  Decimal(18, 4),
    volume       UInt64,
    turnover     Decimal(18, 4),
    pre_close    Nullable(Decimal(18, 4)),
    limit_up     Nullable(Decimal(18, 4)),
    limit_down   Nullable(Decimal(18, 4)),
    paused       UInt8 DEFAULT 0,
    factor       Nullable(Decimal(18, 6)),
    adj_type     LowCardinality(String) DEFAULT 'pre',
    source       LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = ReplacingMergeTree
PARTITION BY toYear(datetime)
ORDER BY (symbol, exchange, datetime)
SETTINGS index_granularity = 8192;


-- 2. 分钟线（对齐 jq_bar_minute_v2，按月分区匹配 _real 表策略）
CREATE TABLE IF NOT EXISTS quant.jq_v3_bar_minute
(
    symbol       LowCardinality(String),
    exchange     LowCardinality(String),
    datetime     DateTime64(3),
    open_price   Decimal(18, 4),
    high_price   Decimal(18, 4),
    low_price    Decimal(18, 4),
    close_price  Decimal(18, 4),
    volume       UInt64,
    turnover     Decimal(18, 4),
    pre_close    Nullable(Decimal(18, 4)),
    limit_up     Nullable(Decimal(18, 4)),
    limit_down   Nullable(Decimal(18, 4)),
    paused       UInt8 DEFAULT 0,
    factor       Nullable(Decimal(18, 6)),
    adj_type     LowCardinality(String) DEFAULT 'pre',
    source       LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMM(datetime)
ORDER BY (symbol, exchange, datetime)
SETTINGS index_granularity = 8192;


-- 3. 估值（对齐 jq_valuation，PE/PB/PS 补齐 xtdata 空值）
CREATE TABLE IF NOT EXISTS quant.jq_v3_valuation
(
    symbol                   LowCardinality(String),
    exchange                 LowCardinality(String),
    datetime                 Date,
    market_cap               Nullable(Decimal(24, 4)),
    circulating_market_cap   Nullable(Decimal(24, 4)),
    pe_ratio                 Nullable(Decimal(18, 4)),
    pe_ratio_lyr             Nullable(Decimal(18, 4)),
    pb_ratio                 Nullable(Decimal(18, 4)),
    ps_ratio                 Nullable(Decimal(18, 4)),
    pcf_ratio                Nullable(Decimal(18, 4)),
    turnover_ratio           Nullable(Decimal(18, 4)),
    capitalization           Nullable(Decimal(24, 4)),
    circulating_cap          Nullable(Decimal(24, 4)),
    source                   LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = ReplacingMergeTree
PARTITION BY toYear(datetime)
ORDER BY (symbol, exchange, datetime)
SETTINGS index_granularity = 8192;


-- 4. 财务指标（对齐 jq_fina_indicator，物理列名 inc_total_revenue_year_on_year 非 inc_return）
CREATE TABLE IF NOT EXISTS quant.jq_v3_fina_indicator
(
    symbol              LowCardinality(String),
    exchange            LowCardinality(String),
    end_date            Date,
    ann_date            Nullable(Date),
    report_type         LowCardinality(Nullable(String)),
    eps                 Nullable(Float64),
    adjusted_profit     Nullable(Float64),
    bps                 Nullable(Float64),
    ocfps               Nullable(Float64),
    roe                 Nullable(Float64),
    roa                 Nullable(Float64),
    roic                Nullable(Float64),
    gross_profit_margin Nullable(Float64),
    net_profit_margin   Nullable(Float64),
    inc_total_revenue_year_on_year    Nullable(Float64),
    inc_net_profit_year_on_year       Nullable(Float64),
    inc_net_profit_quarter_on_quarter Nullable(Float64),
    current_ratio       Nullable(Float64),
    quick_ratio         Nullable(Float64),
    debt_to_assets      Nullable(Float64),
    assets_turn         Nullable(Float64),
    inventory_turnover  Nullable(Float64),
    receivable_turnover Nullable(Float64),
    operating_profit                    Nullable(Float64),
    inc_net_profit_annual               Nullable(Float64),
    ocf_to_operating_profit             Nullable(Float64),
    inc_operation_profit_year_on_year   Nullable(Float64),
    source                              LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = ReplacingMergeTree
PARTITION BY toYear(end_date)
ORDER BY (symbol, exchange, end_date)
SETTINGS index_granularity = 8192;


-- 5. 资产负债表（对齐 jq_balance，物理列名 goodwill/total_liabilities(复数)/total_equity_attr_parent）
CREATE TABLE IF NOT EXISTS quant.jq_v3_balance
(
    symbol                    LowCardinality(String),
    exchange                  LowCardinality(String),
    end_date                  Date,
    ann_date                  Nullable(Date),
    report_type               LowCardinality(Nullable(String)),
    total_assets              Nullable(Float64),
    total_current_assets      Nullable(Float64),
    total_non_current_assets  Nullable(Float64),
    cash_equivalents          Nullable(Float64),
    total_liabilities         Nullable(Float64),
    total_current_liabilities Nullable(Float64),
    total_non_current_liabilities Nullable(Float64),
    total_equity              Nullable(Float64),
    total_equity_attr_parent  Nullable(Float64),
    total_share               Nullable(Float64),
    goodwill                  Nullable(Float64),
    inventaries              Nullable(Float64),
    fixed_assets             Nullable(Float64),
    intangible_assets        Nullable(Float64),
    shortterm_loan           Nullable(Float64),
    longterm_loan            Nullable(Float64),
    retained_profit          Nullable(Float64),
    source                   LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = ReplacingMergeTree
PARTITION BY toYear(end_date)
ORDER BY (symbol, exchange, end_date)
SETTINGS index_granularity = 8192;

-- 注：旧表 jq_balance 物理列名是 inventories（非 inventaries），核对后用旧表实际列名。
-- 实装时先 SHOW CREATE TABLE jq_balance 确认每个列名，再逐字对齐。


-- 6. 利润表（对齐 jq_income）
CREATE TABLE IF NOT EXISTS quant.jq_v3_income
(
    symbol              LowCardinality(String),
    exchange            LowCardinality(String),
    end_date            Date,
    ann_date            Nullable(Date),
    report_type         LowCardinality(Nullable(String)),
    total_operating_revenue     Nullable(Float64),
    operating_revenue           Nullable(Float64),
    total_operating_cost        Nullable(Float64),
    operating_cost              Nullable(Float64),
    selling_expense             Nullable(Float64),
    administrative_expense      Nullable(Float64),
    financial_expense           Nullable(Float64),
    operating_profit            Nullable(Float64),
    total_profit                Nullable(Float64),
    net_profit                  Nullable(Float64),
    net_profit_attr_parent      Nullable(Float64),
    ebit                        Nullable(Float64),
    ebitda                      Nullable(Float64),
    basic_eps               Nullable(Float64),
    diluted_eps             Nullable(Float64),
    investment_income       Nullable(Float64),
    rd_expenses             Nullable(Float64),
    source                  LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = ReplacingMergeTree
PARTITION BY toYear(end_date)
ORDER BY (symbol, exchange, end_date)
SETTINGS index_granularity = 8192;


-- 7. 现金流量表（对齐 jq_cashflow，无 subtotal_* 物理列）
CREATE TABLE IF NOT EXISTS quant.jq_v3_cashflow
(
    symbol                    LowCardinality(String),
    exchange                  LowCardinality(String),
    end_date                  Date,
    ann_date                  Nullable(Date),
    report_type               LowCardinality(Nullable(String)),
    net_operate_cashflow      Nullable(Float64),
    net_profit                Nullable(Float64),
    net_invest_cashflow       Nullable(Float64),
    net_finance_cashflow      Nullable(Float64),
    net_cash_increase         Nullable(Float64),
    cash_equivalents_end      Nullable(Float64),
    free_cashflow             Nullable(Float64),
    goods_sale_and_service_render_cash   Nullable(Float64),
    fix_intan_other_asset_acqui_cash     Nullable(Float64),
    source                   LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = ReplacingMergeTree
PARTITION BY toYear(end_date)
ORDER BY (symbol, exchange, end_date)
SETTINGS index_granularity = 8192;


-- 8. 证券主数据（对齐 jq_stock_info，行业分类补齐 xtdata None 值）
CREATE TABLE IF NOT EXISTS quant.jq_v3_stock_info
(
    symbol       LowCardinality(String),
    exchange     LowCardinality(String),
    display_name String,
    name         String,
    start_date   Nullable(Date),
    end_date     Nullable(Date),
    type         LowCardinality(String),
    sw_l1        Nullable(String),
    sw_l2        Nullable(String),
    sw_l3        Nullable(String),
    jq_l1        Nullable(String),
    jq_l2        Nullable(String),
    zjw          Nullable(String),
    source       LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = ReplacingMergeTree
ORDER BY (symbol, exchange)
SETTINGS index_granularity = 8192;


-- 9. 交易日历（对齐 jq_trade_days，MergeTree）
CREATE TABLE IF NOT EXISTS quant.jq_v3_trade_days
(
    trade_date   Date
) ENGINE = MergeTree
ORDER BY trade_date
SETTINGS index_granularity = 8192;


-- 10. ST 状态（对齐 jq_st_status，无 exchange 列！3 列）
CREATE TABLE IF NOT EXISTS quant.jq_v3_st_status
(
    trade_date   Date,
    symbol       LowCardinality(String),
    is_st        UInt8,
    source       LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = MergeTree
PARTITION BY toYYYYMM(trade_date)
ORDER BY (trade_date, symbol)
SETTINGS index_granularity = 8192;


-- 11. 指数成分（基于 portal SELECT + import INSERT 推断，constituent 非补零存储）
CREATE TABLE IF NOT EXISTS quant.index_constituent_v3
(
    index_symbol     LowCardinality(String),
    index_exchange   LowCardinality(String),
    effective_date   Date,
    constituent      LowCardinality(String),
    constituent_exch LowCardinality(String),
    weight           Nullable(Float64),
    status           LowCardinality(String) DEFAULT 'active',
    source           LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = ReplacingMergeTree
PARTITION BY toYear(effective_date)
ORDER BY (index_symbol, index_exchange, effective_date, constituent, constituent_exch)
SETTINGS index_granularity = 8192;


-- 12. 基金净值（对齐 jq_fund_net_value，MergeTree，refactor_net_value 非 refactored）
CREATE TABLE IF NOT EXISTS quant.jq_v3_fund_net_value
(
    symbol            String,
    exchange          String,
    code              String,
    day               Date,
    ann_date          Date,
    net_value         Float64,
    sum_value         Float64,
    refactor_net_value Float64,
    source            LowCardinality(String) DEFAULT 'joinquant_api'
) ENGINE = MergeTree
PARTITION BY toYYYYMM(day)
ORDER BY (symbol, exchange, day)
SETTINGS index_granularity = 8192;
```

**实装前必须做的核对（Task 1 执行者首步）：**
1. 对每张旧表运行 `SHOW CREATE TABLE quant.<旧表名>`（如 `SHOW CREATE TABLE quant.jq_balance`），取真实 DDL。
2. 逐列比对上面的 schema_v3.sql，**确保每列名、类型、Nullable 与旧表完全一致**（尤其 balance 的 `inventories` 拼写、各表 report_type 是否存在）。规格/计划的列名是基于 jq_schema.sql 的，但 DB 实际可能有过 ALTER，以 `SHOW CREATE` 为准。
3. v3 表 = 旧表全部列 + `source` 列（DEFAULT 'joinquant_api'）。

- [ ] **Step 3: 注册 stream_import TABLE_CONFIG**

读 `scripts/stream_import.py` 的 `TABLE_CONFIG`（约 L41-173）。为 12 张 v3 表各加一条注册，格式对齐现有条目。每条含：
- `"columns"`：列表，顺序与 DDL 列顺序完全一致（CSVWithNames 头）
- `"partition_col"`：对应分区列（datetime/end_date/day/trade_date/effective_date）或 None（stock_info/trade_days 无断点续传分区）

示例（jq_v3_bar_daily）：
```python
"jq_v3_bar_daily": {
    "columns": ["symbol", "exchange", "datetime", "open_price", "high_price",
                "low_price", "close_price", "volume", "turnover", "pre_close",
                "limit_up", "limit_down", "paused", "factor", "adj_type", "source"],
    "partition_col": "datetime",
},
```

12 张表全部注册（含无 partition_col 的设 None）。参考现有 `jq_bar_daily`/`jq_valuation` 等条目的格式。

- [ ] **Step 4: 验证 stream_import 能识别新表**

```bash
cd "E:/量化平台_V1.4.0"
.venv/Scripts/python scripts/stream_import.py --list-tables
```

Expected: 输出含 12 张 `jq_v3_*` / `index_constituent_v3` 表名。

- [ ] **Step 5: 建表并验证**

```bash
cd "E:/量化平台_V1.4.0"
clickhouse-client --database quant < scripts/jq_v3/schema_v3.sql
clickhouse-client --query "SHOW TABLES FROM quant LIKE 'jq_v3_%'"
clickhouse-client --query "SHOW TABLES FROM quant LIKE 'index_constituent_v3'"
```

Expected: 12 张表全部列出。若 clickhouse-client 不在 PATH，用 `wsl clickhouse-client` 或平台文档指定的连接方式（参考 `scripts/jq_schema.sql` 顶部注释的运行方式）。

- [ ] **Step 6: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add scripts/jq_v3/__init__.py scripts/jq_v3/schema_v3.sql scripts/stream_import.py
git commit -m "feat(jq_v3): 12张聚宽原生表DDL+stream_import注册(Task 1)

- jq_v3_bar_daily/minute/valuation/fina_indicator/balance/income/cashflow
- jq_v3_stock_info/trade_days/st_status + index_constituent_v3 + jq_v3_fund_net_value
- 物理列名对齐旧表(portal无感切换), 追加source列标记聚宽来源
- stream_import TABLE_CONFIG 注册12表(columns+partition_col)"
```

---

## Task 2: 拉取脚本公共工具

实现拉取脚本共用的工具函数：聚宽代码↔(symbol,exchange)转换、标的清单加载、流式 CSV writer。这是 Task 3-6 的依赖。

**Files:**
- Create: `E:\量化平台_V1.4.0\scripts\jq_v3\common.py`
- Create: `E:\量化平台_V1.4.0\src\tests\scripts\jq_v3\__init__.py`（空）
- Create: `E:\量化平台_V1.4.0\src\tests\scripts\jq_v3\test_common.py`

**Interfaces:**
- Produces（`common.py`）：
  - `jq_code_to_symbol_exchange(code: str) -> tuple[str, str]` —— '000001.XSHE'→('000001','SZ')；'510300.XSHG'→('510300','SH')；'.XBJE'→'BJ'
  - `symbol_exchange_to_jq_code(symbol: str, exchange: str) -> str` —— 反向
  - `load_security_list(fetcher, types: list[str]) -> list[str]` —— 用 fetcher 拉 get_all_securities 取标的代码清单
  - `class StreamingCsvWriter` —— 流式写 CSV（按行 flush，支持按月份/批次切分文件），构造 `StreamingCsvWriter(output_dir, base_name, header, rows_per_file=200000)`
  - `safe_num(v, ndigits=4)` / `safe_float(v)` —— NaN/None→空串，参考 jq_export.py 的 `_safe_num`

- [ ] **Step 1: 写失败测试 test_common.py**

`src/tests/scripts/jq_v3/test_common.py`：

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""jq_v3 拉取脚本公共工具测试。"""
from __future__ import annotations

import csv
from pathlib import Path

from jq_v3 import common


def test_jq_code_to_symbol_exchange_xshe():
    assert common.jq_code_to_symbol_exchange("000001.XSHE") == ("000001", "SZ")
    assert common.jq_code_to_symbol_exchange("159915.XSHE") == ("159915", "SZ")


def test_jq_code_to_symbol_exchange_xshg():
    assert common.jq_code_to_symbol_exchange("510300.XSHG") == ("510300", "SH")
    assert common.jq_code_to_symbol_exchange("600519.XSHG") == ("600519", "SH")


def test_jq_code_to_symbol_exchange_xbje():
    assert common.jq_code_to_symbol_exchange("430047.XBJE") == ("430047", "BJ")


def test_symbol_exchange_to_jq_code_roundtrip():
    assert common.symbol_exchange_to_jq_code("000001", "SZ") == "000001.XSHE"
    assert common.symbol_exchange_to_jq_code("510300", "SH") == "510300.XSHG"
    assert common.symbol_exchange_to_jq_code("430047", "BJ") == "430047.XBJE"


def test_safe_num_handles_nan_and_none():
    assert common.safe_num(float("nan")) == ""
    assert common.safe_num(None) == ""
    assert common.safe_num(10.5, 4) == "10.5"
    assert common.safe_num(10.123456, 4) == "10.1235"


def test_streaming_csv_writer_creates_file(tmp_path):
    writer = common.StreamingCsvWriter(
        tmp_path, "test_data", ["code", "date", "close"], rows_per_file=2
    )
    writer.writerow({"code": "000001", "date": "2024-01-01", "close": "10.5"})
    writer.writerow({"code": "000001", "date": "2024-01-02", "close": "10.6"})
    writer.writerow({"code": "000001", "date": "2024-01-03", "close": "10.7"})
    writer.close()
    files = sorted(tmp_path.glob("test_data_*.csv"))
    assert len(files) == 2  # rows_per_file=2 → 3 行分 2 文件
    with open(files[0], encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    assert len(rows) == 2
    assert rows[0]["close"] == "10.5"


def test_streaming_csv_writer_flushes_on_close(tmp_path):
    """不足 rows_per_file 的最后一批在 close() 时落盘。"""
    writer = common.StreamingCsvWriter(
        tmp_path, "partial", ["a", "b"], rows_per_file=100
    )
    writer.writerow({"a": "1", "b": "2"})
    writer.close()
    files = list(tmp_path.glob("partial_*.csv"))
    assert len(files) == 1
```

- [ ] **Step 2: 运行测试确认失败**

```bash
cd "E:/量化平台_V1.4.0/src"
.venv/Scripts/python -m pytest tests/scripts/jq_v3/test_common.py -v
```

Expected: FAIL，`ModuleNotFoundError: No module named 'jq_v3'`。注意：`jq_v3` 包在 `scripts/` 下，测试要能 import 需确保 `scripts/` 在 sys.path——测试文件顶部可能需 `import sys; sys.path.insert(0, str(Path(__file__).resolve().parents[4] / "scripts"))` 或 conftest.py 配置。参考现有 `scripts/` 下测试如何被 import 的（如 `src/tests/scripts/` 已有结构）。实装时先确认 import 路径机制。

- [ ] **Step 3: 实现 common.py**

`scripts/jq_v3/common.py`：实现上述接口。参考 `scripts/jq_export.py` 的 `symbol_to_exchange`（L69-81）和 `_safe_num`/`_safe_float`（L488-496）的成熟逻辑，逐字复用。StreamingCsvWriter 用 csv.DictWriter + 每 rows_per_file 行切文件 + close 时 flush 剩余。

- [ ] **Step 4: 运行测试确认通过**

Expected: 7 测试全通过。

- [ ] **Step 5: 提交**

```bash
git add scripts/jq_v3/common.py src/tests/scripts/jq_v3/__init__.py src/tests/scripts/jq_v3/test_common.py
git commit -m "feat(jq_v3): 拉取脚本公共工具(Task 2)

- jq_code↔symbol_exchange转换(XSHE/XSHG/XBJE)
- StreamingCsvWriter流式CSV(按行数切文件, 防OOM)
- safe_num/safe_float(NaN/None→空串)
- load_security_list标的清单加载"
```

---

## Task 3: 静态表拉取脚本（trade_days、stock_info、index_constituent）

拉取三个变化频率低的表：交易日历、证券主数据（含行业）、指数成分。这些表数据量小、查询简单，适合先跑通验证管线。

**Files:**
- Create: `E:\量化平台_V1.4.0\scripts\jq_v3\fetch_static.py`

**功能：**
- `fetch_trade_days(fetcher, start, end) -> Path`：调 `get_trade_days`，写 CSV（单列 trade_date）
- `fetch_stock_info(fetcher, types=['stock','fund','index']) -> Path`：调 `get_all_securities` + 对每标的 `get_industry(date)` 取多级行业（sw_l1/l2/l3/jq_l1/l2/zjw），写 CSV
- `fetch_index_constituent(fetcher, index_list, date) -> Path`：调 `get_index_stocks` + `get_index_weights`，写 CSV（constituent 非补零）

每个函数返回写入的 CSV 路径，供后续 `stream_import` 导入。用 `JqFetcher.fetch_panel` 循环标的（stock_info 的行业查询按标的循环）。

**关键：** 本任务无新增 pytest。测试边界说明：拉取脚本的纯逻辑部分（代码转换、CSV 写、字段映射函数）已由 Task 2 的 common.py 测试覆盖；API 调用部分（get_all_securities/get_industry/get_index_stocks 的实际请求）强依赖真实 jqdatasdk 凭证，无法离线测试，其正确性由 Task 7 验证脚本（点对点核对 + 行数 + 非空率）在 B 部分数据执行时兜底验证。这是数据获取脚本的合理测试取舍——不测网络 IO，测数据处理逻辑。实装时参考 `scripts/jq_export.py` 的对应函数（get_all_securities L143/822、get_industry 模式）。

- [ ] **Step 1: 实现 fetch_static.py**

实现三个函数，用 common.py 的工具 + JqFetcher。每个函数：
1. 用 JqFetcher 认证（main 函数统一认证，fetch 函数接收已认证的 fetcher/api）
2. 拉取数据 → StreamingCsvWriter 写 CSV 到 `tmp/jq_v3_export/<table>/`
3. 返回 CSV 目录路径

main() 提供 CLI 入口（argparse 选择 --table trade_days/stock_info/index_constituent/all）。

- [ ] **Step 2: py_compile 验证**

```bash
.venv/Scripts/python -m py_compile scripts/jq_v3/fetch_static.py
```

Expected: 无输出。

- [ ] **Step 3: 提交**

```bash
git add scripts/jq_v3/fetch_static.py
git commit -m "feat(jq_v3): 静态表拉取脚本(Task 3)

- fetch_trade_days: 交易日历
- fetch_stock_info: 证券主数据+多级行业(sw/jq/zjw)
- fetch_index_constituent: 指数成分+权重
- 输出CSV到tmp/jq_v3_export/, 供stream_import导入"
```

---

## Task 4: 估值 + 四大财务表拉取脚本

拉取估值表（按月分段，batch=200）和四大财务表（按报告期，batch=500）。这是 PE/PB/PS 补齐 + 聚宽原生财务字段的核心。

**Files:**
- Create: `E:\量化平台_V1.4.0\scripts\jq_v3\fetch_valuation_financials.py`

**功能：**
- `fetch_valuation(fetcher, start, end) -> Path`：按月循环 + batch=200，调 `get_valuation`，字段映射聚宽→DB 列（market_cap/circulating_market_cap/pe_ratio/pe_ratio_lyr/pb_ratio/ps_ratio/pcf_ratio/turnover_ratio/capitalization/circulating_cap）。参考 jq_export.py L436-438 + L373-484。
- `fetch_financials(fetcher, table, start_year, end_year) -> Path`：table ∈ {indicator/balance/income/cash_flow}，按报告期循环（每年 q1-q4，末年只到当前季度），batch=500，调 `get_fundamentals(query(...), statDate=period)`。**字段名映射陷阱**：聚宽用 `good_will`/`total_liability`(单数)/`equities_parent_company_owners`，DB 物理列是 `goodwill`/`total_liabilities`(复数)/`total_equity_attr_parent`——CSV header 用 DB 物理列名，取值时用聚宽字段名 `row.get('good_will')`。参考 jq_export.py L558-805。

参考 jq_export.py 的成熟分段逻辑（按月/按报告期 + batch + NaN→空串）。

- [ ] **Step 1-3: 实现 + py_compile + 提交**（同 Task 3 模式）

提交信息：`feat(jq_v3): 估值+四大财务表拉取脚本(Task 4)`

---

## Task 5: 日线 + 分钟线拉取脚本（含流式写）

拉取日线（batch=500）和分钟线（流式按月写，防 OOM）。分钟线是工期大头（1.7 天）。

**Files:**
- Create: `E:\量化平台_V1.4.0\scripts\jq_v3\fetch_bars.py`

**功能：**
- `fetch_daily_bars(fetcher, security_list, start, end) -> Path`：用 JqFetcher.fetch_price（batch=500，fq='pre'，fields=ALL_FIELDS），结果写 CSV。字段映射：open→open_price, close→close_price, high→high_price, low→low_price, volume→volume, money→turnover, pre_close→pre_close, high_limit→limit_up, low_limit→limit_down, paused→paused, factor→factor。CSV header 用 DB 物理列名。
- `fetch_minute_bars(fetcher, security_list, start, end) -> Path`：**关键：流式写**。不用 fetch_panel 的内存返回。实现：对每个标的 × 每个月，调 `api.get_price(security, start_date=月首, end_date=月末, frequency='minute', ...)`，结果直接 StreamingCsvWriter 写入（每标每月 flush），不累积到内存。用 checkpoint 记录已完成（标的,月份）对，断点续传。参考 jq_export.py 的分钟线按月分段逻辑。

**分钟线流式写要点（防 OOM）：**
```python
def fetch_minute_bars_streaming(fetcher, securities, start, end, task_name="minute_v3"):
    """分钟线流式拉取：按(标的,月份)循环，每批直接写CSV，不累积内存。"""
    cp = Checkpoint(task_name, fetcher._checkpoint_dir)
    months = generate_month_range(start, end)  # ['2014-01','2014-02',...]
    items = [(sec, month) for sec in securities for month in months]
    cp.set_total(len(items))
    writer = StreamingCsvWriter(output_dir, "jq_v3_bar_minute", MINUTE_COLUMNS, rows_per_file=500000)
    api = fetcher._get_api()
    pending = [it for it in items if not cp.is_completed(f"{it[0]}|{it[1]}")]
    # 并发拉取（max_workers=4），每完成一个(标的,月份)就写CSV+mark_completed
    with ThreadPoolExecutor(max_workers=fetcher._max_workers) as pool:
        futures = {pool.submit(_fetch_one_month, api, sec, month): (sec,month) for sec,month in pending}
        for future in as_completed(futures):
            sec, month = futures[future]
            df = future.result()  # 单标的单月 DataFrame（~4800行，内存安全）
            if df is not None and len(df) > 0:
                writer.write_rows(df_to_csv_rows(df))
            cp.mark_completed(f"{sec}|{month}")
    writer.close()
    cp.save()
```

- [ ] **Step 1-3: 实现 + py_compile + 提交**

提交信息：`feat(jq_v3): 日线+分钟线拉取脚本(Task 5, 分钟线流式写防OOM)`

---

## Task 6: ST 状态 + 基金净值拉取脚本

**Files:**
- Create: `E:\量化平台_V1.4.0\scripts\jq_v3\fetch_st_fundnav.py`

**功能：**
- `fetch_st_status(fetcher, security_list, start, end) -> Path`：调 `get_extras('is_st', securities, start, end)`，展开为 (trade_date, symbol, is_st) 长表写 CSV。**注意无 exchange 列**（仅 symbol）。
- `fetch_fund_net_value(fetcher, fund_list, start, end) -> Path`：调 `finance.run_query(query(finance.FUND_NET_VALUE).filter(...))`，字段映射 code→symbol/exchange, day, net_value, sum_value(acc), refactor_net_value(adj)。参考 jq_fund_net_value.sql DDL。

- [ ] **Step 1-3: 实现 + py_compile + 提交**

提交信息：`feat(jq_v3): ST状态+基金净值拉取脚本(Task 6)`

---

## Task 7: 验证脚本

验证 12 张新表的数据质量：行数合理性、覆盖完整性、字段非空率、点对点核对、与旧表差异量化。

**Files:**
- Create: `E:\量化平台_V1.4.0\scripts\jq_v3\validate_v3.py`
- Create: `E:\量化平台_V1.4.0\src\tests\scripts\jq_v3\test_validate.py`

**Interfaces:**
- Produces: `validate_table(table_name, pool) -> dict` 返回验证结果；`run_all_validations(pool) -> dict` 聚合 12 表

**功能（注入 ClickHousePool 可测试）：**
- `validate_row_count(table, pool) -> dict`：count(*) 与预期标的×交易日/报告期比对
- `validate_coverage(table, symbol_samples, pool) -> dict`：抽样 20 标的，检查时间跨度无大段缺失
- `validate_non_null_rate(table, pool) -> dict`：估值 PE/PB/PS 非空率、stock_info 行业非空率
- `validate_point_check(table, fetcher, samples, pool) -> dict`：抽样 5 标的×5 日期，新表值 = jqdatasdk 实时查值
- `validate_diff_vs_old(table, pool) -> dict`：对比 v3 vs 旧 jq_* 关键字段差异率（记录差异，正是修复目标）

- [ ] **Step 1: 写失败测试 test_validate.py**

注入 FakePool（手写，返回预设行数/非空统计），测试各 validate 函数返回符合预期的 dict（含 pass/warn/fail 判定）。

- [ ] **Step 2-4: 实现 + 测试通过 + 提交**

提交信息：`feat(jq_v3): 12表验证脚本(Task 7, 注入pool可测试)`

---

## Task 8: 路由切换脚本

切换 `data_routing.json`：12 个路由的 table 字段指向 v3 表，旧表保留 DB 物理表 + 路由归档条目（status=legacy）。含备份和回滚。

**Files:**
- Create: `E:\量化平台_V1.4.0\scripts\jq_v3\switch_routing.py`
- Create: `E:\量化平台_V1.4.0\src\tests\scripts\jq_v3\test_switch_routing.py`

**功能：**
- `backup_routing(routing_path) -> Path`：复制 data_routing.json 为 `.backup.<timestamp>`
- `switch_to_v3(routing_path) -> None`：读 JSON，12 个路由的 table 改为 v3 表名，provider 改为 "jq_api"，旧条目移到 `_legacy_xtdata_*` 前缀 + status=legacy。写回 JSON。
- `rollback(routing_path, backup_path) -> None`：从备份恢复
- `verify_switch(routing_path) -> dict`：验证 12 个路由都指向 v3 表，resolve_table 能解析

切换映射表（data_type → 新 v3 表）：
| data_type | 旧表 | 新表 |
| --- | --- | --- |
| daily_bar | jq_bar_daily | jq_v3_bar_daily |
| minute_bar | jq_bar_minute_v2 | jq_v3_bar_minute |
| fundamentals | jq_valuation | jq_v3_valuation |
| financials, indicators | jq_fina_indicator | jq_v3_fina_indicator |
| income | jq_income | jq_v3_income |
| balancesheet | jq_balance | jq_v3_balance |
| cashflow | jq_cashflow | jq_v3_cashflow |
| symbols | jq_stock_info | jq_v3_stock_info |
| trade_days | jq_trade_days | jq_v3_trade_days |
| st_status | jq_st_status | jq_v3_st_status |
| index_constituent | index_constituent | index_constituent_v3 |
| fund_net_value | jq_fund_net_value | jq_v3_fund_net_value |

注意 `financials` 和 `indicators` 都指向同一张 `jq_v3_fina_indicator`（保持旧的双路由别名）。

- [ ] **Step 1: 写失败测试 test_switch_routing.py**

用 tmp_path + 伪造的 data_routing.json，测试 backup/switch/rollback/verify 的正确性。验证切换后 12 路由指向 v3，旧表条目移到 _legacy_ 前缀。

- [ ] **Step 2-4: 实现 + 测试通过 + 提交**

提交信息：`feat(jq_v3): 路由切换脚本(Task 8, 含备份+回滚+12路由切换)`

---

## 阶段 1 代码开发完成标准

| # | 标准 | 验证 |
| --- | --- | --- |
| 1 | 12 张 v3 表 DDL 建表成功 | SHOW TABLES |
| 2 | stream_import 注册 12 表 | --list-tables |
| 3 | 6 个拉取脚本 py_compile 通过 | py_compile |
| 4 | common/validate/switch_routing 单元测试通过 | pytest |
| 5 | 全部提交到 feat/jq-database-overhaul | git log |

代码完成后，进入 **B 部分：数据执行运行手册**（由主控用凭证执行，非子代理 TDD）。

---

## B 部分：数据执行运行手册（主控执行，非 TDD 任务）

代码全部就绪后，按以下顺序执行（每步是一个长时间运行的命令，主控用真实凭证执行）：

### B1. 拉取数据（约 1.7 天，分钟线是大头）

```bash
cd "E:/量化平台_V1.4.0"
export JQ_USERNAME="..." && export JQ_PASSWORD="..."
# 1. 静态表（分钟级）

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
.venv/Scripts/python scripts/jq_v3/fetch_static.py --table all
# 2. 估值+财务（数小时）

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
.venv/Scripts/python scripts/jq_v3/fetch_valuation_financials.py --all --start-year 2005
# 3. 日线（数小时）

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
.venv/Scripts/python scripts/jq_v3/fetch_bars.py --freq daily --start 2005-01-01
# 4. 分钟线（1.7天大头，后台流式）

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
.venv/Scripts/python scripts/jq_v3/fetch_bars.py --freq minute --start 2005-01-01
# 5. ST+基金净值（小时级）

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
.venv/Scripts/python scripts/jq_v3/fetch_st_fundnav.py --all
```

拉取期间主控每 1-2 分钟 `tail` checkpoint + 进度，符合 AGENTS.md 实时进度规则。断点续传保证中断可恢复。

### B2. 导入 ClickHouse（stream_import）

每张表拉取完后导入：
```bash
.venv/Scripts/python scripts/stream_import.py --table jq_v3_bar_daily --dir tmp/jq_v3_export/jq_v3_bar_daily --user default
# ... 12 表逐一导入

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
```

### B3. 验证（validate_v3.py）

```bash
.venv/Scripts/python scripts/jq_v3/validate_v3.py --all
```

输出 12 表的行数/覆盖/非空率/点对点/差异报告。合格门槛见规格 §3.5。

### B4. 路由切换

```bash
.venv/Scripts/python scripts/jq_v3/switch_routing.py --switch
# 验证

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
.venv/Scripts/python scripts/jq_v3/switch_routing.py --verify
```

切换后 `resolve_table("daily_bar")` 返回 `jq_v3_bar_daily`。旧表保留可回滚（`--rollback`）。

### B5. 回归测试（WUFU/QQ4W/J1ENV）

用可视化分段回测规范（AGENTS.md），对现有策略在切换后的数据上跑：
- WUFU smoke 2024Q1（快速验证不崩）
- WUFU formal 各段（验证聚宽口径下指标，重点看 4.66x 差距是否缩小）
- QQ4W / J1ENV smoke（基础回归）

**若任何策略 KeyError 或指标严重偏离**：`switch_routing.py --rollback` 回滚，排查。

### B6. 决策记录

回归通过后，创建 DEC-JQDB 记录路由切换 + 回归通过决策，更新 EX-JQDB-S1 实验记录。

---

## 实施顺序总结

```
代码开发（子代理驱动 TDD，本计划主体）：
Task 1（DDL+stream_import注册）
  → Task 2（公共工具，2-6 依赖）
  → Task 3（静态表拉取）
  → Task 4（估值+财务拉取）
  → Task 5（日线+分钟线拉取，流式写）
  → Task 6（ST+基金净值拉取）
  → Task 7（验证脚本）
  → Task 8（路由切换脚本）
  → 最终整分支审查

数据执行（主控+凭证，B部分运行手册）：
B1 拉取 → B2 导入 → B3 验证 → B4 切换 → B5 回归 → B6 决策
```

Task 1 必须最先（DDL 是基础）。Task 2 必须在 3-6 前（公共工具）。Task 3-6 相互独立可并行思路（但子代理串行执行避免冲突）。Task 7-8 可在 3-6 后。代码全部完成 + 审查通过后，才进入 B 部分数据执行。
