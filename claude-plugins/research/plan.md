如果你的目标是让 Claude Code 成为科研助理，而不只是一个能够读写代码的 Agent，我建议不要只调整模型参数，而是把它配置成一套具有科研工作流的多 Agent 系统。

对于科研而言，Claude Code 最值得配置的能力有五类：

1. Literature Research：文献检索、阅读、归纳、交叉验证。
2. Research Reasoning：识别研究空白、分析论文之间的矛盾、提出研究假设。
3. Project Planning：将模糊研究想法转化为可执行的研究路线。
4. Research Memory：保存长期研究上下文，避免每次重新调研。
5. Critical Review：让 Agent 扮演审稿人，主动攻击研究方案中的薄弱环节。

我尤其建议把 Claude Code 配置成一个具有主 Agent 和多个专业 Subagents 的科研团队，而不是让一个 Agent 包办所有事情。

下面按照配置层次介绍。

## 一、先理解 Claude Code 的配置体系

Claude Code 有几种配置机制，它们解决的问题并不相同。

根据 Anthropic 2026 年的配置指南，可以将其归纳为以下体系。

[image](https://www.google.com/s2/favicons?domain=https://claude.com\&sz=32)

Claude by Anthropic+1



| 配置机制            | 作用        | 科研中的用途         |
| --------------- | --------- | -------------- |
| `CLAUDE.md`     | 长期指令      | 定义科研原则、研究背景    |
| `Rules`         | 条件化规则     | 约束文献分析、实验规范    |
| `Skills`        | 可复用工作流    | 文献调研、研究方案设计    |
| `Subagents`     | 专业化 Agent | 分别负责检索、分析、审稿   |
| `Hooks`         | 自动化触发     | 保存研究记录、检查引用    |
| `MCP`           | 外部工具接入    | 连接文献数据库、Zotero |
| `Output Styles` | 改变输出风格    | 从代码助手转为科研顾问    |

这里有一个非常重要的设计原则：

不要把所有科研要求都塞进 CLAUDE.md。

例如：

- 科研方向和长期约束，放在 `CLAUDE.md`。
- 如何进行系统性文献调研，放在 Skill。
- 谁负责文献检索、谁负责批判性分析，放在 Subagents。
- 如何自动检查引用和保存进度，放在 Hooks。

这样可以避免主上下文被大量重复的科研指令占据。

## 二、最重要的配置：建立科研 Subagents 团队

我建议采用一个主 Agent + 五个专业 Subagents 的架构。

Orchestrator

Chief Research Agent

理解研究目标、拆解任务、协调子 Agent、整合研究结论

1\. Literature Scout

文献发现、关键词扩展、研究脉络和相关工作检索

2\. Paper Analyst

深入阅读论文、提取方法、假设、局限性

3\. Research Synthesizer

跨论文对比、识别研究空白、构建理论联系

4\. Critical Reviewer

反驳研究假设、寻找反例、评估创新性

5\. Project Architect

研究路线设计、任务分解、技术可行性、实验规划和里程碑

这五个 Agent 不应该只是五个不同名字的聊天机器人，而应该有不同的职责、工具权限和评价标准。

### 1. Literature Scout：不要只会搜索关键词

它的任务应该是：

- 根据研究问题生成多个检索方向。
- 找到经典论文、近期代表性论文和相邻领域论文。
- 建立论文之间的引用关系。
- 识别不同学术社区使用的不同术语。
- 区分直接相关工作和间接相关工作。

例如你的 VLA Memory Conflict 研究：

不能只搜索 `VLA memory`，还应该搜索：

- Long-term memory in embodied agents
- Memory retrieval and reuse in robotics
- Experience reuse in manipulation
- Continual learning in VLA
- Task decomposition and skill composition
- Memory interference and catastrophic forgetting

这样才能避免被某个领域的术语限制住。

### 2. Paper Analyst：强制使用统一的论文分析模板

不要让 Agent 简单总结 Abstract。

要求它对每篇论文提取：

| 维度             | 分析内容          |
| -------------- | ------------- |
| Problem        | 论文解决什么问题？     |
| Motivation     | 为什么这个问题重要？    |
| Assumption     | 依赖什么假设？       |
| Method         | 核心方法和机制是什么？   |
| Representation | 如何表示信息？       |
| Evaluation     | 如何设计实验？       |
| Limitation     | 作者承认和实际存在的局限  |
| Reusability    | 其机制能否迁移到其他任务？ |

特别增加两个维度：

- Hidden Assumptions：作者没有明确说出来，但方法成立所依赖的假设。
- Unresolved Questions：论文没有解决的问题。

这两个维度比普通的论文摘要更有科研价值。

### 3. Research Synthesizer：真正提升文献调研水平的关键

我认为这是整个系统中最重要的 Agent 之一。

它不应该重复 Literature Scout 的工作，而是回答：

1. 哪些论文实际上在解决同一个问题？
2. 哪些论文使用不同方法解决了相似问题？
3. 哪些论文之间存在理论矛盾？
4. 哪些研究假设尚未被充分验证？
5. 哪些现有技术可以组合？
6. 哪些问题仍然没有得到有效解决？

例如：

| 研究方向                  | 已有研究      | 可能的不足              |
| --------------------- | --------- | ------------------ |
| VLA trajectory memory | 保存历史观察和动作 | 是否能跨任务长期复用？        |
| Skill memory          | 保存可执行技能   | 是否能处理技能之间的冲突？      |
| Experience retrieval  | 检索相似经验    | 是否考虑经验有效性？         |
| Continual learning    | 持续学习新任务   | 是否能区分新知识与旧知识的适用范围？ |

这才是从文献阅读走向研究问题发现的过程。

### 4. Critical Reviewer：必须有一个专门反对你的 Agent

科研 Agent 最容易犯的错误是：

它会努力证明你的研究想法是正确的，而不是判断你的研究想法是否成立。

因此，需要一个独立的审稿人 Agent。

它应该重点检查：

- 研究问题是否真的存在？
- 已有工作是否已经解决？
- 创新性是否只是更换术语？
- 方法是否存在不可验证的假设？
- 实验能否证明提出的贡献？
- 有没有更简单的解释？

对于你的 VLA Memory Conflict 方向，它应该特别尝试反驳：

> 所谓 Memory Conflict 是否只是传统的 catastrophic forgetting、retrieval interference 或 context mismatch 的另一种表述？

如果无法明确区别这些问题，就说明研究定义还不够成熟。

### 5. Project Architect：从想法到执行

它不负责寻找论文，而负责将已经形成的研究认识转化为项目计划。

要求输出：

- Research Question
- Hypothesis
- Theoretical Framework
- Proposed Method
- Required Components
- Experimental Design
- Baselines
- Evaluation Metrics
- Risks
- Milestones

最重要的是区分：

- 已经被文献证实的事实。
- 根据文献推导的研究假设。
- 尚未验证的设计选择。

否则，项目计划很容易变成一份看起来完整、实际上建立在未经验证假设上的方案。

[image](https://www.google.com/s2/favicons?domain=https://claude.com\&sz=32)

Claude by Anthropic+1

## 三、配置 Skills：把科研方法固化为可调用工作流

Subagents 负责专业分工，Skills 负责定义工作流程。

建议建立以下目录：

```
.claude/
├── CLAUDE.md
│
├── agents/
│   ├── literature-scout.md
│   ├── paper-analyst.md
│   ├── research-synthesizer.md
│   ├── critical-reviewer.md
│   └── project-architect.md
│
├── skills/
│   ├── literature-review/
│   │   └── SKILL.md
│   ├── paper-analysis/
│   │   └── SKILL.md
│   ├── research-gap/
│   │   └── SKILL.md
│   ├── research-planning/
│   │   └── SKILL.md
│   └── experiment-design/
│       └── SKILL.md
│
└── rules/
    ├── citation.md
    ├── evidence.md
    └── research-quality.md
```

我建议优先实现下面四个 Skill。

### Skill A：`/literature-review`

工作流程：

1. 接收研究问题。
2. 生成检索关键词和同义词。
3. 分多个方向搜索文献。
4. 建立候选论文清单。
5. 对论文进行相关性分级。
6. 深入阅读高相关论文。
7. 生成文献对比矩阵。
8. 汇总研究发展脉络。

最终输出：

```
literature/
├── search_strategy.md
├── paper_catalog.csv
├── literature_matrix.md
├── research_timeline.md
└── literature_review.md
```

### Skill B：`/research-gap`

这是我最建议你投入精力设计的 Skill。

它不是简单地要求 Agent 找出 Gap，而是要求它执行以下推理：

```
Existing Research
       |
       v
Identify Assumptions
       |
       v
Identify Limitations
       |
       v
Cross-paper Comparison
       |
       v
Unresolved Problems
       |
       v
Candidate Research Gaps
       |
       v
Evidence-based Validation
       |
       v
Research Opportunities
```

每个候选 Gap 必须包含：

- Gap Description
- Supporting Papers
- Contradicting Papers
- Why Existing Methods Fail
- Potential Contribution
- Feasibility
- Confidence Level

尤其是 `Contradicting Papers`，防止 Agent 只收集支持自己结论的证据。

### Skill C：`/research-planning`

输入：

一个模糊的研究想法。

输出：

```
1. Problem Definition
2. Research Motivation
3. Research Questions
4. Research Hypotheses
5. Related Work
6. Proposed Architecture
7. Methodology
8. Experimental Design
9. Baselines
10. Evaluation Metrics
11. Potential Risks
12. Research Milestones
```

还应该要求它对每个阶段估计：

- 技术难度
- 所需资源
- 前置条件
- 失败风险
- 验证标准

### Skill D：`/weekly-research-review`

每次研究工作结束后：

- 更新已经阅读的论文。
- 记录本周产生的新假设。
- 更新研究问题的确定程度。
- 记录尚未解决的问题。
- 检查当前项目计划是否需要调整。

这个 Skill 可以帮助 Claude Code 逐渐形成长期的研究上下文。

Anthropic 推荐将重复的多步骤流程封装为 Skills，而不是将完整操作流程一直放在全局指令中。

[image](https://www.google.com/s2/favicons?domain=https://claude.com\&sz=32)

Claude by Anthropic+1



## 四、MCP：让 Claude Code 真正拥有文献调研工具

这是提升文献调研能力非常重要的一步。

Claude Code 本身有 Agent 推理能力，但如果没有可靠的数据源和检索工具，它可能只能依赖有限的搜索能力，甚至产生文献引用错误。

我建议配置以下几类工具。

[Zotero](https://images.openai.com/static-rsc-4/4pkeZjAgMKrsZ7_ZIHp46zJsB-rN8RzreQs4bTkL0doVH6WGUG1qFJN_HZWemz80sEEp8TTGzMSHqEmA03Scmxt47zleasoHjNtHXrvAs-xraGC6LdP2SR0o5vi9otyA7OFmZSxa9JJ0ccyOLSDKS3EOkXZ5k1lYeMBhcJKQhAA?purpose=inline)

Zotero

优先配置

管理论文 PDF、文献元数据、标签、笔记和引用。让 Claude 能读取你的个人文献库。

[Zotero 官网](https://www.zotero.org/?utm_source=chatgpt.com)

[Semantic Scholar | Claim Your Author Page](https://images.openai.com/static-rsc-4/M3uYkdF6_7GkELW5bXC2_FYWBRKGpkO07PjcARMTnEOeiTEcLoR52ij0ak-1MeGAJZPovCEdv4piem5WV7gf_Nifon-mv_eOkfs7NEFocUqeL4_3-rQ6-bJ7UtkEVr3HxOmjAr-wsEy7qwtD1ABUUPPrbIR26GRNuJuhNmLu8mQ?purpose=inline)

Semantic Scholar

搜索论文、作者、引用关系和相关研究。

[Semantic Scholar](https://www.semanticscholar.org/?utm_source=chatgpt.com)

[Universidad Central de Chile se suma a tendencia mundial de Ciencia Abierta y utiliza OpenAlex para el seguimiento de sus publicaciones - Universidad Central de Chile](https://images.openai.com/static-rsc-4/UcKNPZwWqYToHS2XYGt9sNF6eR1a65ncxPhW17t5ZHCdZTT3BCGbI6rcVmeseazBXQfbkYjkEb4w8xUROk_pmJlg9zqrel0U_lh-05THY4Oly-HU05B7-azy6PWC82S1j7u9VxwJsvZ9bid0jZQ5gXxP4eEkD5NZr3DPIn-0tdc?purpose=inline)

OpenAlex

学术文献元数据、研究领域、作者和引用网络分析。

[OpenAlex](https://openalex.org/?utm_source=chatgpt.com)

[Cornell: Computing & Information Science | Cornell Bowers](https://images.openai.com/static-rsc-4/2AIiSCSdPlr6izCkl4eDAyUIVwwV_XRM8WDkn6RVt7p5EiM527kttSpiAdmhqdf6IbRPqFzzRx8514nPT0ZXzWu6PRMIolInuMmzlDrBtaiGKLZok8-PYnqK4XLgbQ0dSVBReq15p0YndAe6DrK6jpcKLDriU0umprGtBgFwA0o?purpose=inline)

arXiv

获取机器学习、机器人、计算机视觉等方向的预印本。

[arXiv](https://arxiv.org/?utm_source=chatgpt.com)

[crossref.jpeg](https://images.openai.com/static-rsc-4/lx9178QPJ32v-hHlsd2Dp2GkWDLOcqpl1kqnQTg7DvHjh39RDL66VysQDr7SvI9QuWisIpSxoqU5Xj4Rtiw4HIjgp6uvku99UHS0nb43Y1tVEi1fI33oxnV4Jh2kFg2aa7zUH8fVXOqSp5HFprvCbRpd0PCJWW7vHUG1QfS-pjg?purpose=inline)

Crossref

DOI 和出版元数据核验，减少错误引用。

[Crossref](https://www.crossref.org/?utm_source=chatgpt.com)

这里有一个值得注意的区别：

- Semantic Scholar、OpenAlex、Crossref：主要负责发现和核验文献。
- Zotero：负责保存、组织和管理文献。
- Claude Code：负责分析、推理和整合。

可以通过 MCP 或相应 API 将这些能力连接起来。并不是所有服务都自带官方 Claude Code MCP Server，需要根据实际可用的 MCP 实现选择。

官方 MCP 配置入口：[Claude Code MCP Documentation](https://code.claude.com/docs/en/mcp?utm_source=chatgpt.com)。

### 我建议增加一个文献证据约束

在 `rules/citation.md` 中写入：

```
# Citation Rules

1. Never fabricate papers, authors, venues, or DOIs.
2. Every cited paper must have a verifiable source.
3. Distinguish between:
   - Verified facts
   - Author claims
   - Agent interpretations
   - Unverified hypotheses
4. Do not infer experimental results from abstracts.
5. When a paper cannot be accessed, explicitly
   report the limitation.
6. Every important research claim should be
   linked to supporting or contradicting papers.
7. Verify DOI and bibliographic metadata
   before including references.
```

这一点非常重要：科研 Agent 的质量不仅取决于它能找到多少论文，更取决于每个结论能否追溯到证据。

## 五、CLAUDE.md：建立长期科研认知体系

这是整个系统的基础配置。

我不建议将 CLAUDE.md 写成普通的角色提示词，例如：

"You are an excellent research assistant."

这种描述几乎没有约束力。

应该明确规定 Claude 如何开展科研。

下面是一份可以直接使用的初始版本。

```

# Research Assistant Configuration

## 1. Role

You are an AI research collaborator specializing in
machine learning, robotics, VLA, and embodied AI.

Your goal is not merely to answer questions, but to
help develop rigorous, novel, and feasible research.

## 2. Research Principles

- Evidence before speculation.
- Critical thinking before agreement.
- Novelty must be verified against existing work.
- Distinguish facts, hypotheses, and opinions.
- Never fabricate papers or experimental results.
- Explicitly report uncertainty.

## 3. Research Workflow

For every new research problem:

1. Understand the problem.
2. Identify existing research.
3. Analyze assumptions and limitations.
4. Compare alternative explanations.
5. Identify unresolved questions.
6. Formulate testable hypotheses.
7. Design feasible experiments.

Do not jump directly from an idea to a proposed method.

## 4. Literature Research

- Search across multiple research directions.
- Include foundational and recent work.
- Analyze papers comparatively.
- Track citation relationships.
- Verify important claims with original papers.

## 5. Research Planning

Every research proposal must contain:

- Problem Definition
- Motivation
- Research Questions
- Hypotheses
- Related Work
- Methodology
- Experimental Design
- Baselines
- Evaluation Metrics
- Risks and Limitations

## 6. Critical Thinking

Always challenge the researcher's assumptions.

When evaluating an idea:

- Identify possible prior work.
- Search for counterexamples.
- Consider simpler explanations.
- Evaluate whether the contribution
  is genuinely novel.
- Identify what evidence would falsify
  the hypothesis.

## 7. Interaction Style

- Do not automatically implement every idea.
- Explain reasoning and alternatives.
- Divide complex research tasks into stages.
- Present intermediate results.
- Wait for approval before major
  architectural or experimental changes.

## 8. Research Records

Maintain structured research records.

Every important decision should include:

- Decision
- Evidence
- Rationale
- Confidence
- Open Questions

```

### 一个额外建议：使用分层科研记忆

你之前提出过一个很有意思的观点：Memory 应该具有基本单元，并且可以通过分层结构组合。

我认为这个想法也可以应用到 Claude Code 的科研工作流。

不要把所有历史讨论都放在一个越来越长的 Markdown 文件中。

可以这样设计：

```
research/
│
├── 00_overview.md
│
├── 01_research_questions/
│   ├── confirmed.md
│   ├── hypotheses.md
│   └── unresolved.md
│
├── 02_literature/
│   ├── paper_database.csv
│   ├── literature_matrix.md
│   └── research_timeline.md
│
├── 03_knowledge/
│   ├── concepts/
│   ├── methods/
│   └── relationships/
│
├── 04_experiences/
│   ├── failed_approaches.md
│   └── experimental_observations.md
│
├── 05_project/
│   ├── research_plan.md
│   ├── milestones.md
│   └── decisions.md
│
└── 06_open_problems/
    └── research_gaps.md
```

其中：

- `overview`：整个研究的全局上下文。
- `research_questions`：问题及其确定程度。
- `literature`：外部文献证据。
- `knowledge`：已经提炼的可复用知识。
- `experiences`：实验经验，包括失败经验。
- `project`：项目执行状态。
- `open_problems`：尚未解决的问题。

这里需要特别区分：

论文中的结论不等于你自己的研究结论。

两者必须保留不同的 Provenance（来源），并记录各自的 Validity（有效条件）。

这也意味着，你提出的 Atomic Task 结构：

```
Atomic Task {
    Effect
    Validity
    Provenance
}
```

可以作为科研记忆管理中的一个基础设计方向。

当然，Claude Code 的 Auto Memory 并不自动提供这种完整的结构化知识管理能力，需要你通过文件结构、Skills 和相应的维护规则来实现。

## 六、Hooks：让科研工作流具有自动化能力

Hooks 不是科研推理工具，而是用于保证一些操作不会被遗忘。

我建议配置三个自动化机制：

| 触发时机         | 自动执行的任务                |
| ------------ | ---------------------- |
| SessionStart | 加载当前项目状态和未解决问题         |
| PostToolUse  | 检查重要文献记录是否缺少 DOI、来源等字段 |
| Stop         | 提醒更新研究进展和决策记录          |

例如，每次结束一个研究阶段时，自动检查：

```
[Research Session Check]

- Were new papers discovered?
- Were research hypotheses changed?
- Were important decisions made?
- Were new limitations identified?
- Does the project plan need updating?
- Are there unresolved questions?
```

注意：Hooks 应当用于确定性的检查，不应该让它自动修改研究假设或替你决定研究方向。

Hooks 可以执行 Shell 命令，必须谨慎审核其权限和脚本来源。

[image](https://www.google.com/s2/favicons?domain=https://claude.com\&sz=32)

Claude by Anthropic+1



## 七、Settings 中值得调整的选项

除了前面那些文件配置，Claude Code 自身也有一些值得调整的设置。

| 设置               | 建议                    |
| ---------------- | --------------------- |
| Model            | 复杂研究推理优先使用能力更强的模型     |
| Effort           | 对研究综合、研究规划使用较高推理投入    |
| Auto Memory      | 开启并定期整理研究记忆           |
| Permissions      | 文献和研究文件优先只读，修改重要计划前确认 |
| Extended Context | 在需要大量论文材料时考虑使用        |
| Output Style     | 使用适合研究讨论的自定义输出风格      |

建议熟悉这些命令：

```
/config
/memory
/agents
/skills
/hooks
/mcp
```

具体支持的选项取决于 Claude Code 版本。官方文档可以查看：

- [Settings](https://code.claude.com/docs/en/settings?utm_source=chatgpt.com)
- [Memory](https://code.claude.com/docs/en/memory?utm_source=chatgpt.com)
- [Subagents](https://code.claude.com/docs/en/sub-agents?utm_source=chatgpt.com)
- [Skills](https://code.claude.com/docs/en/skills?utm_source=chatgpt.com)

## 八、我认为最值得采用的最终科研工作流

前面讲的是组件，现在把它们组合起来。

我建议把科研工作划分成四个阶段：

1. Phase 1：Research Discovery

   发现问题
   - Literature Scout 搜索文献
   - Paper Analyst 阅读论文
   - Research Synthesizer 寻找研究空白
   输出：Research Landscape
2. Phase 2：Research Validation

   验证问题
   - Critical Reviewer 反驳研究假设
   - Literature Scout 补充反例
   - 主 Agent 判断问题是否值得研究
   输出：Validated Research Questions
3. Phase 3：Research Planning

   设计方案
   - Project Architect 设计技术路线
   - Paper Analyst 验证技术依据
   - Critical Reviewer 审查可行性
   输出：Research Proposal
4. Phase 4：Research Execution

   执行研究
   - 分解实验任务
   - 管理实验记录
   - 分析实验结果
   - 更新研究记忆
   - 根据新证据调整研究计划
   输出：持续更新的 Research Project

### 以你的 VLA Memory Conflict 研究为例

假设你向 Claude Code 提出：

> 我希望研究 VLA 中长期可复用记忆的冲突问题，目前还不确定问题定义和技术路线。

理想情况下，它不应该立即给你设计一个 Memory Module。

它应该先执行：

1. Literature Scout：调查 VLA、Robot Memory、Continual Learning、Experience Reuse。
2. Paper Analyst：提取不同方法的记忆表示、复用机制和限制。
3. Research Synthesizer：分析记忆冲突究竟来自 Context、Intention、Experience 还是 Reusable Knowledge。
4. Critical Reviewer：检查这个问题是否已经被 Memory Interference、Catastrophic Forgetting 等研究覆盖。
5. Project Architect：只有在研究问题得到充分论证后，才设计实验和技术路线。

最终得到的应该不是一个立即可以写代码的模块，而是一个经过文献和逻辑验证的研究问题。

## 九、实施优先级：不要一次性配置所有东西

如果由我来搭建，我会按照下面的顺序进行。

第一阶段：建立科研基础

最高优先级

- 编写科研版 `CLAUDE.md`
- 创建 Literature Scout
- 创建 Paper Analyst
- 创建 Research Synthesizer
- 建立论文分析模板\

  第二阶段：建立研究推理能力
- 创建 Critical Reviewer
- 创建 Project Architect
- 创建 `/research-gap`
- 创建 `/research-planning`\

  第三阶段：建立外部知识连接
- 接入 Zotero
- 接入 Semantic Scholar / OpenAlex
- 建立引用核验机制
- 建立结构化研究记忆\

  第四阶段：建立自动化
- 配置 Hooks
- 创建 `/weekly-research-review`
- 自动更新研究进展
- 建立项目状态追踪

## 十、一个更重要的建议：让 Claude Code 成为 Research Partner，而不是 Research Executor

我认为这里存在一个容易忽略的问题。

如果你让 Claude Code 自动搜索论文、总结论文、生成研究方案、编写代码，那么它最终可能只是一个效率更高的研究执行器。

但真正值得追求的是：

让它帮助你提升研究问题的发现能力、判断能力和抽象能力。

因此，我建议设置三个基本原则：

1. Human controls research direction：研究方向和重要假设由你决定。
2. Agent expands research space：Agent 负责探索你尚未考虑的理论、方法和研究方向。
3. Agent challenges human assumptions：Agent 必须主动寻找证据反驳你的想法。

尤其是第三点。

一个好的科研 Agent，不应该总是告诉你：

"Your idea is promising."

它更应该告诉你：

"Your idea is promising, but here are three reasons why it might be wrong."

这才是科研价值所在。

我的最终建议是：先实现 Chief Research Agent + 五个 Subagents + 四个 Skills + 结构化 Research Memory。这套架构比单纯增加 MCP 数量或调整模型参数更值得优先投入。

后续可以把整套配置整理成一个可直接放入 VS Code 项目中的 Claude Code Research Framework，包含完整的 Agent 定义、Skills、CLAUDE.md、Rules 和项目目录模板。
