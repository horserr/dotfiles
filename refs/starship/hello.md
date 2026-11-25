starship

Starship 的高级配置远不止修改颜色和图标。它实际上可以作为一个**根据工作环境动态变化的终端状态栏**，支持条件检测、自定义命令、左右布局、环境警告、项目级配置和性能调优。

如果已经掌握基本配置，下面这些功能更值得研究。

## **1. 左右分离布局（Right Prompt）**

可以将工作相关信息放在左侧，将时间、命令耗时、退出状态等辅助信息放在右侧。

Terminal

\~/dev/api main [!2]

2.3s 15:52

❯ ▏

```
format = """
$directory\
$git_branch\
$git_status\
$line_break\
$character"""

right_format = """
$cmd_duration\
$status\
$time"""

[time]
disabled = false
format = "[$time](dimmed white)"
time_format = "%H:%M"
```

右侧提示符是否可用取决于使用的 Shell，例如 Zsh、Fish 支持，而 Bash 没有原生的右侧提示符支持。

## **2. 使用 Fill 实现自适应布局**

`$fill` 可以自动填充终端剩余空间，随着窗口宽度变化自动调整。

\~/dev/api

main

────────────────────────────────────────────

Go 1.23

15:52

❯

```
format = """
$directory\
$git_branch\
$git_status\
$fill\
$golang\
$cmd_duration\
$time\
$line_break\
$character"""

[fill]
symbol = "─"
style = "dimmed white"

[time]
disabled = false
```

相比 `right_format`，`fill` 更适合多行 Prompt 的信息展示层。

## **3. Transient Prompt（瞬态提示符）**

这是我非常推荐的高级功能：当前正在输入命令时显示完整信息，执行命令后将历史 Prompt 简化。

普通 Prompt

\~/dev main Node.js

❯ ls

...

\~/dev main Node.js

❯ git status

...

\~/dev main Node.js

❯ npm run dev

...

\~/dev main Node.js

❯ ▏

Transient Prompt

❯ ls

...

❯ git status

...

❯ npm run dev

...

\~/dev main Node.js

❯ ▏

例如 Fish：

```
function starship_transient_prompt_func
    starship module character
end

starship init fish | source
enable_transience
```

Fish、PowerShell、Bash + Ble.sh 等环境有相应的实现方式，并不是所有 Shell 都能直接开启。

[image](https://www.google.com/s2/favicons?domain=https://starship.rs&sz=32)

Starship+1

## **4. Custom Module（自定义模块）**

**这是 Starship 最强大的扩展功能之一。** 你可以将本地命令的输出转换成 Prompt 中的信息模块。

例如显示当前目录的磁盘剩余空间：

```
[custom.disk]
command = "df -h . | awk 'END {print $4}'"
when = true
shell = ["sh"]
format = "[DISK $output]($style) "
style = "bold cyan"
```

还可以扩展出很多原生模块没有提供的功能。

| 自定义信息     | 用途                         |
| -------------- | ---------------------------- |
| CPU 使用率     | 监控计算任务                 |
| GPU 显存       | AI 模型开发                  |
| 磁盘剩余容量   | 大数据处理                   |
| Tailscale 状态 | 私有网络连接                 |
| VPN 状态       | 网络环境识别                 |
| 网络延迟       | 远程开发                     |
| Git Worktree   | 多分支并行开发               |
| 当前数据库环境 | 防止误操作                   |
| 当前任务编号   | 项目管理                     |
| 本地服务状态   | 开发环境监控                 |
| AI API 用量    | 成本管理，需要额外的数据来源 |

自定义模块可以使用缓存文件获取信息，不一定每次都执行复杂命令。

## **5. 条件触发与自动环境检测**

不需要让所有模块一直显示，可以根据文件、目录、环境变量或命令结果自动触发。

```
[custom.terraform_project]
command = "echo Terraform"
detect_extensions = ["tf"]
detect_files = [".terraform.lock.hcl"]
detect_folders = [".terraform"]
format = "[$output](bold purple) "
```

常用检测参数：

| 参数                | 触发依据          |
| ------------------- | ----------------- |
| `detect_files`      | 特定文件          |
| `detect_folders`    | 特定目录          |
| `detect_extensions` | 文件扩展名        |
| `detect_env_vars`   | 环境变量          |
| `when`              | 条件命令或布尔值  |
| `require_repo`      | 必须位于 Git 仓库 |
| `os`                | 指定操作系统      |

这样可以让 Prompt 自动适应不同的项目类型。

## **6. 生产环境高亮警告**

对于 DevOps、后端开发人员，这是非常实用的配置。

开发环境

\~/infra **K8S: development**

❯

测试环境

\~/infra **K8S: staging**

❯

生产环境

\~/infra

**! PRODUCTION**

❯

```
[kubernetes]
disabled = false
format = '[$symbol$context( / $namespace)]($style) '
style = "bold green"
symbol = "K8S: "

[[kubernetes.contexts]]
context_pattern = ".*prod.*"
style = "bold white bg:red"
symbol = "WARNING: "

[[kubernetes.contexts]]
context_pattern = ".*staging.*"
style = "bold yellow"
```

也可以通过自定义模块实现 SSH 主机、AWS Profile、数据库连接环境的类似提醒。

## **7. Palette（统一颜色管理）**

可以像前端 CSS Design Token 一样管理整个终端提示符的颜色。

**Catppuccin 风格配色**

Blue

\#89b4fa

Green

\#a6e3a1

Yellow

\#f9e2af

Red

\#f38ba8

Purple

\#cba6f7

Teal

\#94e2d5

Peach

\#fab387

Text

\#cdd6f4

```
palette = "my_theme"

[palettes.my_theme]
primary = "#89b4fa"
success = "#a6e3a1"
warning = "#f9e2af"
danger = "#f38ba8"
accent = "#cba6f7"

[directory]
style = "bold primary"

[git_branch]
style = "accent"

[character]
success_symbol = "[❯](bold success)"
error_symbol = "[❯](bold danger)"
```

以后更换主题只需要修改调色板，不需要逐个修改模块。

## **8. 高级 Git 信息展示**

Starship 可以提供比简单的 Git 分支丰富得多的信息。

\~/workspace/backend feature/auth

+3

!5

?2

⇡2 ⇣1

+128

-42

❯

```
[git_status]
conflicted = "=${count}"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "*${count}"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"

[git_metrics]
disabled = false
added_style = "bold green"
deleted_style = "bold red"

[git_branch]
truncation_length = 30
always_show_remote = true
```

还可以通过 `git_state`、`git_commit` 模块显示 Rebase 进度、Commit Hash、Tag 等信息。

## **9. Vim Mode 模式指示**

如果使用 Shell 的 Vi 编辑模式，可以让 Prompt 根据当前模式改变符号。

**I**

INSERT

\~/workspace

❯

**N**

NORMAL

\~/workspace

❯

**V**

VISUAL

\~/workspace

❯

**R**

REPLACE

\~/workspace

❯

```
[character]
success_symbol = "[I ❯](bold green)"
error_symbol = "[I ❯](bold red)"
vimcmd_symbol = "[N ❮](bold blue)"
vimcmd_visual_symbol = "[V ❮](bold purple)"
vimcmd_replace_symbol = "[R ❮](bold red)"
vimcmd_replace_one_symbol = "[R1 ❮](bold red)"
```

具体可以识别哪些模式取决于 Shell 集成。

## **10. 多套配置与动态切换**

Starship 支持通过 `STARSHIP_CONFIG` 指定不同配置文件。

```
~/.config/starship/
├── minimal.toml
├── developer.toml
├── devops.toml
├── ai.toml
└── remote.toml
```

在 Bash 或 Zsh 中创建快捷命令：

```
alias prompt-min='export STARSHIP_CONFIG="$HOME/.config/starship/minimal.toml"'

alias prompt-dev='export STARSHIP_CONFIG="$HOME/.config/starship/developer.toml"'

alias prompt-ops='export STARSHIP_CONFIG="$HOME/.config/starship/devops.toml"'
```

也可以搭配 `direnv`，进入不同项目时自动加载不同配置。项目级切换需要借助环境变量或外部工具，不是 Starship 原生自动读取项目配置的功能。

## **11. 性能调优**

高级 Prompt 最需要注意的就是性能。毕竟每执行一次命令，都可能重新生成 Prompt。

```
scan_timeout = 30
command_timeout = 500

[git_metrics]
disabled = true

[package]
disabled = true
```

| 参数              | 作用                         |
| ----------------- | ---------------------------- |
| `scan_timeout`    | 文件扫描超时，毫秒           |
| `command_timeout` | 外部命令执行超时，毫秒       |
| `disabled`        | 禁用不需要的模块             |
| `ignore_timeout`  | 允许自定义模块忽略超时，慎用 |

使用内置诊断命令：

```
starship timings
starship explain
starship print-config
```

对于 CPU、GPU、网络请求、API 用量等复杂信息，建议由独立程序定期更新缓存，Starship 只负责读取，不要在每次渲染 Prompt 时访问网络。

## **12. 其他值得了解的高级设置**

| 功能                    | 相关配置                          |
| ----------------------- | --------------------------------- |
| 目录名称替换            | `directory.substitutions`         |
| Git 仓库根目录单独高亮  | `repo_root_style`                 |
| 只读目录提醒            | `read_only`                       |
| 自定义路径截断          | `truncation_symbol`               |
| SSH 连接提醒            | `hostname.ssh_symbol`             |
| Shell 层级过深提醒      | `shlvl`                           |
| Pipeline 各阶段退出状态 | `status.pipestatus`               |
| 长命令桌面通知          | `cmd_duration.show_notifications` |
| 多行命令续行提示        | `continuation_prompt`             |
| Nix Shell 环境识别      | `nix_shell`                       |
| Direnv 环境加载状态     | `direnv`                          |
| TOML 编辑器自动补全     | `$schema`                         |
| Prompt 渲染前执行 Hook  | Shell-specific Hooks              |

以上配置参考了 [Starship 官方配置文档](https://starship.rs/config/?utm_source=chatgpt.com) 和 [高级配置文档](https://starship.rs/advanced-config/?utm_source=chatgpt.com)。示例是独立的配置片段，没有在你的本地环境实际运行测试，不宜直接全部拼接。

## **我比较推荐的终极布局**

Developer Terminal

SSH: dev-server

RAM 42% · 15:52:08

**\~/projects/backend**

feature/api

[!2 ?1 ⇡3]

Python 3.12

.venv

Docker: local

K8S: dev

────────────────────────────────────────────────────────────────

2.41s

**❯ ▏**
Starship 的高级配置远不止修改颜色和图标。它实际上可以作为一个\*\*根据工
将 Prompt 分为四个信息层：

- **主机层**：当前用户、SSH、主机资源。
- **项目层**：目录、Git 分支及修改状态。
- **环境层**：语言版本、虚拟环境、容器、云服务。
- **执行层**：命令耗时、退出状态、输入提示符。

再配合 Transient Prompt 清理历史输出，以及条件触发机制隐藏不相关的信息。

这样 Starship 就不只是一个美化工具，而是一个轻量级、上下文感知的 **Terminal Dashboard（终端仪表盘）**。
