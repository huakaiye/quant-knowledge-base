# 聚宽数据库全面重构设计规格

- **创建日期**：2026-07-08
- **状态**：待审阅
- **研究方向**：RD-JQDB（待创建）
- **影响系统**：回测平台 `E:\量化平台_V1.4.0`（主战场）+ 研究库（资产记录）
- **决策记录**：本规格基于用户三项架构决策——(1) 接入方式=jqdatasdk 纯 API 直连；(2) 隔离策略=新建聚宽表+路由切换（可回滚）；(3) 范围=全面接入（13 主表口径切换 + 聚宽全部特有数据）。补充决策：分钟线也纯 API 拉取。

---

## 0. 背景与问题陈述

### 0.1 现状（已核实）

V2 平台的核心数据表（`jq_bar_daily`、`jq_bar_minute_v2`、`jq_valuation`、`jq_balance`、`jq_income`、`jq_cashflow`、`jq_fina_indicator`、`jq_stock_info`、`jq_trade_days`、`jq_st_status`、`index_constituent`、`jq_fund_net_value`、`jq_adjust_factor`，共 13 张主表）**表名以 `jq_` 开头、`data_routing.json` 里 `provider` 标 `"jq"`，但实际数据全是 xtdata（miniQMT/xtquant）口径**。这是历史遗留的口径混乱。

生产数据更新入口是 `E:\xtquant\策略\xtdata_update_full.py`（非聚宽 API），用 `dividend_type='front'` 写入前复权行情。由此带来三类问题：

1. **数据残缺**：`jq_valuation` 的 `pe_ratio/pb_ratio/ps_ratio/pcf_ratio` 全为 NULL（xtdata 不提供，脚本注释明确"仅更新市值和股本"）；`jq_stock_info` 的 `sw_l1/sw_l2/sw_l3/jq_l1/jq_l2/zjw` 行业分类全为 None。
2. **复权口径偏差**：xtdata 复权因子（`get_divid_factors` 的 `dr` 连乘）与聚宽前复权因子算法不等价。`docs/聚宽复现差异分析.md` 记录 002800 在 CH 中 `factor=0.997902`，聚宽前复权 open 差 0.02 元。这已被证实是 WUFU 策略 4.66x 复现差异的根因之一。
3. **来源不可追溯**：13 张主表均无 `source` 字段，xtdata 行与历史聚宽行混存无法区分，且 `qmt_data_updater.py` 用未复权口径写入与生产脚本前复权口径冲突（隐患）。

### 0.2 目标

将 13 张主表的数据口径从 xtdata 切换为聚宽原生口径，并补齐聚宽提供但平台缺失的全部数据（北向资金、分红送转、可转债、融资融券、资金流向、龙虎榜、限售解禁、聚宽因子库、指数权重、申万行业指数、基金持仓等），未来数据更新统一走聚宽 API（jqdatasdk 直连）。

### 0.3 非目标

- 不改动回测引擎核心逻辑（`daily_engine.py` 的撮合/调度/记账）。
- 不改动 `jq_bridge.py` 的 API 转发语义（策略代码无感）。
- 不重构 portal 的查询方法签名（只切表名，靠 `resolve_table` 抽象）。
- 不删除现有 `jq_*`（xtdata 口径）表，保留作为回滚后盾，直到新表全量验证通过且至少观察一个稳定运行周期。

---

## 1. 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│ 阶段0：jqdatasdk 直连框架（公共底座）                          │
│   认证管理 · 配额监控 · 速率控制 · 断点续传 ·                  │
│   错误重试 · 并发控制 · checkpoint · 日志                      │
│   产出：jq_fetcher 模块 + jq_credentials 凭证管理              │
└─────────────────────────────────────────────────────────────┘
          │ 所有数据拉取复用此框架
          ▼
┌────────────────────────────┐   ┌──────────────────────────────┐
│ 阶段1：核心13表口径切换 ⭐   │   │ 阶段2-4：聚宽全新数据接入      │
│  新建 jq_v3_* 聚宽原生表     │   │  按优先级分批：                │
│  API拉取→写入→验证→         │   │  P1: 北向/分红/可转债          │
│  data_routing 路由切换       │   │  P2: 融资融券/资金流/龙虎榜/   │
│  旧 jq_* 表保留可回滚        │   │      限售/因子库/指数权重/     │
│  现有策略回归测试            │   │      申万行业指数/基金持仓     │
│  → 回到聚宽口径              │   │  P3: 集合竞价/业绩预告/        │
└────────────────────────────┘   │      Alpha101/宏观/舆情        │
                                  └──────────────────────────────┘
          │ portal 通过 resolve_table 无感读取新表
          ▼
┌─────────────────────────────────────────────────────────────┐
│  data_routing.json：jq_v3_* 为唯一聚宽口径真相源              │
│  旧 jq_* 表 status 标 legacy_xtdata（可回滚）                 │
└─────────────────────────────────────────────────────────────┘
```

### 1.1 核心设计原则

1. **聚宽原生口径**：新表按聚宽 API 原生字段建表，含完整 PE/PB/PS、sw_l1/l2/l3 多级行业、聚宽前复权因子，不再迁就 xtdata 残留字段。
2. **portal 无感切换**：新表的 DB 列名严格对齐旧表（portal 用显式列名查询，列名不符会 SQL 报错）。聚宽额外字段作为新增列追加。
3. **可回滚**：旧 `jq_*`（xtdata 口径）表保留，`data_routing.json` 的 `table` 字段切换前可瞬时回退。切换通过改配置 + `reload_routes()` 热加载，无需重启。
4. **框架复用**：jqdatasdk 直连框架（阶段 0）一次建成，13 主表和全新数据共用同一套拉取/写入/验证基础设施。
5. **凭证隔离**：聚宽账号密码绝不入库，通过环境变量或仓库外文件读取，并补齐 `.gitignore` 凭证文件缺口。

### 1.2 平台与研究库的职责边界

| 系统 | 职责 |
| --- | --- |
| 回测平台 `E:\量化平台_V1.4.0` | jq_fetcher 模块、新表 DDL、拉取脚本、写入脚本、验证脚本、`data_routing.json` 切换、portal 适配（如需）、回归测试 |
| 研究库 | RD-JQDB 方向文档、EX-JQDB-S0/S1/S2/S3 实验记录、DEC-JQDB 决策卡、子代理调用台账、术语库、frontmatter 规范遵循 |

---

## 2. 阶段 0：jqdatasdk 直连框架

### 2.1 目标

构建一个可复用的聚宽数据拉取底座，供所有后续拉取任务（13 主表 + 全新数据）共用。包含认证、配额、速率、并发、断点续传、错误重试、checkpoint、日志八项能力。

### 2.2 交付物

| 交付物 | 路径 | 说明 |
| --- | --- | --- |
| jq_fetcher 模块 | `${QUANT_PLATFORM_ROOT}/src/quant_v2/jq_fetcher/__init__.py` | 包入口，导出 `JqFetcher`、`JqCredentials` |
| 认证管理 | `src/quant_v2/jq_fetcher/credentials.py` | `JqCredentials` 类，三级优先级读取（见 2.4） |
| 拉取核心 | `src/quant_v2/jq_fetcher/core.py` | `JqFetcher` 类，封装通用拉取循环（见 2.5） |
| checkpoint 存储 | `src/quant_v2/jq_fetcher/checkpoint.py` | `Checkpoint` 类，JSON 落盘断点（见 2.6） |
| 配额监控 | `src/quant_v2/jq_fetcher/quota.py` | 调 `get_query_count()` 监控，低于阈值告警 |
| 依赖更新 | `src/requirements.txt` 追加 `jqdatasdk` | 仅数据生产侧依赖，不进 `requirements-wsl-backtest.txt` |
| `.gitignore` 补丁 | 平台根 `.gitignore` 追加凭证文件名 | 闭合现有缺口（见 2.4） |
| 速率实测报告 | 阶段 0 实验记录附件 | 实测 jqdatasdk 单机拉取速率，据此估算全量工期（见 2.7） |

### 2.3 jqdatasdk 依赖

- 新增到 `src/requirements.txt`（数据生产侧，Windows 本地运行 jq_fetcher）。
- **不进** `src/requirements-wsl-backtest.txt`（回测进程只读 ClickHouse，不调 jqdatasdk）。
- 版本固定为当前最新稳定版（实装时 `pip show jqdatasdk` 查实际安装版本写死）。

### 2.4 凭证管理

jqdatasdk 用 `auth(username, password)`（手机号 + 密码，密码可含逗号）。凭证读取优先级（对齐 Tushare 现有三段式）：

1. 构造函数显式参数 `JqFetcher(username=..., password=...)`（测试用）
2. 环境变量 `JQ_USERNAME` / `JQ_PASSWORD`
3. 仓库外文件 `E:/xtquant/策略/jq_credentials.json`（`{"username":"...","password":"..."}`，与 `tushare_token.txt` 同目录，不进 git）
4. 研究库 `.research.local.json` 的 `jq_username` / `jq_password` 键（与现有路径配置同文件，但该文件本就不入库）

三级都取不到则抛 `CredentialNotFoundError`。**凭证值绝不打印到日志**（异常信息脱敏，只报"凭证缺失"或"认证失败"，不回显密码）。

`.gitignore` 补丁（闭合现有缺口，`git check-ignore` 已确认这些当前未匹配）：

```gitignore
# 凭证与本地配置（绝不入库）
tushare_token.txt
.tushare_token
*token*.txt
jq_credentials.json
.research.local.json
```

### 2.5 JqFetcher 拉取核心

`JqFetcher` 类提供通用拉取循环，屏蔽 jqdatasdk 的速率/重试/分页细节：

```python
class JqFetcher:
    def __init__(self, credentials=None, max_workers=4, ...):
        ...

    def fetch_panel(self, security_list, fetch_fn, *, by="security",
                    checkpoint_key=None, **fetch_kwargs) -> pd.DataFrame:
        """通用拉取循环。

        - by="security"：按标的循环（适用于行情/估值/财务，每标的一次查询）
        - by="day"：按交易日循环（适用于事件类如龙虎榜）
        - 自动分页（jqdatasdk 单次 5000 行限制）
        - 自动断点续传（读 checkpoint_key 对应的 JSON，跳过已完成项）
        - 自动重试（网络/超时错误，指数退避，最多 3 次）
        - 自动配额检查（每 N 次查询调 get_query_count，低于阈值暂停+告警）
        - 实时进度（tqdm + 每标的完成写 checkpoint + 每 100 标的打印进度行）
        """
```

关键参数与默认值（实装时按速率实测调整）：

- `max_workers=4`：并发线程数（jqdatasdk 有并发限制，初期保守用 4）
- `retry_max=3`：单次查询最大重试次数
- `retry_backoff=2.0`：指数退避基数（1s, 2s, 4s）
- `quota_check_interval=500`：每 500 次查询检查一次配额
- `quota_warn_threshold=1_000_000`：剩余配额低于 100 万次时告警
- `checkpoint_dir`：checkpoint 文件目录，默认 `${QUANT_PLATFORM_ROOT}/tmp/jq_checkpoint/`

### 2.6 checkpoint 断点续传

每个拉取任务对应一个 checkpoint JSON 文件（`tmp/jq_checkpoint/<task_name>.json`），格式：

```json
{
  "task_name": "daily_bar_v3",
  "started_at": "2026-07-08T12:00:00Z",
  "updated_at": "2026-07-08T14:30:00Z",
  "total_items": 10000,
  "completed_items": ["000001.XSHE", "000002.XSHE", ...],
  "failed_items": {"000003.XSHE": "timeout after 3 retries"},
  "last_progress_pct": 35.2
}
```

拉取启动时若 checkpoint 存在，自动跳过 `completed_items`；中断后重启无缝续传。`failed_items` 单独标记，任务结束后可单独重试失败项，不必全量重跑。

### 2.7 速率实测（阶段 0 验收硬门槛）

在正式拉取 13 表前，必须实测 jqdatasdk 速率并据此估算全量工期。实测脚本拉取样本：50 只标的 × 11 年日线 + 50 只标的 × 1 个月分钟线，测以下指标：

| 指标 | 测量方法 | 合格门槛 |
| --- | --- | --- |
| 单次日线查询延迟 | 50 只标的各拉 11 年日线计时取均值 | < 2 秒/次 |
| 单次分钟线查询延迟 | 50 只标的各拉 1 个月分钟线计时取均值 | < 3 秒/次 |
| 并发 4 线程加速比 | 串行 50 只 vs 并发 4 线程 50 只 | ≥ 3.0x |
| 速率限制触发阈值 | 逐步加大并发，观察何时报速率错误 | 记录实际阈值 |
| 全量分钟线工期估算 | 按实测速率 × 7047 标的 × 132 月 | 报告数值 |

工期估算若超过 7 天，在实验记录中标记风险并提请主控决策是否需要局部调整（用户已选择"分钟线也纯 API 拉取"，故此为风险记录而非方案变更）。

### 2.8 阶段 0 验收门槛

| # | 门槛 | 验证方式 |
| --- | --- | --- |
| 1 | jqdatasdk 成功安装并 `auth()` 通过 | `python -c "from jqdatasdk import auth; auth(...)"` 无异常，`get_query_count()` 返回剩余配额 |
| 2 | JqFetcher 能拉取日线/分钟线/财务各 1 只标的 1 段数据 | 单元测试或 smoke 脚本 |
| 3 | checkpoint 断点续传工作 | 手动 Ctrl+C 中断后重启，跳过已完成项 |
| 4 | 配额监控触发 | 拉够 `quota_check_interval` 次后打印剩余配额 |
| 5 | 速率实测报告产出 | 报告含上表全部指标 + 全量工期估算 |
| 6 | 凭证不入库 | `git status` 确认无凭证文件；`.gitignore` 覆盖测试通过 |

---

## 3. 阶段 1：核心 13 表口径切换（核心阶段）

### 3.1 目标

新建一套 `jq_v3_*` 表（聚宽原生口径），用 jqdatasdk 拉取全量历史数据写入，验证后通过 `data_routing.json` 切换 portal 读取，使所有现有策略运行在纯聚宽数据上。旧 `jq_*`（xtdata）表保留为回滚后盾。

### 3.2 新表设计

命名约定：`jq_v3_<语义名>`。`v3` 区别于现有 `jq_*`（实为 xtdata 口径）和旧 `bar_data_jq`（已废弃）。

**硬约束（已核实）**：新表 DB 列名必须逐字段对齐旧表，portal 才能无感切换。下表"必含列"来自 `clickhouse_portal.py` 显式 SELECT 清单。聚宽额外字段在"新增列"补。

#### 3.2.1 日线表 `jq_v3_bar_daily`

```sql
CREATE TABLE IF NOT EXISTS quant.jq_v3_bar_daily
(
    -- 必含列（对齐旧表，portal 无感切换）
    symbol       LowCardinality(String),
    exchange     LowCardinality(String),
    datetime     Date,
    open_price   Decimal(18, 4),
    high_price   Decimal(18, 4),
    low_price    Decimal(18, 4),
    close_price  Decimal(18, 4),
    volume       UInt64,
    turnover     Decimal(18, 4),       -- 聚宽 money 字段
    pre_close    Nullable(Decimal(18, 4)),
    limit_up     Nullable(Decimal(18, 4)),   -- 聚宽 high_limit
    limit_down   Nullable(Decimal(18, 4)),   -- 聚宽 low_limit
    paused       UInt8 DEFAULT 0,
    factor       Nullable(Decimal(18, 6)),   -- 聚宽前复权因子（必填，wufu 依赖）
    adj_type     LowCardinality(String) DEFAULT 'pre',
    -- 新增列（聚宽口径标记）
    source       LowCardinality(String) DEFAULT 'joinquant_api'
)
ENGINE = ReplacingMergeTree
PARTITION BY toYear(datetime)
ORDER BY (symbol, exchange, datetime)
SETTINGS index_granularity = 8192;
```

字段映射（聚宽 API → DB 列）：`open→open_price, high→high_price, low→low_price, close→close_price, volume→volume, money→turnover, pre_close→pre_close, high_limit→limit_up, low_limit→limit_down, paused→paused, factor→factor`。

#### 3.2.2 分钟线表 `jq_v3_bar_minute`

```sql
CREATE TABLE IF NOT EXISTS quant.jq_v3_bar_minute
(
    -- 必含列（对齐 jq_bar_minute_v2，portal 分钟路径无 factor）
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
    factor       Nullable(Decimal(18, 6)),   -- 分钟级前复权因子（聚宽提供）
    adj_type     LowCardinality(String) DEFAULT 'pre',
    source       LowCardinality(String) DEFAULT 'joinquant_api'
)
ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMM(datetime)              -- 按月分区（分钟线量大）
ORDER BY (symbol, exchange, datetime)
SETTINGS index_granularity = 8192;
```

**注意**：现有 `jq_bar_minute_v2` 按年分区（`toYear`），新表改为按月分区（`toYYYYMM`）以匹配 `jq_bar_minute_real` 的成熟分区策略，避免单分区过大。

#### 3.2.3 估值表 `jq_v3_valuation`

```sql
CREATE TABLE IF NOT EXISTS quant.jq_v3_valuation
(
    -- 必含列（对齐旧表，列名即聚宽原生）
    symbol                   LowCardinality(String),
    exchange                 LowCardinality(String),
    datetime                 Date,
    market_cap               Nullable(Decimal(24, 4)),
    circulating_market_cap   Nullable(Decimal(24, 4)),
    pe_ratio                 Nullable(Decimal(18, 4)),   -- 聚宽 PE-TTM（补齐 xtdata 空值）
    pe_ratio_lyr             Nullable(Decimal(18, 4)),   -- 聚宽静态 PE
    pb_ratio                 Nullable(Decimal(18, 4)),   -- 聚宽 PB（补齐）
    ps_ratio                 Nullable(Decimal(18, 4)),   -- 聚宽 PS-TTM（补齐）
    pcf_ratio                Nullable(Decimal(18, 4)),   -- 聚宽 PCF-TTM（补齐）
    turnover_ratio           Nullable(Decimal(18, 4)),
    capitalization           Nullable(Decimal(24, 4)),
    circulating_cap          Nullable(Decimal(24, 4)),
    source                   LowCardinality(String) DEFAULT 'joinquant_api'
)
ENGINE = ReplacingMergeTree
PARTITION BY toYear(datetime)
ORDER BY (symbol, exchange, datetime)
SETTINGS index_granularity = 8192;
```

聚宽 `get_valuation` 返回字段对应：`capitalization, circulating_cap, market_cap, circulating_market_cap, turnover_ratio, pe_ratio, pe_ratio_lyr, pb_ratio, ps_ratio, pcf_ratio`。PE/PB/PS/PCF 全部补齐（解决 xtdata 全空问题）。

#### 3.2.4 财务四表 `jq_v3_fina_indicator` / `jq_v3_balance` / `jq_v3_income` / `jq_v3_cashflow`

这四张表 portal 走 `run_query` 的 SELECT * 路径（按 `DESCRIBE` 自动进 frame），故**新增列零风险**。设计策略：必含列对齐旧表 + 聚宽原生字段全部补齐。

以 `jq_v3_balance` 为例（其他三表同理，字段清单见 `get_history_fundamentals` 文档）：

```sql
CREATE TABLE IF NOT EXISTS quant.jq_v3_balance
(
    -- 必含列（对齐旧表）
    symbol                    LowCardinality(String),
    exchange                  LowCardinality(String),
    end_date                  Date,
    ann_date                  Nullable(Date),
    report_type               LowCardinality(Nullable(String)),
    goodwill                  Nullable(Float64),
    total_equity_attr_parent  Nullable(Float64),
    total_liabilities         Nullable(Float64),
    total_assets              Nullable(Float64),
    shortterm_loan            Nullable(Float64),
    cash_equivalents          Nullable(Float64),
    -- 新增列（聚宽 balance 原生字段全部补齐）
    total_current_assets      Nullable(Float64),
    total_non_current_assets  Nullable(Float64),
    total_current_liabilities Nullable(Float64),
    total_non_current_liabilities Nullable(Float64),
    total_equity              Nullable(Float64),
    total_share               Nullable(Float64),
    inventories               Nullable(Float64),
    fixed_assets              Nullable(Float64),
    intangible_assets         Nullable(Float64),
    longterm_loan             Nullable(Float64),
    retained_profit           Nullable(Float64),
    accounts_receivable      Nullable(Float64),
    -- ... 其余聚宽 balance 字段按 get_history_fundamentals 文档全量补齐
    source                    LowCardinality(String) DEFAULT 'joinquant_api'
)
ENGINE = ReplacingMergeTree
PARTITION BY toYear(end_date)
ORDER BY (symbol, exchange, end_date)
SETTINGS index_granularity = 8192;
```

实装时以 `get_history_fundamentals(security, fields, stat_date='2005', interval='1q')` 为拉取入口（比 `get_fundamentals(query(...))` 更适合批量历史拉取），按报告期循环拉取。

#### 3.2.5 证券主数据 `jq_v3_stock_info`

```sql
CREATE TABLE IF NOT EXISTS quant.jq_v3_stock_info
(
    -- 必含列（对齐旧表）
    symbol       LowCardinality(String),
    exchange     LowCardinality(String),
    display_name String,
    name         String,
    start_date   Nullable(Date),
    end_date     Nullable(Date),
    type         LowCardinality(String),
    -- 行业分类（聚宽原生补齐，解决 xtdata 全 None）
    sw_l1        Nullable(String),
    sw_l2        Nullable(String),
    sw_l3        Nullable(String),
    jq_l1        Nullable(String),
    jq_l2        Nullable(String),
    zjw          Nullable(String),
    source       LowCardinality(String) DEFAULT 'joinquant_api'
)
ENGINE = ReplacingMergeTree
ORDER BY (symbol, exchange)
SETTINGS index_granularity = 8192;
```

拉取方式：`get_all_securities(['stock','fund','index'])` 取标的清单 → 对每只标的 `get_industry(security, date)` 取多级行业分类合并写入。

#### 3.2.6 其余表

- `jq_v3_trade_days`：单列 `trade_date Date`，`get_trade_days('2005-01-01','today')` 一次拉取。
- `jq_v3_st_status`：列 `trade_date, symbol, is_st`（无 exchange，对齐旧表），由 `get_extras('is_st', ...)` 拉取。
- `index_constituent_v3`：列 `index_symbol, index_exchange, effective_date, constituent, constituent_exch, weight, status`，由 `get_index_stocks` + `get_index_weights` 拉取（补齐 weight 字段）。
- `jq_v3_fund_net_value`：聚宽 `finance.FUND_NET_VALUE` 拉取（替代 tushare 来源）。

**复权因子（`adjust_factor` 路由）的特殊处理**：
平台有两处用到复权因子：(a) portal 主路径用 `jq_bar_daily.factor` 列（`_restore_real_price_frame`）还原真实价——这会随 `daily_bar` 路由切换到 `jq_v3_bar_daily` 后自动变成聚宽口径，无需额外动作；(b) 独立表 `jq_adjust_factor` 服务于"真实价数据体系"（配合 `_real` 多源表）。由于 portal 的显式查询清单（附录 A）**不含 `adjust_factor` 路由**，主回测路径不依赖独立复权因子表，故本轮**不为 adjust_factor 单独建 v3 表、不切换其路由**。独立复权因子表的口径治理留待阶段 2 评估（届时与真实价表 `_real` 一起决策）。

### 3.3 拉取顺序与工期

按数据量从小到大、依赖关系从底到顶拉取，便于早期发现问题：

| 序号 | 表 | 拉取入口 | 标的数 | 估计查询次数 | 工期估计 |
| --- | --- | --- | --- | --- | --- |
| 1 | jq_v3_trade_days | `get_trade_days` | — | 1 | 秒级 |
| 2 | jq_v3_stock_info | `get_all_securities` + `get_industry` | ~10000 | ~10000 | 数小时 |
| 3 | jq_v3_valuation | `get_valuation` | ~10000 × 11年/250日 | 分批 | 数小时 |
| 4 | jq_v3_fina_indicator | `get_history_fundamentals` | ~10000 × 44季 | 分批 | 数小时 |
| 5 | jq_v3_balance/income/cashflow | `get_history_fundamentals` | 同上 | 分批 | 数小时×3 |
| 6 | index_constituent_v3 | `get_index_stocks`+`get_index_weights` | ~100指数 | ~100 | 分钟级 |
| 7 | jq_v3_st_status | `get_extras('is_st')` | ~4000股 × 2700日 | 分批 | 数小时 |
| 8 | jq_v3_fund_net_value | `finance.FUND_NET_VALUE` | ~5000基金 | 分批 | 小时级 |
| 9 | jq_v3_bar_daily | `get_price(frequency='daily')` | ~10000 | ~10000 | 数小时 |
| 10 | jq_v3_bar_minute | `get_price(frequency='minute')` | ~10000 × 132月 | ~132万 | **数天（工期大头）** |

**分钟线是工期大头**（序号 10），后台并行拉取，不阻塞序号 1-9 的验证。序号 1-9 完成后即可先切换日线相关路由做部分回归测试。

### 3.4 写入流程

统一用现有 `stream_import.py`（已成熟的 CSV→ClickHouse 流式导入器）。流程：

1. jq_fetcher 拉取数据 → 落地 `tmp/jq_v3_export/<table>.csv`（分批分文件，每文件 ≤ 100 万行）
2. `stream_import.py --table jq_v3_xxx --dir tmp/jq_v3_export --user default` 流式导入
3. ReplacingMergeTree 自动按 ORDER BY 去重

### 3.5 验证（每张表）

每张新表写入后必须通过验证：

| # | 验证项 | 方法 | 合格门槛 |
| --- | --- | --- | --- |
| 1 | 行数合理性 | `SELECT count()` 对比标的数 × 交易日数（日线）或报告期数（财务） | 偏差 < 5% |
| 2 | 覆盖完整性 | 抽样 20 只标的，检查 2005-01-01 至今无大段缺失 | 缺失日 < 1% |
| 3 | 字段非空率 | 估值表 PE/PB/PS 非空率、行业字段非空率 | PE/PB/PS ≥ 90%，行业 ≥ 95% |
| 4 | 与聚宽数据点对点核对 | 抽样 5 只标的 × 5 个日期，新表值 = jqdatasdk 实时查值 | 100% 一致 |
| 5 | 与旧表差异量化 | 对比 jq_v3_* vs jq_*（xtdata）的关键字段差异率 | 记录差异（预期存在，正是修复目标） |

### 3.6 路由切换（核心动作）

13 表全量验证通过后，改 `configs/data_routing.json`：

```json
{
  "data_routing": {
    "daily_bar":    { "table": "jq_v3_bar_daily",    "provider": "jq_api", "status": "active" },
    "minute_bar":   { "table": "jq_v3_bar_minute",   "provider": "jq_api", "status": "active" },
    "fundamentals": { "table": "jq_v3_valuation",    "provider": "jq_api", "status": "active" },
    "financials":   { "table": "jq_v3_fina_indicator","provider": "jq_api", "status": "active" },
    "income":       { "table": "jq_v3_income",       "provider": "jq_api", "status": "active" },
    "balancesheet": { "table": "jq_v3_balance",      "provider": "jq_api", "status": "active" },
    "cashflow":     { "table": "jq_v3_cashflow",     "provider": "jq_api", "status": "active" },
    "symbols":      { "table": "jq_v3_stock_info",   "provider": "jq_api", "status": "active" },
    "trade_days":   { "table": "jq_v3_trade_days",   "provider": "jq_api", "status": "active" },
    "st_status":    { "table": "jq_v3_st_status",    "provider": "jq_api", "status": "active" },
    "index_constituent": { "table": "index_constituent_v3", "provider": "jq_api", "status": "active" },
    "fund_net_value": { "table": "jq_v3_fund_net_value", "provider": "jq_api", "status": "active" },

    "daily_bar_real":  { "table": "jq_bar_daily_real",  "provider": "tushare_xtdata", "status": "active" },
    "minute_bar_real": { "table": "jq_bar_minute_real", "provider": "tushare_xtdata", "status": "active" },
    "adjust_factor":   { "table": "jq_adjust_factor",   "provider": "tushare_xtdata", "status": "active" },
    "...": "...",
    "_legacy_xtdata_daily_bar":  { "table": "jq_bar_daily",      "provider": "xtdata_legacy", "status": "legacy" },
    "_legacy_xtdata_minute_bar": { "table": "jq_bar_minute_v2",  "provider": "xtdata_legacy", "status": "legacy" }
  }
}
```

- 新 `provider` 值用 `"jq_api"`（区分旧 `"jq"` 标签实际是 xtdata 的历史误标）。
- 旧 13 表保留，`data_type` 改名为 `_legacy_xtdata_*` 前缀，`status` 标 `"legacy"`，保留至少一个稳定观察周期后由主控决策删除。
- `resolve_table()` 对 `status="legacy"` 行为：当前只拒绝 `removed`，`legacy` 仍可解析（便于回滚时改回 `active`）。
- 真实价表（`_real`）和复权因子表暂不切换（它们已是多源设计，聚宽 research 优先），后续阶段 2 再评估。

### 3.7 回归测试（切换后强制）

路由切换后，现有策略必须在纯聚宽数据上跑通且结果符合预期：

| # | 策略 | 配置 | 期望 | 验证重点 |
| --- | --- | --- | --- | --- |
| 1 | WUFU（五福闹新春） | smoke 2024Q1 | final_value 与切换前同量级 | 复权因子差异是否改善复现精度（4.66x 差距是否缩小） |
| 2 | WUFU formal 2022 段 | 已有 config | 跑通无 KeyError | 验证聚宽口径下豆粕等 ETF 决策是否与原版对齐 |
| 3 | QQ4W（状态机） | 已有 smoke config | 跑通无异常 | 基础回归 |
| 4 | J1ENV（环境温度） | 已有 config | 跑通无异常 | 基础回归 |
| 5 | 任意日频策略 | 任选 | summary.json exit_status=0 | 估值字段（PE/PB）可正常读取 |

**若任何策略出现 KeyError 或指标严重偏离**：回滚 `data_routing.json`（改回旧表名），排查新表字段缺失或数据问题，修复后重测。

### 3.8 阶段 1 验收门槛

| # | 门槛 |
| --- | --- |
| 1 | 12 张 jq_v3_* 新表全部建表成功（覆盖 13 个路由：financials 与 indicators 共用 jq_v3_fina_indicator；adjust_factor 不单独建表，由 daily_bar 路由切换后 factor 列自动覆盖聚宽口径） |
| 2 | 12 张表全量数据拉取完成（含分钟线） |
| 3 | 12 张表通过 3.5 全部 5 项验证 |
| 4 | `data_routing.json` 切换完成，`resolve_table` 解析正确 |
| 5 | 至少 2 个现有策略（含 WUFU）在切换后跑通且结果符合预期 |
| 6 | WUFU 复现差异分析：记录聚宽口径下的复现结果，与原版差距量化对比 |
| 7 | 旧 jq_* 表保留可回滚（status=legacy） |

---

## 4. 阶段 2-4：聚宽全新数据接入（路线图）

阶段 1 完成后启动。每批独立规划规格，此处只列优先级与数据量级。

### 阶段 2（P1 核心）

| 数据 | 接口 | 新表 | 量级 | ETF 适用 |
| --- | --- | --- | --- | --- |
| 北向资金（沪深港通持股） | `finance.STK_HK_HOLD_INFO` + 4 表 | `jq_v3_hk_hold_info` 等 | 千万行/年 | 否（仅 A 股） |
| 分红送转 | `finance.STK_XR_XD` | `jq_v3_dividend` | 百万行 | 否（A 股），ETF 另有 `FUND_DIVIDEND` |
| 可转债行情 | `bond.CONBOND_DAILY_PRICE` + `CONBOND_BASIC_INFO` | `jq_v3_conbond_*` | 日频 ~500 标的 | 否（独立品种） |

### 阶段 3（P2 重要）

| 数据 | 接口 | 新表 | 量级 |
| --- | --- | --- | --- |
| 融资融券 | `get_mtss` | `jq_v3_mtss` | 日频 ~2000 标的 |
| 资金流向 | `get_money_flow` | `jq_v3_money_flow` | 日频 ~4000 标的 |
| 龙虎榜 | `get_billboard_list` | `jq_v3_billboard` | 事件，小 |
| 限售解禁 | `get_locked_shares` | `jq_v3_locked_shares` | 事件，小 |
| 聚宽因子库 | `get_factor_values` + `get_all_factors` | `jq_v3_factors` | 日频，6 大类 |
| 指数权重 | `get_index_weights` | 扩展 `index_constituent_v3` | 月度 |
| 申万行业指数 | `finance.SW1_DAILY_PRICE` | `jq_v3_sw_index_daily` | 28 行业 |
| 基金持仓/份额 | `finance.FUND_PORTFOLIO_*` | `jq_v3_fund_*` | 季度/日频 |

### 阶段 4（P3 可选）

集合竞价、业绩预告、Alpha101/191、技术分析指标、两市成交概况、宏观、舆情、期权 —— 按策略需求逐个接入。

---

## 5. 研究库资产管理

遵循 `08_方法论/frontmatter规范.md` 和命名规范。

### 5.1 新增资产

| 类型 | ID | 标题 | 时机 |
| --- | --- | --- | --- |
| 研究方向 | RD-JQDB（用 New-ResearchItem.ps1 生成实际 ID） | 聚宽数据库全面重构 | 阶段 0 启动前 |
| 实验 | EX-JQDB-S0 | 阶段0基础设施验证 | 阶段 0 |
| 实验 | EX-JQDB-S1 | 阶段1核心13表口径切换 | 阶段 1 |
| 实验 | EX-JQDB-S2 | 阶段2核心新数据接入 | 阶段 2 |
| 决策 | DEC-JQDB-01 | 路由切换决策（切换前） | 阶段 1 验证通过后 |
| 决策 | DEC-JQDB-02 | 回归测试通过决策 | 阶段 1 回归通过后 |
| 文献 | （复用平台现有聚宽 API 文档） | — | — |

### 5.2 每轮实验硬规则遵循

每个 EX 必须含：研究方向 ID、本次假设、实验前预测、基准对照、竞争性解释、证伪条件、平台配置/结果路径、实际观察、与预测一致性、支持/反对证据、新手短总结、下一步、是否需决策卡。

### 5.3 台账同步

- `01_台账/实验记录台账.csv` 追加 EX-JQDB-S0/S1/S2 行。
- `01_台账/子代理调用台账.csv` 记录每个阶段的子代理调用（拉取/验证/回归测试可委派子代理）。
- `01_台账/文献台账.csv` 不需新增（复用现有聚宽文档）。

### 5.4 入口资产更新

- `00_入口/研究驾驶舱.md`：新增 RD-JQDB 方向。
- `00_入口/当前状态.md`：记录当前推进到哪个阶段。
- `00_入口/研究路线图.canvas` 或 `02_研究方向/RD-JQDB_路线图.canvas`：阶段 0-4 节点。
- 资产变更后用 `tools/Build-ResearchBoard.ps1` 和 `tools/Build-ResearchGraph.ps1` 重建。

---

## 6. 风险与对策

| 风险 | 概率 | 影响 | 对策 |
| --- | --- | --- | --- |
| 分钟线全量拉取耗时超 7 天 | 中 | 阶段 1 周期延长 | 阶段 0 速率实测早预警；后台并行不阻塞日线验证；用户已选纯 API，记录为已知风险 |
| 路由切换破坏现有策略 | 中 | 高 | 强制回归测试；可瞬时回滚（改配置 + reload_routes） |
| 聚宽复权因子与策略预期不符 | 中 | 中 | WUFU 复现差异本就是修复目标，记录差异并验证改善 |
| jqdatasdk 凭证泄露 | 低 | 高 | 凭证不入库；环境变量/仓库外文件；`.gitignore` 补缺口；日志脱敏 |
| 配额耗尽 | 低 | 中 | 配额监控（阶段 0 内置）；预估全量约 300-400 万次，仅占 200M 配额 0.2% |
| jqdatasdk 速率限制触发 | 中 | 中 | 实测阈值；保守并发（max_workers=4）；指数退避重试 |
| 13 表字段映射遗漏 | 低 | 中 | portal 列依赖已逐表核实（见规格 3.2 硬约束）；回归测试兜底 |
| 旧表误删导致无法回滚 | 低 | 高 | 旧表 status 标 legacy 保留，主控决策删除时机 |

---

## 7. 不确定项（需实装时验证）

以下项在实装时需进一步确认，不阻塞规格批准：

1. **jqdatasdk 版本固定值**：实装时 `pip show jqdatasdk` 查实际版本写入 `requirements.txt`。
2. **聚宽财务表完整字段清单**：`get_history_fundamentals` 的 balance/income/cashflow 完整字段列表，实装时从 `get_all_factors` 或 `DESCRIBE` 聚宽返回帧确认，逐字段补齐新表 DDL。
3. **分钟线速率实测值**：阶段 0 速率实测脚本给出具体数值，据此调整 `max_workers` 和工期估算。
4. **`source` 字段对新表 portal 查询的影响**：新表新增 `source` 列，portal 显式 SELECT 不涉及该列（零影响），但需确认 ReplacingMergeTree 去重时 source 不干扰 ORDER BY 去重（应无影响，因 source 不在 ORDER BY）。

---

## 8. 实施顺序总结

```
阶段0（1-2天）
  ├─ jqdatasdk 依赖 + 凭证管理 + .gitignore 补丁
  ├─ jq_fetcher 模块（认证/配额/速率/断点续传/重试/checkpoint/日志）
  └─ 速率实测报告（决策工期）
       │
       ▼
阶段1（5-10天，核心）
  ├─ 建 13 张 jq_v3_* 表 DDL
  ├─ 按 3.3 顺序拉取（分钟线后台并行）
  ├─ 每表 3.5 五项验证
  ├─ data_routing.json 路由切换（可回滚）
  ├─ 现有策略回归测试（WUFU/QQ4W/J1ENV）
  └─ DEC-JQDB 决策卡（切换 + 回归通过）
       │
       ▼
阶段2-4（按优先级分批，每批独立规格）
  ├─ P1: 北向/分红/可转债
  ├─ P2: 融资融券/资金流/龙虎榜/限售/因子库/指数权重/行业指数/基金持仓
  └─ P3: 集合竞价/业绩预告/Alpha/宏观/舆情（按需）
```

---

## 附录 A：portal 列依赖核实结果（已确认，作为新表字段设计依据）

| data_type | portal 查询方法 | SELECT 风格 | 必含 DB 列 |
| --- | --- | --- | --- |
| daily_bar | `_load_daily_bars:896` | 显式 | symbol, exchange, datetime, open_price, high_price, low_price, close_price, volume, turnover, pre_close, limit_up, limit_down, paused, **factor（必填）** |
| minute_bar | `_load_minute_bars:1269` + `minute_cache.py` | 显式 | symbol, exchange, datetime, open_price, high_price, low_price, close_price, volume, turnover, pre_close, limit_up, limit_down, paused（无 factor） |
| fundamentals | `get_fundamentals:532` | 显式 | symbol, exchange, datetime, market_cap, circulating_market_cap, pe_ratio, pe_ratio_lyr, pb_ratio, ps_ratio, pcf_ratio, turnover_ratio, capitalization, circulating_cap |
| financials/indicators | `_load_financials:1690` + `run_query` | 显式 + SELECT * | symbol, exchange, end_date, ann_date, eps, adjusted_profit, roe, roa, roic, gross_profit_margin, net_profit_margin, inc_total_revenue_year_on_year, inc_net_profit_year_on_year, current_ratio, quick_ratio, debt_to_assets, assets_turn, bps, ocfps |
| income | `_load_income_statement:1716` + `run_query` | 显式 + SELECT * | symbol, exchange, end_date, ann_date, net_profit, operating_revenue, total_operating_revenue, basic_eps |
| balancesheet | `_load_balance_statement:1738` + `run_query` | 显式 + SELECT * | symbol, exchange, end_date, ann_date, goodwill, total_equity_attr_parent, total_liabilities, total_assets, shortterm_loan, cash_equivalents |
| cashflow | `_load_cash_flow_statement:1764` + `run_query` | 显式 + SELECT * | symbol, exchange, end_date, ann_date, net_operate_cashflow, free_cashflow |
| symbols | `_query_all_securities:356` | 显式 | symbol, exchange, display_name, name, start_date, end_date, type, sw_l1, sw_l2, sw_l3, jq_l1, jq_l2, zjw |
| trade_days | `get_trade_days:308` | 显式（单列） | trade_date |
| index_constituent | `get_index_stocks:778` 等 | 显式 | index_symbol, index_exchange, effective_date, constituent, constituent_exch, weight, status |
| st_status | `_load_st_status:1581` | 显式 | trade_date, symbol, is_st（无 exchange） |

## 附录 B：聚宽 API 接口完整矩阵（摘要）

完整矩阵见阶段 3 子代理报告。摘要：13 主表口径切换覆盖 `get_price`/`get_valuation`/`get_history_fundamentals`/`get_all_securities`/`get_industry`/`get_trade_days`/`get_index_stocks`/`get_index_weights`/`get_extras('is_st')`/`finance.FUND_NET_VALUE`。全新数据覆盖北向/分红/可转债/融资融券/资金流/龙虎榜/限售/因子库/申万行业指数/基金持仓/集合竞价/业绩预告/Alpha101/宏观/舆情。

---

**规格状态**：待用户审阅。审阅通过后，调用 writing-plans 技能创建阶段 0 的详细实现计划。
