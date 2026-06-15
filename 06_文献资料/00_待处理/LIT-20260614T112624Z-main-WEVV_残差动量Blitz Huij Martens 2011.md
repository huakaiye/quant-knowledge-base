---
type: 文献卡
lit_id: LIT-20260614T112624Z-main-WEVV
status: todo
owner: main
created_at: 2026-06-14T11:26:24Z
updated_at: 2026-06-14T17:40:00Z
year: 2011
journal: Journal of Empirical Finance
authors: David Blitz, Joop Huij, Martin Martens
doi:
url: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2319861
related_rd_ids: []
related_factor_ids: []
related_data_ids: []
tags: [残差动量, momentum, 风险调整, 顶刊, 待迁移实验]
---

# 残差动量Blitz Huij Martens 2011

## 关联链接

- 相关方向：待关联（残差动量研究方向 RD 建设中）
- 因子灵感：残差动量（股票/ETF 收益对风险因子回归后的残差项做动量）
- 数据灵感：市场指数收益、Fama-French 因子收益
- 机制灵感：动量收益的时变因子暴露是传统动量崩溃的主因，剥离后残差更稳定
- 模块灵感：核心轮动评分构造的替代信号

## 文献信息

- 标题：Residual Momentum
- 作者：David Blitz, Joop Huij, Martin Martens（Robeco / Erasmus University）
- 年份：2011
- 期刊或来源：Journal of Empirical Finance
- DOI 或 URL：https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2319861
- 全文 PDF（Erasmus 机构库存）：https://repub.eur.nl/pub/22252/ResidualMomentum-2011.pdf

## 研究问题

传统 Jegadeesh-Titman 动量收益为什么波动极大、在某些年份（如 2009）发生严重崩溃？如果把"对市场、规模、价值等系统性风险因子的暴露"从收益中剥离掉，只用"特质收益"（残差）做动量，是否能获得更稳健、崩盘风险更低的动量收益？

## 数据

美国股票市场，横截面动量组合（多空），样本期跨越数十年。后续 Gupta-Kelly（2019, AQR）将残差动量放到大样本、多国、更长样本外区间复现，确认其样本外仍成立。

## 方法

对每个资产 i 的收益，先对 Fama-French 因子（市场、SMB、HML 等）做时间序列回归：

```text
r_i,t = alpha_i + beta_market * MKT,t + beta_smb * SMB,t + beta_hml * HML,t + epsilon_i,t
```

再用残差 `epsilon_i,t` 替代原始收益 `r_i,t` 构造动量信号（过去 12 个月累计残差，跳过最近 1 个月）。核心是把"动量"与"时变因子暴露"分离。

## 核心结论

用中文概括，不粘贴长篇原文：

1. 残差动量的风险调整收益（alpha / Sharpe）约为传统总收益动量的 **2 倍**。
2. 残差动量的时变因子暴露显著更低，尤其在市场状态切换期不像传统动量那样剧烈漂移。
3. 残差动量的崩溃风险（左尾）明显小于传统动量，因为它不再因空头端在反弹中暴涨而崩溃。
4. 后续复现文献（SSRN 2929306《Residual Momentum and Reversal Strategies Revisited》）确认主结论稳健。

## 可转化灵感

| 类型 | 灵感 | 后续卡片 |
| --- | --- | --- |
| 因子 | 用残差累计收益替代总收益动量做 ETF 排序 | 待建 FAC |
| 数据 | 需要市场指数收益（沪深300/中证全指）作为回归自变量 | 待建 DATA |
| 机制 | 剥离因子暴露降低动量崩溃风险，与本项目 hard5 过热处理目标同向 | 待建 MECH |
| 模块 | 核心轮动评分可新增"残差动量评分器"并列选项 | 待建 IDEA |

## 局限

哪些地方不能直接迁移到 A 股、ETF、ETF 日频或当前平台：

1. 原文是**月频个股**动量；本项目是**日频 ETF**动量。回归窗口、累计期、跳月规则都需要重新适配，不能直接套用 12-1 月参数。
2. A 股 ETF 的因子结构（市场、规模、价值）与美股不同，单因子市场模型可能是更稳的起点；三因子/五因子在 ETF 层面需单独验证。
3. 原文是多空组合；本项目是 Top1 纯多头持有，残差动量在多头单边排序上的增量需要单独 formal 验证。
4. ETF 本身已是组合，残差动量的"特质收益"语义比个股弱（ETF 已分散掉大部分特质风险）；这可能稀释残差动量优势，也可能因 ETF 行业 beta 差异而保留信号——必须用实验回答。

## 下一步

- 与本项目现有"25 日加权回归路径动量评分"对比：现有评分是对 log(price) 做时间回归；残差动量是对收益做因子回归。两者构造完全不同，是真正的"新信号维度"，不是换参数。
- 新建研究方向 RD（残差动量信号构造），parent 指向核心轮动模块 RD-20260605T115651Z-main-CORE。
- 新建预注册实验，baseline = 现有 25 日加权回归路径 hard5，候选 = 25 日残差动量（单因子市场模型），四段 formal + 成本扰动 + 随机/错位残差负控。
