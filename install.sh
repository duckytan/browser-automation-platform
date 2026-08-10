#!/usr/bin/env bash
# BAP install.sh - 软链接 6 skill 到 ~/.agents/skills/（仅 dry-run，需锡哥确认后真执行）
# 用法: bash install.sh --dry-run   # 打印计划不执行
#       bash install.sh             # 真执行（锡哥确认后）

set -euo pipefail

# 6 个 BAP 子 skill（v3-design §1.3 · 朱熹 P2 补清单）
SKILLS=(hub connector operator humanizer recorder monitor)

# 源目录（本项目内，随 P2-P5 逐步填充）
SRC_BASE="$(cd "$(dirname "$0")" && pwd)"

# 目标目录（OpenClaw 自动加载公共 skill 路径 · P32 铁律）
DEST_BASE="${HOME}/.agents/skills"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=1
fi

echo "=== BAP install.sh ==="
echo "源目录: ${SRC_BASE}"
echo "目标目录: ${DEST_BASE}"
echo "模式: $([ $DRY_RUN -eq 1 ] && echo 'DRY-RUN（不执行）' || echo '实际执行')"
echo ""

# 0. 校验 just 存在
if ! command -v just >/dev/null 2>&1 && [[ ! -x /home/node/tools/bin/just ]]; then
    echo "❌ just 未安装，请先运行任务 2" >&2
    exit 1
fi
echo "✅ just 可用: $(command -v just >/dev/null 2>&1 && echo "$(command -v just)" || echo "/home/node/tools/bin/just")"

# 1. 逐 skill 软链接
for skill in "${SKILLS[@]}"; do
    src="${SRC_BASE}/${skill}"
    dest="${DEST_BASE}/${skill}"
    if [[ ! -d "${src}" ]]; then
        echo "⚠️  源目录不存在（P2-P5 才填充）: ${src}"
        continue
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "  [dry-run] 将软链: ${dest} -> ${src}"
    else
        ln -sfn "${src}" "${dest}"
        echo "  ✅ 软链: ${dest} -> ${src}"
    fi
done

echo ""
if [[ $DRY_RUN -eq 1 ]]; then
    echo "dry-run 完成（未执行任何软链接）。确认后运行: bash install.sh"
else
    echo "✅ 安装完成"
fi
