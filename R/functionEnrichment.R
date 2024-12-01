#' Run EnrichR over a set of gene-set libraries and write one sheet per library
#'
#' @param dblist          data.frame/character vector of EnrichR library names
#' @param genes           character vector of gene symbols
#' @param outputFileName  path to the .xlsx workbook to create
#' @return (invisibly) outputFileName
#'
#' Requires: enrichR, openxlsx

functionEnrichment <- function(dblist, genes, outputFileName) {

  dbs <- if (is.data.frame(dblist)) dblist[[1]] else as.character(unlist(dblist))
  genes <- as.character(unlist(genes))

  wb <- openxlsx::createWorkbook()

  for (oneDB in dbs) {
    enriched <- enrichR::enrichr(genes, oneDB)
    result   <- enriched[[oneDB]]

    # openxlsx sheet names are capped at 31 characters
    sheetName <- substr(oneDB, 1, 31)

    openxlsx::addWorksheet(wb, sheetName = sheetName)
    openxlsx::writeDataTable(wb, sheet = sheetName, x = result)
  }

  openxlsx::saveWorkbook(wb, file = outputFileName, overwrite = TRUE)
  invisible(outputFileName)
}
