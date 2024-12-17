#' Line graph of average immune-cell fractions across an ordered axis
#'
#' @param meansAll         matrix/data.frame: rows = immune cell types,
#'                         columns = ordered groups (e.g. Pre-cancer, Stage1, Stage2)
#' @param outputFileName   base name for the saved figure files
#' @param outputFolderName output directory (created if absent)
#' @return the ggplot object (also written to PNG/TIFF/PDF)
#'
#' Requires: reshape2, ggplot2

functionLineGraph <- function(meansAll,
                              outputFileName = "immune_lineplot",
                              outputFolderName = "output") {

  # 22-colour qualitative palette (one line per immune subset)
  palette22 <- c("#000000", "#808080", "#bfbfbf", "#911eb4", "#e6beff",
                 "#b20000", "#e6194b", "#000080", "#0082c8", "#3cb44b",
                 "#aaffc3", "#885820", "#ffd8b1", "#46f0f0", "#d2f53c",
                 "#fabebe", "#808000", "#ffe119", "#008080", "#FF00AA",
                 "#c8b900", "#ff6699")

  melted <- reshape2::melt(meansAll, id.vars = "row.names")
  colnames(melted)[1] <- "ImmuneCellSubtype"

  g <- ggplot2::ggplot(melted,
         ggplot2::aes(x = Var2, y = value, group = ImmuneCellSubtype)) +
    ggplot2::geom_line(ggplot2::aes(color = ImmuneCellSubtype), linewidth = 1.1) +
    ggplot2::geom_point(ggplot2::aes(color = ImmuneCellSubtype), size = 3) +
    ggplot2::ylab("Fraction of immune cells\n") +
    ggplot2::xlab("\nTumor progression") +
    ggplot2::scale_color_manual(values = palette22) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.text.x  = ggplot2::element_text(size = 11, face = "bold"),
      axis.text.y  = ggplot2::element_text(size = 11, face = "bold"),
      axis.title   = ggplot2::element_text(size = 13, face = "bold.italic"),
      legend.text  = ggplot2::element_text(size = 10.5),
      legend.position = "bottom",
      legend.title = ggplot2::element_blank()) +
    ggplot2::guides(color = ggplot2::guide_legend(nrow = 4))

  if (!dir.exists(outputFolderName)) dir.create(outputFolderName, recursive = TRUE)
  op <- file.path(outputFolderName, outputFileName)

  ggplot2::ggsave(paste0(op, ".png"), g, width = 13, height = 5.5, dpi = 150)
  ggplot2::ggsave(paste0(op, ".pdf"), g, width = 15, height = 8)
  ggplot2::ggsave(paste0(op, ".tiff"), g, width = 15, height = 7,
                  dpi = 300, compression = "lzw")

  g
}
