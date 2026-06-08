---
type: 研究决策
dec_id: DEC-20260608T005556Z-main-U7FN
rd_ids: [RD-20260605T115651Z-main-DEF0]
ex_ids: [EX-20260608T005518Z-main-XK5W]
decision: revise_baseline_skeleton_kept
owner: main
created_at: 2026-06-08T00:55:56Z
updated_at: 2026-06-08T01:12:30Z
impact: direction
subagent_call_ids:
  - SUB-20260608T004300Z-main-B34A
  - SUB-20260608T004300Z-main-B34B
subagent_exemption:
tags: [双池轮动, 防御模块, B3Gate, tiered-v2, 旧库复核, 决策]
---

# B3Gate与TieredV2复核后保留为防御骨架决策

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|双池轮动防御模块]]
- 关键实验：[[04_实验记录/EX-20260608T005518Z-main-XK5W_B3Gate与TieredV2旧证据复核|B3Gate 与 TieredV2 旧证据复核]]
- 上一张决策：[[05_研究决策/DEC-20260608T003551Z-main-DYSF_R010C与C1复核后仅日志层观察决策|R010-C/C1 仅日志层观察决策]]
- 来源旧方向：[[02_研究方向/RD-20260603T000000Z-mig-ETF7D5F7_B3Gate+Tiered-v2——防守系统研究总结|B3 Gate + Tiered-v2 防守系统研究总结]]
- 后续实验：待新开 A1/A2 动作链或静态平均仓位四段对照
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`revise_baseline_skeleton_kept`

B3Gate/tiered-v2 旧链条通过新库只读复核，可以继续作为当前双池轮动研究的防御仓位骨架和 A11/A22/A23 的基底组成；但旧库“实盘启用”和“四段验证通过”的表述不能直接升级为新库生产 promote，也不能作为继续降低 cap 或扩参数网格的理由。

## 这个节点是什么

这个节点处理的是“市场全弱时怎么降仓”的老防御系统。B3Gate 先判断市场是不是进入持续全弱状态；tiered-v2 在 B3Gate 生效后，再按弱势强度把风险仓从 cap80 分成 normal/strong/extreme，最强时降到 cap60。

它不是新的选股模型，也不是替代 hard5/A22 的收益 alpha。它是当前研究里保留的防御仓位骨架。

## 相比上一个节点改变了什么

- ARBE/DYSF 已经否决 R010-C/C1 交易化；本决策把下一条防御旧链条 B3Gate/tiered-v2 收口。
- 旧库 `live_enabled_user_authorized` 保留为历史事实，但新库只采纳“可作为防御骨架”的边界。
- 旧库 `tiered-v2 四段验证通过` 改写为更严格表述：四段拼接和 2024 压力段支持，但 2020_2021 回撤未改善、2022_2023 有收益机会成本。
- 后续研究不得在 B3/tiered-v2 旧参数上后验扩 cap50/cap40、breadth/median/top5 阈值或 R026 组合动作。

## 子代理依据来源

适配判断：适合调用。旧链条横跨迁移页、术语页、平台配置、结果和 live 审计，适合拆出只读清单。

调用状态：called

子代理豁免：无。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260608T004300Z-main-B34A | Singer | SUBTASK-20260608T004300Z-main-B3B4资产清单 | gpt-5.3-codex-spark | 2026-06-08T00:43:00Z | 旧库复核队列、迁移台账、B3/B4 迁移页、B3/tiered-v2 术语页 | 无 | 只读检索 | 输出 20 条旧库资产清单 | 只做清单，不做结论 | 主控采纳迁移资产范围并核对关键文件 | 决定旧迁移页和术语页需要同步边界 |
| SUB-20260608T004300Z-main-B34B | Goodall | SUBTASK-20260608T004300Z-main-B3B4平台结果清单 | gpt-5.3-codex-spark | 2026-06-08T00:43:00Z | `${QUANT_PLATFORM_ROOT}` 下 R010-B3/R010-B4 配置、结果、审计脚本清单 | 无 | 只读路径检索 | 输出 12 个高优先平台资产 | 需主控读 summary/CSV | 主控逐项读取 summary、CSV、配置和源码 | 决定平台证据足以保留骨架但不足以 promote |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 支持证据

- `results/v2/research/R010-B4/tiered_v2_split_summary/summary.json` 显示 tiered-v2 相对 cap80 的四段拼接收益 `+1468.34%` vs `+1351.04%`，最大回撤 `-27.13%` vs `-30.00%`。
- `compound_summary.csv` 显示 tiered-v2 相对 cap80 收益多 `117.30pp`，回撤改善 `2.88pp`。
- `segment_action_day_metrics.csv` 和 `total_action_day_metrics.csv` 显示 tiered-v2 强化动作 22 天，动作日胜率 `77.27%`。
- 2024 压力段 tiered-v2 收益 `+67.01%`，高于 cap80 `+62.02%`；最大回撤 `-26.99%`，好于 cap80 `-30.00%`。
- 2025_20260519 tiered-v2 收益 `+217.97%`，高于 cap80 `+205.70%`，没有明显错过强趋势。
- R010-B3 gate live mapping 25/25 pass；R010-B4 tiered-v2 live mapping 17/17 pass；enabled audit 21/21 pass，且显示未引入 R026 交易动作、未恢复 A1/A3/A4 旧动作开关。
- 源码逻辑要求 tiered-v2 只在 B3 persistence active 后生效，并用 `min(current_cap, strong/extreme_cap)` 降低风险仓。

## 反对证据

- 2020_2021 tiered-v2 最大回撤 `-20.678%` 略差于 cap80 `-20.672%`，不支持“四段回撤都改善”。
- 2022_2023 tiered-v2 收益 `+31.21%` 低于 cap80 `+32.23%`，存在机会成本。
- 2025_20260519 回撤改善几乎为 0，只能证明没有明显误伤，不能证明强趋势段防御贡献大。
- 本轮没有完整 cost2x/slip2bps 重新撮合、错位负控或新库重新预注册参数敏感性。
- 旧实盘启用记录引用的是历史 `E:\xtquant\策略\ETF双池动量轮动_MiniQMT.py`，新库不能据此声明当前生产默认已切换。

## 边界

这个决策不能说明：

- 不能说明当前最有效策略已经确定。
- 不能说明默认 hard5 已被 B3/tiered-v2 或 A22 替换。
- 不能说明 tiered-v2 可以继续扩展到 cap50/cap40。
- 不能说明 R026、B5、C1 或旧 A1/A3/A4 可以并入当前交易动作。
- 不能说明已经完成 promote 级未来函数审计、成本扰动和实盘 dry-run。

## 后续动作

- 防御模块继续保留 B3Gate/tiered-v2 为研究骨架；后续实验默认以它为基底时，应清楚写明这是继承骨架，不是本轮新变量。
- 若继续方向 3，优先新开 A1/A2 动作链复核、静态平均仓位四段对照或触发滞后一日负控。
- 更新旧迁移页和术语页，把 `migrated_unverified` 改成“已只读复核，边界为 baseline skeleton”，避免后来者误把旧 `live_enabled` 当作当前新库 promote。
- 不再围绕 B3/tiered-v2 旧参数做后验扩网格。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库
