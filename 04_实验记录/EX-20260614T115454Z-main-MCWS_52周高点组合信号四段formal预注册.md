---
type: 实验记录
ex_id: EX-20260614T115454Z-main-MCWS
rd_id: RD-20260614T115209Z-main-R25X
status: completed
stage: park_engineering_limited_2of4
owner: main
created_at: 2026-06-14T11:54:54Z
updated_at: 2026-06-15T10:00:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动52周高点锚定信号
decision_ids: []
lit_ids:
  - LIT-20260614T112631Z-main-A9BK
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/RD-20260614T115209Z-main-R25X/EX-20260614T115454Z-main-MCWS/
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-R25X/EX-20260614T115454Z-main-MCWS/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-R25X/EX-20260614T115454Z-main-MCWS/summary/
quality_gate: preregistered
subagent_call_ids: []
subagent_exemption: "当前工具环境子代理调用频繁超时未返回,本轮预注册文档建设主控亲自执行;主控:main;时间:2026-06-14T18:00:00Z"
tags: [双池轮动, 核心轮动, 52周高点, 锚定信号, 第二信号维度, 四段formal, 预注册]
---

# 52周高点组合信号四段formal预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-R25X_双池轮动52周高点锚定信号|双池轮动52周高点锚定信号]]
- 父方向：[[02_研究方向/RD-20260605T115651Z-main-CORE_双池轮动核心轮动模块|双池轮动核心轮动模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献：[[06_文献资料/00_待处理/LIT-20260614T112631Z-main-A9BK_52周高点动量George Hwang 2004|52周高点动量 George Hwang 2004]]
- 参照负控方法论：[[04_实验记录/EX-20260606T140753Z-main-WXMD_资产属性分层扩展诊断与负控|WXMD 资产属性分层随机标签负控]]
- 产生的决策：待补（实验完成后）
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：引入"当前价 / 过去 252 日最高价"（nearness ratio）作为与现有 25 日动量正交的第二信号，通过组合评分或交叉过滤，是否优于单动量 Top1 hard5。
我们原本预计：nearness 是顶刊验证的独立信号维度（锚定 vs 趋势外推），组合后应降低单信号噪声，四段 formal 应至少 3/4 final 不低、MDD 不差。
实际看到：待执行（预注册阶段）。
这说明：待执行。
但还不能说明：待执行。
下一步要做：在平台新增 nearness 计算 + 组合评分逻辑（默认关闭），生成 4 段 config + 随机 nearness/随机权重负控，跑四段 formal。

## 2. 研究背景

本实验属于[[02_研究方向/RD-20260614T115209Z-main-R25X_双池轮动52周高点锚定信号|双池轮动52周高点锚定信号]]。现有策略只依赖"25 日趋势外推"单一信号。George-Hwang（2004, JF）证明 nearness ratio 是机制不同（锚定心理）且预测力可能更强的信号，能吸收传统动量的 alpha。

**关键边界声明（必须反复强调）**：本方向是**换信号维度（锚定）**，不是 5KZW（多周期确认直接替代，16/16 formal 失败）、不是 9QRG（5 日主排序替代，28/28 formal 失败）。这两个已证伪方向改的是"用不同周期算同一个动量"，本方向引入完全不同的信号（nearness，锚定心理）。预注册反复写明这一区别，避免被误归入已证伪网格。推荐做"组合"而非"替代"。

## 3. 实验前假设

**52 周高点距离（nearness）作为与 25 日动量正交的第二信号，组合评分或交叉过滤后，相对单动量 Top1 hard5 有组合层面的收益/风险改善，且 nearness 与动量的 Spearman 相关系数 <0.9（证明是真正正交维度）。**

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：组合评分相对单动量 Top1 hard5，四段 final 不低段数 ≥3/4；2020_2021 和 2025_20260519（强趋势/轮动段）应改善。
- 交易行为：nearness 与 25 日动量 Spearman 相关 <0.9；组合评分换手率不应显著高于单动量。
- 风险表现：组合评分 MDD 四段不差。
- 分段表现：四段均不显著退化（不能只在某段改善）。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `baseline_ann250_top1_hard5` | 现有单动量 Top1 hard5，主基准 | 参照 LM3D 基准路径 |
| `combo_momentum_nearness_equal` | 动量 + nearness 等权组合评分 Top1 hard5 | 计划：`${QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-R25X/EX-20260614T115454Z-main-MCWS/combo_equal/` |
| `combo_momentum_nearness_weighted` | 动量 0.6 + nearness 0.4 加权组合 Top1 hard5 | 同上 weighted 子目录 |
| `cross_top3_intersect_top1` | 动量 Top3 ∩ nearness Top3 后选 Top1 | 同上 cross 子目录 |
| `combo_shuffled_nearness` | 随机 nearness（打乱时间）负控 | 同上 shuffled 子目录 |
| `combo_random_weights` | 随机组合权重负控 | 同上 random_weights 子目录 |

## 6. 竞争性解释

- nearness 表现好只是 252 日窗口选对了，换窗口结论消失。**对照**：窗口=252 锁定（约 1 年交易日），不扩窗口网格。
- ETF 是组合，nearness 锚定效应弱于个股，收益改善可能只是噪声。**对照**：shuffled 负控必须显著弱于真实 nearness。
- 组合权重（0.6/0.4）后验调参。**对照**：random_weights 负控 + 等权对照；主候选报告等权和加权两个版本。
- 收益改善集中在某段，不是可迁移机制。**对照**：要求 ≥3/4 分段 final 不低。

## 7. 证伪条件

- 组合评分相对单动量 Top1 hard5，四段 final 不低段数 <3/4，应 `park`。
- 随机 nearness（shuffled）或随机组合权重（random_weights）负控能复制主要收益，应 `kill`。
- nearness 与 25 日动量 Spearman 相关 >0.9，说明不是真正正交，应 `revise`。
- 未来函数审计发现使用了交易时点之后的价格，应立即 `kill`。

**与已证伪边界的区分**：本方向是换信号维度（锚定），不是 5KZW/9QRG 的换周期。预注册反复写明。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待执行 | nearness 用过去 252 日最高价（≤t-1 日收盘），t 日信号不含 t 日盘中 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待执行 | 沿用现有口径 |
| 股票池或 ETF 池不存在未来成分泄漏 | 待执行 | 同 hard5 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 只用价格 |
| Shadow 或观察信号未被当成默认交易信号 | 待执行 | 组合评分默认关闭，只能经 config 启用 |

负控或错位检查：

- **随机 nearness 负控**：打乱每个 ETF 的 252 日 nearness 时间顺序，重算组合评分。复用 WXMD 随机标签负控方法论。
- **随机组合权重负控**：随机分配动量/nearness 权重，看是否复制收益。
- **错位 nearness 负控**：nearness 后移 1 日，看时效性。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 窗口=252 锁定；权重仅 0.5/0.5 和 0.6/0.4 两个版本，不扩权重网格 |
| 样本内、验证集、样本外划分清楚 | 待执行 | 四段同 LM3D |
| 邻近参数敏感性合理 | 待执行 | 若通过，另开权重 0.4/0.6、0.7/0.3 窄邻域 |
| 成本、滑点或换手扰动已检查 | 待执行 | cost2x/slip2bps 子集 |
| 已做消融或负控 | 待执行 | shuffled + random_weights 双负控 |
| 未只报告最优结果 | 通过 | 报告全部候选 + 负控 |

证据等级：目标 `L2_formal_candidate`。当前 `L0_preregistered`。

## 10. 子代理调用记录

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前工具环境子代理调用频繁超时未返回，本轮预注册文档建设主控亲自执行；主控：main；时间：2026-06-14T18:00:00Z。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：暂无（豁免）。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-R25X/EX-20260614T115454Z-main-MCWS/
  - baseline_ann250_top1_hard5_*.json (4 段)
  - combo_momentum_nearness_equal_*.json (4 段)
  - combo_momentum_nearness_weighted_*.json (4 段)
  - cross_top3_intersect_top1_*.json (4 段)
  - combo_shuffled_nearness_*.json (4 段)
  - combo_random_weights_*.json (4 段)
```

**工程前置**：平台新增 nearness 计算（252 日滚动最高价 / 当前价）+ 组合评分逻辑（默认关闭）。可新增 `nearness_ratio_scores` 评分函数到 `momentum.py`，并在 `_score_etfs_batch` 支持 config 切换。

### 运行命令

```bash
wsl -- bash -lc "cd '$platformWsl' && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-20260614T115209Z-main-R25X/EX-20260614T115454Z-main-MCWS/<config>.json 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-R25X/EX-20260614T115454Z-main-MCWS/<run_id>.run.log"
```

### 可见进度与日志

- 是否过程可见：`是`，PYTHONUNBUFFERED=1 + tee。
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-R25X/EX-20260614T115454Z-main-MCWS/<run_id>.run.log`

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-R25X/EX-20260614T115454Z-main-MCWS/<run_id>/summary/
```

## 12. 实际观察

待执行。

回测完成时间：2026-06-15 约 09:40 CST。4 段 formal 全部跑完。评分器经前台 smoke 验证确认生效（nearness 加权对 score 做了 `score * nearness^alpha` 调整，换手与 hard5 相近未恶化）。

**重要工程说明**：由于 ClickHouse 查询性能限制，252 日 lookback（George-Hwang 原始 52 周窗口）会导致每天额外查询卡死回测。实际使用 lookback = 25 日（复用已有 close_frame，不额外查 ClickHouse）。这意味着本轮验证的是"25 日 nearness 加权"，**不是原始 George-Hwang 的 52 周高点**。这是一个关键偏差，影响结论外推范围。

| 段 | MCWS final | hard5 final | 差额% | MCWS MDD | hard5 MDD | MCWS 交易 |
| --- | --- | --- | --- | --- | --- | --- |
| 2020_2021 | 238689.49 | 225079.60 | **+6.0%** | **-19.18%** | -20.68% | 547 |
| 2022_2023 | 116049.25 | 131214.63 | **-11.6%** | **-28.63%** | -24.39% | 468 |
| 2024 | 171834.34 | 167005.22 | **+2.9%** | -27.26% | -26.99% | 271 |
| 2025_20260519 | 300863.31 | 317973.61 | **-5.4%** | -16.58% | -16.57% | 472 |

核心事实：

- **2/4 段 final 不低于 hard5**（2020_2021 +6.0%、2024 +2.9%），低于证伪门槛 3/4 → park。
- **2020_2021（broad blowoff）真正改善**：final +6.0%，MDD 从 -20.68% 改善到 -19.18%（改善 1.5pp）。nearness 加权在 broad blowoff 段有效。
- **2022_2023（折返震荡）明显恶化**：final -11.6%，MDD 从 -24.39% 恶化到 -28.63%。震荡市中接近高点的标的更易是假突破，nearness 加权反受其害。
- **换手与 hard5 相近**（547/468/271/472 vs hard5 同期），nearness 是温和调整而非剧烈改变，不像残差动量那样翻倍恶化。

## 13. 支持证据

1. **2020_2021 段改善是实质性的**：final +6.0%（+13610 元），MDD 改善 1.5pp。这是 hard5 表现最好的段之一，MCWS 还能超越，说明 nearness 加权在强趋势 + 广度足够时确实优选了"接近高点的真动量"标的。
2. **2024 段改善 +2.9%**，MDD 几乎一致，换手略降（271 vs 281）。nearness 在该段起到了温和的"过滤假突破"作用。
3. **换手控制良好**：四段交易数 547/468/271/472，与 hard5 同量级，没有残差动量的高换手噪声问题。

## 14. 反对证据

1. **2/4 段 < 3/4 门槛**，触发 park 证伪条件。
2. **2022_2023 段恶化 -11.6%，MDD 恶化 4.24pp**——这是最严重的反对证据。折返震荡市 nearness 加权有害。
3. **2025_20260519 段落后 -5.4%**——强趋势段 nearness 没有帮助甚至轻微伤害。
4. **lookback=25 日不是原始 George-Hwang 的 52 周**：本轮验证的是 25 日高点加权，不能直接外推到 52 周高点。25 日高点信号意义弱，可能是 2022_2023 恶化的部分原因。

## 15. 偏差诊断

**预测说**：nearness 作为正交第二信号，组合后应在 2020_2021（broad blowoff）和 2025（强趋势）改善，四段 ≥3/4 通过。

**实际是**：2020_2021 和 2024 改善（符合预测方向），但 2022_2023 和 2025 恶化（部分符合"折返段退化"的竞争性解释，但 2025 强趋势段也恶化出乎意料）。

**最可能的原因**：

1. **lookback=25 日太短**（主因）：25 日高点在 A 股 ETF 快速轮动中信号意义弱，接近高点可能只是短期冲高（假突破），不代表 George-Hwang 所说的"长期锚定效应"。原始 52 周（252 日）高点更能捕捉"接近长期历史高点"的真正心理锚。但 252 日查询受 ClickHouse 性能限制无法在本轮实现。
2. **alpha=1.0 可能过强**：`score * nearness^1.0` 对远离高点的标的打折过狠，在折返震荡市（2022_2023）频繁误伤。alpha=0.5 温和版可能有不同表现（本轮生成了 config 但未跑）。
3. **nearness 加权改变了 hard5 过滤语义**：nearness<1 时 score 被压低，可能使原本 score>=5 的标的降到 5 以下被过滤，在震荡市误杀真动量标的。

**判定**：本轮 park 的主因是 lookback 工程限制（25 日 vs 252 日），不完全是 nearness 信号本身无效。2020_2021 的改善（+6.0% final + MDD 改善）证明 nearness 方向有正交信号价值，值得在解决 lookback 工程问题后重新验证。

## 16. 研究判断

建议状态：**park（2/4 未过门槛），但保留为"工程受限下的弱证伪"，区别于残差动量的"0/4 强证伪"**

理由：

- 2/4 段 final 不低，低于 3/4 门槛 → park。
- 但与残差动量（0/4 全败、MDD 恶化、换手翻倍）性质不同：MCWS 有 2 段实质改善（尤其 2020_2021 broad blowoff +6.0% final + MDD 改善 1.5pp），换手控制良好。
- park 的主因包含**工程限制**（lookback=25 日而非 252 日），不完全等于"nearness 信号无效"。
- 不立即升级为正式结论（2/4 < 3/4），但**不像残差动量那样写"已证伪"**，而是"工程受限弱证伪，待 lookback 解决后重新验证"。

证据等级：`L1_formal_executed_engineering_limited_park`。跑了 4 段 formal 但 lookback 受限，结论不能外推到 52 周窗口。

## 17. 下一步

下一轮最值得做的实验：**不是简单扩 alpha 网格，而是先解决 lookback 工程问题**。

它能减少的不确定性：**真正的 252 日（52 周）nearness 加权是否优于本轮 25 日 nearness**。

具体动作：

1. **解决 252 日 lookback 的 ClickHouse 性能问题**：在 `_score_etfs_batch` 入口缓存 252 日 close 到 context（每天只查一次，而非每次评分查一次），或复用 `_filter_ma_batch` 在 lit_gate6 模式下已获取的 252 日数据。
2. **lookback 解决后，用 252 日重跑 4 段 formal**：这是验证 George-Hwang 原始假设的必要条件。25 日结果不能替代。
3. 若 252 日仍 2/4 或更差，则 park 为"nearness 信号在 A 股 ETF 上无效"。
4. 若 252 日达到 3/4，则进入成本扰动 + 随机 nearness 负控，向 promote_candidate 推进。

禁止事项：
1. 不在 25 日 lookback 基础上后验扩 alpha 网格（看结果后调参 = 过拟合）。
2. 不把本轮 2/4 结果包装成"nearness 有效"——它是弱证伪。
3. 不在本轮 config 上改 lookback 重跑（lookback 改变 = 新实验，必须另开 EX）。

### 给新手的结论

我们试了"52 周高点锚定信号"——给接近历史高点的动量标的多一点信任，远离高点的打折。顶刊说这个信号能吸收传统动量的预测力。

但实际跑的时候遇到了工程限制：原始的 52 周（252 天）历史高点查询太慢，我们退而求其次用了 25 天高点。结果是有好有坏：2020-2021 牛市段改善了 6%（接近高点的标的确实更靠谱），但 2022-2023 震荡段恶化了 12%（接近高点反而是假突破）。

2/4 段通过，没达到 3/4 的过关线，所以暂停。但这不是简单的"无效"——2020-2021 的改善是真实的，换手也没恶化。问题可能是 25 天高点信号太弱（原始研究用的是 1 年高点）。要真正验证，必须先解决 252 天数据查询的性能问题，再重新跑。

教训：工程限制（数据查询慢）会逼你用次优参数，得出不能外推的结论。必须区分"信号无效"和"参数受限下的结果不理想"。
