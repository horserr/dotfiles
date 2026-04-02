---
name: plan-vscode-vim-vspacecode
description: Describe when to use this prompt
---

这份方案的核心思路是：**利用 VSpaceCode 接管全局功能（如窗口、文件、搜索管理），同时保留并优化你高效的 Vim 插入模式（Insert Mode）快捷键和特定编辑逻辑。**

---

### 第一阶段：功能迁移与冗余清理
VSpaceCode 的设计初衷是减少手动配置。你可以从 `vim.normalModeKeyBindingsNonRecursive` 中删除以下已由 VSpaceCode 默认覆盖的项：

* [cite_start]**文件与全局搜索**：删除 `<space> f` (quickOpen) [cite: 19][cite_start]、`<space> a` (showCommands) [cite: 19] [cite_start]和 `<leader> F` (findInFiles) [cite: 15]。VSpaceCode 默认使用 `Space f f` 和 `Space s p` 处理这些操作。
* [cite_start]**编辑器管理**：删除 `<space> q` (closeActiveEditor) [cite: 18][cite_start]、`<space> w` (closeOtherEditors) [cite: 19] [cite_start]和 `<space> p/P` (pin/unpin) [cite: 20]。VSpaceCode 对应 `Space b d`、`Space b D` 和 `Space b p`。
* [cite_start]**符号跳转**：删除 `<space> s/S` (symbols) [cite: 20]。VSpaceCode 对应 `Space s s` 和 `Space s S`。

---

### 第二阶段：VSpaceCode 自定义菜单集成
为了保持操作一致性，建议将你习惯的特殊命令（如任务运行和界面切换）集成到 VSpaceCode 菜单中，而不是留在 Vim 配置里。

**操作建议：** 在 VS Code 的 `settings.json` 中添加 `vspacecode.bindingOverrides`：
* [cite_start]**任务管理**：将 `<leader> r` [cite: 15] 映射为 `Space r r` (reRunTask)。
* [cite_start]**界面切换**：将 `<leader> z <leader>` [cite: 15] [cite_start]映射为 `Space t z` (toggleZenMode)，将 `<leader> c <leader>` [cite: 16] 映射为 `Space t c` (toggleCenteredLayout)。
* [cite_start]**只读切换**：将 `<leader> r <leader>` [cite: 16] 映射为 `Space t r`。

---

### 第三阶段：保留与增强 Vim 核心配置
有些配置是 VSpaceCode 无法替代且极其高效的，务必保留并持续优化：

* [cite_start]**插入模式 Snippets**：保留以 `;` 开头的符号快捷键（如 `;f` 生成括号、`;v` 生成大括号） [cite: 4, 5]。这是你提高编码速度的关键逻辑。
* [cite_start]**LaTeX 与 Markdown 增强**：保留 Visual 模式下的 `;m` (行内公式) 和 `;M` (块级公式) 映射 [cite: 24, 25][cite_start]，以及 Markdown 的加粗/斜体映射 [cite: 26]。
* [cite_start]**文本对象优化**：保留 `operatorPendingMode` 中 `L` 到 `$`、`H` 到 `^` 的映射 [cite: 22, 23]，这符合你对快速定位的追求。
* [cite_start]**自动切换输入法**：保留 `vim.autoSwitchInputMethod` 相关配置 [cite: 1]，这对中文开发者切换中英环境至关重要。

---

### 第四阶段：针对性修复与优化
针对你最近反馈的 **Backspace** 和 **Modifier Key** 问题：

* [cite_start]**按键重复修复**：针对你提到的 AutoHotkey 无法自动 repeat 的问题 [cite: 33][cite_start]，如果是因为 Windows 升级导致底层 Hook 冲突，可以尝试在 `vim.handleKeys` 中显式设置 `"<BS>": false` [cite: 2]，将退格键交还给系统处理，或者在 AHK 中使用 `SetKeyDelay` 尝试模拟物理按下。
* [cite_start]**插件启用**：确保 `vim.enableNeovim` 为 `true` [cite: 2] [cite_start]且路径正确 [cite: 12]，因为你习惯使用 Neovim 驱动的逻辑。
* [cite_start]**同步 VSpaceCode**：你的配置中已经有 `vspacecode.space` 的触发映射 [cite: 21, 32][cite_start]，请确保 `vim.leader` 设置为 `,` [cite: 12] 以防与 VSpaceCode 的空格键冲突。

---

### 总结：你的新配置文件结构建议
1.  **VSpaceCode (whichkey.binding)**: 负责所有 `Space` 开头的复杂功能菜单。
2.  **Vim Insert Mode**: 负责 `;` 开头的符号和代码片段快速输入。
3.  **Vim Visual Mode**: 负责选中文本后的包裹（Surround）和格式化操作。
4.  **Vim Normal Mode**: 仅保留最基础的运动（Motion）增强和少量的 `,` (Leader) 快捷键。