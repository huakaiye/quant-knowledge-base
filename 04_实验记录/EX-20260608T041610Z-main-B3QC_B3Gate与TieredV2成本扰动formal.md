---
type: 实验记录
ex_id: EX-20260608T041610Z-main-B3QC
rd_id: RD-20260605T115651Z-main-DEF0
status: active
stage: preregistered_cost_formal_before_run
owner: main
created_at: 2026-06-08T04:16:10Z
updated_at: 2026-06-08T04:16:10Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/
result_paths:
  - results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/
summary_paths:
  - results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/
quality_gate: preregistered_before_formal_run
subagent_call_ids: []
subagent_exemption: 当前工具环境无法新增子代理线程，且现有子代理线程返回 No AppServerManager registered；主控 main 于 2026-06-08T04:15:00Z 只读推进。
tags: [双池轮动, 防御模块, B3Gate, tiered-v2, 成本扰动, formal]
---

# B3Gate与TieredV2成本扰动formal

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|双池轮动防御模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 前置实验：[[04_实验记录/EX-20260608T005518Z-main-XK5W_B3Gate与TieredV2旧证据复核|B3Gate 与 TieredV2 旧证据复核]]
- 前置决策：[[05_研究决策/DEC-20260608T005556Z-main-U7FN_B3Gate与TieredV2复核后保留为防御骨架决策|B3Gate 与 TieredV2 保留为防御骨架决策]]
- 当前防御边界：[[05_研究决策/DEC-20260608T040036Z-main-WAHD_A1静态仓位负控失败后暂停交易化决策|A1 静态仓位负控失败后暂停交易化决策]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：B3Gate/tiered-v2 在旧证据里看起来比 cap80 骨架更好，但如果交易成本提高，它的优势会不会消失。  
我们原本预计：如果 tiered-v2 的分层防御确实稳，它在 `commission_rate=0.0002` 且 `slippage_bps=2` 的成本扰动下，仍应整体优于 B3-gate-cap80。  
实际看到：待 formal 跑完后填写。  
这说明：待 formal 跑完后填写。  
但还不能说明：即使通过成本扰动，也还不能直接 production promote，因为还缺触发错位/滞后一日负控和实盘 dry-run。  
下一步要做：生成 8 个成本扰动配置，完成四段 formal，并汇总和 base-cost 结果的对照。

## 2. 研究背景

[[04_实验记录/EX-20260608T005518Z-main-XK5W_B3Gate与TieredV2旧证据复核|XK5W]] 已把 B3Gate/tiered-v2 收口为防御仓位骨架：四段拼接收益高于 cap80，回撤也改善。但它仍缺完整成本扰动和错位负控。

本轮只处理成本扰动缺口，不调阈值、不扩 cap、不重新选择参数。若成本扰动已经证伪 tiered-v2，就不继续投入滞后负控；若通过，再新开触发滞后一日负控。

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
| 数据时间戳只使用当时可得信息 | 预检查通过 | 本轮不新增信号，只复制既有 cap80/tiered-v2 配置并改成本参数。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待 formal 后检查 | formal 后检查 `R010-B ACTION` 日志中 `signal_date <= trade_date`。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 预检查未新增风险 | 沿用 R010-B4 既有 ETF 池和四段配置。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据。 |
| Shadow 或观察信号未被当成默认交易信号 | 预检查通过 | 本轮只生成 `EX-20260608T041610Z-main-B3QC` 研究配置，不改默认平台配置。 |

负控或错位检查：

- 本轮是成本扰动，不是错位负控。
- 如果通过，本方向下一步必须新开触发滞后一日负控，不能直接 promote。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 只跑两个变体：cap80 和 tiered-v2 的 cost2x/slip2bps。 |
| 样本内、验证集、样本外划分清楚 | 部分通过 | 沿用四段：2020_2021、2022_2023、2024、2025_20260519。 |
| 邻近参数敏感性合理 | 不适用本轮 | 本轮不扩 cap60/cap70/cap50 或阈值。 |
| 成本、滑点或换手扰动已检查 | 待 formal 后检查 | 本轮目标就是补成本扰动。 |
| 已做消融或负控 | 部分通过 | cap80 是同成本对照；错位负控待后续。 |
| 未只报告最优结果 | 通过 | 四段和两个变体全部报告。 |

证据等级：跑完 formal 后最多 `L3_formal_cost_gate`，不支持生产 promote。

## 10. 子代理调用记录

适配判断：适合调用，但当前工具环境不可用。

调用状态：exempt

子代理豁免：

```text
子代理豁免：当前工具环境无法新增子代理线程，且现有子代理线程返回 No AppServerManager registered；主控：main；时间：2026-06-08T04:15:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：待 formal 完成后同步豁免原因。

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
```

### 可见进度与日志

- 是否过程可见：是，formal 脚本计划用 `tee` 输出每个分段日志。
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/logs/formal/`
- 查看进度命令：`tail -f results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/logs/formal/<log>.log`
- 异常判断：待运行。
- 后台回测豁免：不适用，计划前台可见运行。

### 结果路径

```text
results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/formal/
results/v2/research/R010-B4/EX-20260608T041610Z-main-B3QC/summary/formal/
```

## 12. 实际观察

待 formal 完成后填写。

## 13. 支持证据

待 formal 完成后填写。

## 14. 反对证据

待 formal 完成后填写。

## 15. 偏差诊断

待 formal 完成后填写。

## 16. 研究判断

建议状态：待 formal 完成后填写。

理由：待 formal 完成后填写。

## 17. 下一步

1. 若成本扰动失败，更新 U7FN/DEF0 边界，把 tiered-v2 从骨架候选降级为历史观察。
2. 若成本扰动通过，新开触发滞后一日负控，检验 B3/tiered-v2 是否真的依赖及时风险识别。
