# docs/references/examples/slider-captcha.just (v3.2 · Just 工作流模板)
# 滑条验证码自动化处理
# 状态：P1 骨架 · P2 填实际 connector/humanizer/monitor 调用

# 编排模块（v3-design §8.4）：
#   connector  -> 接入浏览器
#   humanizer  -> 模拟人类滑条拖动（P6 实现）
#   monitor    -> 验证码检测（P6 实现）

# 用法：
#   just slider-captcha url="https://example.com"

# 变量（骨架占位 · P2 接入真实默认值）
slider_url := "https://example.com"

# 滑条验证码处理
slider-captcha:
    @echo "slider-captcha 骨架占位 (url={{slider_url}})"
    # P2: connector connect --browser default
    # P2: operator nav --url {{slider_url}}
    # P2: monitor detect-captcha（P6）
    # P2: humanizer drag-slider --target ".captcha-slider"（P6）
