---
type: 实验记录
ex_id: EX-20260619T010219Z-main-B5JS
rd_id: RD-20260618T105950Z-main-7FY3
status: completed
stage: engineering_contract_passed_not_strategy_validation
owner: main
created_at: 2026-06-19T01:02:19Z
updated_at: 2026-06-19T01:08:56Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 执行与换仓模块
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - src/run_v2_live.py
  - src/quant_v2/cli/run_live.py
  - docs/V2_MiniQMT实盘适配说明.md
result_paths:
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T010219Z-main-B5JS/pytest_live_cli_output_json.log
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T010219Z-main-B5JS/summary.json
summary_paths:
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T010219Z-main-B5JS/summary.json
quality_gate: engineering_contract_only_not_strategy_validation
subagent_call_ids:
  - SUB-EXEMPT-20260619T014600Z-main-NEXTPUSH
subagent_exemption: 当前工具规则要求用户显式提出子代理/委派/并行 agent 才能调用；本轮未获得该授权，主控直接执行。
tags: [双池轮动, 低滞后, dry-run, 实盘证据, JSON落盘, 执行与换仓]
---

# V2 dry-run结果落盘证据契约

## 关联链接

- 研究方向：[[02_研究方向/RD-20260618T105950Z-main-7FY3_双池轮动真实交易微观数据低滞后研究|7FY3 双池轮动真实交易微观数据低滞后研究]]
- 父方向：[[02_研究方向/RD-20260605T115651Z-main-EXE0_双池轮动执行与换仓模块|EXE0 双池轮动执行与换仓模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：
- 产生的决策：
- 前置实验：[[04_实验记录/EX-20260618T105959Z-main-BYEX_平台与实盘微观数据就绪度只读盘点|BYEX 平台与实盘微观数据就绪度只读盘点]]
- 前置决策：[[05_研究决策/DEC-20260618T110703Z-main-FF3K_微观数据缺口确认后暂停低滞后执行实验|FF3K 微观数据缺口确认后暂停低滞后执行实验]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：  
V2 实盘 dry-run 是否能把单轮订单意图、事件、组合快照保存成可审计 JSON，从而为后续非 R 方低滞后研究提供真实链路证据入口。
我们原本预计：  
当前 CLI 只打印订单数量，不能留下完整证据；增加默认关闭的 `--output-json` 后，应能在显式传参时保存完整单轮结果，且不改变真实委托默认安全边界。
实际看到：  
平台 CLI 已新增默认关闭的 `--output-json`；`--dry-run-once` 能把输出路径传给 runner，JSON helper 能保存 `datetime` 字段，`--loop --output-json` 会被拒绝；最终 live CLI 单测 `8 passed`，`run_live.py` 编译检查通过。
这说明：  
低滞后方向的下一步不必再停留在“等实盘日志出现后再想怎么解析”，已经有了最小可审计 dry-run 证据格式。
但还不能说明：  
即使工程契约通过，也不能说明任何低滞后策略有效，更不能说明 KFSQ/A22 已经超越 R 方；它只补齐“以后如何收集外部观察证据”。
下一步要做：  
等具备 QMT dry-run 环境或真实观察流时，用 `--output-json` 采集订单意图证据，再把这些 JSON 作为 KFSQ/A22 的外部观察输入。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260618T105950Z-main-7FY3_双池轮动真实交易微观数据低滞后研究|7FY3]]。此前 BYEX/FF3K 已确认：当前环境没有正式盘口、逐笔、真实委托或成交滑点数据，7FY3 因此 park。与此同时，MCYG/KFSQ 和 A22 的共同下一步都指向“真实观察流、实盘 dry-run 或可审计成交日志”，但平台当前 `run_v2_live.py --dry-run-once` 只在控制台打印数量，不落盘完整订单意图。

所以本次不再继续搜索历史拟合函数，而是补一个更基础的证据契约：当未来具备 QMT 账号和可运行 dry-run 环境时，单轮结果必须能保存为 UTF-8 JSON，至少包含时间、执行事件、订单意图、成交、记录和组合快照。

## 3. 实验前假设

如果 V2 live CLI 增加默认关闭的 `--output-json`，则 dry-run 单轮可以产生可审计、可归档、可复核的 JSON 证据文件，同时不改变默认执行行为和真实委托确认门槛。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`src/tests/quant_v2/test_live_job_and_cli.py` 中新增单测通过；JSON 文件可被 `json.loads` 正常解析；时间字段序列化为 ISO 字符串。
- 交易行为：不提交真实委托；`--dry-run-once` 仍只生成订单意图；`--run-once` 仍必须显式 `--confirm-live-orders`。
- 风险表现：默认不落盘；只有显式 `--output-json` 才创建文件；`--loop` 不允许配合 `--output-json`，避免持续循环覆盖或膨胀单文件。
- 分段表现：本次不评估收益、回撤、胜率或分段 alpha。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| 原始 CLI 行为 | 只打印单轮数量，不保存完整证据 | `${QUANT_PLATFORM_ROOT}/src/quant_v2/cli/run_live.py` |
| 新增 JSON helper 单测 | 验证结果结构和时间序列化 | `${QUANT_PLATFORM_ROOT}/src/tests/quant_v2/test_live_job_and_cli.py` |
| `--loop` 排除 | 防止单轮证据参数被误用于持续循环 | `${QUANT_PLATFORM_ROOT}/src/quant_v2/cli/run_live.py` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 单测只覆盖参数传递和序列化，不等于真实 QMT 环境一定有订单或成交。
- dry-run JSON 是链路证据格式，不是策略收益证据；订单意图为 0 时仍不能证明低滞后信号无效。
- 没有本机 `LIVE_TRADING_ROOT` 和真实账号时，本实验不能验证实盘目录、真实成交或滑点。

## 7. 证伪条件

出现以下情况，本假设不通过：

- `--dry-run-once --output-json` 无法把输出路径传给 runner。
- `_write_cycle_result_json` 无法保存包含 `datetime` 的订单记录。
- 默认 CLI 行为被改变，或 `--run-once` 绕过 `--confirm-live-orders`。
- `--loop --output-json` 被允许执行，导致持续循环证据边界不清。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 不适用 | 本实验只改 CLI 落盘契约，不读取行情或生成新信号 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 不做回测收益判断，不用成交价评估 alpha |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 不修改股票池或 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不读取财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | `--output-json` 只保存单轮结果，不改变默认交易逻辑；真实委托仍需 `--confirm-live-orders` |

负控或错位检查：

- 本实验是工程契约，不做收益负控；负控要求转移到后续使用 JSON 的真实观察实验。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 不适用 | 无策略参数搜索 |
| 样本内、验证集、样本外划分清楚 | 不适用 | 无样本拟合 |
| 邻近参数敏感性合理 | 不适用 | 无连续参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 本实验不做收益评估 |
| 已做消融或负控 | 不适用 | 工程契约以单测和安全边界为门禁 |
| 未只报告最优结果 | 通过 | 不存在多结果挑选；记录了第一次测试失败和修正后的最终结果 |

证据等级：`L1`，仅为工程可用性证据，不是策略有效性证据。

## 10. 子代理调用记录

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前工具规则要求用户显式提出子代理/委派/并行 agent 才能调用，本轮未获得该授权；主控：main；时间：2026-06-19T01:05:18Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260619T014600Z-main-NEXTPUSH | 无 | SUBTASK-NONR-NEXT-PUSH-EXEMPT | 无 | 2026-06-19T01:05:18Z | `README.md`; `00_入口/研究驾驶舱.md`; `00_入口/当前状态.md`; `08_方法论/*`; `${QUANT_PLATFORM_ROOT}/AGENTS.md`; `${QUANT_PLATFORM_ROOT}/src/quant_v2/cli/run_live.py`; `${QUANT_PLATFORM_ROOT}/src/tests/quant_v2/test_live_job_and_cli.py` | `${QUANT_PLATFORM_ROOT}/src/quant_v2/cli/run_live.py`; `${QUANT_PLATFORM_ROOT}/src/tests/quant_v2/test_live_job_and_cli.py`; `${QUANT_PLATFORM_ROOT}/docs/V2_MiniQMT实盘适配说明.md`; 本实验记录 | `PYTHONPATH=src python3 -m pytest src/tests/quant_v2/test_live_job_and_cli.py -q`; `PYTHONPATH=src python3 -m py_compile src/quant_v2/cli/run_live.py` | 只判断工程证据契约，不判断策略有效性、未来函数最终结论或路线 promote | 没有真实 QMT 账号与成交日志，无法验证实盘外部证据 | 主控完成代码审阅、单测和文档回填 | B5JS 通过工程契约；7FY3 仍保持 park，下一步变为采集真实 dry-run JSON |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/src/quant_v2/cli/run_live.py
${QUANT_PLATFORM_ROOT}/src/tests/quant_v2/test_live_job_and_cli.py
${QUANT_PLATFORM_ROOT}/docs/V2_MiniQMT实盘适配说明.md
```

### 运行命令

```bash
cd '/mnt/e/量化平台_V1.4.0' && PYTHONPATH=src python3 -m pytest src/tests/quant_v2/test_live_job_and_cli.py -q 2>&1 | tee 'results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T010219Z-main-B5JS/pytest_live_cli_output_json.log'
cd '/mnt/e/量化平台_V1.4.0' && PYTHONPATH=src python3 -m py_compile src/quant_v2/cli/run_live.py
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T010219Z-main-B5JS/pytest_live_cli_output_json.log`
- 查看进度命令：前台运行，无后台进度命令。
- 异常判断：第一次运行 `2 failed, 6 passed`，失败原因是 WSL Python 3.10 触发旧 CLI 单测的 Python 3.11 保护；修正测试环境 monkeypatch 后复跑 `8 passed`。
- 后台回测豁免：不适用，前台运行单测。

```text
后台回测豁免：不适用；本次不是回测，且单测前台运行。
```

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T010219Z-main-B5JS/pytest_live_cli_output_json.log
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T010219Z-main-B5JS/summary.json
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| CLI 证据落盘 | 原 `--dry-run-once` 只打印数量 | 新增显式 `--output-json` | 改善 | 单轮 dry-run/run-once 可保存完整 JSON |
| 默认行为 | 不传参数不落盘 | 仍不落盘 | 不变 | 避免默认生成额外文件 |
| 真实委托保护 | `--run-once/--loop` 必须 `--confirm-live-orders` | 仍必须 | 不变 | 没有放宽真实下单安全门槛 |
| loop 边界 | 无 JSON 单轮证据参数 | `--loop --output-json` 返回 2 | 改善 | 避免持续循环写入边界不清 |
| live CLI 单测 | 旧测试在 WSL Python 3.10 会被保护挡住 | 修正测试环境后 `8 passed` | 改善 | 新增契约有测试覆盖，旧用例目标更清晰 |

## 13. 支持证据

- `${QUANT_PLATFORM_ROOT}/src/quant_v2/cli/run_live.py` 新增 `--output-json`，写出字段包括 `current_dt/dry_run/executed_events/orders/trades/records/portfolio`。
- `${QUANT_PLATFORM_ROOT}/src/tests/quant_v2/test_live_job_and_cli.py` 覆盖 dry-run 参数传递、JSON 写出、`datetime` 序列化、`--loop` 拒绝。
- `${QUANT_PLATFORM_ROOT}/docs/V2_MiniQMT实盘适配说明.md` 已补充 `--output-json` 参数说明和 dry-run 示例。
- 验证日志：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T010219Z-main-B5JS/pytest_live_cli_output_json.log`，最终 `8 passed in 1.60s`。
- 编译检查：`PYTHONPATH=src python3 -m py_compile src/quant_v2/cli/run_live.py` 通过。

## 14. 反对证据

- 本机仍未配置 `LIVE_TRADING_ROOT`，没有真实实盘目录证据。
- 本次没有连接 QMT，也没有产生真实 dry-run 订单 JSON；只证明平台具备保存该类 JSON 的能力。
- 没有评估收益、滑点、换手或触发后收益，因此不能支持任何策略 promote。

## 15. 偏差诊断

实验前预测基本成立。唯一偏差是第一次运行完整单测时两个旧用例失败，原因不是 `--output-json`，而是 WSL `python3` 为 3.10.12，CLI 入口先检查 Python 3.11。修正方式是在旧单测中显式 monkeypatch `_is_python311=True`，让它们继续测试 check-only 和 connect-check 的目标行为；生产 CLI 的 Python 3.11 保护没有放宽。

## 16. 研究判断

建议状态：`observe`

理由：B5JS 通过工程契约，可以作为后续真实观察流的最小证据格式；但它不是策略收益实验，也没有真实订单、成交或滑点证据。因此 7FY3 方向仍保持 `park`，只把下一步从“等待数据层补齐”细化为“可用 `--output-json` 收集 dry-run JSON 后再验证 KFSQ/A22”。

## 17. 下一步

下一轮最值得做的是在可连接 QMT 模拟端或实盘 dry-run 的 Windows 环境中运行：

```powershell
& 'C:\Python311\python.exe' src/run_v2_live.py --config configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json --dry-run-once --force-events --output-json results/v2/live_dry_run/portfolio_latest_dry_run.json
```

它能减少的不确定性是：真实策略链路在当前事件日是否能产生订单意图、订单意图是否有足够字段关联到 KFSQ/A22 等外部观察信号、以及后续是否值得把 dry-run JSON 进入正式观察面板。
