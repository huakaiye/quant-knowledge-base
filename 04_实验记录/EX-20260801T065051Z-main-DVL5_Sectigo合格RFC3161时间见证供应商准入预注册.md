---
type: 实验记录
ex_id: EX-20260801T065051Z-main-DVL5
rd_id: RD-20260731T090245Z-main-KLCN
status: completed
stage: smoke_passed
owner: main
created_at: 2026-08-01T06:50:51Z
updated_at: 2026-08-01T07:20:55Z
strategy_id:
module_type: provider_onboarding
decision_ids:
  - DEC-20260731T092724Z-main-7MPL
  - DEC-20260801T072055Z-main-675B
lit_ids: []
idea_ids: []
platform_project: ${THINKTANK_PROJECT_ROOT}
config_paths:
  - ${THINKTANK_PROJECT_ROOT}/config/time_witness_profiles/sectigo_qualified_rfc3161_2026_v1.json
  - ${THINKTANK_PROJECT_ROOT}/src/thinktank/analysis/forecast_time_witness.py
result_paths:
  - ${THINKTANK_PROJECT_ROOT}/tests/test_forecast_time_witness.py
  - ${THINKTANK_PROJECT_ROOT}/tmp/c5-sectigo-qualified-observation/
summary_paths:
  - ${THINKTANK_PROJECT_ROOT}/docs/架构/RFC3161独立时间见证与逐预测前瞻资格.md
quality_gate: l1_sectigo_qualified_profile_approved_with_single_preregistered_observation
subagent_call_ids: []
subagent_exemption: 当前工具环境不允许调用子代理；主控：main；时间：2026-08-01T06:50:51Z
tags: [个人智库, RFC3161, Sectigo, eIDAS, 时间精度, 供应商准入]
---

# Sectigo合格RFC3161时间见证供应商准入预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260731T090245Z-main-KLCN_个人智库消息面结构化与长期记忆系统|个人智库消息面结构化与长期记忆系统]]
- 策略档案：
- 来源文献或灵感：[[04_实验记录/EX-20260801T061733Z-main-J9D3_RFC3161独立时间见证与逐预测前瞻资格合同预注册|C5独立时间见证合同]]；Sectigo官方TSPPS v1.1.4与官方时间戳端点说明
- 产生的决策：[[05_研究决策/DEC-20260801T072055Z-main-675B_独立时间见证采用见证型与限期前瞻型Profile分层|时间见证Profile分层决策]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：Sectigo的合格时间戳服务能否补上DigiCert当前公开服务没有数值精度上界的缺口。  
我们原本预计：官方合格端点应返回可验证的RFC 3161响应、固定证书链、1秒accuracy和可冻结的证书状态证据。  
实际看到：预注册落盘后只执行了一次POST。响应的nonce、摘要、签名、固定链、两级CRL、合格政策标记和1秒accuracy全部通过，形成`approved_prospective`固定Profile，有效期保守限制到`2026-11-01T00:00:00Z`。  
这说明：Sectigo当前固定服务样本可以补上DigiCert的数值精度缺口，但资格属于特定政策、特定证书链和限期版本，不能永久或自动继承。  
但还不能说明：即使供应商准入，也不能证明任何真实预测正确，只能为以后逐条判断“是否在事件前已存在”提供时间证据。  
下一步要做：先完成NTFS/ReFS耐久介质迁移，再用这个限期Profile见证结果未知的真实预测；到期或证书变化前必须重新预注册准入。

## 2. 研究背景

C5通用协议和DigiCert真实样本已经证明签名、链与吊销证据可以离线复验，但DigiCert响应未携带accuracy，当前CP/CPS也没有可绑定的数值上界，因此只能标为`approved_witness_only`。Sectigo官方TSPPS v1.1.4自2026-02-11生效，声明合格服务位于`http://timestamp.sectigo.com/qualified`，RFC 3161/5816响应的时间精度为1秒或更好，并说明响应包含TSA和subCA证书。本实验只做供应商profile准入，不改C5资格公式。

## 3. 实验前假设

如果公开合格端点的实际响应、签名者、证书链、token标记、精度和吊销证据都与当前官方政策一致，那么可建立一个`approved_prospective`固定profile；否则只能降为`approved_witness_only`或拒绝准入。

## 4. 实验前预测

- 固定主体原文：`thinktank-c5-sectigo-qualified-profile-observation-v1`。
- 固定主体SHA-256：`88778ffb0b1485e2ff841418242bbf9b1834fc64cc9d4a83134c1bfb0c32a80d`。
- 请求：SHA-256 message imprint、OpenSSL生成的随机nonce、`certReq=yes`，不指定reqPolicy，不发送智库正文。
- 网络动作：预注册后只向官方qualified端点发起一次POST；不自动重试，不跟随重定向。
- 预计HTTP 200、MIME `application/timestamp-reply`、PKIStatus granted、nonce和message imprint精确回显。
- 预计token或适用政策能给出1秒上界；系统取token与政策上界的保守最大值，缺任一可绑定证据时不授予前瞻权限。
- 预计响应携带签名者证书和subCA；签名者只含关键Time Stamping EKU，链可固定到官方根。
- 预计token包含能把本响应绑定到合格服务政策的标记；仅访问qualified URL不足以证明token合格。
- 预计至少能冻结覆盖`genTime`的CRL或同等离线状态证据；只在线查询OCSP而不能冻结时不得批准前瞻profile。
- 本次不运行回测，不评价收益、命中率或真实预测质量。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| DigiCert 2025 profile | 签名和吊销均通过、但无数值accuracy的见证型基准 | `${THINKTANK_PROJECT_ROOT}/config/time_witness_profiles/digicert_rfc3161_2025_v1.json` |
| C5固定负控 | nonce、策略、签名者、EKU、链、CRL、边界相等、双侧差异和离线重放 | `${THINKTANK_PROJECT_ROOT}/tests/test_forecast_time_witness.py` |
| Sectigo TSPPS v1.1.4 | 端点、协议、1秒精度、响应字段和层级的政策基准 | `https://www.sectigo.com/uploads/files/eIDAS/Sectigo_eIDAS_TSPPS_v1.1.4.pdf` |

## 6. 竞争性解释

- qualified URL可能返回有效但未带合格标记的普通token，不能把URL名称当证据。
- TSPPS的一秒承诺可能适用于政策整体，但实际token的OID或证书链无法唯一绑定到该政策。
- 响应可以在当前在线验证通过，但缺少可冻结的历史吊销证据，离线重放仍不充分。
- 服务器可能轮换多个合法TSU；单次样本只能批准固定观察到的签名者，不能预先信任未来未知证书。
- OpenSSL可以验证密码学签名，但不会自动替我们完成政策语义和逐预测时间边界判断。

## 7. 证伪条件

出现以下任一情况，本次`approved_prospective`假设不通过：

- 请求发生在本预注册落盘前，或向端点发送了主体原文、预测内容或其他敏感数据。
- 发生第二次POST、自动重试、重定向，或响应HTTP/MIME/大小不合合同。
- PKIStatus非granted，nonce或message imprint不一致，SHA-256请求不被接受。
- 响应未携带证书，签名者不具唯一关键Time Stamping EKU，或无法固定到官方层级。
- token没有可验证的合格政策绑定，或实际OID不能由当前TSPPS解释。
- token与当前官方政策都不能给出数值accuracy，或保守上界大于1秒。
- 无法取得并冻结覆盖`genTime`的链级吊销证据，或证书在签发时刻已撤销/失效。
- profile需要相信调用者自报端点、证书、可信状态或时间，或需要修改C4/C5旧收据才能通过。
- 只有本机联网时可以验证，断网、删除hot原件或任一侧副本独立重放失败。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 预注册文件在唯一POST前落盘；请求只含预先固定合成摘要，TSQ/TSR、请求时间与服务`genTime`均冻结 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 本实验不生成交易信号 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 本实验不使用证券池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 只发送固定合成摘要 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 供应商准入不授予任何交易权限 |

负控或错位检查：复用C5的nonce、imprint、策略、签名者、EKU、链、CRL、精度相等边界和双介质差异负控；新增qualified token标记缺失负控。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 一个固定摘要、一个端点、一次请求、无重试 |
| 样本内、验证集、样本外划分清楚 | 不适用 | 协议准入，不做统计拟合 |
| 邻近参数敏感性合理 | 不适用 | 不调参 |
| 成本、滑点或换手扰动已检查 | 不适用 | 不回测 |
| 已做消融或负控 | 通过 | 合格政策QC标记、policy OID、签名者、链、CRL、accuracy及通用C5负控均进入34项专项回归 |
| 未只报告最优结果 | 通过 | 唯一样本无论成功失败都保留 |

证据等级：预期`L1`，仅为协议和供应商合同证据。

## 10. 子代理调用记录

子代理计划：不调用；调用ID：无；任务代号：SUBTASK-C5-SECTIGO-ONBOARDING；平台昵称：无；模型：主控；交付物：预注册、唯一外部样本、profile、负控、文档；豁免原因：当前工具环境不允许新建子代理。

适配判断：`适合调用但工具环境不允许`

调用状态：`exempt`

```text
子代理豁免：当前工具环境不允许调用子代理；主控：main；时间：2026-08-01T06:50:51Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：无；豁免不登记调用台账。

## 11. 执行记录

### 平台配置

```text
项目：${THINKTANK_PROJECT_ROOT}
OpenSSL：执行时冻结绝对路径、版本、主版本与二进制SHA-256
端点：http://timestamp.sectigo.com/qualified
自动重试：0
自动重定向：关闭
```

### 运行命令

```powershell
# 已执行：生成SHA-256、随机nonce、certReq=yes的TSQ；随后用禁重定向HttpClient只POST一次。
pwsh.exe -NoProfile -File scripts/Test-ThinkTankRepo.ps1
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${THINKTANK_PROJECT_ROOT}/tmp/c5-sectigo-qualified-observation/`
- 查看进度命令：`Get-ChildItem ${THINKTANK_PROJECT_ROOT}/tmp/c5-sectigo-qualified-observation`
- 异常判断：任一证伪条件触发即失败关闭，不追加请求。
- 后台回测豁免：本实验无回测、无后台进程。

### 结果路径

```text
${THINKTANK_PROJECT_ROOT}/tmp/c5-sectigo-qualified-observation/
${THINKTANK_PROJECT_ROOT}/config/time_witness_profiles/sectigo_qualified_rfc3161_2026_v1.json（仅在准入通过时）
```

## 12. 实际观察

- 预注册文件最终落盘时间为`2026-08-01T06:52:35Z`；联网观察前文件SHA-256为`8e32d3982bb2bcb173becdf4779b6d9c92df5c8f77cbf71f33a9907d0dd1d75e`。固定主体SHA-256与预注册一致，为`88778ffb0b1485e2ff841418242bbf9b1834fc64cc9d4a83134c1bfb0c32a80d`。
- 唯一POST从`2026-08-01T06:54:11.0759063Z`开始，于`2026-08-01T06:54:13.8020132Z`收到HTTP 200、MIME `application/timestamp-reply`；没有重试和重定向。
- TSQ共70字节，SHA-256为`3c229d961c39f271afb332ff41573fafe58a9a7c293bed772b52d1e71bc8d78a`；TSR共4531字节，SHA-256为`9cca6940816a0e1c508b182341ecd86c23acbbb485e5f4b3bd97e94c14806c8c`。
- token策略OID为`0.4.0.2023.1.1`，`genTime=2026-08-01T06:54:13Z`，accuracy为1秒，并包含要求的QC statement `0.4.0.19422.1.1`；可信上界因此保守取`2026-08-01T06:54:14Z`。
- 签名者为`Sectigo Qualified Time Stamping Signer #3`，指纹`4ffc3bcb2da5c1623a5e98714df0c4e9ca622db07cb0eb6b2083388a0602029d`；中间证书指纹`cd0a3e00a1bdae3a159fa9e3d70f8e664f560fdce16357cbe440ed0b0d88244f`；根指纹`f871f8976b4068d700d5f281084b4a29eaf4b8f35743330ba062fab46f58c2ed`，根SHA-1与TSPPS Annex C的`cb73944c042e53bfc4579d2f712f3eea99fe4307`一致。
- 签名者CRL与中间CA CRL均覆盖`genTime`且离线验证通过；TSPPS v1.1.4以SHA-256 `6d721d8ca07976bd4b331cd25f8d3c07cbef25874172702612bc08c737dca2ae`冻结。
- 新Profile `sectigo_qualified_rfc3161_2026_v1`通过全部C5门禁，状态为`approved_prospective`，但保守到期时间固定为`2026-11-01T00:00:00Z`；届时或证书、政策变化时必须新建版本。

## 13. 支持证据

- 唯一真实样本与预注册摘要、网络次数、HTTP/MIME、nonce、message imprint和成功状态完全一致。
- token自身给出1秒accuracy，并以QC statement和固定policy OID绑定到合格服务，不依赖URL名称推断。
- 固定签名者、专用关键EKU、完整链和覆盖签发时刻的两级CRL均可断网复验。
- profile不允许调用者自报端点、证书、政策、可信时间或资格；政策PDF、证书和CRL全部进入内容寻址证据闭包。

## 14. 反对证据

- 只有一个时间点、一个签名者样本，不能外推服务可用率、未来轮换证书或长期治理质量。
- Profile授权被主动限制到2026-11-01；期限后的服务状态、政策与吊销材料尚未知。
- 当前真实存储仍是`exFAT/provisional`，所以本次供应商准入本身不能让任何预测取得正式前瞻资格。
- 单一供应商仍是集中信任；多TSA交叉见证与长期续封尚未验证。

## 15. 偏差诊断

正式联网前，系统PATH中的OpenSSL调用失败；该失败发生在TSQ和网络请求之前，随后改用已冻结的绝对二进制路径。唯一TSR取得后，OpenSSL CMS默认文本提取不能保持DER字节，离线分析改用`-binary`；一个辅助双指纹命令参数无效也被保留，但固定链验证不受影响。以上均未触发第二次POST、未改变摘要，也未放宽任何准入门槛。

## 16. 研究判断

建议状态：`promote_candidate`

理由：固定样本、官方政策、token标记、1秒精度、固定链与吊销证据全部满足预注册合同，可批准这个确切Profile作为限期前瞻见证候选；单样本和介质边界阻止其升级为生产能力。

## 17. 下一步

经用户批准把HDD复制迁移到NTFS/ReFS，以恢复器分别验收archive和独立backup并生成`durable`锚；之后才可让结果未知的真实C3 v2 head依次取得C4 v2锚和C5见证。Profile到期、证书或政策变化前另开准入预注册，不原地覆盖；真实预测仍须到期人工裁决并达到冻结样本门槛后才查看校准。
