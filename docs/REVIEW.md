# Review: aligning the project with industry-level cancer genomics practice

This is what I found reviewing the original coursework folder and what I changed
to make it a credible portfolio repository. Items are grouped by whether they
were fixed here or are recommended next steps.

## Fixed in this repo

### Reproducibility (the biggest gap)
- **Hardcoded absolute paths** (`/Users/jay/Documents/Precision Medicine/...`)
  appeared in every notebook and would break on any other machine. One even
  pointed at a `/Midterm/` folder. All paths now resolve from the project root
  via the `here` package.
- **No project root / env definition.** Added an `.Rproj`, a `DESCRIPTION`
  listing dependencies, and install instructions in the README.
- **Flat, ambiguous structure.** Inputs, code, and outputs were interleaved
  inside `Step 1/`…`Step 4/` with duplicated copies. Reorganized into
  `R/` (functions), `analysis/` (numbered notebooks), `data/`, `results/`, `docs/`.

### Correctness bugs
- **Step 4 line-graph notebook referenced undefined variables**
  (`stage1relapseFreeMeans`, `stage1relapseMeans`) — it computed means named
  `relapseMeans`/`relapseFreeMeans` from *stage 2* data, then tried to `cbind`
  differently named *stage 1* objects. It would not run. Rewritten so the
  progression trajectory and the recurrence comparison both compute cleanly.
- **Wrong sample filtering.** `stage2[clinDataRelapse$GSMid, ]` indexed by row
  name, but the CIBERSORTx sample id lives in the `Mixture` column. Replaced
  with an explicit `%in%` match on `Mixture`.
- **Undefined `plot` object** passed to `ggsave()` at the end of the notebook.
  Removed; figures are now saved inside the plotting function.
- **A stray colorectal-cancer notebook** (`04-CibersortCorrPlot.Rmd`) referenced
  `CRC_PILOT_05...` files and a missing `funcCorr.R` — leftover template code
  from a different dataset. Excluded from the clean repo.

### Code quality
- `fnTTest` grew a matrix with `rbind()` inside the loop (quadratic); switched to
  pre-allocated rows + a single `do.call(rbind, ...)`, added `tryCatch` for
  zero-variance features, and documented it with roxygen-style comments.
- `functionEnrichment` reloaded and re-saved the whole workbook on every database
  iteration; now builds one workbook in memory and saves once.
- Deprecated `ggplot2::size=` for lines replaced with `linewidth=`.

### Repo hygiene
- Added `README.md`, `LICENSE` (MIT), `.gitignore`.
- Removed OS/editor cruft (`.DS_Store`), Office temp lock files (`~$*.docx`),
  and duplicate zip archives (`Step 2 2.zip`, per-step `.zip` bundles).
- Dropped redundant/regenerable binaries (Word, PDF, xlsx render outputs, 12 MB
  duplicate t-test dumps). Gzipped the 49 MB expression matrix to ~13 MB; R reads
  `.gz` transparently. Repo went from ~139 MB to ~18 MB.
- **Removed coursework identifiers** ("Group 4", "Team4", "Step N", "Midterm")
  from file names and titles.

### Data governance
- Added `data/raw/README.md` documenting provenance (GEO GSE13507, Kim et al.),
  platform, sample groups, and terms; stated explicitly that data is public,
  aggregate, de-identified, no PII/PHI.

## Recommended next steps (not done — your call)

1. **Swap t-tests for `limma`.** The single most impactful upgrade. Per-gene
   Welch t-tests ignore the shared variance structure that moderated models
   exploit; `limma` (microarray) or `DESeq2`/`edgeR` (counts) is the expected
   standard and would strengthen every downstream result. `fnTTest.R` is kept as
   the original so the change is a clean, reviewable diff.
2. **Filter CIBERSORTx output by fit p-value** (< 0.05) before averaging fractions.
3. **Make the immune trends inferential**, not just descriptive — e.g. a linear
   trend test across ordered stages with FDR control, rather than comparing group
   means by eye.
4. **Add a couple of committed figures** (volcano plot, immune trajectory PNG) to
   the README so the repo shows results at a glance.
5. **Optional CI**: a lightweight GitHub Action that runs `R CMD` / knits the
   notebooks against a tiny fixture, to prove reproducibility on every push.
