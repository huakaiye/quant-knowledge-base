---
type: 实验记录
ex_id: EX-20260618T161843Z-main-TTSK
rd_id: RD-20260618T161832Z-main-KDGD
status: completed
stage: readonly_completed_gate_failed_park
owner: main
created_at: 2026-06-18T16:18:43Z
updated_at: 2026-06-18T16:28:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动状态条件化锚定信号门禁
decision_ids: [DEC-20260618T162627Z-main-3SKD]
lit_ids: [LIT-20260614T112631Z-main-A9BK]
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/analyze_ttsk_state_conditioned_nearness_readonly.py
result_paths:
  - results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/
summary_paths:
  - results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/summary.json
quality_gate: failed_park_conditioned_nearness
subagent_call_ids: [SUB-EXEMPT-20260619T001600Z-main-NEXTDIR]
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags: [双池轮动, 52周高点, nearness, 状态条件化, 只读门禁, 负控失败]
---

# 状态条件化nearness只读门禁

## 关联链接

- 研究方向：[[02_研究方向/RD-20260618T161832Z-main-KDGD_双池轮动状态条件化52周高点锚定门禁|KDGD 状态条件化 52 周高点锚定门禁]]
- 来源方向：[[02_研究方向/RD-20260614T115209Z-main-R25X_双池轮动52周高点锚定信号|R25X 52 周高点锚定信号]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[06_文献资料/00_待处理/LIT-20260614T112631Z-main-A9BK_52周高点动量George Hwang 2004|52周高点动量 George Hwang 2004]]
- 产生的决策：[[05_研究决策/DEC-20260618T162627Z-main-3SKD_状态条件化52周高点门禁失败后park|3SKD 状态条件化 52 周高点门禁失败后 park]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：52 周高点 nearness 失败后，是否还能通过“只在普涨健康市场启用”来保留好处、避开坏处。  
我们原本预计：如果 `MCWS` 的问题真是状态依赖，那么 broad/healthy 状态里 nearness 应该有明显正增量，条件化后至少 `3/4` 分段不差。  
实际看到：样本量足够，但门禁失败。条件化 H5 正分段只有 `2/4`，2025 段仍为 `-0.0608pct`；总体 H5 增量只有 `+0.0089pct`，低于随机同池 p95 `+0.0856pct`。  
这说明：状态条件化不能救活 52 周高点路线。  
但还不能说明：所有非 R 方或所有顶刊信号都失败；它只否定“52 周高点 + A2 broad 状态门禁”这条具体修复。  
下一步要做：本方向 park；不做交易回测，不继续调状态阈值或 nearness 权重。

## 2. 研究背景

`R25X/MCWS` 已经做过 25 日和 252 日两轮验证，都是 `2/4` 段通过：2020-2021 和 2024 有正贡献，2022-2023 与 2025 有伤害。MCWS 的实验卡明确写明：如果未来重启 nearness，必须先证明“状态条件化”能解决 2022-2023 恶化。本实验就是这个前置门禁。

## 3. 实验前假设

如果 52 周高点 nearness 的有效性主要取决于市场状态，那么只在 `ma20_breadth >= 0.72` 且 `median_ret20 >= 0.06` 的 broad/healthy 状态启用 nearness，应能保留 broad 段收益增量，并减少震荡段误伤。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：条件化 H5 增量为正，且高于随机同池 p95。
- 交易行为：combo 与 hard5 的选择切换样本足够，不能只靠少数事件。
- 风险表现：非 broad 状态下不使用 nearness，2022-2023 和 2025 不应明显受伤。
- 分段表现：条件化 H5 至少 `3/4` 分段为正，任一分段不低于 `-0.05pct`。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| hard5 close-to-close 排名代理 | 当前核心排序基准 | `scripts/research/analyze_ttsk_state_conditioned_nearness_readonly.py` |
| combo_52wk 排名代理 | 不做状态条件化的 nearness 选择 | `results/v2/research/RD-20260614T115209Z-main-R25X/EX-20260614T115454Z-main-MCWS/` |
| state-conditioned nearness | broad 状态用 combo，否则用 hard5 | `results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/summary.json` |
| random same-pool control | 判断条件化收益是否只是候选池随机替换 | `results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/ttsk_random_control_summary.csv` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- broad/healthy 阈值从历史经验后验选择，无法外推。
- close-to-close 代理不等于完整回测收益。
- 2020-2021 单段牛市贡献过大。
- nearness 只是随机替换了同池候选，不是锚定机制。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 条件化 H5 正分段少于 `3/4`。
- 最差分段条件化 H5 增量低于 `-0.05pct`。
- broad 状态 combo H5 增量低于 `+0.10pct`。
- 总体条件化 H5 增量低于随机同池 p95。
- 样本量、切换事件、broad 事件或 broad 切换事件不足。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 只读脚本使用 `quant.jq_bar_daily`，信号字段由当日及之前日线计算，未来 H5/H10 仅用于标签。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过但限于只读代理 | 本实验不模拟成交，只比较 close-to-close 排名代理，不生成交易配置。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 弱通过 | 使用策略文件中已固定的 `STATIC_ETF_POOL`；这与 MCWS 同源，但不等于生产股票池审计。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 未使用财务、宏观或估值数据。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 未修改策略默认逻辑，未生成 shadow/observe 配置。 |

负控或错位检查：

- 同池随机选择负控 `200` 次。条件化 H5 增量 `+0.0089pct`，低于随机同池 p95 `+0.0856pct`。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 状态阈值固定复用 A2 环境门槛：`ma20_breadth >= 0.72` 且 `median_ret20 >= 0.06`。 |
| 样本内、验证集、样本外划分清楚 | 弱通过 | 本实验是 MCWS 后的解释性只读门禁，不是可推广 OOS 结论。 |
| 邻近参数敏感性合理 | 未做 | 本轮不允许继续扫状态阈值。 |
| 成本、滑点或换手扰动已检查 | 不适用 | 只读 ranking proxy，不运行交易回测。 |
| 已做消融或负控 | 通过 | hard5、combo、conditioned、random same-pool 四组对照。 |
| 未只报告最优结果 | 通过 | 汇报总体、状态、四段和随机负控。 |

证据等级：`L1_readonly_gate_failed`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-19T00:16:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `SUB-EXEMPT-20260619T001600Z-main-NEXTDIR` | 无 | `SUBTASK-NONR-NEXT-DIRECTION` | 主控 | 2026-06-19T00:16:00Z | 驾驶舱、当前状态、R25X/MCWS、平台脚本 | KDGD/TTSK/3SKD 文档与台账 | 只读脚本编译和运行 | 仅支持门禁失败，不支持实盘判断 | 未由独立子代理复核 | 主控核对 summary、CSV 和门禁 | 支持 3SKD park 决策 |

台账行：见 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/scripts/research/analyze_ttsk_state_conditioned_nearness_readonly.py
```

### 运行命令

```bash
cd /mnt/e/量化平台_V1.4.0
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_ttsk_state_conditioned_nearness_readonly.py 2>&1 | tee results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/run_ttsk.log
```

### 可见进度与日志

- 是否过程可见：是
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/run_ttsk.log`
- 查看进度命令：`Get-Content -Tail 80 "${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/run_ttsk.log"`
- 异常判断：第一次运行因状态汇总列名错误失败，已修复脚本并重新编译/运行通过。
- 后台回测豁免：不适用。

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/summary.json
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/ttsk_event_panel.csv
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/ttsk_state_summary.csv
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/ttsk_segment_summary.csv
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T161832Z-main-KDGD/EX-20260618T161843Z-main-TTSK/ttsk_random_control_summary.csv
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 总事件数 | 门槛 `>=400` | `1293` | 通过 | 样本足够 |
| 切换事件数 | 门槛 `>=50` | `118` | 通过 | combo 与 hard5 有足够差异 |
| broad 事件数 | 门槛 `>=30` | `124` | 通过 | broad 状态样本足够 |
| broad 切换事件数 | 门槛 `>=10` | `29` | 通过 | broad 下有足够真实切换 |
| 条件化 H5 正分段 | 门槛 `>=3/4` | `2/4` | 失败 | 2022-2023、2025 仍为负 |
| 最差分段 H5 增量 | 门槛 `>=-0.05pct` | `-0.0608pct` | 失败 | 2025 段仍受伤 |
| broad H5 增量 | 门槛 `>=+0.10pct` | `+0.0927pct` | 失败 | broad 内收益增量不足 |
| 总体条件化 H5 增量 | 随机 p95 `+0.0856pct` | `+0.0089pct` | 失败 | 没打败随机同池选择 |

## 13. 支持证据

- 样本量足够：`1293` 个事件、`118` 个切换事件。
- broad 状态中 combo H5 均值高于 hard5：`+0.0927pct`，说明状态依赖不是完全没有方向。
- 2020-2021 和 2024 条件化 H5 增量分别为 `+0.0337pct`、`+0.0684pct`，保留了一部分 MCWS 改善。

## 14. 反对证据

- 条件化 H5 正分段只有 `2/4`，未达 `3/4`。
- 2022-2023 条件化 H5 增量 `-0.0334pct`，2025 段 `-0.0608pct`，说明状态门禁仍不能避开误伤。
- broad H10 增量为 `-0.0554pct`，说明 H5 的轻微改善没有延续到 H10。
- 随机同池负控更强：条件化 H5 增量 `+0.0089pct`，随机 p95 `+0.0856pct`。

## 15. 偏差诊断

实验前预测最重要的一点是：broad 状态应明显提高 nearness 的有效性。但实际 broad H5 增量只有 `+0.0927pct`，低于门槛，而且 H10 转负。这说明 MCWS 的 2020-2021 改善更像阶段性市场环境和候选池随机替换共同作用，而不是一个稳定状态门禁。

## 16. 研究判断

建议状态：`park`

理由：

- 本实验的定位是门禁，不是寻找最优阈值。门禁失败后不应继续扫状态阈值。
- 随机同池负控强于条件化方案，不能进入交易回测。
- 这进一步收紧 R25X：52 周高点不只是 lookback 问题，也不是简单 broad 状态条件化能解决的问题。

## 17. 下一步

本方向不继续。非 R 方低滞后研究继续等待 KFSQ 外部样本、真实 dry-run/微观数据，或另开完全不同机制；不要把 52 周高点用状态阈值、rank 权重、alpha 或 TopK 网格继续调参。
