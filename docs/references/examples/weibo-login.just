# docs/references/examples/weibo-login.just (v3.2 · Just 工作流模板)
# 微博自动登录 + 验证码处理 + 保存 cookie
# 状态：P1 骨架（6 模块编排占位）· P2 填实际 connector/operator 调用

# 编排模块（v3-design §8.1）：
#   connector  -> 接入浏览器（CDP 172.22.0.1:19222）
#   operator   -> 导航 / 输入 / 点击
#   humanizer  -> 人类行为 + 指纹 stealth（P6 实现）
#   monitor    -> 验证码检测（P6 实现）
#   state-tool -> 保存 cookie 到 states/cookies/weibo.json

# 用法：
#   just weibo-login profile=xiaobai

# 变量（骨架占位 · P2 接入真实默认值）
profile := "xiaobai"

# 微博登录工作流
weibo-login:
    @echo "weibo-login 骨架占位 (profile={{profile}})"
    # P2: connector connect --browser {{profile}}
    # P2: operator nav --url https://weibo.com
    # P2: operator type --selector "#loginname" --text ...
    # P2: operator click --selector ".login_btn"
    # P2: humanizer stealth（P6）
    # P2: monitor wait-captcha（P6）
    # P2: state-tool save-cookie --name weibo
