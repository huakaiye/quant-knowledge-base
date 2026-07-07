# 五福闹新春 ETF 动量轮动 阶段 0 实现计划（移植 + 静态审计 + smoke）

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把聚宽"五福闹新春 v5.2"策略全机械移植到 V2 平台，完成未来函数静态审计 6 项，跑 smoke 确认移植正确性（display_name 覆盖度 + 动态池构建 + 分钟止损 every_bar 机制），为阶段 1 四段 formal 扫清前置障碍。

**Architecture:** 聚宽式策略（`from jqdata import *` + `initialize` + `run_daily` 调度），复用 V2 平台 `jq_bridge.py` 兼容层。策略文件放在 `${QUANT_PLATFORM_ROOT}/src/strategies/research/wufu_etf_momentum_jq.py`，配置放在 `configs/research/RD-20260707T135354Z-main-WUFU/EX-20260707T135354Z-main-WUFU/`。原版 1265 行全机械复制，仅做 4 处平台适配改动（文件头 docstring / 成本参数化 / every_bar 验证 / record 中文变量名）。

**Tech Stack:** Python 3（聚宽式语法）+ V2 平台 jq_bridge 兼容层 + ClickHouse 行情数据 + SimBroker 撮合

## Global Constraints

- **全机械移植**：原版 7 类机制（固定池/动态行业池/走弱期切换/加权动量/五重过滤/候选筛选/分钟止损）全部保留，不简化、不优化、不重构
- **原版源码路径**：`C:\Users\Administrator\.zcode\tmp\paste-attachments\2026-07-07\pasted-text-20260707-211719-e4843d8b.txt`（用户 2026-07-07 粘贴的临时附件，1265 行）
- **平台根路径**：`E:\量化平台_V1.4.0`（由 `Get-QuantPlatformRoot.ps1` 解析）
- **编码**：策略文件 UTF-8（`# -*- coding: utf-8 -*-`），配置 JSON UTF-8 无 BOM
- **路径分隔符**：台账/文档用 `/`，禁反斜杠
- **前置门禁**：Task 1（移植 + py_compile）通过才能做 Task 2（静态审计），Task 2 通过才能做 Task 3（smoke）
- **smoke 通过门槛**：summary.json 生成 + display_name 覆盖度 ≥ 80% + 动态池构建非空 + 无 NameError/AttributeError
- **回测命令边界**：Agent 回测在 WSL 内运行，`PYTHONUNBUFFERED=1 + tee` 过程可见
- **可视化分段**：smoke 单段 < 5 分钟可直接前台跑；若超 5 分钟用 `Run-VisibleBacktest.ps1`

---

## 文件结构

### 新建文件

| 路径 | 职责 |
|------|------|
| `${QUANT_PLATFORM_ROOT}/src/strategies/research/wufu_etf_momentum_jq.py` | 五福闹新春策略（聚宽式，全机械移植 + 4 处适配） |
| `${QUANT_PLATFORM_ROOT}/configs/research/RD-20260707T135354Z-main-WUFU/EX-20260707T135354Z-main-WUFU/smoke_2024q1.json` | smoke 配置（2024-01~2024-03，分钟回测） |

### 修改文件（仅研究库文档，非平台代码）

| 路径 | 修改内容 |
|------|----------|
| `04_实验记录/EX-20260707T135354Z-main-WUFU_五福闹新春全机械移植与5项门禁预注册.md` | 回填阶段 0 执行记录（第 11 节运行命令/结果路径、第 8 节静态审计结论、第 12-15 节实际观察） |

### 参照文件（只读，不修改）

| 路径 | 用途 |
|------|------|
| `C:\Users\Administrator\.zcode\tmp\paste-attachments\2026-07-07\pasted-text-20260707-211719-e4843d8b.txt` | 原版源码（复制源） |
| `${QUANT_PLATFORM_ROOT}/src/strategies/research/etf_env_temp_strategy.py` | 聚宽式 ETF 策略范例（文件头 docstring 范式） |
| `${QUANT_PLATFORM_ROOT}/src/strategies/research/v_tech_momentum_jq.py` | 聚宽式策略范例（参数化范式） |
| `${QUANT_PLATFORM_ROOT}/src/quant_v2/strategy_api/jq_bridge.py` | 聚宽兼容层（API 覆盖度核查） |
| `${QUANT_PLATFORM_ROOT}/configs/research/R010-A11/env_temperature/smoke/smoke_2024_01.json` | smoke 配置范例 |
| `${QUANT_PLATFORM_ROOT}/docs/聚宽API底层语义兼容审计_2026-05-27.md` | get_current_data 分钟口径审计 |

---

## Task 1: 创建策略文件 + 全机械移植 + 平台适配

**Files:**
- Create: `${QUANT_PLATFORM_ROOT}/src/strategies/research/wufu_etf_momentum_jq.py`

**Interfaces:**
- Consumes: V2 平台 `jq_bridge.py` 导出的聚宽 API（`get_price`/`get_all_securities`/`get_current_data`/`get_security_info`/`attribute_history`/`order`/`set_option`/`set_slippage`/`set_order_cost`/`run_daily`/`record`/`PriceRelatedSlippage`/`OrderCost`）
- Produces: 策略文件 `wufu_etf_momentum_jq.py`，供 Task 3 smoke 配置的 `strategy_file` 字段引用

### 适配改动清单（4 处）

原版 1265 行全机械复制，仅做以下 4 处改动：

#### 改动 1：文件头 docstring（仿 etf_env_temp_strategy.py）

在文件最顶部（`import numpy as np` 之前）加 docstring：

```python
# -*- coding: utf-8 -*-
"""五福闹新春 ETF 动量轮动策略（聚宽式 V2 策略模块）。

研究背景
--------
本策略把聚宽社区"五福闹新春 v5.2"策略移植成 V2 引擎真实撮合口径。
原始来源：聚宽文章 https://www.joinquant.com/post/74243 ，作者"烟花三月ETF"。
原帖未提供回测明细，只有策略源码；本模块走 V2 SimBroker 撮合（T+1 +
佣金 + 滑点 + 最小佣金），用于验证原版 7 类机制是否有效。

研究库登记为 RD-20260707T135354Z-main-WUFU（独立策略族复现），不挂 RD-CORE。
在 EX-WUFU 完成 5 项门禁 + 十一年复核前，本策略不得实盘、不得 shadow。

还原边界
--------
- 全机械移植原版 7 类机制：固定 ETF 池 97 只 + 动态行业池 + 走弱期切换
  全球/中国池 + 加权对数回归动量 + 五重过滤 + 候选筛选 1 只集中 + 分钟级 5% 止损。
- 不简化、不优化、不重构原版逻辑。
- 仅做 4 处平台适配：文件头 docstring / 成本参数化 / every_bar 验证 / record 中文变量名。

口径
----
- 原版 set_slippage(PriceRelatedSlippage(0.0001)) + 佣金万分之一，本版参数化为
  g.slippage_rate / g.commission_rate，默认值与原版一致，支持 cost_multiplier 扰动。
- 分钟回测：data_requirements.minute.enabled=true，every_bar 分钟级止损。
- 前复权用聚宽原生 fq='pre'。
"""
```

#### 改动 2：成本参数化（仿 v_tech_momentum_jq.py 范式）

原版 `initialize` 第 15-16 行硬编码成本：

```python
# 原版
set_slippage(PriceRelatedSlippage(0.0001), type="fund")
set_order_cost(OrderCost(open_tax=0, close_tax=0, open_commission=0.0001, close_commission=0.0001, close_today_commission=0.0001, min_commission=5), type="fund")
```

改为参数化（在 `initialize` 函数开头，`set_option` 之前加参数读取）：

```python
# 改后
params = getattr(context, "params", {}) or {}
g.cost_multiplier = float(params.get("cost_multiplier", 1.0))
g.slippage_rate = float(params.get("slippage_rate", 0.0001 * g.cost_multiplier))
g.commission_rate = float(params.get("commission_rate", 0.0001 * g.cost_multiplier))
g.min_commission = float(params.get("min_commission", 5))

set_slippage(PriceRelatedSlippage(g.slippage_rate), type="fund")
set_order_cost(OrderCost(open_tax=0, close_tax=0, open_commission=g.commission_rate, close_commission=g.commission_rate, close_today_commission=g.commission_rate, min_commission=g.min_commission), type="fund")
```

注意：原版 `initialize` 里 `set_option("avoid_future_data", True)` 和 `set_option("use_real_price", True)` 保留不动。`params` 读取放在 `set_option` 之前。

#### 改动 3：every_bar 验证（可能需要 fallback）

原版第 204 行 `run_daily(minute_level_stop_loss, time='every_bar')`。

V2 平台 `jq_bridge.py` 的 `run_daily` 对 `time='every_bar'` 的支持需在 smoke 阶段验证。如果 smoke 报错或止损未触发，fallback 方案：把 `minute_level_stop_loss` 改为 `handle_data` 驱动。

**fallback 代码（仅当 every_bar 不支持时使用）：**

在 `initialize` 末尾把 `run_daily(minute_level_stop_loss, time='every_bar')` 改为删除该行，并在文件末尾 `def trade(context): pass` 之后加：

```python
def handle_data(context, data):
    """V2 平台 handle_data：每根分钟 bar 驱动分钟级止损（every_bar fallback）。"""
    minute_level_stop_loss(context)
```

注意：此 fallback 仅在 every_bar 不支持时启用。Task 3 smoke 会验证哪种方式工作。

#### 改动 4：record 中文变量名验证

原版第 856-858 行：

```python
if g.is_a_share_weak:
    status_str += f" (已持续{g.weak_days_count}/{g.max_weak_days}个交易日)"
    record(走弱期状态=1)
else:
    record(走弱期状态=0)
```

`record(走弱期状态=1)` 用了中文变量名。V2 平台 `record` 函数（bridge line 925）是否支持中文键名需在 smoke 验证。如果不支持，fallback：改为英文键名 `record(weak_period_status=1)`。

**此改动在 smoke 阶段验证后决定是否启用，不在移植时预先改动（保持全机械原则）。**

### 执行步骤

- [ ] **Step 1: 复制原版源码到策略文件**

```bash
# 在 WSL 内执行（平台路径用 WSL 格式）
platformWsl=$(powershell -ExecutionPolicy Bypass -File "E:/【笔记库】/量化研究库_V2.0.0/tools/Get-QuantPlatformRoot.ps1" -Format WSL | tr -d '\r')
cp "C:\Users\Administrator\.zcode\tmp\paste-attachments\2026-07-07\pasted-text-20260707-211719-e4843d8b.txt" "$platformWsl/src/strategies/research/wufu_etf_momentum_jq.py"
```

预期：文件创建成功，1265 行。

- [ ] **Step 2: 加文件头 docstring（改动 1）**

在文件最顶部（第 1 行 `# 克隆自聚宽文章` 之前）插入改动 1 的 docstring。原版的注释行 `# 克隆自聚宽文章：...` 保留在 docstring 之后作为历史出处记录。

用 Edit 工具，old_string 匹配原版第 1-9 行的注释和 import：

```
# 克隆自聚宽文章：https://www.joinquant.com/post/74243
# 标题：【五福闹新春】v5.2-已解密。别再被13:10狙击了，快跑
# 作者：烟花三月ETF

import numpy as np
```

new_string 为改动 1 的 docstring + 原版注释 + import。

- [ ] **Step 3: 成本参数化（改动 2）**

用 Edit 工具，old_string 匹配原版第 15-16 行的 set_slippage + set_order_cost，new_string 为改动 2 的参数化代码（含 params 读取）。

注意：params 读取要放在 `initialize` 函数体最开头（`set_option` 之前）。原版第 13 行 `set_option("avoid_future_data", True)` 之前插入 params 读取。

- [ ] **Step 4: 确认 every_bar 和 record 暂不改动**

改动 3（every_bar fallback）和改动 4（record 中文变量名）在 Task 3 smoke 验证后决定。移植阶段保持原版不动。

- [ ] **Step 5: py_compile 语法检查**

```bash
platformWsl=$(powershell -ExecutionPolicy Bypass -File "E:/【笔记库】/量化研究库_V2.0.0/tools/Get-QuantPlatformRoot.ps1" -Format WSL | tr -d '\r')
wsl -- bash -lc "cd '$platformWsl' && python3 -m py_compile src/strategies/research/wufu_etf_momentum_jq.py && echo 'py_compile OK'"
```

预期输出：`py_compile OK`（无 SyntaxError）。

如果报错：检查缩进、中文编码、引号匹配。修复后重新编译。

- [ ] **Step 6: 提交策略文件**

```bash
cd "E:/量化平台_V1.4.0"
git add src/strategies/research/wufu_etf_momentum_jq.py
git commit -m "feat(WUFU): 五福闹新春v5.2全机械移植+成本参数化

原版1265行全机械复制，4处平台适配：
- 文件头docstring（仿etf_env_temp_strategy.py）
- 成本参数化（cost_multiplier/slippage_rate/commission_rate，仿v_tech_momentum_jq.py）
- every_bar和record中文变量名待smoke验证

关联：RD-20260707T135354Z-main-WUFU / EX-20260707T135354Z-main-WUFU"
```

---

## Task 2: 未来函数静态审计 6 项

**Files:**
- Modify: `04_实验记录/EX-20260707T135354Z-main-WUFU_五福闹新春全机械移植与5项门禁预注册.md`（第 8 节审计表格）

**Interfaces:**
- Consumes: Task 1 产出的策略文件 `wufu_etf_momentum_jq.py`
- Produces: 审计结论（6 项全通过 = formal 前置门禁通过；任一失败 = 需修复后重审）

### 审计方法

逐项检查策略代码 + V2 平台 bridge 行为，填写 EX-WUFU 第 8 节表格。每项必须有"结论"（通过/失败/有条件通过）和"证据"（代码行号 + bridge 行为说明）。

### 审计项

- [ ] **Step 1: 审计项 1 — `avoid_future_data=True` 生效确认**

检查策略文件 `initialize` 里 `set_option("avoid_future_data", True)` 是否存在（原版第 13 行）。
查阅 `jq_bridge.py` line 856 确认 bridge 实际截断行为。
预期结论：通过（bridge 已实现 avoid_future_data 截断）。

- [ ] **Step 2: 审计项 2 — 13:10 动量计算的 today_vol 日内数据口径**

检查 `get_volume_ratio` 函数（原版第 765-785 行）：`today_vol` 来自 `get_price(..., frequency='1m', ...)`，`elapsed_minutes` 基于 `context.current_dt` 计算。
确认 13:10 时点只用到 13:10 之前的分钟数据（bridge 的 `current_data_policy="joinquant"` 截断口径）。
查阅 `聚宽API底层语义兼容审计_2026-05-27.md` 确认分钟数据时间戳口径。
预期结论：通过（或需注明口径差异）。

- [ ] **Step 3: 审计项 3 — `get_current_data().last_price` 13:10 时点未来信息检查**

检查 `get_final_ranked_etfs`（原版第 915 行 `current_price = current_data[etf].last_price`）。
确认 13:10 时点 `last_price` 是"调度时间戳对应的已完成分钟截面"，不含 13:10 之后的未来信息。
查阅 `聚宽API底层语义兼容审计_2026-05-27.md`。
预期结论：通过（bridge 已校准分钟口径）。

- [ ] **Step 4: 审计项 4 — `attribute_history` 盘中截断口径**

检查 `check_a_share_weak_period`（原版第 800 行 `attribute_history(code, g.weak_period_ma_lookback + 1, '1d', ['close'])`）。
确认 `close[-1]` 在 09:40 盘中调用时是 T-1 收盘（avoid_future_data 截断），不是 T 日收盘。
查阅 bridge line 577（attribute_history 实现）。
预期结论：通过（avoid_future_data=True 时盘中截到 previous_date）。

- [ ] **Step 5: 审计项 5 — `check_a_share_weak_period` 的 close[-1] 是 T-1 还是 T 日**

与审计项 4 同源。重点确认 09:40 调用时点 `close[-1]` 不含 T 日未来数据。
如果 close[-1] 是 T-1，则走弱期判断基于 T-1 收盘，无未来函数。
预期结论：通过（等价 shift(1)）。

- [ ] **Step 6: 审计项 6 — `update_sector_pool` 的 end_date 确认**

检查 `update_sector_pool`（原版第 521 行 `end_date = context.previous_date`）。
确认动态池构建用 `context.previous_date`，不含 T 日数据。
查阅 bridge line 372-384（context.previous_date 实现）。
预期结论：通过（previous_date 是 T-1 日历日）。

- [ ] **Step 7: 填写审计表格到 EX-WUFU**

把 6 项结论填入 `04_实验记录/EX-20260707T135354Z-main-WUFU_五福闹新春全机械移植与5项门禁预注册.md` 第 8 节表格。

格式：
```
| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| avoid_future_data=True 生效确认 | 通过 | 原版L13 set_option + bridge L856 实现截断 |
| ...（6 项全填）| ... | ... |
```

- [ ] **Step 8: 审计结论判定**

6 项全通过 → formal 前置门禁通过，可进 Task 3 smoke。
任一失败 → 修复策略代码后重新审计，不得跳过。

- [ ] **Step 9: 提交审计结论**

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
git add "04_实验记录/EX-20260707T135354Z-main-WUFU_五福闹新春全机械移植与5项门禁预注册.md"
git commit -m "audit(WUFU): 未来函数静态审计6项完成

6项结论：[填入X项通过/Y项有条件通过]
关联：EX-20260707T135354Z-main-WUFU"
```

---

## Task 3: smoke 配置 + 跑 smoke + 验证移植正确性

**Files:**
- Create: `${QUANT_PLATFORM_ROOT}/configs/research/RD-20260707T135354Z-main-WUFU/EX-20260707T135354Z-main-WUFU/smoke_2024q1.json`
- Modify: `04_实验记录/EX-20260707T135354Z-main-WUFU_五福闹新春全机械移植与5项门禁预注册.md`（回填执行记录）

**Interfaces:**
- Consumes: Task 1 策略文件 + Task 2 审计通过
- Produces: smoke 结果（summary.json + run.log），验证移植正确性

### smoke 配置

- [ ] **Step 1: 创建配置目录**

```bash
platformWsl=$(powershell -ExecutionPolicy Bypass -File "E:/【笔记库】/量化研究库_V2.0.0/tools/Get-QuantPlatformRoot.ps1" -Format WSL | tr -d '\r')
wsl -- bash -lc "mkdir -p '$platformWsl/configs/research/RD-20260707T135354Z-main-WUFU/EX-20260707T135354Z-main-WUFU'"
```

- [ ] **Step 2: 创建 smoke 配置文件**

配置内容（仿 `configs/research/R010-A11/env_temperature/smoke/smoke_2024_01.json`）：

```json
{
  "name": "wufu_smoke_2024q1",
  "strategy_type": "joinquant",
  "strategy_file": "src/strategies/research/wufu_etf_momentum_jq.py",
  "strategy_params": {
    "wufu": {
      "cost_multiplier": 1.0,
      "slippage_rate": 0.0001,
      "commission_rate": 0.0001,
      "min_commission": 5
    }
  },
  "output_dir": "results/v2/research/RD-20260707T135354Z-main-WUFU/EX-20260707T135354Z-main-WUFU/smoke/2024q1",
  "runtime_maintenance": {
    "enabled": true,
    "clear_minute_cache_daily": true,
    "compact_cache_days": 7,
    "gc_days": 7,
    "malloc_trim_days": 7,
    "memory_log_days": 7
  },
  "backtest": {
    "start": "2024-01-01",
    "end": "2024-03-31",
    "capital": 100000,
    "data_types": ["bar", "minute"]
  },
  "data_requirements": {
    "daily": true,
    "features": [],
    "warmup_days": 60,
    "minute": {
      "enabled": true,
      "symbols_scope": "dynamic",
      "start_time": "09:30",
      "end_time": "15:00",
      "max_symbols_per_month": 300,
      "cache_months": 2,
      "event_times_only": false,
      "current_data_policy": "joinquant"
    }
  }
}
```

注意：
- `strategy_params.wufu` 的键名 `wufu` 必须和策略文件 `initialize` 里 `params = getattr(context, "params", {})` 读取的子键一致。如果 V2 平台要求 params 顶层就是参数（无子键包裹），改为直接把参数放 `strategy_params` 顶层。需参照 `etf_env_temp_strategy.py` 的配置确认格式。
- `data_types: ["bar", "minute"]` 触发分钟回测。
- `warmup_days: 60` 给 25 日动量窗口留预热。
- `symbols_scope: "dynamic"` 让平台自动加载策略用到的 ETF 分钟数据。
- `capital: 100000` 与原版一致。

- [ ] **Step 3: 确认 strategy_params 格式**

查阅 `configs/research/R010-A11/env_temperature/smoke/smoke_2024_01.json` 确认 `strategy_params` 是否有子键包裹（如 `"etf_env_temp": { ... }`）。

如果有子键包裹，策略文件 `initialize` 里 params 读取要对应：
```python
params = (getattr(context, "params", {}) or {}).get("wufu", {})
```

如果没有子键包裹（参数直接在 strategy_params 顶层），则：
```python
params = getattr(context, "params", {}) or {}
```

根据确认结果调整 Task 1 Step 3 的 params 读取代码。如果需要改策略文件，改后重新 py_compile。

- [ ] **Step 4: 跑 smoke 回测**

单段 3 个月，预估 < 10 分钟。用前台运行（PYTHONUNBUFFERED=1 + tee）：

```bash
platformWsl=$(powershell -ExecutionPolicy Bypass -File "E:/【笔记库】/量化研究库_V2.0.0/tools/Get-QuantPlatformRoot.ps1" -Format WSL | tr -d '\r')
wsl -- bash -lc "cd '$platformWsl' && export PYTHONPATH=src PYTHONUNBUFFERED=1 && python3 src/run_v2_backtest.py --config configs/research/RD-20260707T135354Z-main-WUFU/EX-20260707T135354Z-main-WUFU/smoke_2024q1.json 2>&1 | tee tmp/wufu_smoke.log"
```

预期：5 分钟内报告第一段速度，10 分钟内完成，生成 `summary.json`。

如果超 10 分钟：改用 `Run-VisibleBacktest.ps1` 弹窗运行，每 2 分钟巡检 `tmp/live_wufu_smoke.log`。

- [ ] **Step 5: 验证 smoke 跑通（无崩溃）**

检查 `tmp/wufu_smoke.log` 末尾和 `results/v2/research/RD-...WUFU/EX-...WUFU/smoke/2024q1/summary.json`：

```bash
platformWsl=$(powershell -ExecutionPolicy Bypass -File "E:/【笔记库】/量化研究库_V2.0.0/tools/Get-QuantPlatformRoot.ps1" -Format WSL | tr -d '\r')
wsl -- bash -lc "cd '$platformWsl' && cat results/v2/research/RD-20260707T135354Z-main-WUFU/EX-20260707T135354Z-main-WUFU/smoke/2024q1/summary.json 2>/dev/null | head -30"
```

预期：summary.json 存在，含 `final_value` / `total_return` / `max_drawdown` / `trades_count` 等字段，`exit_status=0`。

如果崩溃（NameError/AttributeError/KeyError）：
- `NameError: name 'get_security_name' is not defined` → 原版已有 `def get_security_name`（L1240），检查是否被正确复制。
- `AttributeError: 'NoneType' object has no attribute 'display_name'` → `get_security_info` 返回 None，portal 缺失该 ETF 元数据。
- `KeyError` on params → strategy_params 格式不对，回 Step 3 调整。

- [ ] **Step 6: 验证 display_name 覆盖度（最高风险点）**

从 run.log 提取 `update_sector_pool` 的日志，统计 display_name 覆盖度：

```bash
platformWsl=$(powershell -ExecutionPolicy Bypass -File "E:/【笔记库】/量化研究库_V2.0.0/tools/Get-QuantPlatformRoot.ps1" -Format WSL | tr -d '\r')
wsl -- bash -lc "cd '$platformWsl' && grep -c 'display_name' tmp/wufu_smoke.log; grep '动态池更新' tmp/wufu_smoke.log | tail -10"
```

预期：动态池构建非空（`动态池共N只ETF`，N > 50），无大量 display_name 退化为代码字符串的警告。

如果 display_name 覆盖度 < 80%（大量 ETF 退化为代码字符串）：
- 记录为移植风险，在 EX-WUFU 标注。
- 评估是否降级为"固定池 only"（关闭 update_sector_pool，只用 fixed_etf_pool）。
- 不直接修复（可能需要补 portal 元数据，超出阶段 0 范围）。

- [ ] **Step 7: 验证 every_bar 分钟止损机制**

从 run.log 提取分钟止损相关日志：

```bash
platformWsl=$(powershell -ExecutionPolicy Bypass -File "E:/【笔记库】/量化研究库_V2.0.0/tools/Get-QuantPlatformRoot.ps1" -Format WSL | tr -d '\r')
wsl -- bash -lc "cd '$platformWsl' && grep -c 'minute_level_stop_loss\|分钟级固定止损\|every_bar' tmp/wufu_smoke.log; grep '止损' tmp/wufu_smoke.log | head -5"
```

预期：如果 every_bar 被支持，run.log 里应有分钟级止损检查的日志（即使未触发止损，函数也应被调用）。

如果 every_bar 不被支持（run_daily 报错或止损函数从未调用）：
- 启用 Task 1 改动 3 的 fallback：删除 `run_daily(minute_level_stop_loss, time='every_bar')`，加 `handle_data` 函数。
- 重新 py_compile + 重跑 smoke。

- [ ] **Step 8: 验证 record 中文变量名**

从 run.log 检查是否有 record 相关报错：

```bash
wsl -- bash -lc "cd '$platformWsl' && grep -i 'record\|走弱期状态' tmp/wufu_smoke.log | head -5"
```

如果 record 中文变量名报错：
- 启用 Task 1 改动 4 的 fallback：`record(走弱期状态=1)` → `record(weak_period_status=1)`。
- 重新 py_compile + 重跑 smoke。

- [ ] **Step 9: 验证走弱期切换机制**

从 run.log 检查走弱期判断日志：

```bash
wsl -- bash -lc "cd '$platformWsl' && grep '走弱期\|正常期\|大A' tmp/wufu_smoke.log | head -20"
```

预期：每日 09:40 有走弱期判断日志，记录 4 指数 MA10 状态和最终走弱期判定。

- [ ] **Step 10: 验证动量计算和交易**

从 run.log 检查动量计算和买卖日志：

```bash
wsl -- bash -lc "cd '$platformWsl' && grep '动量得分\|买入\|卖出\|候选池\|最终目标' tmp/wufu_smoke.log | head -20"
```

预期：每日 13:10 有动量排序日志、候选池日志、买卖操作日志。3 个月 smoke 期间应有若干笔交易。

- [ ] **Step 11: 回填 EX-WUFU 执行记录**

把 smoke 结果填入 `04_实验记录/EX-20260707T135354Z-main-WUFU_五福闹新春全机械移植与5项门禁预注册.md`：

- 第 11 节"平台配置"：填配置路径
- 第 11 节"运行命令"：填实际运行命令
- 第 11 节"可见进度与日志"：填日志路径、进度可见性
- 第 11 节"结果路径"：填 summary.json 路径
- 第 12 节"实际观察"：填 smoke 收益/回撤/交易数 + display_name 覆盖度 + every_bar 是否工作 + 走弱期切换是否触发
- 第 15 节"偏差诊断"：填移植版与原版的口径差异

- [ ] **Step 12: 判定阶段 0 通过门槛**

通过门槛（全部满足）：
1. py_compile 通过 ✓
2. 未来函数静态审计 6 项全通过 ✓
3. smoke summary.json 生成 + exit_status=0 ✓
4. display_name 覆盖度 ≥ 80%（或已记录降级方案）✓
5. 动态池构建非空 ✓
6. every_bar 分钟止损机制工作（或已启用 handle_data fallback）✓
7. 走弱期切换机制有日志输出 ✓
8. 动量计算和交易有日志输出 ✓

全通过 → 阶段 0 完成，可进阶段 1 四段 formal。
任一失败 → 修复后重跑 smoke。

- [ ] **Step 13: 提交 smoke 结果**

```bash
cd "E:/量化平台_V1.4.0"
git add configs/research/RD-20260707T135354Z-main-WUFU/EX-20260707T135354Z-main-WUFU/smoke_2024q1.json
git commit -m "feat(WUFU): smoke配置+smoke验证通过

smoke 2024Q1结果：final_value=XXX, return=XX%, MDD=XX%, trades=XX
display_name覆盖度=XX%, every_bar=工作/fallback, 走弱期切换=触发N次
阶段0通过门槛：8/8满足

关联：EX-20260707T135354Z-main-WUFU"
```

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
git add "04_实验记录/EX-20260707T135354Z-main-WUFU_五福闹新春全机械移植与5项门禁预注册.md"
git commit -m "docs(WUFU): 回填阶段0执行记录+smoke验证结果

关联：EX-20260707T135354Z-main-WUFU"
```

---

## 自审

### 1. 规格覆盖

对照 EX-WUFU 预注册第 17 节阶段 0 要求：

| 规格要求 | 对应任务 | 覆盖 |
|----------|----------|------|
| 移植策略代码 | Task 1 Step 1-4 | ✓ |
| py_compile 语法检查 | Task 1 Step 5 | ✓ |
| 未来函数静态审计 6 项 | Task 2 Step 1-8 | ✓ |
| smoke 1 段短区间（2024-01~2024-03） | Task 3 Step 4 | ✓ |
| display_name 覆盖度验证 | Task 3 Step 6 | ✓ |
| 动态池构建验证 | Task 3 Step 6, 10 | ✓ |
| 通过门槛 | Task 3 Step 12 | ✓ |

### 2. 占位符扫描

- Task 1 Step 6 的 commit message 里有 `feat(WUFU): 五福闹新春v5.2全机械移植+成本参数化` — 这是 commit message 模板，不是代码占位符。✓
- Task 3 Step 12 的 commit message 里有 `final_value=XXX` — 这是待填入的 smoke 结果占位符，执行时替换为实际数字。标注明确。✓
- 无"TBD"/"TODO"/"以后再实现"/"添加适当的错误处理"等含糊描述。✓

### 3. 类型一致性

- Task 1 的 `params` 读取在 Step 3 定义，Task 3 Step 3 确认格式后可能调整。已注明"根据确认结果调整 Task 1 Step 3 的 params 读取代码"。✓
- Task 1 改动 3 的 `handle_data` fallback 在 Task 3 Step 7 验证后决定启用。函数名 `handle_data` 和 `minute_level_stop_loss` 一致。✓
- Task 1 改动 4 的 `record(weak_period_status=1)` fallback 在 Task 3 Step 8 验证后决定。变量名一致。✓
- 策略文件路径 `src/strategies/research/wufu_etf_momentum_jq.py` 在 Task 1 创建、Task 3 配置引用，一致。✓
- 配置路径 `configs/research/RD-20260707T135354Z-main-WUFU/EX-20260707T135354Z-main-WUFU/smoke_2024q1.json` 在 Task 3 创建，与命名规范一致。✓

### 4. 风险点标注

- **display_name 覆盖度**（最高风险）：Task 3 Step 6 专项验证，有降级方案（固定池 only）。
- **every_bar 支持**：Task 3 Step 7 验证，有 fallback（handle_data）。
- **record 中文变量名**：Task 3 Step 8 验证，有 fallback（英文键名）。
- **strategy_params 格式**：Task 3 Step 3 确认，可能需调整 Task 1 代码。
- **smoke 性能**：3 个月分钟回测可能超 10 分钟，有 Run-VisibleBacktest.ps1 降级方案。
