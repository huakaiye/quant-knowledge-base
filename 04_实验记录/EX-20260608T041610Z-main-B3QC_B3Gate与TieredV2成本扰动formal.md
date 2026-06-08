---
type: 实验记录
ex_id: EX-20260608T041610Z-main-B3QC
rd_id: RD-20260605T115651Z-main-DEF0
status: completed
stage: formal_cost_gate_passed_need_lag_negative_control
owner: main
created_at: 2026-06-08T04:16:10Z
updated_at: 2026-06-08T07:25:59Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块
decision_ids:
  - DEC-20260608T072559Z-main-B3QC
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/cap80_cost2x_slip2bps/
  - configs/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/tiered_v2_cost2x_slip2bps/
result_paths:
  - results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/
summary_paths:
  - results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/summary.json
  - results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/quality_gates.json
  - results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/segment_compare.csv
  - results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/compound_compare.csv
  - results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/signal_date_audit.json
  - results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/signal_date_audit.csv
quality_gate: L3_formal_cost_gate_passed_not_promote
subagent_call_ids:
  - SUB-20260608T062000Z-main-B3QC-QA
subagent_exemption:
tags: [双池轮动, 防御模块, B3Gate, tiered-v2, 成本扰动, formal]
---

# B3Gate与TieredV2成本扰动formal

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|双池轮动防御模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 前置实验：[[04_实验记录/EX-20260608T005518Z-main-XK5W_B3Gate与TieredV2旧证据复核|B3Gate 与 TieredV2 旧证据复核]]
- 前置决策：[[05_研究决策/DEC-20260608T005556Z-main-U7FN_B3Gate与TieredV2复核后保留为防御骨架决策|B3Gate 与 TieredV2 保留为防御骨架决策]]
- 当前防御边界：[[05_研究决策/DEC-20260608T040036Z-main-WAHD_A1静态仓位负控失败后暂停交易化决策|A1 静态仓位负控失败后暂停交易化决策]]
- 本轮决策：[[05_研究决策/DEC-20260608T072559Z-main-B3QC_B3Gate与TieredV2成本扰动通过后继续负控决策|B3Gate 与 TieredV2 成本扰动通过后继续负控决策]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：B3Gate/tiered-v2 在旧证据里看起来比 cap80 骨架更好，但如果交易成本提高，它的优势会不会消失。

我们原本预计：如果 tiered-v2 的分层防御确实稳，它在 `commission_rate=0.0002` 且 `slippage_bps=2` 的成本扰动下，仍应整体优于 B3-gate-cap80。

实际看到：8 个 formal 成本扰动 run 全部完成。`tiered_v2_cost2x_slip2bps` 四段拼接收益 `12.1507`，高于 `cap80_cost2x_slip2bps` 的 `11.3111`；拼接最大回撤 `-28.22%`，好于 cap80 的 `-30.37%`。分段 final 与 MDD 均为 `3/4` 不差，2025_20260519 final 比 cap80 多 `12221.83`。

这说明：tiered-v2 的旧优势没有被成本加倍和 2bps 滑点扰动直接吞掉，可以继续作为防御骨架进入下一道质量门禁。

但还不能说明：这不是 production promote。2020_2021 的 MDD 仍略差于 cap80，2022_2023 的 final 仍低于 cap80；更重要的是还没有做触发滞后一日负控，不能证明收益来自及时识别风险状态。

下一步要做：新开触发滞后一日负控，检验 B3Gate/tiered-v2 是否依赖及时状态触发；在负控前不得扩 cap、阈值或默认交易开关。

## 2. 研究背景

[[04_实验记录/EX-20260608T005518Z-main-XK5W_B3Gate与TieredV2旧证据复核|XK5W]] 已把 B3Gate/tiered-v2 收口为防御仓位骨架：四段拼接收益高于 cap80，回撤也改善。但它仍缺完整成本扰动和错位负控。

本轮只处理成本扰动缺口，不调阈值、不扩 cap、不重新选择参数。若成本扰动证伪 tiered-v2，就不继续投入滞后负控；若通过，再新开触发滞后一日负控。

## 3. 实验前假设

B3Gate/tiered-v2 的优势不只是低成本假象；在成本加倍和 2bps 滑点扰动下，它仍能相对 B3-gate-cap80 保持更好的四段复合收益和不明显更差的回撤。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`tiered_v2_cost2x_slip2bps` 四段拼接收益仍高于 `cap80_cost2x_slip2bps`。
- 交易行为：成本扰动不应导致 tiered-v2 相对 cap80 的费用或换手劣势吞掉全部收益优势。
- 风险表现：tiered-v2 的拼接最大回撤不应明显差于 cap80；至少 `3/4` 分段 MDD 不差。
- 分段表现：2025_20260519 强趋势段不能明显弱于 cap80；2022_2023 若继续有收益机会成本，必须被记录为边界。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| B3-gate-cap80 base-cost | 旧骨架基准 | `results/v2/research/R010-B4/tiered_v2_split_summary/` |
| B3-gate-tiered-v2 base-cost | 旧复核对象 | `results/v2/research/R010-B4/tiered_v2_split_summary/` |
| cap80_cost2x_slip2bps | 本轮同成本基准 | `configs/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/cap80_cost2x_slip2bps/` |
| tiered_v2_cost2x_slip2bps | 本轮同成本测试对象 | `configs/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/tiered_v2_cost2x_slip2bps/` |

成本扰动口径：

- `commission_rate=0.0002`
- `min_commission=5`
- `r010b5_research_cost_override_enabled=true`
- `r010b5_research_fund_slippage_bps=2.0`
- `risk_config.execution.slippage_bps=2.0`

## 6. 竞争性解释

即使 tiered-v2 通过成本扰动，也可能是：

- 优势仍来自固定较低风险仓，而不是 B3/tiered 触发日识别。
- 2024 和 2025 的收益贡献掩盖 2020_2021 或 2022_2023 的机会成本。
- 成本扰动只覆盖基金手续费和滑点，不等价于真实实盘冲击成本。
- 触发日若错位一日仍有效，则应优先怀疑状态标签过宽或后验路径依赖。

## 7. 证伪条件

出现以下情况，本假设不通过：

- `tiered_v2_cost2x_slip2bps` 四段拼接收益不高于 `cap80_cost2x_slip2bps`。
- tiered-v2 相对 cap80 少于 `3/4` 分段 final 不低。
- tiered-v2 相对 cap80 少于 `3/4` 分段 MDD 不差。
- 2025_20260519 强趋势段 final 明显低于 cap80。
- 成本扰动后优势只剩 2024 单段，说明稳定性不足。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 本轮不新增信号，只复制既有 cap80/tiered-v2 配置并改成本参数。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | `signal_date_audit.json` 覆盖 8 个 run、3084 条 action，`violation_count=0`，`min_lag_days=1`，`max_lag_days=11`。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 未新增风险 | 沿用 R010-B4 既有 ETF 池和四段配置。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 本轮只生成 `EX-20260608T041610Z-main-B3QC` 研究配置，不改默认平台配置。 |

负控或错位检查：

- 本轮是成本扰动，不是错位负控。
- 成本门禁通过后，下一步必须新开触发滞后一日负控，不能直接 promote。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 只跑两个变体：cap80 和 tiered-v2 的 cost2x/slip2bps。 |
| 样本内、验证集、样本外划分清楚 | 部分通过 | 沿用四段：2020_2021、2022_2023、2024、2025_20260519。 |
| 邻近参数敏感性合理 | 不适用本轮 | 本轮不扩 cap60/cap70/cap50 或阈值。 |
| 成本、滑点或换手扰动已检查 | 通过 | 同成本扰动 8/8 formal 完成，summary gate `tiered_cost_gate_pass=true`。 |
| 已做消融或负控 | 部分通过 | cap80 是同成本对照；错位负控待后续。 |
| 未只报告最优结果 | 通过 | 四段和两个变体全部报告；`source_bucket` 均为 `formal`，未把 OOM recovery 尝试并入正式结果。 |

证据等级：`L3_formal_cost_gate`。不支持生产 promote。

## 10. 子代理调用记录

适配判断：适合调用。formal 完成后需要检查实验卡、台账字段和流程缺口，适合由子代理只读审计。

调用状态：called

子代理豁免：不适用。新开子代理受线程上限阻塞后，主控复用现有 `Bohr` 线程完成只读审计。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260608T062000Z-main-B3QC-QA | Bohr | SUBTASK-20260608T062000Z-B3QC-doc-ledger-audit | inherited | 2026-06-08T06:20:00Z | B3QC 实验卡、实验台账、formal 路径摘要 | 无 | 只读审计 | 只检查文档和台账缺口，不判断 promote | formal 后仍需主控补齐结果、decision_id、子代理记录和台账 | 主控核对平台 summary、segment、compound 和 date audit 后采纳流程建议 | 支持将 B3QC 收口为成本门禁通过并进入滞后负控 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
configs/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/cap80_cost2x_slip2bps/
configs/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/tiered_v2_cost2x_slip2bps/
```

### 运行命令

```bash
PYTHONPATH=src python3 scripts/research/generate_b3qc_tiered_cost_configs.py
PYTHONUNBUFFERED=1 bash scripts/research/run_b3qc_tiered_cost_formal.sh
PYTHONPATH=src python3 scripts/research/summarize_b3qc_tiered_cost_formal.py
PYTHONPATH=src python3 scripts/research/audit_b3qc_signal_dates.py
```

### 可见进度与日志

- 是否过程可见：是，formal 脚本使用 `tee` 输出每个分段日志。
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/logs/formal/`
- 结果路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/`
- 汇总路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/`
- 运行状态：8/8 formal 完成。

### 运行异常和处理

`tiered_v2_cost2x_slip2bps` 的 2025_20260519 首次 formal 曾因平台内存峰值触发 `exit_status=137`。失败日志已保留在：

```text
results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/logs/formal/b3qc_tiered_v2_cost2x_slip2bps_2025_20260519.failed_137_20260608T061627Z.log
```

排查定位到平台 `clickhouse_portal.py` 中 real price 恢复步骤一次性 Polars `with_columns` 导致峰值内存过高。平台侧已改为 field-by-field 恢复，且先处理 `high_limit/low_limit` 再处理 `pre_close` 以保留原始 `pre_close` 基准；随后该 run 完成，正式结果目录为：

```text
results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/tiered_v2_cost2x_slip2bps/2025_20260519/5b4edda7113c4894b28e18c35b7e0981
```

平台侧验证已完成：

```bash
python3 -m py_compile src/quant_v2/data/clickhouse_portal.py scripts/research/probe_b3qc_tiered_oom_stage.py
PYTHONPATH=src python3 -m pytest -q src/tests/quant_v2/test_price_rounding.py src/tests/quant_v2/test_dataset_portal.py src/tests/quant_v2/test_clickhouse_portal.py
```

测试结果：`84 passed in 99.02s`。

## 12. 实际观察

### 复合与拼接回撤

| 变体 | 四段拼接收益 | 四段拼接收益百分比 | 拼接 MDD |
| --- | ---: | ---: | ---: |
| base_cap80 | 13.5104 | 1351.04% | 未汇总 |
| base_tiered_v2 | 14.6834 | 1468.34% | 未汇总 |
| cap80_cost2x_slip2bps | 11.3111 | 1131.11% | -30.37% |
| tiered_v2_cost2x_slip2bps | 12.1507 | 1215.07% | -28.22% |

### 成本扰动分段

| 分段 | cap80 final | tiered-v2 final | tiered-v2 - cap80 | cap80 MDD | tiered-v2 MDD | 交易数 cap80/tiered |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2020_2021 | 212805.18 | 213091.47 | +286.29 | -21.20% | -21.69% | 558/559 |
| 2022_2023 | 125775.05 | 124873.95 | -901.10 | -28.81% | -28.22% | 444/450 |
| 2024 | 158239.17 | 163161.20 | +4922.03 | -30.37% | -27.48% | 270/279 |
| 2025_20260519 | 290673.46 | 302895.29 | +12221.83 | -17.00% | -16.99% | 461/464 |

质量门禁：

- `cost_runs_completed=true`
- `tiered_compound_gt_cap80_cost=true`
- `tiered_final_ge_cap80_segments=3`
- `tiered_mdd_not_worse_segments=3`
- `tiered_stitched_mdd_not_worse_cost=true`
- `tiered_cost_gate_pass=true`
- `decision_hint=continue_to_lag_negative_control`

## 13. 支持证据

- 成本扰动后 tiered-v2 四段拼接收益 `12.1507`，高于 cap80 `11.3111`。
- 成本扰动后 tiered-v2 拼接 MDD `-28.22%`，好于 cap80 `-30.37%`。
- tiered-v2 分段 final 有 `3/4` 不低于 cap80，满足预注册门槛。
- tiered-v2 分段 MDD 有 `3/4` 不差于 cap80，满足预注册门槛。
- 2025_20260519 强趋势段没有被明显错过，tiered-v2 final 比 cap80 多 `12221.83`。
- 分段费用没有吞掉优势：2025 tiered-v2 总费用 `14243.01`，高于 cap80 `13750.14`，但 final 仍显著更高。
- 未来函数日期审计通过：3084 条 action 无 signal/trade 日期逆序。

## 14. 反对证据

- 2020_2021 中 tiered-v2 MDD `-21.69%`，差于 cap80 `-21.20%`，说明不能写成“四段回撤都改善”。
- 2022_2023 中 tiered-v2 final `124873.95`，低于 cap80 `125775.05`，弱势和震荡段仍有机会成本。
- 2025_20260519 的 MDD 改善只有约 `0.004pp`，主要支持“不误伤强趋势”，不能证明强趋势段防御贡献大。
- 本轮只做成本扰动，不包含触发滞后一日负控；若滞后一天仍同样有效，B3/tiered 状态识别的及时性就会被削弱。

## 15. 偏差诊断

成本门禁支持 tiered-v2 继续保留，但其收益来源仍可能混有较低平均仓位、2024 特定压力段贡献和 B3Gate 触发窗口宽度。2022_2023 的收益落后提醒我们：它不是无成本防守，不能因为拼接收益更高就继续后验扩 cap50/cap40 或阈值网格。

平台侧 OOM 修复属于数据恢复流程内存优化，不改变 B3QC 策略逻辑。正式汇总的 `source_bucket` 均为 `formal`，未把 daycache/OOM recovery 尝试并入结果。

## 16. 研究判断

建议状态：`formal_cost_gate_passed_need_lag_negative_control`。

理由：B3Gate/tiered-v2 通过本轮成本扰动 formal，可继续作为防御仓位骨架；但证据等级只到 `L3_formal_cost_gate`，尚未通过触发滞后一日负控、实盘 dry-run 或生产前质量门禁。

## 17. 下一步

1. 新开触发滞后一日负控，检验 B3Gate/tiered-v2 是否真的依赖及时风险识别。
2. 不扩 B3/tiered-v2 的 cap、阈值、状态标签或旧 R026 组合动作。
3. 不改默认生产逻辑，不把旧 live enabled 或本轮 cost gate 写成当前 production promote。
4. 若滞后一日负控失败，B3Gate/tiered-v2 可继续进入下一道质量门禁；若滞后负控仍有效，优先怀疑状态标签过宽、路径依赖或过拟合。
