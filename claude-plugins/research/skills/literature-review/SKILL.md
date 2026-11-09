---
name: literature-review
description: This skill should be used when the user asks to "do a literature review", "survey the literature", "find related work", "map the research landscape", "systematic review", "文献综述", "调研相关文献", "做一次系统性文献调研", "找相关工作", "梳理研究脉络", or invokes "/research:literature-review". Runs a multi-direction literature search, grades relevance, reads the important papers with paper-reader, and writes a comparison matrix, timeline, and evidence-backed review into the research memory.
argument-hint: [research-question-or-topic]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch, Agent
---

# Literature Review

Produce a literature landscape that another researcher can audit: every paper real and resolvable, every comparative claim traceable, every gap candidate paired with contradicting evidence.

## Input

Accept a research question, topic, or draft idea from `$ARGUMENTS`. If the input is narrower than a question (for example a single keyword), infer the likely research question and state the interpretation before searching.

## Preconditions

The literature artifacts belong in the research memory. If `research/02_literature/` does not exist, run the `research-init` skill first, or ask the user where the memory should live. Do not scatter output across ad-hoc directories.

## Workflow

### 1. Frame the question

Write a short framing block before searching:

- Research question in one sentence.
- Unit of analysis (task, model, dataset, mechanism, application).
- What counts as "directly related" versus "adjacent".
- Time window and venue scope. Default: foundational work plus the last three years.

Do not proceed with a single keyword string. A single string inherits one community's terminology and misses the rest.

### 2. Build a multi-direction search strategy

Generate at least six directions, with synonyms per direction. Cover:

- the user's own terminology;
- terminology used by adjacent communities;
- the mechanism-level name (for example "memory interference" rather than "memory conflict");
- the evaluation-level name (benchmark, metric, failure mode);
- foundational work;
- recent representative work.

Example for a VLA long-term memory project:

| Direction | Example queries |
| --- | --- |
| Core | VLA memory, vision-language-action memory |
| Embodied memory | long-term memory embodied agents, robot memory retrieval |
| Experience reuse | experience reuse manipulation, skill reuse robot |
| Continual learning | continual learning VLA, catastrophic forgetting robotics |
| Interference | memory interference, retrieval interference, context mismatch |
| Composition | task decomposition, skill composition, hierarchical policies |

Write the strategy to `research/02_literature/search_strategy.md`, including the databases searched (arXiv, OpenAlex, Semantic Scholar, DBLP, ACL Anthology) and the date.

### 3. Dispatch scouts in parallel

Use the `Agent` tool with `subagent_type: research:literature-scout`, one agent per 2-3 directions. Give each agent:

- the direction and query variants;
- the inclusion/exclusion criteria;
- the required return format: `title | authors | year | venue | identifier (arXiv/DOI/URL) | why relevant | direct-or-adjacent`;
- an instruction to return **only resolvable** items and to mark uncertain venue metadata.

Run the scouts concurrently. Do not serialize independent directions.

### 4. Verify and deduplicate

Treat scout output as `claim` until verified. For every candidate:

1. Deduplicate by title and identifier.
2. Reject items with no resolvable identifier or URL.
3. Verify metadata against a bibliographic API — query OpenAlex (`https://api.openalex.org/works/doi:...` or the title search) or Crossref (`https://api.crossref.org/works/<doi>`) with `WebFetch`. `paper-reader` has no metadata-only mode; use it only to fetch artifacts in step 5.
4. Grade relevance: `high` (solves the same problem), `medium` (same mechanism or evaluation), `low` (background or analogy).

Never keep a paper solely because a scout asserted it exists. If it cannot be resolved, drop it and record the failure in `search_strategy.md`.

### 5. Fetch and read the high-relevance papers

For each `high` paper, invoke the `paper-reader` skill to fetch the PDF and real BibTeX. That fetches artifacts only; do not also read and summarize the paper yourself.

Then dispatch `research:paper-analyst` with the local paper path and the analysis template from that agent's definition. The analyst reads the paper and returns its structured analysis; the main agent writes the result into `literature_matrix.md` and `03_knowledge/`. Do not duplicate the reading step.

### 6. Build the artifacts

Write these files under `research/02_literature/`:

**`paper_database.csv`** — one row per paper:

```csv
bibkey,title,authors,year,venue,doi,arxiv_id,url,local_path,relevance,status,notes
```

**`literature_matrix.md`** — one row per high/medium paper:

| bibkey | Problem | Motivation | Assumption | Method | Representation | Evaluation | Limitation | Hidden assumptions | Unresolved questions | Reusability |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

Every cell that states a paper's position carries a locator, for example `(Dao et al. 2022, §3, p.5)`.

**`research_timeline.md`** — chronological development:

| Year | Work (bibkey) | Venue | Contribution | Relation to this project |
| --- | --- | --- | --- | --- |

**`literature_review.md`** — the synthesis, with these sections:

1. **Landscape** — how the problem has been framed across communities.
2. **Clusters** — groups of papers actually solving the same problem, with the differentiator named.
3. **Method comparison** — what differs, not just what exists.
4. **Contradictions** — papers whose findings or assumptions conflict, with locators for both sides.
5. **Unresolved problems** — what no located paper addresses, plus the evidence that it is genuinely open.
6. **Coverage and limits** — databases searched, date, languages, and what was inaccessible.

### 7. Extract reusable knowledge

For every reusable concept, method, or relationship the review turned up, write a file under `research/03_knowledge/{concepts,methods,relationships}/` using the entry template in `templates/research/03_knowledge/README.md`. Each entry records provenance (bibkey plus locator) and validity (the conditions under which it holds). Do not copy the same content into both the matrix and the knowledge entry; the matrix compares papers, the knowledge entry records a reusable unit.

### 8. Verification pass

Before returning, check:

- Every bibkey in the review exists in `paper_database.csv` and has a real source.
- Every numerical or comparative claim has a locator.
- The contradictions section contains at least one entry, or explicitly states that no contradiction was found after searching.
- No paper is cited from memory.
- The review distinguishes `fact`, `claim`, `inference`, and `hypothesis` where the distinction matters.

## Output to the user

Report:

- the number of candidates found, verified, and read;
- the 3-5 clusters that structure the field;
- the strongest unresolved problems with their evidence;
- the files written;
- what was inaccessible or uncertain.

Do not present the review as settled. Name the searches that would most change the conclusion.

## Failure modes

- **Search produces only one community's vocabulary.** Add adjacent-field directions and re-run.
- **Scouts return plausible but unverifiable papers.** Drop them; never repair a citation by guessing a DOI.
- **Papers cannot be accessed.** Record the limitation explicitly and analyze only what was actually read.
- **The review becomes an annotated bibliography.** Force cross-paper comparison and contradiction analysis before writing prose.
