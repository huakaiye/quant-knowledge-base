---
type: 实验记录
ex_id: EX-20260607T215224Z-main-LWC4
rd_id: RD-20260605T133318Z-main-H6V3
status: completed
stage: formal_strict_pass_forward_observe_gate
owner: main
created_at: 2026-06-07T21:52:24Z
updated_at: 2026-06-07T22:03:30Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: preflight_observe_gate
decision_ids:
  - DEC-20260607T185223Z-main-HH4B
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/formal/
  - configs/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/guard/
result_paths:
  - results/v2/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/formal/
  - results/v2/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/logs/formal/
summary_paths:
  - results/v2/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/summary/formal/
quality_gate: strict_12of12_forward_observe_pass
subagent_call_ids:
  - SUB-20260608T060000Z-main-A22DRYRUN-ENTRY
subagent_exemption:
tags:
  - A22
  - observe
  - forward
  - hard5
  - default_off
  - shadow
---

# A22默认关闭observe近端forward样本门禁

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动score过热拥挤机制模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 产生的决策：[[05_研究决策/DEC-20260607T185223Z-main-HH4B_A22原生forward shadow边界通过后观察决策|A22原生forward shadow边界通过后观察决策]]
- 前置实验：[[04_实验记录/EX-20260607T192201Z-main-YA5R_A22默认关闭observe硬5路径隔离审计|YA5R A22默认关闭observe硬5路径隔离审计]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：A22 在 hard5 默认路径下已经通过历史分段 shadow 隔离后，放到 2026-05-20 到 2026-06-05 这段新近 forward 样本里，是否仍然只写观察日志、不改变交易结果。

我们原本预计：如果 A22 observe 边界是真的，`forward_shadow_on` 和 `forward_shadow_off` 的订单、成交、持仓、净值和子组合净值应该完全一致；`forward_shadow_on` 只多出 A22 shadow 观察日志。

实际看到：12 个 strict gate 全部通过。`forward_shadow_on` 和 `forward_shadow_off` 的 final、MDD、交易数、费用和五类交易产物 hash 完全一致；`forward_shadow_on` 有 13 条 A22 shadow 日志，全部为 `no_hot_score_target`，`orders_changed_by_shadow=0`。

这说明：A22 默认关闭 observe 在 2026-05-20 到 2026-06-05 这个近端 forward 样本里没有污染 hard5 默认交易路径。

但还不能说明：即使门禁通过，也只能说明默认关闭观察链路在近端样本没有污染交易产物，不能说明 A22 有收益提升，也不能批准实盘启用或替代 hard5。

下一步要做：等待或配置 `${LIVE_TRADING_ROOT}` 后再做真实实盘系统 dry-run；本轮不新增 production 决策卡。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|H6V3 A22 score过热拥挤机制模块]] 的生产前观察链路门禁。前置 [[04_实验记录/EX-20260607T192201Z-main-YA5R_A22默认关闭observe硬5路径隔离审计|YA5R]] 已证明历史四段 hard5 默认路径下，A22 shadow-only 不改变交易产物；子代理只读核对提示下一步应优先做实盘系统 dry-run 或新 forward 样本。

本机当前 live 根路径缺口：

```text
powershell -ExecutionPolicy Bypass -File tools/Get-QuantPlatformRoot.ps1 -Target Live -Format All
结果：live root not found；.research.local.json 中 live_root_windows/live_root_wsl 为空。
```

因此本轮选择可执行的新近 forward 样本门禁：`2026-05-20` 至 `2026-06-05`。本样本很短，只用于工程隔离和时间边界检查，不用于收益判断。

## 3. 实验前假设

在 hard5 默认路径、A13/A22 live 均关闭、仅 `r010a22_hot_score_budget_shadow_enabled=true` 的情况下，A22 observe 在近端 forward 样本中只记录 shadow 日志，不改变任何交易产物。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`forward_shadow_on` 与 `forward_shadow_off` 的 final、max_drawdown、trades、fee_sum 差值为 0。
- 交易行为：`equity_curve.csv`、`positions.csv`、`subportfolio_equity.csv`、`orders.json`、`trades.csv` 的归一化 hash 全部一致。
- 风险表现：A13/A22 live 指纹为 0，`orders_changed_by_shadow=false`。
- 分段表现：近端 forward 单段 `forward_20260520_20260605` 的 12 个 strict gate 全部通过。
- 日志表现：`forward_shadow_on` 可见 A22 shadow 日志，`filter_mode=hard_cap`，日期顺序满足 `signal_date <= observe_date <= trade_date`。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `forward_shadow_off` | hard5 默认路径，不启用 A22 shadow | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/formal/forward_shadow_off/lwc4_forward_shadow_off_forward_20260520_20260605.json` |
| `forward_shadow_on` | hard5 默认路径，只启用 A22 shadow 观察 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/formal/forward_shadow_on/lwc4_forward_shadow_on_forward_20260520_20260605.json` |
| `double_on_guard` | 静态互斥样本，只检查 A13/A22 双开可被识别，不执行回测 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/guard/lwc4_double_on_guard_forward_20260520_20260605.json` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- forward 样本太短，没有触发足够多的换仓或极端状态，只能证明本段没有污染。
- hard5 过滤后 A22 shadow trigger 可能为 0，说明本轮验证的是默认路径隔离，不是 A22 live 行为。
- 平台回测环境通过，不等于实盘系统 runner、配置加载和 dry-run 边界已经通过。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 任一交易产物 hash 不一致，或 final、max_drawdown、trades、fee_sum 出现非零差异。
- `orders_changed_by_shadow=true` 或 A22 shadow 观察日志缺失。
- A13/A22 live 指纹出现在正式回测日志中。
- `signal_date`、`observe_date`、`trade_date` 顺序违规。
- 数据窗口未覆盖 2026-05-20 到 2026-06-05。
- `double_on_guard` 静态配置无法识别 A13/A22 双开。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 13 条 shadow 记录均满足 `signal_date <= observe_date <= trade_date` |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | shadow_on/off 订单、成交、持仓、净值和子组合净值 hash 全一致 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不在本轮新增 | 本轮不改股票池/ETF池，只复用前置 hard5 配置 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 双池 ETF 动量/状态路径，本轮不新增财务/宏观字段 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | A13/A22 live 指纹 0；`orders_changed_by_shadow=0` |

负控或错位检查：

- 本轮不做收益负控；`double_on_guard` 只作为静态互斥负控，确认 A13 与 A22 live 双开可被识别。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 仅两个 variant：`forward_shadow_off/on`；不搜索收益参数 |
| 样本内、验证集、样本外划分清楚 | 通过 | 近端 forward 样本在 YA5R 结束日 2026-05-19 之后 |
| 邻近参数敏感性合理 | 不适用 | 本轮不调参 |
| 成本、滑点或换手扰动已检查 | 不适用 | 本轮验证交易产物不变性，不验证收益优势 |
| 已做消融或负控 | 部分通过 | shadow on/off 消融 + double-on 静态 guard |
| 未只报告最优结果 | 通过 | 两个预注册 variant 全量汇总 |

证据等级：`L1`。本轮若通过，只能作为工程隔离和近端 forward 观察证据。

## 10. 子代理调用记录

适配判断：`适合调用`。本轮涉及 live/dry-run 入口、默认关闭观察边界和历史门禁复核，适合委派子代理做只读清单。

调用状态：`called`

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260608T060000Z-main-A22DRYRUN-ENTRY | Newton | SUBTASK-A22DRYRUN-ENTRY | gpt-5.3-codex-spark | 2026-06-08T06:00:00+08:00 | AGENTS、当前状态、研究驾驶舱、HH4B、YA5R、.research.local.json、平台 AGENTS 与 A22 脚本路径 | 无 | 无 | 只读核对：A22 只能 default-off observe；本机 live root 为空，不能完成实盘路径 dry-run；建议转向新 forward 样本或等待 live 配置 | 不能把 shadow/observe 当收益或实盘可用结论 | 主控采纳 live 根路径缺口和 forward 样本替代门禁，不采纳任何 promote 判断 | 决定 LWC4 只做平台近端 forward 工程门禁，并显式记录 live dry-run 未完成 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/scripts/research/generate_lwc4_a22_forward_observe_configs.py
${QUANT_PLATFORM_ROOT}/scripts/research/run_lwc4_a22_forward_observe.sh
${QUANT_PLATFORM_ROOT}/scripts/research/summarize_lwc4_a22_forward_observe.py
${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONIOENCODING=utf-8 python3 scripts/research/generate_lwc4_a22_forward_observe_configs.py
DRY_RUN=1 PYTHONIOENCODING=utf-8 bash scripts/research/run_lwc4_a22_forward_observe.sh
STAMP=<utc> PYTHONIOENCODING=utf-8 bash scripts/research/run_lwc4_a22_forward_observe.sh
PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_lwc4_a22_forward_observe.py --strict
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/logs/formal/<STAMP>/`
- 查看进度命令：`Get-Content -Wait <run.log>`
- 异常判断：runner 退出非 0 且没有 fresh summary；或 summary strict gate 任一失败。
- 后台回测豁免：不使用后台回测。

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/formal/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/logs/formal/20260607T220100Z/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/forward_observe/EX-20260607T215224Z-main-LWC4/summary/formal/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| strict gate | 12 | 12/12 | 通过 | 近端 forward observe 门禁 clean |
| final_value | 104605.95 | 104605.95 | 0.00 | shadow_on/off 完全一致 |
| max_drawdown | -5.20% | -5.20% | 0.00 | shadow 不影响风险路径 |
| trades | 25 | 25 | 0 | shadow 不改变成交 |
| fee_sum | 257.95 | 257.95 | 0.00 | shadow 不改变费用 |
| shadow records | 0 | 13 | +13 | 只多观察日志 |
| shadow triggers | 0 | 0 | 0 | 本段全部为 `no_hot_score_target` |
| data window | 3/3 | 3/3 | 通过 | 日线、交易日、分钟线均覆盖 2026-05-20 至 2026-06-05 |

## 13. 支持证据

- `summary.json`：`all_gates_pass=true`，`strict_failed=[]`，12 个 gates 全 true。
- `shadow_on_off_hash.csv`：final/MDD/trade/fee 差值全 0，orders/trades/equity/positions/subportfolio hash 全匹配。
- `segment_metrics.csv`：两条正式运行 run log exit_status 均为 0，manifest config sha 均匹配，A13/A22 live 指纹均为 0。
- `data_window.csv`：`jq_bar_daily`、`jq_trade_days`、`jq_bar_minute_v2` 均覆盖到 2026-06-05，窗口内分别有 82950、13、20344104 行。

## 14. 反对证据

- 本机 `${LIVE_TRADING_ROOT}` 未配置，因此本轮不能覆盖真实实盘系统 dry-run。
- 样本仅 13 个交易日，不用于收益判断。
- 13 条 shadow 记录均为 `no_hot_score_target`，说明本轮验证仍是 hard5 默认路径观察隔离，不是 A22 live 触发质量。

## 15. 偏差诊断

实际结果与实验前预测一致。主要偏差不在数据结果，而在执行范围：真实 live 根路径缺失，本轮只能完成平台 forward 样本门禁，不能替代实盘系统 dry-run。

## 16. 研究判断

建议状态：`observe_completed`

理由：LWC4 补齐了 YA5R 之后的近端 forward 样本隔离证据，但证据性质仍是工程观察链路。默认 hard5 不变，HH4B 的默认关闭 observe 决策不变，不新增 production promote 决策卡。

## 17. 下一步

等待或配置 `${LIVE_TRADING_ROOT}` 后做真实实盘系统 dry-run 门禁。若继续研究 A22 收益有效性，必须另开样本外/成本扰动/参数敏感性实验，不能使用 LWC4 的 observe 结果直接升级。
