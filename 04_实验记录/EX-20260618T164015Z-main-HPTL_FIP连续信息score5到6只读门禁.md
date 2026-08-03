---
type: 实验记录
ex_id: EX-20260618T164015Z-main-HPTL
rd_id: RD-20260618T164000Z-main-FIPQ
status: completed
stage: readonly_completed_gate_failed_park
owner: main
created_at: 2026-06-18T16:40:15Z
updated_at: 2026-06-18T17:10:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动连续信息质量门禁
decision_ids: [DEC-20260618T165410Z-main-P8JQ]
lit_ids:
  - LIT-20260603T000000Z-mig-2014DAFROGINTHEPANB412A
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths: []
result_paths:
  - results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL/
summary_paths:
  - results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL/hptl_fip_gate_summary.json
quality_gate: failed_readonly_gate
subagent_call_ids: []
subagent_exemption: "当前多代理工具只有在用户显式要求子代理/委派/并行 agent 时才允许 spawn，本轮没有该授权；主控：main；时间：2026-06-18T16:40:15Z"
tags: [双池轮动, 核心轮动, 非R方, 低滞后, Frog-in-the-Pan, 连续信息, 只读门禁, park, 已证伪]
---

# FIP连续信息score5到6只读门禁

## 关联链接

- 研究方向：[[02_研究方向/RD-20260618T164000Z-main-FIPQ_双池轮动FIP连续信息低滞后门禁|双池轮动 FIP 连续信息低滞后门禁]]
- 父方向：[[02_研究方向/RD-20260605T115651Z-main-CORE_双池轮动核心轮动模块|双池轮动核心轮动模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[06_文献资料/08_已归档/LIT-20260603T000000Z-mig-2014DAFROGINTHEPANB412A_L20260521-011FroginthePanContinuousInformationandMomentum|Frog in the Pan: Continuous Information and Momentum]]；[[02_研究方向/RD-20260523T000000Z-mig-BLF20260523002F8A70_BLF20260523-002平滑上涨软排序|平滑上涨软排序旧库迁移方向]]
- 产生的决策：[[05_研究决策/DEC-20260618T165410Z-main-P8JQ_FIP连续信息门禁失败后park|FIP 连续信息门禁失败后 park]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：当 hard5 因 `score>=5` 拦下某个强势 ETF 时，只用 FIP 连续信息条件，能不能识别一部分值得保留的健康趋势。  
我们原本预计：如果 FIP 机制有效，FIP 放行的 `5<=score<6` 差异事件应在 H5/H10 上跑赢 hard5，且不是只靠单一年份。  
实际看到：全样本差异事件 `104` 个，H5/H10 差异均值为正，但 H10 胜率只有 `50.49%`，四个主分段中 H5 正分段只有 `1/4`，0bps 权益代理正分段只有 `2/4`，固定门禁失败。  
这说明：FIP 连续信息在近端和少数阶段有修补信息，但不具备跨阶段稳定性，不能进入组合级 formal。  
但还不能说明：FIP 在所有资产或所有频率都无效；本轮只证伪双池 ETF、日收盘代理、`5<=score<6` 放行这条路线。  
下一步要做：本方向 park，不扫 FIP 阈值、窗口、score 分段或 alpha；非 R 方低滞后研究继续等待 KFSQ 外部样本或新数据层。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260618T164000Z-main-FIPQ_双池轮动FIP连续信息低滞后门禁|FIPQ]]。上一批非 R 方路线中，残差动量、52 周高点、PLS/Ridge/fixed blend、强势阶段转移、分钟路径、H0/H1 和无交易带均已失败或受数据层阻塞。旧库保留了 Frog-in-the-Pan/平滑上涨线索，但迁移状态是 `migrated_unverified`，不能直接采纳。

这次只做一个窄门禁：复用平台现有 R010-A12 只读代理中的 `r092_fip_gate6`，检验 FIP 条件单独作用时，相对 hard5 是否有足够事件层和权益代理增量。它不验证综合 `lit_gate6`，也不把状态门控、52 周高点、成交量拥挤混入结论。

## 3. 实验前假设

FIP 连续信息条件可以在 `5<=score<6` 的候选中识别出一部分被 hard5 过度过滤的健康趋势，使其相对 hard5 的 H5/H10 差异收益为正，并在 0bps/10bps 权益代理下不弱于 hard5。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：差异事件数 `>=80`；H5/H10 差异均值均 `>=+0.10pct`；H5/H10 差异胜率均 `>=52%`。
- 交易行为：目标一致率 `>=90%`，说明只是低扰动修补 hard5，而不是重写全排序。
- 风险表现：10bps 成本代理相对 hard5 不转负。
- 分段表现：2020_2021、2022_2023、2024、2025 四个主分段中，至少 3 段 H5 事件均值为正；0bps 权益代理至少 3 段为正。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `hard5` | 当前基线，`0<score<5` | `analyze_r010a12_literature_hot_gate.py` 输出 |
| `hard6` | 无条件放宽，正控/风险对照 | `analyze_r010a12_literature_hot_gate.py` 输出 |
| `r092_state_gate6` | 区分是否只是市场状态门控贡献 | `analyze_r010a12_literature_hot_gate.py` 输出 |
| `r092_fip_gate6` | 本次主候选，只用 FIP 连续信息门禁 | `analyze_r010a12_literature_hot_gate.py` 输出 |
| `r092_lit_gate6` | 旧综合门控，仅作上下文，不作为 FIP 结论 | `analyze_r010a12_literature_hot_gate.py` 输出 |
| `hptl_fip_gate_summary.json` | 本次固定门禁汇总 | `results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL/` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- FIP 的收益来自市场状态或旧综合门控，而不是连续信息本身。
- 日收盘代理和全日成交量不是 13:09 实盘口径。
- ETF 层面的连续信息扩散机制弱于个股，少数年份有效不代表可迁移。
- `5<=score<6` 是旧 score-cap 研究形成的特定边界，不能外推到更高 score 或全排序。
- 旧库平滑上涨资料存在后验参数选择，不能作为本轮通过证据。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 差异事件数 `<80`。
- H5 或 H10 差异均值 `<+0.10pct`。
- H5 或 H10 差异胜率 `<52%`。
- 四个主分段中 H5 事件均值为正的段数 `<3/4`。
- 四个主分段中 0bps 权益代理为正的段数 `<3/4`。
- 0bps 或 10bps 权益代理相对 hard5 为负。
- 目标一致率 `<90%`，说明它不是低扰动修补。

若失败，方向 `park`，不继续扫 FIP 阈值、窗口、score 分段或 alpha。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过但代理受限 | FIP 主字段使用历史日线收盘序列构造；本轮不使用未来标签训练 |
| 信号生成和成交价格不存在同 bar 泄漏 | 受限 | 这是日收盘只读代理，不是 live-safe 13:09 回测；由于门禁失败，不进入正式 V2 |
| 股票池或 ETF 池不存在未来成分泄漏 | 通过但代理受限 | 代理脚本读取平台研究策略 `STATIC_ETF_POOL`，并构造动态池；实际日样本 `1564` |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 只用价格、成交量代理和已有候选池 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 本轮不改策略、不生成交易配置、不写 shadow/observe |

负控或错位检查：

- `hard6` 判断无条件放宽是否更强。
- `r092_state_gate6` 判断是否只是市场状态门控。
- `r092_lit_gate6` 判断综合门控是否优于单独 FIP。
- 10bps 成本代理检查换手成本敏感性。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 只使用平台已有 `r092_fip_gate6`：`r2>=0.78`、`up_share20>=0.55`、`max_abs_ret20<=0.080`、`jump_ratio20<=0.75`、`ret5<=0.12`；未调阈值 |
| 样本内、验证集、样本外划分清楚 | 通过 | 固定主分段：2020_2021、2022_2023、2024、2025；2026 仅作补充观察 |
| 邻近参数敏感性合理 | 不做 | 本轮只读门禁失败则不扫邻近参数；通过后另开 formal 才考虑敏感性 |
| 成本、滑点或换手扰动已检查 | 通过但代理层 | 使用 0bps/2bps/10bps 代理成本；10bps 相对 hard5 仍为正，但分段失败 |
| 已做消融或负控 | 通过但代理层 | hard6、state_gate6、lit_gate6 为机制对照；FIP 弱于 state_gate6 和 lit_gate6 的权益代理 |
| 未只报告最优结果 | 通过 | 报告所有模式、所有成本和分段；HPTL summary 固定 gate |

证据等级：`L1/L2_readonly_gate_failed`。只读门禁失败，不支持组合级 formal、实盘、shadow、observe 或默认策略修改。

## 10. 子代理调用记录

适配判断：`适合调用，但系统规则禁止未授权 spawn`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具只有在用户显式要求子代理/委派/并行 agent 时才允许 spawn，本轮没有该授权；主控：main；时间：2026-06-18T16:40:15Z。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T164015Z-main-HPTL | 无 | SUBTASK-FIP-CONTINUITY-GATE-EXEMPT | 无 | 2026-06-18T16:40:15Z | 研究库入口与方法论；FIP 文献卡；R010-A12 旧库记录；平台代理脚本；HPTL summary/CSV | 本实验记录；FIPQ 方向；HPTL 汇总脚本；研究只读池解析兼容修复；P8JQ 决策；台账已同步 | `analyze_r010a12_literature_hot_gate.py`; `summarize_hptl_fip_continuity_gate.py` | 只读门禁，不判断交易化 | 旧库迁移线索、日收盘代理偏差、分段不稳 | 主控已复核 summary、checks、事件和分段 CSV | 支持 park FIPQ，不支持 formal |

台账行：`01_台账/子代理调用台账.csv` 已登记。

## 11. 执行记录

### 平台配置

```text
无交易配置；只读代理脚本：
scripts/research/analyze_r010a12_literature_hot_gate.py
scripts/research/summarize_hptl_fip_continuity_gate.py
```

执行中发现旧代理脚本默认读取本机 MiniQMT 实盘脚本，且池解析函数只识别 `STATIC_POOL`。本轮未使用实盘路径，已将 `scripts/research/analyze_r010a11_score_cap_readonly.py` 的 `_load_static_pool` 做向后兼容：优先识别 `STATIC_POOL`，没有时识别平台研究策略里的 `STATIC_ETF_POOL`。这是只读工具兼容修复，不改变策略默认逻辑。

### 运行命令

```bash
cd /mnt/e/量化平台_V1.4.0
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_r010a12_literature_hot_gate.py --start 2020-01-01 --end 2026-06-18 --live-script src/strategies/research/etf_dual_pool_r010b_action_ablation.py --output-dir results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL --modes hard5,hard6,r092_state_gate6,r092_fip_gate6,r092_lit_gate6 --cost-bps 0,2,10 2>&1 | tee results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL/run_hptl_proxy.log
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/summarize_hptl_fip_continuity_gate.py --output-dir results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL 2>&1 | tee results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL/run_hptl_summary.log
```

### 可见进度与日志

- 是否过程可见：是，使用 `PYTHONUNBUFFERED=1` 和 `tee`。
- 日志路径：`results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL/run_hptl_proxy.log`；`results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL/run_hptl_summary.log`
- 查看进度命令：`wsl -- tail -f /mnt/e/量化平台_V1.4.0/results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL/run_hptl_proxy.log`
- 异常判断：退出码非 0、Traceback、输出 CSV 缺失或 summary JSON 不可解析。
- 后台回测豁免：不适用。

### 结果路径

```text
results/v2/research/RD-20260618T164000Z-main-FIPQ/EX-20260618T164015Z-main-HPTL/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 固定门禁 | 必须全部通过 | `gate_pass=false` | 失败 | H10 胜率、H5 正分段和权益正分段未过 |
| 差异事件数 | `>=80` | `104` | 通过 | 样本数足够，不是样本太小导致失败 |
| H5 差异均值 | `>=+0.10pct` | `+1.0084pct` | 通过 | 全样本均值有正边际 |
| H10 差异均值 | `>=+0.10pct` | `+1.1308pct` | 通过 | 均值为正，但胜率不足 |
| H5 胜率 | `>=52%` | `55.77%` | 通过 | 中短期有一定修补信息 |
| H10 胜率 | `>=52%` | `50.49%` | 失败 | 延长到 H10 后稳定性不足 |
| H5 正分段 | `>=3/4` | `1/4` | 失败 | 2020_2021、2022_2023、2024 的 H5 均值为负 |
| 0bps 权益正分段 | `>=3/4` | `2/4` | 失败 | 2020_2021 与 2024 权益代理相对 hard5 为负 |
| 0bps 相对 hard5 | `>=0` | `+8.9901%` | 通过 | 全样本权益代理为正 |
| 10bps 相对 hard5 | `>=0` | `+10.0860%` | 通过 | 成本代理不抹掉全样本优势 |
| 目标一致率 | `>=90%` | `93.35%` | 通过 | 它确实是低扰动修补，不是重写排序 |

分段反证：

| 分段 | 差异事件 | H5 差异均值 | H10 差异均值 | 0bps 权益相对 hard5 | 判断 |
| --- | ---: | ---: | ---: | ---: | --- |
| 2020_2021 | 26 | `-0.5879pct` | `+0.1875pct` | `-8.1397%` | 不稳定，权益负 |
| 2022_2023 | 10 | `-0.2349pct` | `-0.0597pct` | `+1.2015%` | 事件层负 |
| 2024 | 9 | `-0.3558pct` | `-2.0212pct` | `-0.7111%` | 事件层和权益均负 |
| 2025 | 53 | `+1.6573pct` | `+2.0572pct` | `+11.0242%` | 正贡献主要来源 |
| 2026_to_0604 标签段 | 6 | `+6.3120pct` | `+4.2722pct` | `+6.3539%` | 近端补充观察，样本小 |

## 13. 支持证据

- FIP 差异事件数量为 `104`，超过预注册 `80` 门槛。
- 全样本 H5/H10 差异均值分别为 `+1.0084pct` 和 `+1.1308pct`。
- 0bps/10bps 权益代理相对 hard5 分别为 `+8.9901%` 和 `+10.0860%`。
- 目标一致率 `93.35%`，说明它是低扰动修补。

## 14. 反对证据

- H10 差异胜率只有 `50.49%`，低于预注册 `52%`。
- H5 正分段只有 `1/4`，远低于 `3/4` 门槛。
- 0bps 权益正分段只有 `2/4`，低于 `3/4` 门槛。
- 2020_2021 权益代理相对 hard5 为 `-8.1397%`，2024 为 `-0.7111%`；这两个关键段不能支撑跨阶段稳定性。
- `r092_state_gate6` 的 0bps 相对 hard5 为 `+28.9669%`，显著高于 FIP 的 `+8.9901%`；综合 `r092_lit_gate6` 也高于 FIP，说明 FIP 不是当前代理里最强的独立机制。

## 15. 偏差诊断

实验前预测里最重要的一点是跨阶段稳定。实际看到的是全样本均值为正，但正贡献集中在 2025 和近端 2026 小样本，2020_2021、2022_2023、2024 的 H5 事件均值均为负。

最可能的解释是：FIP 连续信息能识别“健康强趋势”的一部分样本，但在 ETF 双池里它对市场阶段高度敏感。2025 这类强趋势阶段放行有帮助；2020_2021 和 2024 这类过热、跳变或压力段中，连续信息并不能替代 hard5 的过热保护。

这与旧库判断一致：平滑上涨可能有信息量，但必须状态化，不能单独作为常开门禁。本轮正好证实了“单独 FIP 门禁不够”。

## 16. 研究判断

建议状态：`park`

理由：

- 固定只读门禁 `gate_pass=false`。
- 失败不是样本不足，而是跨阶段不稳：H5 正分段 `1/4`、权益正分段 `2/4`。
- FIP 全样本均值为正，但不满足进入组合级 smoke/formal 的稳定性条件。
- 不允许在结果后继续扫 `up_share20`、`jump_ratio20`、`max_abs_ret20`、`ret5` 或 score 分段，否则会变成后验调参。

本实验不能说明 FIP 理论无效；只能说明当前双池 ETF、日收盘代理、`5<=score<6` 放行口径下，FIP 不足以成为超越或接近 R 方硬过滤的路线。

## 17. 下一步

本方向不继续 formal，不改实盘，不 shadow，不 observe。后续非 R 方低滞后研究只保留两类路径：

1. 等待 KFSQ `confirmed_state_run_len` 的外部 H10 样本或真实观察流。
2. 等待真实盘口、逐笔、订单簿、成交滑点或 dry-run 数据后，重新开独立数据层方向。

不要继续在 FIP 阈值、窗口、score 分段、状态门槛或综合 lit_gate 权重上扩网格。
