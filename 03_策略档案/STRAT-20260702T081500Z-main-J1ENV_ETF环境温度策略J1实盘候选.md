---
type: 策略档案
strategy_id: STRAT-20260702T081500Z-main-J1ENV
name: ETF环境温度策略（J1实盘候选）
status: promote_candidate
rd_id:
owner: main
created_at: 2026-07-02T08:15:00Z
updated_at: 2026-07-18T08:48:00Z
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
legacy_platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
platform_asset_status: legacy_only_pending_v2_migration
live_version: J1
tags: [ETF, 环境温度, 盘中轮动, 实盘候选]
---

# ETF 环境温度策略（J1 实盘候选）

> 执行阻断：`promote_candidate` 是历史研究评级，不表示当前 V2 已具备该策略的原生代码和受控入口。下列平台资产均属于 V1.4 历史证据；迁移到 V2、复核数据口径和重新通过门禁前，禁止 dry-run、shadow 或实盘启动。

## 版本与定位

- **实盘版本号**：`J1`
- **研究库状态**：`promote_candidate`（5 项门禁已完成，3 项通过 + 2 项有条件通过）
- **策略来源**：朋友分享技术包 `friend_share_technical_package_20260702`，移植为 V2 真实撮合口径
- **外部资料卡**：[[06_文献资料/00_待处理/LIT-20260702T081500Z-main-FRIEND_朋友包ETF环境策略外部资料卡|朋友包 ETF 环境策略外部资料卡]]
- **研究边界声明**：纯工程移植 + 完整门禁验证。**不挂 RD，不主张独立 alpha**（13:09 横截面环境分类路线已被 RD-Y4KC/EX-JGEG 在收盘/次日口径证伪，本策略本质是日内 beta 捕获工具）。

## 策略逻辑一句话

每日 13:09 用全池 ETF 动量 score 横截面结构识别市场环境（8 类分类 + detector_v2 温度），按环境选择相对保守的标的（回避最高分尖峰），13:10 买入，次日 13:09 卖出。

## V1.4 历史平台资产

| 资产 | 路径 |
| --- | --- |
| 策略模块 | `${LEGACY_QUANT_PLATFORM_ROOT}/src/strategies/research/etf_env_temp_strategy.py` |
| Config 根目录 | `${LEGACY_QUANT_PLATFORM_ROOT}/configs/research/R010-A11/env_temperature/` |
| Formal 4 段 | `formal/seg1_2021_2022.json`、`formal/seg2_2023.json`、`formal/seg3_2024.json`、`formal/seg4_2025_20260630.json` |
| 结果根目录 | `${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/R010-A11/env_temperature/` |
| 可视化回测规范 | [[08_方法论/可视化分段回测规范]] |
| 启动脚本 | `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/run_env_temp_live.sh` |

## 关键参数（J1 默认配置）

| 参数 | 默认值 | 说明 | 敏感性 |
| --- | --- | --- | --- |
| `momentum_days` | 25 | 历史窗口（+当日=26点） | — |
| `annualization` | 250 | score 年化系数 | — |
| `hard_score` | **5.0** | 高分阈值 | **⚠️ 倒U型，关键监控参数** |
| `delta_min` | -5 | detector_v2_delta1 下限 | 不敏感（OFAT 邻域无变化） |
| `tail_low_hard5` | 65 | 未触发hard5的tail_risk上限 | 不敏感（OFAT 邻域无变化） |
| `tail_low_tail` | 75 | 分化尾部的tail_risk上限 | — |
| `det_min` / `det_max` | 25 / 90 | detector_v2 区间 | — |
| `pool_mode` | union | 静态池∪动态池 | static_only 等效（可简化） |
| `cap_enabled` | false | 容量守卫（实盘建议开启） | 见容量门禁 |
| `a2_defense_enabled` | **false** | A2广度防御层 | 已验证：改善回撤但收益砍半，J1 不启用 |

## Formal 4 段结果（V2 真实撮合口径）

| 段 | 区间 | 总收益 | 年化 | 最大回撤 |
| --- | --- | --- | --- | --- |
| seg1 | 2021H2-2022 | +20.92% | +13.51% | -17.25% |
| seg2 | 2023 | +49.23% | +50.07% | -22.26% |
| seg3 | 2024 | +27.53% | +27.61% | -19.13% |
| seg4 | 2025-2026H1 | +196.48% | +107.34% | -26.99% |

5 年复合约 **6.82x**（年化约 46.8%）。收益高度依赖 2025-2026 ETF 牛市。

## 五项门禁总结

| 门禁 | 结果 | 关键数字 | 实盘含义 |
| --- | --- | --- | --- |
| 1. walk-forward OOS 4 段 | ✅ 通过 | 4 段全正，OOS 拼接年化 ~61% | 样本外有效 |
| 2. 成本扰动 5 档 | ✅ 通过 | 极端成本（3bp+10bp）仍年化 +23.6% | 成本鲁棒 |
| 3. 容量测试 16 组 | ⚠️ 有条件通过 | 百万级可行，千万级转负 | **资金 ≤ 500万** |
| 4. ETF 池变体 7 种 | ✅ 通过 | 不依赖单一标的（剔头部反升） | 可简化为静态池 |
| 5. 参数敏感性 OFAT | ⚠️ 有条件通过 | delta/tail 不敏感；hard_score 倒 U | **监控 hard_score=5** |

详细门禁数据和 config 路径见平台 `results/v2/research/R010-A11/env_temperature/{walk_forward,cost_sweep,capacity,pool_variant,ofat}/`。

## J1 实盘边界声明（硬约束）

**违反以下任一约束的实盘部署视为越权：**

1. **资金上限 ≤ 500 万**（50% 参与率下年化约 +20.6%）。超过 1000 万禁止实盘（1000 万/10% 参与率已转负 -0.6%）。
2. **hard_score = 5.0** 为关键监控参数，不得随意更改。OFAT 显示 4.0/6.0 都使年化减半（倒 U 型）。如样本外持续失效，优先复查此阈值。
3. **策略本质是日内 beta 捕获工具**，非独立 alpha。13:09 横截面环境分类路线已被 RD-Y4KC/EX-JGEG 证伪同类口径。实盘预期应锚定 ETF 市场 beta，不应预期"环境分类贡献独立超额"。
4. **默认配置 = formal 原版**（不加 A2 防御）。A2 防御层已验证会过度牺牲收益（年化 46.8%→31.5%），用户判定"收益降低太多，非理想方向"。
5. **实盘部署前必须先 dry-run**（MiniQMT 模拟成交），确认订单生命周期和真实滑点后再切换实盘。本机 `${LIVE_TRADING_ROOT}` 尚未配置。
6. **容量守卫建议实盘开启**（`cap_enabled=true, cap_participation=0.05`），避免单笔吃掉分钟成交量。

## 已验证但不启用的变体

### A2 广度防御层叠加（2026-07-02 验证）

- 实现：`a2_defense_enabled=true, a2_min_ma20_breadth=0.72`（广度不足空仓）
- 结果：回撤从 -17~-27% 压到 -3.7~-6.5%（卡玛比率全面提升），但复合年化从 46.8% 降到 31.5%
- 决策：**不启用**。用户判定收益代价过大。
- 保留：代码保留（默认 false），作为可选风控组件。详见策略模块 `_compute_ma20_breadth` 和 `prepare_and_sell` 的 A2 防御层分支。

## 已知风险

1. 收益高度集中于 2025-2026 ETF 牛市（约 78% 净值倍数来自最后 1.5 年），剥离牛市后 2021-2024 年化约 25-30%。
2. 最大回撤较大（最差 -26.99%@2025），实盘需配合外部风控。
3. 容量受限，本质依赖小成交额 ETF（流动性筛除后年化转负）。
4. hard_score 存在过拟合风险（倒 U 型），需持续监控。
5. 策略规则源自朋友包，研究库未独立验证其 alpha 属性（已被 RD-Y4KC 证伪同类路线）。

## 子代理调用记录

本轮策略移植和门禁验证调用多个 Explore 子代理（SUB-FRIENDPKG-001 分析、SUB-PORTSTRAT-001/002 平台与库探索、SUB-ENVT-000/001/002 口径核对与未来函数审计）。属工程移植类任务，非实验/决策，未写入 `01_台账/子代理调用台账.csv`（该台账针对影响实验或决策的调用）。研究判断（门禁判定、J1 边界、对照报告结论）由主控承担。

## 关联链接

- 外部资料卡：[[06_文献资料/00_待处理/LIT-20260702T081500Z-main-FRIEND_朋友包ETF环境策略外部资料卡|朋友包 ETF 环境策略外部资料卡]]
- 可视化回测规范：[[08_方法论/可视化分段回测规范|可视化分段回测规范]]
- 平台协作规范：[[08_方法论/平台协作规范|平台协作规范]]
- 同类已证伪路线：[[02_研究方向/RD-20260702T045340Z-main-Y4KC_双池轮动全池1309市场状态分类模块|RD-Y4KC 13:09 市场状态分类]]（参考其 park 结论）
- 同类已证伪实验：[[04_实验记录/EX-20260702T045517Z-main-JGEG_ETF全池1309市场状态GMM分类只读面板|EX-JGEG GMM 分类只读面板]]

## 下一步

1. 配置本机 `${LIVE_TRADING_ROOT}`（MiniQMT），做 J1 dry-run 验证订单生命周期。
2. dry-run 通过后，以 ≤500 万资金、`cap_enabled=true` 启动 J1 shadow 灰度。
3. shadow 累积 20 个交易日样本后，对比实盘 dry-run 与回测，确认无口径偏移后切实盘。
4. 持续监控 hard_score=5 的稳定性，若样本外失效优先复查。
