---
type: 研究决策
dec_id: DEC-20260605T000000Z-mig-D20260605R010A9S5LIVEREACBC67
legacy_id: "D20260605-R010A9S5-live-readiness-keep-shadow"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\🔀 决策\D20260605-R010A9S5-LiveReadiness未通过保持Shadow.md'
source_old_relative_path: '🔀 决策/D20260605-R010A9S5-LiveReadiness未通过保持Shadow.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# D20260605 R010A9S5 Live-Readiness 未通过保持 Shadow

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`D20260605-R010A9S5-live-readiness-keep-shadow`
- 来源旧库路径：`E:\【笔记库】\量化研究库\🔀 决策\D20260605-R010A9S5-LiveReadiness未通过保持Shadow.md`
- 新库 ID：`DEC-20260605T000000Z-mig-D20260605R010A9S5LIVEREACBC67`
- 证据等级：legacy_raw
- 结论边界：本页保留旧库内容，不代表新库已经采纳旧结论。

## 关联链接

- 迁移总卡：[[11_迁移暂存/MIG-20260605T120000Z-mig-BATCH_旧库批量迁移总卡|旧库批量迁移总卡]]
- 关联方向：[[02_研究方向/RD-20260605T115651Z-main-DP00_双池轮动策略|双池轮动策略]]
- 关联策略：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
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
decision_id: "D20260605-R010A9S5-live-readiness-keep-shadow"
created_at: "2026-06-05"
updated_at: "2026-06-05"
direction_id: "R010-A"
topic_id: "R010-A9S5-live-readiness"
status: 生效
decision: keep_shadow_no_guarded_live
related_record:
  - "[[R20260605-084_R010A9S5_预可见容量护栏Shadow四分段验证]]"
  - "[[R20260605-085_R010A9S5_放行事件LiveReadiness只读审计]]"
related_strategy:
  - "[[ETF双池动量轮动]]"
tags:
  - 决策/ETF双池
  - R010-A9
  - default-off
  - shadow
~~~
## 旧库原文

~~~markdown
# D20260605 R010A9S5 Live-Readiness 未通过保持 Shadow

## 决策

```text
keep_shadow_no_guarded_live
```

R010-A9S5 容量护栏虽然通过 default-off shadow 隔离验证，但放行事件 live-readiness 未通过。S5 继续保持 shadow 观察，不进入 guarded-live，不进入实盘。

## 依据

只读审计结果：

```text
checked_events = 15
allowed_events = 13
blocked_events = 2
ready_initial_events = 8
review_required_events = 5

allowed_interval_delta_after_fee_sum = +23372.35
allowed_negative_after_fee = 3
```

5 个放行后仍需复核的风险：

```text
negative_after_fee = 3
same_day_5pct_capacity_not_full = 1
adjacent_trigger_path_dependency = 2
```

核心问题：

- S5 能剔除最大容量负样本，但无法消除所有负贡献。
- 连续触发事件存在路径依赖，不能直接按独立事件授权交易化。
- 同日容量不足只能用于复核，不能作为信号。

## 允许

- 保留 S5 default-off shadow。
- 对 5 个复核事件继续做事前可见特征拆解。
- 继续寻找 ETF 双池轮动内部的新进攻增强候选。

## 禁止

- 禁止推进 S5 guarded-live。
- 禁止直接开启实盘。
- 禁止把 shadow 结果写入真实 targets、weights、orders。
- 禁止扩展小市值、A0/A1/all_actions。

## 下一步

优先级建议：

```text
1. 暂停 S5 交易化推进；
2. 若继续研究 S5，只做 5 个复核事件的只读归因；
3. 更优先回到 A2 / ETF 双池轮动内部寻找新的进攻收益增强候选。
```

~~~