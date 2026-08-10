# justfile - BAP 工作流入口（make 风格 · Just 1.58）

# 列出所有任务
list:
    @just --list

# 冒烟测试：connector 接入 + operator 操作（真实链路）
# 用法: just smoke [browser=vps]  · 裸跑默认 vps，可用 just smoke browser=xiaobai
browser := "vps"
smoke:
    @echo "🧪 BAP smoke: connector + operator 真实链路 (browser={{browser}})"; \
    ./bin/browser-connector connect {{browser}}; \
    ./bin/browser-operator eval 'JSON.stringify({url: location.href, title: document.title})'

# 导入 5 个工作流模板（P2 填实际编排）
import 'docs/references/examples/weibo-login.just'
import 'docs/references/examples/bilibili-up.just'
import 'docs/references/examples/wechat-article.just'
import 'docs/references/examples/slider-captcha.just'
import 'docs/references/examples/batch-fetch.just'
