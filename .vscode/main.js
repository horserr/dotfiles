/// <reference path="c:/Users/ASUSCosmos/.vscode/extensions/nur.script-0.2.1/@types/api.global.d.ts" />
/// <reference path="c:/Users/ASUSCosmos/.vscode/extensions/nur.script-0.2.1/@types/vscode.global.d.ts" />
//  @ts-check
//  API: https://code.visualstudio.com/api/references/vscode-api

function activate(_context) {
   window.showInformationMessage('Hello, World!');
}

function deactivate() {}

// module.exports = { activate, deactivate }

// import * as vscode from 'vscode';

// export async function activate(context: vscode.ExtensionContext) {
//     // 1. 获取内置 Git 扩展的 API
//     const gitExtension = vscode.extensions.getExtension('vscode.git')?.exports;
//     if (!gitExtension) return;
//     const git = gitExtension.getAPI(1);

//     // 2. 获取当前处于激活状态的仓库（假设有打开的项目）
//     const repository = git.repositories[0];
//     if (!repository) {
//         vscode.window.showErrorMessage("未找到活动的 Git 仓库");
//         return;
//     }

//     // 3. 准备你想单独 fetch 的远程分支名称（ref）
//     // 如果不传，它会默认取当前分支关联的远程 ref
//     const targetRef = 'refs/remotes/origin/feature-branch';

//     // 4. 执行命令 (必须按照它声明的参数结构传参)
//     // 第一个参数是内置命令名，后面依次是源码中对应的参数
//     await vscode.commands.executeCommand('git.fetchRef', repository, targetRef);

//     vscode.window.showInformationMessage(`成功单独 Fetch 了 ${targetRef}`);
// }
