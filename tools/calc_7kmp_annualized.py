#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""选项2: V2 vs hard5 全年年化对比（四段几何拼接）。"""
import glob, json, os
from datetime import date

ROOT = "/mnt/e/量化平台_V1.4.0/results/v2/research/R010-A22/overnight_timed_paired/EX-20260622T133000Z-main-7KMP/formal"

SEGS = {
    "2020_2021": (date(2020, 1, 1), date(2021, 12, 31)),
    "2022_2023": (date(2022, 1, 1), date(2023, 12, 31)),
    "2024": (date(2024, 1, 1), date(2024, 12, 31)),
    "2025_20260519": (date(2025, 1, 1), date(2026, 5, 19)),
}
SEG_YEARS = {s: (e - st).days / 365.25 for s, (st, e) in SEGS.items()}
TOTAL_YEARS = (date(2026, 5, 19) - date(2020, 1, 1)).days / 365.25

def seg_final(v, cost, s):
    sps = glob.glob(f"{ROOT}/{v}/{cost}/{s}/*/summary.json")
    if not sps:
        return None
    sp = sorted(sps, key=os.path.getmtime, reverse=True)[0]
    return json.loads(open(sp, encoding="utf-8").read())["statistics"]["final_value"]

def annualized(v, cost):
    prod = 1.0
    yrs = 0.0
    parts = []
    for s in ["2020_2021", "2022_2023", "2024", "2025_20260519"]:
        fv = seg_final(v, cost, s)
        y = SEG_YEARS[s]
        if fv is None:
            parts.append((s, None, y))
            continue
        r = fv / 100000.0
        prod *= r
        yrs += y
        parts.append((s, r, y))
    ann = prod ** (1.0 / yrs) - 1.0 if yrs > 0 else None
    return ann, prod, yrs, parts

print(f"段年数(日历天数), 总跨度 {TOTAL_YEARS:.3f}y")
for s, y in SEG_YEARS.items():
    print(f"  {s}: {y:.3f}y")

for cost in ["cost1x", "cost2x_slip2bps"]:
    print("\n" + "=" * 60)
    print(f"[{cost}] 全年年化对比")
    print("=" * 60)
    for v, nm in [("baseline_hard5", "hard5"),
                  ("cand_full_release_low_share", "V2满仓放行"),
                  ("cand_timed_low_share", "V2+市场门")]:
        ann, prod, yrs, parts = annualized(v, cost)
        print(f"\n{nm}:")
        for s, r, y in parts:
            if r is None:
                print(f"  {s}: NA")
            else:
                print(f"  {s}: {r:.4f} ({(r-1)*100:+.1f}%, {y:.3f}y)")
        print(f"  => 累计净值={prod:.4f} 年化={ann*100:+.2f}%")
