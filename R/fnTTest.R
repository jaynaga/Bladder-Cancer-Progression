#' Per-feature Welch two-sample t-test across an expression matrix
#'
#' Runs an independent Welch t-test for every row (probe/gene) of an
#' expression matrix between two sample groups, computes a signed log2
#' fold change, and applies Benjamini-Hochberg FDR correction across all
#' features. Results are written to `folderName` as a CSV sorted by p-value.
#'
#' NOTE: For production transcriptomics, an empirical-Bayes moderated model
#' (limma / DESeq2 / edgeR) is preferred over per-gene t-tests because it
#' shares variance information across genes and has far better small-sample
#' behaviour. This function is retained as the original coursework
#' implementation; see README "Known limitations" for the recommended upgrade.
#'
#' @param baseGroup      data.frame/matrix of features x samples (baseline group)
#' @param compGroup      data.frame/matrix of features x samples (comparison group)
#' @param testName       prefix for the output file name
#' @param baseGroupName  label for the baseline group
#' @param compGroupName  label for the comparison group
#' @param folderName     output directory (created if absent)
#' @return (invisibly) the path to the written CSV

funcCalcSignedFCLog <- function(c, b) {
  # c and b are group means on the log2 scale; returns a signed linear fold change
  if (c >= b) 2^(c - b) else -2^(b - c)
}

fnTTest <- function(baseGroup, compGroup, testName = "TTest",
                    baseGroupName, compGroupName, folderName = "output") {

  dataMatrixFinal <- cbind(compGroup, baseGroup)
  nFeatures <- nrow(dataMatrixFinal)

  # Pre-allocate a list rather than growing a matrix with rbind() in the loop
  rows <- vector("list", nFeatures)

  for (iCount in seq_len(nFeatures)) {
    onerowBaseline   <- as.numeric(unlist(baseGroup[iCount, ]))
    onerowComparison <- as.numeric(unlist(compGroup[iCount, ]))
    featureName      <- row.names(dataMatrixFinal)[iCount]

    tt <- tryCatch(
      t.test(x = onerowComparison, y = onerowBaseline),
      error = function(e) NULL
    )
    if (is.null(tt)) next   # e.g. zero variance in both groups

    signedFC <- funcCalcSignedFCLog(c = tt$estimate[1], b = tt$estimate[2])

    rows[[iCount]] <- data.frame(
      Feature          = featureName,
      CompGroup        = compGroupName,
      BaseGroup        = baseGroupName,
      NumSamplesInComp = length(onerowComparison),
      NumSamplesInBase = length(onerowBaseline),
      SignedFC         = signedFC,
      Tstatistic       = unname(tt$statistic),
      Parameter        = unname(tt$parameter),
      Pvalue           = tt$p.value,
      ConfInt_low      = tt$conf.int[1],
      ConfInt_high     = tt$conf.int[2],
      MeanComp         = unname(tt$estimate[1]),
      MeanBase         = unname(tt$estimate[2]),
      Method           = tt$method,
      stringsAsFactors = FALSE
    )
  }

  finalM <- do.call(rbind, rows)

  # Benjamini-Hochberg FDR across all tested features
  finalM$FDR <- p.adjust(finalM$Pvalue, method = "fdr")

  # Sort by ascending p-value
  finalM <- finalM[order(finalM$Pvalue), ]

  if (!dir.exists(folderName)) dir.create(folderName, recursive = TRUE)

  outFileName <- paste0(testName, "_", compGroupName, "_vs_", baseGroupName, "_TTest.csv")
  pathName    <- file.path(folderName, outFileName)
  write.csv(finalM, pathName, quote = FALSE, row.names = FALSE)

  invisible(pathName)
}
