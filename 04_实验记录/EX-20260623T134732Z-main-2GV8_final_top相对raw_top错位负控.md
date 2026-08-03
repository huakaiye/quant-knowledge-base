---
type: 实验记录
ex_id: EX-20260623T134732Z-main-2GV8
rd_id: RD-20260623T125116Z-main-DVXD
status: completed
stage: negative_control_failed
owner: main
created_at: 2026-06-23T13:47:32Z
updated_at: 2026-06-23T13:50:24Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 进攻与核心轮动扩展模块
decision_ids: [DEC-20260623T133954Z-main-67YJ, DEC-20260623T135036Z-main-PFMU]
lit_ids: []
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/analyze_2gv8_final_top_negative_controls.py
result_paths:
  - results/v2/research/RD-20260623T125116Z-main-DVXD/EX-20260623T134732Z-main-2GV8/
summary_paths:
  - results/v2/research/RD-20260623T125116Z-main-DVXD/EX-20260623T134732Z-main-2GV8/summary.json
quality_gate: negative_control_failed_lead_random_stronger
subagent_call_ids: []
subagent_exemption: 当前工具环境未提供可直接调用的子代理；主控：main；时间：2026-06-23T13:47:32Z
tags: [双池轮动, 行业轮动, ETF代理池, 过热降权, 错位负控]
---

# final_top相对raw_top错位负控

## 关联链接

- 研究方向：[[02_研究方向/RD-20260623T125116Z-main-DVXD_双池轮动行业状态机与个股增强模块|双池轮动行业状态机与个股增强模块]]
- 关键实验：[[04_实验记录/EX-20260623T133642Z-main-3GNZ_行业ETF代理池状态机未来收益验证|3GNZ 行业 ETF 代理池状态机未来收益验证]]
- 关键决策：[[05_研究决策/DEC-20260623T133954Z-main-67YJ_ETF代理池收益验证后保留过热降权单因子|67YJ 保留过热降权单因子]]
- 产生的决策：[[05_研究决策/DEC-20260623T135036Z-main-PFMU_ETF代理池final_top错位负控失败后暂停|ETF代理池final_top错位负控失败后暂停]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：3GNZ 中 `final_top` 的 T+10 均值优势，是否只是日期错位、少数差异日或随机替换造成的假象。  
我们原本预计：如果 `final_top` 真有增量，正确日期的差异日收益应好于错位版本，也应好于随机替换。  
实际看到：`final_top` 差异日 T+10 均值为 0.7314%，但 `final_top_lead1` 前移一天达到 1.3487%，且多个随机替换 seed 也为正。  
这说明：`final_top` 的优势没有通过基础错位和随机负控，不能进入交易化回测。  
但还不能说明：不能说明行业 ETF 代理池完全无价值，只能否定当前这组 `final_top` 过热降权信号的升级路线。  
下一步要做：暂停 ETF 代理池 `final_top` formal，回到数据补齐或更基础的行业定义问题。  

## 2. 研究背景

3GNZ 发现 `final_top` 的 T+10 均值高于 `raw_top`，但相对 `raw_top` 的同日差值胜率很低，说明多数日期两者选择相同 ETF，均值优势可能来自少数差异日。本实验只验证这个增量是否经得住基础负控。

本实验不运行回测、不计算成本、不生成策略配置。

## 3. 实验前假设

如果 `final_top` 的增量不是偶然，应满足：正确日期的 `final_top - raw_top` 差异日在 T+10 上优于 `final_top` 信号前移/后移 1 日，也优于固定 seed 的随机候选替换。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：差异日 `final_top - raw_top` 的 T+10 平均差值为正，且高于 `final_top_lag1`、`final_top_lead1`、随机替换。
- 交易行为：差异日样本不能过少；否则均值优势不可靠。
- 风险表现：正确日期的 p10 不应显著差于裸动量。
- 分段表现：至少 2 个以上分段方向一致，不能只靠单段。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `final_top` vs `raw_top` 差异日 | 检查真实增量来自哪些日期 | `diff_day_metrics.csv` |
| `final_top_lag1` | 检查滞后一天是否仍有效 | `negative_control_metrics.csv` |
| `final_top_lead1` | 检查前移一天是否异常有效，排查对齐问题 | `negative_control_metrics.csv` |
| `random_top_seed_*` | 检查随机替换是否也有类似表现 | `negative_control_metrics.csv` |

## 6. 竞争性解释

即使 `final_top` 看起来更好，也可能是：

- 少数差异日贡献了全部均值，样本不稳定。
- 前移/后移信号也表现好，说明不是当日信号有用，而是行业动量持续或日期对齐松散。
- 随机替换也能接近或超过，说明代理池本身强，不是过热降权有增量。
- 静态 ETF 代理池和重叠 ETF 导致集中度偏差。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 差异日样本太少，或差异日 T+10 均值不稳定。
- `final_top_lag1` 或 `final_top_lead1` 与正确日期相近甚至更好。
- 随机替换均值接近或超过 `final_top`。
- 正确日期的 p10 明显恶化，无法支持风控价值。
- 分段只有单段有效。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待检查 | 复用 MTPU/3GNZ 的 T 日信号与未来收益评估 |
| 信号生成和成交价格不存在同 bar 泄漏 | 部分适用 | 本实验不成交，只做未来收益诊断 |
| 股票池或 ETF 池不存在未来成分泄漏 | 待检查 | 仍使用静态 ETF 代理池，需保留偏差说明 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观、分析师或北向数据 |
| Shadow 或观察信号未被当成默认交易信号 | 已约束 | 本实验只读，不改默认策略 |

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 已固定 | 只做 lag1/lead1 和固定随机 seeds |
| 样本内、验证集、样本外划分清楚 | 待检查 | 输出四段统计 |
| 邻近参数敏感性合理 | 不适用 | 不调阈值 |
| 成本、滑点或换手扰动已检查 | 不适用 | 只读负控，不成交 |
| 已做消融或负控 | 已预注册 | 错位、差异日、随机替换 |
| 未只报告最优结果 | 待检查 | summary 必须列全部负控 |

证据等级：`L1_negative_control_failed`，只读负控完成且未通过。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前工具环境未提供可直接调用的子代理；主控：main；时间：2026-06-23T13:47:32Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：

```text
无；本轮未调用子代理，仅在正文记录豁免。
```

## 11. 执行记录

### 平台配置

```text
计划脚本：
${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_2gv8_final_top_negative_controls.py
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONPATH=src python3 -m py_compile scripts/research/analyze_2gv8_final_top_negative_controls.py scripts/research/test_2gv8_final_top_negative_controls.py
PYTHONPATH=src python3 -m pytest -q scripts/research/test_2gv8_final_top_negative_controls.py
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_2gv8_final_top_negative_controls.py
```

### 可见进度与日志

- 是否过程可见：是，脚本按 4 个阶段实时输出读取、负控事件、汇总和摘要
- 日志路径：未单独落日志；结果文件见下方路径
- 查看进度命令：不适用，脚本约 8 秒完成
- 异常判断：首次 pytest 因 `numpy.bool_ is False` 测试断言失败，修正测试为 `bool(...) is False` 后通过；脚本运行无异常
- 后台回测豁免：不适用，本实验不是回测

### 结果路径

```text
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260623T125116Z-main-DVXD/EX-20260623T134732Z-main-2GV8/

关键文件：
- `summary.json`
- `negative_control_report.md`
- `negative_control_events.csv`
- `negative_control_metrics.csv`
- `diff_day_metrics.csv`
- `segment_diff_day_metrics.csv`
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| `final_top` 差异日 T+10 均值 | 正确日期候选 | 0.007314 | 观察为正 | 差异日只有 271 天，胜率 49.25% |
| `final_top_lead1` 差异日 T+10 均值 | 前移一天负控 | 0.013487 | 明显更强 | 负控强于正确日期，提示对齐/持续性问题 |
| `final_top_lag1` 差异日 T+10 均值 | 滞后一天负控 | 0.003539 | 仍为正 | 说明信号附近持续性强，非精确当日增量 |
| 随机替换 seed | 随机负控 | 5 个 seed 均为正 | 未通过 | 随机替换也有正均值，代理池本身或样本结构贡献较大 |
| 分段差异日 | 至少多数分段方向一致 | 4 段均值为正但胜率不稳 | 不足以升级 | 2025-2026 胜率仅 44.44%，p10 较差 |

## 13. 支持证据

- 3GNZ 显示 `final_top` T+10 均值高于 `raw_top`。
- 3GNZ 同时显示差值胜率低，负控有必要。
- 2GV8 差异日显示 `final_top` 均值为正，说明现象不是完全不存在。

## 14. 反对证据

- 3GNZ 的收益优势可能来自少数差异日。
- 本实验仍然不是正式回测。
- `final_top_lead1` 强于正确日期，击穿“当日过热降权有独立增量”的解释。
- 多个随机替换 seed 也为正，说明代理池或行业持续性本身可能贡献收益。
- 正确日期差异日 T+10 胜率低于 50%，左尾也没有改善。

## 15. 偏差诊断

实验前假设未通过：正确日期没有强于 lead1，也没有明显强于随机替换。3GNZ 的均值优势更像是少数日期、行业持续性或代理池结构带来的观察现象，不能作为交易化回测候选。

## 16. 研究判断

建议状态：`park`

理由：`final_top` 未通过错位和随机负控，暂停 ETF 代理池过热降权 formal 路线；保留结果作为方法资产。

## 17. 下一步

暂停 ETF 代理池 `final_top` 路线。后续若继续行业研究，应优先补历史行业成分，或重新定义更干净的行业 ETF 池和基准后另开实验。
