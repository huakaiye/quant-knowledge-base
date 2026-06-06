---
type: 术语
term_id: TERM-20260603T000000Z-mig-SHADOWONLYC6472
legacy_id: "Shadow-only（影子观察）"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📖 概念\Shadow-only（影子观察）.md'
source_old_relative_path: '📖 概念/Shadow-only（影子观察）.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# Shadow-only（影子观察）

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`Shadow-only（影子观察）`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📖 概念\Shadow-only（影子观察）.md`
- 新库 ID：`TERM-20260603T000000Z-mig-SHADOWONLYC6472`
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
type: 概念
aliases: [shadow, 影子观察, shadow-only, 默认关闭观察]
status: 生效
tags:
  - 概念/研究方法
~~~
## 旧库原文

~~~markdown
# Shadow-only（影子观察）

## 定义

Shadow-only 是一种**安全性实验模式**：在回测或实盘中同时记录"如果启用了新模块会怎么做"和"实际怎么做"，但**不改变任何真实交易**。

## 用途

在新模块上线实盘之前，shadows-only 回答三个问题：

1. **字段审计**：候选建议是否能被日志记录下来？（缺字段就补字段）
2. **交易隔离**：影子日志的出现是否改变了真实订单？（必须证明没有）
3. **事件代理**：候选建议的差异日聚集在什么市场状态下？（为严格反事实审计提供条件）

## 在不同阶段的体现

| 阶段 | Shadow 状态 | 含义 |
|------|-----------|------|
| tiered-v2 shadow 观察 | `tiered_candidate_cap` 被记录，但 `tiered_effective_cap` 仍为 cap80 | 影子在跑，实盘不改 |
| 实盘启用后 | `SHADOW=0`，`TIERED_V2=1` | 影子关闭，交易生效 |
| R010-B5 shadow 观察 | `nonlinear_suggested_cap` vs `actual_tiered_cap` | 非线性在影子中，实盘永远不启用（已 park） |

## 硬性规则

- Shadow-only 阶段**禁止**修改真实 target_weights
- Shadow-only 阶段**禁止**修改真实订单
- 交易隔离必须被审计证明（净值、成交、订单完全一致）
- 影子日志中的字段必须在 `source_lag_days` 上只有 T-1 可见信息

## 相关概念

- [[预注册]]
- [[严格反事实审计]] — 反事实审计依赖 shadow 日志提供的数据
- [[tiered-v2（分层强度防守）]]

## 相关决策

- [[D20260601-R010B4-tiered-v2影子观察方案建立]]
- [[D20260602-R010B5R4-默认关闭影子观察预注册完成]]

~~~