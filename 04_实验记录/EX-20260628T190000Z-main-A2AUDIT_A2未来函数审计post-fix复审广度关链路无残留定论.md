---
type: 实验记录
ex_id: EX-20260628T190000Z-main-A2AUDIT
rd_id: RD-20260605T115651Z-main-DEF0
status: completed
stage: formal_completed_审计定论
owner: main
created_at: 2026-06-28T19:00:00Z
updated_at: 2026-06-28T19:00:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块
decision_ids:
  - DEC-20260627T073551Z-main-DTH2
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths: []
result_paths:
  - ${QUANT_PLATFORM_ROOT}/src/strategies/research/etf_dual_pool_r010b_action_ablation.py
quality_gate: 通过_post-fix全链路无残留未来函数风险
subagent_call_ids:
  - SUB-20260628T190000Z-main-A2AUDIT
tags: [防御模块, A2趋势破位, 未来函数审计, post-fix复审, raw_closes, ret20_breadth, 广度关链路, 趋势关独立性, 审计定论, A2AUDIT]
---

# A2 未来函数审计 post-fix 复审：广度关链路无残留定论

> 本实验是 A2（趋势破位）在 raw_closes bug 修复（2026-06-28，代码 7810 行）后的**独立未来函数复审**。前序审计 EX-JTX7 §8、EX-XSFC §8 只覆盖了趋势破位逻辑本身，未覆盖广度关（ret20_breadth）的 raw_closes→breadth 链路——而该链路在 bug 期间确实读过污染路径。本复审补审该链路，确认修复后无残留风险。

## 1. 实验前预注册（每轮实验硬规则）

- **研究方向 ID**：RD-20260605T115651Z-main-DEF0（下限空仓/防御模块）
- **本次假设**：raw_closes bug 修复后（7810 行每日整体替换），A2 的广度关（ret20_breadth<0.5）数据链路不再有跨日累加污染，取的是最近 20 个交易日的真实价格，无残留未来函数/陈旧数据风险。
- **实验前预测**：全链路无残留风险。理由——A2 对 bug 结果免疫（39.43→39.38，-0.1%）是因为趋势关把关，但广度关确实读过污染路径，需确认修复后该路径干净。
- **基准对照**：EX-JTX7 §8 原审计（仅覆盖趋势关）、`_refresh_state_price_cache`（state_prices 每日重建的健康对照）。
- **竞争性解释**：① 可能存在其他 dict.update 累加点未被发现；② ret20_breadth 可能用"末尾N值"切片但N值取错；③ market_signals 缓存可能跨日残留。
- **证伪条件**：若发现 raw_closes 或 state_prices 仍有跨日累加、或 breadth 读到非当日重建数据、或趋势关数据源耦合 raw_closes，则假设证伪。
- **计划使用的平台配置/结果路径**：`src/strategies/research/etf_dual_pool_r010b_action_ablation.py`（代码级链路追踪，无回测）。

## 2. 审计方法

代码级全链路追踪（子代理 SUB-A2AUDIT 执行），覆盖 5 个追踪点：
1. raw_closes 的构建（是否每日重建）
2. ret20_breadth 的计算（取数逻辑）
3. breadth 关卡判定（读哪个缓存）
4. 残留风险（其他累加点/末尾切片/旁路）
5. 趋势关的数据独立性（是否耦合 raw_closes）

## 3. 审计结果

### 3.1 raw_closes 构建（追踪点1）—— 无风险 ✅

- 构建位置：`_score_etfs_batch` 第 7781-7810 行。
- 第 7800-7802 行：`c_arr = pd.to_numeric(close_frame[key]...).dropna().values`，`raw_closes_cache[etf] = c_arr`（仅当 len≥21）。**raw_closes 不含当前价**（末值=T-1 收盘），与 state_prices 不同。
- **修复点 7810 行**：`context._r010a_raw_closes = raw_closes_cache`——每日整体替换。
- 对照组 `_refresh_state_price_cache`（7439-7457）同样每日整体替换（7445 局部累加→7457 整体替换），第 7455 行 append 当前价。
- **结论**：修复后 `_r010a_raw_closes` 与 `_r010a_state_prices` 同口径，跨日单调累加已消除。

### 3.2 ret20_breadth 计算（追踪点2）—— 无风险 ✅

- 计算位置：`_record_market_state_from_scores`（2176）+ `_calc_etf_state_metrics`（2332）。
- 第 2190-2196 行：先取 state_prices，再把 raw_closes 中不在 state_prices 的 ETF 补进去（当日重建值）。
- 第 2214-2226 行：遍历 state_prices 调 `_calc_etf_state_metrics` 收集 ret20_list。
- 第 2261 行：`ret20_breadth = positive_rets / n_valid`。
- **取数切片**（`_safe_ret` 2366-2369）：`ret20 = arr[-1] / arr[-21] - 1`，取末尾 21 值。**修复后这 21 值是最近 21 个交易日的真实价格**（state_prices 路径含当前价=实时20日收益；raw_closes 兜底路径 T-1 收盘，略滞后但无未来函数/无陈旧）。

### 3.3 breadth 关卡判定（追踪点3）—— 无风险 ✅

- 判定位置：第 6657-6666 行。
- 读 `market_signals["ret20_breadth"]`（第 2315 行 `context._r010a_cache["market_signals"] = signals`，每日整体替换，非 update）。
- **结论**：判定读的就是当日 freshly 计算的 ret20_breadth，无陈旧缓存旁路。

### 3.4 残留风险（追踪点4）—— 无残留 ✅

- **(a) 其他累加点**：`_r010a_raw_closes` 唯一写点是 7810（整体替换）；`_r010a_state_prices` 唯一写点在 `_refresh_state_price_cache` 7444/7457（整体替换）。两处 merge 块（689、2196）的 `state_prices[etf]=closes` 是对 getattr 返回 dict 的 in-place 增补，但增补值来自当日重建的 raw_closes，且次日整体替换丢弃增补，**不跨日累积**。
- **(b) 末尾切片**：`_safe_ret(arr,20)` 用 arr[-1]/arr[-21]，修复后是最近 21 个交易日，正确。
- **(c) 旁路**：`market_signals`、state_prices、raw_closes 均每日整体替换。`_get_cached_close_series`（5621）、`_score_hot_ma20_gap`（1109）、`_score_hot_series`（1135）虽读 raw_closes，但只用于持仓自身动量/MA20 gap，**不参与 ret20_breadth 广度计算**。

### 3.5 趋势关数据独立性（追踪点5）—— 完全独立 ✅

- 判定位置：第 6669-6705 行。
- 第 6678 行：`hs300_frame = _history_wide(fetch_count, 'close', [hs300_code])`——**直接对沪深300（510300.XSHG）当日新拉行情**，完全独立于 `_r010a_raw_closes`/`_r010a_state_prices` 缓存。
- **结论**：趋势关数据源是独立的当日 hs300 直接查询，与 raw_closes bug 无任何耦合。这正是 A2 对 bug 结果免疫的机制根因。

## 4. 实际观察

与预测完全一致：全链路无残留风险。raw_closes 与 state_prices 均每日整体替换、无跨日累加；ret20_breadth 取末尾 21 值（最近 20 个交易日真实价格）；breadth 判定读当日 freshly 计算的 market_signals；趋势关数据源完全独立于 raw_closes 缓存。

## 5. 和预测一致或不一致的地方

**完全一致**。预测"全链路无残留风险"，审计确认每个追踪点均无风险。三个竞争性解释（其他累加点/末尾切片取错/缓存残留）逐一排查后被否定。

## 6. 支持证据

- 子代理 SUB-A2AUDIT 代码级追踪报告（5 个追踪点，每点含行号+代码片段+结论）。
- 代码行号锚点：7810（修复点）、7439-7457（state_prices 对照）、2176-2261（breadth 计算）、6657-6666（breadth 判定）、6669-6705（趋势关）、2366-2369（_safe_ret 取数）。

## 7. 反对证据

无。本次审计未发现任何残留未来函数/陈旧数据风险。

## 8. 对新手的短总结

raw_closes bug 修复后，A2 的广度关（ret20_breadth<0.5）数据链路完全干净：每天的价格缓存都整体重建（不再跨日累加），广度计算取的是最近 20 个交易日的真实价格，趋势关用的是独立的沪深300实时行情。**A2 之所以在 bug 期间结果几乎不变（39.43→39.38），正是因为趋势关这道独立物理量把关，不让广度关的污染影响最终触发决策。** 本审计补上了前序审计（EX-JTX7/XSFC §8）遗漏的广度关链路，确认 A2 无残留风险。

## 9. 下一步

- A2 未来函数审计 post-fix 复审**通过**，可作为 promote 前的完备性证据之一。
- 后续 P2（成本扰动）、P3（参数敏感性）、P4（消融）继续推进 A2 的验证完备度。
- 本审计不替代样本外验证（仍卡 QMT 工程阻塞）。

## 10. 是否需要研究决策卡

否。本审计是验证补全，确认现有 A2 无残留风险，不改变决策状态（A2 仍 promote_candidate）。

## 11. 子代理调用记录

子代理计划：调用；调用ID SUB-20260628T190000Z-main-A2AUDIT；任务代号 SUBTASK-P1-A2AUDIT；平台昵称 Explore；模型 gpt-5.3-codex-spark；交付物 A2 广度关数据链路 5 追踪点代码级报告；豁免原因：审计最终定论由主控承担。

调用结果：子代理完成 5 个追踪点的代码级追踪，确认全链路无残留风险。主控据此写审计定论。

## 12. 关联链接

- [[04_实验记录/EX-20260627T053730Z-main-JTX7|EX-JTX7]]（前序 A2 实验，§8 原审计仅覆盖趋势关）
- [[04_实验记录/EX-20260628T120000Z-main-D3_raw_closes缓存累加污染根因定论|EX-D3]]（raw_closes bug 根因定论+修复）
- [[05_研究决策/DEC-20260627T073551Z-main-DTH2_A2趋势破位升级RA5第三维L2robustness更新shadow配置|DEC-DTH2]]（A2 决策卡）
