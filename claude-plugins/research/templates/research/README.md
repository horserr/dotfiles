# Research Memory

This directory is the project's structured research memory. It is maintained by the `research` Claude Code plugin.

## Layout

| Path | Contents |
| --- | --- |
| `00_overview.md` | Global context, current phase, review log |
| `01_research_questions/` | Confirmed questions, hypotheses, unresolved questions |
| `02_literature/` | Paper database, search strategy, comparison matrix, timeline, literature review |
| `03_knowledge/` | Reusable concepts, methods, and relationships |
| `04_experiences/` | Failed approaches and experimental observations |
| `05_project/` | Research plan, milestones, decision records |
| `06_open_problems/` | Validated and candidate research gaps |

## Rules

1. **Provenance is mandatory.** Every reusable conclusion records where it came from: paper bibkey plus locator, experiment id, or `inference`.
2. **Validity is mandatory.** Record the conditions under which a conclusion holds (task, embodiment, model family, dataset, assumption).
3. **Papers are not conclusions.** A result reported in a paper is not this project's own result. Keep them separate.
4. **Append, do not rewrite history.** Correct an earlier entry with a dated correction that names what changed and why.
5. **Failed approaches are knowledge.** Record why an approach failed and what was learned.
6. **No fabricated citations.** A paper without a resolvable bibkey is not evidence.
7. **One paper, one row.** Do not paste literature dumps into a single Markdown file.

## Status vocabulary

- Questions: `open | investigating | answered | abandoned`
- Hypotheses: `untested | testing | supported | refuted`
- Papers: `unread | reading | read`
- Gaps: `candidate | validated | rejected`
- Decisions: `proposed | accepted | superseded`

## Maintenance

Run `/research:weekly-research-review` at the end of each research week. The `SessionStart` hook injects the overview and open questions at the start of a session; the `Stop` hook reminds you to update records when work ends.
