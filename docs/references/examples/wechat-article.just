# docs/references/examples/wechat-article.just (v3.2 · Just 工作流模板)
# 微信公众号文章抓取
# 状态：P1 骨架 · P2 填实际 connector/operator 调用

# 编排模块（v3-design §8.3）：
#   connector  -> 接入浏览器（微信登录态）
#   operator   -> 导航 / 提取正文

# 用法：
#   just wechat-article url="https://mp.weixin.qq.com/s/xxx"

# 变量（骨架占位 · P2 接入真实默认值）
wechat_url := "https://mp.weixin.qq.com"

# 公众号文章抓取
wechat-article:
    @echo "wechat-article 骨架占位 (url={{wechat_url}})"
    # P2: connector connect --browser default
    # P2: operator nav --url {{wechat_url}}
    # P2: operator wait --selector "#js_content"
    # P2: operator extract --selector "#js_content"
