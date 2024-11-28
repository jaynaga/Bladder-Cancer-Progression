# Data provenance

## Source

Gene expression and clinical annotation derive from NCBI GEO series
**GSE13507**:

> Kim WJ, Kim EJ, Kim SK, et al. *Predictive value of progression-related gene
> classifier in primary non-muscle invasive bladder cancer.* Molecular Cancer,
> 2010;9:3. GEO: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE13507

Platform: Illumina human-6 v2.0 expression beadchip (microarray).

## Files

| File | Description |
|---|---|
| `BC_GeneExpData_withAnno_233.tsv.gz` | ~43k annotated Illumina probes × 233 samples. Feature ids are `ILMN_xxxxxxx\|SYMBOL`. Gzipped (~13 MB; ~49 MB uncompressed). R reads it via `gzfile()` / `read.delim()` transparently. |
| `BC_ClinData_233rows.csv` | Clinical metadata for the 233 samples: tissue group (`PrimaryBladderCancerType`), `recurrence` (1 = relapse-free, 2 = relapse), `progression`, stage, grade, survival. |

## Sample groups (n)

| Tissue group | n |
|---|---|
| Normal bladder mucosa | 10 |
| Bladder mucosa surrounding tumor (pre-cancer field) | 58 |
| Primary BC, superficial (stage 1, non-muscle-invasive) | 103 |
| Primary BC, invasive (stage 2, muscle-invasive) | 62 |

## Terms

GEO data is publicly available for research use. It is aggregate and
de-identified; no PII/PHI is present. Redistributed here for reproducibility of
this educational analysis. If you reuse the data, cite the original study above.
