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
if $nu.is-interactive {
    $env.config.edit_mode = 'vi'
    # 1. 改变光标形状：插入模式用竖线(|)，普通模式用方块(█)
    $env.config.cursor_shape = {
        vi_insert: line
        vi_normal: block
    }

    # 2. 改变提示符状态（可选）：在输入行前明确显示当前状态
    $env.PROMPT_INDICATOR_VI_INSERT = { "[I]> " }
    $env.PROMPT_INDICATOR_VI_NORMAL = { "[N]: " }
}

# 1. Environment & Path Settings (Must be standalone lines, do not use load-env for configs)
$env.LANG = "en_US.UTF-8"
$env.EDITOR = "vim"
$env.VISUAL = "vim"

# Update PATH dynamically
$env.PATH = (
    $env.PATH
    | split row (char env_sep)
    | append "C:/Program Files/Git/usr/bin"
    | uniq
)

# 2. Nushell Global Configuration
$env.config = {
    buffer_editor: "vim" # Moved inside the valid $env.config record
}

# 仅在执行当前测试时，临时开启 debug 模式
# with-env { DEBUG: "true" } { npm run test }
# direnv
# 查看 $env 删除 hide-env variable
