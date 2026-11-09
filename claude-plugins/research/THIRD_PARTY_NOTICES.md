# Third-party notices

## paper-reader

The `skills/paper-reader/` directory is adapted from
[Mapika/paper-reader](https://github.com/Mapika/paper-reader), licensed under
the MIT License.

Files adapted:

- `skills/paper-reader/scripts/fetch_paper.py`
- `skills/paper-reader/scripts/extract_pages.py`
- `skills/paper-reader/references/citation-discipline.md`
- `skills/paper-reader/references/sources.md`
- the workflow and citation discipline in `skills/paper-reader/SKILL.md`

Changes: script paths now resolve through `${CLAUDE_PLUGIN_ROOT}` so the
skill is self-contained inside this plugin; the workflow additionally records
papers into this plugin's research memory when a `research/` directory exists.

MIT License

Copyright (c) Mapika

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
