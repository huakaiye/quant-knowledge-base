# Git 协作规范

本库会上传到 GitHub，因此命名和协作必须默认支持多人并行。

## 分支命名

推荐：

```text
research/<方向短名>/<ex_id或dec_id>
docs/<主题>
migration/<旧库主题>
```

示例：

```text
research/dual-pool/EX-20260605T115651Z-main-BASE
docs/research-methodology
migration/old-r010-b5
```

## PR 必须说明

每个 PR 至少说明：

- 改了哪些研究方向。
- 新增或修改了哪些实验、决策、文献或术语。
- 是否同步更新台账。
- 是否涉及平台路径。
- 是否有未迁移或未复核内容。

## 避免冲突

- 不使用顺序号。
- 不在同一个文件中堆积所有研究记录。
- 多个 Agent 写入时，尽量每人负责独立 ID 的文件。
- 改驾驶舱和台账前先拉取最新分支。
- 合并冲突时，以台账和正文双重核对，不只保留某一边。

## 编码规范

- 所有文本文件优先使用 UTF-8。
- 新增 Markdown、CSV、JSON、Canvas、YAML、PowerShell 脚本和 Git 配置文本时，默认使用 UTF-8 无 BOM。
- 只有为兼容 Windows PowerShell 5.1 等明确场景时，才允许使用 UTF-8 with BOM。
- 不得提交 ANSI、GBK、UTF-16 等容易造成 GitHub diff、Obsidian 预览或跨系统 Agent 读取异常的文本编码。
- 提交前运行 `tools/Test-ResearchRepo.ps1` 做 UTF-8 解码检查。

## 不入库内容

- 平台 `results/` 大文件。
- 平台 `reports/` 大型报告。
- 数据库、Parquet、Feather、HDF5。
- 论文 PDF 原文。
- 私密账号、Token、券商配置、实盘凭据。
- 本地 Obsidian 工作区状态。

## 提交前检查

建议执行：

```powershell
powershell -ExecutionPolicy Bypass -File tools/Test-ResearchRepo.ps1
```

如果涉及回测平台，还应按平台文档执行对应质量门禁。
