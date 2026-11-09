---
name: research-gap
description: This skill should be used when the user asks to "find research gaps", "identify an open problem", "is there a gap here", "what is missing in the literature", "find a novel angle", "找研究空白", "这个方向还有什么没解决", "有什么可做的创新点", "帮我找一个研究问题", or invokes "/research:research-gap". Runs assumption → limitation → cross-paper comparison → unresolved-problem reasoning and requires each candidate gap to include supporting and contradicting evidence.
argument-hint: [research-direction-or-question]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch, Agent
---

# Research Gap

Find research gaps by reasoning from evidence, not by listing things that sound unexplored. A gap is a claim: *existing work does not solve problem P under condition C, and this matters because E.*

## Input

Read the research direction or question from `$ARGUMENTS`. If the input is only a keyword or a paper title, infer the likely research question, state the interpretation explicitly, and confirm the scope before running the pipeline.

## Preconditions

Before identifying gaps, confirm that `research/02_literature/literature_matrix.md` exists and covers the direction. If it does not, run the `literature-review` skill first. Do not invent gaps from a handful of abstracts.

## Reasoning pipeline

Execute in order. Do not skip to "candidate gaps".

### 1. Restate existing research

For each high-relevance paper, state:

- the problem it actually solves;
- the mechanism it uses;
- the evaluation setting;
- the conditions under which its claim holds.

### 2. Identify assumptions

Extract two kinds:

- **Explicit assumptions** — stated by the authors, usually in Method or Limitations.
- **Hidden assumptions** — required for the method to work but not stated: data availability, task distribution, embodiment, label quality, context length, stationarity, cost budget, or human supervision.

A hidden assumption is a gap candidate when a realistic setting violates it.

### 3. Identify limitations

Separate:

- limitations the authors admit;
- limitations visible from the results but not admitted;
- limitations inherited from the evaluation design (for example one benchmark, one embodiment, one task family).

### 4. Cross-paper comparison

Answer these questions with paper pairings:

1. Which papers solve the same problem with different methods?
2. Which papers use the same method on different problems?
3. Where do two papers' findings or assumptions conflict?
4. Which claimed capability is evaluated only under conditions that trivially satisfy the assumption?
5. Which technical components could be combined but never have been?

### 5. Derive unresolved problems

Convert assumptions and limitations into problem statements. An unresolved problem must be phrased so that it could be answered by evidence:

- Bad: "memory in VLA is not well studied."
- Good: "no located method specifies when a retrieved memory should be treated as invalid after the task distribution shifts."

### 6. Validate each candidate gap

For every candidate, perform a deliberate disconfirmation search:

- Has this exact problem been solved under another name?
- Is the gap already covered by a survey, benchmark, or negative result?
- Is it a real problem or an artifact of the evaluation?
- Would solving it change a downstream outcome anyone cares about?
- Is the proposed contribution distinguishable from the closest existing work?

Record the search terms and what was found. If the gap dissolves, say so and drop it.

Dispatch `research:literature-scout` with the disconfirmation queries. For the top 1-3 candidates, dispatch `research:critical-reviewer` to attack the gap. Treat subagent output as `claim` until verified against a source, and record the queries and results in the gap record.

## Required gap record

Append each surviving candidate to `research/06_open_problems/research_gaps.md`:

```markdown
## GAP-<N>: <short title>

- Status: candidate | validated | rejected
- Gap description: <problem P under condition C>
- Why it matters: <downstream consequence E>
- Supporting papers: <bibkey (locator) — what it establishes>
- Contradicting papers: <bibkey (locator) — how it challenges the gap, or "none found; searched ...">
- Why existing methods fail: <mechanism-level explanation>
- Closest existing work: <bibkey> — <why this gap is not already covered>
- Potential contribution: <what a solution would enable>
- Feasibility: high | medium | low — <required resources and skills>
- Validation evidence: <searches run, benchmarks examined, people consulted>
- Confidence: high | medium | low
- What would falsify this gap: <observation that would show the problem is already solved or irrelevant>
- Date: YYYY-MM-DD
```

`Contradicting papers` is mandatory. If the search finds none, state the searches run. A gap record without a disconfirmation attempt is not a gap record.

## Ranking

Insert new gap records above the template's `## Ranking` section, then update that table in `research/06_open_problems/research_gaps.md`.

Rank validated gaps by:

1. **Magnitude** — how much a solution changes downstream capability.
2. **Distinctness** — how clearly it differs from the nearest existing work.
3. **Feasibility** — can this project actually test it.
4. **Evidence strength** — how well the gap is supported and disconfirmed.

Do not rank by how novel the wording sounds.

## Output to the user

Return:

- the number of candidates considered and the number that survived;
- the top 3 gaps, each in two sentences: the gap and why existing work does not cover it;
- for each, the strongest reason it might be wrong;
- the file path where full records were written;
- the searches that would most change the ranking.

## Failure modes

- **Gap by vocabulary.** The "new" term names an old problem. Compare mechanisms, not labels.
- **Gap by absence of search.** "No paper does X" without a documented search is not evidence.
- **Gap by ignoring contradictions.** Only supporting papers were collected. Re-run the disconfirmation step.
- **Gap too broad to test.** Narrow the condition C until an experiment could distinguish solved from unsolved.
- **Gap that is an engineering inconvenience.** A missing implementation is not a research gap unless it reveals a general limitation.
