---
type: 实验记录
ex_id: EX-20260801T155629Z-main-NDDW
rd_id: RD-20260731T090245Z-main-KLCN
status: draft
stage: preregistered
owner: main
created_at: 2026-08-01T15:56:29Z
updated_at: 2026-08-01T16:50:40Z
strategy_id:
module_type:
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: '${THINKTANK_PROJECT_ROOT}'
config_paths:
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/candidate_extraction_isolated_execution_plan.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/candidate_extraction_isolated_execution_receipt.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/prompt_v0.3.md'
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/news_extraction.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/tests/fixtures/candidate_extraction_synthetic_v1.json'
  - '${THINKTANK_PROJECT_ROOT}/src/thinktank/intelligence/candidate_extraction_isolated_runner.py'
  - '${THINKTANK_PROJECT_ROOT}/src/thinktank/intelligence/candidate_extraction_omp_sdk_adapter.ts'
  - '${THINKTANK_PROJECT_ROOT}/tests/test_intelligence_candidate_extraction_isolated_runner.py'
result_paths: []
summary_paths:
  - '${THINKTANK_PROJECT_ROOT}/docs/架构/低成本候选抽取隔离单回合执行.md'
quality_gate: implementation_ready_pending_independent_release_audit
subagent_call_ids: [SUB-20260801T154845Z-main-C14A]
subagent_exemption:
tags:
  - 个人智库
  - 低成本模型
  - DeepSeekV4Flash
  - OMP
  - 单回合
  - 环境隔离
  - 失败关闭
---

# OMP隔离环境单回合计数与唯一JSON合同修订

## 关联链接

- 研究方向：[[02_研究方向/RD-20260731T090245Z-main-KLCN_个人智库消息面结构化与长期记忆系统|个人智库消息面结构化与长期记忆系统]]
- 策略档案：
- 来源文献或灵感：[[04_实验记录/EX-20260801T142253Z-main-2KTE_低成本候选抽取受控执行与失败留痕合同|C13低成本候选抽取受控执行]]
- 产生的决策：
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：把OMP放进不含本机Codex/MCP配置的隔离环境后，是否能把一次合成抽取真正限制为一个模型请求、零工具调用，并把输出格式是否合格作为独立门禁。  
我们原本预计：C14唯一运行只有一个OMP会话、一个assistant请求、一个`stop`终态和零工具事件；是否输出唯一JSON对象另行裁决。  
实际看到：C14尚未执行。预注册前的回顾审计已确认C13是一个OMP会话内5个assistant请求和4次`mcp__node_repl_js`调用，旧收据中的`model_call_count=1`实际只计了进程/会话，且只保存最后一回合usage。C14实现后的零模型探针已在严格环境允许名单下创建受限SDK Session，四份工具清单、MCP、扩展和LSP均为0。  
这说明：C13仍是有效的失败留痕，但“单次模型调用”和约`0.00094`美元总成本的旧解释必须更正；五回合账单字段合计约`0.008145984`美元。  
但还不能说明：隔离环境一定能让DeepSeek直接输出合法JSON，也不能说明真实中文新闻抽取质量、泛化能力或生产成本。  
下一步要做：先完成独立放行审计和全库门禁；全部通过后才编译唯一写一次计划并执行一次固定合成运行，不重试。  

## 2. 研究背景

本实验属于个人智库的低成本候选抽取线，是C13的独立协议修订，不修改C13工件、不清理C13围栏，也不把C13改判成功。

C13冻结事件流`sha256:61beb1b0cbac07458467d91ccc05b0b34df7be91134df2cf5c00215fe7c21ae7`包含5个assistant `message_end`，停止原因为4次`toolUse`和1次`stop`；4组`tool_execution_start/end`调用了本机Codex配置自动发现的`mcp__node_repl_js`。OMP 17.2.1本机源码把assistant `message_end`定义为assistant request计数来源，故本实验把“OMP会话数”“模型请求数”“工具调用数”和“最终回答数”拆开记录。

为只改变一个关键变量，C14继续使用C13相同的固定合成夹具、`prompt_v0.3`、新闻抽取Schema、DeepSeek V4 Flash和`thinking=high`。模型输入必须保持`sha256:c128ed283fae7005f1b6b7beb6903f4cd7e04ead54c6f6063432e0530f263a9b`；连同C13原显示文件名、空行和末尾换行组成的完整user消息必须保持`sha256:25f2d3d23d1261ec2414c47b956b6096456976c8ea66a40c142d807da6bb1aca`。Prompt、夹具和输出Schema哈希分别保持`sha256:a8f8a91d2b036894b9665de86ce79d7a00fe80c0aad8c5c075b40b39808a1d51`、`sha256:2622cdab24196cf237ebe96a1cd74fce071105cb15d69b4cf3fe8b2aedab577d`和`sha256:efe43fad8b69e75e8c5ed42a3c9447362cf0cd90f3251c4178b88d1a0117fd92`。

预注册前的临时只读探针只证明：把`HOME`、`USERPROFILE`、`CODEX_HOME`和`PI_CODING_AGENT_DIR`指向全新目录后，OMP仍可解析`deepseek-v4-flash`且不再出现MCP bridge提示。实现后又用正式TypeScript适配器完成两次`--preflight-only`探针，其中一次先清空全部子进程环境再只注入允许名单；两次均看到`active/enabled/all/selected_mcp=[]`、`mcp_manager_present=false`、`extension_count=0`、`lsp_server_count=0`且stderr为空。所有探针都没有执行`session.prompt()`，不计入正式结果。

## 3. 实验前假设

若C14在运行前把用户目录、Codex目录和OMP Agent目录全部重定向到运行专属空目录，并通过OMP 17.2.1 SDK显式设置`toolNames=[]`、`restrictToolNames=true`、`enableMCP=false`及禁用扩展/LSP/IRC，再以环境变量允许名单发送与C13字节相同的完整user消息，则唯一运行应形成恰好一个assistant请求、零工具调用的可重放证据；唯一JSON和候选语义能否通过作为与运行隔离相互独立的次级门禁。

## 4. 实验前预测

如果假设为真，应该看到：

- 主指标：`omp_session_count=1`、`provider_request_count=1`、`turn_start_count=turn_end_count=1`、assistant `message_end=1`且`stopReason=stop`。
- 工具隔离：assistant内容中的`toolCall`为0，`tool_execution_start/end=0`，`toolResult message_end=0`；任一非零即失败。
- 环境隔离：`HOME`、`USERPROFILE`、`CODEX_HOME`、`PI_CODING_AGENT_DIR`、`APPDATA`和`LOCALAPPDATA`全部位于本次运行沙箱；`NODE_REPL_*`、`CODEX_THREAD_ID`及未允许的`MCP_*`不传给子进程。收据只记录变量名和隔离路径，不记录密钥值。
- 输入等价：模型输入、完整user消息、Prompt、夹具和输出Schema必须等于第2节冻结哈希；C13事件和收据只作只读基准，不进入模型上下文。
- 调用预算：一个运行ID、一个OMP进程、零格式重试；每个assistant请求的usage逐项聚合，总账单字段不高于`0.01`美元。缺失usage或成本字段视为计量门禁失败。
- 输出门禁：原始assistant文本去除首尾空白后必须能直接解析为单个JSON object，不接受解释、Markdown围栏、数组、标量或清理修复。该门禁可以在主运行隔离通过时独立失败。
- 候选门禁：只有输出门禁通过后才校验固定元数据、最多5条Claim/Relation、Unicode code point半开区间、逐字证据和禁用`independently_confirms`；仍保持`metric_eligible=false`。
- 权限边界：事实批准、分析上下文、长期记忆、数据库、行动和交易权限全部为false，所有下游写入计数为0。
- 无交易行为、风险收益或分段表现；本实验最高只提供L1工程证据。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| C13冻结事件流 | 已知污染基准：5个assistant请求、4次工具调用 | `hot://intelligence/candidate_extraction_runs/v1/CERUN-20260801T150913Z-3B39011C/events/attempt-001.jsonl` |
| C13模型输入 | 配对输入字节基准 | `hot://intelligence/candidate_extraction_runs/v1/CERUN-20260801T150913Z-3B39011C/inputs/model_input.json` |
| C13失败收据 | 验证旧`model_call_count`与最终usage口径，不修改原件 | `hot://intelligence/candidate_extraction_runs/v1/CERUN-20260801T150913Z-3B39011C/execution_receipt.json` |
| 单回合合成事件正控 | 验证事件解析器只接受一个`stop`终态 | 新增测试内合成JSONL，不调用模型 |
| 工具泄漏、第二回合、围栏与非object负控 | 验证失败关闭和零清理 | 新增测试内合成JSONL/文本，不调用模型 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 同一输入命中供应商前缀缓存，使本次更快或更便宜；因此只比较请求数和工具隔离，不把时延/成本差异解释为模型能力提升。
- 没有工具后模型可能无法稳定计算证据偏移，导致唯一JSON或语义失败；这不反证环境隔离，只反证当前无工具抽取合同。
- OMP、Agent Core或模型目录在编译计划后变化；运行前必须重算全部依赖哈希，任何漂移直接拒绝调用。
- MCP工具可能由显式命令行或供应商侧注入而非HOME发现；事件负控仍会使运行失败，不能据零工具先验放宽检查。
- 一个合成样本偶然服从格式，不能外推真实新闻、其他长度、其他中文体裁或长期稳定性。

## 7. 证伪条件

出现以下任一情况，主假设不通过：

- `provider_request_count != 1`、assistant终态不唯一、最终停止原因不是`stop`，或`turn_start/turn_end`不各为1。
- 出现任何`toolCall`、`tool_execution_start/end`或`toolResult`，即便工具结果有助于生成正确候选。
- 任一隔离目录不在运行根下、运行前非空、禁用父环境变量被继承，或收据/日志泄露密钥值。
- 输入、Prompt、夹具、Schema、runner、OMP身份或冻结事件语义依赖在计划后漂移。
- 启动第二个运行ID、发生格式重试或在失败后重跑同一实验。
- usage未覆盖所有assistant请求，聚合成本缺失或超过`0.01`美元。

分层裁决：主隔离合同通过但输出不是唯一JSON时，记录`runtime_passed_output_failed`，不重试；主隔离和输出均通过但候选语义失败时，记录`runtime_passed_candidate_failed`；三层都通过才允许`status=succeeded`。任一结果仍不批准事实、记忆、数据库、行动或交易。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 不适用 | 固定`.invalid`合成文本，不作真实时序结论 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 不生成交易信号或订单 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 无标的池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 无真实财务或宏观数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 全部行动与交易权限冻结为false |

负控或错位检查：

- C13事件流作为已知工具泄漏负控；合成第二回合、工具事件、围栏、数组、路径逃逸和环境变量泄漏均必须失败。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 模型、thinking、输入、Prompt、Schema、时限、一次调用与零重试全部固定 |
| 样本内、验证集、样本外划分清楚 | 通过 | 本轮仅合成协议样本，明确不计入真实能力指标 |
| 邻近参数敏感性合理 | 不适用 | 不扫Prompt、模型、thinking或阈值 |
| 成本、滑点或换手扰动已检查 | 不适用 | 仅登记所有请求聚合成本，无交易成本 |
| 已做消融或负控 | 待执行 | C13污染基准与离线事件/环境负控 |
| 未只报告最优结果 | 通过 | 唯一正式运行无论成功失败都封存，不重试 |

证据等级：最高`L1`，且只覆盖运行隔离、计数、格式和失败留痕合同。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`；C14A只读故障审计已完成并由主控复核。实现完成后还需独立C14B放行审计，未通过前禁止真实调用。

子代理豁免：

```text
如未调用，必须写：子代理豁免：<原因>；主控：<agent>；时间：<UTC时间>
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260801T154845Z-main-C14A | Anscombe | SUBTASK-C14-OMP-EVENT-SEMANTICS-AUDIT | inherited | 2026-08-01T15:48:45Z | C13冻结事件、观察、原文、收据与本机OMP 17.2.1源码/帮助；禁止真实新闻、Gold和holdout | 无 | 只读解析与源码检索；禁止模型调用 | 确认C13为5个assistant请求、4次MCP工具调用；旧收据把会话误作调用，只取最后usage；CLI `--no-tools`仅关闭内置工具，旧解析器还误伤正常user/toolResult终态 | 请求计数、成本总计、MCP环境污染和事件角色语义 | 主控采纳：新建v2协议，改用SDK硬限制并拆分运行/输出/语义三层状态 | 阻止沿用C13 runner，要求C14B再审计后才可放行 |

台账行：C14A已写入`01_台账/子代理调用台账.csv`；C14B完成后追加。

## 11. 执行记录

### 平台配置

```text
项目：${THINKTANK_PROJECT_ROOT}
模型：deepseek/deepseek-v4-flash
thinking：high
运行时：Bun 1.3.14 + OMP SDK 17.2.1；执行前复核可执行文件、package.json、sdk.ts和print-mode.ts哈希
输入：固定SYNTH-C13-001合成夹具；模型输入和完整user消息均与C13字节一致；禁止C12、live、unseen、Gold、qrels、curation、event_nodes和formal holdout
隔离：运行专属空HOME/USERPROFILE/CODEX_HOME/PI_CODING_AGENT_DIR/APPDATA/LOCALAPPDATA；子进程环境允许名单；SDK工具四清单必须全空，MCP/扩展/LSP均为0
预算：一个运行ID、一个适配器进程、一个OMP SDK Session、恰好一个assistant请求、零工具、零格式重试、300秒SDK绝对期限、360秒进程时限、聚合账单字段上限0.01美元
权限：事实、分析上下文、记忆、数据库、行动和交易全部关闭
```

### 运行命令

```powershell
$env:PYTHONPATH = (Join-Path (Get-Location) 'src')
python -m thinktank.intelligence.candidate_extraction_isolated_runner compile <冻结参数>
python -m thinktank.intelligence.candidate_extraction_isolated_runner run --plan-uri <唯一计划> --config .thinktank.local.json
python -m thinktank.intelligence.candidate_extraction_isolated_runner verify --receipt-uri <唯一收据> --config .thinktank.local.json
```

### 可见进度与日志

- 是否过程可见：是；前台执行，主控按工具返回持续同步，不启动后台任务。
- 日志路径：运行前由唯一`output_uri`确定，事件、stderr、runner observation、原文、解析结果和收据分目录写一次。
- 查看进度命令：无需后台日志；若工具调用超过10秒，主控使用等待接口持续跟踪。
- 异常判断：第二回合、任何工具事件、超时、非零退出、事件异常、格式/语义错误或依赖漂移均失败关闭。
- 后台回测豁免：不适用，本实验不是回测且不后台执行。

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
未执行。计划前缀：hot://intelligence/candidate_extraction_isolated_plans/v2/
运行前缀：hot://intelligence/candidate_extraction_isolated_runs/v2/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| OMP会话数 | C13=1 | 未执行 | 待执行 | 区分进程/会话与请求 |
| assistant请求数 | C13=5 | 预测=1 | 待执行 | 每个assistant `message_end`计一次请求 |
| 工具调用数 | C13=4 | 预测=0 | 待执行 | 任一非零失败 |
| 聚合账单字段 | C13=`0.008145984`美元 | 预测不高于`0.01`美元 | 待执行 | 聚合所有assistant请求，不只取最终回合 |
| 唯一JSON | C13=失败 | 未预设必须成功 | 待执行 | 与运行隔离独立裁决 |
| 下游写入 | C13=0 | 预测=0 | 待执行 | 不扩权 |

## 13. 支持证据

- C14专项测试当前`9/9`通过：覆盖正常user终态、多assistant累计计数/成本、工具事件与toolResult、禁用环境变量、运行/输出分层、状态优先级、Schema和UTF-8。
- 严格环境`--preflight-only`探针退出码0、stderr为空；`active/enabled/all/selected_mcp=[]`，MCP manager不存在，扩展和LSP均为0。
- 完整C13 user消息哈希已独立回算为`sha256:25f2d3d23d1261ec2414c47b956b6096456976c8ea66a40c142d807da6bb1aca`，C14适配器保留相同显示文件名、空行和末尾换行。
- 以上均未发起模型请求，只支持实现可执行性，不是正式实验结果。

## 14. 反对证据

- 待唯一正式运行后填写；任何不符合预测的事件和原始文本必须完整保留。

## 15. 偏差诊断

尚未执行。C13已知偏差是把一个OMP会话误记为一个模型调用，并把最后一回合usage误作总usage；本实验禁止继承这两个口径。实现检查还发现C13文件包装器包含额外空行和末尾换行，现已在正式调用前纳入完整user消息哈希门禁，不构成结果后修订。

## 16. 研究判断

建议状态：`preregistered`，尚无路线判断。

理由：只有在预注册、实现、负控、专项测试、全库门禁和独立审计均通过后，才允许唯一正式合成运行；本实验最高只能`observe`或`revise`，不得`promote`。

## 17. 下一步

先完成C14B独立放行审计、专项与全库门禁，不调用模型。若全部通过，编译唯一写一次计划并执行唯一合成运行，按三层状态封存；失败不重试。即使三层全通过，下一次真实新闻实验仍须等待未来新C9/C11产生未见URL并由独立流程确认正文，再另开支持`unseen_prospective`的协议，不能直接复用C14合成成功。
