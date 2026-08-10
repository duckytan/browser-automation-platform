# justfile - BAP 工作流入口（make 风格 · Just 1.58）

# ========== 变量 ==========
browser := "vps"

# ========== 内置任务 ==========

# 列出所有任务
list:
    @just --list

# 冒烟测试：connector 接入 + operator 操作（真实链路）
# 用法: just smoke [browser=vps]  · 裸跑默认 vps，可用 just smoke browser=xiaobai
smoke:
    @echo "🧪 BAP smoke: connector + operator 真实链路 (browser={{browser}})"; \
    ./bin/browser-connector connect {{browser}}; \
    ./bin/browser-operator eval "location.href"

# ========== 5 个工作流模板（内联 · 与 docs/references/examples/*.just 同步）==========
# 说明：just 的 import 对带参数 recipe 有作用域限制，故内联在根 justfile。
# 模板文件保留作编排参考文档（docs/references/examples/）。

# 微博登录（编排：connector + operator + humanizer + monitor + state-tool）
weibo-login profile="vps":
    @./engines/retry.sh 3 ./bin/browser-connector connect --browser {{profile}}; \
    ./engines/expect.sh "url_contains=weibo" ./bin/browser-operator nav --url https://weibo.com; \
    ./bin/browser-operator type --selector "#loginname" --text "$(cat ~/.bap/states/weibo-username)"; \
    ./bin/browser-operator type --selector "#pl_login_form input[type=password]" --text "$(cat ~/.bap/states/weibo-password)"; \
    ./engines/retry.sh 3 ./bin/browser-operator click --selector ".login_btn"; \
    ./bin/browser-humanizer check-captcha 2>/dev/null || echo "跳过验证码检测（P6 实现）"; \
    ./bin/browser-operator cookies-export --name weibo

# B 站 UP 主数据提取（编排：connector + operator + state-tool）
bilibili-up uid="12345" bl_browser="vps":
    @./engines/retry.sh 3 ./bin/browser-connector connect --browser {{bl_browser}}; \
    ./engines/expect.sh "url_contains=bilibili" ./bin/browser-operator nav --url https://space.bilibili.com/{{uid}}; \
    ./bin/browser-operator scroll --times 5; \
    ./bin/browser-operator extract --selector ".video-list" --output /tmp/bilibili-{{uid}}.json; \
    ./bin/browser-operator cookies-export --name bilibili-{{uid}} 2>/dev/null || echo "已提取 /tmp/bilibili-{{uid}}.json"

# 微信公众号文章抓取（编排：connector + operator）
wechat-article wechat_url="https://mp.weixin.qq.com" wa_browser="vps":
    @./engines/retry.sh 3 ./bin/browser-connector connect --browser {{wa_browser}}; \
    ./engines/expect.sh "url_contains=mp.weixin" ./bin/browser-operator nav --url {{wechat_url}}; \
    ./bin/browser-operator wait --selector "#js_content" --timeout 10; \
    ./bin/browser-operator extract --selector "#js_content" --output /tmp/wechat-article.html

# 滑条验证码处理（编排：connector + humanizer + monitor）
slider-captcha slider_url="https://example.com" sc_browser="vps":
    @./engines/retry.sh 3 ./bin/browser-connector connect --browser {{sc_browser}}; \
    ./engines/expect.sh "url_contains=example" ./bin/browser-operator nav --url {{slider_url}}; \
    ./bin/browser-monitor detect-captcha 2>/dev/null || echo "跳过验证码检测（P6 实现）"; \
    ./bin/browser-humanizer drag-slider --target ".captcha-slider" 2>/dev/null || echo "跳过滑条拖动（P6 实现）"

# 批量 URL 抓取（编排：connector + operator + humanizer）
batch-fetch batch_input="urls.txt" bf_browser="vps":
    @./engines/retry.sh 3 ./bin/browser-connector connect --browser {{bf_browser}}; \
    while read -r url; do \
        echo "抓取: $$url"; \
        ./bin/browser-operator nav --url "$$url"; \
        ./bin/browser-operator extract --selector "body" --output "/tmp/batch-$$(echo $$url | md5sum | cut -c1-8).html"; \
        sleep 2; \
    done < {{batch_input}}
