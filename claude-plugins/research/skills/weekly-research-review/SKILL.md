---
name: weekly-research-review
description: This skill should be used when the user asks for a "weekly research review", "end-of-week research update", "research progress check", "reconcile my research notes", "what changed in my research this week", "每周研究复盘", "研究周报", "本周研究总结", "复盘这周的研究", or invokes "/research:weekly-research-review". Reconciles the research memory with what actually happened and surfaces changes in questions, hypotheses, decisions, and open problems.
argument-hint: [week-or-date-range]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Weekly Research Review

Reconcile the structured research memory with the actual work. The goal is not a status report; it is to detect drift between what the project believes and what the evidence now supports.

## Preconditions

Read the date range or period from `$ARGUMENTS`; default to the current week.

If `research/` does not exist, offer to run the `research-init` skill first. Do not create memory files silently in an unrelated directory.

## Review procedure

Read the memory tree before writing anything:

1. `research/00_overview.md`
2. `research/01_research_questions/{confirmed,hypotheses,unresolved}.md`
3. `research/02_literature/paper_database.csv`, `search_strategy.md`, `literature_matrix.md`, `research_timeline.md`
4. `research/03_knowledge/` — concepts, methods, and relationships
5. `research/04_experiences/{failed_approaches,experimental_observations}.md`
6. `research/05_project/{research_plan,milestones,decisions}.md`
7. `research/06_open_problems/research_gaps.md`

Then answer these questions using the session history and the files:

### 1. Literature changes

- Which papers were newly read or fetched?
- Which existing rows changed status (`unread` → `reading` → `read`)?
- Which new papers contradict an existing belief?
- Are there high-relevance papers still missing from the matrix?

### 2. Question changes

- Which questions moved between `confirmed`, `hypotheses`, and `unresolved`?
- Which hypothesis gained or lost support? What evidence caused the change?
- Which question was abandoned, and why?

### 3. Decision changes

- What important decisions were made this period?
- For each: Decision, Evidence, Rationale, Confidence, Open Questions.
- Which earlier decision is now invalidated by new evidence?

### 4. Experience capture

- Which approaches failed? Record why and what was learned in `failed_approaches.md`.
- Which experimental observations are worth reusing? Record provenance and validity conditions.

### 5. Plan drift

- Does `research_plan.md` still address the current question?
- Are milestones still ordered by cheap falsification first?
- Which assumptions in the plan remain untested?

### 6. Open problems

- Which gaps were validated, rejected, or narrowed?
- What is the single most important unresolved question now?

## Write the review

Append a dated entry to `research/00_overview.md` under `## Review Log`:

```markdown
### YYYY-MM-DD — Weekly Review

- Papers added: <n>; papers read: <n>
- Questions changed: <list>
- Hypotheses changed: <list with direction>
- Decisions made: <list>
- Failures recorded: <list>
- Plan changes: <list>
- Most important open question: <one sentence>
- Next week's cheapest decisive test: <one sentence>
```

Update the affected files in place:

- `paper_database.csv` statuses;
- `01_research_questions/*`;
- `03_knowledge/` when a concept or method was refined this week;
- `04_experiences/*`;
- `05_project/decisions.md` and `milestones.md`;
- `06_open_problems/research_gaps.md` and its ranking table.

Do not rewrite history. Correct an earlier entry only by appending a dated correction that names what changed and why.

## Consistency checks

Before finishing, verify:

- Every `confirmed` question has cited evidence.
- Every hypothesis has a falsification condition.
- Every decision has Evidence, Rationale, Confidence, and Open Questions.
- Every failed approach has a lesson, not just a description.
- No paper was cited without a resolvable bibkey.
- `00_overview.md` "Current Status" matches the actual phase of work.
- Open questions are questions, not topics.
- Every knowledge entry under `03_knowledge/` records provenance and validity.
- The gap ranking table matches the statuses of the gap records.

## Failure modes

- **No session history.** Reconstruct the week from file timestamps and git history, and say that the review is file-based rather than session-based.
- **Missing `research/`.** Offer `research-init`; do not fabricate a memory tree.
- **User asks to "clean up".** Clarify that the memory is append-only. Archive superseded entries with a dated note instead of deleting them.
- **Conflicting files.** Report the conflict and ask which record is authoritative; do not silently overwrite either side.
- **Nothing changed.** Say so plainly. An empty review is a valid result.

## Output to the user

Return a compact review:

- **Moved** — what changed in questions, hypotheses, or decisions.
- **Contradicted** — evidence that challenges a current belief.
- **Stale** — records that no longer match reality.
- **Unresolved** — the top open questions, ranked.
- **Next** — the cheapest experiment or search that would reduce the most uncertainty.

Ask before rewriting any file whose change would alter the research direction. Routine status updates can proceed without asking.
