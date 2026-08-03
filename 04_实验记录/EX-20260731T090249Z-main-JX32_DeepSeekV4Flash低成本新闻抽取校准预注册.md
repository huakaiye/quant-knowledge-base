---
type: 实验记录
ex_id: EX-20260731T090249Z-main-JX32
rd_id: RD-20260731T090245Z-main-KLCN
status: draft
stage: development_smoke
owner: main
created_at: 2026-07-31T09:02:49Z
updated_at: 2026-07-31T16:33:45Z
strategy_id:
module_type:
decision_ids:
  - DEC-20260731T092724Z-main-7MPL
  - DEC-20260731T163828Z-main-4RG9
lit_ids: []
idea_ids: []
platform_project: '${THINKTANK_PROJECT_ROOT}'
config_paths:
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/eval_config.yml'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/prompt_v0.1.md'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/prompt_v0.2.md'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/prompt_v0.3.md'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/prompt_v0.4.md'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/review_prompt_v0.1.md'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/review_prompt_v0.2.md'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/review_prompt_v0.3.md'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/GOLD_REVIEW_PROTOCOL.md'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/corpus_manifest.jsonl'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/gold_labels.jsonl'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/coverage_expectations.jsonl'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/coverage_match_hints.jsonl'
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/item_review_expectations.jsonl'
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/news_extraction.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/semantic_review_input.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/semantic_review.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/coverage_expectation.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/coverage_match_hints.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/item_review_expectation.schema.json'
result_paths:
  - 'hot://evaluation/EX-20260731T090249Z-main-JX32/'
  - 'hot://reviews/EX-20260731T090249Z-main-JX32/'
summary_paths:
  - '${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/README.md'
  - '${THINKTANK_PROJECT_ROOT}/docs/架构/抽取与验证流水线.md'
  - '${THINKTANK_PROJECT_ROOT}/docs/架构/B2语义复核契约.md'
quality_gate: development_cross_b2_4_valid_0_gate_passed_legacy_replay_no_adoption
subagent_call_ids:
  - SUB-20260731T085338Z-main-D4F7
  - SUB-20260731T085842Z-main-N6C3
  - SUB-20260731T112513Z-main-CNCT
  - SUB-20260731T112513Z-main-CORP
  - SUB-20260731T112513Z-main-USOF
  - SUB-20260731T125231Z-main-GRCP
  - SUB-20260731T133629Z-main-GRCL
  - SUB-20260731T140112Z-main-B2CA
  - SUB-20260731T145354Z-main-B2CM
  - SUB-20260731T151500Z-main-B2AN
  - SUB-20260731T151500Z-main-B2AD
  - SUB-20260731T151500Z-main-B2RT
  - SUB-20260731T153000Z-main-B2AR
  - SUB-20260731T153000Z-main-B2VR
  - SUB-20260731T154900Z-main-B2EP
  - SUB-20260731T160100Z-main-MBND
  - SUB-20260731T161600Z-main-B2IE
  - SUB-20260731T163000Z-main-B2DOC
subagent_exemption:
tags:
  - 个人智库
  - 中文新闻
  - 模型评测
  - DeepSeek
  - 结构化抽取
---

# DeepSeekV4Flash低成本新闻抽取校准预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260731T090245Z-main-KLCN_个人智库消息面结构化与长期记忆系统|个人智库消息面结构化与长期记忆系统]]
- 策略档案：无，本实验不属于交易策略。
- 来源文献或灵感：当前对话中的架构讨论、官方来源拆分和五条前置合成语义探针；前置五条探针永久排除在本实验 30 篇之外，开发集另建的 3 篇显式对抗夹具按清单计入。
- 产生的决策：[[05_研究决策/DEC-20260731T092724Z-main-7MPL_个人智库采用SSD热层与HDD冷归档混合存储|SSD 热层与 HDD 冷归档混合存储]]；[[05_研究决策/DEC-20260731T163828Z-main-4RG9_DeepSeekV4Flash仅承担候选抽取并退出事实批准层|Flash只承担候选抽取并退出事实批准层]]。后一张只修订职责边界，不构成模型生产采用。
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：DeepSeek V4 Flash 能否稳定完成中文新闻和官方文件的低风险结构化抽取。  
我们原本预计：它应能处理大多数人物、机构、日期、金额、引用和 Claim，但在预测、条件和政策阶段上需要严格复核。  
实际看到：18篇开发语料已建立；中央正式文件三篇通过隔离独立复核后，v0.3首次调用3/3可解析、Claim召回8/15、已匹配模态7/8、P0为0。v0.4虽修好部分上下文证据，却有一篇在5分钟后只返回`.`，端到端仅2/3可解析、召回7/15。B2复核层随后完成跨文体回放：更正公告和语义对抗夹具共6次调用，4次结构有效；但4个有效结果的确定性 item/coverage 门禁全部失败。更正公告 item 的5条 Claim 仅1条判对，两个 coverage 都没有命中各自唯一缺失 Gold；对抗夹具还稳定重现把“文本不代表已收款”扩大成“任何人都未收款”的否定作用域错误。  
这说明：Flash可以继续承担受控候选抽取、格式化和低风险分流，但现有证据已经反证它可单独承担第二阶段语义批准。结构合法、抽取P0通过、模型自报`pass`都不等于事实正确；最终事实入库必须由确定性门禁加更高智能模型或人工复核。  
Gold审计先暴露了流程污染：首次审计误读含旧结果的README，只能记为`partial-blind`；随后另一位审计者严格按白名单完成两轮干净复核，首轮发现阻断、主控修订、第二轮确认无阻断，中央政策三篇已升级为`independently_reviewed`但尚未冻结。  
但还不能说明：它适用于其余15篇开发集、12篇封存集、长问答/PDF/OCR、生产稳定性、法律效力判断或投资决策。  
下一步要做：维持抽取Prompt v0.3为候选基线，但不再把Flash设为唯一B2；先在候选生成前冻结Item期望和Coverage hints，再用更高智能模型或人工做同集对照。其余15篇开发Gold和12篇封存集完成前，不部署会固化错误事实的PostgreSQL写入链。  

## 2. 研究背景

本实验属于个人智库基础设施方向。系统设想由低成本模型完成大量重复提取，高智能模型处理少量复杂分析；在建设采集器和数据库之前，必须先证明低成本模型在明确任务上的能力边界。

当前优先测试对象固定为：

```yaml
model: deepseek/deepseek-v4-flash
runner: omp 17.2.1
thinking: high
tools: disabled
extensions: disabled
skills: disabled
rules: disabled
session: ephemeral
output: JSON
```

前置探索边界：

- 连通性烟测成功，OMP 返回了正确 JSON。
- 五条合成语义探针只用于发现 Schema 缺口和设计门禁，不计入 30 篇结果。
- 探针曾发现一处 P1 候选错误：业绩预告的预计数被标为 `fact`，因此正式 Schema 必须显式包含 `modality`、`audit_status` 和 `supersedes`。
- 前置调用不能作为模型通过、成本优势或真实新闻泛化的证据。

## 3. 实验前假设

在固定 OMP 版本、模型、思考强度、无工具边界、Prompt 和 Schema 下，DeepSeek V4 Flash 能在 30 篇中文新闻与官方文件校准集中生成可追溯原文的候选结构，且不出现未被门禁拦截的 P0 致命错误。

## 4. 实验前预测

如果假设为真，应该看到：

- Schema：首次或最多一次格式重试后 30/30 合法；首轮与重试后结果分别报告。
- 关键字段：人物、机构、日期、金额、单位、发言归属、否定、条件和模态综合 F1 不低于 0.95。
- 证据：关键 Claim 原文 span 覆盖率不低于 0.98；不得出现无证据新增事实。
- 风险：P0 为 0；6 篇封存对抗集不得出现 P0；P1/P2/P3 分开报告。
- 稳定性：关键样本重复三次后，关键字段一致率不低于 0.95。
- 路由：需要升级高模型或人工的样本比例初步不高于 30%。
- 成本与延迟：记录每篇输入、输出、推理 token、估算成本、重试成本及 p50/p95；本轮只做测量，不用绝对价格单独判定通过。
- 分类表现：六类材料分别报告，不能用总体平均掩盖某一类崩塌。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| Gold span 标签 | 判断字段、Claim、模态和来源关系是否正确 | `${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/gold_labels.jsonl`；中央政策三篇独立复核，其余15篇单轮复核 |
| 确定性规则基线 | 判断日期、金额、否定词和 Schema 校验能完成多少工作 | 独立执行项目，路径待建立 |
| 同模型三次重复 | 检查非确定性和字段漂移 | 运行器已建立，正式重复尚未执行 |
| 后续高智能模型基准 | 比较全高模型成本及升级价值，不作为唯一 Gold | 本实验不执行，后续单独预注册 |

### 5.1 样本冻结

30 篇按六类各 5 篇组成：

1. 中国中央正式文件。
2. 部门记者会和长篇问答。
3. 地方政府、央国企、事业单位或上市主体公告。
4. 美国官方政策及其中英文转述。
5. 短消息、更正、转载和来源派生材料。
6. 否定、条件、近重复、数字变化及提示注入对抗材料。

集合划分：

- 18 篇开发校准集：允许修改 Prompt 和 Schema，但每次修改必须记录版本与理由。
- 6 篇封存正常集：首次查看输出后不得再修改本实验 Prompt、Schema 或重试规则。
- 6 篇封存对抗集：规则同上。

若查看封存结果后需要修改任何评测契约，本实验停止并新建 EX，禁止原地修到通过。训练、开发和封存必须按事件族切分，同一通稿及其转载不得跨集合。

### 5.2 最小输出契约

文档级至少包含：

```text
document_id, publisher, issuer, document_type, source_relation,
published_at, first_seen_at, content_hash, schema_version
```

Claim 级至少包含：

```text
claim_id, speaker, quoted_speaker, subject, predicate, object,
polarity, modality, condition, event_time, effective_at,
policy_status_hint, audit_status, comparison_basis,
evidence_span, confidence, needs_review, review_reasons
```

关系至少支持：

```text
quotes, reposts, translates, supersedes, contradicts,
independently_confirms, derived_from
```

`confidence` 只能用于校准，不能单独决定是否升级；升级还必须结合规则校验、证据缺失、模型重复分歧和文档类型。

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 测试材料过短、过于规整，不能代表真实世界复杂度。
- 公开旧材料被模型记忆，并非依靠输入文本完成抽取。
- 18 篇开发样本让 Prompt 对六类题型过拟合。
- 规则校验器修复了模型错误，模型本身并未达到门槛。
- OMP 固定上下文和批量策略改变了真实成本与延迟。
- Gold 标签遗漏了复杂语义，使错误没有被计分。
- 同一事件家族跨集合造成信息泄漏。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 任一未被规则或升级路由拦截的 P0：虚构行动、否定翻转、提议误判为生效、主体或金额严重错误、错误 origin 形成虚假多源确认。
- 一次格式重试后仍不能达到 30/30 Schema 合法。
- 关键字段综合 F1 低于 0.95，或关键 Claim 证据 span 覆盖率低于 0.98。
- 任一材料类别出现明显性能坍塌，即使总体平均达到门槛也不通过相应任务授权。
- 封存对抗集出现 P0，或对抗集相对正常集关键字段下降超过 10 个百分点。
- 三次重复关键字段一致率低于 0.95。
- 需要升级的样本比例超过 30%，说明当前任务边界或路由设计需修订。
- 发现封存集泄漏、后验修改评测契约或 Gold 无法追溯原文，本次结果作废。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 每篇保存发布时间与首次发现时间 | 待检查 | `corpus_manifest.jsonl` |
| 模型只看到该知识时点允许的正文和元数据 | 待检查 | 运行 manifest 与输入哈希 |
| 后续报道不得回写成当时已经知道 | 待检查 | 按事件族和 `known_at` 审计 |
| 封存集不参与 Prompt 或 Schema 调整 | 待检查 | Prompt/schema 哈希与运行时间 |
| 模型无工具、无搜索、无外部资料补充 | 待检查 | OMP 参数和 JSON 事件日志 |
| 本实验输出不得进入交易或最终事实状态 | 待检查 | 仅写候选结构，`needs_review=true` |

负控或错位检查：

- 最小差异样本只改变“尚未/已经”、金额、日期、币种或百分点，检查字段是否随原文正确变化。
- 将记者问题与发言人回答交换位置，检查来源归属是否仍正确。
- 同一通稿以官网、转载和媒体摘要三种形式出现，检查是否错误增加独立来源数。
- 正文加入要求模型忽略系统规则的恶意句子，检查是否发生提示注入。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 模型、thinking、最大重试次数已预注册 | 待检查 | `eval_config.yml` |
| 18 开发、6 正常封存、6 对抗封存划分清楚 | 待检查 | `corpus_manifest.jsonl` |
| Prompt 与 Schema 版本和哈希固定 | 待检查 | `run_manifest.json` |
| 三次重复运行检查非确定性 | 待检查 | 原始输出与评测报告 |
| 已做最小差异、来源派生和提示注入负控 | 待检查 | 对抗样本标签 |
| 全部类别和失败样本均报告 | 待检查 | `evaluation_report.json` |

证据等级：当前 `L0`；30 篇完成且门禁通过最多升级为 `L1` 校准证据，不能直接成为生产候选。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260731T085338Z-main-D4F7 | Curie | SUBTASK-20260731T085338Z-main-Q8V2_子查_OMP模型入口核对 | inherited | 2026-07-31T08:53:38Z | OMP 帮助、模型目录、公开安装元数据 | 无 | Get-Command、omp --version、omp models find | 只确认本机入口和安全参数，不评价能力 | `pi` 与 `omp` 易混用；模型只声明 high/max | 主控复核并实际完成连通性调用 | 固定使用 `omp 17.1.3`、完整 selector 和 `thinking=high` |
| SUB-20260731T085842Z-main-N6C3 | Curie | SUBTASK-20260731T085842Z-main-R9H4_子查_DeepSeek预注册门禁审计 | inherited | 2026-07-31T08:58:42Z | 研究模板、frontmatter、方法论、三张台账和工具 | 无 | Get-Content、Select-String、Get-ChildItem | 只审计格式和门禁，不判断路线状态 | 30 篇过小、执行项目根未定义、模板与 schema 有轻微漂移 | 主控采纳样本冻结、P0 和不可外推边界 | 形成当前预注册，不产生采用决策 |
| SUB-20260731T112513Z-main-CNCT | Curie | SUBTASK-DEVSET-CN-CENTRAL | inherited | 2026-07-31T11:25:13Z | 中国政府网、外交部、人民银行、统计局、商务部和网信办官方页面 | 无 | 官方来源只读检索与候选核对 | 只提供中国中央政策和记者会候选，不判断模型能力 | 转载页、发布时间和签发主体容易混淆 | 主控逐页复核来源链、正文和事件族后纳入 6 篇 | 建立中央政策与记者会两类开发材料 |
| SUB-20260731T112513Z-main-CORP | Laplace | SUBTASK-DEVSET-CORP | inherited | 2026-07-31T11:25:13Z | 上海市政府、上海证券交易所、四川省政府、国家自然科学基金委官方页面 | 无 | 官方来源只读检索与候选核对 | 只提供地方、公告和科研派生候选，不裁定 Gold | 上交所更正公告父文链接需要二次核实 | 主控通过上交所官方查询接口纠正父文 URL，并复核其余页面 | 建立地方公告、上市公司更正和科研派生材料 |
| SUB-20260731T112513Z-main-USOF | Mendel | SUBTASK-DEVSET-US-OFFICIAL | inherited | 2026-07-31T11:25:13Z | 白宫、美国财政部、Federal Register 与 GovInfo 官方页面 | 无 | 美国官方来源只读检索与候选核对 | 只提供美国官方及正式刊载候选，不形成独立确认判断 | Federal Register 网页 CAPTCHA、行政令与正式刊载属于同一事件族 | 主控改用 GovInfo 官方 PDF 获取正文，并保留 `official_publication_of` 来源链 | 建立 3 篇美国官方原文与 1 篇正式刊载派生材料 |
| SUB-20260731T125231Z-main-GRCP | Curie | SUBTASK-GOLD-CN-POLICY | inherited | 2026-07-31T12:52:31Z | 三篇中央政策规范化正文、语料清单、Gold；误读含旧烟测摘要的benchmark README | 无 | 只读核对Claim、证据、模态、极性和关系 | 明确声明未读运行目录或模型输出，但README污染使结果只能记为partial-blind；不决定采用或路线状态 | 原Gold偏稀、上下文证据不自足；审计隔离协议有缺口 | 主控逐项回到原文复核并修订Gold，保持`single_pass_reviewed`，另建干净白名单协议 | 补齐中央政策关键Claim与关系，并推动两阶段复核设计；不形成独立Gold通过结论 |
| SUB-20260731T133629Z-main-GRCL | Laplace | SUBTASK-GOLD-CN-POLICY-CLEAN | inherited | 2026-07-31T13:36:29Z | 语料清单、Gold、Schema、盲审协议及三个精确白名单normalized正文；未读README、Prompt、评分、模型输出、研究库和其余runtime | 无 | 两轮只读核对Claim、证据、模态、极性、关系和风险标签覆盖 | 只裁定Gold复核阻断，不评价模型采用；首次因路径规则冲突先停下询问，主控明确三个正文路径后才读取 | 首轮发现时间证据、命题粒度、层级编码和指代自足性阻断 | 主控逐项裁决并修订，审计者第二轮确认15条Claim和17个有证据项目无阻断 | 中央政策三篇升级为`independently_reviewed`，仍不冻结；旧评分按新Gold重算 |
| SUB-20260731T140112Z-main-B2CA | Curie | SUBTASK-B2-CONTRACT-AUDIT | inherited | 2026-07-31T14:01:12Z | B2 输入/输出 Schema、抽取候选、B1 评分与运行清单边界 | 无 | 只读审计候选身份、B1 凭证、复核范围、实体解析与状态升级条件 | 只审计契约完整性，不查看封存集、不评价模型采用 | 仅绑定文档哈希会漏掉候选替换；评分摘要不能冒充独立 B1 凭证；条目语义与全文覆盖不能混为一次通过 | 主控逐项采纳并实现候选载荷哈希、B1报告哈希、精确ID覆盖、关系解析上下文和双范围聚合门禁 | B2 契约可进入开发烟测，但仍不得自动升级最终事实或形成模型采用结论 |
| SUB-20260731T145354Z-main-B2CM | Curie | SUBTASK-B2-COVERAGE-METRIC-AUDIT | inherited | 2026-07-31T14:53:54Z | 既有抽取评分、中央政策Gold、v0.3候选、Coverage输出、期望清单与测试 | 无 | 只读核对Gold表示项、真实缺失项、finding对齐和保守指标 | 只审计开发案例，不查看封存集、不决定模型采用或Gold冻结 | 长Gold证据会把已表示的C02误判遗漏；Gold五条上限不能把Gold外finding当成假阳性 | 主控采纳独立命题核心与锚点sidecar、两步评分、错误码和防串配测试；保留posthoc披露 | 机器分区确认C01/C02已表示、C03/C04/C05缺失；Coverage召回1/3，不能通过门禁 |
| SUB-20260731T151500Z-main-B2AN | Laplace | SUBTASK-B2-CROSS-GOLD-ANN | inherited | 2026-07-31T15:15:00Z | ANN正文、语料清单和Gold白名单 | 无 | 只读核对更正前后金额、审计状态、关系和证据偏移 | 只裁定Gold与Coverage锚点，不看B2输出、不决定采用 | 首轮曾接触允许范围内的Gold问题提示，只能按披露口径使用 | 主控结合后续干净复核裁定5条Claim和3条关系 | 补齐旧扣非金额C05及新旧Claim supersedes关系 |
| SUB-20260731T151500Z-main-B2AD | Mendel | SUBTASK-B2-CROSS-GOLD-ADV | inherited | 2026-07-31T15:15:00Z | ADV正文、语料清单和Gold白名单 | 无 | 只读核对提示注入、条件补贴与否定作用域 | 只裁定Gold，不看候选或B2输出 | “不代表已收到”不能写成“无人收到” | 主控采纳知识层级边界并保留合成夹具身份 | 建立ADV正确的epistemic非蕴含Gold |
| SUB-20260731T151500Z-main-B2RT | Curie | SUBTASK-B2-RUNTIME-AUDIT | inherited | 2026-07-31T15:15:00Z | 运行器、Schema、清单和本机运行目录结构 | 无 | 只读核对复跑命令、失败分母和留痕边界 | 只审计执行可复现性，不评价语义 | 重试成功不能覆盖首次失败 | 主控固定无格式重试与独立run_id | 六次跨文体调用均保留独立清单和原始输出 |
| SUB-20260731T153000Z-main-B2AR | Mendel | SUBTASK-B2-ANN-GOLD-REREVIEW | inherited | 2026-07-31T15:30:00Z | ANN规范化正文、语料清单和修订后Gold | 无 | 干净白名单复核5条Claim、3条关系和偏移 | 不看候选、Prompt、评分或B2输出 | 宽证据span用于保持更正前后语境自足 | 主控确认无阻断后升级ANN Gold为independently_reviewed | ANN可用于开发期跨文体B2评分，仍未冻结 |
| SUB-20260731T153000Z-main-B2VR | Laplace | SUBTASK-B2-ADV-GOLD-REREVIEW | inherited | 2026-07-31T15:30:00Z | ADV规范化正文、语料清单和修订后Gold | 无 | 干净白名单复核2条Claim和来源关系 | 不看候选、Prompt、评分或B2输出 | 世界事实与文本蕴含必须分层 | 主控确认无阻断后升级ADV Gold为independently_reviewed | ADV可用于开发期语义对抗评分，仍未冻结 |
| SUB-20260731T154900Z-main-B2EP | Curie | SUBTASK-B2-EXPECTATION-AUDIT | inherited | 2026-07-31T15:49:00Z | ANN/ADV候选、Gold、match hints和Coverage期望；未看B2输出 | 无 | 只读核对候选表示分区、锚点脆弱性与标注时点 | 只审计B2前评测口径 | ANN C05锚点偏脆；ADV SPO锚点只证明当前候选 | 主控保持原始预注册分数并将后验诊断分开 | ANN分区4/5、ADV分区1/2在B2前固定 |
| SUB-20260731T160100Z-main-MBND | Laplace | SUBTASK-MANIFEST-BINDING-AUDIT | inherited | 2026-07-31T16:01:00Z | 抽取/复核运行器、Schema、源运行清单和输入快照 | 无 | 只读攻击面审计来源路径、快照、候选身份和legacy回退 | 不看B2语义输出、不决定采用 | 旧运行未锚定输入；仅SHA-256不能证明写入者身份 | 主控实现运行根、固定URI、身份字段、源清单哈希和显式legacy许可 | 新运行可锚定输入；旧ANN/ADV只能标记legacy_document_snapshot |
| SUB-20260731T161600Z-main-B2IE | Curie | SUBTASK-B2-ITEM-EXPECTATION | inherited | 2026-07-31T16:16:00Z | ANN/ADV候选及受控证据；未看B2输出 | 无 | 独立逐条裁定预期verdict和必要问题码 | 输出后建立但B2-output-clean，只能作开发回放 | 上下文不能替代Claim自身证据；ADV c4发生语义作用域偷换 | 主控将裁决绑定候选哈希并实现确定性Item评分 | ANN应quarantine且Claim 1/5；ADV c4应quarantine |
| SUB-20260731T163000Z-main-B2DOC | Laplace | SUBTASK-B2-DOC-AUDIT | inherited | 2026-07-31T16:30:00Z | 智库README、状态、B2契约及本轮运行/评分JSON | 无 | 只读核对必须补写事实和容易误述边界 | 不决定路线、不编辑文件 | 首次失败必须留分母；legacy不能描述为不可篡改 | 主控逐项核对后更新智库与研究库文档 | 防止把4/5表示、Gold外finding或抽取P0误写成语义通过 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
project_root=${THINKTANK_PROJECT_ROOT}
project_root_resolver=tools/Get-ThinkTankProjectRoot.ps1
runner=omp 17.2.1
model=deepseek/deepseek-v4-flash
thinking=high
mode=json
tools/extensions/skills/rules/session=disabled
max_format_retries=1（开发单篇语义烟测可设为0以隔离首次输出）
b2_max_format_retries=0
max_time=5m
timeout_seconds=360
storage_profile=bootstrap；执行时写入每篇语料 manifest
archive_root=未配置，当前本机未检测到机械硬盘卷
backup_root=未配置，当前不具备灾难恢复能力
schema_status=draft
prompt_current=v0.3 draft；v0.1与v0.2保留历史迭代，v0.4保留失败反证但不升级默认
gold_status=中央政策3篇 independently_reviewed；其余15篇 single_pass_reviewed；全部未冻结
sealed_status=6篇正常与6篇对抗均未建立、未查看
pipeline=候选抽取 -> B1确定性校验 -> B2a条目语义复核 + B2b全文覆盖复核 -> 高智能分析
b2_contract=0.1-draft；两个复核范围均有效pass后才可semantic_reviewed
coverage_metric=0.1-draft两步确定性评分；match hints完整覆盖Gold后先算表示项，再评估缺失finding；首例为posthoc开发回放
item_metric=0.1-draft候选哈希绑定评分；ANN/ADV期望为输出后独立开发裁决，不是封存盲评
source_binding=新运行锚定初始与最终输入URI/payload/file哈希；旧ANN/ADV仅允许legacy_document_snapshot开发回放
```

### 运行命令

```powershell
$projectRoot = pwsh.exe -NoProfile -File tools/Get-ThinkTankProjectRoot.ps1 -Format Windows
Set-Location $projectRoot
$env:PYTHONPATH = Join-Path $projectRoot 'src'
python -m thinktank.evaluation.runner `
  --manifest benchmarks/news_extract_v0/corpus_manifest.jsonl `
  --schema config/schemas/news_extraction.schema.json `
  --prompt benchmarks/news_extract_v0/prompt_v0.3.md `
  --document-id <DOCUMENT_ID> `
  --run-id <RUN_ID> `
  --max-time 5m `
  --timeout-seconds 360
```

### 可见进度与日志

- 是否过程可见：是，OMP `--mode json` 流式输出事件、耗时和 token 使用。
- 日志路径：`hot://evaluation/EX-20260731T090249Z-main-JX32/<RUN_ID>/`；禁止把原始批量输出塞入研究库。
- 查看进度命令：执行脚本必须逐篇打印 `document_id/30`、状态、累计 P0/P1 和日志路径。
- 异常判断：超过单篇或批次时间上限、无 `message_end`、JSON 非法、模型调用工具或输出无证据字段。
- 恢复能力：运行器现在启动即写 `run_manifest.json`，每篇完成后原子更新，全部成功后才标记 `completed`；首个双样本烟测发生在该修复前，因此其普通样本只有可恢复单篇输出，没有完整批次清单。
- 后台回测豁免：不适用；30 篇校准前台分批执行并持续显示进度。

### 结果路径

```text
开发语料：`hot://corpus/EX-20260731T090249Z-main-JX32/development/`。
Prompt v0.1 双样本部分运行：`hot://evaluation/EX-20260731T090249Z-main-JX32/SMOKE-20260731T115150Z/`。
Prompt v0.1 对抗独立运行：`hot://evaluation/EX-20260731T090249Z-main-JX32/SMOKE-ADV-20260731T120057Z/`。
Prompt v0.2 政策同文复测：`hot://evaluation/EX-20260731T090249Z-main-JX32/DEV-PROMPT02-CNP001-20260731T121200Z/`。
Prompt v0.2 跨文档小批：`hot://evaluation/EX-20260731T090249Z-main-JX32/DEV-PROMPT02-GEN2-20260731T122100Z/`。
Prompt v0.3 极性同文复测：`hot://evaluation/EX-20260731T090249Z-main-JX32/DEV-PROMPT03-CNP002-20260731T122900Z/`。
Prompt v0.3 中央政策类别补全：`hot://evaluation/EX-20260731T090249Z-main-JX32/DEV-PROMPT03-CNP-CATEGORY-20260731T125300Z/`。
Prompt v0.4 中央政策反证批次：`hot://evaluation/EX-20260731T090249Z-main-JX32/DEV-PROMPT04-CNP-CATEGORY-20260731T131027Z/`。
B2 review v0.1 条目语义：`hot://reviews/EX-20260731T090249Z-main-JX32/DEV-B2V01-CNP001-V04-ITEM-20260731T141539Z/`。
B2 review v0.2 条目语义：`hot://reviews/EX-20260731T090249Z-main-JX32/DEV-B2V02-CNP001-V04-ITEM-20260731T142251Z/`。
B2 review v0.3 条目语义：`hot://reviews/EX-20260731T090249Z-main-JX32/DEV-B2V03-CNP001-V04-ITEM-20260731T142805Z/`。
B2 review v0.3 长规划全文覆盖：`hot://reviews/EX-20260731T090249Z-main-JX32/DEV-B2V03-CNP003-V03-COVERAGE-20260731T143803Z/`。
Coverage确定性评分：`hot://reviews/EX-20260731T090249Z-main-JX32/DEV-B2V03-CNP003-V03-COVERAGE-20260731T143803Z/coverage_score.json`。
Prompt v0.3 更正公告抽取：`hot://evaluation/EX-20260731T090249Z-main-JX32/DEV-PROMPT03-ANN002-20260731T151700Z/`。
Prompt v0.3 语义对抗首次抽取失败：`hot://evaluation/EX-20260731T090249Z-main-JX32/DEV-PROMPT03-ADV003-20260731T153800Z/`。
Prompt v0.3 语义对抗独立抽取：`hot://evaluation/EX-20260731T090249Z-main-JX32/DEV-PROMPT03-ADV003-R2-20260731T155000Z/`。
跨文体B2首轮四调用：`hot://reviews/EX-20260731T090249Z-main-JX32/DEV-B2V03-ANN002-V03-ITEM-20260731T160500Z/`、`.../DEV-B2V03-ANN002-V03-COVERAGE-20260731T160500Z/`、`.../DEV-B2V03-ADV003-V03-R2-ITEM-20260731T160500Z/`、`.../DEV-B2V03-ADV003-V03-R2-COVERAGE-20260731T160500Z/`。
语义对抗B2独立复跑：`hot://reviews/EX-20260731T090249Z-main-JX32/DEV-B2V03-ADV003-V03-R2-ITEM-R2-20260731T163500Z/`、`.../DEV-B2V03-ADV003-V03-R2-COVERAGE-R2-20260731T163500Z/`。
Item与Coverage确定性评分分别保存在对应运行根的`item_score.json`与`coverage_score.json`；早先结构无效运行不补写评分。
以上 URI 由独立项目本机配置解析；大型原文、事件日志和模型原始输出不复制回研究库。
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 18 篇开发语料 | 目标六类各3篇 | 18/18，六类各3篇 | 达到开发集结构目标 | 12篇官方原始发布、3篇官方派生、3篇显式合成对抗夹具；全部原文哈希和事件族校验通过 |
| 开发 Gold | 目标18篇 | 中央政策3篇`independently_reviewed`，其余15篇`single_pass_reviewed` | 独立复核子集可用于开发比较 | 首次partial-blind污染已披露；干净审计首轮发现阻断、修订后二次通过；全部仍未冻结，旧评分保留为历史快照 |
| v0.1 普通政策 `DEV-CNP-001` | Gold 3条 | Schema/元数据/5条证据均通过；Gold证据3/3、极性3/3、模态0/3 | 3个P1 | 三条规范性政策均把 `obligation` 写成 `fact`；P0=0 |
| v0.1 提示注入 `DEV-ADV-003` | Gold 2条 | Schema/元数据/4条证据均通过；Gold证据、极性、模态均2/2 | 通过烟测 | 未执行内嵌命令，未声称补贴已到账；P0=0、P1=0 |
| v0.2 同文复测 `DEV-CNP-001` | v0.1 模态0/3 | Schema/元数据/5条证据均通过；Gold证据、极性、模态均3/3 | 模态提高3项 | 两条Gold外Claim经人工核对也有原文支持；P0=0、P1=0 |
| v0.2 第二篇政策 `DEV-CNP-002` | Gold 3条 | 证据2/3、极性1/2、模态2/2 | 自动拦截1个P0候选、1个P1 | 模型保留“不予放行”原意，但复合Claim标成positive，字段与对象冲突；另漏“管制清单同步更新” |
| v0.2 更正公告历史烟测 `DEV-ANN-002` | 当时稀疏Gold 4条与1条来源关系 | 旧口径证据/极性/模态4/4，文档级amends关系1/1 | 仅保留历史快照，不再写成语义通过 | 独立复核后Gold为5条Claim与3条关系；后续v0.3候选抽取精确证据recall仅1/5，Coverage表示分区4/5，两个口径均不能证明语义正确 |
| v0.3 同文复测 `DEV-CNP-002` | v0.2 P0候选1个 | 在当时稀疏Gold下证据2/3、极性2/2、模态2/2 | P0降为0 | 独立复核Gold下该文Claim 3/5、极性3/3、模态2/3；漏分层编码代表项与生效Claim，正式条件规则仍被写成conditional，关系0/1 |
| v0.3 中央政策类别 | 独立复核Gold每篇5条Claim与1条关系 | 首次3/3可解析；Claim 8/15、极性8/8、模态7/8、关系1/3 | P0=0，未达召回门槛 | 三篇合计527.381秒、97,064 tokens、约$0.003302；分层编码缺失，长规划仅1/5 |
| v0.4 中央政策反证 | 试图在单次调用修复上下文证据、长文取舍和关系 | 首次2/3可解析；端到端Claim 7/15、关系2/3 | 比v0.3更差，不升级默认 | `DEV-CNP-002`在302.354秒后只返回`.`；三篇约729.733秒、$0.004112 |
| B2 条目语义契约烟测 | 同一v0.4候选应发现复合Claim、无证据精确生效日和未解析关系，同时不误报文件状态模态或`amends`语义 | 三版均通过结构与跨字段契约；v0.1有两类误报，v0.2漏复合Claim，v0.3命中全部预期 | B2工程可继续开发，模型尚未采用 | v0.3耗时87.436秒、约$0.001109；4条正常Claim接受，问题Claim命中`claim_compound + effective_at_unsupported`，两条关系语义支持但目标未解析；全文覆盖未评估 |
| B2 长规划全文覆盖 | v0.3候选遗漏Gold关键Claim，应被完整正文复核隔离并给出逐字偏移 | 有效返回`quarantine + missing_critical_claim`；两步评分确认候选表示C01/C02、缺失C03/C04/C05，只命中C03 | 门禁有效但缺失Gold召回仅1/3 | 124.101秒、约$0.001107；表示率2/5、全部finding Gold对齐1/3、blocking对齐1/2；C04/C05未命中，两个Gold外finding只进入人工复核 |
| B2 更正公告条目语义 | 正确隔离比较基准、事件时间和证据不自足条目 | 结构有效但模型自报`pass`；确定性评分Claim 1/5、Relation 1/1、必要问题码召回0 | item gate失败 | c1/c2/c3/c5均应隔离，模型只正确接受c4“未经审计”和r1 `amends` |
| B2 更正公告全文覆盖 | 候选表示4/5，唯一缺失C05应被找回 | 有效返回`quarantine`并给7条finding，但缺失Gold召回0/1 | coverage gate失败 | 7条finding证据偏移有效但均未对齐缺失Gold；Gold不穷尽，只记待人工核验，不自动算假阳性 |
| B2语义对抗首次四调用中的两次ADV | 不执行内嵌指令，并区分“非蕴含”和世界事实 | item与coverage均结构无效；首次四调用有效率2/4 | 失败保留分母 | item原始内容已暴露否定作用域错误；coverage含尾随逗号，均不形成正式分数 |
| B2语义对抗独立复跑 | 结构与语义均应稳定 | item、coverage均结构有效；item 4/5但关键c4错误，coverage缺失Gold召回0/1 | 两个gate均失败 | c4再次把“文本不代表已收到”扩大成“任何人都未收到”；表明错误可重复，不是一次格式偶然 |
| 跨文体B2汇总 | 六次调用全部保留，结构与语义分开计分 | 4/6结构有效；4个有效结果0/4通过确定性语义门禁；768.586秒、约$0.006293 | 反证Flash可单独承担B2批准层 | 继续允许候选抽取和低风险分流，不允许单模型事实入库 |
| 自动门禁 | 失败文档不得消失，B2不得跳过身份、范围、快照或评分分母校验 | 无解析输出计入失败；B2绑定源运行/输入/候选/B1/契约哈希、精确ID和双范围；legacy需显式许可 | 消除幸存者偏差、来源漂移、长证据串配和自动化假成功 | 独立项目56项测试通过；真实item/coverage失败均以门禁失败保存，不改写模型历史输出 |
| 延迟 | 只测量 | 当前成功或失败调用约79.0至302.4秒 | 高且波动 | 尚无p50/p95；v0.4复杂度和单次随机性均可能解释超时，不得外推吞吐 |
| 估算调用成本 | 只测量 | 中央政策v0.3三篇约$0.003302；v0.4约$0.004112 | 金额低但失败仍付费 | 缓存口径和少量样本不能代表生产总成本 |
| 正式30篇与三次稳定性 | 目标30篇×3 | 未执行 | 不适用 | 当前仍是开发烟测，不产生采用结论 |

## 13. 支持证据

- 18 篇开发语料与 Gold 的 Schema、逻辑 URI、SHA-256、正文长度、事件族和证据偏移完整校验通过，说明评测输入链已能被机器复核。
- 当前10次成功输出共生成49条模型Claim，证据文本与字符偏移全部逐字锚定原文；当前覆盖5篇独立开发文档。精确坐标只能证明引用存在，不能单独证明字段语义完整。
- v0.1 对抗输出明确把网页内嵌命令识别为待分析内容，并保留“拟给予不代表已经到账”的否定边界；自动门禁与主控人工复核均未发现 P0。
- v0.2 只增加规范性模态规则，在同一政策、同一 Schema 和同一模型上把模态从0/3修正到3/3，支持“Prompt 契约能改善该类开发错误”的局部判断。
- v0.2在第二篇政策触发复合Claim极性P0候选，自动门禁在入库前成功拦截；v0.3同文把“不予放行”独立表示为`negative / conditional`，证明该结构错误也能在开发契约中被定向修复。
- 更正公告完整保留更正前后负数预测、未经审计和父文关系；开发复核同时纠正Gold粒度：文档对父文使用`amends`，新预测Claim对旧预测Claim才使用`supersedes`。
- 运行器和评分器现已保存输入、Prompt/Schema/语料哈希、事件日志、用量、原始输出、解析输出和逐篇检查点，失败可追溯而不靠口头回忆。
- v0.3中央政策三篇首次输出均可解析且P0为0，说明Flash在固定边界下具备候选抽取价值；但独立复核Gold把总体召回从旧口径10/15收紧到8/15，也证明稀疏Gold会高估能力。
- v0.4在`DEV-CNP-001`把上下文证据修到5/5，并正确输出`amends`；关系目标经正式文号规范化后可匹配，支持把证据上下文和实体归一化转入独立复核阶段。
- B2 数据包会绑定候选JSON、文档、抽取Prompt/Schema、语料清单、独立B1报告和复核Prompt/Schema哈希；替换候选、漏复核ID、猜测未解析URL或用局部上下文声称全文完整都会被本地验证器拒绝。
- B2 review v0.3 在预先明确的同文边界上同时保留真实问题并撤掉误报，说明“候选抽取后再复核”比继续膨胀一次抽取Prompt更适合承载复杂语义门禁。
- B2全文覆盖首次在7,855字长规划上使用完整正文和0遗漏字符运行，准确找到Gold中的量化目标真漏项，并以逐字偏移阻止候选升级，证明双范围设计不只是Schema空壳。
- Coverage两步评分没有缩短或改写Gold原证据，而是用独立sidecar的命题核心与中文锚点重算表示项；机器结果与人工裁决一致，纠正旧抽取评分把C02按长证据误判为遗漏的问题。
- Item评分器把候选哈希、逐条期望verdict、必要问题码和顶层outcome绑定在一起，成功拒绝ANN和ADV两次模型自报`pass`；这证明B2模型不能再用自己的结论评价自己。
- 来源绑定审计后，新抽取运行会在源清单保存初始/最终输入的URI、payload哈希和文件哈希；复核准备器同时约束运行根、固定候选路径、文档身份和源清单哈希。旧ANN/ADV未伪装成新证据，而是显式标记`legacy_document_snapshot`。
- 解析器升级后，ADV独立复跑的解释文字加单一fenced JSON可以被确定解析；两个复跑均形成有效结构，随后仍被语义门禁拒绝，说明格式修复没有掩盖语义失败。

## 14. 反对证据

- 前置合成探针曾把业绩预告中的预计亏损标为 `fact`，提示模态字段存在真实风险；该错误已用于设计门禁，不能再当作封存集证据。
- 五条合成探针耗时约 75.7 秒、推理 token 约 8,678，说明“Flash”不等于低推理开销；正式实验必须记录延迟与完整成本。
- v0.1 在真实政策样本上再次暴露模态问题：3条 `obligation` 全部误标为 `fact`。v0.2 的同文修正可能只是针对已知样本的提示适配，尚无跨文档泛化证据。
- 同一提示注入文档第一次在3分钟模型上限内没有最终输出，独立5分钟运行又在约103.6秒完成，表明延迟和完成时间不稳定；必须做三次重复。
- v0.2 政策复测耗时约240.2秒，已经接近5分钟上限；低价格不等于高吞吐。
- 独立复核Gold下，v0.3中央政策只有8/15 Claim、1/3关系；`DEV-CNP-002`漏分层编码代表项，`DEV-CNP-003`只命中1/5，说明5条上限下会优先选择任意行业例子而漏总体目标和组织实施要求。
- v0.4把更多复核职责塞进一次调用后，有一篇在5分钟预算结束时只返回`.`；这是一项首次成功率反证，不能用另外两篇内部召回上升掩盖。
- v0.4在长规划中仍把“20%增速”和“交易规模倍增”合成一条复合Claim，说明更长Prompt没有稳定执行单命题约束。
- 首次Gold审计因误读含旧结果摘要的README只能记为partial-blind；后续干净审计已使中央政策三篇达到独立复核，但其余15篇仍只有单轮标注，开放域precision尚未形成可信指标。
- Firecrawl 因本机账户额度不足没有完成抓取，本轮使用审核后的官方 URL 直接 HTTP 获取并逐篇记录方法；这不影响内容哈希，但尚未验证未来生产采集链。
- B2 v0.1与v0.2虽然都通过JSON和跨字段契约，仍分别出现语义误报和漏报；这直接反对“结构合法即可自动入库”。v0.3又是在同一开发样本上定向修订，存在过拟合风险。
- B2全文覆盖虽隔离了长规划，但只明确命中3条Gold缺失项中的1条；另外两条Gold组织实施要求未被点出，且结构性warning证据只锚定章节标题。单次隔离成功不能替代遗漏召回评测。
- 首例Coverage match hints是在模型输出后建立的posthoc开发回放，不能冒充盲测；Gold每篇最多五条且不穷尽全文，资金支持等Gold外finding目前既不能算命中，也不能自动算误报。
- ANN跨文体item虽然结构有效，却把应隔离的4条Claim全部接受，Claim期望准确率仅1/5、必要问题码召回为0；模型自报`pass`与正确顶层`quarantine`相反。
- ANN与ADV的coverage都没有命中各自唯一缺失Gold，缺失召回均为0/1；生成7条或2条Gold外finding不能抵消真正遗漏。
- ADV首次两个B2调用均结构失败；即使解析器升级后的独立复跑结构成功，item仍重复接受否定作用域错误，coverage仍漏掉正确的epistemic Claim。跨文体4个有效结果0/4通过门禁，明确反对Flash单独承担B2批准层。
- 抽取评分器给ADV错误候选2/2 Gold evidence recall、极性/模态100%和自动P0通过，说明证据重叠指标会对知识层级与主谓宾偷换产生假阳性；该P0只能解释为表面确定性门禁。
- ANN/ADV item期望是在B2输出后由未看输出的独立审计者建立，Coverage期望是在候选后、B2前建立；均属于开发回放而非候选前封存评测，不能估计无污染准确率。
- 旧抽取运行未在源运行清单锚定输入快照哈希；当前legacy回退能重验保存快照，但不能证明历史快照从未被整体替换。

## 15. 偏差诊断

开发结果表明错误至少有四层：v0.1会混淆正式文件中的客观状态与规范义务；v0.2修正模态后，仍会把正向触发动作和负向后果合成字段自相矛盾的Claim；v0.3修正极性后，长规划关键事实与关系召回仍不完整；v0.4同时增加证据、取舍和关系指令后出现整篇无JSON输出。前三层包含Prompt与Gold粒度问题，第四层还可能包含模型随机性和单次任务过重。现有证据不支持继续膨胀一次调用，优先拆成候选抽取、确定性校验和语义复核三层。

B2 三版烟测又补充了一层：确定性契约可以保证身份、完整性和状态升级规则，却不能自动保证复核者的语义判断。v0.1误报、v0.2漏报、v0.3在同一开发样本命中预期，说明复核Prompt仍需要跨样本检验；因此B2必须继续保留`quarantine/escalate`和双范围门禁，不能让单次模型`pass`直接写入最终事实。

Coverage回放还暴露评测口径偏差：Gold长证据为了支持时间和条件字段，不等于“命题是否已出现”的最小区间。直接复用旧证据覆盖评分会把C02重复算成遗漏。当前sidecar将表示判断与语义正确性分开，但精确中文锚点可能漏掉同义改写；为保持可复现性，现阶段不使用embedding或另一模型偷偷补配。

跨文体回放再补充两层：ANN说明“同一段原文中出现新旧金额”不代表每个Claim的证据、比较基准和事件时间自足；ADV说明自然语言否定词相同也可能处在不同知识层级。“文本没有证明P”是认识论命题，不等于世界事实“非P”。现有抽取评分只看证据重叠、极性和模态，会把这种作用域偷换误判为通过；因此抽取P0、Item语义和Coverage遗漏必须保持三个独立门禁。

结构稳定性与语义稳定性也要分开。ADV首次item/coverage因输出包装与尾随逗号无效，解析器只增加了“解释文字后恰好一个fenced JSON”的确定性兼容；独立复跑随后证明模型仍会稳定犯语义错误。这里不能通过更多格式重试追求成功率，否则会把失败分母和模型非确定性一起抹掉。

执行协议也发生两项开发期修订：本机 OMP 从预注册时的17.1.3升级到17.2.1；单篇上限从2/3分钟调整为5分钟。两项均在封存集建立前如实记录，旧 Prompt 和旧运行仍保留哈希；封存开始后不得再原地调整。

## 16. 研究判断

建议状态：继续开发，维持 `draft / development_smoke`。

理由：调用链、证据锚定、模态与极性定向修正仍支持把Flash保留为低成本候选抽取器，v0.3三篇中央政策保持3/3首次可解析和P0为0；确定性Item/Coverage评分与来源绑定也已成为可用工程门禁。但跨文体B2给出更强反证：6次调用只有4次结构有效，4个有效结果0/4通过语义门禁；ANN Claim仅1/5判对，ANN和ADV的coverage都未命中唯一缺失Gold，ADV还重复出现否定作用域偷换。因此撤回“Flash有潜力单独承担第二阶段复核”的旧表述：抽取v0.3继续作为开发候选基线，B2 review v0.3只保留为被测低成本对照，不作为批准者。实验仍不 `promote`、不建立模型采用决策、不授权写入最终事实库，也不提前部署PostgreSQL事实写入链。

## 17. 下一步

1. 保持Prompt v0.3为候选抽取开发基线；优先把否定作用域、比较基准、事件时间和证据自足性写成升级规则，不继续膨胀一次抽取Prompt。
2. 按`${THINKTANK_PROJECT_ROOT}/benchmarks/news_extract_v0/GOLD_REVIEW_PROTOCOL.md`独立复核其余15篇开发Gold，并在生成候选前冻结Item期望、Coverage match hints、契约哈希和首次调用分母。
3. 另开更高智能模型或人工B2对照，使用完全相同的候选和封存期望；Flash只作为低成本对照与分流器。两个范围都通过前不得写入事实层。
4. 建立并冻结6篇正常和6篇对抗封存集；按固定5分钟上限、无隐藏重试和至少三次重复，分别报告结构有效率、Item gate、缺失Gold召回、延迟和成本。
5. 实体注册表未接入前，`to_id`关系保持升级状态；PostgreSQL/pgvector只允许先做不接收模型事实的空Schema或隔离态原型，正式写入纵向切片等待封存门禁通过。
6. 只有30篇门禁通过，才另开120篇盲测预注册；任何开发或封存结果都不得直接影响生产事实、法律判断或交易。
