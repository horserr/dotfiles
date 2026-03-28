# Horserr's dotfiles config on Windows

[Chezmoi Home Page](https://www.chezmoi.io/)

This repo is adapted from: [twpayne's dotfiles](https://github.com/twpayne/dotfiles)

## set WSL network mode to `mirrored`

link: https://learn.microsoft.com/en-us/windows/wsl/networking#mirrored-mode-networking

powershell admin:

```pwsh
Set-NetFirewallHyperVVMSetting -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -DefaultInboundAction Allow
```

### error: CreateInstance/CreateVm/ConfigureNetworking/0x8007054f

solution:[link](https://github.com/microsoft/WSL/issues/12351#issuecomment-3938183381)

powershell admin

```pwsh
wsl --shutdown
# wait for at least 8 seconds

# restart HNS services
net stop hns
net start hns

# reset WSL network configurations
netsh winsock reset
netsh int ip reset

# restart Windows machine, and set WSL network to ``mirrored'' mode.
# can use ip route show to check whether being successful.
```

## chezmoi usage

- 查看可用数据：chezmoi data
- 测试模板渲染：chezmoi execute-template < 文件名.tmpl
- 查看差异：chezmoi diff

## git

`git checkout --orphan main`

`git update-index --chmod=+x <file>`
如果你想看看当前 Git 记录里，哪些文件是可执行的，可以运行：

```sh
git ls-files --stage
```

to fix end of line encoding

```sh
git add --renormalize .
```

to update staged files

```sh
git add -u
```

to remove file from history
```sh
uvx git-filter-repo --path <file path> --invert-paths
```

在输出列表中，权限位以 100755 开头的文件就是 Git 认为的可执行文件。

## test proxy connection in WSL

在 WSL2 的镜像模式下，判断代理是否生效最直接的方法确实是查看 **出口 IP**。不过，由于镜像模式的特殊性，你需要区分“浏览器代理”和“终端代理”。

以下是几种最有效的方法，按推荐程度排序：

---

### 1. 使用 `curl` 命令检查出口 IP（最推荐）
在终端中通过不同的 API 查询，可以直观看到你的流量是从哪个地理位置发出的。

* **检查海外连接（判断梯子是否生效）：**
    ```bash
    curl -i https://ipapi.co/json/
    ```
    *如果返回的 `country_name` 是美国、新加坡等，说明代理已成功拦截了终端流量。*

* **检查国内连接（判断是否直连）：**
    ```bash
    curl -i http://ip.6655.com/ip.aspx
    ```

> [!TIP]
> **为什么要用 `curl` 而不是浏览器？**
> 在 Windows 浏览器里看到 IP 变了，不代表 WSL 终端里的 `apt` 或 `git` 也能走代理。Linux 终端通常需要独立配置环境变量。

---

### 2. 检查环境变量
在镜像模式下，即便你开启了 `autoProxy`，很多 Linux 程序依然需要看到环境变量才会走代理。你可以输入以下命令检查：

```bash
env | grep -i proxy
```
* **如果没有任何输出**：说明你的终端目前是“裸奔”状态，流量会直接尝试通过物理网卡发出。
* **如果有输出**（如 `http_proxy=http://127.0.0.1:xxxx`）：说明终端程序已经尝试对接代理。

---

### 3. 测试 Google 连通性
有时候 IP 库更新不及时，最暴力的办法是直接看能不能“翻墙”：

```bash
curl -I -s --connect-timeout 5 https://www.google.com
```
* 如果返回 `HTTP/2 200`，说明代理链路完全打通。
* 如果卡住或显示 `Connection timed out`，说明代理未生效。

---

### 4. 镜像模式下的特殊验证：监听端口
既然是镜像模式，WSL 和 Windows 共享端口。你可以直接在 WSL 里检查能不能看到 Windows 代理软件的监听端口（假设你的代理端口是 `7890`）：

```bash
ss -antl | grep 7890
```
* 如果你能看到 `LISTEN` 状态，说明 WSL 已经“看”到了 Windows 上的代理服务，这时候你只需要把 `export http_proxy="http://127.0.0.1:7890"` 写入 `.bashrc` 即可。

---

### 总结与建议
在镜像模式下，最理想的状态是：
1.  **`.wslconfig`** 中开启了 `autoProxy=true`（负责底层链路）。
2.  **`.bashrc`** 或 **`.zshrc`** 中手动加上了 `export` 变量（负责告诉终端软件去哪找代理）。

**你需要我帮你写一个可以快速开关 WSL 代理的 Shell 函数吗？** 这样你只需要输入一个简单的命令（比如 `proxy_on`）就能一键切换状态。