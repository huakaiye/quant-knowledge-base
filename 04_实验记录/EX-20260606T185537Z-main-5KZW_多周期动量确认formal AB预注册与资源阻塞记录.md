---
type: 实验记录
ex_id: EX-20260606T185537Z-main-5KZW
rd_id: RD-20260605T115651Z-main-CORE
status: active
stage: preregistered_configs_generated_formal_blocked_by_platform_resource
owner: main
created_at: 2026-06-06T18:55:37Z
updated_at: 2026-06-06T19:40:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 多周期动量确认
decision_ids: []
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
  - results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/summary/summary.json
quality_gate: L1_engineering_preregistered_configs_generated_no_backtest
subagent_call_ids:
  - SUB-20260606T192000Z-main-MULTI
subagent_exemption:
tags: [双池轮动, 多周期动量, 动量质量, 预注册, formal待执行, 资源阻塞]
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
实际看到：本轮只完成平台实现补丁、16 个四段 formal 配置生成和单元测试；formal 回测尚未启动，因为 WSL 内仍有无关 A23 回测占用较高 CPU/内存。  
这说明：方向 1 已经进入可执行的预注册状态，但没有收益、回撤或交易次数结论。  
但还不能说明：多周期确认有效，也不能说明它能替代 A23/hard5。  
下一步要做：等 WSL 回测资源空闲后，按本卡预注册的 4 个变体 × 4 个分段运行 formal，再和 `baseline_top1_hard5`、A23/hard5 对照。

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

证据等级：`L1_engineering_preregistered_configs_generated_no_backtest`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called_errored`

子代理豁免：无；已调用，但未产生可采纳输出。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260606T192000Z-main-MULTI | Turing | SUBTASK-20260606T192000Z-main-MULTI | gpt-5.3-codex-spark | 2026-06-06T19:20:00Z | 计划读取多周期动量相关旧库和平台资产 | 无 | 无 | 子代理上下文压缩超限，未产生可采纳输出 | 广范围证据映射任务过大，重复派发会浪费上下文 | 主控停止同类大盘点重试，改为本地检索和工程核对 | 只作为流程记录，不支持任何策略结论 |

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

### 结果路径

```text
results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/formal/       # planned
results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/logs/formal/  # planned
results/v2/research/R010-MULTI/EX-20260606T185537Z-main-5KZW/summary/      # planned
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| formal 回测 | 未运行 | 未运行 | 无 | 因 WSL 资源被无关 A23 回测占用，本轮只做预注册和工程准备。 |
| 配置覆盖 | 无 | 16/16 已生成 | 通过 | 四段 × 四变体均有 JSON 配置。 |
| 单元测试 | 既有测试 | 13/13 通过 | 通过 | 新增严格多周期确认默认关闭，未破坏 TopN hold 测试。 |
| 收益/回撤/交易次数 | 待跑 | 待跑 | 无 | 当前不能形成任何收益结论。 |

## 13. 支持证据

- 平台配置根已包含 `baseline_top1_hard5`、`mconfirm_60_120_positive`、`mconfirm_60_120_score055`、`mconfirm_25_60_120_positive` 四个变体。
- 每个变体对应 `2020_2021`、`2022_2023`、`2024`、`2025_20260519` 四段，共 16 个 JSON。
- `etf_dual_pool_topn_vol_scaled.py` 新增严格多周期确认参数且默认不启用，降低误伤既有策略的风险。
- `test_etf_dual_pool_topn_hold.py` 13 个测试通过，覆盖新增参数路径。

## 14. 反对证据

- 尚未运行 formal，不能证明收益、回撤或交易次数改善。
- 旧库 R20260521-006 的单段 2025 质量因子结果属于 `migrated_unverified`，且不是本轮严格确认设计。
- 当前没有成本扰动、错位窗口负控或消融检查。
- 如果 formal 结果显示确认变体只是长期防守或错过 2025 强趋势，本假设应直接降级。

## 15. 偏差诊断

实验前计划原本希望尽快完成四段 formal，但 WSL 中 A23 cap 邻近回测仍在运行且资源占用较高。为了避免并发污染，本轮把工作边界收窄为工程准备和预注册。这个偏差不影响实验假设，但会推迟收益判断。

## 16. 研究判断

建议状态：`observe_engineering_ready_formal_blocked`

理由：本实验已经把方向 1 从想法推进到可执行配置：参数默认关闭、配置全量生成、单元测试通过、证伪条件明确。但没有任何 formal 结果，因此不得 promote、不得修改默认 hard5/A23，也不得把旧库多周期结果当作当前结论。

## 17. 下一步

等 WSL 无关 A23 回测结束后，优先运行 5KZW 四段 formal，并按以下顺序汇总：

1. `baseline_top1_hard5`
2. `mconfirm_60_120_positive`
3. `mconfirm_60_120_score055`
4. `mconfirm_25_60_120_positive`

完成后必须输出四段 formal 表、与 baseline/A23 的 final/MDD/trades 对比、信号冲突日清单，以及错位窗口负控预注册。
