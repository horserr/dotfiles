---
name: paper-reader
description: This skill should be used whenever the user wants to read, summarize, discuss, cite, pull, or fetch a specific research paper, including any arXiv / OpenReview / ACL Anthology link, DOI, PDF URL, paper title, or phrases such as "read this paper", "pull this paper", "summarize this paper", "what does X say", "cite X", "find the bibtex", "读这篇论文", "下载这篇论文", "总结这篇论文", "这篇论文说了什么", "引用这篇论文". Fetches the PDF and arXiv tex source when available, resolves a real BibTeX entry from open sources (never fabricated), and enforces inline per-claim locators. For topic-level discovery, use literature-review instead; for a structured matrix row, use research:paper-analyst.
argument-hint: [paper-url-or-identifier]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent, WebFetch
---

# Paper Reader

Read research papers carefully and cite them honestly.

The job has two halves. First, fetch and structure the artifacts so the paper is available locally with a real bib entry. Second, discuss the paper with strict locator discipline so every claim is traceable and no citation is ever invented.

## Core invariants

These rules justify the skill existing. Apply them on every turn:

1. **Never fabricate a citation.** If `citation.bib` could not be fetched from an authoritative source, say so explicitly. Do not synthesize a BibTeX entry from training memory. A missing bib is a known state; a hallucinated bib is silent corruption that propagates into the user's own writing.
2. **Every claim about a paper gets an inline locator.** Format: `(FirstAuthor et al. Year, §<section>, p.<page>)`, or `(ibid., §..., p....)` for adjacent claims about the same paper. Read the section heading and page number off the actual PDF. Do not infer them.
3. **Quote when paraphrasing risks distortion.** Use `"…"` for direct quotes, with the same locator.
4. **Results live in tables and figures.** When stating numbers, cite the table or figure: `(…, Table 3, p.8)` or `(…, Fig. 4, p.7)`. Do not round or restate numbers without checking the source.
5. **No tex source is not no paper.** Tex source is a bonus that enables exact wording, equation, and macro searches. Absence is not a blocker. PDF plus bib is the floor.

## Workflow

### 1. Resolve the input to a canonical identifier

Resolve whatever the user gave to a *source kind* plus *id*:

- `arxiv.org/abs/<id>` or `arxiv.org/pdf/<id>`: kind=`arxiv`, id=`<id>` (strip `v<N>` only if the user clearly wants the latest version; preserve it otherwise).
- `openreview.net/forum?id=<id>` or `pdf?id=<id>`: kind=`openreview`, id=`<id>`.
- `aclanthology.org/<paperid>`: kind=`acl`, id=`<paperid>`.
- A DOI (`10.xxxx/...` or `doi.org/...`): kind=`doi`, id=`<doi>`.
- A non-arXiv PDF URL: kind=`pdf`, id=`<url>`.
- Just a title: kind=`title`, id=`<title>`; the fetcher resolves it through Semantic Scholar.

### 2. Fetch the artifacts

Run the bundled fetcher. It handles source-specific downloads, the bib lookup chain, slug computation, and directory layout. Keep this single source of truth:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/paper-reader/scripts/fetch_paper.py" <input>
```

On Windows, use `python` instead of `python3`. Both scripts are standard-library only.

The script:

- Picks a slug `<firstauthor_lastname><year>-<first-significant-title-words>` and creates `~/papers/<slug>/`.
- Downloads `paper.pdf`.
- For arXiv, also downloads `https://arxiv.org/e-print/<id>` and extracts it into `source/`.
- Resolves BibTeX through: OpenAlex → publisher native (ACL `.bib`, Crossref by DOI) → DBLP → Semantic Scholar → arXiv-API-constructed (arXiv inputs only). If every source fails, writes `citation.MISSING` with the full lookup trail instead of inventing an entry.
- For DOI and title inputs without a deterministic PDF URL, tries Unpaywall and the OpenAlex `best_oa_location.pdf_url` field.
- Writes `meta.json` with title, authors, year, venue, arXiv id, DOI, URL, slug, bibkey, and `bib_trail`.

Read `meta.json` for the bibkey before citing. If fetching fails (paywall, dead URL, no network), report what failed and ask how to proceed. Do not guess metadata.

### 3. Read the PDF

Reading a PDF directly with the `Read` tool can fail depending on the host's PDF text-extraction support (for example, a machine without poppler). The bundled extractor is the reliable primary path:

```bash
mkdir -p ~/papers/<slug>/extract
uvx --with pypdf python "${CLAUDE_PLUGIN_ROOT}/skills/paper-reader/scripts/extract_pages.py" \
    ~/papers/<slug>/paper.pdf --pages 1-10 --out ~/papers/<slug>/extract/p1-10.txt
```

The output is page-marked plain text (`===== PAGE N =====` separators), which is exactly what is needed for `p.N` locators. The script prints the resolved output path; read that file with the `Read` tool. For long papers, extract 10-15 pages per call. Use `Read` on the PDF directly when the host supports it and rendered visuals (figures, equations) matter.

For exact wording, equations, or macro values, grep the tex source:

```bash
grep -rn "self-attention" ~/papers/<slug>/source/
```

### 3a. Fast path: delegate the read to Haiku

Reading a 20-page paper end to end on a large model is expensive. For the standard fetch + summarize + cite workflow, delegate the read to Haiku and use its structured claim index to compose the reply.

**Path A:** When the `Agent` tool is available, call it with `subagent_type=general-purpose, model=haiku` and the prompt below.

**Path B:** Inside subagents or headless contexts, invoke the CLI:

```bash
claude -p --model haiku <<'EOF'
<the same prompt>
EOF
```

**The prompt:**

```
You are a paper-reader subagent. The paper is fully fetched at <paper_dir>.
- meta.json: <paste it>
- citation.bib: <paste it or note bibkey>
- PDF: <paper_dir>/paper.pdf (use extract_pages.py; Read may fail on PDFs here)
- tex source: <paper_dir>/source/ (grep for exact wording, equation defs, table data)

Produce a single JSON object:

{
  "bibkey": "<from citation.bib>",
  "sections": [{"num": "3.2", "title": "...", "pages": [5, 6]}],
  "tables": [{"num": "2", "caption": "...", "page": 8, "key_numbers": [{"name": "EN-DE BLEU", "value": "28.4", "model": "Transformer (big)"}]}],
  "figures": [{"num": "1", "caption": "...", "page": 3}],
  "claims": [
    {"claim": "Self-attention is O(n²·d) per layer", "section": "3.2.2", "page": 6, "kind": "complexity"},
    {"claim": "Transformer outperforms ConvS2S by 2.0 BLEU on EN-DE", "table": "2", "page": 8, "kind": "result"}
  ],
  "tldr": "<one paragraph, each sentence ending with the locator that backs it>"
}

No commentary, no markdown, just the JSON. Every claim must have a locator (section or table/figure plus page). Drop claims you cannot locate.
```

Do **not** use this fast path when the user wants verbatim passages, figure interpretation requiring vision, or only one specific section of a short paper.

### 4. Produce `notes.md`

After the first careful read, generate `~/papers/<slug>/notes.md`:

```markdown
# <Paper Title>

<bibkey> · <Author list> · <Venue Year> · [arXiv:<id>](https://arxiv.org/abs/<id>) / [doi:<doi>](...)

## TL;DR
One paragraph, max 4 sentences, every factual claim cited.

## Problem
What problem the paper addresses and why prior work was insufficient. Cite §1, §2.

## Method
Core idea plus moving parts. Cite §3 and relevant subsections. Quote definitions when they matter.

## Key results
- One result per bullet, each cited (Author Year, Table/Fig N, p.M).
- … (…, Table 2, p.8)

## Limitations
What the paper itself flags (Limitations / Discussion). Mark anything you add as "[reader note]".

## Open questions / follow-ups
Free-form. Things to ask, verify, or read next.
```

### 5. Record into research memory when present

If the project has a `research/` directory, also update
`research/02_literature/paper_database.csv`. The canonical header lives in
`templates/research/02_literature/paper_database.csv`:

```csv
bibkey,title,authors,year,venue,doi,arxiv_id,url,local_path,relevance,status,notes
```

Append one row per paper, or update the existing row with the same bibkey.
`relevance` is `high|medium|low`; `status` is `unread|reading|read`. Never
invent missing fields; leave them empty and note what is missing in `notes`.
Update `research/02_literature/literature_matrix.md` only for dimensions this
skill actually analyzed; otherwise leave the matrix to `research:paper-analyst`.
Do not duplicate papers.

### 6. Discussing the paper later

Once `notes.md` exists, re-reading the whole PDF is unnecessary. Any specific claim, number, or quotation must still cite its actual source location (§ and page, or table/figure number). Do not lift a number from `notes.md` without the locator attached to it.

When comparing multiple papers, repeat the workflow for each. Each gets its own `~/papers/<slug>/` and its own bibkey.

## When things go wrong

- **Bib lookup failed everywhere.** Do not fabricate. The script writes `citation.MISSING`. Cite as `(Author Year [bib unresolved])` and tell the user. For arXiv inputs the fetcher may construct an `@misc{…, archivePrefix={arXiv}}` entry from the arXiv API; that is logged as `arXiv API (constructed): OK` in `bib_trail`. It is authoritative for the preprint but contains no venue or DOI. Surface that distinction when the user writes for a venue.
- **arXiv tex source missing or encrypted.** Note it and proceed with the PDF only.
- **Locator unknown.** Use `(Author Year, §unknown, p.<N>)` with at least the page, or omit the claim. Never round a page number "close enough".
- **PDF is scanned / no text layer.** Page locators still work; grep and tex search will not. Tell the user.
- **User asks to cite something not fetched.** Pull the paper first. Do not cite from training memory.

## Additional Resources

- **`references/citation-discipline.md`** — strict locator format, worked examples, common failure modes, `ibid.` and multi-paper conventions.
- **`references/sources.md`** — per-source fetch URLs, bib lookup chains, and gotchas.
