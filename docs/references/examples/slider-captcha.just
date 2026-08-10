# docs/references/examples/slider-captcha.just (v3.2 · Just 工作流模板 · P2 编排)
# 滑条验证码自动化处理
# 编排：connector + humanizer + monitor

# 用法：just slider-captcha slider_url="https://example.com"
slider_url := "https://example.com"

# 滑条验证码处理
slider-captcha:
    # 1. 接入浏览器
    @./engines/retry.sh 3 browser-connector connect --browser default
    # 2. 导航到目标页
    @./engines/expect.sh "url_contains=example" browser-operator nav --url {{slider_url}}
    # 3. 检测验证码（monitor·P6 实现，先占位）
    @browser-monitor detect-captcha 2>/dev/null || echo "跳过验证码检测（P6 实现）"
    # 4. 拖动滑条（humanizer·P6 实现，先占位）
    @browser-humanizer drag-slider --target ".captcha-slider" 2>/dev/null || echo "跳过滑条拖动（P6 实现）"
