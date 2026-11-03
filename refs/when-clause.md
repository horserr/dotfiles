# vscode when clause

- isComposing
    冲突场景：假设你为 Enter 键绑定了一个命令。如果你在打中文时按 Enter（通常是为了把英文字母直接上屏），如果没有限制，VS Code 会直接执行你的快捷键命令，而不是处理输入法，这就破坏了打字体验。解决方案：VS Code 的很多核心快捷键（如接受建议、关闭查找框等）都会加上 !isComposing（即：当不在输入法组字时）作为条件。
