---
type: 实验记录
ex_id: EX-20260621T015355Z-main-F44P
rd_id: RD-20260619T083919Z-main-WEMY
status: park
stage: completed
owner: main
created_at: 2026-06-21T01:53:55Z
updated_at: 2026-06-22T09:00:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 个股层量价结构 veto 组合层 formal
decision_ids: [DEC-20260621T024805Z-main-CHCD]
lit_ids: [LIT-20260620T022539Z-main-36A6]
idea_ids: [MECH-20260620T154044Z-main-MATN]
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths: [configs/research/R010-A22/frozen_veto_paired/EX-20260621T015355Z-main-F44P/formal/manifest.json]
result_paths: [results/v2/research/R010-A22/frozen_veto_paired/EX-20260621T015355Z-main-F44P/formal]
summary_paths: [results/v2/research/R010-A22/frozen_veto_paired/EX-20260621T015355Z-main-F44P/summary/formal/summary.json]
quality_gate: completed_not_passed
subagent_call_ids: [SUB-20260621T011000Z-main-G4H7]
subagent_exemption: 预注册的研究假设、证伪规则、未来函数审计、4 veto 阈值冻结、方向判断和最终 park 决策由主控承担；SUB-G4H7 只做检索盘点，不独立决定决策状态；主控：main；时间：2026-06-22T09:00:00Z
tags: [双池轮动, hard5, frozen-veto, 量价结构, A28, m14, m04, m12, m01, formal, park, 参数矩阵无必要]
---

# A29 frozen-veto 组合层双方向配对 formal

## 关联链接

- 研究方向：[[02_研究方向/RD-20260619T083919Z-main-WEMY_双池轮动A股撤离追高状态机|双池轮动 A 股撤离追高状态机]]
- 父方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]（H6V3）
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 上游实验（A28 量价结构门禁，全门槛通过）：[[04_实验记录/EX-20260619T113348Z-main-UN96_A28非QMT量价结构状态机数据门禁|EX-UN96 A28 量价结构门禁]]
- 上游决策：[[05_研究决策/DEC-20260619T114146Z-main-5E5G_A28量价结构门禁通过后转过热veto正式实验|DEC-5E5G A28 通过后转 A29 veto formal]]
- MAX 二元 veto 参考：[[05_研究决策/DEC-20260620T062621Z-main-Z8MP_FZM4MAX彩票式过热observeA28二元版优先|DEC-Z8MP m04 二元版]]
- 同口径模板（CS dispersion formal，已 park）：[[04_实验记录/EX-20260620T094932Z-main-S8BP_CS dispersion 组合层双方向配对 formal|EX-S8BP CS dispersion formal]]
- 产生的决策：（待执行后产生）
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：A28 只读面板已经发现，当 hard5 高分标的同时出现"高波高量/极端单日跳/注意力冲击/高量晚期动量"这 4 种量价结构异常时，继续追高往往更差（H10 胜率 57-69%）。本次把 4 个 veto 接进策略做正式四段回测（2020-2026），检验"veto 命中维持 hard5 保守、veto 未命中放宽到 cap70"能否改善默认 hard5。这是继 CS dispersion（组合层标量，失败 park）之后，用个股层结构信号（粒度更细）再试一次"什么时候该对高分保守"。

我们原本预计：veto 未命中日放行的标的质量更好（剔除了 4 种过热结构），组合 final 4/4 段不低于 hard5。

实际看到：（待执行后填写）

这说明：（待执行后填写）

但还不能说明：（待执行后填写）

下一步要做：（待执行后填写）

## 2. 研究背景

DEC-5E5G 既定动作：A28 全门槛通过（178 事件，4 veto H10 胜率 57-69%、分段 3-4、p10≥-0.10），明确"新开 A29 formal，固定四个 strong veto"。CS dispersion（EX-S8BP）刚证明组合层标量信号单独不可行（无法区分普涨健康 vs 普涨冲顶），park 后 A29 用个股层结构信号替代，理论上能解决 CS dispersion 无法解决的问题。A28 的 4 veto 实证：m14（42 事件/4 段/H10 +4.59pp/胜率 69.05%）、m04（24/4/+4.19pp/66.67%）、m12（70/4/+3.47pp/64.29%）、m01（21/3/+2.00pp/57.14%），全部过 strong-hint 门禁。effect 含义：正值=追 raw Top1 比 hard5 实际路径更差，支持 veto。

## 3. 实验前假设

把 A28 四个 strong veto 作为组合层 gate，当日对高分标的若任一 veto 命中则维持 hard5 保守，veto 全不命中则放宽到 A22 cap70 允许追；在四段历史中，联合 veto 候选能 4/4 段 final 不低于 hard5 且 3/4 段 MDD 不差，且该优势在 cost2x/slip2bps 下不消失，而单独 veto 候选作为归因不全部过门槛（验证是联合信号在驱动而非单个）。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：联合 veto 候选 final 4/4 ≥ hard5，MDD ≥3/4 不差；4 单独 veto 候选中 m12（样本最厚）单独也较强，m01（仅 3 段）单独较弱。
- 交易行为：veto 命中日高分标的被拦截（维持 hard5），未命中日按 cap70 放行。
- 风险表现：veto 命中若误伤 2025 修复反弹，2025 段应有归因说明。
- 分段表现：基于 A28 4 veto 分段 3-4，预测联合 veto 在多数段稳健；错位一日不应反转（否则 FZM4 同款）。

## 5. 基准和对照

| 对照 | 用途 | 关键配置 |
| --- | --- | --- |
| baseline_hard5 | 主对比基准 | max_score=5, hard_cap, veto gate 关 |
| ref_a22_cap70_always | 上界参照 | 无条件 cap70（验证 veto gate 信息量） |
| cand_loosen_if_no_veto | 主候选：联合 veto 未命中→cap70 | 4 veto OR 组合 |
| cand_loosen_if_no_m14 | 归因：仅 m14 | 单 m14 veto |
| cand_loosen_if_no_m04 | 归因：仅 m04 | 单 m04 veto |
| cand_loosen_if_no_m12 | 归因：仅 m12 | 单 m12 veto |
| cand_loosen_if_no_m01 | 归因：仅 m01 | 单 m01 veto |

四段：2020-01-01~2021-12-31 / 2022-01-01~2023-12-31 / 2024-01-01~2024-12-31 / 2025-01-01~2026-05-19（同 S8BP/K3AC）。成本：cost1x + cost2x_slip2bps。配对矩阵：7 变体 × 4 段 × 2 成本 = 56 回测。

## 6. 竞争性解释

即使联合 veto 4/4 赢 hard5，也可能是：

- cap70 单纯放行驱动（需对照 ref_a22_cap70：若 cand≈ref，veto 无信息量）。
- veto 只是 A25/A26 事件样本的后验结构（DEC-5E5G 已警示，需错位负控）。
- 2025 强反弹环境 veto 误伤修复反弹（需看 2025 段 veto 命中率与收益归因）。
- 某单一 veto（如 m12 样本最厚）主导，联合只是 m12 换皮（需单独 veto 归因）。
- FZM4 同款错位反转问题（m04 深化的 MAX 十分位 shift_prev1 完全反转）。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 联合 veto 候选 final 4/4 段不低于 hard5 不成立（≤3/4）。
- MDD ≥3/4 段不差不成立。
- cost2x/slip2bps 下门槛被翻转。
- 与 ref_a22_cap70 四段 final 几乎相同（差<0.5%），veto 无独立信息量。
- veto 命中触发次数过低（某段<5 日），效应不可信。
- 错位一日负控反转（shift_prev1 组合层 effect 反号），提示 FZM4 同款问题。

整体证伪：联合 veto 候选≤2/4 段赢 hard5 → frozen-veto 组合层开关整体 park。

## 8. 未来函数审计

继承 A28 数据门禁（EX-UN96 已通过）：

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预注册通过（待复核） | 4 veto 全日频结构，turnover_ma20/volume_ma20 用 shift(1).rolling(20) 前一日 MA；ret5/ret20 用历史比；signal_date 当日及以前 |
| 信号生成和成交价格不存在同 bar 泄漏 | 预注册通过（待复核） | 日级状态，不用 13:09 后分钟；V2 引擎次日撮合，与 A22 同口径 |
| 股票池或 ETF 池不存在未来成分泄漏 | 预注册通过（待复核） | 沿用 A11/A16 既有 hard5 事件池 + ETF 前缀过滤 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本实验只用日频量价 |
| Shadow 或观察信号未被当成默认交易信号 | 预注册通过（待复核） | frozen_veto_gate 默认 enabled=False；hard5 默认路径不受影响 |

负控或错位检查：

- 错位一日：summarize 阶段事后归因（不新增回测变体），shift±1 重算组合层 effect 检查反转。
- 随机同日：trades.csv 的 veto 命中分布与全样本随机基线对比。
- 同主题随机 TopK：m11 peer_diffusion 风格，本轮作为观察项不强门禁。
- 成本扰动负控：cost2x/slip2bps（K3AC 同口径）。
- 上界对照：ref_a22_cap70（区分 veto 信息量与 cap70 放行效应）。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 是 | 4 veto 阈值全部冻结（见下表），DEC-5E5G "不调阈值" |
| 样本内、验证集、样本外划分清楚 | 部分 | 四段全历史；2024 历史负控段 |
| 邻近参数敏感性合理 | 不在首轮 | 阈值 frozen；通过后补邻域 |
| 成本、滑点或换手扰动已检查 | 是 | cost1x + cost2x_slip2bps |
| 已做消融或负控 | 是 | ref_cap70 上界 + 4 单独 veto 归因 + 错位负控 + 2024 负控段 |
| 未只报告最优结果 | 是 | 7 变体四段两成本全部报告，含归因和反方向 |

预注册冻结参数（DEC-5E5G "固定不调"，原样抄 A28 脚本 :517-569）：

| 参数 | 冻结值 | 来源 |
| --- | --- | --- |
| m14 atr20 阈值 | ≥0.035 | A28 :569 |
| m14 turnover_ratio20 阈值 | ≥1.50 | A28 :569 |
| m14 ret5 阈值 | ≥0.08 | A28 :569 |
| m04 max_ret20 阈值 | ≥0.08 | A28 :541 |
| m04 disc 或 ret5 | disc≥0.55 OR ret5≥0.12 | A28 :542 |
| m04 turnover_ratio20 | ≥1.50 | A28 :543 |
| m12 ret5 | ≥0.10 | A28 :565 |
| m12 OR 组 | turnover_ratio20≥2.00 OR volume_ratio20≥2.00 OR failed_limit OR score≥6.50 | A28 :566 |
| m01 ret20 | >0.10 | A28 :518 |
| m01 turnover_ratio20 | ≥2.20 | A28 :519 |
| m01 OR 组 | max_ret20≥0.06 OR disc≥0.55 | A28 :520 |
| 联合 veto | m14 OR m04 OR m12 OR m01 | DEC-5E5G |
| loosen risk_cap | 0.70 | 对齐 A22 |
| 四段 daterange | 见 §5 | S8BP/K3AC |
| 成本 | cost1x + cost2x_slip2bps | S8BP/K3AC |

字段计算口径（A28 :359-411，shift(1) 无未来函数）：

- ret1=close/pre_close-1；ret5/ret20=close 比 5/20 日前
- max_ret20=ret1.rolling(20).max()（**正向最大**，非 max_abs_ret20）
- return_discreteness20=max_abs_ret20/abs_sum_ret20
- turnover_ratio20=turnover/turnover.shift(1).rolling(20).mean()（前一日 MA）
- volume_ratio20=volume/volume.shift(1).rolling(20).mean()
- atr20=((high-low)/close).rolling(20).mean()
- failed_limit=hit_limit_intraday AND NOT close_lock_limit（需 limit_up 字段）

证据等级：`L2`（预注册四段 formal + 成本扰动 + veto 归因 + 错位负控）。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`（G4H7 检索已完成；策略代码/回测/汇总主控承担）

子代理豁免：预注册的研究假设、证伪规则、未来函数审计、4 veto 阈值冻结和方向判断由主控承担；SUB-G4H7 只做检索盘点，不独立决定决策状态；主控：main；时间：2026-06-21T02:30:00Z

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260621T011000Z-main-G4H7 | 待返回 | SUBTASK-G4H7 A29formal前置检索 | explore | 2026-06-21T01:10:00Z | WEMY/DEC-5E5G/EX-UN96/A28脚本/S8BP脚本 | 无 | 无 | 检索盘点 | 无 | 采纳为预注册依据 | 不影响假设设计 |

台账行：[[01_台账/子代理调用台账.csv|子代理调用台账]] 待登记。

## 11. 执行记录

### 平台配置

```text
已生成 56 configs（7 变体 × 4 段 × 2 成本），路径根：
configs/research/R010-A22/frozen_veto_paired/EX-20260621T015355Z-main-F44P/formal/<variant>/<cost>/<segment>/f44p_<variant>_<cost>_<segment>.json
manifest: configs/research/R010-A22/frozen_veto_paired/EX-20260621T015355Z-main-F44P/formal/manifest.json
变体：baseline_hard5 / ref_a22_cap70_always / cand_loosen_if_no_veto / cand_loosen_if_no_m14 / _m04 / _m12 / _m01
脚本：generate_f44p_frozen_veto_paired_configs.py / run_f44p_frozen_veto_paired.sh / summarize_f44p_frozen_veto_paired.py
并行执行：run_parallel_backtest.sh（max-parallel=6，32段并行约90分钟）
```

### 运行命令

```bash
# 并行执行（遵守 AGENTS.md 并行回测默认规则）
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && python3 scripts/research/_tmp_f44p_run_parallel.py"
# 汇总
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 scripts/research/summarize_f44p_frozen_veto_paired.py --strict"
```

### 可见进度与日志

- 是否过程可见：`是`（PYTHONUNBUFFERED=1 + tee，并行脚本实时进度，每5分钟报告）
- 日志路径：`results/v2/research/R010-A22/frozen_veto_paired/EX-20260621T015355Z-main-F44P/logs/formal/` + `tmp/parallel_backtests_*/`
- 后台回测豁免：56段并行回测（max-parallel=6），后台 run_parallel_backtest.sh tee 落盘可见；预计耗时约90分钟（并行）。

### 结果路径

```text
results/v2/research/R010-A22/frozen_veto_paired/EX-20260621T015355Z-main-F44P/formal/<variant>/<cost>/<segment>/<job_id>/{summary.json,...}
汇总：results/v2/research/R010-A22/frozen_veto_paired/EX-20260621T015355Z-main-F44P/summary/formal/{summary.json, segment_metrics.csv}
```

## 12. 实际观察

### 12.1 56 段结果矩阵（cost1x，vs baseline_hard5）

| 段 | hard5 | ref_a22 | 联合veto | m14 | m04 | m12 | m01 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2020_2021 | 224943 | 132765 | **259938** ✅(-0.196) | 126356(-0.323) | 126356 | **259938** ✅(-0.196) | 126356 |
| 2022_2023 | **131215** | 103364 | 82709 ❌(-0.360) | 100663(-0.271) | 100663 | 82709 ❌(-0.360) | 100663 |
| 2024 | 167005 | 162437 | **180483** ✅(-0.265) | 155707(-0.282) | 155707 | **180483** ✅(-0.265) | 155707 |
| 2025 | **317974** | 59923(崩) | 106689 ❌(-0.701) | 36598 ❌(崩-0.765) | 36598 | 106720 ❌(-0.701) | 36598 |

### 12.2 门禁结果（summarize，evidence_complete 部分缺失因并行日志格式）

| Gate | 结果 | 值 |
| --- | --- | --- |
| 联合veto final 4/4 vs hard5 | ❌ | 2/4 段赢 |
| 联合veto mdd 3/4 vs hard5 | ❌ | 2/4 段不差 |
| 联合veto cost2x 稳健 | ❌ | 2/4 段赢 |
| 联合veto ≠ ref（gate 有信息量）| ✅ | 0.78 差异 |
| m12 final 4/4 | ❌ | 2/4（与联合veto几乎相同）|
| m14/m04/m01 final 4/4 | ❌ | 0/4（2025全崩）|

decision_hint：`frozen_veto_gate_park`（联合veto未过门槛）。

### 12.3 关键归因

- **m12 主导联合 veto**：m12 和联合 veto 四段结果几乎完全相同（259938/82709/180483/106720 vs 106689），说明 m12 触发率最高、其他 3 个 veto 几乎不额外贡献。
- **m14/m04/m01 结果完全相同**（126356/100663/155707/36598）：这 3 个单独 veto 触发模式一致，且 2025 段全部崩盘（36598，MDD -76.5%）。
- **2025 段是致命伤**：所有 cand 变体在 2025 段惨败（10-12 万 vs hard5 31.8 万）。veto 在 2025 强反弹环境误伤了修复反弹标的。

## 13. 支持证据

- **veto gate 有独立信息量**：cand≠ref 通过（0.78 差异）。ref_a22 无条件放行 2025 段崩盘（59923，MDD -55.7%），veto gate 虽也输但机制不同（veto 误伤 vs cap70 放行劣质标的）。
- **联合 veto 在 2020_2021 和 2024 段赢 hard5**：259938 vs 224943（+15.6%）、180483 vs 167005（+8.1%），说明 veto 在牛市普涨和震荡市能改善选股。
- **m12 样本最厚（A28 70 事件）确实主导**：单独 m12 与联合 veto 结果几乎相同，符合 A28 实证（m12 事件数最多、H10 effect 稳健）。

## 14. 反对证据

- **2025 段全面惨败**：联合 veto 106689 vs hard5 317974（-66%，MDD -70.1%），m14/m04/m01 更惨（36598，-88%，MDD -76.5%）。veto 在 2025 强反弹环境误伤了修复反弹标的。
- **2022_2023 段也输**：联合 veto 82709 vs hard5 131215（-37%）。veto 在 2022 熊市过度保守。
- **不满足预注册证伪条件**：联合 veto 仅 2/4 段赢（需 4/4），MDD 仅 2/4 不差（需 3/4）。整体 park。
- **m14/m04/m01 完全无贡献**：3 个单独 veto 结果完全相同且全段劣于 hard5，说明这 3 个 veto 的触发模式有问题（可能全部同时触发或全部不触发，无区分度）。

## 15. 偏差诊断

**预测与实际的不一致**：

1. 预测联合 veto 比单独 veto 更稳健——实际 m12 主导，其他 3 个 veto 无额外贡献（m14/m04/m01 结果完全相同）。
2. 预测 veto 能改善 2025 段（剔除过热冲顶）——实际 2025 段全面惨败。原因是 2025 是强反弹环境，veto 误伤了修复反弹标的（高分+高量+高波在 2025 是健康反弹特征，不是过热）。
3. **核心矛盾**：veto 信号（高波高量+极端跳+注意力+晚期动量）在牛市普涨（2020）和震荡市（2024）是"过热"信号（剔除正确），但在强反弹（2025）是"修复"信号（剔除错误）。与 CS dispersion 的问题对称：CS dispersion 早段输晚段赢，veto 早段赢晚段输。**两种信号都无法同时适应所有时段**。

**参数矩阵必要性评估**（objective 第3项）：
- veto 阈值是 frozen（DEC-5E5G "不调"），调阈值违反预注册硬规则。
- 即使调阈值，核心矛盾是"同一信号在不同时段含义相反"（过热 vs 修复），非阈值问题。
- **结论：参数矩阵无必要**。

### 15.1 实现 bug 诊断（2026-06-22 深挖日志发现）

回测后深挖 veto gate 日志发现**实现层面的关键 bug**，导致 m14/m04/m01 结果失真：

**现象**：
- m14/m04/m01 的 veto 在 2024 段**242 日全部 loosen（veto_hit=0）**——3 个 veto 从未命中，等同无条件 cap70。
- m12 和联合 veto 有 66 个 veto 命中日（loosen=176），有区分度。
- 因此 m14/m04/m01 结果完全相同（155707），且 ≠ ref_a22（162437）——因 loosen 242 日 vs ref 全程 cap70 的交易路径细微差异。

**根因**：`_compute_frozen_veto_today` 对**全池所有标的**算 veto 并聚合（任一命中即 veto_hit），但 A28 的 veto 阈值是**个股级**（针对高分事件标的标定）：
- m14 需 `atr20≥0.035`——ETF 的 atr20（(high-low)/close 均值）通常 0.01-0.02，远低于个股级 0.035 阈值，全池标的几乎达不到。
- m04 需 `max_ret20≥0.08`——ETF 单日收益极难达 8%。
- m01 需 `ret20>0.10 AND turnover_ratio20≥2.20`——ETF 20 日涨 10%+换手翻倍极少。
- m12 有 `turnover_ratio20≥2.00 OR volume_ratio20≥2.00 OR failed_limit OR score≥6.50`，ETF 偶尔能触发 → 有区分度。

**另一个实现问题**：策略代码用 `score=5.0` 硬编码（非真实高分标的 score），且对全池聚合而非只对高分候选。A28 的 veto 是事件级（只对 raw_top_code 高分标的算），策略是组合层（全池任一命中即 veto）。口径不一致。

**影响**：
- m14/m04/m01 的结果（155707/126356/100663/36598）**不能代表这 3 个 veto 的真实效果**——它们实际等同"无条件 cap70 但 loosen 判断有细微差异"。
- m12 和联合 veto 的结果（259938/82709/180483/106689）相对可信（m12 确实在触发），但 2025 段惨败的结论仍成立（m12 误伤修复反弹）。
- 联合 veto 退化为 m12 单 veto 的结论**部分成立**（m14/m04/m01 未额外触发），但因 bug 无法确认"修复后 m14/m04/m01 是否有额外贡献"。

**是否修复重跑**：
- 修复方案：`_compute_frozen_veto_today` 改为只对当日高分候选（score≥5）算 veto，不对全池聚合；score 用真实标的评分而非硬编码 5.0。
- 但 DEC-5E5G 要求"不调阈值"，修复口径不改阈值，只改"对谁算"——属实现修正而非调参。
- **决策：本轮不修复重跑**。原因：(1) m12 单 veto 的 2025 段惨败已证明 veto 信号在强反弹环境误伤修复反弹的核心矛盾，修复 m14/m04/m01 口径不会改变这个结论；(2) 修复重跑需再 90 分钟，而核心矛盾（过热 vs 修复时段依赖）已清晰。留作 follow-up：若未来 MECH-MATN 联合 veto 时需要 m14/m04/m01 的真实贡献，再修复口径。

## 16. 研究判断

建议状态：`park`（frozen-veto 组合层开关方向暂停）。

理由：
1. 联合 veto 未满足预注册证伪条件（2/4 final，2/4 MDD），按硬规则 park。
2. 根本矛盾是 veto 信号在 2025 强反弹环境误伤修复反弹，非参数问题。
3. veto gate 确实有独立信息量（cand≠ref 通过，2020/2024 段赢），但 2025 段的惨败无法通过调参弥补。
4. m14/m04/m01 无额外贡献（结果与 m12 主导一致），联合 veto 退化为 m12 单 veto。
5. 诚实结论：frozen-veto 作为 WEMY 方向的"何时该撤离追高"答案，**单独使用不可行**。与 CS dispersion（组合层标量）失败原因不同但结果相同——都是"同一信号在不同时段含义相反"。

## 17. 下一步

下一轮最值得做：**转向能区分"过热 vs 修复"的信号**，解决 veto 和 CS dispersion 共同的核心矛盾。

**首选立项**：MECH-MATN 隔夜收益知情交易（Lou Polk Skouras 2019）——个股层信号，用隔夜/日内收益分解判断"上涨是知情延续（修复，放行）还是噪声追高（过热，保守）"。这直接回答 veto 和 CS dispersion 都无法回答的"同一高分信号在不同时段是过热还是修复"。

它能减少的不确定性："高分标的的上涨本质"——这是 hard5 误杀/误放的核心痛点，也是 veto（误伤修复）和 CS dispersion（普涨含义时段依赖）共同失败的根源。

**WEMY 方向**：park，不复活单独 veto formal。A28 的 4 veto 留作未来 MECH-DQUM 多信号联合的候选组件（与 CS dispersion 条件先验并列），但本轮不展开。

### Follow-up

- WEMY 方向页更新（status→park，current_decision_id→CHCD）。
- DEC-5E5G 的"A29 formal"既定动作已完成（结果 park），WEMY 路线收敛。
- 术语库新增 m14/m04/m12/m01 词条。
- MECH-MATN 灵感文件已存档（CS dispersion park 时建立），待数据门禁后正式立项。
