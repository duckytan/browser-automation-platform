# 🗓 施工计划 · BAP 路径 X（MVP）

> **依据**：docs/v3-design.md v3.2（§9）· 算术已修正（4 司会审 + 施工文档审计 8 项已修）
> **范围**：路径 X · P1-P5 · 22.1h / 164K

---

## 阶段排期

| P | 内容 | 工时 | Token | 依赖 | 里程碑 | 状态 |
|---|---|---|---|---|---|---|
| **P1** | 项目骨架 + monorepo + install.sh（软链接 dry-run）| 3.1h | 18K | 无 | 8 目录 + just + justfile + 5 模板骨架 | ⏳ 待开工 |
| **P2** | Just 引擎集成 + 5 个 .just 模板实际编排 + wrapper | 4.5h | 29K | P1 | `just --list` 全 recipe | ⏳ |
| **P3** | connector（5 action）| 3.5h | 27K | P1 | 接入完成 | ⏳ |
| **P4** | operator（33 action · 拆 4 子任务）| 7h | 58K | P3 | 操作 MVP | ⏳ |
| **P5** | hub（含 Just 调用 wrapper）| 4h | 32K | P2 | 总控可用 | ⏳ |
| **总计** | | **22.1h** | **164K** | | `just smoke` 跑通 | |

---

### P4 拆分（老子 #7 · 7h/58K 单块不可验收）

> operator 33 action 是全盘最大单点（占工时 32%），开工前拆成 4 子任务，各带验收：

| 子任务 | action 聚类 | 预估 | 验收 |
|---|---|---|---|
| P4-a | 导航/页面（nav / goto / back / reload / shot…）| ~1.5h | `operator nav --url` 可截图 |
| P4-b | 元素交互（click / type / hover / select…）| ~2h | `operator click --selector` 可点 |
| P4-c | 表单/等待/JS（fill / wait / eval…）| ~2h | `operator eval` 可执行 JS |
| P4-d | 状态/其他（state / cookies / 收尾…）| ~1.5h | `operator state` 可读 context |

> 每个子任务完成后更新 PROGRESS.md，爆雷时能定位到子聚类。

---

## 关键里程碑（MVP 完成定义）

1. **`just --list`** 显示全部 recipe（P2 完成）
2. **`just smoke`** 冒烟跑通 = connector 接入 + operator 操作（P5 完成 · 路径 X 演示）
3. **完整 weibo-login** 待 P6（humanizer 后 · 不在路径 X 范围）

---

## 会话分段（老子 #4 映射澄清）

| 段 | 阶段 | Token | 累计 |
|---|---|---|---|
| 会话 1 | P1-P5 | 164K | 164K |

**映射说明（老子 #4）**：164K token = 单会话**上下文量**，22.1h = 跨天**工作量**，两者不冲突。164K 指 P1-P5 全部代码/文档写入的累计 token，可跨多个实际操作会话完成（每次用 PROGRESS.md 续跑），不要求一次开到底。

**临界警示**：单会话 > 500K 强制开新会话。

---

## 风险预案（含校准探针 · 老子 #1）

| 风险 | 触发 | 行动 |
|---|---|---|
| P1-P2 实际超时 >30% | just 安装/模板语法反复出错 | 全量重估 P3-P5（老子知几 0.30 置信）|
| just 装不上 | 网络/GitHub 限速 | 记 BLOCKED，试镜像 |
| 模板空壳导致演示失败 | 5 .just 未填 | 填内容后再演示 |

### 校准探针（老子 #1 · 升工时置信）

> **先把 P1-P2（3.1+4.5 = 7.6h）当「实测校准段」跑**，用真实 `just --version` / `just --list` 输出反推 P3-P5 工时：
> - 若 P1-P2 实际 ≤ 估算 → 置信 0.30 升到 ≥0.6，按原计划排 P3-P5
> - 若 P1-P2 实际 > 估算 30% → 触发全量重估（上表第一行）

_施工计划 v1.1 · 周星星 🌟 · 2026-08-10 · 待开工_
