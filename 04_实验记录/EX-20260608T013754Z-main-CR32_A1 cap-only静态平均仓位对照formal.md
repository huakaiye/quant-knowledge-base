---
type: 实验记录
ex_id: EX-20260608T013754Z-main-CR32
rd_id: RD-20260605T115651Z-main-DEF0
status: completed
stage: formal_static_cap_negative_control_completed
owner: main
created_at: 2026-06-08T01:37:54Z
updated_at: 2026-06-08T04:10:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块
decision_ids:
  - DEC-20260608T040036Z-main-WAHD
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-B1/EX-20260608T013754Z-main-CR32/formal/
result_paths:
  - results/v2/research/R010-B1/EX-20260608T013754Z-main-CR32/formal/
summary_paths:
  - results/v2/research/R010-B1/EX-20260608T013754Z-main-CR32/summary/formal/summary.json
  - results/v2/research/R010-B1/EX-20260608T013754Z-main-CR32/summary/formal/segment_compare.csv
  - results/v2/research/R010-B1/EX-20260608T013754Z-main-CR32/summary/formal/exposure_compare.csv
  - results/v2/research/R010-B1/EX-20260608T013754Z-main-CR32/summary/formal/quality_gates.json
quality_gate: formal_negative_control_failed_a1_trigger_alpha
subagent_call_ids:
  - SUB-20260608T014500Z-main-A1CAPA
  - SUB-20260608T014500Z-main-A1CAPB
subagent_exemption:
tags: [双池轮动, 防御模块, A1, 静态仓位, 负控, formal]
---

# A1 cap-only静态平均仓位对照formal

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|双池轮动防御模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 前置边界实验：[[04_实验记录/EX-20260608T012134Z-main-5YF3_A1A2动作链旧证据复核|A1A2 动作链旧证据复核]]
- 前置边界决策：[[05_研究决策/DEC-20260608T012134Z-main-T9JS_A1A2动作链复核后边界决策|A1A2 动作链复核后边界决策]]
- 本次决策：[[05_研究决策/DEC-20260608T040036Z-main-WAHD_A1静态仓位负控失败后暂停交易化决策|A1 静态仓位负控失败后暂停交易化决策]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：A1 cap-only 的回撤改善，到底来自“识别了正确风险日”，还是只是因为平均风险仓位更低。  
我们原本预计：如果 A1 触发本身有价值，A1 cap-only 应该优于同平均仓位的静态固定 cap；如果静态 cap 也能达到类似结果，A1 的风险识别解释就站不稳。  
实际看到：A1 cap-only 没有通过静态平均仓位负控。A1 四段复合收益为 `8.5238`，低于 `static_global_avg_cap` 的 `9.9971` 和 `static_segment_avg_cap` 的 `9.9528`；相对 global 静态 cap 只有 `1/4` 分段 final 胜出，相对 segment 静态 cap 只有 `2/4` 胜出，MDD 不差也只有 `2/4`。  
这说明：A1 cap-only 的回撤改善，主要可以被“长期平均风险仓位降低”解释，暂时不能说 A1 触发日识别出了更好的风险时点。  
但还不能说明：所有 A1 风险层都无用。A1 的日志字段仍可以作为诊断和触发重构素材，只是当前 cap-only 交易化假设被负控证伪。  
下一步要做：暂停 A1 cap-only 交易规则推进；如继续 A1，只能新开触发重构或滞后一日负控预注册。

## 2. 研究背景

前置 [[04_实验记录/EX-20260608T012134Z-main-5YF3_A1A2动作链旧证据复核|5YF3]] 显示：A1 cap-only 四段均改善最大回撤，但四段复合收益低于 B0，且 3/4 分段收益落后。这个结果有两种解释：

- A1 在正确的风险日把风险仓降到 90%，因此回撤改善；
- 策略只是长期平均风险仓位降到约 `0.9226`，风险下降不需要 A1 触发。

本实验做正式负控：用固定风险仓位控制组挑战 A1 cap-only。

## 3. 实验前假设

如果 A1 cap-only 具有独立风险识别价值，它应在四段中显著优于固定平均风险仓位控制组，而不只是获得类似的回撤改善。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：A1 cap-only 至少 3/4 分段 final 不低于 `static_global_avg_cap`，且 3/4 分段 final 不低于 `static_segment_avg_cap`。
- 交易行为：A1 cap-only 的交易数不应靠远高于静态 cap 的换手换来收益。
- 风险表现：A1 cap-only 至少 3/4 分段 MDD 不差于两个静态 cap 控制组。
- 分段表现：2025_20260519 强趋势不能明显弱于静态 cap；2024 不能成为唯一胜出分段。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| B0 | 原始 R010-B 分段基准 | `results/v2/research/R010-B/split_action_log/` |
| A1 cap-only | 旧 A1 只降风险仓位的动态触发版本 | `results/v2/research/R010-B1/a1_cap_only_split/` |
| static_global_avg_cap | 用 A1 cap-only 全样本平均风险权重 `0.922636` 固定缩放风险仓 | `configs/research/R010-B1/EX-20260608T013754Z-main-CR32/formal/static_global_avg_cap/` |
| static_segment_avg_cap | 用 A1 cap-only 各分段平均风险权重固定缩放风险仓，强负控但含分段后验 | `configs/research/R010-B1/EX-20260608T013754Z-main-CR32/formal/static_segment_avg_cap/` |

固定 cap 控制组都使用原始 Top1 风险目标；未用风险仓位转入 `511880.XSHG`，与 A1 cap-only 的 `use_defensive_for_unused_cash=true` 对齐。

## 6. 竞争性解释

即使 A1 cap-only 胜出，也可能是：

- 静态 cap 控制组的固定仓位口径不完全等同于 A1 实际日内目标权重；
- `511880` 防御 ETF 的收益贡献掩盖了风险识别；
- A1 的交易节奏与静态 cap 交易节奏不同，收益来自换手路径而非风险识别；
- `static_segment_avg_cap` 使用分段均值，包含后验信息，只能作为强负控，不是可部署方案。

## 7. 证伪条件

出现以下情况，本假设不通过：

- A1 cap-only 相对 `static_global_avg_cap` 或 `static_segment_avg_cap` 少于 3/4 分段 final 不低。
- A1 cap-only 相对任一静态控制组少于 3/4 分段 MDD 不差。
- 静态控制组复合收益和回撤接近或优于 A1 cap-only，说明低仓位解释足够。
- 2025 强趋势中 A1 cap-only 明显弱于静态控制组。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预检查通过 | 静态控制组不新增外部信号，只复用原始 Top1 和固定 cap。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 8 个静态 cap formal run 的 `R010-B ACTION` 日志均满足 `signal_date <= trade_date`；`signal_date > trade_date` 违规数为 `0`，最小滞后 `1` 天。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 预检查未新增风险 | 复用 R010-B1 策略池，不改 ETF 池。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 平台源码默认 `static_risk_cap_control_enabled=false`；R010-B1 下只有 CR32 8 个实验配置打开该键。 |

负控或错位检查：

- 本轮负控为同平均风险仓位静态 cap。若 A1 输给或接近静态 cap，应优先认为 A1 的风险识别不足。
- 滞后一日触发负控不在本轮运行，作为下一轮。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 仅两个控制组：global avg `0.922636`、segment avg `0.932144/0.919479/0.920372/0.914926`。 |
| 样本内、验证集、样本外划分清楚 | 部分通过 | 沿用四段：2020_2021、2022_2023、2024、2025_20260519。 |
| 邻近参数敏感性合理 | 不适用本轮 | 本轮不是调参，而是负控；不扫 `0.91/0.92/0.93`。 |
| 成本、滑点或换手扰动已检查 | 待后续 | 本轮沿用原成本口径，不做 cost2x。 |
| 已做消融或负控 | 通过 | 本轮本身是静态平均仓位负控。 |
| 未只报告最优结果 | 通过 | 两个静态 cap 控制组全部预注册。 |

证据等级：跑完 formal 后最多 `L2_formal_negative_control`，不支持直接 production promote。

## 10. 子代理调用记录

适配判断：适合调用。平台实现入口和既有结果口径可以并行核对，主控负责预注册、实现和最终判断。

调用状态：called

子代理豁免：不适用

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260608T014500Z-main-A1CAPA | Bohr | SUBTASK-20260608T014500Z-main-A1CAP实现路径核对 | inherited | 2026-06-08T01:45:00Z | `src/strategies/research/etf_dual_pool_r010b_action_ablation.py`、R010-B1 配置、B5 fixed cap 脚本 | 无 | 只读检索 | 只核对实现入口，不做路线判断 | 现有 `a1_risk_cap` 只在 A1 动作日生效，不能表达全样本静态 cap | 主控采纳其缺口判断并新增默认关闭静态 cap 控制 | 支持新建 CR32 平台脚本 |
| SUB-20260608T014500Z-main-A1CAPB | Heisenberg | SUBTASK-20260608T014500Z-main-A1CAP结果口径核对 | inherited | 2026-06-08T01:45:00Z | A1 cap-only summary、segment_compare、positions、XA5G fixed cap 结果 | 无 | 只读检索 | 只核对既有结果，不做最终判断 | 平均仓位为只读派生口径 | 主控复核并独立重算平均风险权重 | 确认缺少 A1 同平均仓位 static cap formal，支持新开 CR32 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
configs/research/R010-B1/EX-20260608T013754Z-main-CR32/formal/static_global_avg_cap/
configs/research/R010-B1/EX-20260608T013754Z-main-CR32/formal/static_segment_avg_cap/
```

### 运行命令

```bash
PYTHONPATH=src python3 scripts/research/generate_cr32_a1_static_cap_configs.py
PYTHONUNBUFFERED=1 bash scripts/research/run_cr32_a1_static_cap_control.sh
PYTHONPATH=src python3 scripts/research/summarize_cr32_a1_static_cap_control.py
```

### 可见进度与日志

- 是否过程可见：是，formal 脚本使用 `tee` 输出每个分段日志。
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-B1/EX-20260608T013754Z-main-CR32/logs/formal/`
- 查看进度命令：`tail -f results/v2/research/R010-B1/EX-20260608T013754Z-main-CR32/logs/formal/<log>.log`
- 异常判断：第一次 formal 启动被平台保护阻断；已有进程 `python3 src/run_v2_backtest.py --config configs/v2_migrate_80_small_cap.json`，PID `191968`，非 CR32 任务。未终止该进程，等待空闲后重试。
- 长跑说明：第一次正式运行在 `static_segment_avg_cap_2020_2021` 完成后被工具层 1 小时超时切断，导致该 tee 日志尾部没有 `exit_status=0`；结果目录、manifest 和 summary 完整。随后重跑同一脚本，已存在结果被跳过，其余 3 段完成。因此结果完整性为 `8/8`，日志 exit status 记录为 `7/8`。
- 后台回测豁免：不适用，计划前台可见运行。

### 结果路径

```text
results/v2/research/R010-B1/EX-20260608T013754Z-main-CR32/formal/
results/v2/research/R010-B1/EX-20260608T013754Z-main-CR32/summary/formal/
```

## 12. 实际观察

### 12.1 质量门禁

| 门禁 | 结果 |
| --- | --- |
| static_global_completed | true |
| static_segment_completed | true |
| A1 相对 static_global final 胜出分段 | `1/4` |
| A1 相对 static_segment final 胜出分段 | `2/4` |
| A1 相对 static_global MDD 不差分段 | `2/4` |
| A1 相对 static_segment MDD 不差分段 | `2/4` |
| a1_trigger_alpha_support | false |

### 12.2 四段对照

| 分段 | B0 final / MDD | A1 cap-only final / MDD | static_global final / MDD | static_segment final / MDD |
| --- | --- | --- | --- | --- |
| 2020_2021 | `229549.01` / `-21.12%` | `213757.82` / `-19.68%` | `206152.58` / `-19.39%` | `207373.30` / `-19.60%` |
| 2022_2023 | `130277.31` / `-30.91%` | `128605.13` / `-28.58%` | `134103.96` / `-26.66%` | `133973.46` / `-26.59%` |
| 2024 | `119958.38` / `-35.10%` | `121033.64` / `-32.20%` | `137877.30` / `-32.79%` | `137856.58` / `-32.72%` |
| 2025_20260519 | `311357.21` / `-19.42%` | `286235.22` / `-17.56%` | `288506.99` / `-18.01%` | `285974.77` / `-17.82%` |

四段复合收益：

- B0：`10.1695`
- A1 cap-only：`8.5238`
- static_global_avg_cap：`9.9971`
- static_segment_avg_cap：`9.9528`

### 12.3 仓位口径

| 分段 | A1 平均风险仓 | static_global 平均风险仓 | static_segment 平均风险仓 |
| --- | --- | --- | --- |
| 2020_2021 | `0.9321` | `0.9217` | `0.9310` |
| 2022_2023 | `0.9195` | `0.9223` | `0.9192` |
| 2024 | `0.9204` | `0.9216` | `0.9196` |
| 2025_20260519 | `0.9149` | `0.9182` | `0.9098` |

## 13. 支持证据

- A1 的收益胜出不足：相对 `static_global_avg_cap` 只有 2020_2021 分段 final 更高；相对 `static_segment_avg_cap` 只有 2020_2021 和 2025_20260519 分段 final 不低。
- A1 的回撤胜出不足：相对两个静态控制组都只有 `2/4` 分段 MDD 不差，低于预注册 `3/4` 门槛。
- 静态控制组复合收益更强：`static_global_avg_cap` 和 `static_segment_avg_cap` 的四段复合收益都明显高于 A1 cap-only。
- 2024 是关键反证：A1 cap-only 相对 B0 看起来收益和回撤都有改善，但 static cap final 达到约 `137.9k`，显著高于 A1 的 `121.0k`，MDD 只比 A1 略深。这说明 2024 的改善不能归因于 A1 触发日识别能力。
- 2025 强趋势没有被 A1 明显保住：`static_global_avg_cap` final `288506.99` 高于 A1 的 `286235.22`；A1 只在 MDD 上略浅。

## 14. 反对证据

- 2020_2021 中 A1 cap-only final 高于两个静态控制组，说明 A1 触发在个别阶段仍可能存在路径价值。
- 2025_20260519 中 A1 cap-only 与 `static_segment_avg_cap` final 接近，且 MDD 略浅；因此不能把所有 A1 风险层诊断字段直接删除。
- `static_segment_avg_cap` 使用分段平均风险仓，包含分段后验信息，只能作为强负控，不能作为可部署策略。
- 本轮不是 cost2x/slip2bps 重新撮合，也没有滞后一日触发负控；但由于 A1 已输给同平均仓位静态 cap，缺口不足以支持继续交易化。

## 15. 偏差诊断

- 低仓位解释更强：A1 cap-only 的平均风险仓长期约 `0.9226`，静态控制组不需要识别 A1 风险日，也能获得接近或更好的回撤/收益组合。
- 防御 ETF 权重存在执行路径差异：A1 的平均防御权重高于静态控制组，说明 A1 和 static cap 的未用风险仓补足路径并不完全等价；但这没有帮助 A1 在复合收益上胜出。
- 日志完整性小瑕疵：`static_segment_avg_cap_2020_2021` 的 tee 日志缺少最终 exit_status，原因是工具层超时切断父命令；结果产物完整并被 summary 纳入。
- 未来函数边界未发现新增风险：静态控制组只用预先固定 cap，不新增外部预测变量；8 个 run 的 `signal_date` 均早于 `trade_date`。

## 16. 研究判断

建议状态：`park_a1_cap_only_trade_alpha_keep_diagnostic`。

理由：A1 cap-only 未通过预注册静态平均仓位负控。当前证据不支持把 A1 触发作为防御交易规则、默认仓位规则或 production promote 候选；但 A1 风险字段仍可作为诊断标签，后续如果重启，必须换成新的触发结构并重新预注册。

## 17. 下一步

1. 新增并执行 [[05_研究决策/DEC-20260608T040036Z-main-WAHD_A1静态仓位负控失败后暂停交易化决策|WAHD 决策]]。
2. 防御模块下一步不再扩 A1 cap-only 仓位参数；如继续 A1，只允许新开“触发重构 formal”或“触发滞后一日负控”。
3. 继续保持 B3Gate/tiered-v2 为防御仓位骨架，A1 只作为诊断素材，不覆盖 hard5/A22 默认边界。
