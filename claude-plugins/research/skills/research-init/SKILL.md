---
name: research-init
description: This skill should be used when the user asks to "set up research memory", "initialize the research directory", "create the research folder structure", "scaffold a research workspace", "初始化研究目录", "创建研究记忆目录", "建立研究记忆（目录）", or invokes "/research:research-init". Creates the layered research/ directory from the plugin's templates without overwriting existing notes. For defining a new project's research question, use research-planning instead.
argument-hint: [target-directory]
allowed-tools: Read, Write, Bash, Glob
---

# Research Init

Create the layered research memory described by the `research-standards` skill. The operation is additive: never overwrite an existing note.

## Steps

### 1. Resolve the target

Use the directory in `$ARGUMENTS` if provided. Otherwise use `research/` under the current project root. Confirm the resolved absolute path in the reply.

If the target already contains files, inspect them first with `Glob` or `ls`. Do not delete or reinitialize a directory that already holds research notes. Create only missing files.

### 2. Copy the template tree

Run the template copy. It skips any file that already exists and reports each action:

```bash
target="${TARGET_DIR:-research}"
src="${CLAUDE_PLUGIN_ROOT}/templates/research"

if [ ! -d "$src" ]; then
  echo "ERROR: templates not found at $src" >&2
  exit 1
fi

mkdir -p "$target"
target="$(cd "$target" && pwd)"
cd "$src" || exit 1

find . -type f | while IFS= read -r f; do
  rel="${f#./}"
  dest="$target/$rel"
  if [ -e "$dest" ]; then
    echo "skip   $rel"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$f" "$dest"
    echo "create $rel"
  fi
done
```

Set `TARGET_DIR` explicitly in the command when the user chose a custom path, for example `TARGET_DIR="docs/research"`.

### 3. Verify

After copying, list the resulting tree and confirm that these exist:

- `00_overview.md`
- `01_research_questions/{confirmed,hypotheses,unresolved}.md`
- `02_literature/{paper_database.csv,search_strategy.md,literature_matrix.md,research_timeline.md,literature_review.md}`
- `03_knowledge/{concepts,methods,relationships}/`
- `04_experiences/{failed_approaches,experimental_observations}.md`
- `05_project/{research_plan,milestones,decisions}.md`
- `06_open_problems/research_gaps.md`
- `README.md`

### 4. Seed the overview

Ask the user for, or infer from the conversation:

- the research direction in one paragraph;
- the core question;
- the current phase: `discovery`, `validation`, `planning`, or `execution`.

Write these into `00_overview.md` only if the file is newly created. If the file already existed, append the new information under a dated entry instead of replacing it.

### 5. Report

Return:

- the absolute target path;
- files created versus skipped;
- the next recommended skill (`literature-review` for a new direction, `research-gap` if literature already exists, `research-planning` if a validated gap exists);
- a reminder that memory files should be committed alongside the code they describe.

## Failure modes

- **Target is inside a plugin install directory.** Refuse and ask for a project path.
- **Template files are missing.** Report the resolved `${CLAUDE_PLUGIN_ROOT}` and stop; do not hand-write a partial tree.
- **Existing directory with unrelated content.** Do not merge into it without explicit confirmation.
