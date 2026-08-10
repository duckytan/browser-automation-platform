#!/usr/bin/env bash
# BAP engines/expect.sh - 期望校验 wrapper（§7.4）
# 用法: ./engines/expect.sh "<cond>" <cmd> [args...]
#   <cond>: 校验条件，支持:
#     url_contains=xxx    输出包含 xxx
#     exit=0             命令退出码为 0
#   示例: ./engines/expect.sh "url_contains=weibo.com" browser-operator shot

set -uo pipefail

COND="${1:-}"
shift

if [[ -z "$COND" || $# -lt 1 ]]; then
    echo "❌ expect.sh: 用法 expect.sh \"<cond>\" <cmd> [args...]" >&2
    exit 2
fi

# 执行命令并捕获输出
OUTPUT="$("$@" 2>&1)"
CODE=$?

# 解析条件
case "$COND" in
    url_contains=*)
        NEEDLE="${COND#url_contains=}"
        if echo "$OUTPUT" | grep -qF "$NEEDLE"; then
            echo "✅ expect: 输出包含 '$NEEDLE'"
            exit 0
        else
            echo "❌ expect: 输出不含 '$NEEDLE'" >&2
            echo "--- 实际输出 ---" >&2
            echo "$OUTPUT" >&2
            exit 1
        fi
        ;;
    exit=0)
        if [[ $CODE -eq 0 ]]; then
            echo "✅ expect: exit=0"
            exit 0
        else
            echo "❌ expect: exit=$CODE (期望 0)" >&2
            exit $CODE
        fi
        ;;
    *)
        echo "❌ expect.sh: 未知条件 '$COND'" >&2
        exit 2
        ;;
esac
