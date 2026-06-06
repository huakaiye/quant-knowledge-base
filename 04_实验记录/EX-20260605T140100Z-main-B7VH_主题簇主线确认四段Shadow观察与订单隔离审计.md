---
type: 实验记录
ex_id: EX-20260605T140100Z-main-B7VH
rd_id: RD-20260605T131301Z-main-KC7N
status: completed
stage: four_segment_shadow_isolation_completed
owner: main
created_at: 2026-06-05T14:01:00Z
updated_at: 2026-06-05T15:56:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动诊断模块
decision_ids: []
lit_ids: [LIT-20260603T000000Z-mig-1999MOSKOWITZ83801, LIT-20260605T133500Z-main-E46H, LIT-20260605T133518Z-main-ZU9R]
idea_ids: []
platform_project: E:\量化平台_V1.4.0
config_paths:
  - E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/
result_paths:
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_on/2020_2021/53c9c4fb4b824f638ed2459025207196/
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_off/2020_2021/200cdf90e32b4902b330be590d653c6e/
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_on/2022_2023/6d064724e68f48459016fac78debfbf2/
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_off/2022_2023/9230f0427dcc4022b970cec4fec7965f/
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_on/2024/052268fd49cd46c88c2b7a3e025f8d8e/
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_off/2024/7175f8e20ed441a3950e285349f607b5/
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_on/2025_20260519/d0193fde90f24d0a81c45d7145b0b28b/
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_off/2025_20260519/823b8baa678648aead79bf8b3c033173/
summary_paths:
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/summary/
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/summary/summary.json
quality_gate: preregistered_before_execution
tags: [双池轮动, 主题簇, 行业动量, 主线确认, shadow, 订单隔离, 非hard5]
---

# 主题簇主线确认四段Shadow观察与订单隔离审计

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T131301Z-main-KC7N_双池轮动主题簇主线确认模块|双池轮动主题簇主线确认模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[06_文献资料/08_已归档/LIT-20260603T000000Z-mig-1999MOSKOWITZ83801_L20260531-031DoIndustriesExplainMomentum|Do Industries Explain Momentum?]]；[[06_文献资料/00_待处理/LIT-20260605T133500Z-main-E46H_Time Series Momentum|Time Series Momentum]]；[[06_文献资料/00_待处理/LIT-20260605T133518Z-main-ZU9R_Do Industries Lead Stock Markets|Do Industries Lead Stock Markets]]
- 产生的决策：
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]

## 1. 新手摘要

这次实验想知道：主题簇 shadow 字段在四段正式 V2 路径中是否稳定，同时是否能被证明不改变交易。  
我们原本预计：每个分段的 shadow-on 都有 `R010-THEME SHADOW` 日志，shadow-on 与 shadow-off 的订单、成交和净值哈希一致。  
实际看到：四段全部完成，共 1542 条 shadow 日志，`changes_targets=true` 为 0；四段 shadow-on/off normalized 交易产物哈希全部一致。  
这说明：主题簇 shadow 可以作为干净观察面板继续研究，当前证据足以证明本轮实现没有改变交易目标、订单、成交、净值和持仓。  
但还不能说明：`6p_same` 或金融坏桶已经可交易，因为本轮没有计算 forward return、错位主题、随机主题或成本扰动。  
下一步要做：新开收益归因实验，按 `6p_same`、主题集中度、金融坏桶、市场状态和 A1/A2 action 分层，看这些观察字段能否解释后续收益和回撤。  

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260605T131301Z-main-KC7N_双池轮动主题簇主线确认模块|双池轮动主题簇主线确认模块]]。上一轮 `EX-20260605T133436Z-main-TZ5W` 已在 2025Q1 smoke 中证明：主题字段可以写入 V2 action/shadow 日志，且 `changes_targets=true` 为 0。但单段 smoke 不能代表全历史，也没有 shadow-off 同区间基准哈希。

本轮使用 A11 cap5 tiered v2 作为非 hard5 交易骨架，在四个分段上生成 shadow-on 和 shadow-off 两套配置。核心验证是工程和审计边界：主题模块只观察，不影响订单；同时收集 `6p_same`、`3_5_same`、坏桶主题和主题分布，为后续收益归因预备干净面板。

## 3. 实验前假设

只验证一件事：在四段正式 V2 回测中，主题簇 shadow 字段能稳定记录，且 shadow-on 与 shadow-off 的交易产物哈希一致，证明该模块没有影响真实目标、权重、订单和成交。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：四段 shadow-on 均能抽取 `R010-THEME SHADOW` 日志；`r010theme_bucket` 至少覆盖 `6p_same` 和 `3_5_same` 中的一类；汇总脚本输出 `theme_shadow_records.csv`、`bucket_summary.csv`、`theme_summary.csv`、`on_off_hash_audit.csv`。
- 交易行为：每段 shadow-on 与 shadow-off 的 `orders.json`、`trades.csv`、`equity_curve.csv`、`positions.csv` 哈希应一致；shadow 日志中 `r010theme_changes_targets=true` 计数必须为 0。
- 风险表现：本轮不评价风险收益改善；如果 shadow-on/off 净值不同，优先判定为隔离失败或非确定性问题，而不是策略有效。
- 分段表现：2020-2021、2022-2023、2024、2025-20260519 四段均需生成可审计结果；若只跑完部分分段，只能标记 partial。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| A11 cap5 tiered v2 四段原配置 | 非 hard5 交易骨架，避免与 hard5/score cap 主线混用 | `E:/量化平台_V1.4.0/configs/research/R010-A11/score_cap_backtest/r010a11_score_cap5_tiered_v2_*.json` |
| shadow-on 四段配置 | 开启主题簇观察字段，不改变交易 | `E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_on/` |
| shadow-off 四段配置 | 同区间订单哈希对照 | `E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_off/` |
| 日志抽取与哈希审计脚本 | 统一解析四段结果和对照哈希 | `E:/量化平台_V1.4.0/scripts/research/summarize_r010theme_shadow_split.py` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- shadow-on/off 哈希不一致可能来自平台非确定性、动态池缓存、执行时间或日志副作用，不一定是主题字段直接改交易。
- 如果某些分段没有金融主题或没有 `6p_same`，说明样本分布不足，不代表坏桶假设无效。
- 主题字段稳定出现，不等于主题簇有收益解释力；后续仍需 forward-return 或真实换仓归因。
- 四段都通过也可能只是证明工程隔离，不能替代未来函数、样本外和成本扰动审计。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 任一 shadow-on 分段没有 `R010-THEME SHADOW` 日志。
- 任一 shadow-on 分段出现 `r010theme_changes_targets=true`。
- 任一 shadow-on/off 同区间的 `orders.json`、`trades.csv`、`equity_curve.csv` 或 `positions.csv` 哈希不一致，且无法解释为平台非确定性。
- 汇总脚本无法从 action 日志稳定抽取 `r010theme_*` 字段。
- 看完分布后修改主题词表或阈值，必须另开新实验，不得覆盖本预注册。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 工程审计通过 | 主题来自固定名称关键词表；候选排序来自当日 `filter_etfs` 已有结果 |
| 信号生成和成交价格不存在同 bar 泄漏 | 工程审计通过 | 本轮不使用未来收益，不用主题字段成交 |
| 股票池或 ETF 池不存在未来成分泄漏 | 沿用基准，未新增风险 | 使用 A11 cap5 tiered v2 四段骨架，不新增 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 四段通过 | 四段 `orders.json`、`trades.csv` 去除随机 `order_id` 后一致，`equity_curve.csv`、`positions.csv` 完全一致 |

负控或错位检查：

- 本轮的负控是 shadow-off 同区间基准哈希和去主题观察字段。错位主题、随机主题用于下一步收益归因；本轮只检查它们的脚本接口预留，不直接评价收益。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 固定 `topn=10`、`same_count_min=6`、`bad_themes=["金融"]` |
| 样本内、验证集、样本外划分清楚 | 通过 | 四段固定：2020-2021、2022-2023、2024、2025-20260519 |
| 邻近参数敏感性合理 | 待后续 | 本轮不扫参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | shadow 不改变交易，成本不能归因于主题字段 |
| 已做消融或负控 | 部分预注册 | shadow-off 哈希对照；收益负控留到下一轮 |
| 未只报告最优结果 | 通过 | 四段全量报告，不按结果筛选分段 |

证据等级：执行前 `L0`；四段工程审计全通过也最多为 `L1_engineering`，不能 promote。

## 10. 执行记录

### 平台配置

```text
计划生成：
E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_on/theme_shadow_on_cap5_tiered_v2_2020_2021.json
E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_off/theme_shadow_off_cap5_tiered_v2_2020_2021.json
其余三段同名模式：2022_2023、2024、2025_20260519。
```

### 运行命令

```bash
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 scripts/research/generate_r010theme_shadow_split_configs.py --ex-id EX-20260605T140100Z-main-B7VH"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_on/theme_shadow_on_cap5_tiered_v2_2024.json"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_off/theme_shadow_off_cap5_tiered_v2_2024.json"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_on/theme_shadow_on_cap5_tiered_v2_2025_20260519.json"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_off/theme_shadow_off_cap5_tiered_v2_2025_20260519.json"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_on/theme_shadow_on_cap5_tiered_v2_2022_2023.json"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_off/theme_shadow_off_cap5_tiered_v2_2022_2023.json"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_on/theme_shadow_on_cap5_tiered_v2_2020_2021.json"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/shadow_off/theme_shadow_off_cap5_tiered_v2_2020_2021.json"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_r010theme_shadow_split.py --ex-id EX-20260605T140100Z-main-B7VH"
```

### 结果路径

```text
计划路径：
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/split/
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/summary/
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/summary/theme_shadow_records.csv
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T140100Z-main-B7VH/summary/on_off_hash_audit.csv
```

## 11. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 完成分段 | 4 段 | 4 段 | 符合 | `missing_runs=[]` |
| shadow 日志 | 预期存在 | 1542 条 | 符合 | 与 action 带主题字段条数一致 |
| `changes_targets=true` | 预期 0 | 0 | 符合 | 主题 shadow 没有声明改变目标 |
| raw hash | 预期可能受随机 ID 影响 | orders/trades raw 不一致，equity/positions 一致 | 部分不一致 | orders/trades 差异来自随机 `order_id` |
| normalized hash | 预期一致 | 16/16 一致 | 符合 | 四段四类产物均通过 normalized hash |
| bucket 合计 | 只观察 | `3_5_same` 1026；`6p_same` 391；`0_2_same` 125 | 不做收益解释 | 有足够样本进入下一轮分层归因 |
| top_theme 合计 | 只观察 | 资源能源 318；跨境 256；其他 193；宽基 181；科技信息 148；医药 117；新能源 89；金融 55 | 不做收益解释 | 金融坏桶样本不再只来自 2024 的 1 条 |

### 分段摘要

| 分段 | shadow 日志 | on run | off run | on/off 总收益 | normalized hash |
| --- | ---: | --- | --- | ---: | --- |
| 2020-2021 | 486 | `53c9c4fb4b824f638ed2459025207196` | `200cdf90e32b4902b330be590d653c6e` | `1.2507960000000011` / `1.2507960000000011` | 4/4 通过 |
| 2022-2023 | 484 | `6d064724e68f48459016fac78debfbf2` | `9230f0427dcc4022b970cec4fec7965f` | `0.31214629999999954` / `0.31214629999999954` | 4/4 通过 |
| 2024 | 242 | `052268fd49cd46c88c2b7a3e025f8d8e` | `7175f8e20ed441a3950e285349f607b5` | `0.670052200000002` / `0.670052200000002` | 4/4 通过 |
| 2025-20260519 | 330 | `d0193fde90f24d0a81c45d7145b0b28b` | `823b8baa678648aead79bf8b3c033173` | `2.1797361000000026` / `2.1797361000000026` | 4/4 通过 |

## 12. 支持证据

- `summary.json` 显示 `record_count=1542`、`all_completed=true`、`all_normalized_hashes_match=true`、`all_changes_targets_false=true`。
- `segment_summary.csv` 显示四段 `changes_targets_true_count=0`、`error_count=0`。
- `on_off_hash_audit.csv` 显示四段 `orders.json`、`trades.csv`、`equity_curve.csv`、`positions.csv` 的 normalized hash 全部一致。
- `bucket_summary.csv` 显示 `6p_same` 在四段均出现，合计 391 条；`3_5_same` 合计 1026 条。

## 13. 反对证据

- raw hash 中 orders/trades 不一致，虽然已确认是随机 `order_id`，但最终审计应以 normalized hash 为准。
- 金融主题合计 55 条，仍然偏少；坏桶假设需要后续归因和负控支持。
- 当前仍没有收益归因、错位主题、随机主题或成本扰动；只证明工程隔离。

## 14. 偏差诊断

四段均符合主要预测：shadow 日志稳定、`changes_targets` 为 0、normalized 交易产物一致。不一致的是 raw orders/trades hash 不一致，原因是平台每次生成随机 `order_id`，不是交易行为差异。

本轮已经完成四段工程审计，但只允许记为 `L1_engineering observe`。它证明观察字段可用和不改交易，不证明主题簇能提升收益。

## 15. 研究判断

建议状态：`promote_candidate / promote / revise / park / kill / observe`

建议状态：`observe`

理由：四段工程隔离通过，值得进入收益归因；但尚无 forward-return、错位主题、随机主题、成本扰动和参数敏感性证据，因此不能 promote。

## 16. 下一步

新开收益归因实验：对 shadow 日志按 `6p_same`、金融坏桶、主题集中度、市场状态和 A2/A1 action 分层，计算后续收益或真实持仓路径差异。下一轮必须继续预注册错位主题和随机主题负控，避免把事后主题行情误读成可交易规则。

## 子代理调用记录

- 调用状态：exempt
- 子代理豁免：历史实验记录在子代理强制门禁生效前创建；主控：main；时间：2026-06-06T00:23:50Z
- 后续要求：若本实验用于新决策、路线升级或当前最佳策略判断，必须补充子代理复核记录并同步 `01_台账/子代理调用台账.csv`。
