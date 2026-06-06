---
type: 旧库迁移归档
mig_id: MIG-20260604T000000Z-mig-RYYYYMMDD0014E475
legacy_id: "RYYYYMMDD-001"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\🧪 实验\研究记录模板.md'
source_old_relative_path: '🧪 实验/研究记录模板.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# RYYYYMMDD-001 研究主题

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`RYYYYMMDD-001`
- 来源旧库路径：`E:\【笔记库】\量化研究库\🧪 实验\研究记录模板.md`
- 新库 ID：`MIG-20260604T000000Z-mig-RYYYYMMDD0014E475`
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
type: 实验
research_id: RYYYYMMDD-001
created_at: YYYY-MM-DD
updated_at: YYYY-MM-DD
direction_id: 待填
topic_id: 待填
result_status: preregistered_no_run
governance_review_status: 待确认
related_strategies:
  - 待填
belief_id: BLFYYYYMMDD-001
hypothesis_id: HYYYYMMDD-001
source_tags:
  - "[[趋势跟踪类策略]]"
execution_tags:
  - "[[ETF轮动]]"
  - "[[日频调仓]]"
status: 草稿
decision: 待判断
research_stage: 灵感收集
progress: 0
blocker:
next_action: 待填
related_factor:
prior_confidence: 中
posterior_confidence: 待判断
decision_action: 待判断
baseline_return:
test_return:
baseline_mdd:
test_mdd:
config_path: configs/research/<direction_id>/RYYYYMMDD-001_<topic_id>/
result_path: results/v2/research/<direction_id>/RYYYYMMDD-001_<topic_id>/
decision_ids: 待填
tags:
  - 研究/实验
  - 状态/草稿
~~~
## 旧库原文

~~~markdown
# RYYYYMMDD-001 研究主题

## 研究信念

关联信念：BLFYYYYMMDD-001_研究信念名称

当前相信的机制：

先验置信度：中

## 本次研究假设

说明这次实验想验证什么。假设必须是可被支持或反驳的单一主张，不要写成宽泛的策略愿望。

## 可观察预测

如果假设成立，预期应当观察到：

- 预测 1：
- 预测 2：
- 预测 3：

## 竞争性解释

| 竞争性解释 | 为什么可能成立 | 如何区分 |
| --- | --- | --- |
| 风格暴露 | 待填 | 中性化或暴露分解 |
| 样本偶然 | 待填 | 年份切分、滚动样本外、去极端日 |
| 交易不可实现 | 待填 | 成本、滑点、成交约束 |
| 数据口径问题 | 待填 | 时点审计、延迟执行 |

## 证伪测试与决策规则

| 测试 | 目的 | kill / revise / promote 规则 |
| --- | --- | --- |
| 样本外 | 判断是否依赖样本内 | 待填 |
| 消融 | 判断模块是否真的贡献收益 | 待填 |
| 成本与换手 | 判断是否可交易 | 待填 |
| 参数扰动 | 判断是否脆弱 | 待填 |

## 双标签

收益来源：[[趋势跟踪类策略]]
执行方式：[[ETF轮动]]、[[日频调仓]]

## 关联对象

目标策略：待填
使用因子：待填
理论来源：待填

## 改动内容

说明新增因子、组合方式、风控规则或参数结构变化。

## 实验配置

| 项目 | 内容 |
| --- | --- |
| 基准配置 | `configs/research/<direction_id>/RYYYYMMDD-001_<topic_id>/baseline.json` |
| 实验配置 | `configs/research/<direction_id>/RYYYYMMDD-001_<topic_id>/test_v1.json` |
| 回测区间 | 待填 |
| 初始资金 | 待填 |
| 费率口径 | 待填 |
| 结果目录 | `results/v2/research/<direction_id>/RYYYYMMDD-001_<topic_id>/` |

## 关键对比

| 版本 | 年化收益 | 总收益 | 最大回撤 | 夏普 | 换手率 | 结论 |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 基准版 | 待填 | 待填 | 待填 | 待填 | 待填 | 对照 |
| 实验版 | 待填 | 待填 | 待填 | 待填 | 待填 | 待判断 |

## 预期与实际差异

| 预测 | 实际观察 | 一致/冲突/不确定 | 备注 |
| --- | --- | --- | --- |
| 预测 1 | 待填 | 待判断 | 待填 |
| 预测 2 | 待填 | 待判断 | 待填 |
| 预测 3 | 待填 | 待判断 | 待填 |

## 偏差诊断

最大意外：

可能原因：

- 机制偏差：
- 信号偏差：
- 样本偏差：
- 交易偏差：
- 组合暴露：
- 统计偏差：

是否存在比原假设更简单的解释：

## 大型结果表

| 文件 | 说明 |
| --- | --- |
| `results/v2/research/<direction_id>/RYYYYMMDD-001_<topic_id>/parameter_scan.csv` | 参数扫描结果 |
| `results/v2/research/<direction_id>/RYYYYMMDD-001_<topic_id>/trades.csv` | 交易明细 |

## 消融与样本外

说明关闭关键模块后的结果、滚动验证结果和样本外表现。

## 信念更新

| 项目 | 内容 |
| --- | --- |
| 实验前置信度 | 中 |
| 实验后置信度 | 待判断 |
| 支持证据 | 待填 |
| 反对证据 | 待填 |
| 仍未解决的问题 | 待填 |

## 下一轮实验

下一轮实验目的：减少不确定性 / 提升收益 / 验证交易可行性 / 其他

最有信息量的下一步：

- 待填

## 方向决策卡片

如果本实验改变研究方向、候选优先级、交易边界、实盘观察边界或后续实验顺序，必须新建或更新 `🔀 决策/DYYYYMMDD-主题.md`，并在此处链接。

关联决策卡片：待填

是否已更新 [[📊 驾驶舱]]：否

是否需要更新 Canvas：待判断

是否已刷新 [[研究资产清单]]：否

## 结论

结论状态：kill / revise / promote / park / 待判断
是否进入策略路线图：否

## 风险备注

记录过拟合、样本依赖、成交假设、数据缺口、换手过高等风险。

~~~