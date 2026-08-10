# docs/references/examples/wechat-article.just (v3.2 · Just 工作流模板 · P2 编排)
# 微信公众号文章抓取
# 编排：connector + operator

# 用法：just wechat-article wechat_url="https://mp.weixin.qq.com/s/xxx" [browser=vps]
wechat_url := "https://mp.weixin.qq.com"
wa_browser := "vps"

# 公众号文章抓取
wechat-article:
    # 1. 接入浏览器（微信登录态）
    @./engines/retry.sh 3 ./bin/browser-connector connect --browser {{wa_browser}}
    # 2. 导航到文章
    @./engines/expect.sh "url_contains=mp.weixin" ./bin/browser-operator nav --url {{wechat_url}}
    # 3. 等待正文加载
    @./bin/browser-operator wait --selector "#js_content" --timeout 10
    # 4. 提取正文
    @./bin/browser-operator extract --selector "#js_content" --output /tmp/wechat-article.html
