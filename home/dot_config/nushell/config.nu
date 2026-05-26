# config.nu
#
# Installed by:
# version = "0.113.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.config.edit_mode = 'vi'

# 1. 改变光标形状：插入模式用竖线(|)，普通模式用方块(█)
$env.config.cursor_shape = {
    vi_insert: line
    vi_normal: block
}

# 2. 改变提示符状态（可选）：在输入行前明确显示当前状态
$env.PROMPT_INDICATOR_VI_INSERT = { "[I]> " }
$env.PROMPT_INDICATOR_VI_NORMAL = { "[N]: " }

# Add Git Bash's bin directory only to Nushell's path
$env.ENV_CONVERSIONS.PATH = {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path join }
}
$env.PATH = ($env.PATH | append "C:/Program Files/Git/usr/bin")

# Set Vim as the default buffer editor for Nushell (e.g., when pressing Ctrl+E)
$env.config.buffer_editor = "vim"

# Set Vim as the global environment editor for scripts and Git
$env.EDITOR = "vim"
$env.VISUAL = "code"
