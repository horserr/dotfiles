# SSH common problems

## [SSH Connection Refused: Causes and Fixes](https://linuxize.com/post/fix-ssh-connection-refused/)

## [SSH Permission Denied (publickey): Causes and Fixes](https://linuxize.com/post/fix-ssh-permission-denied-publickey/)

| Problem                              | Fix                               |
| :----------------------------------- | :-------------------------------- |
| Key not on server                    | ssh-copy-id user@host             |
| Wrong permissions on ~/.ssh          | chmod 700 ~/.ssh                  |
| Wrong permissions on authorized_keys | chmod 600 ~/.ssh/authorized_keys  |
| Wrong permissions on private key     | chmod 600 ~/.ssh/id_ed25519       |
| SSH agent not running                | eval "$(ssh-agent -s)" && ssh-add |
| Wrong key offered                    | ssh -i ~/.ssh/key user@host       |
| SELinux blocking access              | sudo restorecon -R ~/.ssh         |
| Check auth log (Ubuntu)              | sudo tail -f /var/log/auth.log    |
| Debug SSH connection                 | ssh -vvv user@host                |

## [Fix SSH "Host Key Verification Failed" Error](https://linuxize.com/post/fix-ssh-host-key-verification-failed/)

| Task                                  | Command                    |
| :------------------------------------ | :------------------------- | ---------------- |
| Remove a host entry                   | ssh-keygen -R hostname     |
| Remove by IP                          | ssh-keygen -R 192.168.1.10 |
| Show the server’s new key fingerprint | ssh-keyscan host           | ssh-keygen -lf - |
| known_hosts file (user)               | ~/.ssh/known_hosts         |
| known_hosts file (system)             | /etc/ssh/ssh_known_hosts   |

# ssh escape sequence

| 快捷键             | 功能描述                   | 适用场景                                       |
| :----------------- | :------------------------- | :--------------------------------------------- |
| Enter + ~ + .      | 强制断开当前 SSH 连接      | 远程服务器卡死、网络挂起、无法退出时最有效     |
| Enter + ~ + Ctrl+Z | 将当前 SSH 会话挂起到后台  | 临时回到本地终端执行命令，后续可用 fg 恢复连接 |
| Enter + ~ + C      | 打开 SSH 命令行（ssh>）    | 在不断开连接的情况下，动态添加端口转发         |
| Enter + ~ + #      | 列出所有列出的转发连接     | 查看当前通过该 SSH 会话转发的所有端口状态      |
| Enter + ~ + ?      | 显示所有支持的转义序列帮助 | 忘记快捷键时随时查看帮助列表                   |
| Enter + ~ + ~      | 发送一个原生的 ~ 字符      | 当你需要向远程终端发送字面量 ~ 且刚好在行首时  |

## ssh canonicalization parse sequence illustration

请详细讲讲 canonicalization 介入之后的解析顺序，它是否会产生递归？拼接得到了完整的 hostname 之后是否会丢弃之前已经匹配到的配置，而重新读取配置？

> from chatgpt

是的。你问到的正是 `CanonicalizeHostname` 最容易被误解、但也最有意思的地方。

先给结论：

> **Canonicalization 会触发一次“重新解析配置”的 pass，但不是递归解析。**
>
> 更准确地说：OpenSSH 通常是“第一轮解析 → 得到是否需要 canonicalization 的配置 → canonicalize hostname → 如果 hostname 发生了 canonicalization，则用新的 hostname 再解析一次配置”。
>
> **第一轮已经得到的配置不会全部丢弃。** 第二轮是在已有配置基础上继续处理，而且仍然遵守“每个参数第一次获得的值有效”的规则。
>
> 因此，第一轮已经确定的参数，第二轮通常不能被新的 `Host` 配置覆盖。

OpenSSH 当前文档明确说：启用 `CanonicalizeHostname` 后，配置文件会再次处理，以新的 target name 匹配 `Host` 和 `Match`；同时配置的一般规则仍然是每个 directive 第一次得到的值有效。([OpenBSD Manual Pages][1])

不过，要理解“第二轮到底拿什么重新解析”，需要稍微深入一点源码级的模型。

---

### 1. 先建立一个最重要的模型：不是“重新开始”，而是“第二次 pass”

假设：

```sshconfig
Host foo
    User alice

Host *
    Port 22

Host foo.example.com
    User bob
    IdentityFile ~/.ssh/foo

Host *
    ServerAliveInterval 60

Host *
    CanonicalizeHostname yes
    CanonicalDomains example.com
```

执行：

```bash
ssh foo
```

我们先不要考虑细节，粗略理解成：

```text
                ssh foo
                   │
                   ▼
          ┌─────────────────┐
          │ First pass      │
          │ hostname = foo  │
          └────────┬────────┘
                   │
                   ▼
       读取 CanonicalizeHostname
                   │
                   ▼
              foo.example.com
                   │
                   ▼
          ┌────────────────────────┐
          │ Second / canonical pass│
          │ hostname =              │
          │ foo.example.com         │
          └────────────────────────┘
                   │
                   ▼
              最终配置
```

所以你说的：

> “拼接得到了完整 hostname 之后是否会重新读取配置？”

**是的。**

而且不是概念上的“重新读取”，OpenSSH 文档明确写的是：

> configuration files are processed again using the new target name

也就是**配置文件再次被处理**。([GitHub][2])

---

### 2. 但最关键的问题：第一次 pass 的结果会不会被清空？

**不会简单地全部清空。**

这正是你问题里最关键的地方。

OpenSSH 配置解析的基本机制是：

```text
某个 option：
    如果还没有值 → 设置
    如果已经有值 → 忽略
```

官方文档说的是：

> for each configuration directive, the first specified value will be used. ([GitHub][2])

所以可以把内部状态想象成：

```text
User         = NULL
HostName     = NULL
Port         = NULL
IdentityFile = NULL
ProxyJump    = NULL
```

第一轮：

```sshconfig
Host foo
    User alice
    Port 2222
```

变成：

```text
User         = alice
HostName     = NULL
Port         = 2222
IdentityFile = NULL
ProxyJump    = NULL
```

然后 canonicalization：

```text
foo
 ↓
foo.example.com
```

第二轮重新读取配置。

如果第二轮遇到：

```sshconfig
Host foo.example.com
    User bob
    IdentityFile ~/.ssh/foo
```

那么：

```text
User
    已经是 alice
    ↓
    bob 被忽略

IdentityFile
    还没有
    ↓
    设置为 ~/.ssh/foo
```

最终：

```text
User         = alice
Port         = 2222
IdentityFile = ~/.ssh/foo
```

所以：

> **第二轮不是“重新计算最终配置并覆盖第一轮结果”，而更接近于“拿新的 hostname 再扫描一次配置，把第一轮还没有得到的参数补上”。**

这是理解 canonicalization 的关键。

---

### 3. 这也解释了一个非常反直觉的例子

考虑：

```sshconfig
Host foo
    User alice

Host *
    CanonicalizeHostname yes
    CanonicalDomains example.com

Host foo.example.com
    User bob
```

执行：

```bash
ssh foo
```

第一轮：

```text
hostname = foo

Host foo
    User alice
        ↓
User = alice

Host *
    CanonicalizeHostname = yes
    CanonicalDomains = example.com
```

然后：

```text
foo
 ↓ canonicalize
foo.example.com
```

第二轮：

```text
hostname = foo.example.com

Host foo
    不匹配

Host *
    匹配

Host foo.example.com
    匹配
    User bob
```

但是：

```text
User = alice
```

已经在第一轮获得。

因此：

```text
bob
 ↓
忽略
```

最终：

```text
User = alice
```

而不是 `bob`。

这非常重要：

**canonicalization 第二轮并不意味着“canonical hostname 对应的 Host 规则拥有更高优先级”。**

它只是提供了**新的匹配机会**。

---

### 4. 所以 canonicalization 的真正价值是什么？

最重要的用途其实不是覆盖旧配置，而是：

> **让 canonical hostname 能够贡献第一轮尚未确定的配置项。**

例如：

```sshconfig
Host foo
    User alice

Host *
    CanonicalizeHostname yes
    CanonicalDomains example.com

Host *.example.com
    IdentityFile ~/.ssh/company_ed25519
    ForwardAgent yes
```

执行：

```bash
ssh foo
```

第一轮：

```text
foo

Host foo
    User alice

Host *
    CanonicalizeHostname yes
    CanonicalDomains example.com
```

得到：

```text
User = alice
```

canonicalize：

```text
foo
 ↓
foo.example.com
```

第二轮：

```text
foo.example.com

Host *.example.com
    IdentityFile ~/.ssh/company_ed25519
    ForwardAgent yes
```

这两个参数第一轮没有设置，所以第二轮可以补进来：

```text
User         = alice
IdentityFile = ~/.ssh/company_ed25519
ForwardAgent = yes
```

这就是 canonicalization 的设计意义。

---

### 5. 那么它会不会递归？

**正常意义上不会。**

也就是说，不是：

```text
第一轮
 ↓
canonicalize
 ↓
第二轮
 ↓
canonicalize
 ↓
第三轮
 ↓
canonicalize
 ↓
第四轮
...
```

不是这种递归模型。

更接近：

```text
initial pass
     │
     ▼
是否需要 canonicalization？
     │
     ├── 否 → 继续
     │
     └── 是
          │
          ▼
     canonicalize hostname
          │
          ▼
     canonical/final pass
          │
          ▼
        结束
```

源码里也可以看到 `canonical` / `final` 是作为不同解析阶段处理的；`Match canonical` 专门表示“配置文件正在 canonicalization 后重新解析”。([GitHub][3])

而当前文档也明确说：

```text
Match canonical
```

只在 hostname canonicalization 后的重新解析阶段匹配；`Match final` 则要求进行 final pass。([OpenBSD Manual Pages][1])

---

### 6. 为什么不会无限递归？

因为 canonicalization 本身不是：

```text
hostname = f(hostname)
一直调用 f()
```

它的逻辑是：

```text
原始 hostname
    ↓
根据 CanonicalDomains / DNS 等规则
    ↓
得到 canonical hostname
```

例如：

```text
foo
 ↓
foo.example.com
```

而不是：

```text
foo
 ↓
foo.example.com
 ↓
foo.example.com.example.com
 ↓
foo.example.com.example.com.example.com
```

事实上 OpenSSH 还有：

```sshconfig
CanonicalizeMaxDots
```

来限制哪些 hostname 会尝试 canonicalization。当前默认值是 `1`，也就是说包含超过一个 dot 的名字默认不会继续进行这种 canonicalization。([GitHub][2])

因此：

```text
foo
```

适合：

```text
foo.example.com
```

而：

```text
foo.example.com
```

本身已经有足够多的 domain qualification，通常不会再变成：

```text
foo.example.com.example.com
```

---

### 7. 一个非常重要的细节：第二轮看到的 `HostName` 也可能不同

这也是为什么我不建议把 canonicalization 简化成“字符串拼接”。

比如：

```sshconfig
Host foo
    HostName internal-foo

Host *
    CanonicalizeHostname yes
    CanonicalDomains example.com
```

执行：

```bash
ssh foo
```

这里实际上涉及两个概念：

```text
原始名字：
foo

HostName：
internal-foo
```

canonicalization 的目标 hostname 和最终连接 hostname 并不应该简单地理解成：

```text
foo → foo.example.com
```

而是 OpenSSH 会根据当前配置状态、目标 hostname、canonicalization 规则进行处理。

源码中对 `final_pass` 甚至有特殊处理：在 final pass 中，用的是已经得到的 `options->hostname` 来作为匹配 hostname；而非 final pass 时则会区分 `options->hostname` 和原始 `host_arg`。([GitHub][3])

这也是为什么源码级别理解时，要区分：

```text
original host
target host
canonical host
HostName
```

它们不是完全同一个东西。

---

### 8. `Host` 和 `Match host` 在 canonicalization 后也有区别

当前 OpenSSH 文档还有一个很容易忽略的细节：

```sshconfig
Match host ...
```

匹配的是：

> target hostname，在 `Hostname` 或 `CanonicalizeHostname` 替换之后。

而：

```sshconfig
Match originalhost ...
```

匹配的是：

> 命令行最开始指定的 hostname。

([OpenBSD Manual Pages][1])

这意味着：

```bash
ssh foo
```

canonicalization 后：

```text
originalhost = foo
host         = foo.example.com
```

于是你可以明确区分：

```sshconfig
Match originalhost foo
    ...

Match host foo.example.com
    ...
```

这是比单纯使用：

```sshconfig
Host foo
```

更加精细的控制方式。

---

### 9. `Match canonical` 是专门为这个场景准备的

例如：

```sshconfig
Host *
    CanonicalizeHostname yes
    CanonicalDomains example.com

Match canonical host *.example.com
    User alice
```

这里：

```text
第一次 pass
    ↓
Match canonical
    ↓
不成立
```

canonicalization：

```text
foo
 ↓
foo.example.com
```

第二次 pass：

```text
Match canonical
    ↓
成立
```

因此：

```text
Match canonical
```

可以理解成：

> “我只想在 canonical hostname 已经产生以后执行这段配置。”

官方文档正是这样定义的。([OpenBSD Manual Pages][1])

---

### 10. `Match final` 又稍微不一样

这是另一个容易混淆的地方。

```sshconfig
Match final
    ...
```

表示：

> 要求 SSH 进行一次 final pass。

即使：

```sshconfig
CanonicalizeHostname no
```

也可以触发 final pass。

如果：

```sshconfig
CanonicalizeHostname yes
```

那么 canonical pass 和 final pass 是同一轮。([OpenBSD Manual Pages][1])

所以可以把解析阶段理解成：

```text
                 ┌──────────────┐
                 │ Initial pass │
                 └──────┬───────┘
                        │
             CanonicalizeHostname?
                 ┌──────┴──────┐
                 │             │
                yes            no
                 │             │
                 ▼             │
          canonicalize         │
                 │             │
                 ▼             │
          canonical pass       │
                 │             │
                 └──────┬──────┘
                        │
                 Match final?
                        │
                        ▼
                   final pass
```

不过如果 canonicalization 已经发生，canonical/final 可以是同一轮，而不是两轮。([OpenBSD Manual Pages][1])

---

### 11. 所以你问的“是否丢弃之前配置”，可以精确回答为：

**不是。**

更准确地说：

```text
第一轮：
    得到一部分配置
             │
             ▼
       canonicalization
             │
             ▼
第二轮：
    使用新的 hostname
    再扫描配置
             │
             ▼
    对尚未确定的参数进行补充
```

不是：

```text
第一轮：
    User=alice
    Port=2222
             │
             ▼
canonicalize
             │
             ▼
全部清空
             │
             ▼
第二轮重新算：
    User=bob
    Port=22
```

而是：

```text
第一轮：
    User=alice
    Port=2222
             │
             ▼
canonicalize
             │
             ▼
第二轮：
    User=bob          → 忽略
    Port=22           → 忽略
    IdentityFile=xxx  → 接受
    ProxyJump=xxx     → 接受
```

因此可以把它理解成：

> **第二轮是“追加解析”，不是“重新覆盖解析”。**

---

### 12. 但有一个更微妙的问题：并不是所有 option 都简单遵循这个模型

这里需要稍微修正一下前面的简化。

OpenSSH 的配置项有一些特殊处理，例如：

```text
IdentityFile
IdentityAgent
SendEnv
SetEnv
CertificateFile
```

这类选项可能是列表、数组或者具有特殊合并语义，并不一定像：

```text
User
Port
ForwardAgent
```

一样简单地理解成一个 `NULL → value` 的槽位。

所以：

> **“first obtained value” 是理解大多数单值 option 的核心规则，但不能把所有配置项都机械地当成一个标量变量。**

OpenSSH 官方文档自己也用了：

> “Unless noted otherwise”

也就是说，除非该 directive 有特殊说明，否则才是 first obtained value。([GitHub][2])

---

### 13. 最后给你一个完整的“脑内执行模型”

假设：

```sshconfig
Host db
    User alice

Host *
    CanonicalizeHostname yes
    CanonicalDomains corp.example.com
    Port 22

Host db.corp.example.com
    User bob
    IdentityFile ~/.ssh/corp
    Port 2222
```

执行：

```bash
ssh db
```

你可以脑补成：

```text
══════════════════════════════
PASS 1
hostname = "db"
original = "db"
══════════════════════════════

Host db
    User alice
        ↓
    User = alice

Host *
    CanonicalizeHostname yes
        ↓
    Canonicalization = yes

    CanonicalDomains corp.example.com
        ↓
    canonical domains = ...

    Port 22
        ↓
    Port = 22

Host db.corp.example.com
    不匹配


══════════════════════════════
CANONICALIZATION
══════════════════════════════

db
 ↓
db.corp.example.com


══════════════════════════════
PASS 2
hostname = "db.corp.example.com"
original = "db"
══════════════════════════════

Host db
    不匹配

Host *
    Port 22
        ↓
    已经有 Port
        ↓
    忽略

Host db.corp.example.com
    User bob
        ↓
    已经有 User=alice
        ↓
    忽略

    IdentityFile ~/.ssh/corp
        ↓
    尚未设置
        ↓
    接受

    Port 2222
        ↓
    已经有 Port=22
        ↓
    忽略


══════════════════════════════
FINAL
══════════════════════════════

original hostname = db
target hostname   = db.corp.example.com

User         = alice
Port         = 22
IdentityFile = ~/.ssh/corp
```

这就是你刚才问的三个问题的核心答案：

**会不会递归？**

不会。正常情况下是有限的解析 pass，而不是 canonicalize → 再 canonicalize → 无限递归。

**canonicalization 后会不会重新读取配置？**

会。OpenSSH 明确会使用新的 target name 再处理配置，以获得新的 `Host` / `Match` 匹配。([GitHub][2])

**第一次匹配到的配置会不会被丢掉？**

不会。第一轮得到的配置仍然存在；第二轮主要是在已有结果上继续填充，而且普通配置项仍遵循 first-obtained 规则。

如果你真正想彻底掌握这个机制，下一步最值得看的其实是一个**具体的 OpenSSH 配置文件，逐行模拟 Pass 1 → canonicalization → Pass 2**。尤其是把 `Host`、`HostName`、`Match host`、`Match originalhost`、`Match canonical`、`Match final`、`%n`、`%h` 全部放进同一个例子里，会非常清楚。

[1]: https://man.openbsd.org/OpenBSD-7.8/ssh_config.5?utm_source=chatgpt.com "ssh_config(5) - OpenBSD manual pages"
[2]: https://github.com/openssh/openssh-portable/blob/master/ssh_config.5?utm_source=chatgpt.com "openssh-portable/ssh_config.5 at master · openssh/openssh-portable · GitHub"
[3]: https://github.com/openssh-gsskex/openssh-gsskex/blob/master/readconf.c?utm_source=chatgpt.com "openssh-gsskex/readconf.c at master · openssh-gsskex/openssh-gsskex · GitHub"
