<!-- @三司会审 v3.0 · 8-10 · 待审 -->

# browser-automation-platform (BAP) · v3.0 设计方案

> **锡哥 10 答拍板**（8-10 16:16）：
> 1A 名字 · 2A 位置 · 3D 总控名(hub) · 4A 上下文共享 · 5A rbscript · 6A CLI 调用 ·
> 7A humanizer 独立 · 8A 版本号 · 9A monorepo · 10A 先方案后实施
>
> **锡哥 16:50 拍板**：本文档不写代码实例。代码示例一律在 `docs/references/`，修改本文不需要重复修改 references/。

---

## references/ 目录

本文档中所有代码块、配置示例、脚本示例均已移至 `docs/references/` 目录，**本文档不再重复代码**。

| 子目录 | 内容 | 何时读 |
|--------|------|--------|
| `references/examples/` | 5 个完整 .rbs 工作流模板（weibo-login / bilibili-up / wechat-article / slider-captcha / batch-fetch）| 实施 P7 阶段读 |
| `references/schemas/` | `rbscript.schema.yaml`（rbscript JSON Schema）+ `browsers.example.yaml`（浏览器注册表示例）| 实施 P3 阶段读 |
| `references/install.sh.example` | 项目级安装脚本示例（含 10 个子 skill 软链接 + bap CLI 快捷方式）| 实施 P1 阶段读 |

**重要约定**：未来方案讨论中如果涉及代码，只在本文档描述"做什么 / 为什么"，具体实现一律写入 `references/`。修改本文档时不需要重复修改 references/ 内容。

---

## 1. 项目概述

### 1.1 项目目标

构建一个**围绕浏览器自动化**的综合平台，采用**总控 + 子 skill 的总分模式**——参考三司会审（总）+ 4 诀（分）的成熟架构：

- **总控层**：`browser-hub`（编排层 · 项目大脑）
- **执行层**：9 个独立子 skill（单一职责 · 可独立可用）
- **业务层**：rbscript 工作流（多步骤任务脚本）

### 1.2 名字含义

| 名 | 含义 |
|---|---|
| **browser-automation-platform** | 完整项目名 · 直白 · 一听就知道干嘛 |
| **BAP** | 缩写 · 方便记忆 · 类似 K8s / ELK |
| **browser-hub** | 总控 skill 名 · **4 个字母一眼记住** · 锡哥 16:17 "记不住 orchestrator" 拍板 |

### 1.3 ⚠️ 与 Selenium Hub 的区分（重要）

锡哥选 `browser-hub` 我必须显式说明，避免未来混淆：

| 维度 | Selenium Hub | browser-hub（本项目）|
|---|---|---|
| **是什么** | Selenium Grid 的中心节点 | BAP 项目总控编排器 |
| **职责** | 调度浏览器节点 | 编排子 skill · 跑工作流 |
| **协议** | WebDriver / BiDi | 本地 CLI 调用 |
| **关系** | Selenium 生态内部组件 | **包含并使用** Selenium（作为子 skill 之一）|

> **未来搜索/文档**：所有 "browser-hub" 提到时都要明确指本项目，**避免误导读者去查 Selenium Hub**。

### 1.4 边界声明（破妄 · 8-10 锡哥明确）

✅ **包含**：
- 浏览器接入（discover / connect / health）
- 浏览器操作（点击 / 输入 / 截图 / 26+10 action）
- 工作流编排（rbscript · Taskfile）
- 人类行为模拟（humanizer）
- 反爬指纹（anti-detect）
- 轨迹录制（recorder）
- 数据提取（extractor）
- 状态管理（cookie / login）
- 监控（monitor）

❌ **不包含**（明确边界）：
- KBH（共享知识库）
- agent-board（多 Agent 通信）
- 三司会审 / 4 诀（审查方法论）
- cron / scheduled tasks（任务调度）
- 任何**与浏览器无关**的能力

---

## 2. 总分架构

**总控层**：1 个总控 skill（browser-hub），编排所有子 skill。

**执行层**：9 个独立子 skill，单一职责，可独立调用。

**业务层**：rbscript 工作流（多步骤任务脚本）。

**关键关系**：
- 总控 → 依赖 → 子 skill（hub 编排子 skill）
- 子 skill → 独立可用（不依赖 hub）
- 子 skill 之间 → 通过 `BROWSER_HUB_CONTEXT` 环境变量共享上下文
- AI 触发 → 自然语言（hub）· 单点调用（子 skill）

详见 §3 目录结构、§5 总控设计、§6 子 skill 详细设计。

## 3. 项目结构（monorepo）

### 3.1 目录结构（精简版）

项目采用 monorepo，根目录 `~/projects/browser-automation-platform/`。

核心目录（详细目录树见 ADR-001 / 实施阶段）：

| 目录 | 作用 |
|------|------|
| `hub/` | 总控 skill（编排器 · rbscript 解析 · 上下文共享）|
| `connector/` | 子 skill 1（浏览器接入 · drivers · 浏览器注册表）|
| `operator/` | 子 skill 2（浏览器操作 · 26 个 action）|
| `runner/` | 子 skill 3（工作流执行引擎）|
| `humanizer/` | 子 skill 4（人类行为模拟 · 行为画像）|
| `anti-detect/` | 子 skill 5（反爬指纹）|
| `recorder/` | 子 skill 6（轨迹录制）|
| `extractor/` | 子 skill 7（数据提取）|
| `state-manager/` | 子 skill 8（状态管理）|
| `monitor/` | 子 skill 9（监控）|
| `docs/` | 项目级文档（含本文）|
| `docs/references/` | 参考资料（代码示例 / schema / 安装脚本）|
| `bin/` | 项目级 CLI 入口 |

子 skill 软链接到 `~/.agents/skills/`（让 OpenClaw AI 能自动加载）。

### 3.2 monorepo vs multi-repo 决策（ADR-001）

**为什么 monorepo**：

| 优势 | 体现 |
|---|---|
| 1. **统一版本** | 项目 v3.0 = 所有子 skill v1.0.0 |
| 2. **原子提交** | 跨子 skill 改动一个 commit 搞定 |
| 3. **共享文档** | docs/ 项目级共享 |
| 4. **本地开发** | 子 skill 之间联调方便 |
| 5. **CI 简单** | 一个 pipeline 跑所有 |

**为什么不是 multi-repo**：
- 锡哥个人项目 · 团队小 · 不需要严格权限分离
- 子 skill 之间耦合度中（共享 context.json）
- multi-repo 引入 git submodule / monorepo 工具（更复杂）

### 3.3 子 skill 注册到全局 skills/

每个子 skill 安装时通过符号链接到 `~/.agents/skills/`：

**好处**：
- AI 能自动加载子 skill（按需触发）
- 项目代码集中管理（升级 git pull 即可）
- 不污染 `~/.agents/skills/`（软链接透明）

---

## 4. 子 skill 清单（9 个）

### 4.1 3 核心（锡哥明确要）

| # | 子 skill | 职责 | CLI 入口 | 核心 action |
|---|---|---|---|---|
| 1 | **browser-connector** | 浏览器接入 | `browser-connector` | discover / connect / list / test / warmup |
| 2 | **browser-operator** | 浏览器操作 | `browser-operator` | nav / click / type / shot / source / text / eval / cookies + 26+10 |
| 3 | **browser-runner** | 工作流执行 | `browser-runner` | run / validate / template |

### 4.2 6 进阶（锡哥"等等各种独立功能"）

| # | 子 skill | 职责 | CLI 入口 | 核心 action |
|---|---|---|---|---|
| 4 | **browser-humanizer** | 人类行为模拟 | `browser-humanizer` | delay / drag / move-along / type-typo / profile |
| 5 | **browser-anti-detect** | 反爬指纹 | `browser-anti-detect` | stealth / rotate-fp / check-detect |
| 6 | **browser-recorder** | 轨迹录制 | `browser-recorder` | start / stop / replay / library |
| 7 | **browser-extractor** | 数据提取 | `browser-extractor` | extract / template / schema |
| 8 | **browser-state-mgr** | 状态管理 | `browser-state-mgr` | cookies-export / cookies-import / login / state |
| 9 | **browser-monitor** | 监控 | `browser-monitor` | watch / detect / alert |

---

## 5. 总控 browser-hub 设计

### 5.1 CLI 入口

### 5.2 上下文共享机制（context.json）

### 5.3 子 skill 调用协议

### 5.4 错误恢复策略

| step 失败 | 默认行为 | 可配置 |
|---|---|---|
| **non-critical step** | skip + 警告 | `on_fail: skip` |
| **critical step** | halt + 报错 | `on_fail: halt` |
| **retry step** | 重试 N 次 + backoff | `retry: {max: 3, backoff: exponential}` |
| **fallback skill** | 切换到备用 skill | `fallback_skill: anti-detect` |

---

## 段 1 结束

**段 2 将包含**：
- §6 子 skill 详细设计（9 个）
- §7 rbscript 完整语法 + schema
- §8 浏览器配置 browsers.yaml
- §9 26+10 action 详细清单
- §10 人类模拟 + 反爬细节
- §11 5 个内置工作流模板
- §12 实施阶段 P1-P12（60+ 小时工作量）
- §13 决策记录 + 风险

锡哥看完段 1 告诉我"继续"或"调整"，我立刻发段 2。

---

_本方案 v3.0 · 段 1 · 8-10 16:18 · 待三司会审_<!-- @三司会审 v3.0 · 8-10 · 待审 -->

# browser-automation-platform (BAP) · v3.0 设计方案 · 段 2（详细设计 + 实施）

> **接段 1**：5 章基础架构已发，本段含 §6-§13 完整细节
> **锡哥 10 答拍板**：1A 名字 · 2A 位置 · 3D hub · 4A context.json · 5A rbscript · 6A CLI · 7A humanizer · 8A 版本号 · 9A monorepo · 10A 先方案后实施

---

## 6. 9 个子 skill 详细设计

### 6.1 browser-connector（接入层）

**职责**：浏览器发现 / 连接 / 健康检查 / 预热

**目录结构**：
**CLI 设计**：
**核心配置文件 `config/browsers.yaml`**（YAML · 锡哥 v3.0 已选）：
**启动校验**：
- 启动时 `jq` 用 `browsers.schema.yaml` 校验 `browsers.yaml`
- 失败报错退出（不静默吞错）
- 5 类常见校验失败：缺 name/image 字段、driver 缺 endpoint、占位符未替换、JSON 语法错、浏览器名重复

---

### 6.2 browser-operator（操作层 · 26+10 action）

**职责**：浏览器所有操作 action（核心高频使用）

**目录结构**：
**36 个 action（5 大类）**：

> **注意**：F 类（人类模拟 10 个）实际归属 `browser-humanizer` skill（第 6.4），operator 不重复实现。operator 主要负责 A-E 类 26 个。

---

### 6.3 browser-runner（脚本执行层）

**职责**：解析并执行 rbscript 工作流（实际是 hub 的执行引擎，但暴露 CLI 单独调试）

**目录结构**：
**CLI 完整接口**：
**核心算法（rbscript_parser.sh）**：
**错误码**：
| code | 含义 | 恢复策略 |
|---|---|---|
| `E001` | YAML 语法错 | 报错退出 · 不重试 |
| `E002` | schema 校验失败 | 报错退出 + 指出哪个字段 |
| `E003` | 循环依赖（DAG 不闭合）| 报错退出 + 路径 |
| `E004` | step 缺 skill 或 action | 报错退出 |
| `E005` | 期望断言失败 | 按 `on_fail` 配置处理 |
| `E006` | 重试超过 max | 按 `on_fail` 配置处理 |
| `E007` | 变量未定义 | 报错退出 + 指出哪个变量 |
| `E008` | 子 skill 调用超时 | 按 retry 配置处理 |

> **为什么 runner 单独 skill**：rbscript 解析 + 工作流调度是个**独立能力**，未来还能扩展 Taskfile / Just 的支持。锡哥 v3.0 决定 rbscript 是主选，所以 runner 围绕 rbscript 设计。

---

### 6.4 browser-humanizer（人类行为模拟）

**职责**：随机延迟 / 鼠标轨迹 / 滑条拖动 / 行为画像 / 轨迹录制

**目录结构**：
**CLI 完整接口**：
**行为画像示例**：
**drag 算法详解**（滑条验证码专杀）：
**错误码**：
| code | 含义 |
|---|---|
| `H001` | 行为画像不存在 |
| `H002` | selector 找不到元素 |
| `H003` | 浏览器 session 丢失 |
| `H004` | 拖动起点/终点不在同一 viewport |

---

### 6.5 browser-anti-detect（反爬指纹）

**职责**：webdriver 标志隐藏 / fingerprint 随机化 / 检测规避

**目录结构**：
**CLI 完整接口**：
**指纹模板示例（windows-chrome.yaml）**：
**反检测插件（webdriver-hide.js）**：
**错误码**：
| code | 含义 |
|---|---|
| `AD001` | 指纹模板不存在 |
| `AD002` | 插件注入失败（浏览器版本不兼容）|
| `AD003` | 检测页面访问失败 |
| `AD004` | 注入后还是被检测到（需调整指纹）|

---

### 6.6 browser-recorder（轨迹录制）

**职责**：录制真实人类操作轨迹 · 回放（用于锡哥手动操作一次后，后续脚本自动重放）

**目录结构**：
**CLI 完整接口**：
**录制格式（library/weibo-login.json）**：
**convert-to-rbscript 能力**（锡哥意外收获）：
**错误码**：
| code | 含义 |
|---|---|
| `R001` | 录制未启动 |
| `R002` | 浏览器断连（录制中）|
| `R003` | 录制库不存在 |
| `R004` | 回放步骤超界 |

---

### 6.7 browser-extractor（数据提取）

**职责**：结构化数据提取 · 模板化 · 输出标准化（Markdown / JSON / CSV）

**目录结构**：
**CLI 完整接口**：
**模板示例（wechat-article.yaml）**：
**错误码**：
| code | 含义 |
|---|---|
| `EX001` | 模板不存在 |
| `EX002` | 必需字段提取失败 |
| `EX003` | 转换函数错误（如 datetime_iso 解析失败）|
| `EX004` | 输出格式不支持 |
| `EX005` | 批量任务部分失败 |

---

### 6.8 browser-state-mgr（状态管理）

**职责**：cookie 备份/恢复 / 登录态搬运 / 多设备登录同步

**目录结构**：
**CLI 完整接口**：
**状态文件格式（states/weibo.json）**：
**错误码**：
| code | 含义 |
|---|---|
| `S001` | 浏览器未连接 |
| `S002` | Cookie 导出失败 |
| `S003` | Cookie 导入被拒绝（域名不匹配）|
| `S004` | 自动登录验证码无法绕过 |
| `S005` | 两步验证需人工 |
| `S006` | 状态文件损坏 |

---

### 6.9 browser-monitor（监控）

**职责**：长跑任务监控 / 反爬检测告警 / 日志聚合 / QQ Bot 告警推送

**目录结构**：
**CLI 完整接口**：
**告警规则示例（rules/captcha-detected.yaml）**：
**告警规则示例（rules/ip-banned.yaml）**：
**错误码**：
| code | 含义 |
|---|---|
| `M001` | 监控目标不在线 |
| `M002` | 告警渠道不可用（QQ Bot 断连）|
| `M003` | 检测器误报 |
| `M004` | 告警抑制中 |

---

## 7. rbscript 工作流格式

### 7.1 设计原则（锡哥 v3.0 选择）

| 维度 | 选择 | 理由 |
|---|---|---|
| 格式 | **YAML 自定义** | 锡哥 v3.0 已选 YAML + AI 友好 + 自定义灵活 |
| 文件扩展名 | `.rbs`（Real Browser Script） | 与 justfile/Taskfile 区分 |
| 验证 | JSON Schema（启动时 jq 校验） | 锡哥 v3.0 M1 必改 |

### 7.2 rbscript 完整示例（微博登录）

### 7.3 rbscript 语法要素

| 要素 | 关键字 | 必选 | 说明 |
|---|---|---|---|
| **元信息** | `name` `version` `description` | ✅ | 工作流标识 |
| **默认配置** | `defaults` | ⚠️ | 默认 browser/profile/timeout |
| **变量** | `vars` | ⚠️ | 支持 `${ENV.X}` `${vars.X}` 引用 |
| **钩子** | `hooks: before_each / on_fail / on_done` | ⚠️ | 自动化辅助 |
| **步骤** | `steps` | ✅ | 执行序列 |
| **步骤属性** | `id` `skill` `action` `args` | ✅ | 单步定义 |
| **依赖** | `after: <step_id>` | ⚠️ | 显式依赖（DAG 调度）|
| **期望** | `expect: {url_contains / selector_value_equals / not_empty}` | ⚠️ | 断言 |
| **重试** | `retry: {max, backoff}` | ⚠️ | 错误恢复 |
| **分支** | `branches: [{when, then}]` | ❌ | 条件分支 |
| **失败处理** | `on_fail` | ⚠️ | step 级 vs 全局 |

### 7.4 rbscript schema（启动校验）

---

## 8. 5 个内置工作流模板

| # | 模板 | 子 skill 编排 | 实战场景 |
|---|---|---|---|
| **1** | `weibo-login.rbs` | connector + operator + humanizer + anti-detect + state-mgr | 微博登录 + 验证码 + 保存 cookie |
| **2** | `bilibili-up.rbs` | connector + operator + extractor + state-mgr | B 站 UP 主主页数据提取 |
| **3** | `wechat-article.rbs` | connector + operator + extractor | 微信公众号文章抓取 |
| **4** | `slider-captcha.rbs` | connector + humanizer（drag） + monitor | 滑条验证码自动化处理 |
| **5** | `batch-fetch.rbs` | runner（loop）+ connector + operator + extractor | 批量 URL 抓取 |

---

### 8.1 weibo-login.rbs（完整内容）

---

### 8.2 bilibili-up.rbs（完整内容）

---

### 8.3 wechat-article.rbs（完整内容）

---

### 8.4 slider-captcha.rbs（完整内容）

---

### 8.5 batch-fetch.rbs（完整内容）

---

## 9. 实施阶段（P1-P12）

### 9.1 阶段总览

| P | 内容 | 工作量 | 依赖 | 里程碑 |
|---|---|---|---|---|
| **P1** | 项目结构 + monorepo + install.sh（软链接）| 4h | 无 | 项目骨架 |
| **P2** | 总控 hub：CLI 骨架 + rbscript 解析 + 上下文共享 | 6h | P1 | hub MVP |
| **P3** | 子 skill 1: connector（驱动层 + browsers.yaml）| 5h | P1 | 接入完成 |
| **P4** | 子 skill 2: operator（26 个 action 核心 8 个）| 6h | P3 | 操作 MVP |
| **P5** | 子 skill 2: operator（18 个剩余 action）| 6h | P4 | 操作完整 |
| **P6** | 子 skill 3: runner（rbscript 执行引擎）| 5h | P2 | 脚本引擎 |
| **P7** | 5 个内置工作流模板 | 4h | P2-P6 | 实战可用 |
| **P8** | 子 skill 4: humanizer（10 个 action + 行为画像）| 6h | P4 | 人类模拟 |
| **P9** | 子 skill 5: anti-detect（指纹 + stealth）| 4h | P4 | 反爬基础 |
| **P10** | 子 skill 6: recorder（录制 + 回放）| 4h | P4, P8 | 轨迹录制 |
| **P11** | 子 skill 7-9: extractor + state-mgr + monitor | 8h | P4 | 完整工具集 |
| **P12** | 文档 + 测试 + 锡哥 review + CHANGELOG | 4h | P1-P11 | v3.0 发布 |
| **总计** | **62 小时**（8 个工作日） | | | |

### 9.2 依赖图

### 9.3 MVP 路径（锡哥想早点用上）

**MVP = P1 + P2 + P3 + P4 + P6 + P7** = **30 小时**（4 个工作日）
- 包含 hub + connector + operator 核心 + runner + 5 模板
- 可跑通：锡哥手动写 weibo-login.rbs → hub 执行

**完整 v3.0** = 全部 P1-P12 = **62 小时**（8 个工作日）

### 9.4 推荐策略

| 选项 | 工作量 | 完成时间 |
|---|---|---|
| **A. MVP 优先**（推荐）| 30h | 这周 4 天 |
| **B. 一次性 62h** | 62h | 2 周 |
| **C. 砍模板先**（P7 → P11）| 27h · 但只有核心 action | 3.5 天 |

---

## 10. 决策记录（8-10 锡哥拍板）

| # | 决策点 | 锡哥拍板 | 备注 |
|---|---|---|---|
| 1 | 项目名 | browser-automation-platform（BAP）| 1A |
| 2 | 项目位置 | `~/projects/browser-automation-platform/` | 2A |
| 3 | 总控 skill 名 | **browser-hub** | 3D（"记不住 orchestrator"）|
| 4 | 上下文共享 | 全局 JSON 文件 `~/.bap/context/current.json` | 4A |
| 5 | 工作流格式 | rbscript（YAML 自定义）| 5A |
| 6 | 子 skill 调用 | CLI 调用 + 环境变量 | 6A |
| 7 | humanizer 独立 | 是（独立 skill）| 7A |
| 8 | 版本号 | 项目 v3.0 + 子 skill v1.0.0 | 8A |
| 9 | 文档结构 | monorepo + ADR | 9A |
| 10 | 顺序 | 先方案后实施 | 10A |

---

## 11. 风险与缓解

| # | 风险 | 缓解 |
|---|---|---|
| **1** | hub vs Selenium Hub 撞名 | §1.3 专门说明 + ADR-002 记录 |
| **2** | 9 个 skill 太多，认知负担重 | install.sh 默认全装；文档分"必读" + "选读" |
| **3** | rbscript 解析复杂度 | 用 jq 解析 YAML（成熟工具）；schema 校验 |
| **4** | context.json 文件冲突 | 加锁机制（`/tmp/bap-context.lock`）|
| **5** | 大圣 60 秒启动 | connector warmup 子命令 + browser warmup 默认 hook |
| **6** | CLI 调子 skill 慢（每次启动 Python）| 用 `python -m xxx` 模块复用，或缓存解释器 |
| **7** | 多子 skill 装到 `~/.agents/skills/` 污染 | 软链接方案 · 项目 git pull 自动更新 |
| **8** | 62 小时工作量太大 | MVP 30h 优先（§9.3）|

---

## 12. ADR（架构决策记录）4 条

### ADR-001 为什么 monorepo
**决策**：monorepo（不是 multi-repo）
**原因**：
1. 锡哥个人项目，团队小，不需要严格权限分离
2. 子 skill 之间耦合度中（共享 context.json）
3. monorepo 简化版本管理（项目 v3.0 统一发版）
4. CI / 文档 / 测试 集中管理

### ADR-002 为什么叫 browser-hub（不是 orchestrator）
**决策**：browser-hub
**原因**：
1. **锡哥 8-10 16:17 反馈**："记不住 orchestrator 这个单词"
2. hub = 4 个字母，**一眼记住**
3. 与 Selenium Hub 的区分已在 §1.3 显式说明
4. AI 也能轻松识别（hub = 中心节点，业内通用）

### ADR-003 为什么 YAML 全栈
**决策**：browsers.yaml + rbscript.yml + schema 全 YAML
**原因**：
1. 锡哥 v3.0 已选 YAML 路线
2. AI 友好（LLM 训练数据中 YAML 比 DSL 多）
3. 注释支持（JSON 不支持）
4. 人类可读 + 可写
5. 工具支持：yq / jq 生态成熟

### ADR-004 为什么 CLI 调用（不是 Python import）
**决策**：子 skill 之间通过 CLI + 环境变量调用
**原因**：
1. **跨语言**：子 skill 可 bash / python / go 实现
2. **跨进程**：context.json 自然共享
3. **可调试**：单独调 `browser-operator shot ...` 验证
4. **易测试**：mock CLI 输出而非 mock Python 对象

---

## 13. 锡哥下一步

锡哥看完整文档（§1-§12）后告诉我：

| # | 决策 | 选项 |
|---|---|---|
| **A. 方案是否通过** | A. 通过 · B. 还要改（指出哪段）· C. 推倒重来 |
| **B. 实施节奏** | A. MVP 30h（4 天）· B. 完整 62h（8 天）· C. 砍到 27h（3.5 天）|
| **C. 开始时间** | A. 这次会话开 P1 · B. 下一会话开 · C. 暂停 |
| **D. 是否走三司会审** | A. 是（强制）· B. 这次直接开（已两次走完）|

锡哥选 4 项，我立刻按方案开工。

---

_本方案 v3.0 · 8-10 16:52 · 精简版（代码移 references/）· 待三司会审_

**总字数**：段 1 (12.7KB) + 段 2 (18KB) = **30.7KB**