# 🗓 施工计划 · BAP 路径 X（MVP）

> **依据**：docs/v3-design.md v3.2（§9）· 算术已修正（4 司会审）
> **范围**：P1-P5 · 22.1h / 164K

---

## 阶段排期

| P | 内容 | 工时 | Token | 依赖 | 里程碑 | 状态 |
|---|---|---|---|---|---|---|
| **P1** | 项目骨架 + monorepo + install.sh（软链接）| 3.1h | 18K | 无 | 8 目录 + just + justfile + 5 模板 | ⏳ 待开工 |
| **P2** | Just 引擎集成 + 5 个 .just 模板 + wrapper | 4.5h | 29K | P1 | `just --list` 全 recipe | ⏳ |
| **P3** | connector（5 action）| 3.5h | 27K | P1 | 接入完成 | ⏳ |
| **P4** | operator（33 action）| 7h | 58K | P3 | 操作 MVP | ⏳ |
| **P5** | hub（含 Just 调用 wrapper）| 4h | 32K | P2 | 总控可用 | ⏳ |
| **总计** | | **22.1h** | **164K** | | `just smoke` 跑通 | |

---

## 关键里程碑（MVP 完成定义）

1. **`just --list`** 显示全部 recipe（P2 完成）
2. **`just smoke`** 冒烟跑通 = connector 接入 + operator 操作（P5 完成 · 路径 X 演示）
3. **完整 weibo-login** 待 P6（humanizer 后 · 不在路径 X 范围）

---

## 会话分段

| 段 | 阶段 | Token | 累计 |
|---|---|---|---|
| 会话 1 | P1-P5 | 164K | 164K |

**临界警示**：单会话 > 500K 强制开新会话。

---

## 风险预案

| 风险 | 触发 | 行动 |
|---|---|---|
| P1-P2 实际超时 >30% | just 安装/模板语法反复出错 | 全量重估 P3-P5（老子知几 0.30 置信）|
| just 装不上 | 网络/GitHub 限速 | 记 BLOCKED，试镜像 |
| 模板空壳导致演示失败 | 5 .just 未填 | 填内容后再演示 |

---

_施工计划 v1.0 · 周星星 🌟 · 2026-08-10 · 待开工_
