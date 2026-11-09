---
name: research-planning
description: This skill should be used when the user asks to "design a research plan", "turn this idea into a project", "write a research proposal", "plan the experiments", "define baselines and metrics", "制定研究计划", "把这个想法变成研究方案", "写研究提案", "设计实验", "规划技术路线", or invokes "/research:research-planning". Converts a validated research question into a proposal that separates established facts, derived hypotheses, and unverified design choices.
argument-hint: [research-idea-or-question]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent
---

# Research Planning

Turn a research understanding into an executable plan without hiding uncertainty. The failure mode to prevent is a plan that looks complete because every gap was filled with an unverified assumption.

## Input

Read the research idea or question from `$ARGUMENTS`. If the input is a vague idea rather than a question, restate the most plausible research question and name the assumptions in that interpretation before planning.

## Preconditions

A plan is only as good as the problem it addresses. Before planning, check:

- `research/01_research_questions/` contains the research question and its status.
- `research/06_open_problems/research_gaps.md` contains at least one validated gap. A validated question without a gap record may proceed only as a provisional sketch.
- The closest existing work is named and distinguished.

If these are missing, run `literature-review` and `research-gap` first, or explicitly mark the plan as a provisional sketch.

## Required proposal structure

Write `research/05_project/research_plan.md`. The section names and fields in `templates/research/05_project/research_plan.md` are canonical. Do not drop a section; write "not yet determined" where it is genuinely open.

1. **Problem Definition** — the problem, the setting, and the scope boundary.
2. **Research Motivation** — why it matters and to whom.
3. **Research Questions** — one primary question, at most three secondary questions.
4. **Research Hypotheses** — each with a falsification condition.
5. **Related Work and Differentiator** — closest work and the precise mechanism-level difference.
6. **Theoretical Framework** — the mechanism the proposal assumes, stated explicitly.
7. **Proposed Method / Architecture** — components, interfaces, and data flow.
8. **Methodology** — how the hypothesis will be tested.
9. **Experimental Design** — conditions, controls, ablations, and confounders.
10. **Baselines** — strongest available methods, not straw men. Justify each baseline.
11. **Evaluation Metrics** — primary metric, secondary metrics, and what counts as success.
12. **Risks and Limitations** — technical, evidential, and resource risks. Place the feasibility table here.
13. **Milestones** — staged deliverables with verification criteria.

## Evidence labeling

Tag every nontrivial statement:

- `[fact]` — established in a cited paper, with bibkey and locator.
- `[claim]` — asserted by an author but not independently verified.
- `[inference]` — derived by reasoning; show the derivation.
- `[hypothesis]` — proposed and untested.
- `[design choice]` — a decision made for engineering convenience, not yet justified empirically.

A proposal whose method rests mostly on `[design choice]` is a sketch, not a validated plan. Say so.

## Feasibility table

For each phase, estimate:

| Phase | Technical difficulty | Required resources | Prerequisites | Failure risk | Verification criterion |
| --- | --- | --- | --- | --- | --- |

Difficulty and risk are `low|medium|high`. Required resources include compute, data, hardware, annotation, and expertise. A phase with no verification criterion is not a milestone. Write this table under section 12 of `research_plan.md`.

## Baselines and metrics discipline

- Name the strongest published baseline and the strongest simple baseline.
- Include an ablation for every component claimed as a contribution.
- Specify the evaluation split and whether it was used during development.
- State the metric's known weaknesses and any secondary metric that guards against gaming it.
- Pre-register the success threshold where possible. "Improves performance" is not a threshold.

## Risk analysis

For each major risk, write:

- the assumption the plan depends on;
- the early experiment that would test it cheaply;
- the fallback if the assumption fails;
- the decision point at which the plan is revised.

Prefer cheap falsification early. Do not schedule the decisive experiment last.

## Milestones

Write `research/05_project/milestones.md`:

| Milestone | Deliverable | Depends on | Verification | Target date | Status |
| --- | --- | --- | --- | --- | --- |

Each milestone must produce an artifact that can be checked by someone else. "Understand X" is not a deliverable; "a matrix of N papers with extracted assumptions" is.

## Review before delivery

Dispatch `research:critical-reviewer` on the draft with these questions:

- Does the experiment actually test the stated hypothesis?
- Is the closest prior work distinguished by mechanism, not wording?
- Which design choices are presented as facts?
- What is the simplest explanation for the expected result?
- What result would falsify the central claim?

Incorporate the review. Keep unresolved criticisms visible rather than smoothing them over.

## Failure modes

- **Unvalidated idea.** The question was never checked against prior work. Mark the plan provisional and route back to `research-gap`.
- **Missing baseline numbers.** Do not invent expected results or baseline performance. Write "not yet measured" and name the measurement.
- **Plan rests on `[design choice]`.** State that the plan is a sketch, not a validated proposal, and name the experiment that would justify the choice.
- **Unknown feasibility.** Compute, data, or hardware requirements are guesses. Mark them as estimates and identify the cheapest way to verify.
- **No falsification condition.** The hypothesis cannot fail, so the experiment cannot inform anything. Rewrite the hypothesis or drop it.
- **The decisive experiment is scheduled last.** Reorder so the cheapest test that can kill the project comes first.

## Output to the user

Return:

- the one-sentence research question;
- the central hypothesis and its falsification condition;
- the method in three sentences;
- the decisive experiment and its success threshold;
- the top three risks;
- the files written;
- what remains undecided and who must decide it.

The user owns the research direction. Present options and trade-offs; do not silently choose the direction.
