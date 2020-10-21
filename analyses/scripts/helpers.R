AGENTCOUNT_LEVELS <- c(
  "500" = "500 agents", "550" = "550 agents", "600" = "600 agents", "650" = "650 agents", 
  "700" = "700 agents", "750" = "750 agents", "800" = "800 agents", "850" = "850 agents", 
  "900" = "900 agents", "950" = "950 agents", "1000" = "1000 agents"
)
BEHAVIORACTIVATED_LEVELS <- c("FALSE" = "behavior not activated", "TRUE" = "behavior activated")
BEHAVIORREDUCTIONFACTOR_LEVELS <- c(
  "0" = "0.000", "0.125" = "0.125", "0.25" = "0.250", "0.375" = "0.375", "0.5" = "0.500", 
  "0.625" = "0.625", "0.75" = "0.750", "0.875" = "0.875", "1" = "1.000"
)
CLASS_LEVELS <- c(
  "SCount" = "S", "ECount" = "E", "IuCount" = "I undetected", "IdCount" = "I detected", "ICount" = "I", "RCount" = "R",
  "IdCumulative" = "cumulated detected cases", "ICumulative" = "I cumulated",
  "NewCasesReal" = "actual new cases", "NewCasesDetected" = "new detected cases"
)
REPLICATE_LEVELS <- c(
  "1" = "Replicate 1", "2" = "Replicate 2", "3" = "Replicate 3", "4" = "Replicate 4", "5" = "Replicate 5",
  "6" = "Replicate 6", "7" = "Replicate 7", "8" = "Replicate 8", "9" = "Replicate 9", "10" = "Replicate 10"
)
TESTPROB_LEVELS <- c(
  "0" = "0.0", "0.1" = "0.1", "0.2" = "0.2", "0.3" = "0.3", 
  "0.4" = "0.4", "0.5" = "0.5", "0.6" = "0.6", "0.7" = "0.7",
  "0.8" = "0.8", "0.9" = "0.9", "1" = "1.0"
)

theme_thesis <- function(plot_margin = 15, design = 0) {
  specs <- theme_minimal() +
    theme(
      plot.title = element_text(size = 14, margin = margin(b = 10)),
      plot.margin = margin(t = plot_margin, b = plot_margin, l = plot_margin, r = plot_margin),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black", size = 0.3),
      axis.title.x = element_text(size = 11, margin = margin(t = 10, b = 10)),
      axis.title.y = element_text(size = 11, margin = margin(r = 10)),
      axis.text.x = element_text(size = 8),
      axis.text.y = element_text(size = 8),
      legend.title = element_blank(),
      panel.spacing = unit(1.2, "lines")
    )
  if (design == 1) {
    specs <- specs +
    theme(
      plot.background = element_rect(fill = "grey98", color = "transparent"),
      panel.background = element_rect(fill = "grey93", color = "transparent"),
      panel.grid.major = element_line(color = "grey89")
    )
  } else if (design == 2) {
    specs <- specs +
    theme(
      plot.background = element_rect(fill = "grey98", color = "transparent"),
      panel.grid.major = element_line(color = "grey89")
    )
  } else if (design == 3) {
    specs <- specs +
    theme(
      panel.background = element_rect(fill = "grey98", color = "transparent"),
      panel.grid.major = element_line(color = "grey89")
    )
  }
  return(specs)
}

theme_thesis_arrange <- function(plot_margin = 15, design = 0) {
  specs <- theme(
    plot.margin = margin(t = plot_margin, b = plot_margin, l = plot_margin, r = plot_margin)
  )
  if (design == 1 | design == 2) {
    specs <- specs +
      theme(
        plot.background = element_rect(fill = "grey98", color = "transparent")
      ) 
  }
  return(specs)
}

strip_varname <- function(x) {return(sub("X[0-9]+.", "", x))}

standard_error <- function(x) {return(sd(x) / sqrt(n()))}

save_plot <- function(filename = "default", width = 8, height = 5, dpi = 50) {
    ggsave(
      file.path("graphics", "pdf", paste0(filename, ".pdf")), 
      width = width, height = height, units = "in", dpi = dpi
    )  
    ggsave(
      file.path("graphics", "png", paste0(filename, ".png")), 
      width = width, height = height, units = "in", dpi = dpi
    )  
}