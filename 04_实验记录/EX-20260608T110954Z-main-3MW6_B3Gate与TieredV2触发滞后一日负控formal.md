---
type: 实验记录
ex_id: EX-20260608T110954Z-main-3MW6
rd_id: RD-20260605T115651Z-main-DEF0
status: active
stage: preregistered_ready_to_run
owner: main
created_at: 2026-06-08T11:09:54Z
updated_at: 2026-06-08T11:22:08Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块
decision_ids:
  - DEC-20260608T072559Z-main-B3QC
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-B4/EX-20260608T110954Z-main-3MW6/formal/manifest.json
  - configs/research/R010-B4/EX-20260608T110954Z-main-3MW6/formal/cap80_lag1_cost2x_slip2bps/
  - configs/research/R010-B4/EX-20260608T110954Z-main-3MW6/formal/tiered_v2_lag1_cost2x_slip2bps/
result_paths:
  - results/v2/research/R010-B4/EX-20260608T110954Z-main-3MW6/formal/
  - results/v2/research/R010-B4/EX-20260608T110954Z-main-3MW6/logs/formal/
summary_paths:
  - results/v2/research/R010-B4/EX-20260608T110954Z-main-3MW6/summary/formal/
quality_gate: L3_formal_negative_control_pending
subagent_call_ids:
  - SUB-20260608T110000Z-main-B3NC
subagent_exemption:
tags: [双池轮动, 防御模块, B3Gate, tiered-v2, 触发滞后, 负控, formal]
---

# B3Gate与TieredV2触发滞后一日负控formal

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|双池轮动防御模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 前置实验：[[04_实验记录/EX-20260608T005518Z-main-XK5W_B3Gate与TieredV2旧证据复核|B3Gate 与 TieredV2 旧证据复核]]
- 前置实验：[[04_实验记录/EX-20260608T041610Z-main-B3QC_B3Gate与TieredV2成本扰动formal|B3Gate 与 TieredV2 成本扰动 formal]]
- 前置决策：[[05_研究决策/DEC-20260608T072559Z-main-B3QC_B3Gate与TieredV2成本扰动通过后继续负控决策|B3Gate 与 TieredV2 成本扰动通过后继续负控决策]]
- 产生的决策：待定
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：B3Gate/tiered-v2 的防御效果是不是依赖“风险状态被及时识别并及时降仓”。  
我们原本预计：如果 B3Gate/tiered-v2 真有及时防御价值，把触发整体晚一个交易日后，它应该明显变弱，不能轻松复制 B3QC 的成本门禁结果。  
实际看到：待 formal 跑完后填写。  
这说明：待 formal 跑完后填写。  
但还不能说明：即使滞后负控通过，也仍不是生产 promote；它只说明“及时触发”这一关没有被负控直接反证。  
下一步要做：跑完 8 个 formal 配置，汇总 `lag_audit`、分段收益、分段最大回撤和复合收益，再决定是否进入下一道质量门禁。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|防御模块]]。

前置 [[04_实验记录/EX-20260608T005518Z-main-XK5W_B3Gate与TieredV2旧证据复核|XK5W]] 说明 B3Gate/tiered-v2 可以保留为防御仓位骨架：它相对 B3-gate-cap80 有更高拼接收益和更浅拼接回撤。但旧证据缺完整成本扰动和错位负控。

前置 [[04_实验记录/EX-20260608T041610Z-main-B3QC_B3Gate与TieredV2成本扰动formal|B3QC]] 已完成成本扰动 formal：`tiered_v2_cost2x_slip2bps` 复合收益 `12.1507` 高于 `cap80_cost2x_slip2bps` 的 `11.3111`，拼接最大回撤 `-28.22%` 好于 `-30.37%`，分段 final 与 MDD 均为 `3/4` 不差。

但 B3QC 只证明“优势没有被成本扰动直接吃掉”，还不能证明收益来自及时风险识别。因此本轮只做触发滞后一日负控，不扩 cap、阈值、状态标签或旧组合动作。

## 3. 实验前假设

B3Gate/tiered-v2 的有效性应当依赖及时触发；如果把 B3 persistence 触发输出整体滞后一交易日，tiered-v2 相对非滞后 tiered-v2 应明显变弱，并且不应继续完整复刻 B3QC 的成本门禁优势。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`tiered_v2_lag1_cost2x_slip2bps` 的复合收益低于 B3QC 非滞后 `tiered_v2_cost2x_slip2bps`。
- 交易行为：ACTION 日志中 `r010b3_all_weak_persistence_lag_applied=true`，`trigger_lag_days=1`，且 `lag_source_date` 不晚于 `trade_date`。
- 风险表现：滞后一日后，不应继续同时满足相对 cap80 的 `3/4` 分段 final 不低、`3/4` 分段 MDD 不差、2025 final 不低和拼接 MDD 不差。
- 分段表现：2024 压力段或其他 B3 关键保护段应出现保护效率下降；若完全不降，说明原优势可能来自较低平均仓位或触发窗口过宽。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| B3QC 非滞后 cap80 成本扰动 | 成本同口径基准 | `results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/segment_compare.csv` |
| B3QC 非滞后 tiered-v2 成本扰动 | 原始通过对象 | `results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/segment_compare.csv` |
| `cap80_lag1_cost2x_slip2bps` | cap80 本身滞后一日后的控制组 | `configs/research/R010-B4/EX-20260608T110954Z-main-3MW6/formal/cap80_lag1_cost2x_slip2bps/` |
| `tiered_v2_lag1_cost2x_slip2bps` | 本轮负控测试对象 | `configs/research/R010-B4/EX-20260608T110954Z-main-3MW6/formal/tiered_v2_lag1_cost2x_slip2bps/` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 滞后一日只是错过少数关键交易日，并不能说明全部 tiered-v2 机制稳健。
- tiered-v2 的收益可能仍有较低平均仓位贡献，需要后续仓位归因或静态仓位对照。
- 某个年份的压力行情主导了拼接收益，需要分段看支持和反对证据。
- 如果滞后负控仍表现很好，可能说明 B3Gate/tiered-v2 触发窗口过宽、状态标签不够精确，或存在路径依赖和过拟合。

## 7. 证伪条件

出现以下情况，本假设不通过：

- `tiered_v2_lag1_cost2x_slip2bps` 复合收益不低于非滞后 `tiered_v2_cost2x_slip2bps`。
- 滞后 tiered-v2 仍完整复刻 B3QC 成本门禁：相对非滞后 cap80 成本组复合收益更高、`>=3/4` 分段 final 不低、`>=3/4` 分段 MDD 不差、2025 final 不低，并且拼接 MDD 不差。
- ACTION 日志不能证明 `trigger_lag_days=1` 已生效，或出现 `lag_source_date >= trade_date` 的日期边界问题。
- 8 个 formal run 未全部完成，或存在未解释的错误日志、OOM 恢复混入正式结果而未单独标注。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预注册待检查 | 继承 B3QC cost2x/slip2bps 配置，只新增交易日 FIFO 滞后参数。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 预注册待检查 | 汇总脚本将审计 `lag_source_date` 与 `trade_date` 关系。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 继承前置 | 不修改 ETF 池、数据加载、动态池配置。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本实验不新增财务、宏观或估值字段。 |
| Shadow 或观察信号未被当成默认交易信号 | 预注册通过 | 本实验只在研究配置中打开滞后负控，不修改默认配置和实盘开关。 |

负控或错位检查：

- 本轮正式负控是 `r010b3_all_weak_persistence_trigger_lag_days=1`。
- 汇总输出 `lag_audit.csv`，检查 `lag_applied`、`lag_source_date` 和 `trigger_lag_days`。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 只跑 2 个变体、4 个分段：cap80 lag1 和 tiered-v2 lag1。 |
| 样本内、验证集、样本外划分清楚 | 通过 | 沿用 B3QC 四分段：2020_2021、2022_2023、2024、2025_20260519。 |
| 邻近参数敏感性合理 | 不在本轮 | 本轮禁止扩 lag2、cap、median、breadth、top5 或 persistence 阈值。 |
| 成本、滑点或换手扰动已检查 | 继承通过 | 配置继承 B3QC `cost2x/slip2bps`，不新增成本口径。 |
| 已做消融或负控 | 预注册待检查 | 本轮是触发滞后一日负控。 |
| 未只报告最优结果 | 预注册通过 | 汇总会报告 8/8 formal 和 B3QC 非滞后对照，不只看赢家。 |

证据等级：预注册阶段为 `L2_preregistered_negative_control`；formal 完成且日志审计通过后最多升级为 `L3_formal_negative_control`，仍不支持生产 promote。

## 10. 子代理调用记录

适配判断：适合调用。B3Gate/tiered-v2 负控涉及平台脚本、配置路径和默认边界，需要子代理只读核对。

调用状态：called

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260608T110000Z-main-B3NC | Lorentz | SUBTASK-20260608T110000Z-main-B3NC_子查_B3滞后负控路径核对 | inherited | 2026-06-08T11:00:00Z | B3QC/XK5W/U7FN/B3QC 决策、平台 R010-B4 配置和脚本 | 无 | 只读检索 | 只核对路径、脚本和默认边界，不判断 promote | 原 B3QC 日期审计不足以证明 lag 生效，需审计 lag 字段 | 主控采纳路径和边界建议，并在汇总脚本加入 lag 审计 | 支持本轮只开 lag1 formal，不扩 B3/tiered 参数 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
configs/research/R010-B4/EX-20260608T110954Z-main-3MW6/formal/cap80_lag1_cost2x_slip2bps/
configs/research/R010-B4/EX-20260608T110954Z-main-3MW6/formal/tiered_v2_lag1_cost2x_slip2bps/
```

配置校验：

- 8 个配置已生成，`manifest` 含 2 个变体和 4 个分段。
- 新配置已和 B3QC 源配置逐对比对；除 `name`、`output_dir`、`research_metadata` 和 `r010b3_all_weak_persistence_trigger_lag_days=1` 外，无其他参数差异。
- 未改默认策略，未扩 B3/tiered-v2 cap、median、breadth、top5、persistence 或 apply_days 参数。

### 运行命令

```bash
PYTHONUNBUFFERED=1 bash scripts/research/run_b3nc_trigger_lag_formal.sh
PYTHONPATH=src python3 scripts/research/summarize_b3nc_trigger_lag_formal.py
```

运行状态：尚未启动 formal。2026-06-08T11:22:08Z 检查到 WSL 内已有 `pid=661` 正在运行 `python3 src/run_v2_backtest.py --config configs/v2_migrate_80_small_cap.json`，脚本为避免抢占回测槽而拒绝并行启动。该进程不是本轮 B3NC 进程，主控未擅自终止。

### 可见进度与日志

- 是否过程可见：是，formal 脚本逐个分段输出并用 `tee` 写日志。
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260608T110954Z-main-3MW6/logs/formal/`
- 查看进度命令：`Get-Content -Tail 40 <log>` 或 WSL 内 `tail -f results/v2/research/R010-B4/EX-20260608T110954Z-main-3MW6/logs/formal/<log>`
- 异常判断：脚本会记录 `exit_status`；非 0 直接停止。
- 后台回测豁免：无，本轮过程可见前台运行。

### 结果路径

```text
results/v2/research/R010-B4/EX-20260608T110954Z-main-3MW6/formal/
results/v2/research/R010-B4/EX-20260608T110954Z-main-3MW6/summary/formal/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 8 个 formal run | 待执行 | 待执行 | 待执行 | 待执行 |

## 13. 支持证据

- 待 formal 完成后填写。

## 14. 反对证据

- 待 formal 完成后填写。

## 15. 偏差诊断

待 formal 完成后填写。

## 16. 研究判断

建议状态：`active_preregistered`

理由：预注册已完成，配置已生成，尚未运行 formal。

## 17. 下一步

1. 在 WSL 内运行 `scripts/research/run_b3nc_trigger_lag_formal.sh`。
2. 运行 `scripts/research/summarize_b3nc_trigger_lag_formal.py`。
3. 根据 summary 与 lag audit 补齐实际观察、支持证据、反对证据和决策卡。
