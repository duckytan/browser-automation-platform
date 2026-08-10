<!-- @三司会审 v3.0 · 8-10 · 待审 -->

# browser-automation-platform (BAP) · v3.0 设计方案 · 段 1（基础架构）

> **锡哥 10 答拍板**（8-10 16:16）：
> 1A 名字 · 2A 位置 · 3D 总控名(hub) · 4A 上下文共享 · 5A rbscript · 6A CLI 调用 ·
> 7A humanizer 独立 · 8A 版本号 · 9A monorepo · 10A 先方案后实施

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

## 2. 总分架构图

```
                  ┌─────────────────────────────────────┐
                  │        browser-hub（总控）          │
                  │   BAP 项目大脑 · 编排器              │
                  │   ┌─────────────────────────────┐   │
                  │   │ 工作流引擎（rbscript 解析）  │   │
                  │   │ 上下文共享（context.json）   │   │
                  │   │ 错误恢复（重试 / 跳过）      │   │
                  │   └─────────────────────────────┘   │
                  └─────────────────────────────────────┘
                                       │
                                       │ CLI 调用 + 上下文共享
                                       ▼
        ┌──────────────┬──────────────┬──────────────┬──────────────┐
        │              │              │              │              │
   ┌────▼─────┐  ┌─────▼────┐  ┌──────▼─────┐  ┌─────▼────┐  ┌─────▼────┐
   │ connector│  │ operator │  │  runner    │  │humanizer │  │anti-detect│
   │ 接入     │  │ 操作     │  │ 脚本执行  │  │人类模拟  │  │反爬指纹  │
   │ v1.0.0   │  │ v1.0.0   │  │  v1.0.0    │  │ v1.0.0   │  │  v1.0.0   │
   └──────────┘  └──────────┘  └────────────┘  └──────────┘  └──────────┘

   ┌──────────────┬──────────────┬──────────────┬──────────────┐
   │              │              │              │              │
┌──▼───────┐ ┌────▼─────┐ ┌──────▼─────┐ ┌─────▼─────┐
│recorder  │ │extractor │ │state-mgr   │ │ monitor   │
│轨迹录制  │ │数据提取  │ │状态管理    │ │ 监控      │
│ v1.0.0   │ │ v1.0.0   │ │ v1.0.0     │ │ v1.0.0    │
└──────────┘ └──────────┘ └────────────┘ └───────────┘
```

### 2.1 总分关系

| 维度 | 总控 hub | 子 skill |
|---|---|---|
| **数量** | 1 个 | 9 个 |
| **职责** | 编排 · 调度 · 监控 | 单一职责执行 |
| **依赖** | **依赖**所有子 skill | **独立**可用 · 不依赖 hub |
| **入口** | `browser-hub run workflow.rbs` | `browser-operator shot --url=...` |
| **AI 触发** | 自然语言 · 工作流 | 单独调用 |

### 2.2 调用链示例（微博登录）

```
用户: browser-hub run weibo-login.rbs
    │
    ▼
hub 解析 rbscript → 拿到 5 个 steps
    │
    ├─ step 1: connector.connect → hub 调 `browser-connector connect`
    │           写 context.json {"browser": "dasheng", "session_id": "..."}
    │
    ├─ step 2: operator.nav → hub 调 `browser-operator nav`
    │           读 context.json → 用 session_id 连接浏览器
    │
    ├─ step 3: humanizer.delay → hub 调 `browser-humanizer delay`
    │           用 session_id 找到浏览器 → 插入随机延迟
    │
    ├─ step 4: operator.type → hub 调 `browser-operator type`
    │           + humanizer.before hook（自动执行）
    │
    ├─ step 5: state-manager.cookies-export → hub 调 `browser-state-mgr export`
    │
    ▼
返回结果给用户
```

---

## 3. 项目结构（monorepo）

### 3.1 完整目录树

```
~/projects/browser-automation-platform/        # 项目根 v3.0
├── README.md                                    # 项目入口
├── CHANGELOG.md                                 # 版本历史
├── LICENSE                                      # MIT
├── .gitignore
├── .editorconfig
│
├── docs/                                        # 项目级文档
│   ├── architecture.md                          # 架构总览
│   ├── naming-conventions.md                    # 命名规范（含 hub 区分）
│   ├── workflow-spec.md                         # rbscript 规范
│   ├── troubleshooting.md                       # 故障排查
│   ├── faq.md
│   └── adr/                                     # 架构决策记录
│       ├── 001-why-monorepo.md
│       ├── 002-why-hub-name.md                  # 锡哥 8-10 16:17 决策
│       ├── 003-why-yaml.md
│       └── 004-why-cli-coupling.md
│
├── bin/                                         # 项目级 CLI
│   └── bap                                      # 项目总入口（快捷方式）
│
├── hub/                                         # 🆕 总控 skill
│   ├── SKILL.md
│   ├── bin/
│   │   └── browser-hub                          # 总控主程序
│   ├── lib/
│   │   ├── rbscript_parser.sh                   # rbscript YAML 解析
│   │   ├── context_manager.sh                   # 上下文共享
│   │   ├── workflow_engine.sh                   # 工作流执行引擎
│   │   ├── error_handler.sh                     # 错误恢复
│   │   └── logger.sh                            # 统一日志
│   ├── skills-registry.yaml                     # 9 个子 skill 注册表
│   ├── workflows/                               # 内置工作流模板
│   │   ├── weibo-login.rbs
│   │   ├── bilibili-up.rbs
│   │   ├── wechat-article.rbs
│   │   ├── slider-captcha.rbs
│   │   └── batch-fetch.rbs
│   ├── schemas/
│   │   ├── rbscript.schema.yaml
│   │   └── skills-registry.schema.yaml
│   └── tests/
│
├── connector/                                   # 🆕 子 skill 1（接入）
│   ├── SKILL.md
│   ├── bin/
│   │   └── browser-connector                    # CLI 入口
│   ├── drivers/                                 # CDP / WebDriver / ws-cdp
│   ├── config/
│   │   ├── browsers.yaml
│   │   └── browsers.schema.yaml
│   └── tests/
│
├── operator/                                    # 🆕 子 skill 2（操作）
│   ├── SKILL.md
│   ├── bin/
│   │   └── browser-operator                     # CLI 入口
│   ├── actions/                                 # 26+10 个 action
│   ├── profiles/                                # 行为画像
│   ├── screenshots/                             # Python 实现
│   └── tests/
│
├── runner/                                      # 🆕 子 skill 3（脚本执行）
│   ├── SKILL.md
│   ├── bin/
│   │   └── browser-runner                       # CLI 入口
│   ├── taskfile-templates/                      # Taskfile.yml 模板
│   ├── just-templates/                          # justfile 模板（备用）
│   └── tests/
│
├── humanizer/                                   # 🆕 子 skill 4（人类模拟）
│   ├── SKILL.md
│   ├── bin/
│   │   └── browser-humanizer                    # CLI 入口
│   ├── behaviors/                               # 行为画像库
│   ├── trajectories/                            # 鼠标轨迹算法
│   └── tests/
│
├── anti-detect/                                 # 🆕 子 skill 5（反爬指纹）
│   ├── SKILL.md
│   ├── bin/
│   │   └── browser-anti-detect                  # CLI 入口
│   ├── fingerprints/                            # fingerprint 随机化
│   └── tests/
│
├── recorder/                                    # 🆕 子 skill 6（轨迹录制）
│   ├── SKILL.md
│   ├── bin/
│   │   └── browser-recorder                     # CLI 入口
│   ├── library/                                 # 录制库存储
│   └── tests/
│
├── extractor/                                   # 🆕 子 skill 7（数据提取）
│   ├── SKILL.md
│   ├── bin/
│   │   └── browser-extractor                    # CLI 入口
│   ├── templates/                               # 数据提取模板
│   └── tests/
│
├── state-manager/                               # 🆕 子 skill 8（状态管理）
│   ├── SKILL.md
│   ├── bin/
│   │   └── browser-state-mgr                    # CLI 入口
│   ├── states/                                  # cookie / 登录态存储
│   └── tests/
│
├── monitor/                                     # 🆕 子 skill 9（监控）
│   ├── SKILL.md
│   ├── bin/
│   │   └── browser-monitor                      # CLI 入口
│   └── tests/
│
├── install.sh                                   # 项目级安装（链接到 ~/.agents/skills/）
└── Makefile                                     # 项目级构建/测试/部署
```

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

```bash
# install.sh 自动执行
ln -sf ~/projects/browser-automation-platform/hub      ~/.agents/skills/browser-hub
ln -sf ~/projects/browser-automation-platform/connector ~/.agents/skills/browser-connector
ln -sf ~/projects/browser-automation-platform/operator   ~/.agents/skills/browser-operator
# ... 其他 6 个
```

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

```bash
# === 总控核心命令 ===
browser-hub run <workflow.rbs>             # 执行工作流
browser-hub validate <workflow.rbs>        # 校验 rbscript 语法
browser-hub list                           # 列出已注册子 skill
browser-hub list-workflows                 # 列出内置工作流模板

# === 子 skill 管理 ===
browser-hub skill list                     # 列出子 skill
browser-hub skill info <name>              # 子 skill 详情
browser-hub skill test <name>              # 测试子 skill 连通性

# === 上下文管理 ===
browser-hub context show                   # 看当前上下文
browser-hub context clear                  # 清空上下文
browser-hub context share                  # 跨进程共享

# === 监控 ===
browser-hub watch                          # 实时监控执行
browser-hub logs [--tail]                  # 看日志
browser-hub status                         # 当前状态
```

### 5.2 上下文共享机制（context.json）

```json
// ~/.bap/context/current.json
{
  "_meta": {
    "version": "3.0",
    "session_id": "uuid-xxx",
    "started_at": "2026-08-10T16:30:00Z"
  },
  "browser": {
    "name": "dasheng",
    "endpoint": "http://172.18.0.4:14444",
    "session_id": "selenium-session-id"
  },
  "profile": "human-casual",
  "state": {
    "logged_in": ["weibo.com"],
    "cookies_exported": "./state/weibo.json"
  },
  "vars": {
    "WEIBO_USER": "anonymous",
    "WEIBO_PASS": "***"
  },
  "history": [
    {"step": "connect", "skill": "connector", "status": "success", "duration_ms": 1234}
  ]
}
```

### 5.3 子 skill 调用协议

```bash
# 总控调子 skill 标准方式（CLI + 环境变量）
$ BROWSER_HUB_CONTEXT=/path/to/context.json \
  browser-operator shot \
    --url="https://baidu.com" \
    --browser-from-context=true \
    --output=/tmp/x.png

# 子 skill 内部读取 BROWSER_HUB_CONTEXT 环境变量，拿到 context 路径
# 读取 browser.session_id 连接浏览器
# 完成后写回 context.json（更新 history）
```

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
```
connector/
├── SKILL.md
├── bin/browser-connector
├── drivers/
│   ├── _interface.sh
│   ├── _validator.sh
│   ├── cdp.sh
│   ├── webdriver.sh
│   └── ws-cdp.sh
├── config/
│   ├── browsers.yaml
│   └── browsers.schema.yaml
├── screenshots/                # 截图辅助
└── tests/
```

**CLI 设计**：
```bash
browser-connector discover                       # 自动发现所有浏览器
browser-connector list                           # 列出已注册浏览器
browser-connector info --browser=dasheng        # 浏览器详情
browser-connector test --browser=dasheng         # 健康检查
browser-connector warmup --browser=dasheng      # 预热（大圣 60 秒问题解）
browser-connector connect --browser=dasheng      # 建立连接
browser-connector connect --browser=dasheng --disconnect-after=300   # 5 分钟后断开
browser-connector session-info                   # 当前 session 详情
```

**核心配置文件 `config/browsers.yaml`**（YAML · 锡哥 v3.0 已选）：
```yaml
version: "3.0"
defaults:
  host: "172.18.0.1"
  startup_timeout_sec: 90
  session_reuse: true

browsers:
  xiaobai:
    name: "小白 (maelp/docker-vnc-chromium)"
    image: maelp/docker-vnc-chromium:latest
    novnc_url: "http://{host}:5800"
    default_driver: cdp
    drivers:
      cdp:
        endpoint: "http://{host}:19222"
        ws_endpoint: "ws://{host}:19222"
        protocol: WebSocket
        health_check: "{endpoint}/json/version"
    tags: [chromium, lightweight, production]

  dasheng:
    name: "大圣 (selenium/standalone-chrome:4)"
    image: selenium/standalone-chrome:4.21.0
    novnc_url: "http://{host}:17900"
    default_driver: webdriver
    drivers:
      webdriver:
        endpoint: "http://{host}:14444"
        protocol: "HTTP + WebSocket (W3C WebDriver)"
        health_check: "{endpoint}/status"
        session_browser: chrome
        startup_time_sec: 60
      ws-cdp:
        endpoint: "ws://{host}:14444/session/{sid}/se/cdp"
        protocol: "WebSocket (Selenium BiDi)"
        requires: webdriver
    tags: [chrome, official, heavy, test]
```

**启动校验**：
- 启动时 `jq` 用 `browsers.schema.yaml` 校验 `browsers.yaml`
- 失败报错退出（不静默吞错）
- 5 类常见校验失败：缺 name/image 字段、driver 缺 endpoint、占位符未替换、JSON 语法错、浏览器名重复

---

### 6.2 browser-operator（操作层 · 26+10 action）

**职责**：浏览器所有操作 action（核心高频使用）

**目录结构**：
```
operator/
├── SKILL.md
├── bin/browser-operator
├── actions/                     # 26 个基础 action + 10 个人类模拟
│   ├── nav.sh
│   ├── shot.sh
│   ├── source.sh
│   ├── text.sh
│   ├── eval.sh
│   ├── click.sh
│   ├── type.sh
│   ├── ... (共 36 个)
├── profiles/                    # 行为画像
│   ├── human-casual.yaml
│   ├── human-aggressive.yaml
│   ├── stealth.yaml
│   └── README.md
├── screenshots/                 # Python 实现
│   ├── cdp.py
│   ├── webdriver.py
│   └── common.py
└── tests/
```

**36 个 action（5 大类）**：

```bash
# === A. 导航（4） ===
browser-operator nav          <url>                # 跳转
browser-operator reload                             # 刷新
browser-operator back                               # 后退
browser-operator forward                            # 前进

# === B. 数据提取（6） ===
browser-operator shot         <url> [options]      # 截图（整页/可视/元素）
browser-operator source       [--selector=...]     # HTML 源码
browser-operator text         [--selector=...]     # 可见文本
browser-operator eval         <js> [--json]        # 执行 JS 返回值
browser-operator cookies      [--export|--import]  # cookie 操作
browser-operator storage      [local|session]      # storage 操作

# === C. 交互（7） ===
browser-operator click        <selector>           # 点击
browser-operator type         <selector> <text>    # 输入
browser-operator hover        <selector>           # 悬停
browser-operator keypress     <key>                # 按键
browser-operator scroll       <selector|x> <y>     # 滚动
browser-operator select       <selector> <value>   # 下拉
browser-operator upload       <selector> <files>   # 上传

# === D. 等待/状态（4） ===
browser-operator wait         <selector|expr>      # 等待
browser-operator exists       <selector>           # 判断存在
browser-operator url                                # 当前 URL
browser-operator title                             # 当前标题

# === E. 高级（5） ===
browser-operator inject       <js_file>            # 注入 JS（持久）
browser-operator headers      <json>               # 设请求头
browser-operator intercept    <rule>               # 拦截请求
browser-operator emulate      <device>             # 模拟设备
browser-operator dialog       <accept|dismiss>     # 处理弹窗

# === F. 人类模拟（10 · 锡哥抓的痛点） ===
browser-humanizer delay --min=100 --max=500          # 随机延迟
browser-humanizer pause --min=2 --max=8              # 思考停顿
browser-humanizer move-to --selector=.btn --jitter=5 # 移动+抖动
browser-humanizer move-along --trajectory=points.json # 沿路径移动
browser-humanizer drag --from=.slider --to=.end --curve=bezier  # 滑条拖动
browser-humanizer type --selector=input --text=hello --typo-rate=0.05  # 带打错输入
browser-humanizer scroll --curve=natural            # 自然滚动
browser-humanizer record-trajectory start --name=login  # 录制
browser-humanizer replay-trajectory --name=login   # 回放
browser-humanizer --stealth ...                     # 全局 stealth
```

> **注意**：F 类（人类模拟 10 个）实际归属 `browser-humanizer` skill（第 6.4），operator 不重复实现。operator 主要负责 A-E 类 26 个。

---

### 6.3 browser-runner（脚本执行层）

**职责**：解析并执行 rbscript 工作流

**目录结构**：
```
runner/
├── SKILL.md
├── bin/browser-runner
├── taskfile-templates/         # Taskfile.yml 模板
├── just-templates/             # justfile 模板（备用）
└── tests/
```

**CLI**：
```bash
browser-runner run <workflow.rbs>     # 执行 rbscript 工作流
browser-runner validate <workflow.rbs> # 校验 rbscript 语法（用 schema）
browser-runner template list           # 列出内置模板
browser-runner template create <name>  # 创建新模板
```

> **为什么 runner 单独 skill**：rbscript 解析 + 工作流调度是个**独立能力**，未来还能扩展 Taskfile / Just 的支持。锡哥 v3.0 决定 rbscript 是主选，所以 runner 围绕 rbscript 设计。

---

### 6.4 browser-humanizer（人类行为模拟）

**职责**：随机延迟 / 鼠标轨迹 / 滑条拖动 / 行为画像 / 轨迹录制

**目录结构**：
```
humanizer/
├── SKILL.md
├── bin/browser-humanizer
├── behaviors/                  # 行为画像
│   ├── human-casual.yaml       # 休闲用户（50% 模拟）
│   ├── human-aggressive.yaml   # 激进用户（快节奏）
│   ├── human-scripted.yaml     # 脚本用户（机械精准）
│   └── README.md
├── trajectories/               # 鼠标轨迹算法
│   ├── bezier.py               # 贝塞尔曲线
│   ├── easing.py               # 缓动函数
│   └── noise.py                # 抖动噪声
├── library/                    # 录制轨迹库
└── tests/
```

**行为画像示例**：
```yaml
# behaviors/human-casual.yaml
profile_name: human-casual
click_delay_ms: {min: 100, max: 400}
type_delay_per_char_ms: {min: 80, max: 250}
type_typo_rate: 0.03
type_typo_backspace: true
think_pause_sec: {min: 0.5, max: 3.0}
scroll_curve: natural
scroll_step_px: {min: 100, max: 400}
mouse_jitter_px: {min: 1, max: 8}
drag_curve: bezier
drag_steps: {min: 15, max: 35}
drag_overshoot_px: 2
```

---

### 6.5 browser-anti-detect（反爬指纹）

**职责**：webdriver 标志隐藏 / fingerprint 随机化 / 检测规避

**目录结构**：
```
anti-detect/
├── SKILL.md
├── bin/browser-anti-detect
├── fingerprints/               # 浏览器指纹模板
│   ├── windows-chrome.yaml
│   ├── macos-safari.yaml
│   └── mobile-iphone.yaml
├── plugins/                    # 反检测插件
│   ├── webdriver-hide.js
│   ├── canvas-noise.js
│   └── audio-noise.js
└── tests/
```

**核心能力**：
```bash
browser-anti-detect stealth --browser=dasheng      # 启用 stealth 模式
browser-anti-detect rotate-fingerprint             # 随机化 fingerprint
browser-anti-detect check --url=https://bot.sannysoft.com  # 检测当前是否被识别
```

---

### 6.6 browser-recorder（轨迹录制）

**职责**：录制真实人类操作轨迹 · 回放

**目录结构**：
```
recorder/
├── SKILL.md
├── bin/browser-recorder
├── library/                    # 录制库
│   ├── weibo-login.json        # 锡哥手动录的微博登录
│   ├── taobao-search.json
│   └── README.md
└── tests/
```

**核心能力**：
```bash
browser-recorder record start --name=weibo-login --browser=dasheng   # 开始录制
browser-recorder record stop --name=weibo-login                     # 停止录制（锡哥手动操作）
browser-recorder replay --name=weibo-login --browser=dasheng        # 回放
browser-recorder library list                                       # 列出所有录制
```

---

### 6.7 browser-extractor（数据提取）

**职责**：结构化数据提取 · 模板化 · 输出标准化

**目录结构**：
```
extractor/
├── SKILL.md
├── bin/browser-extractor
├── templates/                  # 提取模板
│   ├── wechat-article.yaml     # 微信公众号文章提取模板
│   ├── bilibili-up.yaml        # B 站 UP 主提取
│   └── douyin-video.yaml       # 抖音视频提取
└── tests/
```

**核心能力**：
```bash
browser-extractor extract --template=wechat-article --url=https://mp.weixin.qq.com/s/xxx --output=article.md
browser-extractor template create --name=my-template                # 创建新模板
```

---

### 6.8 browser-state-mgr（状态管理）

**职责**：cookie 备份/恢复 / 登录态搬运 / 多设备登录同步

**目录结构**：
```
state-manager/
├── SKILL.md
├── bin/browser-state-mgr
├── states/                     # 状态存储
│   ├── weibo.json
│   ├── github.json
│   └── README.md
└── tests/
```

**核心能力**：
```bash
browser-state-mgr cookies export --browser=xiaobai --output=./states/weibo.json
browser-state-mgr cookies import --browser=dasheng --input=./states/weibo.json
browser-state-mgr login --browser=xiaobai --site=weibo --user=xxx
browser-state-mgr state show                                       # 当前所有浏览器登录态
```

---

### 6.9 browser-monitor（监控）

**职责**：长跑任务监控 / 反爬检测告警 / 日志聚合

**目录结构**：
```
monitor/
├── SKILL.md
├── bin/browser-monitor
├── rules/                      # 告警规则
│   ├── captcha-detected.yaml
│   ├── ip-banned.yaml
│   └── flow-abnormal.yaml
└── tests/
```

**核心能力**：
```bash
browser-monitor watch                                          # 实时监控
browser-monitor detect                                         # 当前检测（验证码 / IP 封禁 / 流程异常）
browser-monitor alert --rule=captcha-detected                  # 配置告警
```

---

## 7. rbscript 工作流格式

### 7.1 设计原则（锡哥 v3.0 选择）

| 维度 | 选择 | 理由 |
|---|---|---|
| 格式 | **YAML 自定义** | 锡哥 v3.0 已选 YAML + AI 友好 + 自定义灵活 |
| 文件扩展名 | `.rbs`（Real Browser Script） | 与 justfile/Taskfile 区分 |
| 验证 | JSON Schema（启动时 jq 校验） | 锡哥 v3.0 M1 必改 |

### 7.2 rbscript 完整示例（微博登录）

```yaml
# ~/.bap/workflows/weibo-login.rbs
# 微博自动登录（带验证码处理 + 人类化）
name: weibo-login
version: "1.0"
description: 微博自动登录 + 验证码处理 + 保存 cookie

# === 默认配置 ===
defaults:
  browser: dasheng
  profile: human-casual
  timeout: 30

# === 变量声明（支持环境变量 + dotenv） ===
vars:
  username: ${ENV.WEIBO_USER}
  password: ${ENV.WEIBO_PASS}
  max_retry: 3

# === 钩子（每个 step 自动触发） ===
hooks:
  before_each:
    - skill: browser-humanizer
      action: delay
      args: {min: 500, max: 1500}
    - skill: browser-operator
      action: shot
      args: {output: "./logs/${step.id}-${timestamp}.png"}
  on_fail:
    - skill: browser-humanizer
      action: pause
      args: {min: 1, max: 3}
    - skill: browser-monitor
      action: detect
      args: {}
  on_done:
    - skill: browser-state-mgr
      action: cookies-export
      args: {path: "./states/weibo.json"}

# === 步骤序列 ===
steps:
  - id: warmup_browser
    skill: browser-connector
    action: warmup
    args: {browser: ${defaults.browser}}

  - id: nav_login
    skill: browser-operator
    action: nav
    args: {url: "https://weibo.com/login"}
    after: warmup_browser
    expect: {url_contains: "weibo.com/login"}
    retry: {max: 2, backoff: exponential}

  - id: detect_stealth
    skill: browser-anti-detect
    action: check
    args: {url: "https://bot.sannysoft.com"}
    after: nav_login

  - id: type_user
    skill: browser-operator
    action: type
    args:
      selector: "input[name=username]"
      text: ${vars.username}
    after: nav_login
    expect: {selector_value_equals: {selector: "input[name=username]", value: ${vars.username}}}
    hooks:
      before:
        - skill: browser-humanizer
          action: delay
          args: {min: 100, max: 300}

  - id: type_pass
    skill: browser-operator
    action: type
    args:
      selector: "input[name=password]"
      text: ${vars.password}
    after: type_user
    hooks:
      before:
        - skill: browser-humanizer
          action: type-typo
          args: {selector: "input[name=password]", text: ${vars.password}, typo_rate: 0.03}

  - id: click_login
    skill: browser-operator
    action: click
    args: {selector: ".login-btn"}
    after: type_pass
    expect: {url_contains: "weibo.com/u/"}
    on_fail:
      - skill: browser-anti-detect
        action: rotate-fingerprint
      - retry: click_login
      - max: ${vars.max_retry}

  - id: verify_login
    skill: browser-operator
    action: eval
    args: {expr: "document.querySelector('.user-name')?.innerText"}
    after: click_login
    expect: {not_empty: true}
    on_fail:
      - skill: browser-monitor
        action: detect
      - fail "登录失败，未找到用户名"

# === 流程控制（可选） ===
branches:
  - when: {step: click_login, status: timeout}
    then:
      - skill: browser-operator
        action: reload
      - retry_step: click_login
      - max: ${vars.max_retry}
```

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

```yaml
# hub/schemas/rbscript.schema.yaml
$schema: http://json-schema.org/draft-07/schema#
type: object
required: [name, steps]
properties:
  name: {type: string}
  version: {type: string, pattern: "^[0-9]+\\.[0-9]+$"}
  description: {type: string}
  defaults:
    type: object
    properties:
      browser: {type: string}
      profile: {type: string}
      timeout: {type: integer, minimum: 1}
  vars:
    type: object
    additionalProperties: {type: string}
  hooks:
    type: object
    properties:
      before_each: {type: array}
      on_fail: {type: array}
      on_done: {type: array}
  steps:
    type: array
    items:
      type: object
      required: [id, skill, action]
      properties:
        id: {type: string}
        skill: {type: string, enum: [browser-connector, browser-operator, browser-runner, browser-humanizer, browser-anti-detect, browser-recorder, browser-extractor, browser-state-mgr, browser-monitor]}
        action: {type: string}
        args: {type: object}
        after: {type: string}
        expect: {type: object}
        retry:
          type: object
          properties:
            max: {type: integer}
            backoff: {type: string, enum: [linear, exponential]}
        on_fail: {type: array}
  branches:
    type: array
```

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

```
P1 (骨架)
 ├─ P2 (hub CLI)
 │   ├─ P6 (runner)
 │   │   └─ P7 (5 模板)
 │   └─ P7 (5 模板) [依赖 P4]
 └─ P3 (connector)
     └─ P4 (operator 核心 8 个)
         ├─ P5 (operator 剩余 18 个)
         ├─ P8 (humanizer)
         ├─ P9 (anti-detect)
         ├─ P10 (recorder) [需 P8]
         ├─ P11 (extractor + state-mgr + monitor)
         └─ P7 (5 模板) [需所有子 skill]
             └─ P12 (文档 + 发布)
```

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

锡哥看完段 1 + 段 2 后告诉我：

| # | 决策 | 选项 |
|---|---|---|
| **A. 方案是否通过** | A. 通过 · B. 还要改（指出哪段）· C. 推倒重来 |
| **B. 实施节奏** | A. MVP 30h（4 天）· B. 完整 62h（8 天）· C. 砍到 27h（3.5 天）|
| **C. 开始时间** | A. 这次会话开 P1 · B. 下一会话开 · C. 暂停 |
| **D. 是否走三司会审** | A. 是（强制）· B. 这次直接开（已两次走完）|

锡哥选 4 项，我立刻按方案开工。

---

_本方案 v3.0 · 完整版 · 8-10 16:20 · 待三司会审_

**附录 A**（段 1）：基础架构 5 章 — 已发
**附录 B**（段 2 · 本文档）：详细设计 + 实施 8 章 — 本文件

**总字数**：段 1 (12.7KB) + 段 2 (18KB) = **30.7KB**