# 03 — Immune Cell Deconvolution (CIBERSORTx)

CIBERSORTx is run on the hosted service at <https://cibersortx.stanford.edu>,
so this step is documented rather than scripted. The inputs and outputs live in
the repo so the downstream visualization (step 04) is fully reproducible.

## Inputs

Mixture files (genes × samples, one file per tissue group) are in
`data/cibersortx_inputs/`:

| File | Tissue group |
|---|---|
| `NormalForCibersortX.txt` | Normal bladder mucosa |
| `BCSurrMucosaForCibersortX.txt` | Bladder mucosa surrounding tumor (pre-cancer field) |
| `BCsuperficialCibersortX.txt` | Primary BC, superficial (stage 1) |
| `BCinvasiveCibersortX.txt` | Primary BC, invasive (stage 2) |

## Run settings

- **Signature matrix:** LM22 (22 immune cell subsets)
- **Mode:** Impute Cell Fractions
- **Quantile normalization:** **disabled** — recommended by CIBERSORTx for
  microarray data (this cohort is Illumina microarray, not RNA-seq)
- **Permutations:** 100 (for the deconvolution p-value)

## Outputs

Per-group cell-fraction tables are in `results/deconvolution/`:

- `CIBERSORTx_precancer.csv`, `CIBERSORTx_stage1.csv`, `CIBERSORTx_stage2.csv`
- `CIBERSORTx_stage1_by_recurrence.csv`, `CIBERSORTx_stage2_by_recurrence.csv`
  (used for the recurrence-stratified trend analysis)

Each row is a sample; the first 22 columns are LM22 fractions and the final
three are the CIBERSORTx `P-value`, `Correlation`, and `RMSE` goodness-of-fit
statistics. Samples with a deconvolution p-value ≥ 0.05 have a low-confidence
mixture fit and should be interpreted with caution.
