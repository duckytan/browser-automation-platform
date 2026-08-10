# docs/references/examples/bilibili-up.just (v3.2 · Just 工作流模板 · P2 编排)
# B 站 UP 主主页数据提取
# 编排：connector + operator + state-tool

# 用法：just bilibili-up uid=12345
uid := "12345"

# B 站 UP 主页数据提取
bilibili-up:
    # 1. 接入浏览器
    @./engines/retry.sh 3 browser-connector connect --browser default
    # 2. 导航到 UP 主页
    @./engines/expect.sh "url_contains=bilibili" browser-operator nav --url https://space.bilibili.com/{{uid}}
    # 3. 滚动加载
    @browser-operator scroll --times 5
    # 4. 提取视频列表
    @browser-operator extract --selector ".video-list" --output /tmp/bilibili-{{uid}}.json
    # 5. 保存结果（state-tool）
    @browser-operator cookies-export --name bilibili-{{uid}} 2>/dev/null || echo "已提取 /tmp/bilibili-{{uid}}.json"
