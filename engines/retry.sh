#!/usr/bin/env bash
# BAP engines/retry.sh - 重试 wrapper（§7.4 · 六祖 P0 已定 wrapper 实现错误处理）
# 用法: ./engines/retry.sh <max-retries> <cmd> [args...]
#   <max-retries>: 重试次数（含首次）
#   示例: ./engines/retry.sh 3 browser-operator nav --url https://weibo.com

set -uo pipefail

MAX_RETRIES="${1:-3}"
shift

if [[ $# -lt 1 ]]; then
    echo "❌ retry.sh: 缺少要执行的命令" >&2
    exit 2
fi

retry=0
while true; do
    "$@" && exit 0
    code=$?
    retry=$((retry + 1))
    if [[ $retry -ge $MAX_RETRIES ]]; then
        echo "❌ retry.sh: 重试 ${MAX_RETRIES} 次后仍失败 (exit=$code)" >&2
        exit $code
    fi
    backoff=$((2 ** (retry - 1)))
    echo "⚠️ retry.sh: 第 ${retry} 次失败 (exit=$code)，${backoff}s 后重试" >&2
    sleep "$backoff"
done
