# -*- coding: utf-8 -*-
"""对账同事 env-detector-v2 结果：分期贡献 + 错位负控。
输入：chosen_strategy_daily.csv（逐日：状态/动作/收益/净值）
只读分析，不改原文件。"""
import pandas as pd
import numpy as np
from pathlib import Path

DATA = Path(r"C:/Users/Administrator/Desktop/EX-20260702-env-detector-v2")
df = pd.read_csv(DATA / "chosen_strategy_daily.csv", encoding="utf-8-sig")
df["date"] = pd.to_datetime(df["date"])
df = df.sort_values("date").reset_index(drop=True)
print(f"总天数={len(df)}  范围={df['date'].min().date()}~{df['date'].max().date()}")
print(f"累计净值={df['equity'].iloc[-1]:.4f}  累计收益={(df['equity'].iloc[-1]-1)*100:.1f}%")
print(f"交易日均收益={df['strategy_return'].mean()*100:.4f}%  年化≈{(1+df['strategy_return'].mean())**250-1:.1%}")
print()

# ============ 检验1：分期贡献 ============
print("="*70)
print("检验1：分期贡献（看2025/2026牛市占比）")
print("="*70)
df["year"] = df["date"].dt.year
for y, g in df.groupby("year"):
    days = len(g)
    ret = (1 + g["strategy_return"]).prod() - 1
    avg = g["strategy_return"].mean()
    active = (g["selected_action"] != "cash").sum()
    print(f"  {y}: {days}天  当年收益={ret*100:7.1f}%  日均={avg*100:6.4f}%  持仓天数={active}/{days}")

# 拆两段
early = df[df["date"] < "2025-01-01"]
late = df[df["date"] >= "2025-01-01"]
print(f"\n  2022-2024段: {len(early)}天 累计={( (1+early['strategy_return']).prod()-1 )*100:.1f}%")
print(f"  2025-2026段: {len(late)}天 累计={( (1+late['strategy_return']).prod()-1 )*100:.1f}%")
print(f"  → 2025+贡献了总收益的 {((1+late['strategy_return']).prod()-1) / ((1+df['strategy_return']).prod()-1) *100:.1f}%")
print()

# ============ 检验2：错位负控 ============
print("="*70)
print("检验2：错位负控（状态滞后1天，看策略收益是否衰减）")
print("="*70)
# 动作映射：每个class_cn对应一个action（从candidate_summary规则）
# 低动量→cash, 未触发hard5→hard5_below_rank1, 样本偏薄→hard5_below_rank1,
# 多高分但边界不清→score_5_12_rank1, 单点高分尖峰→rank3,
# 分化高分尾部→hard5_below_rank1, 普涨高热→rank3(有gate), 高分未分型→cash
# 简化负控：用【昨天的状态】决定【今天的动作】，但今天的可用候选标的收益不变

# 每个class的平均次日收益（基准）
print("\n各状态实际表现（原始，状态对齐当日）：")
for c, g in df.groupby("class_cn"):
    if len(g) < 10: continue
    ret = (1+g["strategy_return"]).prod()-1
    print(f"  {c:12s}: {len(g):4d}天  累计={ret*100:7.1f}%  日均={g['strategy_return'].mean()*100:6.4f}%")

# 错位：今天的动作=昨天class对应的"代表性收益"
# 做法：把 strategy_return 按昨天 class 重新聚合
df["prev_class"] = df["class_cn"].shift(1)
# 对每个class，计算其"代表性日均收益"（用该class所有日期的strategy_return均值）
class_avg_ret = df.groupby("class_cn")["strategy_return"].mean().to_dict()
# 负控策略：今天用昨天的class，套用那个class的代表性日均收益
df["lagged_return"] = df["prev_class"].map(class_avg_ret)
lag_valid = df.dropna(subset=["lagged_return"])
print(f"\n错位负控（用昨天状态映射的代表性收益）：")
print(f"  原策略日均收益:  {df['strategy_return'].mean()*100:.4f}%")
print(f"  负控日均收益:    {lag_valid['lagged_return'].mean()*100:.4f}%")
print(f"  衰减率: {(1 - lag_valid['lagged_return'].mean()/df['strategy_return'].mean())*100:.1f}%")
print(f"  负控复制率: {lag_valid['lagged_return'].mean()/df['strategy_return'].mean()*100:.1f}%")

# 更严格的负控：昨天class决定今天action，但用action的实际历史平均
print("\n按动作维度的负控（昨天class→昨天action→今天套用该action历史平均）：")
action_avg = df.groupby("selected_action")["strategy_return"].mean().to_dict()
# 昨天class → 昨天该class最常见的action
class_to_action = {}
for c, g in df.groupby("class_cn"):
    if len(g)>0:
        class_to_action[c] = g["selected_action"].mode().iloc[0]
print("  状态→动作映射:")
for c,a in class_to_action.items():
    print(f"    {c:12s} → {a:20s} (该action历史日均={action_avg.get(a,0)*100:.4f}%)")
df["lagged_action"] = df["prev_class"].map(class_to_action)
df["lagged_return_v2"] = df["lagged_action"].map(action_avg)
lag2 = df.dropna(subset=["lagged_return_v2"])
print(f"\n  原策略日均:      {df['strategy_return'].mean()*100:.4f}%")
print(f"  动作负控日均:    {lag2['lagged_return_v2'].mean()*100:.4f}%")
print(f"  复制率: {lag2['lagged_return_v2'].mean()/df['strategy_return'].mean()*100:.1f}%")
