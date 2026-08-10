# docs/references/examples/batch-fetch.just (v3.2 · Just 工作流模板 · P2 编排)
# 批量 URL 抓取
# 编排：connector + operator + humanizer

# 用法：just batch-fetch batch_input="urls.txt"
batch_input := "urls.txt"

# 批量 URL 抓取
batch-fetch:
    # 1. 接入浏览器
    @./engines/retry.sh 3 browser-connector connect --browser default
    # 2. 逐 URL 抓取
    @while read -r url; do \
        echo "抓取: $$url"; \
        browser-operator nav --url "$$url"; \
        browser-operator extract --selector "body" --output "/tmp/batch-$$(echo $$url | md5sum | cut -c1-8).html"; \
        # humanizer 随机间隔（P6 实现，先占位）\
        sleep 2; \
    done < {{batch_input}}
