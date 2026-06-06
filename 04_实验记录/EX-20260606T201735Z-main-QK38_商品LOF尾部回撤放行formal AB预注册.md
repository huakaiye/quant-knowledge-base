---
type: 实验记录
ex_id: EX-20260606T201735Z-main-QK38
rd_id: RD-20260605T133318Z-main-H6V3
status: active
stage: preregistered_configs_generated_tests_passed_formal_pending
owner: main
created_at: 2026-06-06T20:17:35Z
updated_at: 2026-06-06T20:35:00Z
strategy_id: R010-A24
module_type: 资产属性分层 / score过热放行
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/hard5_ctail_allow/
  - configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/a23_ctail_allow/
result_paths:
  - results/v2/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/
summary_paths: []
quality_gate: preregistered_default_off_implementation_tests_20of20_formal_pending
subagent_call_ids:
  - SUB-20260607T041000Z-main-CTAIL
subagent_exemption:
tags: [双池轮动, 商品LOF, hard5, A23, 资产状态交互, formal预注册]
---

# 商品LOF尾部回撤放行formal AB预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动score过热拥挤机制模块]]
- 上游只读证据：[[04_实验记录/EX-20260606T200545Z-main-GCHV_资产状态交互只读负控复核|GCHV 资产状态交互只读负控复核]]
- 上游资产标签：[[04_实验记录/EX-20260606T140753Z-main-WXMD_资产属性分层扩展诊断与负控|WXMD 资产属性分层扩展诊断与负控]]
- 上游状态面板：[[04_实验记录/EX-20260606T183604Z-main-7YDQ_动量崩盘状态只读归因与错位负控|7YDQ 目标ETF状态反证]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：商品 LOF 在强趋势中出现 20/60 日尾部回撤时，是否不该被 `score >= 5` 或 A23 的条件化高分过滤直接挡掉。  
我们原本预计：如果 GCHV 的只读线索是真实的交易机会，hard5 放行分支在 2025_20260519 应该明显改善，A23 分支至少不能变差；历史两段不能靠牺牲 2020_2023 换近端收益。  
实际看到：目前只完成默认关闭实现、8 个 formal 配置生成和单元测试，尚未运行四段 formal。  
这说明：候选已经从观察信号变成可回测的正式 A/B，但还没有任何收益结论。  
但还不能说明：商品 LOF 尾部回撤一定有效，也不能说明可以改默认 hard5、A23 或实盘规则。  
下一步要做：等 WSL 回测资源空闲后，按预注册顺序跑 hard5 放行和 A23 放行四段 formal，并做触发日归因。

## 2. 研究背景

本实验属于 `RD-20260605T133318Z-main-H6V3`。GCHV 在只读事件面板中发现，`commodity_tail_drawdown` 共有 24 个事件、覆盖 2025 和 2026_to_date 两段，H10 相对同资产非状态补集的 effect 为 `+0.1476`，分段内随机置换的 `random_abs_p_ge=0.066`，且 Top ETF 占比 `0.625`，没有超过 0.80 的集中度上限。

这个线索不同于“资产标签直接交易化”。WXMD 已反证资产标签本身不能直接作为交易信号；QK38 只测试一个很窄的交互：raw Top1 是商品 LOF，且当日 20 日回撤 <= -10% 或 60 日回撤 <= -15% 时，是否允许它通过高分过滤。

## 3. 实验前假设

商品 LOF 在强趋势中的尾部回撤更像趋势修复，而不是普通过热；当 raw Top1 为预注册商品 LOF 且触发尾部回撤状态时，豁免高分过滤可能比 hard5 或当前 A23 更稳。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`hard5_ctail_allow` 在 2025_20260519 final 高于 hard5，且回撤不显著恶化；`a23_ctail_allow` 对 A23 至少不弱。
- 交易行为：新增换入主要集中在 `161226`、`161129`，少量来自 `160723`、`161116`；2024 应接近负控，因为 GCHV 中商品尾部回撤触发为 0。
- 风险表现：历史 2020_2021、2022_2023 不应因为商品放行产生新的深回撤。
- 分段表现：不能只有 2026_to_date 单段有效；2025 与 2026_to_date 的触发归因都要能解释。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| hard5 | 当前默认生产语义基线 | `configs/research/R010-A11/score_hot_backtest/r010a11_score_hot_hard5_tiered_v2_*.json` |
| A23 92/4/d09 | 当前 hard5 替代研究首选候选 | `configs/research/R010-A23/state_tier_hot_budget/base70_blowoff92_m04_d09_cap60/` |
| hard5_ctail_allow | 直接检验 GCHV 的 raw-vs-hard5 线索 | `configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/hard5_ctail_allow/` |
| a23_ctail_allow | 检验当前 A23 是否仍需要商品尾部回撤放行 | `configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/a23_ctail_allow/` |

固定参数：

- 商品代码：`161226`、`161129`、`160723`、`161116`。
- 尾部回撤：`dd20 <= -0.10` 或 `dd60 <= -0.15`。
- 最小 score：`5.0`。
- `hard5_ctail_allow` 只允许 `hard_cap/hard/cap` 模式放行。
- `a23_ctail_allow` 只允许 `conditional_hot_state/r010a17_conditional_hot_state/conditional_hard5` 模式放行。

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 2025_20260519 的贵金属/原油单一行情造成的样本偶然性。
- 静态代码表把“商品 LOF”定义成事后最优集合。
- 交易口径与 GCHV 的 close-to-close 事件归因口径不一致。
- 改善来自放宽 hard5，而不是尾部回撤本身。
- A23 的高分预算已经覆盖了主要收益，本实验只是重复表达。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 任一候选有两个以上分段 final 明显低于对应基准。
- 2025_20260519 没有改善，或明显错过商品强趋势。
- 任一历史分段 MDD 恶化超过 2 个百分点且 final 没有补偿。
- 触发样本少于 5 个交易日，无法解释为可交易机制。
- 改善集中在单一代码且集中度超过 0.80。
- `a23_ctail_allow` 对 A23 没有边际效果，且 `hard5_ctail_allow` 只是在重复 A23 已知机制。
- 成本扰动或错位状态负控后优势消失。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预审通过，formal 后复核 | 策略在当日评分阶段从已缓存日线和当前价复算 `dd20/dd60`，不读取 GCHV 前瞻收益。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待 formal 审计 | 与原 `score_hot_filter_passes` 同一入口；需在回测日志中确认成交时序与既有 hard5/A23 一致。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 待 formal 审计 | 沿用 A11/A23 模板池；新增静态代码表来自上游观察，需在总结中标注为研究参数。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本实验不使用财务、宏观或估值数据。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 新参数默认关闭；只有 QK38 formal 配置打开。 |

负控或错位检查：

- 2024 商品尾部回撤触发为 0，应接近负控。
- formal 完成后增加错位状态或成本扰动，不得直接 promote。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 固定 2 个分支、4 个代码、2 个回撤阈值，无网格扫描。 |
| 样本内、验证集、样本外划分清楚 | 部分通过 | GCHV 种子来自 2024-2026 近端事件；formal 必须看 2020_2021、2022_2023、2024、2025_20260519 四段。 |
| 邻近参数敏感性合理 | 待检查 | 本轮不做邻近阈值，避免继续调参；若通过，再新开敏感性实验。 |
| 成本、滑点或换手扰动已检查 | 待检查 | 当前仅生成 base-cost formal 配置。 |
| 已做消融或负控 | 部分通过 | 上游 GCHV 做了 500 次分段内随机状态置换；formal 后仍需错位状态负控。 |
| 未只报告最优结果 | 通过 | 同时预注册 hard5 与 A23 两个固定分支。 |

证据等级：`L1_engineered_preregistered`，formal 未运行前不得升级。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260607T041000Z-main-CTAIL | main | SUBTASK-20260607T041000Z-main-CTAIL-IMPLCHECK | gpt-5.5 | 2026-06-07T04:10:00+08:00 | `etf_dual_pool_topn_vol_scaled.py`; `analyze_r010a16_hot_state_panel.py`; `analyze_r010a18_asset_class_label_audit.py`; 配置生成器样式 | 无 | 无 | 只读实现可行性审计，不做策略有效性判断 | 指出运行时资产分类、交易口径和配置一致性风险；但误把主要实现入口指向 `topn_vol_scaled.py` | 采纳 A16 回撤定义、资产标注风险和默认关闭建议；主控改为在 A23 实际策略入口实现 | 支持 QK38 采用静态代码表和默认关闭实现，不支持任何 promote |

台账行：`SUB-20260607T041000Z-main-CTAIL` 已同步到 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/hard5_ctail_allow/qk38_hard5_ctail_allow_2020_2021.json
configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/hard5_ctail_allow/qk38_hard5_ctail_allow_2022_2023.json
configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/hard5_ctail_allow/qk38_hard5_ctail_allow_2024.json
configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/hard5_ctail_allow/qk38_hard5_ctail_allow_2025_20260519.json
configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/a23_ctail_allow/qk38_a23_ctail_allow_2020_2021.json
configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/a23_ctail_allow/qk38_a23_ctail_allow_2022_2023.json
configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/a23_ctail_allow/qk38_a23_ctail_allow_2024.json
configs/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/a23_ctail_allow/qk38_a23_ctail_allow_2025_20260519.json
```

### 运行命令

```powershell
python scripts/research/generate_qk38_commodity_tail_allow_configs.py
python -m pytest src/tests/strategies/test_etf_dual_pool_rank_weighting.py src/tests/strategies/test_etf_dual_pool_topn_hold.py -q
python -m py_compile scripts/research/generate_qk38_commodity_tail_allow_configs.py src/strategies/research/etf_dual_pool_r010b_action_ablation.py
```

formal 回测命令尚未运行。按平台规范，正式回测需要 WSL 可见执行：

```powershell
$platformWsl = powershell -ExecutionPolicy Bypass -File tools/Get-QuantPlatformRoot.ps1 -Format WSL
wsl -- bash -lc "cd '$platformWsl' && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config <config> | tee <log>"
```

### 可见进度与日志

- 是否过程可见：formal 尚未执行。
- 日志路径：formal 计划写入 `results/v2/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/logs/formal/`。
- 查看进度命令：formal 运行时另记。
- 异常判断：若 WSL 仍被无关 A23 回测占用，则继续记录资源阻塞，不静默后台运行。
- 后台回测豁免：

```text
未后台运行。
```

### 结果路径

```text
results/v2/research/R010-A24/commodity_tail_drawdown_allow/EX-20260606T201735Z-main-QK38/formal/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 策略默认行为 | hard5/A23 默认 | 新参数默认关闭 | 不改变 | 只有 QK38 formal 配置打开。 |
| 配置数量 | 无 | 8 个 | 新增 | 2 个分支 × 4 个分段。 |
| 单元测试 | 既有相关测试 16 个 | 20/20 通过 | 新增 4 个测试 | 覆盖默认关闭、商品放行、非商品拒绝、无尾部回撤拒绝。 |
| formal 回测 | 未执行 | 未执行 | 无收益结论 | 等 WSL 资源空闲后运行。 |

## 13. 支持证据

- 上游 GCHV：`commodity_tail_drawdown` 24 个事件，H10 同资产 effect `+0.1475816611`，`random_abs_p_ge=0.066`，Top ETF share `0.625`。
- 新实现默认关闭，降低误改默认 hard5/A23 的风险。
- 参数固定为 A16 原定义，不在 formal 前新增阈值网格。

## 14. 反对证据

- GCHV 是 close-to-close 事件归因，不是组合回测。
- 24 个事件主要集中在 `161226.SZ` 和 `161129.SZ`。
- 上游随机置换 p 值只是接近通过，不是强显著。
- 如果 A23 已经覆盖主要高分收益，`a23_ctail_allow` 可能没有任何边际贡献。

## 15. 偏差诊断

实验前预测要求正式回测后才能判断。当前偏差只来自实现核对：Hume 子代理把候选实现入口指向 `topn_vol_scaled.py`，但主控复核后确认 A23 正式配置使用 `etf_dual_pool_r010b_action_ablation.py`，因此实际补丁落在 A23/hard5 共用的 `score_hot_filter_passes`。

## 16. 研究判断

建议状态：`observe`

理由：QK38 已完成预注册、默认关闭工程实现、配置生成和测试，但没有 formal 回测结果。它只能作为 `GCHV -> formal A/B` 的执行候选，不能改默认逻辑。

## 17. 下一步

1. 检查 WSL 无关 A23 回测是否结束。
2. 按 hard5_ctail_allow、a23_ctail_allow 顺序跑四段 formal。
3. 汇总 final、MDD、trades、换仓事件和 `【商品尾部回撤放行】` 日志。
4. 若通过，再新开成本扰动和错位尾部回撤负控；若不通过，回写 GCHV 候选被 formal 证伪。
