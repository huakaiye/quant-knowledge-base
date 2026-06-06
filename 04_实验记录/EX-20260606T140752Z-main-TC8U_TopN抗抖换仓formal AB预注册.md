---
type: 实验记录
ex_id: EX-20260606T140752Z-main-TC8U
rd_id: RD-20260605T115651Z-main-EXE0
status: active
stage: preregistered_platform_config_ready
owner: main
created_at: 2026-06-06T14:07:52Z
updated_at: 2026-06-06T14:15:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 执行与换仓模块
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
  - scripts/research/generate_tc8u_topn_antishake_configs.py
result_paths:
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
summary_paths:
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary/summary.json
  - scripts/research/summarize_tc8u_topn_antishake.py
quality_gate: L1_preregistered_platform_config_ready_no_backtest_yet
subagent_call_ids:
  - SUB-20260606T140000Z-main-TOPN
subagent_exemption:
tags: [双池轮动, TopN抗抖, 执行模块, formal预注册]
---

# TopN抗抖换仓formal AB预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-EXE0_双池轮动执行与换仓模块|双池轮动执行与换仓模块]]
- 父方向：[[02_研究方向/RD-20260605T115651Z-main-DP00_双池轮动策略|双池轮动策略]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 上游路线预注册：[[04_实验记录/EX-20260606T134047Z-main-HPHZ_五方向接手证据映射与首轮路线预注册|五方向接手证据映射与首轮路线预注册]]
- Top4 反证：[[04_实验记录/EX-20260606T012550Z-main-LM3D_动量评分尺度与Top4排名权重预注册|动量评分尺度与 Top4 排名权重预注册]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：当前持仓如果仍在 Top3/Top5 且分数没有明显落后，继续持有是否能减少无意义换仓。  
我们原本预计：它应该主要降低交易次数和成本敏感性，而不是显著改变选股逻辑。  
实际看到：本卡还没有执行 formal 回测，只完成平台参数覆盖补丁、单元测试和配置生成脚本准备。  
这说明：TopN 抗抖可以进入干净 A/B，但不能和波动率缩放、绝对动量过滤或 Top4 多持仓混在一起。  
但还不能说明：TopN 抗抖已经有效，也不能说明它优于 A23 或 hard5。  
下一步要做：生成 5 组变体四段配置，先完成 dry-run，再用 WSL 可见日志跑 formal。

## 2. 研究背景

`EX-20260606T012550Z-main-LM3D` 已经否定 Top4 等权、Top4 `40/30/20/10` 和取消 hard5 上限进入默认逻辑。  
因此本实验不研究“多买几个 ETF”，只研究“仍主要 Top1，但当前持仓还在候选前列时是否延迟换仓”。

平台 `src/strategies/research/etf_dual_pool_topn_vol_scaled.py` 已有 `choose_targets_with_topn_hold`。本轮补了 `strategy_params.topn_hold` 参数覆盖能力，并通过 `src/tests/strategies/test_etf_dual_pool_topn_hold.py` 10 项测试。

## 3. 实验前假设

低分差、低名次抖动的切换日里，继续持有仍在 Top3/Top5 的旧持仓，可以降低换手和交易次数；如果真实趋势已经切换，Top1 领先会通过分数比例或急跌否决迫使换仓。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：TopN 变体的四段 final 不应明显低于同策略文件 `baseline_top1_hard5`。
- 交易行为：TopN 变体交易数应低于 baseline，日志中应出现 `topn_retained`。
- 风险表现：MDD 不应明显恶化；急跌否决触发日不应继续保留旧持仓。
- 分段表现：2025_20260519 强趋势段不能明显落后；2022_2023 不能因抗抖持有弱势旧标的而放大回撤。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| baseline_top1_hard5 | 同一策略文件、关闭 TopN，隔离策略文件差异 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/baseline_top1_hard5/` |
| top3_ratio070_veto | 当前持仓在 Top3 且分数 >= Top1 的 70% 时保留 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top3_ratio070_veto/` |
| top3_ratio085_veto | 更严格分数比例，检验是否只靠宽松滞后获益 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top3_ratio085_veto/` |
| top5_ratio070_veto | 更宽排名保留，检验 Top5 是否过度滞后 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top5_ratio070_veto/` |
| top3_ratio070_gap050_veto | Top3 + 比例 + 绝对分差上限，检验“新第一名必须明显强” | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top3_ratio070_gap050_veto/` |
| hard5/A23 | 外部参考，不作为本轮同文件直接基准 | `results/v2/research/R010-A23/state_tier_hot_budget/` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 交易减少来自策略文件差异或参数覆盖错误，而不是 TopN 抗抖。
- 收益改善来自更少交易成本，而不是持仓延续本身。
- TopN 只在 2025 强趋势段减少噪声，无法跨段稳定。
- `top5_ratio070` 可能隐藏真实趋势切换，表面少换仓但损失未来收益。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 两个以上分段 final 明显低于 baseline_top1_hard5。
- 交易数下降但 MDD 没改善且收益明显下降。
- 2025_20260519 强趋势段跟不上 baseline 或 A23 外部参考。
- 只有 `top5_ratio070` 有效而 `top3` 邻近参数失败，说明可能是偶然滞后。
- 后续成本加倍后优势消失；本卡未做成本扰动前不得 promote。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待检查 | formal 运行后查看 manifest 与平台 V2 数据输入 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待检查 | 沿用 V2 JoinQuant bridge 与原策略调仓流程，formal 后复核日志 |
| 股票池或 ETF 池不存在未来成分泄漏 | 待检查 | 使用既有动态池逻辑；后续需复核动态池不是结束日快照 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本策略不使用财务宏观估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 待检查 | 本实验为 formal A/B，但不修改生产默认 |

负控或错位检查：

- baseline_top1_hard5 关闭 TopN。
- `top3_ratio085_veto` 与 `top3_ratio070_gap050_veto` 做邻近收紧。
- 后续追加成本加倍和随机延迟换仓负控，完成前不升级结论。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 已预注册 | 5 个变体固定，不看结果后扩网格 |
| 样本内、验证集、样本外划分清楚 | 待检查 | 四段固定：2020_2021、2022_2023、2024、2025_20260519 |
| 邻近参数敏感性合理 | 待检查 | ratio 0.70/0.85、Top3/Top5、gap 0/0.50 |
| 成本、滑点或换手扰动已检查 | 未完成 | 本卡先做 base cost；成本扰动为后续硬门槛 |
| 已做消融或负控 | 部分预注册 | baseline 和邻近收紧已预注册；随机延迟待补 |
| 未只报告最优结果 | 待检查 | 汇总脚本输出全部变体 |

证据等级：`L1_preregistered_platform_config_ready_no_backtest_yet`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`

子代理豁免：

```text
不适用
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260606T140000Z-main-TOPN | Cicero | SUBTASK-20260606T140000Z-main-TOPN | gpt-5.3-codex-spark | 2026-06-06T14:00:00Z | 待子代理返回 | 无 | 无长回测 | 只读核对，不做最终判断 | 待返回 | 主控已独立发现参数覆盖缺口并补测试 | 用于后续执行清单核对 |

台账行：待补。

## 11. 执行记录

### 平台配置

```text
configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
```

### 运行命令

```bash
PYTHONPATH=src python3 scripts/research/generate_tc8u_topn_antishake_configs.py
PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/<variant>/tc8u_<variant>_<segment>.json
PYTHONPATH=src python3 scripts/research/summarize_tc8u_topn_antishake.py
```

### 可见进度与日志

- 是否过程可见：`待执行，正式回测必须使用 PYTHONUNBUFFERED=1 + tee`
- 日志路径：`results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/logs/`
- 查看进度命令：待执行时登记
- 异常判断：`exit_status=0`、`manifest.json`、`summary.json`、`trades.csv` 齐全
- 后台回测豁免：

```text
不适用，尚未执行后台回测。
```

### 结果路径

```text
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 未执行 | 未执行 | 未执行 | 未执行 | 预注册阶段 |

## 13. 支持证据

- 平台已有 `choose_targets_with_topn_hold`，本轮新增 `strategy_params.topn_hold` 覆盖能力。
- `python -m pytest src/tests/strategies/test_etf_dual_pool_topn_hold.py -q` 通过 10/10。

## 14. 反对证据

- 还没有 formal 回测结果。
- 还没有成本加倍、随机延迟和冷却期 live 实现负控。
- 本实验不能直接证明 A23 与 TopN 叠加有效。

## 15. 偏差诊断

待 formal 运行后填写。

## 16. 研究判断

建议状态：`observe`

理由：已具备 formal A/B 执行条件，但没有收益、回撤、交易数和成本扰动证据。

## 17. 下一步

生成 20 个 formal 配置，先 dry-run 校验，再按四段可见运行；完成后用汇总脚本判断是否需要追加成本扰动和冷却期实现。
