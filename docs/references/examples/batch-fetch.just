# docs/references/examples/batch-fetch.just (v3.2 · Just 工作流模板 · 参数版)
# 批量 URL 抓取
# 编排：connector + operator + humanizer

# 用法：just batch-fetch [batch_input=urls.txt] [browser=vps]
batch-fetch batch_input="urls.txt" browser="vps":
    # 1. 接入浏览器
    @./engines/retry.sh 3 ./bin/browser-connector connect --browser {{browser}}
    # 2. 逐 URL 抓取
    @while read -r url; do \
        echo "抓取: $$url"; \
        ./bin/browser-operator nav --url "$$url"; \
        ./bin/browser-operator extract --selector "body" --output "/tmp/batch-$$(echo $$url | md5sum | cut -c1-8).html"; \
        # humanizer 随机间隔（P6 实现，先占位）\
        sleep 2; \
    done < {{batch_input}}
