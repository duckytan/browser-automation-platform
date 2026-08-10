# docs/references/examples/weibo-login.just (v3.2 · Just 工作流模板 · P2 编排)
# 微博自动登录 + 验证码处理 + 保存 cookie
# 编排：connector + operator + humanizer + monitor + state-tool

# 用法：just weibo-login profile=vps
profile := "vps"

# 微博登录工作流
weibo-login:
    # 1. 接入浏览器（connector.connect）
    @./engines/retry.sh 3 ./bin/browser-connector connect --browser {{profile}}
    # 2. 导航到微博登录页（operator.nav）
    @./engines/expect.sh "url_contains=weibo" ./bin/browser-operator nav --url https://weibo.com
    # 3. 输入账号（operator.type）
    @./bin/browser-operator type --selector "#loginname" --text "$(cat ~/.bap/states/weibo-username)"
    # 4. 输入密码
    @./bin/browser-operator type --selector "#pl_login_form input[type=password]" --text "$(cat ~/.bap/states/weibo-password)"
    # 5. 点击登录
    @./engines/retry.sh 3 ./bin/browser-operator click --selector ".login_btn"
    # 6. 验证码检测（humanizer·P6 实现，先占位）
    @./bin/browser-humanizer check-captcha 2>/dev/null || echo "跳过验证码检测（P6 实现）"
    # 7. 保存 cookie（state-tool）
    @./bin/browser-operator cookies-export --name weibo
