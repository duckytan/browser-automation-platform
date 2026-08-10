# browser-automation-platform (BAP)

> 一个围绕浏览器自动化的综合项目，采用"总控 + 子 skill"的**总分模式**（参考三司会审 + 4 诀的成熟架构）。

## 🎯 项目目标

构建一个**完整**的浏览器自动化平台，覆盖：

| 层 | 组件 |
|---|---|
| **总控** | `browser-hub`（编排器）|
| **接入层** | `browser-connector`（CDP / WebDriver / ws-cdp）|
| **操作层** | `browser-operator`（26+10 action）|
| **脚本层** | `browser-runner`（rbscript 解释执行）|
| **增强层** | `browser-humanizer` · `browser-anti-detect` · `browser-recorder` · `browser-extractor` · `browser-state-mgr` · `browser-monitor` |

## 📚 文档

完整设计文档在 [docs/v3-design.md](docs/v3-design.md)。

## 🚧 项目状态

**v3.0 设计阶段**（8-10 起 · 锡哥拍板）

- ✅ 10 项关键决策已拍板
- ✅ 总分架构设计完成
- ✅ 9 个子 skill 职责划分
- ✅ rbscript 工作流格式设计
- 🔄 代码实现待启动

## 🎬 实施路径

| 阶段 | 内容 | 工作量 |
|---|---|---|
| **MVP** | hub + connector + operator(核心 8 个) + runner + 5 模板 | ~30 小时 |
| **完整 v3.0** | MVP + 18 个剩余 action + humanizer + anti-detect + recorder + extractor + state-mgr + monitor | ~62 小时 |

## 📂 项目位置

- 仓库：`https://github.com/duckytan/browser-automation-platform`
- 本地：`~/projects/browser-automation-platform/`

## 📜 决策记录

8-10 16:16 锡哥拍板 10 项决策，详见 [docs/v3-design.md §10](docs/v3-design.md)。

## 📄 License

MIT

---

_项目 v3.0 · 2026-08-10 · 待实施_