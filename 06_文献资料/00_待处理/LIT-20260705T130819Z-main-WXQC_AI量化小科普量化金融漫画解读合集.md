---
type: 文献
lit_id: LIT-20260705T130819Z-main-WXQC
status: 待处理
source: 微信公众号
authors: AI量化小科普
year: 2026
url: https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzY5NjA0MTEzOA==&action=getalbum&album_id=4537431503202533386#wechat_redirect
created_at: 2026-07-05T13:08:19Z
updated_at: 2026-07-05T13:08:19Z
tags:
  - 公众号科普
  - 量化金融漫画解读
  - 新手学习
  - 数学基础
  - 资产定价
---

# AI量化小科普量化金融漫画解读合集

## 关联链接

- 文献资料规范：[[06_文献资料/README|文献资料说明]]
- 质量边界：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理记录规范：[[08_方法论/子代理调度规范|子代理调度规范]]

## 基本信息

- 来源：微信公众号 `AI量化小科普`
- 专辑：`量化金融漫画解读`
- 专辑入口：<https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzY5NjA0MTEzOA==&action=getalbum&album_id=4537431503202533386#wechat_redirect>
- 覆盖范围：2026-05-29 至 2026-07-03 公开可访问文章，共 21 篇。
- 阅读方式：微信正文主要由图片漫画承载。本轮按文章链路抓取页面和正文图片，生成逐篇预览图后由主控逐篇视觉阅读；本文只记录摘要和研究边界，不复制原图或长段原文。

## 总体判断

这组文章适合放在研究库的 L0 科普资料层：它把线性代数、概率、随机过程、优化、时间序列、多元统计、机器学习、CAPM、APT、Fama-French、Black-Litterman、MAD、利率模型等概念讲成入门图解，能帮助新手建立“量化工具箱”索引。

它不能作为策略有效性证据。文章没有给出可复现实证数据、样本区间、交易成本、参数稳定性、未来函数审计、样本外检验或负控设计，因此不能支持任何 `promote`、实盘开关或正式研究结论。若后续要把其中某个概念转化为研究，必须另建 RD/EX，按预注册规则写清假设、预测、基准、证伪条件、平台配置和结果路径。

## 主题归纳

- 数学基础线：线性代数、微积分、概率论、随机过程、微分方程、优化理论、时间序列、多元统计、机器学习。
- 组合与资产定价线：CAPM、APT、Fama-French、期权定价、信用定价、马科维茨均值方差、CAL/CML、MAD、市场风险、Black-Litterman、信用风险、静态利率模型。
- 对本库的直接价值：术语索引、新手学习路线、后续文献卡或机制卡的概念入口。
- 对本库的禁止用途：不得直接把文中“能降低风险”“能提高收益”“可寻找低估机会”等教学表述登记为已验证因子或策略结论。

## 逐篇阅读摘要

| 序号 | 日期 | 文章 | 摘要 | 研究库处理 |
| --- | --- | --- | --- | --- |
| 1 | 2026-05-29 | [漫画解读-量化交易之线性代数](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486245&idx=1&sn=8514a1462aa84fcaac430953f9b5456a&chksm=f473a0f8c30429eebcb6c3a08c1eeae54c2a2b73afc6a85c1ea1529088fdc5a891ddfa8e2310#rd) | 用向量表达组合权重，用矩阵表达多股票多时点价格或收益；矩阵乘权重可得到组合收益。还用线性方程组、特征值/特征向量、PCA 和最小二乘说明组合构建、降维和趋势拟合。 | 作为矩阵、PCA、最小二乘的入门说明；不能替代实证检验。 |
| 2 | 2026-05-29 | [漫画解读-量化交易之微积分](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486255&idx=1&sn=985e55beb9237d3965a0ddb47207eed2&chksm=f473a0f2c30429e434700b017dfe16388cf7dad9d5df3f7ef0f65f8c7ffac8e93ce7fdc6f739#wechat_redirect) | 微分用于观察价格变化速度、趋势斜率和即时边际变化；积分用于累计成本、累计收益或一段时间内的总变化；优化问题用来寻找最大收益或最小风险点。 | 可转成“变化率/累计量/优化目标”术语解释。 |
| 3 | 2026-05-29 | [漫画解读-量化交易之概率论](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486265&idx=1&sn=a88490036dc686fc1b2c4f4aeeecd24c&chksm=f473a0e4c30429f2c574272a0ac661b14aa76a8d7b4978a5e27ffb67290c092c5fb86486b0e5#wechat_redirect) | 用概率分布描述价格或收益的不确定区间，用统计检验和 P 值判断超额收益是否可能只是偶然；用正态分布、均值和方差介绍组合收益与风险权衡。 | 可作为概率分布、显著性、均值方差的入门索引。 |
| 4 | 2026-06-01 | [漫画解读-量化交易之随机过程](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486318&idx=1&sn=fe743cfab423ae3d9c79e35a19981a83&chksm=f473a0b3c30429a523d9d65a70075d4c803a3e57e542f72566a823dbb4e976f9bfbdbf16cf12#wechat_redirect) | 把市场波动拆成可预测趋势和不可预测随机扰动；用布朗运动、蒙特卡洛和马尔可夫状态切换解释价格路径模拟、风险评估、止损止盈和状态转移。 | 可转成状态机和蒙特卡洛的术语入口；不能作为状态信号有效性证明。 |
| 5 | 2026-06-02 | [漫画解读-量化交易之微分方程](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486385&idx=1&sn=c2d995d14c3c607205b9f47bab594a88&chksm=f473a06cc304297aee4d8812d63ae57ea369a0ddaed827d12a3cd66b0ead8ad677c768ed4637#wechat_redirect) | 通过梯度和方程描述市场变量随时间变化的关系；ODE 可表达恒定增长率，PDE 可引入波动率、利率等多因素；动态对冲可被看成持续调整组合以稳定回报。 | 适合作为动态系统和期权/PDE 的概念铺垫。 |
| 6 | 2026-06-03 | [漫画解读-量化交易之优化理论](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486496&idx=1&sn=20463dec7e70a9d81e8ea46221978a4a&chksm=f473a7fdc3042eeb20dcb922e5a9ab2439c2af3ebb939678ec2533d16d89f24f6244de5ae240#wechat_redirect) | 说明投资组合优化是在“收益最大”和“风险最小”之间寻找平衡；通过分散化降低单票风险，并引出马科维茨均值方差模型。 | 可作为组合优化概念索引；不直接给出本库可用权重模型。 |
| 7 | 2026-06-04 | [漫画解读-量化交易之时间序列](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486467&idx=1&sn=ab11fc8a51aa055e817373a9a503aa75&chksm=f473a7dec3042ec83486426997bd9d5598d0dd971643e46ec13d21f1580eecffd722f554ce6d#wechat_redirect) | 时间序列是按时间排序的数据，可拆成长周期趋势、周期波动和随机噪声；AR/MA 类模型用过去数据预测未来，并用于监测市场模式和触发交易判断。 | 可作为 AR/MA、趋势/周期/噪声分解的学习入口。 |
| 8 | 2026-06-05 | [漫画解读-量化交易之多元统计分析](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486572&idx=1&sn=ae800f2b116dd63c02206da631d874b8&chksm=f473a7b1c3042ea7f03f483bb58bbb6ba2ec83a17e16e6129b8a82247be0670e112cbe0dcbd9#wechat_redirect) | 把价格、成交量、情绪等多个变量放在一起分析；PCA 用少数主成分保留主要信息，因子分析用于寻找隐藏共性因子，目标是降低噪声并把握主要结构。 | 可作为 PCA/因子分析的术语说明；不能证明任何压缩特征有效。 |
| 9 | 2026-06-06 | [漫画解读-量化交易之机器学习](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486573&idx=1&sn=04258cd58cc0acd7cd86d67300110478&chksm=f473a7b0c3042ea64a20cd615c45ac479293147944369f8a2f6dc60efce3321410c440edd591#wechat_redirect) | 介绍机器学习从历史数据中学习规律，特征可包含价格、成交量和情绪；线性回归解释特征与价格关系，决策树做买卖判断，模型评估用于控制风险，PCA 可简化变量。 | 可作为 ML 基础概念索引；本库若采用必须有样本外和泄漏审计。 |
| 10 | 2026-06-07 | [漫画解读-资本资产定价模型](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486575&idx=1&sn=d60e4aba36761918c061f18a6169e392&chksm=f473a7b2c3042ea48e33faac827433d3bf2e32c953f47278c59fdac0cc16448e18146f399793#wechat_redirect) | CAPM 用无风险收益率、市场风险溢价和 Beta 估计资产预期收益，公式为 `E(Ri)=Rf+βi*(E(Rm)-Rf)`；Alpha 和 Beta 可帮助评价股票相对市场的表现和风险。 | 可补 CAPM、Beta、Alpha 术语；不能直接作为选股因子证据。 |
| 11 | 2026-06-08 | [漫画解读-量化交易之套利定价理论（APT）](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486596&idx=1&sn=4c0cde985cce4a6246fc7641823dbb97&chksm=f473a759c3042e4ff8a49cf5fca44f67079db605ca1b7cd94974f7d8394b9455e2cbe9472576#wechat_redirect) | APT 相比 CAPM 更强调多个宏观或市场因素共同决定收益，例如 GDP、通胀、利率等；收益可拆成 alpha、多因子敏感度和误差，并据此寻找高估/低估机会。 | 可作为多因子敏感度和套利定价入口；不提供可用因子清单。 |
| 12 | 2026-06-09 | [漫画解读-量化交易之FamaFrench因子模型](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486674&idx=1&sn=a8bce2fd028bbdc338f103615b0e84ce&chksm=f473a70fc3042e1987cff8759a9c001687e8ecf656d8b3e6c5ea8a84a6ec850d0142f77166fb#wechat_redirect) | 在 CAPM 市场因子之外加入规模因子 SMB 和价值因子 HML；说明小公司历史上可能有更高回报，价值股可能相对成长股有不同风险收益特征。 | 可补 Fama-French、SMB、HML 术语；不替代 A 股因子检验。 |
| 13 | 2026-06-10 | [漫画解读-量化交易之期权定价模型](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486727&idx=1&sn=0cbd47cef90b6538469cd9aca48d99e3&chksm=f473a6dac3042fcca84497cea62f193b648c64ca819da7a89870e9460f3a7f53f4e572ee2145#wechat_redirect) | 用 Black-Scholes 等模型根据标的价格、执行价、到期时间、波动率和利率计算期权合理价格；低估或高估可形成交易判断。 | 可作为期权定价变量说明；本库股票/ETF方向暂不直接转实验。 |
| 14 | 2026-06-12 | [漫画解读-量化交易之信用定价模型](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486824&idx=1&sn=a9a77b88ed43f96c5b2c4177783bedac&chksm=f473a6b5c3042fa37a15820bdd818bd23a4e707bccd18384a707c3a7e6f31adad86326adeaaf#wechat_redirect) | 说明信用风险会影响债券或股票的合理价格；高信用风险需要更高收益补偿，模型价格与市场价格差异可被解释为低估或高估。 | 可作为信用风险补偿概念入口；不直接适配当前 A 股轮动实验。 |
| 15 | 2026-06-16 | [漫画解读-量化交易之马科维茨均值方差模型](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486885&idx=1&sn=0ff76a5d8a922e80768d928e29e5db13&chksm=f473a678c3042f6eea475c9741e0e694adef727aca8ed9f1d43f5a8866d2c788e70ab754f315#wechat_redirect) | 收集股票历史收益，分别关注平均收益和方差/标准差风险；目标是在相同收益下降低风险，或在相同风险下提高收益，并输出股票与现金配置比例。 | 可作为均值方差模型入口；正式使用前必须处理估计误差和样本外稳定性。 |
| 16 | 2026-06-18 | [漫画解读-量化交易之资本配置线（CAL）与资本市场线（CML）](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486940&idx=1&sn=dca7a90411f1d34d0c1788a1d32affb7&chksm=f473a601c3042f17d1064192e2119cee4794823e2b4ef97361e34003ded11cd7aba9cc7faa0f#wechat_redirect) | CAL 描述无风险资产和某个风险资产组合之间的配比关系；CML 描述无风险资产与市场组合之间的有效配置关系，理论上给出同风险下更高收益的组合边界。 | 可补 CAL/CML 术语；不作为组合杠杆或仓位规则。 |
| 17 | 2026-06-23 | [漫画解读-量化交易之均值绝对偏差模型（MAD）](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247486959&idx=1&sn=9336fb71c909591509a94dce42967577&chksm=f473a632c3042f242777f038005cd3bbc99469341d875c64923b99ef2e50a15ddeb1f139c021#wechat_redirect) | MAD 用收益相对均值的绝对偏离衡量波动，强调选择平均回报较好且偏离较小的资产，作为比方差更直观的稳健风险度量。 | 可作为稳健风险度量术语；若实验需与方差/回撤/尾部风险对照。 |
| 18 | 2026-06-25 | [漫画解读-量化交易之市场风险模型](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247487036&idx=1&sn=1755d10064597c3888fb4a5b6a66958b&chksm=f473a5e1c3042cf71fde8c24b6e9c479a87c1f610692a388d82f2ad0b076587d34792a23e589#wechat_redirect) | 市场风险模型关注价格波动和可能损失，利用历史数据估计风险大小，并据此避开高风险资产或控制组合暴露。 | 可作为 VaR/波动率/风险暴露的学习入口；不能替代风险门控回测。 |
| 19 | 2026-06-29 | [漫画解读-量化交易之BlackLitterman模型](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247487109&idx=1&sn=c2a5c428c9a8cf51b3f84d86f51461af&chksm=f473a558c3042c4e8b45fbc01d34f097f9825f44a525fffc64f4a1bf201fb0925a218fde6f62#wechat_redirect) | Black-Litterman 把市场均衡预期与投资者主观观点结合，输出更平滑的组合配置；核心价值是避免完全依赖历史均值，也避免主观观点过度支配。 | 可作为组合先验/观点融合概念入口；不直接生成本库默认权重。 |
| 20 | 2026-07-01 | [漫画解读-量化交易之信用风险模型](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247487160&idx=1&sn=481a6a598bbe27e2c8bd293cbd3e0dde&chksm=f473a565c3042c73415291c69fa34b6ae1f52f168cf9fe2e19a8f53dd8e9497d19d13b80def2#wechat_redirect) | 信用风险模型通过收入、历史表现等信息给投资对象打分，并估计违约概率；目标是识别债券、股票或其他资产的信用风险并辅助风险管理。 | 可作为信用打分和违约概率入口；当前不转交易实验。 |
| 21 | 2026-07-03 | [漫画解读-量化交易之静态利率模型](https://mp.weixin.qq.com/s?__biz=MzY5NjA0MTEzOA==&mid=2247487194&idx=1&sn=752431c60f6e9ffea696b0d7118c117b&chksm=f473a507c3042c1190bf35a432c3659a95f5d4babbb1aed5a27d22c391e60d930206353d4151#wechat_redirect) | 静态利率模型解释即期利率和远期利率，并用收益率曲线描述不同期限利率结构；可帮助理解债券定价、利率预期和投资期限选择。 | 可作为利率期限结构入门；不直接影响当前股票轮动主线。 |

## 可转化动作

- 可补充术语：CAPM、APT、Fama-French、Black-Litterman、MAD、CAL、CML、PCA、马科维茨均值方差、蒙特卡洛、马尔可夫链、收益率曲线。
- 可作为新手学习路线：先读数学基础线，再读组合与资产定价线，最后再进入顶刊文献和本库实验记录。
- 不建议直接开实验：这批资料没有提出可证伪的具体 A 股/ETF 信号。如果后续要实验，应从更严肃文献或本库已有失败/成功线索抽取明确假设。

## 局限

- 正文是漫画式科普，解释简化较多，很多结论是教学语境下的直觉表达。
- 没有样本区间、资产池、调仓规则、成本假设、交易约束、统计检验或代码。
- 没有针对 A 股、ETF、分钟执行、涨跌停、停牌、容量和流动性的本地化边界。
- 因此只能作为术语和方法目录，不作为研究证据链。

## 子代理调用记录

- 调用 ID：`SUB-20260705T130000Z-main-WXQC`
- 任务代号：`SUBTASK-20260705T130000Z-main-WXQC_子查_公众号专辑清单核对`
- 平台昵称：Heisenberg
- 模型：`gpt-5.3-codex-spark`
- 发起方：`main`
- 输入：微信公众号专辑 `量化金融漫画解读`，`album_id=4537431503202533386`，`biz=MzY5NjA0MTEzOA==`。
- 交付物：只读核对专辑文章清单、文章数量和正文形态；确认公开链路下可取得 21 篇，正文主要为图片漫画。
- 边界：子代理不做策略有效性判断，不做未来函数审计，不独立决定资料等级。
- 主控复核：主控用 `next_article_link` 链路独立抓取 21 篇页面，按篇生成预览图并逐篇视觉阅读；本文摘要由主控整理。

## 下一步

- 优先作为新手学习索引保留。
- 若维护术语库，可从“可转化动作”中挑选术语逐条补入 `09_术语库/术语库.md`。
- 若后续要转实验，必须另建研究方向或实验记录，并按正式实验硬规则预注册。
