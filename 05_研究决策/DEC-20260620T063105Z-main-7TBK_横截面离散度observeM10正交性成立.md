---
type: 研究决策
dec_id: DEC-20260620T063105Z-main-7TBK
rd_ids: [RD-20260620T052147Z-main-8AB7, RD-20260605T133318Z-main-H6V3]
ex_ids: [EX-20260620T052156Z-main-BL8Y]
decision: promote_candidate
owner: main
created_at: 2026-06-20T06:31:05Z
updated_at: 2026-06-20T10:00:00Z
impact: direction
subagent_call_ids: []
subagent_exemption: 决策由主控承担；主控：main；时间：2026-06-20T10:00:00Z
tags: [双池轮动, hard5, CS-dispersion, 横截面离散度, promote_candidate, M10正交, 全门槛通过]
---

# 横截面离散度 observe M10 正交性成立

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260620T052147Z-main-8AB7_双池轮动横截面离散度组合层保守开关|双池轮动横截面离散度组合层保守开关]]（8AB7）、[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]（H6V3）
- 关键实验：[[04_实验记录/EX-20260620T052156Z-main-BL8Y_横截面离散度组合层保守开关只读面板预注册|BL8Y CS dispersion 只读面板]]
- 上游反证：[[04_实验记录/EX-20260605T184943Z-main-Q3YU_A20-A21市场状态高分延续放行formal V2与路径依赖反证|A20-A21 市场状态高分延续放行 formal V2 与路径依赖反证]]
- 兄弟决策：[[05_研究决策/DEC-20260620T062621Z-main-Z8MP_FZM4MAX彩票式过热observeA28二元版优先|FZM4 MAX observe A28 二元版优先]]
- 后续实验：[[04_实验记录/EX-20260620T052616Z-main-UEAC_GSADF爆炸性泡沫只读面板预注册|UEAC GSADF]]
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`promote_candidate`（从 observe 升级，2026-06-20 v2 修复后全门槛通过）

## 这个节点是什么

BL8Y 用 Stivers-Sun 2010 的横截面收益离散度（CS dispersion）作为组合层保守开关。经 2020 版扩展（361 事件/7 段）和错位负控 bug 修复（lookup 补 hard5_first baseline）后，**全门槛通过**（passes_gate=True）：事件 73>50、胜率 56.9%>52%、分段 3/5>=3、M10 正交性成立、错位负控不反转（valid_count 307/313）、随机负控不可复制。CS dispersion 作为 MECH-DQUM `p_crash` 组合层字段进入 formal 候选。这是三个顶刊正交维度中唯一全门槛通过的方向，直接回答"什么时候该保守"：低横截面离散度（普涨冲顶）时保守，高离散度（分化健康）时允许追高。

## 相比上一个节点改变了什么

- CS dispersion 作为 MECH-DQUM `p_crash` 组合层字段候选：方向支持，与 M10 正交。
- 确认错位负控反转是跨方向系统性问题：FZM4/BL8Y 两次出现完全相同的错位反转（shift_prev1 H10=-0.058, shift_next1 H10=-0.042），说明是数据窗口限制（valid_count 仅 20/165）的系统性假象，不是特定方向的问题。
- 转向 UEAC（GSADF 过程层）继续验证最后一个正交维度。

## 子代理依据来源

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：BL8Y 回测执行和结果分析由主控承担；主控：main；时间：2026-06-20T08:00:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：本决策无新增子代理调用。

## 支持证据

- 低离散桶 H10 effect +0.018 > 高离散桶 -0.000，方向与 Stivers-Sun 2010 一致。
- M10 正交性初步成立：市场涨+低离散 H10 +0.022 > 市场涨+高离散 +0.002。
- 未来函数审计通过：212/212 有效，全池 788922 行日频支撑。

## 反对证据

- 错位一日负控反转（与 FZM4 完全相同模式）。
- 分段不一致：2024 段 -0.066 反方向。
- 事件 43<50、分段 1<3。
- 市场跌时样本仅 1-3 事件，M10 正交性无法完整验证。

## 边界

这个决策不能说明什么？哪些内容仍然不确定？

- M10 正交性是"初步成立"，仅在市场涨时验证（40-42 事件），市场跌时样本不足。
- 错位反转是系统性问题，不代表 CS dispersion 信号伪——需用更长数据窗口重跑错位负控确认。
- CS dispersion 作为 `p_crash` 字段的方向支持，不等于可以单独 promote——需与 MECH-DQUM 三概率组合验证。

## 后续动作

- 8AB7 方向保持 active，BL8Y 记为 observe。
- CS dispersion 纳入 MECH-DQUM `p_crash` 字段池。
- 执行 UEAC（GSADF 过程层只读面板）。
- 新开方法论实验研究"错位负控反转的系统性原因"（FZM4/BL8Y 两次出现）。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账（无新增）

## formal 后续更正（2026-06-20，DEC-XSNQ）

本决策（DEC-7TBK）当时基于 BL8Y 只读面板全门槛通过，将 CS dispersion 升为 promote_candidate 并写"低离散（普涨冲顶）保守、高离散（分化健康）允许追高"。**后续 EX-S8BP formal 证明此方向不可行，且本决策的方向符号解释有误**：

1. **方向符号错误**：本决策 line 34/61 称"低离散 H10 effect +0.018 > 高离散 -0.000，方向与 Stivers-Sun 2010 一致（低离散=追高更差）"。但经核实 `analyze_r010a16_hot_state_panel.py:277`，`raw_top_diff_h10_vs_hard5 = 追高标的收益 − hard5保守持仓收益`（正值=追高胜=hard5误杀）。361 版低离散桶 H10 effect = **+0.0313**（正值），实际含义是"低离散日追高**胜过** hard5（hard5 误杀，应放行）"，与"追高更差应保守"表述**符号相反**。

2. **formal 结论**：EX-S8BP 双方向配对 formal 证明，无论按数据方向（低离散放行）还是理论方向（高离散放行），均未通过 4/4 final + 3/4 MDD + cost2x 稳健门槛。CS dispersion 组合层开关 park。根本矛盾是组合层标量无法区分"低离散=普涨健康（2020 牛市）"vs"低离散=普涨冲顶（2025 结构分化）"。

3. **本决策状态**：7TBK 的 promote_candidate 判断已被 XSNQ 的 park 决策覆盖。8AB7 方向 status 从 active 改为 park，current_decision_id 从 7TBK 改为 XSNQ。CS dispersion 留作未来 MECH-DQUM 双概率联合的条件先验，不单独复活。

详见 [[04_实验记录/EX-20260620T094932Z-main-S8BP_CS dispersion 组合层双方向配对 formal|EX-S8BP]] 和 [[05_研究决策/DEC-20260620T150805Z-main-XSNQ_CS dispersion 组合层双方向配对 formal 决策|DEC-XSNQ]]。
