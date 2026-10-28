#!/usr/bin/env bash
# agent.sh - 安装 Claude 或 GitHub Copilot 命令行工具
# 用法:
#   ./agent.sh            # 默认安装 Claude
#   ./agent.sh copilot    # 安装 GitHub Copilot
#   ./agent.sh claude     # 显式安装 Claude

set -euo pipefail

TARGET="${1:-claude}"

# 注意: https://claude.ai 是官网首页(HTML)，安装脚本在 /install.sh
CLAUDE_INSTALL_URL="https://claude.ai/install.sh"
COPILOT_INSTALL_URL="https://gh.io/copilot-install"

# 下载远程安装脚本并校验内容，避免把重定向页/HTML 错误页直接喂给 shell
# 用法: run_remote_installer <url> [bash|sh]
run_remote_installer() {
    local url="$1"
    local shell_bin="${2:-bash}"
    local tmp rc=0
    tmp="$(mktemp "${TMPDIR:-/tmp}/install-XXXXXX.sh")" || return 1

    if ! curl -fsSL --max-time 120 --retry 2 -o "$tmp" "$url"; then
        rm -f "$tmp"
        echo "错误: 下载安装脚本失败: $url" >&2
        return 1
    fi

    # 正常安装脚本一定以 #! 开头；否则说明拿到的是 HTML(如 302/地区限制页)
    if [ "$(head -c 2 "$tmp" 2>/dev/null)" != '#!' ]; then
        echo "错误: $url 返回的不是 shell 脚本（可能是重定向页或地区限制页）。" >&2
        echo "      返回内容开头: $(head -c 120 "$tmp" 2>/dev/null | tr -d '\r\n')" >&2
        rm -f "$tmp"
        echo "      请检查网络/代理后重试。" >&2
        return 1
    fi

    "$shell_bin" "$tmp" && rc=0 || rc=$?
    rm -f "$tmp"
    return $rc
}

install_claude() {
    echo "==> 正在安装 Claude ..."
    run_remote_installer "$CLAUDE_INSTALL_URL" bash
    echo "==> Claude 安装完成。"
}

install_copilot() {
    echo "==> 正在安装 GitHub Copilot ..."
    run_remote_installer "$COPILOT_INSTALL_URL" bash
    echo "==> GitHub Copilot 安装完成。"
}

case "$TARGET" in
    claude)
        install_claude
        ;;
    copilot)
        install_copilot
        ;;
    -h|--help|help)
        cat <<EOF
用法: $0 [claude|copilot]

  (无参数)     安装 Claude（默认）
  claude       安装 Claude
  copilot      安装 GitHub Copilot
  help         显示此帮助
EOF
        ;;
    *)
        echo "错误: 未知参数 '$TARGET'" >&2
        echo "用法: $0 [claude|copilot]" >&2
        exit 1
        ;;
esac
