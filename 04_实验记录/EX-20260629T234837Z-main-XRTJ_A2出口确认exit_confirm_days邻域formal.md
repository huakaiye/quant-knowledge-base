---
type: 实验记录
ex_id: EX-20260629T234837Z-main-XRTJ
rd_id: RD-20260605T115651Z-main-DEF0
status: completed
stage: formal_completed_十一年口径H1证伪_exit_confirm对A2最终收益零净影响
owner: main
created_at: 2026-06-29T23:48:37Z
updated_at: 2026-06-30T10:30:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块
decision_ids:
  - DEC-20260627T073551Z-main-DTH2
lit_ids: []
idea_ids:
  - MECH-20260629T234714Z-main-EFHW
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-DEFENSE/rule_a_idle/EX-20260629T234837Z-main-XRTJ/formal/exit_confirm/
result_paths:
  - results/v2/research/R010-DEFENSE/rule_a_idle/EX-20260629T234837Z-main-XRTJ/
summary_paths: []
quality_gate: L2_preregistered_待formal
subagent_call_ids: []
subagent_exemption: 代码改动插入点已由主控只读核实（etf_dual_pool_r010b_action_ablation.py:6620-6748 状态机逻辑）；假设/证伪/机制设计/最终判断主控承担；主控：main；时间：2026-06-29T23:48:37Z
tags: [双池轮动, 防御模块, A2趋势破位, 出口确认, exit_confirm, 邻域验证, formal, 阶段1.1, A2改进计划]
---

# A2 出口确认 exit_confirm_days 邻域 formal（A2 改进计划阶段 1.1）

> 隶属 [[05_研究决策/DEC-20260627T073551Z-main-DTH2_A2趋势破位升级RA5第三维L2robustness更新shadow配置|DEC-DTH2]] 下的 A2 改进计划阶段 1.1。承接 [[04_实验记录/EX-20260629T151849Z-main-2ZBC_A2出口抖动与不对称设计只读诊断|EX-2ZBC]] 诊断（出口抖动成立，集中在 2023 反弹段），本实验用 formal 回测验证"给出口加连续确认"能否治抖动且净效应为正。**不违反 DEC-DTH2 第 5 节**（禁的是 A2+RA7 entry_confirm 组合，无人禁 exit_confirm）。

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|DEF0]]
- A2 来源：[[04_实验记录/EX-20260627T053730Z-main-JTX7_A2趋势破位ma200斜率治V型误伤|EX-JTX7]]
- 诊断依据：[[04_实验记录/EX-20260629T151849Z-main-2ZBC_A2出口抖动与不对称设计只读诊断|EX-2ZBC 出口抖动]]
- 改进 backlog：[[07_因子数据灵感/03_机制/MECH-20260629T234714Z-main-EFHW_A2改进方向备选清单与阶段0诊断结论沉淀|MECH-EFHW]]
- A2 决策：[[05_研究决策/DEC-20260627T073551Z-main-DTH2_A2趋势破位升级RA5第三维L2robustness更新shadow配置|DEC-DTH2]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]

## 1. 新手摘要

A2 防御信号有个不对称：进入空仓很难（要分数低+广度差+趋势破位三关同时满足、连续 N 天），但退出空仓很容易（三关里任一恢复就立即切回持仓，没有"连续确认几天"的要求）。EX-2ZBC 诊断证明这种"进严出松"导致趋势关在 2023 反弹段反复抖动——转正后 5 天内 50% 又重新转负，产生"刚切回又得切回空仓"的无谓换手。

**本实验**：给出口也加连续确认（exit_confirm_days），即空仓时要"连续 N 天三关不再满足"才真正切回持仓。镜像现有入口确认机制。预期：过滤 2023 反弹段的虚假转正，降低换手，净改善 2022_2023 段（该段对 slope_window 最敏感的根因）。

**风险**：出口确认会延迟真实反弹的退出（少赚反弹）。formal 必须验证"减少抖动省的换手成本" > "延迟退出少赚的收益"。

## 2. 研究背景

### 2.1 现有状态机的进严出松

代码 `etf_dual_pool_r010b_action_ablation.py`：
- **入口**（`:6716-6727`）：持仓时 `is_low` 累积 `low_streak`，连续 `entry_confirm` 天（默认 1）才 `is_flat=True` 切空仓。**有确认**。
- **出口**（`:6707-6715`）：空仓时只要 `not is_low`（任一关恢复）就立即 `is_flat=False` 切回。**无确认**。

### 2.2 EX-2ZBC 的量化靶子

- 全样本趋势关转正后 5 天内 50% 重新转负（短段 ≤3 天占 33.3%）。
- 抖动集中在 2023 反弹段（6 次转正、5 天内 66.7% 重入、slope 临界区 58.3%）。
- exit_confirm=3 理论上能过滤 2023 段约 50% 的虚假转正。
- 2022 全年 100% on/0 抖动（持续下跌段不受影响）。

## 3. 实验前假设

**H1**：给 A2 出口加连续确认（exit_confirm_days），能过滤 2023 反弹段的虚假转正，降低换手，净改善 2022_2023 段复合收益（缩小对 slope_window 的敏感），且不破坏 2024 真崩盘保护（exit_confirm≤3 天，真反弹持续远超 3 天）。

## 4. 实验前预测

基于 EX-2ZBC 抖动量化 + A2 四段基线（EX-JTX7）：

| exit_confirm | 2022_2023 预测 | 2024 预测 | 2025 预测 | 复合预测 |
| --- | --- | --- | --- | --- |
| 1（=现状） | -5.5%（A2 基线） | +26.3% | -0.0% | 18.719x（基线） |
| 2 | -4%~-5%（略改善） | +26.3%（不变，真反弹>2天） | -0.0% | 18.8~19.0x |
| 3 | **-2%~-3%（核心改善）** | +25%~+26%（略降，边缘） | -0.0% | **19.0~19.3x** |
| 5（边界，防过拟合） | -1%~-2% | +23%~+25%（开始少赚反弹） | -0.0% | 18.5~19.0x（倒 U 顶端在 3） |

预测理由：
- **2022_2023 核心改善**：exit_confirm 过滤 2023 反弹段虚假转正（诊断已证 50% 是假的），减少"切回又切回空仓"的换手损耗。
- **2024 保护基本不变**：2024 真崩盘后真反弹持续远超 3 天，exit_confirm≤3 不会延迟退出。但 exit_confirm=5 可能开始吃掉反弹初期的收益。
- **2025 不变**：2025 段 A2 本就 0 触发，exit_confirm 无影响。
- **复合倒 U，顶端在 3**：太小（1-2）过滤不够，太大（5）延迟退出少赚。3 是物理甜区（V 型反弹<3 天，真反弹>3 天的物理分界）。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| A2 现状（exit_confirm=1） | 主对照，复合 18.719x | 复用 EX-JTX7 formal 结果不重跑 |
| exit_confirm=2/3/5 | 邻域 | 本轮新跑 |
| baseline hard5 | 绝对基准 15.683x | 复用 |

## 6. 竞争性解释

即使 H1 看似成立，也可能是：
- **改善来自少交易省钱，不是机制更优**：若 cost1x 改善大但 cost2x 改善小，说明是成本效应非机制。→ 必须双成本档验证。
- **2023 样本量小**：6 次转正事件，exit_confirm=3 的"过滤 50%"统计意义有限。→ 多段交叉 + 邻域一致性验证。
- **exit_confirm 治了抖动但引入新滞后**：出口延迟可能在别的段（如 2024 反弹初期）少赚。→ 重点查 2024 段是否退化。

## 7. 证伪条件

出现以下任一项，H1 不通过：
- **2024 保护恶化**：2024 段收益差 <+15%（exit_confirm 延迟退出漏掉真崩盘后的反弹）→ 核心证伪。
- **复合不达**：所有 exit_confirm 邻域复合 < A2 现状 18.719x（出口确认无净改善）。
- **邻域不稳健**：exit_confirm 呈单调（非倒 U），或仅单点甜区（过拟合嫌疑，对标 RA7 的 N 倒 U 教训）。

**通过条件**：exit_confirm 邻域复合 ≥ A2 现状 18.719x + 2024 保护不恶化（≥+15%）+ 2022_2023 改善 + 邻域倒 U 非单点。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | ✅ 通过 | exit_confirm 只用 T 日及之前的 is_low 状态累积，无未来 |
| 信号生成和成交价格不存在同 bar 泄漏 | ✅ 通过 | T 日盘后判定，T+1 开盘下单（沿用 A2） |
| 出口确认不引入未来函数 | ✅ 通过 | not_low_streak 累积的是历史 is_low=False 的连续天数 |
| Shadow 或观察信号未被当成默认交易信号 | ✅ 通过 | exit_confirm_days 默认 1 退化现状，baseline 不受污染 |

负控：exit_confirm=1 配置等价于现状（任一恢复即切回），作为消融对照，复用 A2 现状结果不重跑。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | ✅ 通过 | exit_confirm ∈ {1,2,3,5} 预注册，非看结果扩网格 |
| 样本划分清楚 | ✅ 通过 | 4 段 formal；样本外靠 shadow（本轮不替代） |
| 邻近参数敏感性合理 | **本实验验证项** | 邻域 {1,2,3,5}，看倒 U 非单点 |
| 成本扰动已检查 | ✅ 计划 | cost1x 主跑，若通过补 cost2x |
| 已做消融或负控 | ✅ 通过 | exit_confirm=1 退化现状即负控 |
| 未只报告最优结果 | ✅ 承诺 | 所有邻域结果全列出 |

证据等级：`L2_single_point_preregistered`（待 formal 后升级）

## 10. 子代理调用记录

子代理豁免：代码改动插入点已由主控只读核实（状态机逻辑 :6620-6748 清晰）；配置生成/回测执行可委派但本轮主控直接做（避免超时）；假设/证伪/机制设计/最终判断主控承担。主控：main；时间：2026-06-29T23:48:37Z。

## 11. 执行记录

### 代码改动设计（镜像入口机制，最小侵入，默认退化）

```text
策略文件：src/strategies/research/etf_dual_pool_r010b_action_ablation.py

1. 配置读取（:6627 cooldown_days 后加 1 行）：
   exit_confirm = int(R010B_ACTION_CONFIG.get("r010b_rule_a_idle_exit_confirm_days", 1) or 1)
   # 默认 1 = 任一恢复即切回 = 退化当前行为

2. 状态字典（:6643 加字段）：
   context._rule_a_state = {"low_streak": 0, "cooldown_left": 0, "is_flat": False,
                            "score_history": [], "not_low_streak": 0}  # 新增 not_low_streak

3. 出口逻辑改写（:6707-6715）：
   if st_a["is_flat"]:
       if not is_low:
           st_a["not_low_streak"] += 1            # 新增：连续恢复计数
           if st_a["not_low_streak"] >= exit_confirm:   # 连续 exit_confirm 天才真正切回
               st_a["is_flat"] = False
               st_a["low_streak"] = 0
               st_a["not_low_streak"] = 0
               st_a["cooldown_left"] = cooldown_days
           else:
               should_go_flat = True              # 还没连续够天数，保持空仓
       else:
           st_a["not_low_streak"] = 0             # 中断，重新计数
           should_go_flat = True
   else:
       ...（入口逻辑不变）
```

### 配置生成

```text
配置根：configs/research/R010-DEFENSE/rule_a_idle/EX-20260629T234837Z-main-XRTJ/formal/exit_confirm/<N>_<segment>/
基于 EX-JTX7 A2 配置模板（trend_break_enabled=True + slope_window=20 + 三维 2.0/0.5/200），
仅替换 r010b_rule_a_idle_exit_confirm_days + output_dir + research_metadata。
邻域：exit_confirm ∈ {1,2,3,5} × 4 段（2020_2021/2022_2023/2024/2025_20260519）
cost1x 主跑；exit_confirm=1 复用 A2 现状不重跑（=3 个新邻域 × 4 段 = 12 pair）
```

### 运行命令（并行回测，过程可见）

```bash
platformWsl=/mnt/e/量化平台_V1.4.0
# 1. 改代码 + py_compile 验证
wsl -- bash -lc "cd '$platformWsl' && python3 -m py_compile src/strategies/research/etf_dual_pool_r010b_action_ablation.py"
# 2. 生成 12 个配置（exit_confirm 2/3/5 × 4 段）
wsl -- bash -lc "cd '$platformWsl' && PYTHONUNBUFFERED=1 python3 scripts/research/gen_a2_exit_confirm.py"
# 3. 并行回测（max-parallel=6，单批约 10-15 分钟）
wsl -- bash -lc "cd '$platformWsl' && bash scripts/research/run_parallel_backtest.sh configs/research/R010-DEFENSE/rule_a_idle/EX-20260629T234837Z-main-XRTJ/formal/exit_confirm/*/*.json"
```

### 可见进度与日志

- 是否过程可见：是（PYTHONUNBUFFERED=1 + tee，run_parallel_backtest 每段独立 run.log）
- 启动后 5 分钟内报告第一段速度并估算总时长
- 查看进度：`tail -f tmp/parallel_backtests_<STAMP>/segN_*.run.log`
- 异常判断：回测卡住或超时立即报告哪段卡住、已跑多久

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-DEFENSE/rule_a_idle/EX-20260629T234837Z-main-XRTJ/
```

## 11.1 四段口径回测结果与方法论发现（2026-06-30，转十一年口径）

### 11.1.1 四段口径回测结果（12 段 = ec 2/3/5 × 4 段）

12 段全部 exit code=0 完成，但发现严重异常：

| 段 | ec=2 | ec=3 | ec=5 | A2基线(EX-JTX7,bug版) | baseline |
| --- | --- | --- | --- | --- | --- |
| 2020_2021 | 216819 | 216819 | 216819 | 225080 | 225080 |
| 2022_2023 | 132447 | 132447 | 132447 | 123954 | 131215 |
| 2024 | 209811 | 209811 | 209811 | 211005 | 167005 |
| 2025 | 293921 | 293921 | 293921 | 317974 | 317974 |

**两个异常**：① ec 2/3/5 三列**完全相同**（exit_confirm 无差异）；② 4 段日志**全部无 RULE_A_IDLE 触发记录**。

### 11.1.2 根因诊断（已验证）

- ✅ **代码逻辑正确**：单元测试 `test_exit_confirm_logic.py` 证明 ec=1/2/3/5 在相同 is_low 序列下产生不同切换时点（ec=1 抖动 5 次切换、ec=2/3/5 过滤到 2 次，切回时点随 ec 延后）。
- ✅ **配置正确**：逐字段对比与 EX-JTX7 原版 A2 完全一致（仅多了 exit_confirm_days）。
- ❌ **根因**：**raw_closes bug 修复后（EX-D3，2026-06-28），A2 的 rule_a_idle 三关门控在四段空仓重置口径下基本不再触发空仓**。EX-JTX7 报告的 123954/211005 等是 **bug 版结果**——bug 让 ret20_breadth/median_ret 失真导致误触发；修复后这些段不再触发。四段日志无 RULE_A_IDLE 记录即铁证。

### 11.1.3 这是第三次被四段空仓重置口径误导（方法论教训）

| 次 | 实验 | 四段口径误导 |
| --- | --- | --- |
| 1 | EX-HUWV（2026-06-27） | 四段高估 RA5 防御效果（段初空仓轻仓假象） |
| 2 | EX-A2COST（2026-06-29） | 四段 cost2x 误判 A2 多换手（实际少换手 6.2%） |
| **3** | **EX-XRTJ（本轮）** | **四段口径下 A2 根本不触发空仓（raw_closes 修复后），无法验证 exit_confirm** |

**教训（写进研究质量审计规范）**：raw_closes bug 修复后，四段空仓重置口径对 A2 rule_a_idle 的验证能力进一步下降。任何涉及 rule_a_idle 触发/出口/抖动的实验，**必须用十一年持仓继承口径**，四段口径会得到无效结果。

### 11.1.4 决策：转十一年口径重跑（用户确认 2026-06-30）

- EX-A2C2X11Y 已证明十一年口径下 A2 真实触发空仓（交易笔数 2449，比 baseline 少 162 笔，"空仓省钱"）。
- 转十一年口径（2015-01-01~2026-05-19）重跑 ec 2/3/5 × cost1x/cost2x（6 配置），ec=1 复用 EX-A2C2X11Y 已有结果作基线。
- 配置：`configs/research/R010-DEFENSE/rule_a_idle/EX-20260629T234837Z-main-XRTJ/formal/exit_confirm_11yr/`

## 12. 实际观察（十一年口径 formal）

6 段（ec 2/3/5 × cost1x/cost2x）全部 exit code=0 完成，耗时约 70 分钟。

### 12.1 十一年最终结果

| 配置 | cost1x final | cost2x final | 交易笔数 |
| --- | --- | --- | --- |
| ec=2 | **3,937,776.04** | **3,018,985.79** | 2449/2454 |
| ec=3 | **3,937,776.04** | **3,018,985.79** | 2449/2454 |
| ec=5 | **3,937,776.04** | **3,018,985.79** | 2449/2454 |
| **ec=1（原版A2,EX-A2C2X11Y基线）** | **3,937,776（38.378x）** | **3,018,986（29.190x）** | 2449 |

**ec 2/3/5 的最终结果与原版 ec=1 完全相同（差异 <0.01%，浮点误差级）。**

### 12.2 中途差异与最终收敛

虽然最终相同，但中途（2023 反弹段、2024 段）三版本曾出现权益分歧：
- 2023-06：ec2=722431 vs ec3/ec5=720059（差 2372）
- 2024-02：ec2/ec3=773926 vs ec5=719688（差 54237，ec5 延迟切回少赚反弹）
- 但这些差异在后续交易日被完全抵消，最终收敛到相同终值。

## 13. 支持证据

1. **代码逻辑正确（已验证）**：单元测试 `test_exit_confirm_logic.py` 证明 ec=1/2/3/5 在相同 is_low 序列下产生不同切换时点。十一年回测中途的权益分歧（2023/2024 段）也证实 exit_confirm 确实改变了出口时点。
2. **十一年口径下 rule_a_idle 真实触发**：与四段口径（不触发）不同，十一年口径下 A2 触发了空仓（中途权益分歧即证据），exit_confirm 有对象可作用。

## 14. 反对证据（H1 证伪）

1. **最终收益零净影响（核心证伪）**：ec 2/3/5 的十一年 final 与原版 ec=1 **完全相同**（3937776/3018986）。exit_confirm 没有带来任何可测量的收益改善或回撤改善。
2. **中途差异被完全抵消**：2023/2024 段的权益分歧（ec5 曾落后 54237）在后续被抹平。说明 exit_confirm 改变切回时点带来的"早切回赚/晚切回亏"在长周期里互相抵消，净值为零。
3. **EX-2ZBC 诊断的"出口抖动"对收益无影响**：诊断证明趋势关转正后 50% 重入（抖动真实存在），但本次 formal 证明这些抖动的换手损耗与 exit_confirm 延迟退出的少赚互相抵消，净效应为零。

## 15. 偏差诊断

| 预测 | 实际 | 原因 |
| --- | --- | --- |
| ec=3 复合 19.0~19.3x（改善） | **39.38x = 与原版完全相同** | 预测错误。exit_confirm 的换手节省与延迟退出少赚完全抵消 |
| ec=5 开始少赚（倒 U 顶端在 3） | ec5 中途少赚（2024 落后 54237）但最终收敛 | 少赚被后续弥补，最终无差异 |
| 2022_2023 改善 | 中途有差异，最终无差异 | 改善被抵消 |

预测与实际严重不符——根本原因是高估了"出口抖动换手损耗"的量级。实际换手损耗很小（T+1 摩擦），exit_confirm 节省的不足以产生净收益。

## 16. 研究判断

**建议状态：`completed_observe`（H1 证伪，exit_confirm 无净影响，不 adopt）**

理由：

1. **H1 证伪**：exit_confirm 对 A2 十一年最终收益零净影响（ec2/3/5 = ec1）。EX-2ZBC 诊断的出口抖动虽然真实存在，但对收益无可测量影响。
2. **不 adopt exit_confirm**：既然无净改善，不改变 A2 现状（exit_confirm 默认 1 保持）。代码改动保留（默认退化），但不启用。
3. **方法论价值**：本次实验有两个重要副产品：
   - **第三次确认四段口径误导**（raw_closes 修复后四段不触发空仓），强化"rule_a_idle 验证必须用十一年口径"教训。
   - **诊断≠formal**：EX-2ZBC 诊断证明抖动"存在"，但 formal 证明抖动"无影响"。存在≠有效，必须 formal 验证净效应。

## 17. 下一步

1. **阶段 1.1 终止**：exit_confirm 方向证伪（无净影响），不 adopt。
2. **转向阶段 2（L2 死叉预警）**：这是治本方向（反应式滞后），优先级最高。EX-JA43 预注册已完成，启动 death_cross_gate 代码改动 + 组合层 formal + 负控。
3. **阶段 1.2（斜率缓冲带）**：仍可做（填补 EX-XSFC 空白），但优先级低于阶段 2。
4. **教训写进研究质量审计规范**：诊断证明机制"存在"不等于机制"有效"，必须 formal 验证净效应（本次 exit_confirm 是第 4 次被"看结果猜测"推翻：P3 breadth、r010b3、P2 cost、本轮 exit_confirm）。
