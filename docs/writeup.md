# Transcriptomic and Immune Microenvironment Profiling of Bladder Cancer Progression

**A precision medicine case study in differential expression, pathway enrichment, and immune deconvolution**

## Overview

This project traces the molecular and immune changes that accompany bladder cancer as it moves from pre cancerous tissue through non muscle invasive (stage 1) to muscle invasive (stage 2) disease. Using a public gene expression cohort of 233 bladder tissue samples, I built a four stage analytical pipeline in R that identifies differentially expressed genes between disease stages, maps those genes to biological pathways, estimates the immune cell composition of each tumor sample, and tracks how that composition shifts across the progression trajectory. The goal was to demonstrate an end to end precision medicine workflow: raw expression data in, biologically interpretable, potentially actionable findings out.

## Clinical Motivation

Bladder cancer is typically staged as non muscle invasive or muscle invasive, and that single distinction drives very different treatment paths (intravesical therapy versus systemic chemotherapy or cystectomy). Roughly half of non muscle invasive tumors recur, and a meaningful subset progress to muscle invasive disease, yet the biology that separates a tumor that stays contained from one that invades is not fully resolved. Understanding the transcriptional and immune features that mark each transition is a step toward better recurrence and progression biomarkers, and toward identifying immune targets that could be exploited therapeutically.

## Dataset

The analysis uses a publicly available Illumina microarray gene expression dataset (consistent with GEO series GSE13507, Kim et al.) profiling 233 bladder tissue samples with matched clinical annotation, including tumor stage, recurrence, and progression status:

| Tissue group | n |
|---|---|
| Normal bladder mucosa | 10 |
| Bladder mucosa surrounding tumor (pre cancerous field) | 58 |
| Primary BC, superficial (stage 1, non muscle invasive) | 103 |
| Primary BC, invasive (stage 2, muscle invasive) | 62 |

Expression data covered roughly 43,000 annotated Illumina probes per sample. Clinical metadata included recurrence status (67 non recurrent versus 36 recurrent, among annotated stage 1 cases) and progression status (134 non progressors versus 31 progressors), which supported downstream stratified analyses.

## Analytical Pipeline

### Phase 1: Differential expression analysis

I wrote a custom R function (`fnTTest`) that runs a Welch two sample t test independently for every probe between two patient groups, computes a signed log2 fold change, and applies Benjamini-Hochberg FDR correction across all tests. This was run for two clinically meaningful comparisons:

- **Pre cancer versus stage 1**: bladder mucosa surrounding the tumor versus superficial primary tumor
- **Stage 1 versus stage 2**: superficial (non muscle invasive) versus invasive (muscle invasive) primary tumor

The pre cancer to stage 1 transition produced the strongest signal, with genes such as MFAP4, CFD, COL16A1, DCN, and ACTG2 sharply downregulated in tumor tissue (FDR values on the order of 1e-20 or smaller). These are stromal and extracellular matrix (ECM) associated genes, consistent with loss of normal connective tissue architecture as tumor tissue replaces it. The stage 1 to stage 2 comparison showed a more modest but still significant signal, led by genes including UNC5B, KRTAP5-2, and CRTAC1.

### Phase 2: Functional enrichment analysis

For each comparison, I took the 1,000 most significant differentially expressed genes and submitted them to EnrichR (via the `enrichR` R package) against roughly 30 curated gene set libraries, including KEGG, GO Biological Process, Reactome, WikiPathways, BioPlanet, and MSigDB Hallmark. Results were compiled into per comparison Excel workbooks with one sheet per database, so findings could be cross checked across independent pathway resources rather than relying on a single annotation source.

Two consistent, biologically coherent signals emerged:

- **Epithelial-to-mesenchymal transition (EMT)** was the single most enriched MSigDB Hallmark pathway in both the pre cancer to stage 1 transition and the stage 1 to stage 2 transition, alongside strong enrichment for TGF-beta regulation of the ECM (BioPlanet) and extracellular matrix organization (Reactome). This tracks with the DEG findings above and reinforces that early tumor establishment is marked by structural and matrix remodeling.
- **Inflammatory and TNF driven signaling** became more prominent specifically in the transition to invasive disease: TNF-alpha signaling via NF-kB was the second ranked Hallmark pathway in the stage 1 to stage 2 comparison, and BioPlanet flagged Oncostatin M signaling and interleukin-1 regulation of the ECM as top hits. This suggests that the shift toward muscle invasion is associated with a distinct inflammatory signaling program layered on top of ongoing matrix remodeling, not simply "more of the same" biology from earlier stages.

### Phase 3: Immune cell deconvolution

To characterize the tumor immune microenvironment directly from bulk expression data, I ran CIBERSORTx against the LM22 signature matrix (22 immune cell subsets), with quantile normalization disabled per CIBERSORTx guidance for microarray data. Deconvolution was run separately for the pre cancer, stage 1, and stage 2 groups, and again stratified by recurrence status within stage 1 and stage 2, to test whether immune composition tracked with clinical outcome as well as with stage.

A simple comparison of average immune fractions in normal versus tumor tissue was striking on its own: normal bladder mucosa was dominated by naive and memory B cells (24% and 16% of immune content, respectively) and CD8 T cells (11%), while tumor tissue was dominated by neutrophils (54%) and eosinophils (16%), with adaptive lymphocyte fractions comparatively minor. This is consistent with a tumor microenvironment that has shifted from adaptive immune surveillance toward innate, myeloid driven infiltration, a pattern often associated with immune evasion.

Looking at the full pre cancer, stage 1, stage 2 trajectory (average CIBERSORTx fractions computed across each group):

- **Regulatory T cells (Tregs)** rose from about 7.5% of immune content in pre cancerous tissue to 13.5% in stage 1, then declined to roughly 9% in stage 2.
- **Activated dendritic cells** rose sharply from about 5% in pre cancerous tissue to roughly 13% in both stage 1 and stage 2, and stayed elevated.
- **M2 macrophages**, generally considered pro tumor and immunosuppressive, declined steadily across the trajectory, from about 12% (pre cancer) to 10% (stage 1) to 9% (stage 2).

Together these patterns suggest that the earliest steps of malignant transformation coincide with an immunosuppressive shift (rising Tregs and activated dendritic cells), while fully invasive disease presents a somewhat more immune quiescent, less lymphocyte rich microenvironment, a distinction with potential relevance for immunotherapy timing and patient selection.

### Phase 4: Longitudinal visualization

The 22 cell type fractions from each CIBERSORTx run were reshaped and plotted with `ggplot2` as line graphs tracking each immune subset across the progression axis (and separately across recurrence status), making the trends described above visually inspectable rather than buried in a results table. This plotting step was built as a reusable function (`functionLineGraph`) that outputs publication ready PNG, TIFF, and PDF versions of each figure.

## Technical Skills Demonstrated

- **R programming**: `dplyr`, `tidyr`, `reshape2`, `plyr`, `ggplot2`, `openxlsx`, custom function authorship and modular script design
- **Statistical methods**: per gene Welch t tests at genome scale, multiple testing correction (Benjamini-Hochberg FDR), signed fold change calculation
- **Bioinformatics tools**: EnrichR API integration across dozens of gene set libraries, CIBERSORTx immune deconvolution with a defined signature matrix
- **Reproducible research practice**: RMarkdown notebooks with embedded code, narrative, and output for every analytical phase, structured project organization separating inputs, code, and outputs at each step
- **Data wrangling at scale**: aligning a ~43,000 probe by 233 sample expression matrix against clinical metadata, filtering and reshaping deconvolution outputs for visualization

## Why This Matters

This project is a compact demonstration of how a single public dataset can be pushed through a genuine precision medicine workflow: from raw expression values to a testable biological hypothesis about immune evasion during bladder cancer progression. The specific findings, an EMT and ECM remodeling signature at tumor onset, a shift toward TNF and inflammatory signaling at the point of invasion, and a corresponding rise and fall in immunosuppressive Treg and dendritic cell populations, are the kind of multi layered evidence (transcriptomic plus immune composition) that translational and computational oncology teams use to prioritize biomarkers and therapeutic targets for further validation.

## Project Structure

The full analysis is organized into four sequential phases, each with its own inputs, R/RMarkdown code, and outputs:

1. **Differential expression** (t tests, FDR correction, DEG tables for both stage comparisons)
2. **Functional enrichment** (EnrichR results across ~30 databases per comparison)
3. **Immune deconvolution** (CIBERSORTx results per tissue group and per recurrence status)
4. **Trend visualization** (line graphs of immune cell fractions across progression and outcome)
