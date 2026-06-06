---
type: 术语
term_id: TERM-20260604T000000Z-mig-DRAWDOWNTHRESHOLD355BE
legacy_id: "drawdown_threshold（回撤门槛）"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📖 概念\drawdown_threshold（回撤门槛）.md'
source_old_relative_path: '📖 概念/drawdown_threshold（回撤门槛）.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# drawdown_threshold（回撤门槛）

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`drawdown_threshold（回撤门槛）`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📖 概念\drawdown_threshold（回撤门槛）.md`
- 新库 ID：`TERM-20260604T000000Z-mig-DRAWDOWNTHRESHOLD355BE`
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
status: 待补全
created_at: 2026-06-04
updated_at: 2026-06-04
tags:
  - 概念/补链
  - 参数
~~~
## 旧库原文

~~~markdown
# drawdown_threshold（回撤门槛）

drawdown_threshold 是回撤反馈类仓位控制中的触发参数，表示资金曲线回撤达到某个阈值后才开始缩放风险仓。

在当前研究库中，它只作为 [[非线性仓位控制（概念）]] 与 [[risk_scale（风险仓缩放系数）]] 的参数概念，不代表已进入实盘。

## 相关

- [[risk_scale（风险仓缩放系数）]]
- [[资金曲线状态]]
- [[组合回撤预算]]

~~~