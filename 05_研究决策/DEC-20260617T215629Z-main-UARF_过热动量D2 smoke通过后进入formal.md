---
type: 研究决策
dec_id: DEC-20260617T215629Z-main-UARF
rd_ids: [RD-20260614T115209Z-main-MCYG]
ex_ids: [EX-20260617T212938Z-main-LJQ7, EX-20260617T213634Z-main-XA5U]
decision: promote_candidate
owner: main
created_at: 2026-06-17T21:56:29Z
updated_at: 2026-06-17T21:58:00Z
impact: direction
subagent_call_ids: []
subagent_exemption: 当前可用子代理工具需用户显式要求委派/并行 agent，本轮没有显式授权；主控：main；时间：2026-06-17T21:58:00Z
tags: [双池轮动, 防御模块, 动量崩溃, R010D, 过热动量, formal候选]
---

# 过热动量D2 smoke通过后进入formal

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|双池轮动动量崩溃事前暴露管理]]
- 关键实验：[[04_实验记录/EX-20260617T212938Z-main-LJQ7_DM前置风险标签只读面板|LJQ7 DM 前置风险标签只读面板]]；[[04_实验记录/EX-20260617T213634Z-main-XA5U_过热动量前置暴露D2 smoke|XA5U 过热动量前置暴露 D2 smoke]]
- 上一张决策：
- 后续实验：待新建 XA5U 四段 formal + 负控
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`promote_candidate`

## 这个节点是什么

本决策处理 MCYG 的修订路线：J7EF 原来的“方差缩放 + 状态门控”在 2024 smoke 里像事后压仓，LJQ7 的 broad-any 风险标签也太滞后；但 LJQ7 的“过热动量”子标签和 XA5U 的真实组合 smoke 显示，已有 `R010D_D2_OVERHEAT` 动作值得进入正式四段验证。

## 相比上一个节点改变了什么

- 放弃 broad-any A1 风险并集作为前置暴露层。
- 不继续 J7EF 原 `target_vol=30% + unfavorable/state_or_blowoff` 20 组 formal。
- 把 MCYG 下一步改为 overheat-only：`R010D_D2_OVERHEAT(cap=0.90, keep_current=true)` 四段 formal + 延迟/随机/成本负控。

## 子代理依据来源

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前可用子代理工具需用户显式要求委派/并行 agent，本轮没有显式授权；主控：main；时间：2026-06-17T21:58:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：

无；本轮没有实际子代理调用。

## 支持证据

- LJQ7 子标签 `front_existing_overheated_momentum`：支持 `188`，H10 路径最低收益均值比未标记 A1 多差 `1.35pp`，`preemptive_bad10_lift` `+20.11pp`，`already_dd5_rate` `42.55%`，优于 delay5/future5/random 同支持度负控。
- XA5U 2024 当前代码口径 baseline：final `167005.22`，MDD `-26.99%`，交易 `281`。
- XA5U `r010d_d2_overheat_cap90_keep_current`：final `181373.71`，MDD `-22.80%`，交易 `255`，触发 `36` 次；final 多 `14368.49`，MDD 改善 `4.20pp`，`economic_smoke_pass=true`。

## 反对证据

- LJQ7 主标签 `front_existing_any` 未通过：H10 路径风险只比未标记 A1 多差 `0.73pp`，触发时 `53.26%` 已在 20 日回撤 5% 后。
- XA5U 只有 2024 smoke，尚未证明跨分段稳定，也未做成本扰动、延迟触发、随机触发负控。
- D2-overheat 的收益改善可能来自少换仓和保留旧仓，不一定来自仓位 cap；formal 必须做动作归因。

## 边界

不能说明 D2-overheat 已验证有效，不能改实盘、不能 shadow、不能 observe。仍不确定：2020_2021 是否同样改善回撤、2022_2023 是否错过折返、2025_20260519 强趋势段是否伤收益、成本扰动和延迟触发是否稳健、随机 overheat 日期是否能复制结果。

## 后续动作

- 新开 XA5U 四段 formal 预注册：baseline vs D2-overheat。
- 同一 formal 中必须补：延迟一日触发、随机 overheat 日期、成本扰动、动作归因。
- 在 formal 通过前，不扩 `top1_ret20/top1_slope10` 阈值、不扫 cap、不改 `keep_current`，不接入实盘或 shadow。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账豁免
- [x] 术语库
