#!/usr/bin/env bash
# l-agents.sh - 安装 Claude Code 或 GitHub Copilot CLI
# 用法:
#   ./l-agents.sh                # 默认用 pnpm 安装 Claude Code
#   ./l-agents.sh copilot        # 用 pnpm 安装 GitHub Copilot CLI
#   ./l-agents.sh claude --npm   # 改用 npm 安装

set -euo pipefail

CLAUDE_PKG="@anthropic-ai/claude-code"
CLAUDE_BIN="claude"
COPILOT_PKG="@github/copilot"
COPILOT_BIN="copilot"

TARGET=""
PM="pnpm"            # 默认包管理器

usage() {
    cat <<EOF
用法: $0 [claude|copilot] [--pnpm|--npm]

  claude        安装 Claude Code（默认）
  copilot       安装 GitHub Copilot CLI

  --pnpm        使用 pnpm 安装（默认）
  --npm         使用 npm 安装
  -h, --help    显示此帮助

示例:
  $0                    # pnpm 安装 claude
  $0 copilot            # pnpm 安装 copilot
  $0 claude --npm       # npm 安装 claude
EOF
}

# ---- 解析参数 ----
while [ $# -gt 0 ]; do
    case "$1" in
        claude|copilot)
            TARGET="$1"
            ;;
        --pnpm)
            PM="pnpm"
            ;;
        --npm)
            PM="npm"
            ;;
        -h|--help|help)
            usage
            exit 0
            ;;
        *)
            echo "错误: 未知参数 '$1'" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

TARGET="${TARGET:-claude}"

require_pm() {
    if command -v "$PM" >/dev/null 2>&1; then
        return 0
    fi
    echo "错误: 未找到 $PM。" >&2
    if [ "$PM" = "pnpm" ]; then
        echo "      请先安装 pnpm: corepack enable pnpm  或  npm i -g pnpm" >&2
        echo "      或改用 npm:  $0 $TARGET --npm" >&2
    fi
    return 1
}

# 全局安装: install_pkg <显示名> <包名> <可执行文件名>
install_pkg() {
    local name="$1" pkg="$2" bin="$3"

    echo "==> 使用 $PM 安装 $name ($pkg) ..."
    case "$PM" in
        pnpm)
            pnpm add -g "$pkg"
            ;;
        npm)
            npm install -g "$pkg"
            ;;
        *)
            echo "错误: 不支持的包管理器 $PM" >&2
            return 1
            ;;
    esac
    echo "==> $name 安装完成。"

    if command -v "$bin" >/dev/null 2>&1; then
        echo "    已就绪: $bin -> $(command -v "$bin")"
    else
        echo "    提示: 未在 PATH 中找到 '$bin'。" >&2
        if [ "$PM" = "pnpm" ]; then
            echo "          pnpm 全局 bin 目录可能未加入 PATH，执行一次 'pnpm setup' 后重开终端。" >&2
        fi
    fi
}

require_pm

case "$TARGET" in
    claude)
        install_pkg "Claude Code" "$CLAUDE_PKG" "$CLAUDE_BIN"
        ;;
    copilot)
        install_pkg "GitHub Copilot CLI" "$COPILOT_PKG" "$COPILOT_BIN"
        ;;
esac
