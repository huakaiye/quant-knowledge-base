---
type: 术语
term_id: TERM-20260604T000000Z-mig-RISKSCALE04BDB
legacy_id: "risk_scale（风险仓缩放系数）"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📖 概念\risk_scale（风险仓缩放系数）.md'
source_old_relative_path: '📖 概念/risk_scale（风险仓缩放系数）.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# risk_scale（风险仓缩放系数）

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`risk_scale（风险仓缩放系数）`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📖 概念\risk_scale（风险仓缩放系数）.md`
- 新库 ID：`TERM-20260604T000000Z-mig-RISKSCALE04BDB`
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
aliases: [risk_scale, 风险仓缩放系数, 仓位缩放]
status: 观察中
related: R010-B5
tags:
  - 概念/风控
  - 非线性仓位
~~~
## 旧库原文

~~~markdown
# risk_scale（风险仓缩放系数）

## 定义

risk_scale 是非线性仓位控制中的**仓位缩放因子**。它由连续函数计算，取值 **0.70 – 1.00**，在 tiered-v2 的固定 cap 之上做二级微调。

## 公式

```text
risk_scale = max(0.70, exp(-5 × max(组合回撤 - 10%, 0)))
           ──────       ──  ─────────────────
           floor=70%   衰减   超过 threshold 才缩放
```

## 数值含义

```
回撤 10% → risk_scale = 1.00（刚触及，不缩放）
回撤 15% → risk_scale = 0.78（回撤超 5%，开始缩放）
回撤 20% → risk_scale = 0.70（触底 floor，不再下降）
回撤 30% → risk_scale = 0.70（仍在地板上）
```

## 如何影响最终仓位

```text
最终仓位上限 = tiered_cap × risk_scale

例：tiered-v2 给出 cap70（0.70），当日回撤 15%
  → risk_scale = 0.78
  → 最终仓位上限 = 0.70 × 0.78 = 0.545
  → 100% 仓位被压到 54.5%
```

## 两层准入条件（必须同时满足才生效）

1. **市场状态门**：当天 B3 gate 处于 active → gate 没触发的日子 risk_scale = 1
2. **组合回撤门**：T-1 组合回撤 > 10% → 回撤不深的日子 risk_scale = 1

## 当前状态

- **R5 严格反事实审计已否证整体替代路径** — 10 日正率仅 37%
- **叠加 tiered-v2 的离线版本**四段回测通过但严格检验未过
- **低 median_ret 条件版**有弱线索但缺独立样本外 → 📌 park
- **完整非线性乘法公式** `w = σ_target/σ × tanh(k·m) × exp(-a·D) × S` → 组件不成熟，禁止回测

## 相关概念

- [[drawdown_threshold（回撤门槛）]]
- [[decay（衰减系数）]]
- [[组合回撤预算]]
- [[非线性仓位控制（概念）]]
- [[tiered-v2（分层强度防守）]]

## 相关决策

- [[D20260602-R010B5R1-非线性组合回撤预算代理审计通过]] — risk_scale 首次公式化
- [[D20260603-R010B5R5-严格Counterfactual审计未通过]] — 整体替代被否证

~~~