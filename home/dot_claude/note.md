#

claude code schema: <https://github.com/amitray007/claude-code-schema>

claude code python dev setup: https://pydevtools.com/handbook/how-to/#editor-ai

- [configure pyrefly](https://pyrefly.org/blog/pyrefly-agentic-loop/)
- [configure ruff](https://pydevtools.com/handbook/how-to/how-to-configure-ruff-with-claude-code/)

[Maximizing the value of your Claude Code sessions](https://claude.com/resources/articles/maximizing-the-value-of-your-claude-code-sessions)

1. 任务结束就 /clear：完成一个独立任务（如修完一个 bug）后，立即清空对话。避免将上一个任务读过的文件和命令输出带入新任务，让后续每一轮都白白携带这些无关信息。

2. 开局定好模型和 Effort：在会话开始时就用 /model 和 /effort 选好配置。中途切换会使提示缓存失效，导致整段对话历史需要按全价重新计算。

3. 用 @ 引用文件：需要 Claude 看某个文件时，直接用 @文件名 附上。这省去了一次让 Claude 调用工具去读取的步骤；如果不给路径，它可能还要先搜索再试探性打开多个文件，这些都会累积在上下文里。

4. 给嘈杂命令加静默参数：测试、构建等命令的输出可能很长。在 CLAUDE.md 里配置静默参数（如 --reporter=dot），让输出只保留摘要。输出越短，占用的上下文越少。

5. 离开前 /compact：在对话缓存还有效时进行压缩，成本很低。如果等缓存过期后再压缩，就需要按全价重新读取全部历史，费用高得多。

6. 大任务扔给子 Agent：对于会产生大量输出的任务（如大范围搜索），交给子 Agent 处理。它在独立的上下文窗口中运行，只把最终结论传回主对话，过程噪音不会污染你的主上下文。

⚙️ 配置与结构调整

- 精简 CLAUDE.md：这个文件在会话启动时就会加载。将其中针对特定工作流（如 PR 审查）的详细指令移到按需加载的 Skill 中，可以保持基础上下文更小。目标是让 CLAUDE.md 保持在 200 行以内。

- 用 Hook 预处理数据：与其让 Claude 读一个万行日志文件找错误，不如配置一个 PreToolUse Hook，在数据到达 Claude 之前就用脚本过滤。例如，只把包含 ERROR 的行返回，能将上下文从数万 token 压缩到数百 token。

- 管理 MCP 服务器：用 /mcp 命令禁用当前不需要的服务器。每个 MCP 工具的定义都会占用上下文空间，过多未使用的 MCP 会显著挤压你实际可用的上下文窗口。

- 为语言安装代码智能插件：对于 TypeScript 等类型化语言，安装代码智能插件能提供精确的“转到定义”能力，替代低效的文本搜索和试错式文件读取，从而减少不必要的文件读取 token 消耗。

- 按需关闭扩展思考：如果确定当前任务只是机械性工作，可以在启动时设置 MAX_THINKING_TOKENS=0 claude 来关闭该次会话的思考过程，直接减少隐藏的思考 token 开销。
