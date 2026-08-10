# docs/references/examples/bilibili-up.just (v3.2 · Just 工作流模板)
# B 站 UP 主主页数据提取
# 状态：P1 骨架 · P2 填实际 connector/operator 调用

# 编排模块（v3-design §8.2）：
#   connector  -> 接入浏览器
#   operator   -> 导航 / 滚动 / 提取
#   state-tool -> 保存提取结果

# 用法：
#   just bilibili-up uid=12345

# 变量（骨架占位 · P2 接入真实默认值）
uid := "12345"

# B 站 UP 主页数据提取
bilibili-up:
    @echo "bilibili-up 骨架占位 (uid={{uid}})"
    # P2: connector connect --browser default
    # P2: operator nav --url https://space.bilibili.com/{{uid}}
    # P2: operator scroll --times 5
    # P2: operator extract --selector ".video-list"
    # P2: state-tool save-data --name bilibili-{{uid}}
