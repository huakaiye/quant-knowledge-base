---
type: 实验记录
ex_id: EX-20260605T133436Z-main-TZ5W
rd_id: RD-20260605T131301Z-main-KC7N
status: completed
stage: shadow_smoke_completed
owner: main
created_at: 2026-06-05T13:34:36Z
updated_at: 2026-06-05T13:48:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动诊断模块
decision_ids: []
lit_ids: [LIT-20260603T000000Z-mig-1999MOSKOWITZ83801, LIT-20260605T133500Z-main-E46H, LIT-20260605T133518Z-main-ZU9R]
idea_ids: []
platform_project: E:\量化平台_V1.4.0
config_paths:
  - E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/theme_cluster_shadow_smoke_2025q1.json
result_paths:
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/smoke_2025q1/
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/smoke_2025q1/0a952e934da745d7aa0979f88ed0d55f/
summary_paths:
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/smoke_2025q1/0a952e934da745d7aa0979f88ed0d55f/summary.json
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/smoke_2025q1/0a952e934da745d7aa0979f88ed0d55f/manifest.json
quality_gate: preregistered_before_execution
tags: [双池轮动, 主题簇, 行业动量, 主线确认, shadow, 非hard5]
---

# 主题簇主线确认Formal V2 Shadow预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T131301Z-main-KC7N_双池轮动主题簇主线确认模块|双池轮动主题簇主线确认模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[06_文献资料/08_已归档/LIT-20260603T000000Z-mig-1999MOSKOWITZ83801_L20260531-031DoIndustriesExplainMomentum|Do Industries Explain Momentum?]]；[[06_文献资料/00_待处理/LIT-20260605T133500Z-main-E46H_Time Series Momentum|Time Series Momentum]]；[[06_文献资料/00_待处理/LIT-20260605T133518Z-main-ZU9R_Do Industries Lead Stock Markets|Do Industries Lead Stock Markets]]
- 产生的决策：
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]

## 1. 新手摘要

这次实验想知道：能否把主题簇主线确认嵌入正式 V2 回测链路，但只作为日志观察，不改变持仓。  
我们原本预计：平台会稳定输出 `R010-THEME SHADOW` 日志，并在 R010-B action JSON 中带上 `6p_same` 强主线和金融坏桶字段。  
实际看到：2025Q1 smoke 生成 57 条带主题字段的 `R010-B ACTION`，57 条独立 `R010-THEME SHADOW`；`r010theme_changes_targets=true` 为 0。  
这说明：主题簇主线确认已能进入正式 V2 日志链路，当前实现保持观察属性，不改变交易目标。  
但还不能说明：即使 smoke 通过，也只说明日志链路可用，不能说明主题簇能赚钱。  
下一步要做：新开四段 formal V2 shadow 观察，加入错位主题、随机主题和去主题消融。  

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260605T131301Z-main-KC7N_双池轮动主题簇主线确认模块|双池轮动主题簇主线确认模块]]。上一轮 `EX-20260605T131309Z-main-QCVT` 的只读审计显示，强主题簇 `6p_same` 的 H10 均值明显好于孤立事件，但 H5/H10 胜率不稳定，随机负控仍有正收益，因此只能进入 formal V2 shadow，不得写成交易结论。

顶刊启发只用于提出机制：Moskowitz 与 Grinblatt 的行业动量说明动量可能在行业层级存在；Moskowitz、Ooi、Pedersen 的时间序列动量提示趋势延续需要事前确认；Hong、Torous、Valkanov 的行业领先研究提示主题信息可能逐步扩散。三者共同支持“看 Top1 背后是否有同主题主线”的假设，但不替代本库实验。

本轮刻意避开 hard5/score cap 主线。shadow 标签只在当前策略已通过分数上限与过滤后的候选排序上计算，不新增无限分数旁路，不改变 `max_score`，不改交易目标。

## 3. 实验前假设

只验证一件事：固定主题关键词表能否在正式 V2 回测日志中稳定产出事前可得的主题簇字段，并证明这些字段不会改变当日 `raw_targets`、`final_targets`、权重和订单。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`R010-B ACTION` JSON 中出现 `r010theme_bucket`、`r010theme_6p_same`、`r010theme_bad_theme_mainline`、`r010theme_top_theme_count` 等字段；同时独立出现 `【R010-THEME SHADOW】` 日志。
- 交易行为：所有主题簇字段只写日志，不修改 `raw_targets`、`final_targets`、`context._r010b_target_weights` 和订单；日志里 `r010theme_changes_targets=false`。
- 风险表现：本轮 smoke 不评价收益优劣，只检查路径和字段。任何收益变化都不能归因于主题簇。
- 分段表现：先跑 2025Q1 smoke；若通过，下一步才预注册 2020-2021、2022-2023、2024、2025-20260519 四段观察。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| A11 cap5 tiered v2 2025 配置 | 作为当前非 hard5 基准骨架，只叠加 shadow 字段 | `E:/量化平台_V1.4.0/configs/research/R010-A11/score_cap_backtest/r010a11_score_cap5_tiered_v2_2025_20260519.json` |
| 本次 smoke 配置 | 同一交易逻辑，加 `r010theme_mainline_shadow_enabled=true` | `E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/theme_cluster_shadow_smoke_2025q1.json` |
| 上一轮只读审计 | 提供为什么只测 `6p_same` 与金融坏桶，不新增阈值搜索 | `E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T131309Z-main-QCVT/theme_cluster_mainline_readonly_summary.json` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 日志字段正常，只说明工程链路通了，不说明主题簇有收益解释力。
- 当前主题表由 ETF 名称关键词生成，可能分类粗糙或主题粒度过大。
- 如果 2025Q1 没有 `6p_same` 或金融坏桶事件，smoke 无法验证标签分布，只能验证日志存在。
- A11 cap5 tiered 基准本身已有 A2/B3 交易效果，主题 shadow 不应被误认为导致收益变化。
- 后续四段如果有效，也可能只是市场阶段、score、R2 或广度的代理。

## 7. 证伪条件

出现以下情况，本假设不通过：

- smoke 运行没有输出 `【R010-THEME SHADOW】` 日志。
- `R010-B ACTION` JSON 中缺少预注册主题字段。
- shadow 字段导致 `raw_targets`、`final_targets`、权重或订单发生变化。
- 主题分类需要看结果后手工改词表才能产出想要的标签。
- 错位主题、随机主题或去主题消融在下一阶段得到同等解释力。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过但限于工程 smoke | 主题来自固定名称关键词表；候选排序来自当日 `filter_etfs` 已有中间结果，日志字段为 `source=raw_post_score_filter` |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 本轮不使用未来收益，主题字段只进入日志；`r010theme_changes_targets=true` 计数为 0 |
| 股票池或 ETF 池不存在未来成分泄漏 | 沿用基准，未新增风险 | smoke 使用 A11 cap5 tiered v2 基准骨架，不新增 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 独立 shadow 日志 57 条，`r010theme_changes_targets=true` 为 0；代码只在既有目标生成后输出日志 |

负控或错位检查：

- 本轮先不评价预测收益，只做工程 smoke。后续正式观察必须加入错位主题和随机主题负控；若负控同样有效，优先怀疑市场阶段或主题分类噪音。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 本轮只允许 `topn=10`、`same_count_min=6`、`bad_themes=["金融"]`，来自上一轮观察，不新增看结果后的阈值 |
| 样本内、验证集、样本外划分清楚 | 不适用/待扩展 | smoke 只验证链路；四段观察另行预注册 |
| 邻近参数敏感性合理 | 待扩展 | 本轮不做参数扫描 |
| 成本、滑点或换手扰动已检查 | 不适用 | shadow 不改变交易，成本无从归因 |
| 已做消融或负控 | 待扩展 | smoke 后下一步做错位主题、随机主题、去主题字段消融 |
| 未只报告最优结果 | 预注册约束 | smoke 只报告日志存在、字段完整性和是否改变交易 |

证据等级：`L1_engineering`。本轮只证明日志链路和 default-off shadow 边界，不证明收益有效，不能 promote。

## 10. 执行记录

### 平台配置

```text
E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/theme_cluster_shadow_smoke_2025q1.json
```

### 运行命令

```bash
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/theme_cluster_shadow_smoke_2025q1.json"
```

备注：外层工具等待 120 秒后返回 timeout 124，但平台 run 已完成并生成完整 `summary.json`、`manifest.json` 与结果包；复查时没有残留同配置回测进程。

### 结果路径

```text
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/smoke_2025q1/
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/smoke_2025q1/0a952e934da745d7aa0979f88ed0d55f/
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/smoke_2025q1/0a952e934da745d7aa0979f88ed0d55f/summary.json
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T133436Z-main-TZ5W/smoke_2025q1/0a952e934da745d7aa0979f88ed0d55f/logs.jsonl
```

## 11. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 平台 run | A11 cap5 tiered v2 骨架 | `0a952e934da745d7aa0979f88ed0d55f` | 成功生成结果 | 外层 timeout 不等于 run 失败 |
| 参数日志 | 预期 1 条 | 1 条 | 符合 | `shadow=True topn=10 same_min=6 bad_themes=['金融']` |
| 带主题字段的 `R010-B ACTION` | 预期存在 | 57 条 | 符合 | action JSON 已含 `r010theme_bucket` 等字段 |
| 独立 `R010-THEME SHADOW` | 预期存在 | 57 条 | 符合 | shadow 日志可独立抽取 |
| `r010theme_changes_targets=true` | 预期 0 | 0 | 符合 | 没有主题 shadow 改目标的日志证据 |
| shadow 桶分布 | 只做观察 | `6p_same` 17；`3_5_same` 40 | 不做收益解释 | 2025Q1 有足够强主题样本进入下一阶段观察 |
| 主题分布 | 只做观察 | 跨境 21；科技信息 14；宽基 9；资源能源 8；其他 4；医药 1 | 不做收益解释 | 2025Q1 未出现金融主线坏桶 |
| 日志错误 | 预期 0 | 0 | 符合 | 未发现 `ERROR` 或 `Traceback` |

## 12. 支持证据

- `logs.jsonl` 第 11 行出现 `【R010-THEME 参数】shadow=True topn=10 same_min=6 bad_themes=['金融'] source=raw_post_score_filter`。
- `R010-B ACTION` JSON 含完整 `r010theme_*` 字段，首个样例为跨境主题 `6p_same`，Top10 中跨境 6 只。
- 独立 `R010-THEME SHADOW` 日志 57 条，与 action 主题字段条数一致。
- 统计脚本显示 `changes_targets_true_count=0`、`error_count=0`。
- 平台 `summary.json` 与 `manifest.json` 已生成，说明 run 完成；结果路径只登记，不复制大文件。

## 13. 反对证据

- 本轮没有跑 shadow disabled 的同区间基准哈希对照，因此“未改变订单”的证据来自代码路径和 shadow 日志字段，不是订单逐笔 diff。
- 2025Q1 未出现金融主线坏桶，无法验证金融坏桶字段在真实分布中的触发。
- 本轮没有评价收益，也没有做错位主题、随机主题和去主题消融；不能把 `6p_same` 写成有效交易信号。
- 外层命令超时返回 124，虽然平台结果完整，但后续长区间回测应使用更长 timeout 或分段脚本。

## 14. 偏差诊断

实验前预测基本匹配：主题字段写入 action JSON，独立 shadow 日志存在，且没有主题模块改目标的证据。不一致处是命令外层返回 timeout 124；原因是工具等待时间短于平台 run 生成和打包耗时，不是策略运行错误。

另一个局限是本轮 2025Q1 没有金融坏桶触发，因此只能证明字段存在，不能证明坏桶分类在样本中可用。

## 15. 研究判断

可选状态：`promote_candidate / promote / revise / park / kill / observe`

建议状态：`observe`

理由：工程链路通过，值得进入四段 formal V2 shadow 观察；但本轮只达到 `L1_engineering`，没有收益、样本外、成本、消融和负控证据，禁止 promote 或接入默认交易逻辑。

## 16. 下一步

下一轮新开四段 formal V2 shadow 观察，减少“日志链路可用但样本外无解释力”的不确定性。四段观察必须加入 shadow-disabled 同区间基准哈希对照、错位主题、随机主题和去主题消融。

## 子代理调用记录

- 调用状态：exempt
- 子代理豁免：历史实验记录在子代理强制门禁生效前创建；主控：main；时间：2026-06-06T00:23:50Z
- 后续要求：若本实验用于新决策、路线升级或当前最佳策略判断，必须补充子代理复核记录并同步 `01_台账/子代理调用台账.csv`。
