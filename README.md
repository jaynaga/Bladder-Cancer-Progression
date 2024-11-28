# Transcriptomic & Immune Microenvironment Profiling of Bladder Cancer Progression

A reproducible precision-medicine pipeline in R that traces the molecular and
immune changes accompanying bladder cancer as it progresses from a pre-cancerous
field through non-muscle-invasive (stage 1) to muscle-invasive (stage 2) disease,
using a public cohort of 233 bladder tissue samples (GEO **GSE13507**).

The pipeline runs raw expression data in and biologically interpretable findings
out, across four stages: **differential expression → pathway enrichment → immune
deconvolution → trend visualization.**

## Key findings

- **Tumor onset (pre-cancer → stage 1)** is dominated by an **EMT / ECM-remodeling**
  signature — stromal/matrix genes (MFAP4, CFD, COL16A1, DCN, ACTG2) sharply
  downregulated; EMT is the top MSigDB Hallmark pathway.
- **Invasion (stage 1 → stage 2)** layers on a distinct **inflammatory program** —
  TNF-α signaling via NF-κB, Oncostatin M, and IL-1 regulation of the ECM.
- **Immune microenvironment** shifts from adaptive (B/CD8 T cells in normal tissue)
  toward innate/myeloid (neutrophil-dominated) infiltration in tumor, with
  regulatory T cells and activated dendritic cells rising early then easing in
  invasive disease.

See [`docs/writeup.md`](docs/writeup.md) for the full narrative and interpretation.

## Repository layout

```
bladder-cancer-progression/
├── R/                       # reusable, documented functions
│   ├── fnTTest.R                # per-probe Welch t-test + BH FDR
│   ├── functionEnrichment.R     # EnrichR across gene-set libraries
│   └── functionLineGraph.R      # immune-fraction line graphs
├── analysis/                # numbered, runnable notebooks (the pipeline)
│   ├── 01_differential_expression.Rmd
│   ├── 02_functional_enrichment.Rmd
│   ├── 03_immune_deconvolution.md    # CIBERSORTx (hosted) run notes
│   └── 04_trend_visualization.Rmd
├── data/
│   ├── raw/                 # GSE13507 expression matrix (gzipped) + clinical table
│   ├── cibersortx_inputs/   # per-group mixture files for CIBERSORTx
│   └── EnrichR-Databases-2023.txt
├── results/                 # analysis outputs (regenerable)
│   ├── differential_expression/
│   ├── enrichment/
│   └── deconvolution/
└── docs/                    # writeup + generated figures
```

## Reproducing the analysis

Requires R ≥ 4.1. Paths are resolved from the project root with the `here`
package, so open `bladder-cancer-progression.Rproj` (or set the working directory
to the repo root) and knit the notebooks in order.

```r
install.packages(c("here", "dplyr", "tidyr", "reshape2", "ggplot2",
                   "openxlsx", "enrichR"))

# then knit, in order:
#   analysis/01_differential_expression.Rmd
#   analysis/02_functional_enrichment.Rmd     (calls the live EnrichR API)
#   analysis/03_immune_deconvolution.md        (run CIBERSORTx on the hosted service)
#   analysis/04_trend_visualization.Rmd
```

Step 03 (CIBERSORTx) runs on the hosted Stanford service; its inputs and outputs
are committed so steps 01, 02, and 04 are fully reproducible from this repo.

## Data & ethics

All data is public, de-identified, and aggregate. The expression and clinical
data derive from GEO series **GSE13507** (Kim et al., *Mol Cancer* 2010). See
[`data/raw/README.md`](data/raw/README.md) for provenance and licensing. No PII
or PHI is present. This project is for research/educational demonstration and is
not a validated clinical tool.

## Known limitations & recommended upgrades

This began as a graduate coursework project; a few choices reflect that origin
and are worth flagging honestly for anyone evaluating it as portfolio work:

- **Statistical model.** Differential expression uses per-probe Welch t-tests.
  The field-standard for microarray/RNA-seq is an empirical-Bayes moderated model
  (`limma` for microarray, `DESeq2`/`edgeR` for counts), which borrows variance
  across genes and is markedly more robust at these sample sizes. `fnTTest.R` is
  kept as the original implementation; a `limma` port is the natural next step.
- **Deconvolution confidence.** CIBERSORTx returns a per-sample fit p-value;
  low-confidence samples (p ≥ 0.05) should be filtered before averaging.
- **Trend testing.** The progression trends are currently descriptive (group
  means); formal testing (e.g. linear trend / mixed models across stages, with
  multiplicity control) would make the immune claims inferential.

## License

Code released under the [MIT License](LICENSE). Data belongs to its original
authors and is redistributed under the terms noted in `data/raw/README.md`.
