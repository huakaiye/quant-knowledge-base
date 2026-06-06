---
type: 研究决策
dec_id: DEC-20260601T000000Z-mig-D20260601R026STRICTMARKEFD93C
legacy_id: "D20260601-R026-strict-marker-only"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\🔀 决策\D20260601-R026-strict-marker-only.md'
source_old_relative_path: '🔀 决策/D20260601-R026-strict-marker-only.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# D20260601-R026 strict_marker_only

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`D20260601-R026-strict-marker-only`
- 来源旧库路径：`E:\【笔记库】\量化研究库\🔀 决策\D20260601-R026-strict-marker-only.md`
- 新库 ID：`DEC-20260601T000000Z-mig-D20260601R026STRICTMARKEFD93C`
- 证据等级：legacy_raw
- 结论边界：本页保留旧库内容，不代表新库已经采纳旧结论。

## 关联链接

- 迁移总卡：[[11_迁移暂存/MIG-20260605T120000Z-mig-BATCH_旧库批量迁移总卡|旧库批量迁移总卡]]
- 关联方向：待复核
- 关联策略：待复核
- 迁移规范：[[08_方法论/研究库迁移规范|研究库迁移规范]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]

## 复核清单

- [ ] 旧路径真实存在。
- [ ] 平台配置路径真实存在。
- [ ] 平台结果路径真实存在。
- [ ] 实验前假设和证伪条件满足新库标准。
- [ ] 未来函数和过拟合审计满足新库标准。
- [ ] 已同步对应台账和驾驶舱。

## 旧库 Frontmatter

~~~yaml
type: 决策
decision_id: D20260601-R026-strict-marker-only
decision_date: 2026-06-01
status: 生效
decision_class: revise
chain_id: R026防守池分层主链
topic_id: R20260531-026
source_record: "[[R20260531-026_防守池分层与吸血撤离信号研究计划]]"
related_topics:
  - "[[10-ETF阴跌防守专题]]"
  - "[[07-市场状态识别专题]]"
previous_decision: "[[D20260601-R010B3-gate成为当前主候选]]"
next_decision: "[[D20260601-MiniQMT-v18默认关闭映射]]"
tags:
  - 研究/决策
  - 状态/revise
~~~
## 旧库原文

~~~markdown
# D20260601-R026 strict_marker_only

## 决策摘要

R026 防守池吸血信号不进入主交易 gate，只保留为低覆盖、高精度的风险复核标记和解释层。

## 当时问题

[[B3 gate]] 四段通过后，需要判断 R026 是否能在 gate 触发、gate 拦截和非 raw 回撤日上提供增量解释力。

## 支持证据

| 证据 | 说明 |
| --- | --- |
| `signal_B_equity_defense` 精度较高 | 未来 10 日 -5% 下探精度高于基准 |
| gate blocked raw 覆盖为 0 | 没有明显重新放大已被 gate 拦截的噪音 |
| 可解释部分风险日 | 适合作为人工复核和日志字段 |

## 反对证据

| 证据 | 说明 |
| --- | --- |
| 覆盖太低 | 无法承担主撤离或仓位开关职责 |
| 宽信号噪音大 | `signal_any_defense_mem30` 覆盖广但精度低于全样本基准 |
| 不能替代 B3 gate | B3 gate 已经更直接地改善收益和回撤 |

## 竞争性解释

| 解释 | 如何区分 |
| --- | --- |
| 防守池信号更多是事后风险状态，不是交易触发 | 做启动前、启动早期和谷底前事件审计 |
| B 层信号干净但过稀疏 | 继续作为日志标记，不单独回测交易动作 |

## 决策

```text
strict_marker_only
```

决策边界：

- R026 不是主防守动作。
- R026 不是替代 B3 gate 的仓位开关。
- R026 不直接 cap80、清仓或绕过 gate。

## 下一步

- 观察 R026 是否能解释 B3 gate active 日或少数非 raw 回撤日。
- 若未来参与仓位，必须先通过新的分段样本外审计，且不得降低 B3 gate 已取得的收益/回撤性价比。


~~~