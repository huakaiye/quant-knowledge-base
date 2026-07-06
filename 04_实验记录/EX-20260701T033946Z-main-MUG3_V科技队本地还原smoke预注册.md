---
type: 实验记录
ex_id: EX-20260701T033946Z-main-MUG3
rd_id: RD-20260701T033937Z-main-HTGA
status: completed
stage: completed_smoke_passed
owner: main
created_at: 2026-07-01T03:39:46Z
updated_at: 2026-07-01T03:46:19Z
strategy_id: STRAT-20260701T034401Z-main-YDL6
module_type: 个股静态池动量轮动
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/vtech_smoke.json
result_paths:
  - results/v2/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/smoke/
summary_paths:
  - results/v2/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/smoke/72f86de716834da9b114b363ecd1308f/summary.json
quality_gate: smoke_passed_no_promote
subagent_call_ids: []
subagent_exemption: 当前工具环境虽有子代理能力，但本会话上层工具规则要求只有用户明确要求时才能调用子代理；主控：Codex；时间：2026-07-01T03:32:11Z。
tags: [V科技队, 科技股, 聚宽复现, smoke, 分时调仓, 个股动量]
---

# V科技队本地还原smoke预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260701T033937Z-main-HTGA_V科技队科技股动量轮动复现|V科技队科技股动量轮动复现]]
- 策略档案：[[03_策略档案/STRAT-20260701T034401Z-main-YDL6_V科技队科技股动量轮动策略档案|V科技队科技股动量轮动策略档案]]
- 来源文献或灵感：[聚宽文章 73612](https://www.joinquant.com/post/73612)
- 产生的决策：
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：公开聚宽源码删除外部下单封装和明文 token 后，能不能在本地平台以聚宽兼容模式加载并跑完短窗 smoke。  
我们原本预计：配置能识别 106 只股票，策略能在 10:10 清仓、14:30 买入，短窗内至少产生可解释的调度日志和成交或无成交原因。  
实际看到：smoke 正常完成，任务 ID `72f86de716834da9b114b363ecd1308f`，识别 106 只股票，事件表包含 10:10 清仓和 14:30 买入，短窗累计 65 笔成交。  
这说明：本地平台可以加载还原版源码，并按原策略的分时调仓链路完成短窗撮合。  
但还不能说明：即使 smoke 通过，也不能说明策略有效、无未来函数、能实盘或能承受成本冲击。  
下一步要做：若 smoke 通过，再开正式复现和负控实验。

## 2. 研究背景

用户提供 `C:/Users/Administrator/Desktop/V科技队.txt`，计划在本地还原。原策略来自聚宽文章，核心是固定科技股池内按 20 日趋势动量打分，每日 10:10 清仓、14:30 买入前 5 名。本实验只做本地还原 smoke，避免把未审计结果误写成正式结论。

## 3. 实验前假设

删除原文外部下单封装和明文 token 后，保留原版策略逻辑，可以用本地 V2 平台 `joinquant` 模式完成短窗加载、调度和交易链路验证。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：任务正常结束，输出 `summary.json`、`trades.csv`、`positions.csv`、`logs.jsonl` 或等效结果文件。
- 交易行为：日志出现策略初始化、10:10 清仓、14:30 选股买入；若无成交，需要能解释为数据覆盖或打分全 0。
- 风险表现：本实验不评价收益风险，只记录是否能跑通。
- 分段表现：2025-01-02 至 2025-01-10 短窗能完成；不做跨期结论。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| 原始源码 | 确认还原版只删除外部依赖和 token，不改核心逻辑 | `C:/Users/Administrator/Desktop/V科技队.txt` |
| 本地还原策略 | smoke 执行对象 | `${QUANT_PLATFORM_ROOT}/src/strategies/research/v_tech_momentum_jq.py` |
| smoke 配置 | 最小加载与交易链路验证 | `${QUANT_PLATFORM_ROOT}/configs/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/vtech_smoke.json` |

## 6. 竞争性解释

即使 smoke 符合预期，也可能是：

- 短窗样本太短，只说明工程链路能跑，不说明长期可用。
- 静态科技股池来自文章发布时点，存在后验主题池偏差。
- 本地平台和聚宽在分钟撮合、涨跌停、停牌和 `current_data` 细节上仍可能有差异。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 策略无法加载，或仍依赖外部下单封装、明文 token。
- 配置无法解析 106 只股票或分钟数据要求。
- 回测报错中断，且不是本地数据缺失可解释问题。
- 调度时点不符合 10:10/14:30，或成交链路与策略语义明显不一致。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待检查 | 本轮仅 smoke；后续需抽样核对 `attribute_history` 日线截止和 14:30 当前价时间戳 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待检查 | 后续需检查 14:30 `last_price` 与成交价口径 |
| 股票池或 ETF 池不存在未来成分泄漏 | 未通过正式审计 | 106 只科技股为 2026 年文章静态池，历史长测天然有后验池风险 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本策略不使用财务、宏观或估值字段 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 本实验只做 smoke，不接入默认交易逻辑 |

负控或错位检查：

- 本轮不做；下一轮正式复现必须包含随机 top5、信号错位 1 日/5 日、固定科技池等权、修正 R2 消融和成本扰动。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 本轮不搜索参数，只复刻原版 `lookback_days=20`、`holdings_num=5` |
| 样本内、验证集、样本外划分清楚 | 待检查 | smoke 短窗不做收益结论 |
| 邻近参数敏感性合理 | 待检查 | 后续正式实验再做 3/5/10 持仓数和窗口敏感性 |
| 成本、滑点或换手扰动已检查 | 待检查 | 本轮只使用原文成本口径 |
| 已做消融或负控 | 待检查 | 本轮不做负控 |
| 未只报告最优结果 | 通过 | 本轮只报告工程能否跑通 |

证据等级：`L0`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前工具环境虽有子代理能力，但本会话上层工具规则要求只有用户明确要求时才能调用子代理；主控：Codex；时间：2026-07-01T03:32:11Z。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：无实际子代理调用，不追加调用台账。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/configs/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/vtech_smoke.json
```

### 运行命令

```bash
wsl -- bash -lc "cd '/mnt/e/量化平台_V1.4.0' && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/vtech_smoke.json 2>&1 | tee results/v2/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/vtech_smoke.run.log"
```

### 可见进度与日志

- 是否过程可见：是
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/vtech_smoke.run.log`
- 查看进度命令：`wsl -- bash -lc "tail -f '/mnt/e/量化平台_V1.4.0/results/v2/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/vtech_smoke.run.log'"`
- 异常判断：加载失败、数据缺失、调度错误、交易链路异常均视为 smoke 未通过。
- 后台回测豁免：不适用，前台执行。

### 结果路径

```text
results/v2/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/smoke/72f86de716834da9b114b363ecd1308f/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 策略加载 | 应成功 | 成功 | 通过 | 输出 `summary.json`、`trades.csv`、`positions.csv`、`logs.jsonl`、`report.html` 等结果文件 |
| 股票池数量 | 106 | 106 | 一致 | `summary.json` 记录 106 只 symbols，初始化日志显示 `股票池数量:106` |
| 调度行为 | 10:10/14:30 | 事件表包含 `sell_all_positions` 10:10 和 `buy_top_stocks` 14:30 | 一致 | `summary.json` events 与 `trades.csv` 时间戳一致 |
| 成交文件 | 应输出 | `trades.csv` 65 笔 | 通过 | 2025-01-02 买入 5 笔，之后每个交易日卖出 5 笔、买入 5 笔 |
| 短窗收益 | 不评价 | 总收益 -4.2403%，最终权益 95,759.68 | 仅记录 | 7 个交易日短窗不能说明策略有效性 |
| 最大回撤 | 不评价 | -4.4891% | 仅记录 | 只作为 smoke 记录 |

## 13. 支持证据

- 还原策略已删除外部下单封装和明文 token。
- 配置显式登记 106 只股票和分钟数据要求。
- 前台命令按 `PYTHONUNBUFFERED=1 + tee` 执行，日志路径为 `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260701T033937Z-main-HTGA/EX-20260701T033946Z-main-MUG3/vtech_smoke.run.log`。
- `trades.csv` 显示交易时间集中在 10:10 和 14:30，符合原策略分时调仓语义。

## 14. 反对证据

- 静态科技股池存在后验偏差，不能因 smoke 通过而解除。
- 本轮未做随机 top5、信号错位、固定等权、成本扰动、容量或涨跌停不可成交审计。
- 2025-01-02 至 2025-01-10 短窗总收益为 -4.2403%，但窗口太短，不能做收益判断。

## 15. 偏差诊断

工程链路符合预期；收益表现不纳入本轮判断。短窗成交集中在科创板和创业板高波动股票，进一步强化后续必须做滑点、冲击成本和涨跌停可成交审计。

## 16. 研究判断

建议状态：`observe`

理由：smoke 已通过，证明本地还原版能运行；但证据等级仍为 L0，只能支持继续正式复现实验，不允许 `promote`。

## 17. 下一步

执行 smoke 回测；若通过，再新开正式复现实验，加入随机/错位负控、固定池等权基准、修正 R2 消融、成本/滑点/容量扰动和涨跌停不可成交审计。
