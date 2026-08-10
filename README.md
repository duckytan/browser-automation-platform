# browser-automation-platform (BAP)

> 一个围绕浏览器自动化的综合项目，采用"总控 + 子 skill"的**总分模式**（参考三司会审 + 4 诀的成熟架构）。

## 🎯 项目目标

构建一个**完整**的浏览器自动化平台（**模板化 SOP 平台**），覆盖：

| 层 | 组件 |
|---|---|
| **总控** | `browser-hub`（编排器 · 6 action）|
| **接入层** | `browser-connector`（CDP · 5 action）|
| **操作层** | `browser-operator`（33 action）|
| **脚本层** | `engines/`（retry.sh · expect.sh wrapper）|
| **增强层** | `browser-humanizer` · `browser-monitor` · `browser-recorder`（P6 实现）|

## 📚 文档

- 完整设计文档：[docs/v3-design.md](docs/v3-design.md)
- 施工文档：[docs/施工/](docs/施工/)

## ✅ 当前状态（路径 X MVP · P1-P5 完成）

- ✅ connector 5 action + operator 33 action + hub 6 action + 5 模板 + wrapper
- ✅ `just smoke` 真实链路跑通（connector 接入 → operator 操作）
- ✅ 5 个工作流模板（weibo-login / bilibili-up / wechat-article / slider-captcha / batch-fetch）
- ⏳ P6：humanizer / monitor / recorder（验证码 / 反爬 / 录制）

## 🚀 快速开始

### 前置依赖

1. **just**（任务执行器）：`/home/node/tools/bin/just`（或 `which just`）
2. **CDP 浏览器**：Docker Chrome 可达（默认 `172.17.0.1:19222`，见 `config/browsers.yaml`）
3. **PATH**：本项目 CLI 在 `bin/` 软链，模板已用 `./bin/` 前缀，**无需手动加 PATH**

### 冒烟测试

```bash
cd browser-automation-platform
just smoke                    # 裸跑（默认 browser=vps）
just smoke browser=xiaobai    # 指定浏览器
```

### 运行工作流

```bash
just bilibili-up uid=12345          # B 站 UP 数据提取
just weibo-login profile=vps        # 微博登录（需 ~/.bap/states/weibo-username 等）
just wechat-article wechat_url="https://mp.weixin.qq.com/s/xxx"
just batch-fetch batch_input="urls.txt"
```

### 直接调用 CLI

```bash
./bin/browser-connector list        # 列出浏览器
./bin/browser-operator eval 'JSON.stringify({url: location.href})'
./bin/browser-hub list              # 列出工作流
```

## 🛠 安装（软链到 ~/.agents/skills/）

```bash
bash install.sh --dry-run    # 预览（推荐先跑）
bash install.sh              # 真软链 hub/connector/operator
```

> 注意：install.sh 默认**实执行**（软链 3 个已实现 skill）；`--dry-run` 仅预览不执行。

## 📂 项目位置

- 仓库：`https://github.com/duckytan/browser-automation-platform`
