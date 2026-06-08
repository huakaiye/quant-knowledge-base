---
type: 实验记录
ex_id: EX-20260606T185537Z-main-5KZW
rd_id: RD-20260605T115651Z-main-CORE
status: completed
stage: formal_16of16_completed_all_candidates_failed
owner: main
created_at: 2026-06-06T18:55:37Z
updated_at: 2026-06-07T09:45:00+08:00
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 多周期动量确认
decision_ids:
  - DEC-20260607T094500Z-main-RQ9M
lit_ids:
  - LIT-20260605T133336Z-main-67C4
  - LIT-20260605T133500Z-main-E46H
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/generate_5kzw_multi_momentum_configs.py
  - configs/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/formal/
result_paths:
  - results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/formal/
  - results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/logs/formal/
summary_paths:
  - results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/summary/formal/summary.json
  - results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/summary/formal/metrics.csv
  - results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/summary/formal/comparisons.csv
  - results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/summary/formal/conflict_summary.json
  - results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/summary/formal/conflict_by_segment.csv
  - results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/summary/formal/conflict_days_top.csv
quality_gate: L2_formal_16of16_failed_preregistered_candidate_gate
subagent_call_ids:
  - SUB-20260606T192000Z-main-MULTI
  - SUB-20260606T224013Z-main-5KZW
subagent_exemption:
tags: [双池轮动, 多周期动量, 动量质量, 预注册, formal完成, 反证]
---

# 多周期动量确认formal AB预注册与资源阻塞记录

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-CORE_双池轮动核心轮动模块|双池轮动核心轮动模块]]
- 父方向：[[02_研究方向/RD-20260605T115651Z-main-DP00_双池轮动策略|双池轮动策略]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 路线预注册：[[04_实验记录/EX-20260606T134047Z-main-HPHZ_五方向接手证据映射与首轮路线预注册|五方向接手证据映射与首轮路线预注册]]
- 上游反证：[[04_实验记录/EX-20260606T012550Z-main-LM3D_动量评分尺度与Top4排名权重预注册|动量评分尺度与 Top4 排名权重预注册]]
- 旧库线索：[[04_实验记录/EX-20260521T000000Z-mig-R202605210069BE6D_R20260521-006ETF双池动量质量因子准入|R20260521-006 ETF 双池动量质量因子准入]]
- 来源文献或灵感：[[06_文献资料/00_待处理/LIT-20260605T133336Z-main-67C4_score过热拥挤机制文献映射|score 过热拥挤机制文献映射]]
- 来源文献或灵感：[[06_文献资料/00_待处理/LIT-20260605T133500Z-main-E46H_Time Series Momentum|Time Series Momentum]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：只看 25 日短期动量第一名，是否太容易追到短期噪声；如果第一名同时满足 60 日、120 日中期趋势确认，策略会不会更稳。  
我们原本预计：多周期确认会减少弱趋势和震荡期买入，交易次数或无效换仓下降，回撤可能改善；但不能明显错过 2025_20260519 强趋势。  
实际看到：4 个变体 × 4 个历史分段共 16 个 formal 回测已全部完成；三个多周期确认候选都只有 `1/4` 分段 final 不低于 `baseline_top1_hard5`，均未通过预注册门槛。
这说明：多周期确认确实能少交易，也在 `3/4` 分段让最大回撤不差于基准，但收益稳定性不够，尤其在 2022_2023、2024、2025_20260519 三段都低于基准。
但还不能说明：`score > 5` 应该无条件保留或无条件废除；本实验只否定“用简单 60/120 或 25/60/120 趋势确认替代 hard5/高分处理”的这条路线。
下一步要做：关闭 5KZW 直接替代路线，把高分处理继续转向状态化 soft budget、事件归因、成本/换手约束和高分持仓的利润保护。

## 2. 研究背景

本实验对应用户方向 1“多周期动量确认”。Jegadeesh 和 Titman 的中期动量、Moskowitz/Ooi/Pedersen 的时间序列动量都提示趋势延续不应只看一个短窗口。当前双池轮动在核心排序中仍以短期动量和 hard5/A23 风控为主，旧库 R20260521-006 曾有“多周期趋势一致”线索，但该记录为迁移旧资产，不能直接采纳。

LM3D 已经反证 Top4 全买、25 天化和取消 hard5 上限，因此本实验不扩大持仓数量，只检验“Top1 是否必须通过中期趋势确认”。为避免和 A23 Agent 的状态分层预算重叠，本实验只改入场确认，不改高分仓位预算。

## 3. 实验前假设

在同一双池候选、同一 Top1 持仓数量和同一 hard5 基础约束下，短期 25 日 Top1 若同时通过 60 日、120 日趋势确认，会比单一短期 Top1 更稳，尤其在震荡和短期反弹误导阶段减少错误买入。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：至少一个多周期确认变体在 4 个分段中不少于 3 个分段 final 不明显低于 `baseline_top1_hard5`，且最大回撤至少在 1-2 个历史分段改善。
- 交易行为：交易次数和短期反复切换减少；若 Top1 不通过确认，应进入既有防守逻辑，而不是扫描 Top2/Top3。
- 风险表现：2020_2021 或 2022_2023 的震荡/急变阶段应减少弱趋势买入。
- 分段表现：2025_20260519 强趋势段不能明显错过，final 和参与度不得大幅弱于 baseline 与 A23。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `baseline_top1_hard5` | 同策略文件、关闭多周期确认，隔离实现差异 | `configs/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/formal/baseline_top1_hard5/` |
| `mconfirm_60_120_positive` | 只要求 Top1 的 60/120 日收益均为正 | `configs/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/formal/mconfirm_60_120_positive/` |
| `mconfirm_60_120_score055` | 在 60/120 日均为正基础上要求质量分不低于 0.55 | `configs/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/formal/mconfirm_60_120_score055/` |
| `mconfirm_25_60_120_positive` | 要求 25/60/120 日均为正，检验更严格确认 | `configs/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/formal/mconfirm_25_60_120_positive/` |
| A23 92/4/d09 cap60 | 当前 hard5 替代研究首选候选，用作外部参照 | `results/v2/research/R010-A23/state_tier_hot_budget/base70_blowoff92_m04_d09_cap60/` |

预注册分段：

| 分段 | 起止日期 |
| --- | --- |
| `2020_2021` | 2020-01-01 至 2021-12-31 |
| `2022_2023` | 2022-01-01 至 2023-12-31 |
| `2024` | 2024-01-01 至 2024-12-31 |
| `2025_20260519` | 2025-01-01 至 2026-05-19 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 严格确认只是长期低仓位，收益风险看似改善但实际错过趋势。
- 60/120 日窗口与 A23 的市场状态预算隐含重叠，贡献不独立。
- 结果只在某个单点阈值有效，邻近阈值或错位窗口失效。
- 旧库多周期质量分使用的是宽松评分，和本次“每个窗口必须为正”的严格确认不是同一机制。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 两个以上分段 final 明显低于 `baseline_top1_hard5` 或 A23/hard5。
- 2025_20260519 强趋势被明显错过，final 大幅下降且没有对应回撤改善。
- 回撤没有改善但收益下降。
- 仅 `score055` 或仅某个窗口组合有效，邻近或宽松/严格变体没有机制一致性。
- 成本扰动后优势消失，或只是通过少交易隐藏成本问题。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 初步通过，formal 后复核 | `_calc_multi_horizon_quality` 使用历史价格窗口和当前评分日价格，不读取未来 H1/H5/H10。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待 formal 复核 | 策略沿用平台当前调仓时点；本实验没有新引入成交后收益字段，但需在 run log 和 trades 中复核。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 沿用基线风险 | 使用同一双池配置和基线，不新增成分。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本实验不使用财务、宏观或估值字段。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 新参数默认关闭；只有 5KZW 配置显式开启。 |

负控或错位检查：

- formal 完成后补做窗口错位负控：将 60/120 日确认错位 1-2 个交易日，若错位仍同样有效，优先怀疑机制不独立或过拟合。
- formal 完成后补做窗口消融：只 60、只 120、60+120、25+60+120 分开看。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 初步通过 | 本卡固定 4 个变体和 4 个分段，不看结果追加新网格。 |
| 样本内、验证集、样本外划分清楚 | 初步通过 | 四段沿用主线 formal 分段；2025_20260519 是强趋势压力测试。 |
| 邻近参数敏感性合理 | 待补 | 本轮只生成核心确认变体；formal 后再决定是否开邻近阈值新实验。 |
| 成本、滑点或换手扰动已检查 | 未完成 | formal 尚未运行，成本扰动不能提前结论化。 |
| 已做消融或负控 | 未完成 | 当前只有预注册和工程测试。 |
| 未只报告最优结果 | 初步通过 | 16 个配置全量生成，后续汇总必须报告所有分段和所有变体。 |

证据等级：`L2_formal_16of16_failed_preregistered_candidate_gate`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called_mixed`

子代理豁免：无；本实验先后调用过子代理。第一次大范围盘点失败，第二次缩窄为只读配置与文档核对后完成。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260606T192000Z-main-MULTI | Turing | SUBTASK-20260606T192000Z-main-MULTI | gpt-5.3-codex-spark | 2026-06-06T19:20:00Z | 计划读取多周期动量相关旧库和平台资产 | 无 | 无 | 子代理上下文压缩超限，未产生可采纳输出 | 广范围证据映射任务过大，重复派发会浪费上下文 | 主控停止同类大盘点重试，改为本地检索和工程核对 | 只作为流程记录，不支持任何策略结论 |
| SUB-20260606T224013Z-main-5KZW | James | SUBTASK-20260606T224013Z-main-5KZW-CONFIGCHECK | gpt-5.3-codex-spark | 2026-06-06T22:40:13Z | 本实验卡；5KZW formal 配置目录；runner 与汇总脚本 | 无 | 无 | 只读确认 16 个预注册配置、runner 和 summary 脚本存在；formal 前 `completed_runs=0` | 仅做路径和字段核对，不运行回测，不判断策略有效性 | 主控采纳其路径完整性核对；formal 结果、冲突日归因和最终判断由主控完成 | 支持实验流程完整性，不独立支持 `kill` 决策 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
生成脚本：scripts/research/generate_5kzw_multi_momentum_configs.py
配置根：configs/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/formal/
配置数量：4 个变体 × 4 个分段 = 16
策略文件：src/strategies/research/etf_dual_pool_topn_vol_scaled.py
新增默认关闭参数：
- momentum_quality_multi_min_positive_ratio
- momentum_quality_multi_min_each_return
```

### 已执行命令

```powershell
python scripts/research/generate_5kzw_multi_momentum_configs.py
python -m pytest src/tests/strategies/test_etf_dual_pool_topn_hold.py -q
bash -n scripts/research/run_5kzw_formal.sh
python3 -m py_compile scripts/research/summarize_5kzw_formal.py
PYTHONUNBUFFERED=1 bash scripts/research/run_5kzw_formal.sh
python3 scripts/research/summarize_5kzw_formal.py
python3 scripts/research/analyze_5kzw_conflict_days.py
```

单元测试观察：`13 passed`。测试覆盖了多周期确认参数可被 `strategy_params` 覆盖、严格要求所有窗口为正时会拒绝不合格候选、全部窗口为正时可通过。

### 计划运行命令

```bash
cd '/mnt/e/量化平台_V1.4.0'
PYTHONUNBUFFERED=1 python3 src/run_v2_backtest.py --config configs/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/formal/<variant>/<config>.json 2>&1 | tee results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/logs/formal/<variant>_<segment>.log
```

### 可见进度与日志

- 是否过程可见：formal 尚未启动；计划使用 `PYTHONUNBUFFERED=1 + tee`。
- 日志路径：`results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/logs/formal/`
- 查看进度命令：`tail -f results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/logs/formal/<variant>_<segment>.log`
- 异常判断：formal 未启动，不存在 5KZW traceback。
- 后台回测豁免：未后台运行。

### 资源阻塞记录

2026-06-06T19:40:00Z 复核 WSL 进程时，仍有无关 A23 回测：

```text
pid=90288 pcpu=345 pmem=18.8 elapsed=04:24
python3 src/run_backtest.py --config configs/research/R010-A23/state_tier_hot_budget/base75_blowoff92_m04_d09_cap65/r010a23_base75_blowoff92_m04_d09_cap65_tiered_v2_2020_2021.json
```

因此本轮不并发启动 5KZW formal，避免资源竞争污染日志或导致中断。

2026-06-07T06:41:10+08:00 资源恢复后启动 5KZW formal 顺序 runner；2026-06-07T09:29:27+08:00 全部 16/16 回测完成，日志均包含 `exit_status=0`，无 traceback。

### 结果路径

```text
results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/formal/
results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/logs/formal/
results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/summary/formal/
```

## 12. 实际观察

| 变体 | 完成 | final 不低于 baseline | MDD 不差于 baseline | 四段 final 合计差额 | 2025 强趋势 final 差额 | 交易数差额 | 判断 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `mconfirm_60_120_positive` | 4/4 | 1/4 | 3/4 | `-23066.55` | `-9467.62` | `-90` | 失败 |
| `mconfirm_60_120_score055` | 4/4 | 1/4 | 3/4 | `-25284.31` | `-9411.97` | `-108` | 失败 |
| `mconfirm_25_60_120_positive` | 4/4 | 1/4 | 3/4 | `-19484.67` | `-9467.62` | `-92` | 失败 |

分段观察：

- 2020_2021：三个确认变体均高于 baseline，说明“短期 Top1 叠加中期趋势确认”在部分震荡/急变阶段有正向边际。
- 2022_2023：三个确认变体均明显低于 baseline，收益少约 `27695.59` 到 `33066.55`。
- 2024：三个确认变体均低于 baseline，虽然 MDD 改善，但收益补偿不足。
- 2025_20260519：三个确认变体均低于 baseline，少约 `9411.97` 到 `9467.62`；最大回撤也略差于 baseline。

冲突日归因：

- 归因脚本输出 `conflict_by_segment.csv` 与 `conflict_days_top.csv`，用于解释“短期第一名通过/不通过多周期确认”导致的持仓差异。
- 2022_2023 是最主要反证段。`mconfirm_60_120_positive` 与 baseline 有 `106` 个持仓冲突日，冲突日平均权益差为 `-17901.58`，最差为 `-46134.80`。
- 多周期确认在若干关键日把组合切到 `511880.SH`，而 baseline 持有 `512200.SH`、`513310.SH`、`515120.SH` 或 `159985.SZ` 等强势标的。典型日包括 `2023-08-03`、`2023-04-07`、`2023-10-13`、`2023-07-05`。
- 2025_20260519 的冲突日较少，`mconfirm_60_120_positive` 只有 `18` 个持仓冲突日，但最差冲突日仍达到 `-11333.96`，例如 `2026-04-21` baseline 持有 `520500.SH`，确认变体持有 `511880.SH`。
- 这说明失败机制不是“多周期信号完全随机”，而是严格确认经常把组合推回防守资产，换来部分 MDD 改善，同时错过中后段强势 ETF。

## 13. 支持证据

- 平台配置根包含 `baseline_top1_hard5`、`mconfirm_60_120_positive`、`mconfirm_60_120_score055`、`mconfirm_25_60_120_positive` 四个变体。
- 每个变体对应 `2020_2021`、`2022_2023`、`2024`、`2025_20260519` 四段，共 16 个 JSON，formal 汇总显示 `completed_runs=16`、`missing_runs=[]`。
- `etf_dual_pool_topn_vol_scaled.py` 新增严格多周期确认参数且默认不启用，降低误伤既有策略的风险。
- `test_etf_dual_pool_topn_hold.py` 13 个测试通过，覆盖新增参数路径。
- 2020_2021 中三个确认变体相对 baseline final 均提升约 `19788.87` 到 `20267.05`，且 MDD 改善，说明机制不是完全无效。
- 三个确认变体在 `3/4` 分段 MDD 不差于 baseline，说明它们有一定风险收缩作用。
- 冲突日归因显示失败主要来自趋势确认未通过时持有 `511880.SH`，而 baseline 继续持有阶段性强势 ETF；这支持“严格确认更像风险收缩/现金化规则，而不是稳健收益增强规则”的解释。

## 14. 反对证据

- 三个确认变体均只有 `1/4` 分段 final 不低于 `baseline_top1_hard5`，未达到预注册的 `>=3/4` 门槛。
- 三个确认变体在 2022_2023、2024、2025_20260519 均低于 baseline；这不是单年偶然失败。
- 2025_20260519 是强趋势压力测试，三个确认变体 final 均比 baseline 少约 `0.94` 万，且 MDD 略差，没有做到“强趋势不明显错过”。
- 相比 A23 92/4/d09，三个确认变体四段 final 均明显偏弱，不能替代当前 score-cap soft budget 候选。
- 当前没有证据支持继续扩大 60/120 阈值或 `score055` 网格；若继续调阈值，容易变成后验参数搜索。
- 冲突日归因没有发现“少数异常日解释全部失败”的结构；2022_2023、2024 和 2025 都存在收益拖累，继续在本实验内调窗口会违反预注册边界。

## 15. 偏差诊断

实验前计划原本因为 WSL 中 A23 cap 邻近回测占用资源而暂缓，后来在资源恢复后按预注册顺序完成全部 formal。执行偏差只影响启动时间，不影响变体集合、分段集合和判断门槛。

## 16. 研究判断

建议状态：`reject_formal_candidate_gate_failed`

理由：本实验已经把方向 1 从想法推进到默认关闭实现、配置生成、单元测试、16/16 formal 和汇总判断。三个多周期确认候选都没有通过预注册门槛，因此不得 promote、不得修改默认 hard5/A23，也不得把旧库多周期质量线索当作当前有效结论。

## 17. 下一步

关闭 5KZW 作为直接替代候选，不继续扩大多周期确认阈值网格。

后续如果继续利用本实验线索，只允许换研究问题：

1. 把“通过中期趋势才买入”改为“高分强趋势允许小仓位或预算化参与”。
2. 对高分持仓增加利润保护、回撤退潮或拥挤退潮退出，而不是只在入场时一刀切。
3. 新开 A23 事件级归因和成本/换手约束版本，定位 2020 改善、2025 强趋势收益和成本劣化来源。
4. 若要继续多周期方向，必须新开消融/负控预注册，例如只 60 日、只 120 日、窗口错位 1-2 日；不得在本实验内追加新参数。
