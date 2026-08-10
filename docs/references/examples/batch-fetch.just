# docs/references/examples/batch-fetch.just (v3.2 · Just 工作流模板)
# 批量 URL 抓取
# 状态：P1 骨架 · P2 填实际 connector/operator/humanizer 调用

# 编排模块（v3-design §8.5）：
#   connector  -> 接入浏览器
#   operator   -> 逐个 URL 导航 / 提取
#   humanizer  -> 请求间隔（人类节奏 · P6 实现）

# 用法：
#   just batch-fetch input="urls.txt"

# 变量（骨架占位 · P2 接入真实默认值）
batch_input := "urls.txt"

# 批量 URL 抓取
batch-fetch:
    @echo "batch-fetch 骨架占位 (input={{batch_input}})"
    # P2: connector connect --browser default
    # P2: for url in $(cat {{batch_input}}):
    #       operator nav --url $url
    #       operator extract --selector "body"
    #       humanizer sleep --random 2-5s（P6）
