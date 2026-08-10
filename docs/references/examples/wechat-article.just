# docs/references/examples/wechat-article.just (v3.2 · Just 工作流模板 · P2 编排)
# 微信公众号文章抓取
# 编排：connector + operator

# 用法：just wechat-article wechat_url="https://mp.weixin.qq.com/s/xxx"
wechat_url := "https://mp.weixin.qq.com"

# 公众号文章抓取
wechat-article:
    # 1. 接入浏览器（微信登录态）
    @./engines/retry.sh 3 browser-connector connect --browser default
    # 2. 导航到文章
    @./engines/expect.sh "url_contains=mp.weixin" browser-operator nav --url {{wechat_url}}
    # 3. 等待正文加载
    @browser-operator wait --selector "#js_content" --timeout 10
    # 4. 提取正文
    @browser-operator extract --selector "#js_content" --output /tmp/wechat-article.html
