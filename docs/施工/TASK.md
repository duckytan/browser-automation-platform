# 📋 施工任务书 · BAP P1-P5（路径 X · MVP）

> **版本**：v1.1 · **依据**：docs/v3-design.md v3.2（commit `0ea3ceb`）
> **会审**：三司会审 4 司通过（sanshi-20260810-002）+ 施工文档审计 3 司通过（sanshi-20260810-003 · 8 项已修）· 锡哥 19:13 拍板整合建议 + 19:31「先修复，别开工」
> **范围**：路径 X = P1-P5（22.1h / 164K）· 骨架 + Just + connector + operator + hub
> **状态**：**待锡哥开工指令**

---

## [开头] 唯一真理 / 兜底 / 续跑

**唯一真理**：以 `docs/v3-design.md`（v3.2）为唯一权威，本任务书与设计文档冲突时以设计文档为准（本任务书若有误立即回写设计文档）。

- **BLOCKED.md**：任何一步卡住（工具装不上 / 依赖缺失 / 设计矛盾）→ 记入 BLOCKED.md，不硬闯，等锡哥。
- **PROGRESS.md**：每次施工后更新进度，断电/中断后从此续跑。
- **这活为什么干**：锡哥从 real-browser skill（7-10 跑通 CDP）升级为公开平台，复用浏览器自动化能力给其他项目。不干则 CDP 知识无法沉淀复用。
- **冲突让步顺序**：锡哥指令 > 设计文档 > 本任务书 > 我的判断。

---

## [1] 我替领导拍的板（默认值标「猜的」）

| # | 拍板项 | 值 | 标注 |
|---|---|---|---|
| 1 | 实施路径 | X（MVP · 22.1h/164K）| 锡哥 19:13 拍板同意（与 README/PLAN 一致）|
| 2 | 开工时机 | 待锡哥指令 | **未拍板** |
| 3 | 引擎 | Just 1.58.0（make 风格）| 锡哥已拍 MVP=Just |
| 4 | just 安装位置 | `/home/node/tools/bin/just` | 公共路径（P38）· 猜的，可改 |
| 5 | 工具下载 | GitHub release 预编译 musl | 无 cargo，猜的 |

---

## [2] 界限（白名单 · 只允许改哪些）

**✅ 允许**：
- 新建 `workflows/` `engines/` `hub/` `operator/` `humanizer/` `recorder/` `monitor/` `state-tool/` 目录骨架（8 个缺失项；`bin/` `connector/` 已存在，不重复建）
- 安装 just 到 `/home/node/tools/bin/`
- 填 5 个 `.just` 模板（docs/references/examples/）
- 写 P1 骨架文件（install.sh 软链接脚本 **仅 dry-run** · justfile 入口）
- 更新 `docs/施工/PROGRESS.md` / `BLOCKED.md`

**❌ 禁止**（除非锡哥明确说）：
- 不写 P2+ 的实际功能代码（operator 33 action / hub 编排等）
- 不改 `docs/v3-design.md`（除非发现设计矛盾，先记 BLOCKED）
- **不实际执行软链接**到 `~/.agents/skills/`（install.sh 可写可 dry-run，但真软链等 P1 验证 + 锡哥确认）
- 不动任何系统配置 / cron / 其他项目

---

## [3] 现状 + 任务 0（实测数字 + 核验）

### 现状（8-10 19:18 实测）

| 项 | 实测 | 命令 |
|---|---|---|
| 项目目录 | `bin/`(空) + `connector/`(空) + `docs/` + `hub-implementations/`(空) | `ls -la` |
| 8 个核心目录 | 全部缺失（hub/operator/humanizer/recorder/monitor/state-tool/workflows/engines）| `ls` |
| just | 未装（`/tmp/just` 已下载 1.58.0 待装）| `which just` |
| 5 个 .just 模板 | 空壳（6 行注释）| `wc -l docs/references/examples/*.just` |
| 代码量 | 0 行 | `find -name "*.py" \| wc -l` |

### 任务 0 · 建施工文档（本任务书 + PROGRESS + BLOCKED + PLAN + 验收清单）

**验收命令**：
```bash
ls docs/施工/  # 应有 README/TASK/PROGRESS/BLOCKED/PLAN/验收清单.md
```

---

## [4] 任务 N（每项带验收命令 + 反向验证）

### 任务 1 · 建 8 个缺失目录骨架

```bash
# 工作目录：项目根（/home/node/projects/browser-automation-platform）
mkdir -p workflows engines hub operator humanizer recorder monitor state-tool
```

> **P2 修复（六祖）**：现状列 8 缺失（hub/operator/humanizer/recorder/monitor/state-tool/workflows/engines）→ 任务 1 就建这 8 个。`bin/` `connector/` 已存在，不重复 mkdir。

**验收命令**（工作目录：项目根）：`ls -d workflows engines hub operator humanizer recorder monitor state-tool`
**反向验证**：`test -d hub && test -d operator && echo OK`

### 任务 2 · 安装 just（公共路径 + sha256 校验）

```bash
# 工作目录：项目根（/home/node/projects/browser-automation-platform）
# 0. 先校验二进制哈希（防 GitHub/镜像链路污染）
sha256sum /tmp/just   # 与官方 release SHA256 比对（https://github.com/casey/just/releases/tag/1.58.0）
# 1. 安装到公共路径
cp /tmp/just /home/node/tools/bin/just
chmod +x /home/node/tools/bin/just
# 2. 验证
/home/node/tools/bin/just --version  # 应输出 just 1.58.0
```

**验收命令**（工作目录：项目根）：`sha256sum /tmp/just`（记下哈希供比对）· `/home/node/tools/bin/just --version`
**反向验证**：`which just`（若 PATH 无，则记录 PATH 现状）

### 任务 3 · 写 justfile 入口（make 风格 · 含模板 import）

创建根目录 `justfile`，含：
- `list` recipe（列全部任务）
- `smoke` recipe（connector 接入 + operator 操作冒烟）
- **`import` 5 个模板**（just 1.58 支持 import · 让 `docs/references/examples/*.just` 进 `--list`）

> **P0-1 修复（六祖）**：just 只自动读根 justfile，不发现任意目录 `*.just`。故根 justfile **必须 `import` 5 模板**，否则任务 4 填模板后 `--list` 无反应。二选一已定：**用 import**（just 1.58 原生）。

**验收命令**（工作目录：项目根）：`just --list` 显示全部 recipe（7 个 + import 的模板）
**反向验证**：`just smoke` 能跑（骨架阶段可 echo 占位，见任务 4 强度分级）

### 任务 4 · 填 5 个 .just 模板（骨架内容 · P2 填实际编排）

按 §8 编排定义填每个模板的**骨架**（connector/operator/humanizer 调用占位）：
- weibo-login.just（5 模块编排）
- bilibili-up.just（3 模块）
- wechat-article.just（2 模块）
- slider-captcha.just（3 模块）
- batch-fetch.just（3 模块）

> **P1-3 修复（六祖+老子）**：与 v3-design §4 + PLAN 对齐 —— **P1 只填骨架占位（每文件 >20 行结构化注释 + recipe 头）**，实际 connector/operator 编排在 **P2** 填。

**验收命令**（工作目录：项目根）：`wc -l docs/references/examples/*.just`（每文件 >20 行）· `just --justfile docs/references/examples/weibo-login.just --list` 无报错
**反向验证**：`just --list`（根 justfile import 后）能列出 5 模板，无报错

### 任务 5 · 写 install.sh（软链接脚本 · 仅 dry-run）

创建 `install.sh`：校验 just 存在 → 软链接 6 skill（hub/connector/operator/humanizer/recorder/monitor）到 `~/.agents/skills/`（**只 dry-run，锡哥确认后才真执行**）

**验收命令**（工作目录：项目根）：`bash install.sh --dry-run` 打印计划不执行
**反向验证**：`test -f install.sh && echo OK`

---

## [5] 规矩（防作弊 · 点名具体姿势）

1. **不伪造验收**：验收命令输出必须真实（`just --version` 真有输出，不是 echo）
2. **不静默跳过**：每任务完成必须回报验收命令 + 输出（P43 证据铁律）
3. **不硬闯 BLOCKED**：just 装不上 / 模板语法错 → 记 BLOCKED.md，不擅自绕道
4. **不越界写代码**：任务 1-5 只建骨架，**不写 operator 33 action 等 P2+ 功能**
5. **不假装开工**：锡哥没下"开工"指令，即使本任务书写好了也只建文档 + 骨架准备，实际施工等指令

---

## [6] 完成条件（两条硬指标收尾）

**路径 X（P1-P5）完成的硬指标**：
1. **`just --list` 显示全部 recipe（含 import 模板）+ `just smoke` 能跑通真实 connector 接入 + operator 操作冒烟**
2. **5 个 .just 模板 + install.sh 就绪**，且 `docs/施工/PROGRESS.md` 记录每一步实测输出

> **smoke 验收强度分级（P2 修复 · 朱熹）**：
> - **任务 3（P1 骨架）**：`just smoke` = echo 占位即算骨架完成
> - **路径 X 完成（P5 后）**：`just smoke` = 真实 connector 接入 + operator 操作冒烟
> 两处强度不同是有意分级，不是矛盾。

**P1 阶段（本次会话范围）完成条件**：
1. 8 个目录骨架建成 + just 1.58.0 安装成功（`just --version`）
2. justfile 入口 + 5 模板骨架 + install.sh dry-run 通过

---

_任务书 v1.0 · 周星星 🌟 · 2026-08-10 · 待锡哥开工指令_
