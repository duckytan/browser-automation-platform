# justfile - BAP 工作流入口（make 风格 · Just 1.58）

# 列出所有任务
list:
    @just --list

# 冒烟测试：connector 接入 + operator 操作（骨架阶段 echo 占位，P5 后真实冒烟）
smoke:
    @echo "BAP smoke: 骨架占位（P5 后 connector+operator 真实冒烟）"

# 导入 5 个工作流模板（P2 填实际编排）
import 'docs/references/examples/weibo-login.just'
import 'docs/references/examples/bilibili-up.just'
import 'docs/references/examples/wechat-article.just'
import 'docs/references/examples/slider-captcha.just'
import 'docs/references/examples/batch-fetch.just'
