---
type: 实验记录
ex_id: EX-20260607T154134Z-main-QTFV
rd_id: RD-20260605T133318Z-main-H6V3
status: completed
stage: formal_strict_pass_a22_native_forward_shadow_boundary
owner: main
created_at: 2026-06-07T15:41:34Z
updated_at: 2026-06-07T18:41:19Z
strategy_id:
module_type: 核心轮动风控诊断模块
decision_ids: [DEC-20260607T151252Z-main-A22N, DEC-20260607T185223Z-main-HH4B]
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/
  - configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/guard/
  - scripts/research/generate_qtfv_a22_native_forward_shadow_configs.py
  - scripts/research/run_qtfv_a22_native_forward_shadow.sh
  - scripts/research/summarize_qtfv_a22_native_forward_shadow.py
result_paths:
  - results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/
  - results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/logs/formal/
  - results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/
summary_paths:
  - results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/summary.json
quality_gate: L1_engineering_shadow_boundary_strict_pass
subagent_call_ids: [SUB-20260607T154000Z-main-A22FS-ENTRY, SUB-20260607T154800Z-main-A22FS-MIN, SUB-20260607T183800Z-main-QTFV-VERIFY]
subagent_exemption:
tags: [双池轮动, score过热, A22, 原生字段, forward边界, shadow边界, 默认关闭观察]
---

# A22原生forward shadow边界验证预注册与formal收口

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 上游字段审计：[[04_实验记录/EX-20260607T131336Z-main-QXSS_A22原生字段与未来函数审计预注册|QXSS A22 原生字段审计]]
- 上游等价 formal：[[04_实验记录/EX-20260607T131209Z-main-A22N_A22原生字段等价审计预注册|A22N 原生等价 formal]]
- 上游日志/日期审计：[[04_实验记录/EX-20260607T152511Z-main-EKZ8_A22原生字段日志与未来函数二次审计|EKZ8 日志/日期审计]]
- 产生的决策：[[05_研究决策/DEC-20260607T185223Z-main-HH4B_A22原生forward shadow边界通过后观察决策|A22 原生 forward/shadow 边界通过后观察决策]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：A22 已经能用原生字段复现结果后，能不能安全进入默认关闭观察和 forward/shadow 边界验证。

我们原本预计：native A22 live 组应复现 A22N 的 native 结果；shadow_on/off 组应只多写 A22 shadow 日志，不改变交易产物；所有配置必须显式互斥 A13/A22。

实际看到：12/12 formal 已完成，strict summary 的 10 个门禁全部为 true。`native_a22_live` 四段 final/MDD/trades/fee 和关键 hash 与 A22N native 完全一致；`a20_unbudgeted_shadow_on/off` 四段 orders/trades/equity/positions/subportfolio hash 全一致，`shadow_on_orders_changed=0`；4 个 `double_on_guard` 都能识别 A13+A22 双开。

这说明：A22 native 已通过工程 forward/shadow 边界验证，可以进入默认关闭观察或更严格 forward 样本验证。

但还不能说明：QTFV 不是收益优越性实验，也不是最终未来函数裁决；默认策略仍保留 hard5，A22 不因本实验直接生产放行。

下一步要做：保留 A22 shadow 默认关闭，继续做更贴近真实 forward 的观察样本或生产前门禁；若未来想启用 A22，仍需单独决策卡。

## 2. 研究背景

这个实验属于 `RD-20260605T133318Z-main-H6V3`。K3AC 已把 score-cap 主线切回 A22 cap70；QXSS 发现旧 A22 实际复用了 A13 字段；A22N 证明 legacy A13 字段表达和 native A22 flat cap70 完全等价；EKZ8 又补齐日志语义和可见日期顺序审计。

剩余阻塞是工程边界：A22 native 不能直接进入生产，需要先证明两件事：

- live 配置能用原生 A22 字段可见复现 A22N 结果。
- shadow 配置在默认关闭观察状态下只写日志，不改变 orders/trades/equity/positions。

本实验不寻找新收益，只做 A22 native 的 forward/shadow 边界验证。

## 3. 实验前假设

在四个固定分段中，A22 native live 可复现 A22N native 行为；A22 shadow_on/off 可证明默认关闭观察不改变交易产物，并且日志、manifest 和可见日期顺序满足 strict gate。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：live 组四段 final/MDD/trades/fee 与 A22N native 对应分段完全一致；shadow_on/off 四段关键交易产物 hash 完全一致。
- 交易行为：shadow_on 比 shadow_off 只多 `R010-A22 SHADOW` 日志，orders/trades/equity/positions/subportfolio_equity 不变；live 组只出现 A22 live 指纹，不出现 A13 live 指纹。
- 风险表现：本实验不新增收益优势判断；只复核工程边界。2025_20260519 若与 A22N 不一致则失败。
- 分段表现：2020_2021、2022_2023、2025_20260519 应出现 A22 触发或 shadow 触发记录；2024 可作为零触发负控。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| A22N `native_a22_cap70` | live 复现基准 | `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_hot_score_budget/EX-20260607T131209Z-main-A22N/formal/native_a22_cap70/` |
| `native_a22_live` | 原生 A22 live 可见复现组 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/native_a22_live/` |
| `a20_unbudgeted_shadow_off` | shadow 隔离对照，A20 放行但不启用 A22 live/shadow | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/a20_unbudgeted_shadow_off/` |
| `a20_unbudgeted_shadow_on` | 默认关闭 A22 shadow 观察组，不改变交易 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/a20_unbudgeted_shadow_on/` |
| `double_on_guard` | 静态负控，仅检查 A13/A22 双开会被 strict 拒绝 | 不作为 formal 回测组 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- shadow_on/off 完全一致，可能只是 A22 shadow 没有触发或日志没有覆盖关键字段，而不是隔离证明充分。
- live 复现 A22N，可能只是再次跑同一历史样本，不能替代真正 forward 样本。
- A20 unbudgeted shadow 基线不是 hard5 真实生产路径；它只用于观察 A22 预算建议，不代表 hard5 已可安全启用 A22 shadow。
- 双开 A13/A22 若没有被静态 gate 拦住，可能出现 legacy 先应用、native 后覆盖的顺序干扰。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 任一 formal 配置没有显式互斥 A13/A22。
- `native_a22_live` 四段 final/MDD/trades/fee 或关键 hash 与 A22N native 不一致且不能归因于日志外非策略差异。
- `a20_unbudgeted_shadow_on` 与 `a20_unbudgeted_shadow_off` 任一分段 orders/trades/equity/positions/subportfolio_equity 归一化 hash 不一致。
- shadow_on 没有输出 `R010-A22 SHADOW` 日志，或 shadow 日志缺少 `observe_date/signal_date/trigger/suggested_cap/orders_changed_by_shadow` 等核心字段。
- 任一可解析日志出现 `signal_date > trade_date` 或 `signal_date > observe_date`。
- run log 缺失、`exit_status` 非 0、manifest 缺少 config sha 或出现 `Traceback/ERROR/SystemError`。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过本实验边界 | `shadow_date_order_ok_4of4=true`；四段 shadow 可解析记录均未出现 `signal_date > trade_date` 或 `signal_date > observe_date` |
| 信号生成和成交价格不存在同 bar 泄漏 | 未做最终裁决 | 本实验只检查可见日期边界；成交模型继承平台，不能替代全策略未来函数最终审计 |
| 股票池或 ETF 池不存在未来成分泄漏 | 继承上游 | 不改 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | A22 不引入财务、宏观或估值字段 |
| Shadow 或观察信号未被当成默认交易信号 | 通过本实验边界 | `shadow_on_off_trade_outputs_match_4of4=true`，且四段 `shadow_on_orders_changed=0` |

负控或错位检查：

- 2024 零触发负控：通过。2024 `shadow_on_triggers=0`，shadow_on/off 产物一致。
- `double_on_guard` 静态负控：通过。四段 guard 均为 `a13_enabled=true`、`a22_live_enabled=true`、`guard_detected=true`，且不进入 formal 回测组。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 不调参；只跑三组四段加一个静态双开负控 |
| 样本内、验证集、样本外划分清楚 | 部分 | 固定四段；2025_20260519 作为近端 forward-like 边界，不声明真实样本外 |
| 邻近参数敏感性合理 | 不适用 | 工程边界验证，不做阈值邻域 |
| 成本、滑点或换手扰动已检查 | 继承 K3AC/A22N | 本实验看交易产物隔离，不看收益优势 |
| 已做消融或负控 | 通过本实验边界 | shadow_on/off 交易产物完全一致；double_on_guard 四段均被识别 |
| 未只报告最优结果 | 通过 | 全部 12 个 formal 回测和 4 个静态 guard 均进入 strict summary |

证据等级：`L1_engineering_shadow_boundary_strict_pass`。只支持默认关闭观察和下一步更严格 forward/shadow 研究，不支持生产 promote。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called_completed_with_one_errored`

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260607T154000Z-main-A22FS-ENTRY | Archimedes | SUBTASK-20260607T154000Z-main-A22FS_子查_A22_native_forward_shadow脚本边界 | gpt-5.3-codex-spark | 2026-06-07T15:40:00Z | 平台 forward/shadow/observe 脚本、A22/A22N 脚本和策略源码 | 无 | 只读检索 | context length exceeded，未形成可用交付物 | 无结论可采纳 | 主控关闭调用并改用更小任务重试 | 不影响研究判断，只作为失败调用记录 |
| SUB-20260607T154800Z-main-A22FS-MIN | Pascal | SUBTASK-20260607T154800Z-main-A22FS_子查_最小脚本清单 | gpt-5.3-codex-spark | 2026-06-07T15:48:00Z | `scripts/research` 中 A22/A22N 与 shadow/forward 相关脚本 | 无 | 只读检索 | 确认 A22N 链路可复用为模板；B5/THEME shadow 运行脚本不是 drop-in；forward/shadow 后处理脚本可借鉴；最小 gate 应同时覆盖 A22N 等价和 EKZ8 日志/日期审计 | 旧 shadow 脚本硬编码旧实验路径；后处理脚本只读既有产物 | 主控采纳脚本边界建议，并按最小专用脚本实现 QTFV | 支持新建 QTFV 专用生成/运行/汇总脚本，不支持直接复用旧 shadow 脚本跑 formal |
| SUB-20260607T183800Z-main-QTFV-VERIFY | Planck | SUBTASK-20260607T183800Z-QTFV-SUMMARY-CHECK | gpt-5.3-codex-spark | 2026-06-07T18:38:00Z | QTFV `summary.json`、`live_vs_a22n.csv`、`shadow_on_off_hash.csv`、`guard_audit.csv` 和研究库 QTFV 文档 | 无 | 只读复核 | 确认 `all_gates_pass=true` 且 10 个 gates 全 true；live 四段 final/MDD/trades 与 A22N 完全一致；shadow_on/off 四段 5 类 hash 全一致且 orders_changed 为 0；guard 四段均识别 A13+A22 双开 | 未做最终研究决策，也未判断未来函数最终通过 | 主控采纳为 formal 收口复核证据，并限制结论为工程边界通过 | 支持 QTFV 写为 `completed / strict_pass`，不支持生产 promote |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/
${QUANT_PLATFORM_ROOT}/scripts/research/generate_qtfv_a22_native_forward_shadow_configs.py
${QUANT_PLATFORM_ROOT}/scripts/research/run_qtfv_a22_native_forward_shadow.sh
${QUANT_PLATFORM_ROOT}/scripts/research/summarize_qtfv_a22_native_forward_shadow.py
${QUANT_PLATFORM_ROOT}/src/strategies/research/etf_dual_pool_r010b_action_ablation.py
```

### 运行命令

```bash
cd /mnt/e/qp_v1_4_0
PYTHONIOENCODING=utf-8 python3 -m py_compile scripts/research/generate_qtfv_a22_native_forward_shadow_configs.py scripts/research/summarize_qtfv_a22_native_forward_shadow.py
PYTHONIOENCODING=utf-8 python3 scripts/research/generate_qtfv_a22_native_forward_shadow_configs.py
DRY_RUN=1 bash scripts/research/run_qtfv_a22_native_forward_shadow.sh
PYTHONUNBUFFERED=1 bash scripts/research/run_qtfv_a22_native_forward_shadow.sh
PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_qtfv_a22_native_forward_shadow.py --strict
```

### 可见进度与日志

- 是否过程可见：是，run 脚本必须 `PYTHONUNBUFFERED=1` 并用 `tee` 写每个配置的 run log。
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/logs/formal/`
- 查看进度命令：`Get-ChildItem ${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/logs/formal/ -Recurse`
- 异常判断：任一 run log 无 `exit_status=0`、任一 summary 缺失、strict gate 失败则本实验失败。
- 后台回测豁免：不后台运行。

```text
如后台或静默运行，必须写：
后台回测豁免：<原因>
进程标识：<pid或任务名>
日志路径：<path>
查看进度：<command>
停止方式：<command>
预计耗时：<duration>
```

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/logs/formal/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/summary.json
```

## 12. 实际观察

预执行检查通过：

- 已读平台 `AGENTS.md` 和 `docs/AGENT_RULES.md`。
- 已新增默认关闭参数 `r010a22_hot_score_budget_shadow_enabled=False`。
- 已新增 `【R010-A22 SHADOW】` 日志函数；该函数只写日志，不修改 `final_targets`、`weights` 或订单。
- 已完成 WSL `py_compile`：策略源码、配置生成器和汇总脚本均通过。
- 已生成 12 个 formal 配置和 4 个 double-on guard 配置。
- run 脚本 `DRY_RUN=1` 正常列出 3 variants × 4 segments。
- 字段抽检通过：`native_a22_live` 为 A13=false/A22Live=true/A22Shadow=false；`a20_unbudgeted_shadow_on` 为 A13=false/A22Live=false/A22Shadow=true；`double_on_guard` 为 A13=true/A22Live=true/A22Shadow=false 且不在 run 脚本 formal variants 中。

正式 formal 结果：

- 12/12 formal 回测完成，run log 最新根路径为 `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/logs/formal/20260607T155359Z/`。
- strict summary `all_gates_pass=true`，10 个 gates 全部为 true：12/12 运行齐全、12/12 配置字段正确、12/12 run log 正常、12/12 manifest config sha 匹配、native live 4/4 复现 A22N、shadow_on/off 4/4 交易产物一致、shadow 4/4 订单未改变、shadow 4/4 日期顺序通过、触发画像 3+1 通过、double-on guard 4/4 检出。
- `native_a22_live` 四段与 A22N baseline 完全一致：
  - 2020_2021：final `225931.41`，MDD `-20.8378%`，trades `585`。
  - 2022_2023：final `138583.63`，MDD `-24.3881%`，trades `463`。
  - 2024：final `167005.22`，MDD `-26.9936%`，trades `281`。
  - 2025_20260519：final `350312.39`，MDD `-14.9040%`，trades `506`。
- `a20_unbudgeted_shadow_on/off` 四段 orders/trades/equity/positions/subportfolio_equity 归一化 hash 全一致，`shadow_on_orders_changed=0`。
- shadow 记录数和触发数：2020_2021 `486/9`，2022_2023 `484/6`，2024 `242/0`，2025_20260519 `330/34`。
- `double_on_guard` 四段均存在并被识别为 A13+A22 双开；guard 不进入 formal 回测组。
- 汇总命令 stdout 末尾出现 WSL localhost 提示的编码噪声，不影响 JSON 解析、strict exit code 或平台 run log 结果。

## 13. 支持证据

- `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/summary.json`：`all_gates_pass=true`。
- `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/live_vs_a22n.csv`：四段 final/MDD/trades/fee 与 A22N native 全一致，关键 hash 全一致。
- `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/shadow_on_off_hash.csv`：shadow_on/off 四段交易产物 hash 全一致，`orders_changed=0`。
- `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/guard_audit.csv`：四段双开 guard 均被识别。
- Planck 子代理只读复核确认 summary、live reproduction、shadow hash 和 guard 证据一致，且明确不做最终研究决策。

## 14. 反对证据

- 本实验不是收益增强实验，不能证明 A22 比 hard5 更适合生产默认。
- 本实验仍使用固定历史四段；2025_20260519 只是近端 forward-like 边界，不是真实未来样本。
- 本实验只检查可见日期边界和 shadow 隔离，不替代成交模型、数据源或组合层完整未来函数审计。
- shadow_on/off 使用 A20 unbudgeted 路径观察 A22 预算建议，不等同于 hard5 生产路径。

## 15. 偏差诊断

当前偏差：原计划“复用现成 forward/shadow 脚本”不可行。Pascal 和主控源码检查都确认，B5/THEME shadow run 脚本硬编码旧实验路径，不能 drop-in 到 A22；A22 源码也没有 shadow-only 开关。因此主控新增了 A22 专用默认关闭 shadow 日志和 QTFV 专用脚本。

结果偏差：本实验的结论空间比收益实验更窄。即使 strict 通过，也只能说明 A22 native live/shadow 工程边界干净，不能把历史四段上的 A22 cap70 表现直接升级成生产切换。

## 16. 研究判断

建议状态：`completed / engineering_strict_pass`。预注册上限为 `observe` 或 `engineering_pass`，不得直接写 `promote`。

理由：QTFV 已完成 12/12 formal 和 strict summary，A22 native live 能复现 A22N，shadow_on/off 不改变交易产物，双开 guard 可被静态检出。这个结果解除 A22 原生字段进入默认关闭观察或更严格 forward/shadow 样本验证的工程阻塞；默认 hard5 仍保留。

## 17. 下一步

1. 保留 A22 shadow 默认关闭；如进入观察，只记录建议预算和触发状态，不改订单。
2. 若要从 `engineering_pass` 推进到交易候选，需要新开生产前决策卡或 forward-like formal，覆盖默认 hard5 路径、真实执行边界和完整未来函数审计。
3. 不因 QTFV 通过而修改默认 hard5，也不新开 A23 换手约束扩展。
