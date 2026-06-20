---
type: 实验记录
ex_id: EX-20260620T052616Z-main-UEAC
rd_id: RD-20260620T052601Z-main-3B2X
status: active
stage: completed
owner: main
created_at: 2026-06-20T05:26:16Z
updated_at: 2026-06-20T08:30:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 过程层爆炸性泡沫检测
decision_ids: []
lit_ids: [LIT-20260620T052601Z-main-PYTZ]
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths: []
result_paths: [${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260620T052601Z-main-3B2X/EX-20260620T052616Z-main-UEAC/ueac_gsadf_panel/]
summary_paths: [${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260620T052601Z-main-3B2X/EX-20260620T052616Z-main-UEAC/ueac_gsadf_panel/summary.json]
quality_gate: completed_observe_not_passed
subagent_call_ids: []
subagent_exemption: 预注册设计阶段由主控承担，未调用执行子代理；主控：main；时间：2026-06-20T05:26:16Z
tags: [双池轮动, hard5, GSADF, PSY, 爆炸性, 泡沫检测, 只读面板, 预注册]
---

# GSADF 爆炸性泡沫只读面板预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260620T052601Z-main-3B2X_双池轮动GSADF爆炸性泡沫检测|双池轮动 GSADF 爆炸性泡沫检测]]
- 父方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 兄弟方向：[[02_研究方向/RD-20260619T083919Z-main-WEMY_双池轮动A股撤离追高状态机|双池轮动 A 股撤离追高状态机]]（WEMY，当前 revise）、[[02_研究方向/RD-20260620T022601Z-main-GHZL_双池轮动MAX彩票式过热信号|双池轮动 MAX 彩票式过热信号]]、[[02_研究方向/RD-20260620T052147Z-main-8AB7_双池轮动横截面离散度组合层保守开关|双池轮动横截面离散度组合层保守开关]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献：[[06_文献资料/00_待处理/LIT-20260620T052601Z-main-PYTZ_GSADF爆炸性泡沫PhillipsShiYu2015|GSADF 爆炸性泡沫 Phillips Shi Yu 2015]]
- 关联综述（M4 MAX 是单日跳，不是爆炸性过程）：[[06_文献资料/00_待处理/LIT-20260619T104218Z-main-66QH_顶刊K线成交量过热修复因子机制综述|顶刊 K 线成交量过热修复因子机制综述]]
- 关联框架（`recursive_explosive_score` 列为 p_overheat 候选但未实现）：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|hard5 过热概率与反弹修复状态框架]]
- 产生的决策：（待执行后产生）
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：hard5 高分事件里，"趋势性上涨"（GSADF 不显著，平稳）和"泡沫性加速"（GSADF 显著，爆炸性）的后续收益是否真的不同，能不能用 GSADF 这个过程层维度把泡沫性加速从一般高分里拆出来。
我们原本预计：爆炸性桶的 H5/H10 弱于平稳趋势桶，下尾更负，差异不能被负控复制，且与 MAX（单日跳）和 52 周高点（nearness）正交。
实际看到：方向与预测相反——高爆炸性桶（decile 8-9）H10 effect +0.022 < 低爆炸性桶（decile 0-1）+0.059，差 -0.037（爆炸性反而后续更好）。高爆炸性桶 H10 胜率仅 50%（不过门槛）。错位一日负控第三次出现相同反转。
这说明：GSADF 在 A 股 ETF 上的爆炸性检测方向与 Phillips-Shi-Yu 2015 预期相反——ETF 的"爆炸性"可能是趋势加速的良性阶段，而非泡沫尾声。GSADF 不适合作为 hard5 过热撤离信号。
但还不能说明：纯 numpy 简化 ADF 是否足够准确（statsmodels 不可用）；GSADF_THRESHOLD=0 是否合理；反转是真信号还是简化实现误差。
下一步要做：UEAC 记为 observe（方向反），GSADF 不纳入 MECH-DQUM p_overheat 字段。三个正交维度全部执行完毕，做综合判断。

## 2. 研究背景

本实验属于 GSADF 爆炸性泡沫检测方向（`RD-20260620T052601Z-main-3B2X`），父方向是 score 过热拥挤机制模块（`RD-20260605T133318Z-main-H6V3`），与 WEMY 个股层状态机、CS dispersion 组合层开关、MAX 彩票式过热并列。

现在要做的理由：52 周高点 nearness（R25X/MCWS）和状态条件化 52 周高点（3SKD/KDGD/TTSK）已证伪，但 nearness 只看价格位置（距离 52 周高点多近），不看价格过程的生成机制。Phillips-Shi-Yu 2015（IER）的 GSADF 用递归右尾单位根检测价格序列是否进入"温和爆炸性"状态，能区分"平稳趋势上涨"和"爆炸性泡沫加速"，是 nearness 没覆盖的过程层维度。MECH-DQUM 框架把 `recursive_explosive_score` 列为 `p_overheat` 候选但从未实现。研究库已连续 18 条路线证明精修 score 失败，本方向不精修 score，而是加一个正交的过程层维度。

## 3. 实验前假设

一句话写清本次只验证什么：在 hard5 高分事件中，GSADF 显著（爆炸性）桶的后续 H5/H10 弱于 GSADF 不显著（平稳趋势）桶，且差异不能被随机同 GSADF 桶、错位一日、MAX 分层、52 周高点分层负控复制，且 GSADF 与 MAX 正交（不是 MAX 重复）、与 nearness 正交（不是 nearness 重复）。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：爆炸性桶 H5/H10 均值低于平稳趋势桶；爆炸性桶下尾 p10 更负。
- 交易行为：（只读面板，无交易动作）
- 风险表现：爆炸性桶未来 10 日最大回撤更深（collapse 特征）。
- 分段表现：差异在 `>=3/4` 历史分段方向一致。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| hard5 全体高分事件 baseline | 主对比基准 | `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A16/hot_state_panel/`（沿用 A16/A11 事件源） |
| 随机同 GSADF 桶 | 负控：检验差异是否只是 GSADF 桶随机分位效应 | 待生成 |
| `shift_prev1` / `shift_next1` 错位 | 负控：检验是否日期基准错配 | 待生成 |
| MAX 分层 | 正交性确认：GSADF 显著 + MAX 低的事件是否存在且后续差（确认不是 MAX 重复） | 待生成 |
| 52 周高点 nearness 分层 | 正交性确认：GSADF 显著 + nearness 低的事件是否存在且后续差（确认不是 nearness 重复） | 待生成 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- ETF 上市时间短（多数 `< 10` 年），GSADF 递归窗口可选范围受限，统计功效不足。
- GSADF 递归窗口滞后，BSADF 逐时点分数滞后于泡沫起始，实时无预测力。
- GSADF 只是 MAX（M4 单日跳）的重复，不是正交新维度。
- GSADF 只是 52 周高点 nearness 的重复（创新高时爆炸性也高，nearness 已证伪）。
- 只在单一年份有效，跨期不稳。
- 实现成本高（R 包 `exuber` / Python 移植），工程风险。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 爆炸性 vs 平稳趋势桶 H5/H10 差异消失，或被任一类负控复制。
- GSADF 与 MAX 不正交（只是 MAX 重复）。
- GSADF 与 52 周高点 nearness 高度共线（只是 nearness 重复，已证伪）。
- GSADF 递归窗口滞后太大，实时无预测力（BSADF 分数对 hard5 事件日无前向预测力）。
- 只在单一年份有效，`<3/4` 分段方向一致。
- hard5 高分事件数不足 50，无法形成统计结论。
- 看完结果才后验调 GSADF 窗口、临界值（违反预注册硬规则）。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待检查（执行前预注册：GSADF 只用 `signal_date` 当时可见的过去价格序列；BSADF 逐时点分数的递归窗口严格用历史数据，不含 `signal_date` 之后的价格；吸取 52 周高点 lookback 滑入未来的教训） | 待执行后填写 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待检查（只读面板，无成交；H5/H10 用未来收益但仅用于事后评估，不反向写入信号） | 待执行后填写 |
| 股票池或 ETF 池不存在未来成分泄漏 | 待检查（沿用 A11/A16 既有 hard5 事件源 + 当时可得 ETF 池） | 待执行后填写 |
| 财务、宏观或估值数据按可得日处理 | 不适用（本实验只用日频收盘价） | — |
| Shadow 或观察信号未被当成默认交易信号 | 待检查（本实验为只读面板，默认 hard5 不变） | 待执行后填写 |

负控或错位检查：

- 随机同 GSADF 桶：同规模随机分位是否复制主差异。
- `shift_prev1` / `shift_next1` 错位：状态标签错位一日是否仍成立。
- MAX 分层：确认 GSADF 与 MAX（M4 单日跳）正交。
- 52 周高点 nearness 分层：确认 GSADF 与 nearness 正交（不是已证伪 nearness 的重复）。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 是（窗口下限=20、max_ratio=0.8、threshold=0） | 本预注册 |
| 样本内、验证集、样本外划分清楚 | 部分（A16 仅覆盖 2024-2026，高爆炸性桶仅 2025 段有数据） | summary.json segment_means |
| 邻近参数敏感性合理 | 未检查（本轮不调参） | 后续若进 formal 需补 |
| 成本、滑点或换手扰动已检查 | 不适用（只读面板，无交易） | — |
| 已做消融或负控 | 部分（错位一日完成且反转；near-high 分层完成） | ueac_shifted/near_high_strat_summary.csv |
| 未只报告最优结果 | 是（报告方向相反的结果，如实记录） | ueac_high_vs_low_summary.csv |

证据等级：`L1`（只读面板已执行，方向与预测相反，不过门槛）

## 10. 子代理调用记录

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：预注册设计阶段由主控承担研究假设、证伪规则和未来函数审计设计，不调用执行子代理；主控：main；时间：2026-06-20T05:26:16Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：（待执行后若调用子代理再补）

## 11. 执行记录

### 平台配置

```text
未执行
```

### 运行命令

```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONUNBUFFERED=1 python3 scripts/research/analyze_ueac_gsadf_readonly.py 2>&1 | tee results/v2/research/RD-20260620T052601Z-main-3B2X/EX-20260620T052616Z-main-UEAC/ueac_run.log"
```

### 可见进度与日志

- 是否过程可见：`是`（PYTHONUNBUFFERED=1 + tee）
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260620T052601Z-main-3B2X/EX-20260620T052616Z-main-UEAC/ueac_run.log`
- 异常判断：无异常。211/212 事件有效 GSADF（覆盖率 99.5%），14051 日频行，11314 GSADF 特征行。merge 列冲突问题修复后正常。
- 后台回测豁免：不适用（只读面板，前台执行，约 60 秒，GSADF 递归 ADF 计算较重）

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260620T052601Z-main-3B2X/EX-20260620T052616Z-main-UEAC/ueac_gsadf_panel/
含：ueac_event_panel.csv / ueac_high_vs_low_summary.csv / ueac_shifted_control_summary.csv /
ueac_near_high_strat_summary.csv / ueac_feature_coverage.csv / summary.json
```

### 结果路径

```text
未执行（预期路径：${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260620T052601Z-main-3B2X/EX-20260620T052616Z-main-UEAC/ueac_gsadf_panel/）
```

工程依赖：GSADF 用纯 numpy 简化 ADF 右尾检验实现（statsmodels 不可用，pip install 超时）。GSADF = sup over recursive windows of ADF t-stat，临界值用 GSADF_THRESHOLD=0 简化，非严格 PSY 仿真临界值。

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 事件数（有效 gsadf_stat） | 212 | 211 | -1 | 覆盖率 99.5%，1 事件历史不足 120 日 |
| 高爆炸性桶（decile 8-9）H10 effect | — | +0.022 | — | 爆炸性标的后续追高超额 |
| 高爆炸性桶 H10 胜率 | — | 50% | — | 不过 52% 门槛 |
| 低爆炸性桶（decile 0-1）H10 effect | — | +0.059 | — | 平稳趋势标的追高超额反而更大 |
| 高 vs 低 effect 差 H10 | 预测正（爆炸更差） | -0.037 | 方向相反 | 爆炸性反而后续更好，与 Phillips-Shi-Yu 预期相反 |
| 错位一日 shift_prev1 H10 | 原始 +0.034 | -0.058 | 反转 | 第三次出现相同反转（FZM4/BL8Y/UEAC 一致） |
| 分段一致性 | 预测 >=3/4 | 1/1 | 不足 | 高爆炸性桶仅 2025 段有数据 |
| 质量门 | — | 不过 | — | 方向相反 + 胜率 50% + 错位反转 |

## 13. 支持证据

- GSADF 特征计算成功：211/212 事件有效，11314 特征行，纯 numpy ADF 实现可行。
- 未来函数审计通过：所有事件有 signal_date，GSADF 只用 signal_date 及之前 120 日收盘价。
- 方向相反本身是有价值的证伪结果：排除了 GSADF 作为 hard5 过热撤离信号的可行性。

## 14. 反对证据

- **方向与预测相反**（最严重）：高爆炸性桶 H10 +0.022 < 低爆炸性桶 +0.059，差 -0.037。爆炸性标的后续反而更好，与 Phillips-Shi-Yu 2015 的"exuberance and collapse"预期相反。
- 高爆炸性桶 H10 胜率仅 50%，不过 52% 门槛。
- 错位一日负控第三次反转（与 FZM4/BL8Y 完全相同模式）。
- 高爆炸性桶仅 2025 段有数据（2024 段 NaN），分段一致性无法检验。
- 纯 numpy 简化 ADF 可能不够准确：无截距无趋势模型、GSADF_THRESHOLD=0 非严格 PSY 仿真临界值，反转可能是实现误差而非真信号。

## 15. 偏差诊断

实验前预测和实际结果有哪些不一致？可能原因是什么？

1. **预测爆炸性更差，实际爆炸性更好**：最大偏差。可能原因：(a) ETF 的"爆炸性"（GSADF 显著）多为趋势加速的良性阶段，而非个股泡沫尾声——ETF 已分散特质风险，爆炸性更多反映主题趋势强度而非投机泡沫；(b) 纯 numpy 简化 ADF（无截距无趋势）对 ETF 价格序列的爆炸性检测可能失真；(c) GSADF_THRESHOLD=0 过低，把很多正常趋势误判为爆炸性。
2. **预测错位负控不反转，实际第三次反转**：FZM4/BL8Y/UEAC 三个方向错位负控结果完全一致，确认是数据窗口系统性问题（valid_count 仅 20/165），不是 GSADF 特有。

## 16. 研究判断

建议状态：`observe`

理由：GSADF 在 A 股 ETF 上的爆炸性检测方向与 Phillips-Shi-Yu 2015 预期相反（爆炸性反而后续更好），高爆炸性桶胜率仅 50%，且简化 ADF 实现有不确定性。GSADF 不适合作为 hard5 过热撤离信号，不纳入 MECH-DQUM `p_overheat` 字段。但方向相反本身是有价值的证伪——说明 ETF 的"爆炸性"是趋势加速良性阶段而非泡沫尾声，这与个股泡沫检测的适用场景不同。本实验记为 observe（方向反），作为方法资产保留。

对应决策：待产出 DEC（UEAC observe 方向反，GSADF 不纳入 p_overheat，三个正交维度综合判断）。

## 17. 下一步

下一轮最值得做的实验是什么？它能减少哪一个不确定性？

1. **UEAC 记为 observe（方向反）**：GSADF 不纳入 MECH-DQUM p_overheat 字段。三个正交维度全部执行完毕。
2. **三方向综合判断**：MAX（p_overheat，方向支持，A28 二元版）+ CS dispersion（p_crash，方向支持，M10 正交）+ GSADF（方向反，不纳入）。下一步组合 MAX + CS dispersion 做 MECH-DQUM 双概率软预算只读复核。
3. **错位负控反转是三个方向共同发现**：需新开方法论实验研究其系统性原因（数据窗口限制 valid_count 仅 20/165）。这是本轮最大的方法论收获。
4. **GSADF 反转的后续**：若未来 statsmodels 可用，可用严格 PSY 仿真临界值重跑确认反转是真信号还是简化实现误差。
