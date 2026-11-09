# research

把 Claude Code 配置成科研伙伴，而不是科研执行器。插件面向机器学习、机器人学与具身智能（embodied AI）研究，方法论本身也可用于其他实证领域。这个插件结合了两部分：

- **来自 [`plan.md`](plan.md) 的科研工作流**：五 Agent 科研团队、四阶段流程、研究空白发现、研究规划、分层研究记忆。
- **来自 [Mapika/paper-reader](https://github.com/Mapika/paper-reader) 的论文处理能力**：真实下载 PDF / arXiv tex source、从 OpenAlex / Crossref / DBLP / ACL / Semantic Scholar 解析真实 BibTeX、每条论断带 §/页/表定位，绝不编造引用。

## 安装

本仓库已把插件注册到 `.claude-plugin/marketplace.json`：

```text
/plugin marketplace add ~/.config/.dotfiles/claude-plugins
/plugin install research@dotfiles
```

本地开发时可以直接加载目录：

```bash
cc --plugin-dir ~/.config/.dotfiles/claude-plugins/research
```

安装后重启 Claude Code。插件提供的命令、Agent 会自动被发现。

## 组件

### Agents（5 个）

| Agent | 职责 |
| --- | --- |
| `research:literature-scout` | 多方向文献发现、术语扩展、引用关系、反例搜索 |
| `research:paper-analyst` | 深读单篇论文，提取问题、假设、方法、表示、评估、局限、隐藏假设、未解问题 |
| `research:research-synthesizer` | 跨论文聚类、方法对比、矛盾定位、研究空白推导 |
| `research:critical-reviewer` | 专门反驳：问题是否真实、是否已被解决、创新是否只是换术语、实验能否证明贡献 |
| `research:project-architect` | 研究路线、实验设计、baseline、指标、风险、里程碑 |

主 Agent 负责编排；子 Agent 负责各自阶段。不要让一个 Agent 包办全部。

### Skills（7 个）

| Skill | 触发方式 | 作用 |
| --- | --- | --- |
| `research-standards` | 自动 | 证据分级、四阶段流程、Agent 调度、Provenance/Validity 规则 |
| `paper-reader` | 自动 | 下载论文、解析真实 BibTeX、生成带定位的笔记 |
| `literature-review` | `/research:literature-review <问题>` | 系统性文献调研，输出矩阵/时间线/综述 |
| `research-gap` | `/research:research-gap <方向>` | 从假设与局限推导候选 Gap，强制包含反证论文 |
| `research-planning` | `/research:research-planning <想法>` | 把已验证的问题转成研究提案 |
| `weekly-research-review` | `/research:weekly-research-review` | 对照研究记忆，检查问题/假设/决策漂移 |
| `research-init` | `/research:research-init [目录]` | 创建分层 `research/` 记忆目录（不覆盖已有笔记） |

### Hooks（2 个）

| 事件 | 行为 |
| --- | --- |
| `SessionStart` | 若项目存在 `research/`，注入 overview、未解问题、假设、研究 gaps 与论文数量的快照 |
| `Stop` | 若项目存在 `research/`，提醒把本次会话的新论文、假设、决策、局限写回研究记忆。每个会话最多提醒一次，避免每轮都打扰 |

Hooks 只做确定性提醒，不会自动修改研究结论。它们只在该目录存在时生效。

### 研究记忆模板

`/research:research-init` 会创建：

```text
research/
├── 00_overview.md
├── 01_research_questions/
│   ├── confirmed.md
│   ├── hypotheses.md
│   └── unresolved.md
├── 02_literature/
│   ├── paper_database.csv
│   ├── search_strategy.md
│   ├── literature_matrix.md
│   ├── research_timeline.md
│   └── literature_review.md
├── 03_knowledge/
│   ├── concepts/
│   ├── methods/
│   └── relationships/
├── 04_experiences/
│   ├── failed_approaches.md
│   └── experimental_observations.md
├── 05_project/
│   ├── research_plan.md
│   ├── milestones.md
│   └── decisions.md
└── 06_open_problems/
    └── research_gaps.md
```

## 典型用法

### 1. 从模糊想法开始

```text
我想研究 VLA 中长期可复用记忆的冲突问题，目前还不确定问题定义和技术路线。
```

预期行为：先调用 `research:literature-scout` 调查 VLA memory、robot memory、continual learning、experience reuse；再用 `research:paper-analyst` 提取记忆表示与复用机制；`research:research-synthesizer` 判断冲突来自 context、intention、experience 还是 reusable knowledge；`research:critical-reviewer` 检查这是否只是 catastrophic forgetting / interference 的换名；只有问题被论证后，`research:project-architect` 才设计实验。

### 2. 系统文献调研

```text
/research:literature-review VLA 长期记忆中的经验复用与冲突
```

输出写入 `research/02_literature/`，并返回候选数、已验证数、已读数、主要聚类、未解问题与覆盖限制。

### 3. 找研究空白

```text
/research:research-gap VLA memory conflict
```

每个候选 Gap 必须包含 Supporting papers、Contradicting papers、Closest existing work、disconfirmation search、falsification condition。

### 4. 读一篇论文

```text
读一下 https://arxiv.org/abs/2205.14135
```

`paper-reader` 会把 PDF、tex source、真实 `citation.bib` 放到 `~/papers/<slug>/`，生成 `notes.md`，并在存在 `research/` 时登记到 `paper_database.csv`。

### 5. 每周复盘

```text
/research:weekly-research-review
```

## 依赖

- Python 3.9+（`fetch_paper.py` 仅用标准库）
- `uvx`（用于 `pypdf` 提取 PDF 文本；无需系统 poppler）
- 网络访问：`arxiv.org`、`api.openalex.org`、`dblp.org`、`api.crossref.org`、`aclanthology.org`、`api.semanticscholar.org`、`api.unpaywall.org`
- `bash`（用于 hooks；Windows 上由 Git Bash 提供）

论文默认保存到 `~/papers/<slug>/`。BibTeX 解析失败时会写 `citation.MISSING`，不会编造条目。

## 推荐设置

| 设置 | 建议 |
| --- | --- |
| Model | 综合与规划阶段使用能力更强的模型；子 Agent 默认 `inherit` |
| Effort | 研究空白推导、跨论文综合、实验设计使用较高推理投入 |
| Permissions | 文献目录和研究笔记优先只读；修改 `research_plan.md` 或方向性决策前确认 |
| Extended context | 需要同时阅读多篇长论文时再启用 |
| Auto memory | 与 `research/` 分工：Auto memory 存会话偏好，`research/` 存可审计的研究结论 |

## 可选：外部工具接入

插件本身不附带 MCP server。`paper-reader` 已通过 HTTP 直接查询 OpenAlex、Crossref、DBLP、ACL Anthology、Semantic Scholar、arXiv 和 Unpaywall，因此发现与核验文献不依赖 MCP。

如需管理个人文献库，可另外配置 Zotero MCP；但不要让 MCP 返回的元数据绕过引用核验：论文结论仍必须能追溯到 bibkey 和 locator。

## 设计边界

- 研究方向和重要假设由人决定；Agent 负责扩展空间和主动反驳。
- 不把整个文献库塞进一个 Markdown；一篇文章一行，一个概念一个文件。
- 论文结论 ≠ 本项目结论。两者保留不同 Provenance 与 Validity。
- Agent 的自信陈述在核对来源前只算 `claim` 或 `inference`。
- 不自动实现每个想法；重大架构或实验变更前先确认。

## 许可证与署名

本插件 MIT，© 2026 Horserr。`skills/paper-reader/` 改编自 Mapika/paper-reader（MIT），详见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
