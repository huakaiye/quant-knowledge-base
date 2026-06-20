---
type: 实验记录
ex_id: EX-20260618T160438Z-main-MESV
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: readonly_tool_completed_wait_for_new_market_data
owner: main
created_at: 2026-06-18T16:04:38Z
updated_at: 2026-06-18T16:12:00Z
strategy_id: 双池轮动
module_type: 外部验证数据门禁
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths: []
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T160438Z-main-MESV/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T160438Z-main-MESV/summary.json
quality_gate: wait_for_new_market_data
subagent_call_ids:
  - SUB-EXEMPT-20260619T000000Z-main-FWDGATE
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - MCYG
  - KFSQ
  - forward
  - readonly
  - label_gate
---

# KFSQ forward补跑触发检查器只读资产

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 双池轮动动量崩溃事前暴露管理]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[04_实验记录/EX-20260618T154810Z-main-TRXX_KFSQ forward补跑20260618标签门禁复核|TRXX 2026-06-18 标签门禁复核]]
- 产生的决策：无新增，沿用 [[05_研究决策/DEC-20260618T152400Z-main-6JF6_KFSQ forward外部验证数据不足后继续等待新样本|6JF6 KFSQ forward 外部验证数据不足后继续等待新样本]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：现在已经是 2026-06-19，但平台日线和分钟线是否真的有 2026-06-19 数据，是否值得继续补跑 KFSQ forward。  
我们原本预计：如果平台数据仍只到 2026-06-18，继续跑 forward 只会重复 TRXX 的无标签短窗；更好的做法是先做一个自动触发检查器。  
实际看到：平台日线最大日期 `2026-06-18`，分钟线最大日期 `2026-06-18`；TRXX forward 也已经跑到 `2026-06-18`。可用新增交易日为 `0`，而最早未成熟 H10 标签还需要 `1` 个额外交易日。  
这说明：今天当前环境不能合法补跑到 2026-06-19；推荐动作是 `wait_for_new_market_data`。  
但还不能说明：KFSQ 有效或无效；它只说明当前数据还没有推进到下一次可解释验证点。  
下一步要做：等日线和分钟线同时出现 `2026-06-19` 或更晚日期后，再用本检查器判断是否补跑；正式外部验证仍需 H10 `>=20` 行且 `>=5` episode。

## 2. 研究背景

[[04_实验记录/EX-20260618T154810Z-main-TRXX_KFSQ forward补跑20260618标签门禁复核|TRXX]] 已确认：补跑到 2026-06-18 后，H10 可标注仍为 `0/0`，最早候选还差 `1` 个交易日。今天进入 2026-06-19 后，直觉上可能想继续补跑。但研究纪律要求先检查平台数据是否真的更新，否则只会重复同一段 forward。

本实验建设一个只读触发检查器：读取 TRXX/N3CD 的 `summary.json`，查询 ClickHouse 日线和分钟线的最新日期，输出是否值得补跑。

## 3. 实验前假设

如果平台日线和分钟线尚未超过 TRXX 的 `latest_forward_end=2026-06-18`，则不应启动新的 forward 补跑。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`daily_max_date=2026-06-18`，`minute_max_date=2026-06-18`，`available_extra_trading_days=0`，`recommended_action=wait_for_new_market_data`。
- 交易行为：不运行回测，不生成交易，不改 shadow/observe/live 配置。
- 风险表现：不评价收益或风险，只评价数据是否足以推进标签。
- 分段表现：不适用；这是工具资产和数据门禁检查。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| TRXX readiness summary | 判断最新 forward 截止日和 H10 等待天数 | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/readiness_monitor/summary.json` |
| ClickHouse 日线表 | 判断是否有新日线交易日 | `quant.jq_bar_daily` |
| ClickHouse 分钟线表 | 判断是否有新分钟线交易日 | `quant.jq_bar_minute_v2` |

## 6. 竞争性解释

即使推荐等待，也可能是：

- 数据更新流程稍后才完成，当前只是日内暂未入库。
- 日线已更新但分钟线未更新；此时仍不适合运行当前需要分钟数据的配置。
- 团队其他机器已有 dry-run 或实盘记录，但本机 `${LIVE_TRADING_ROOT}` 未配置，当前环境不可见。

## 7. 证伪条件

出现以下情况，本假设不通过：

- ClickHouse 日线和分钟线都已经存在 `2026-06-19` 或更晚日期。
- `available_extra_trading_days >= required_extra_trading_days_for_first_unlabelled_h10`。
- 检查器误判已有新交易日为不可用，或无法解析 TRXX summary。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 只读查询 ClickHouse 已入库最大日期，不请求或更新外部数据 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 本实验不生成信号、不运行回测 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 本实验不读取股票池或 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本实验不使用财务、宏观或估值字段 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 只读工具，不写 shadow/observe/live 配置 |

负控或错位检查：本实验是数据门禁工具，不测试策略收益。它的负控是平台数据未超过 forward end 时必须输出 `wait_for_new_market_data`。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 固定读取 TRXX summary、日线表、分钟线表 |
| 样本内、验证集、样本外划分清楚 | 通过 | 历史 KFSQ 校准截至 2026-05-19；本实验只检查 2026-06-18 之后是否有新数据 |
| 邻近参数敏感性合理 | 不适用 | 无策略参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 不评价交易表现 |
| 已做消融或负控 | 不适用 | 数据门禁工具；正式外部验证前仍需随机和 shift 负控 |
| 未只报告最优结果 | 通过 | 输出所有关键门禁字段到 `rerun_readiness.csv` |

证据等级：`L1` 工具资产和数据门禁证据，不构成策略有效性证据。

## 10. 子代理调用记录

适配判断：适合调用，但当前工具环境受限。

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-19T00:00:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260619T000000Z-main-FWDGATE | 无 | SUBTASK-KFSQ-FORWARD-GATE-CONTINUE | 无 | 2026-06-19T00:00:00Z | TRXX summary；BYEX 数据就绪度记录；ClickHouse 日线/分钟线最大日期 | 本实验记录；平台只读触发检查器 | `check_kfsq_forward_rerun_readiness.py` | 只判断是否值得补跑，不判断 KFSQ 有效性 | 数据更新稍后可能发生 | 主控已复核 summary/CSV 和平台日期查询 | 维持等待，不运行新 forward |

台账行：见 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
无新增回测配置；新增只读脚本：
${QUANT_PLATFORM_ROOT}/scripts/research/check_kfsq_forward_rerun_readiness.py
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/check_kfsq_forward_rerun_readiness.py 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T160438Z-main-MESV/run_check.log
```

### 可见进度与日志

- 是否过程可见：是，使用 `PYTHONUNBUFFERED=1` 和 `tee`。
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T160438Z-main-MESV/run_check.log`
- 查看进度命令：`Get-Content -Tail 80 "${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T160438Z-main-MESV/run_check.log"`
- 异常判断：脚本非 0 退出、ClickHouse 查询失败、TRXX summary 缺字段、输出 summary/CSV 缺失。
- 后台回测豁免：不适用；本实验不是回测，前台可见运行。

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T160438Z-main-MESV/summary.json
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T160438Z-main-MESV/rerun_readiness.csv
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| latest_forward_end | TRXX | `2026-06-18` | 不变 | 已补跑到平台当前数据末端 |
| daily_max_date | 需要大于 forward end 才可补跑 | `2026-06-18` | 无新增 | 日线没有 2026-06-19 |
| minute_max_date | 需要大于 forward end 才可补跑 | `2026-06-18` | 无新增 | 分钟线没有 2026-06-19 |
| available_extra_trading_days | 至少 `1` | `0` | 不足 | 当前无共同新增交易日 |
| required_extra_trading_days_for_first_unlabelled_h10 | TRXX 输出 | `1` | 不变 | 最早候选还差 1 个交易日 |
| current_h10_labelable_rows/episode | 外部验证门槛 `20/5` | `0/0` | 不足 | 不能进入正式外部验证 |
| projected current candidates | 门槛 `20/5` | `3/1` | 不足 | 即使当前候选全部成熟也不够 |
| recommended_action | 预期等待 | `wait_for_new_market_data` | 符合预期 | 继续补跑会重复无标签短窗 |

## 13. 支持证据

- `summary.json` 显示 `daily_max_date=2026-06-18`、`minute_max_date=2026-06-18`、`common_data_dates_after_forward_json=[]`。
- `rerun_readiness.csv` 显示 `available_extra_trading_days=0`、`required_extra_trading_days_for_first_unlabelled_h10=1`。
- 脚本 `python3 -m py_compile scripts/research/check_kfsq_forward_rerun_readiness.py` 通过。
- 本机 `${LIVE_TRADING_ROOT}` 解析仍失败，因此没有可替代的实盘/dry-run 数据源。

## 14. 反对证据

- 没有反对“当前不应补跑”的证据。
- 该结论可能随数据入库改变；如果稍后出现 2026-06-19 日线和分钟线，应重新运行 MESV 检查器。

## 15. 偏差诊断

实验前预测和实际一致。额外确认的是：当前日期已到 2026-06-19，但平台数据仍停在 2026-06-18，所以“日历日期到了”不等于“可回测数据到了”。

## 16. 研究判断

建议状态：`readonly_tool_completed_wait_for_new_market_data`

理由：MESV 让下一步补跑从人工判断变成明确门禁：没有共同新增交易日时不跑；有新增交易日时先补跑并监控；正式外部验证仍必须等待 H10 `>=20` 行且 `>=5` episode。

## 17. 下一步

下一轮先运行 MESV 检查器。如果 `recommended_action=optional_incremental_forward_rerun_then_monitor`，可以新开补跑实验到最新共同交易日；如果仍是 `wait_for_new_market_data`，不要创建新 forward 实验。即使出现第一个 H10 标签，也只代表可以观察增量，不代表 KFSQ 通过。
