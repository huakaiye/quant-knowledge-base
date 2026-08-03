---
type: 实验记录
ex_id: EX-20260618T170619Z-main-YQBP
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: readonly_completed_wait_for_new_market_data
owner: main
created_at: 2026-06-18T17:06:19Z
updated_at: 2026-06-18T17:20:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块外部验证数据门禁
decision_ids: []
lit_ids:
  - LIT-20260617T220410Z-main-RDHA
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths: []
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T170619Z-main-YQBP/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T170619Z-main-YQBP/summary.json
quality_gate: completed_readiness_wait_for_new_market_data
subagent_call_ids: []
subagent_exemption: "当前多代理工具只有在用户显式要求子代理/委派/并行 agent 时才允许 spawn，本轮没有该授权；主控：main；时间：2026-06-18T17:12:00Z"
tags: [双池轮动, 防御模块, 低滞后, KFSQ, forward, 数据门禁, 只读检查]
---

# KFSQ forward新样本触发检查

## 关联链接

- 研究方向：
- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|双池轮动动量崩溃事前暴露管理]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[06_文献资料/00_待处理/LIT-20260617T220410Z-main-RDHA_顶刊拟合目标替代与动量崩溃前置暴露|顶刊拟合目标替代与动量崩溃前置暴露]]
- 前置实验：[[04_实验记录/EX-20260618T145033Z-main-KFSQ_confirmed_state单组件episode随机负控只读复核|KFSQ confirmed_state 单组件复核]]；[[04_实验记录/EX-20260618T153621Z-main-N3CD_KFSQ forward标签门禁监控器只读资产|N3CD forward 标签门禁监控器]]；[[04_实验记录/EX-20260618T160438Z-main-MESV_KFSQ forward补跑触发检查器只读资产|MESV 补跑触发检查器]]
- 产生的决策：待本实验完成后判断是否需要新增决策
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：平台在 MESV 之后是否已经出现足够的新交易日，值得重新跑 KFSQ forward 外部验证。  
我们原本预计：如果日线和分钟线仍停在 2026-06-18，就不应重复补跑，因为 H10 标签仍不会成熟。  
实际看到：日线和分钟线最大日期仍为 `2026-06-18`，相对 latest forward end 无共同新增交易日，`recommended_action=wait_for_new_market_data`。  
这说明：今天继续补跑 KFSQ forward 外部验证只会重复无标签短窗，不能减少不确定性。  
但还不能说明：即使有新增交易日，本实验也只判断能否补跑，不判断 KFSQ 是否有效。  
下一步要做：先运行只读触发检查；若 `recommended_action=run_kfsq_external_validation_now`，再另开外部验证复核；否则继续等待新数据。  

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 动量崩溃事前暴露管理]]。前置 KFSQ 只读复核把 `confirmed_state_run_len` 单组件推到外部验证候选，但 KZF8、N3CD、TRXX 和 MESV 都显示 forward H10 标签不足。当前非 R 方低滞后研究已经证伪多条日频、分钟和 FIP 代理路线，剩余能推进的不是继续扫参数，而是确认 KFSQ 是否出现新样本，或等待真实微观/实盘 dry-run 数据。

## 3. 实验前假设

只验证一个问题：截至本轮检查时，平台 `jq_bar_daily` 和 `jq_bar_minute_v2` 是否相对 TRXX/N3CD 的 latest forward end 出现足够共同新增交易日，使 KFSQ forward 标签值得重新刷新。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`daily_max_date` 和 `minute_max_date` 至少有共同新增交易日；`available_extra_trading_days >= required_extra_trading_days_for_first_unlabelled_h10` 时才允许补跑。
- 交易行为：无交易行为；本实验不跑组合回测、不改配置、不下单。
- 风险表现：不产生收益或回撤结论。
- 分段表现：不做分段收益判断，只输出数据就绪度。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| N3CD/TRXX readiness summary | 判断当前 H10 标签门槛和最新 forward 结束日 | `results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/readiness_monitor/summary.json` |
| ClickHouse 日线/分钟线最大日期 | 判断是否有新交易日 | `quant.jq_bar_daily`；`quant.jq_bar_minute_v2` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 只新增了日线但分钟线未新增，不能支持 forward 刷新。
- 只足够让第一批 H10 标签成熟，但总行数和 episode 仍达不到 `20` 行、`5` episode 的正式外部验证门槛。
- 数据已经新增但不是完整交易日，不能自动升级为外部验证结论。

## 7. 证伪条件

出现以下情况，本假设不通过：

- `recommended_action=wait_for_new_market_data`，说明仍不该补跑。
- `available_extra_trading_days < required_extra_trading_days_for_first_unlabelled_h10`。
- ClickHouse 查询失败或日线/分钟线日期不一致，无法证明新样本就绪。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预注册为只读检查 | 只查询数据库已有最大日期和 N3CD/TRXX summary |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 不生成交易信号、不计算收益 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 不读取候选池或成分池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不读取财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 预注册通过边界 | 本实验只决定是否值得补跑，不改变 shadow/observe/默认策略 |

负控或错位检查：

- 无收益负控；本实验的负控是“如果没有足够新交易日，则不得补跑外部验证”。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 无参数搜索，只用 N3CD/MESV 固定门槛 |
| 样本内、验证集、样本外划分清楚 | 通过 | 只检查 forward 数据是否新增，不评估历史样本 |
| 邻近参数敏感性合理 | 不适用 | 无可调参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 不生成交易或收益 |
| 已做消融或负控 | 通过 | 无新交易日则禁止补跑 |
| 未只报告最优结果 | 通过 | 单一固定检查器，完整输出 summary 和 CSV |

证据等级：`L1_readiness_check`

## 10. 子代理调用记录

适配判断：`适合调用，但系统工具规则禁止未授权 spawn`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具只有在用户显式要求子代理/委派/并行 agent 时才允许 spawn，本轮没有该授权；主控：main；时间：2026-06-18T17:12:00Z。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T170619Z-main-YQBP | 无 | SUBTASK-KFSQ-RERUN-READINESS-EXEMPT | 无 | 2026-06-18T17:12:00Z | 研究库入口和方法论；平台 AGENTS；N3CD/TRXX/MESV 前置结果；KFSQ readiness 脚本 | 本实验记录；只读检查脚本新增可选 `--ex-id` 参数；实验台账和方向页已同步 | `check_kfsq_forward_rerun_readiness.py` | 只判断是否值得补跑，不判断 KFSQ 是否有效 | 实盘根未配置；平台数据未新增 | 主控已复核 summary/CSV 和日志 | 支持继续等待新数据，不新增交易决策 |

台账行：`01_台账/子代理调用台账.csv` 已登记。

## 11. 执行记录

### 平台配置

```text
无独立回测配置；使用平台只读脚本 `scripts/research/check_kfsq_forward_rerun_readiness.py`。
```

### 运行命令

```bash
mkdir -p results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T170619Z-main-YQBP && \
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/check_kfsq_forward_rerun_readiness.py \
  --ex-id EX-20260618T170619Z-main-YQBP \
  --output-dir results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T170619Z-main-YQBP \
  2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T170619Z-main-YQBP/run_yqbp_readiness.log
```

### 可见进度与日志

- 是否过程可见：是，`tee` 输出并保存日志
- 日志路径：`results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T170619Z-main-YQBP/run_yqbp_readiness.log`
- 查看进度命令：运行中直接查看终端输出；运行后读取日志
- 异常判断：脚本非 0 退出、ClickHouse 查询失败、summary 缺失或 JSON 无法解析
- 后台回测豁免：不适用，前台只读检查

```text
如后台或静默运行，必须写：
后台回测豁免：<原因>
进程标识：<pid或任务名>
日志路径：<path>
查看进度：<command>
停止方式：<command>
预计耗时：<duration>
```

### 结果路径

```text
results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T170619Z-main-YQBP/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| daily_max_date | MESV 为 `2026-06-18` | `2026-06-18` | 无新增 | 日线没有推进到新交易日 |
| minute_max_date | MESV 为 `2026-06-18` | `2026-06-18` | 无新增 | 分钟线也没有推进到新交易日 |
| latest_forward_end | TRXX latest forward end `2026-06-18` | `2026-06-18` | 无变化 | 当前数据没有超出已补跑窗口 |
| available_extra_trading_days | 至少 `1` 才可让最早未成熟 H10 候选成熟 | `0` | 未达标 | 不应补跑 |
| current_h10_labelable_rows | 门槛 `>=20` | `0` | 未达标 | 仍不能外部验证 |
| current_h10_labelable_episode_count | 门槛 `>=5` | `0` | 未达标 | 仍不能外部验证 |
| projected_rows_after_current_candidates_labelled | 门槛 `>=20` | `3` | 仍差 `17` | 即使当前候选全成熟也不够 |
| projected_episodes_after_current_candidates_labelled | 门槛 `>=5` | `1` | 仍差 `4` | episode 也不够 |
| recommended_action | 希望看到 `run_kfsq_external_validation_now` 或至少 `optional_incremental_forward_rerun_then_monitor` | `wait_for_new_market_data` | 不通过 | 继续等待新市场数据 |

## 13. 支持证据

- 输出 summary 和 CSV 均写入 `results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T170619Z-main-YQBP/`。
- 日线最大日期与分钟线最大日期一致，都是 `2026-06-18`，没有数据源错配。
- `common_data_dates_after_forward_json=[]`，明确说明 latest forward end 之后没有共同新增交易日。

## 14. 反对证据

- H10 标签仍为 `0/0`，KFSQ 不能升级。
- 当前候选即使全部成熟也只有 `3` 行、`1` 个 episode，距离 `20/5` 正式门槛仍很远。
- 本机实盘根路径未配置，不能转向真实 dry-run 或委托成交日志。

## 15. 偏差诊断

实际结果与预测一致：平台数据没有超过 `2026-06-18`。这不是 KFSQ 信号失败，而是外部验证样本仍不足。

## 16. 研究判断

建议状态：`observe`

理由：本实验只完成数据触发检查，不产生交易结论。它支持维持既有 6JF6/MESV 路线判断：KFSQ 仍是外部验证候选，但当前不能补跑、不能升级，也不能判死。

## 17. 下一步

下一轮最值得做的动作仍是等待平台日线和分钟线共同新增交易日后，先重跑 YQBP/MESV 类触发检查；只有 `recommended_action` 不再是 `wait_for_new_market_data` 时，才新开 KFSQ forward 补跑或正式外部验证复核。
