# Review and validation

## Source and scope

Source: completed 2026_Assignment2.qmd and its submitted PDF in the supplied MAST30027 Assignment 2 directory. The student answer section starts at Part 1: Executive summary. The published QMD retains that section, adds a portfolio title and AIMS acknowledgement, and changes the CSV path to data/. Original source files are unchanged.

The public 16-page PDF has a new provenance cover and the original completed analysis pages. The first five original pages contain assignment requirements and identifying headers and are omitted. Remaining requirements at the top of original page 6 were removed from the content stream; the empty region and decorative bullets are cropped. Text on original pages 7-20 is identical to the retained analysis pages. No student ID remains in extracted PDF text. The changed cover and first analysis page were rendered and visually checked.

## Execution

Rscript run_analysis.R completed successfully using R 4.5.2, ggplot2 4.0.2 and knitr 1.51. Locale startup warnings did not prevent execution. It reproduces the original completed code blocks, seeded display jitter, plus added CSV exports, checks and a fitted-count chart. Quarto rendering was not run. Results/session-info.txt records the R session.

Checks confirm 120 complete observations with unique anonymous IDs and nonnegative integer counts, positive finite fitted means, reproduced dispersion and zone coefficient, agreement between the Poisson and quasi-Poisson interaction-model fitted means, and preserved zone-association direction in sensitivity refits. The row positions used to omit AIMS022/AIMS024 are checked against those identifiers to avoid accidental deletion after a data reorder.

The report's original near-95% confidence intervals use estimate +/- 2 SE on the log scale. That convention is retained and explicitly labelled approximate. They are intervals for expected counts or an expected-count ratio, not individual-site prediction intervals. Recomputing with a different critical value would be a different numerical convention.

The Poisson interaction model has Pearson dispersion 5.3776; the final additive quasi-Poisson model's dispersion is approximately 5.4043. These are different fits. The quasi-Poisson comparison uses an F test and does not compare AIC. A smaller p-value from the initial Poisson model is not retained as the final interaction conclusion.

Influence analysis is descriptive. Omitting influential observations is a sensitivity check, not a replacement primary analysis. Overdispersion adjustment cannot itself establish model adequacy, independence or the absence of omitted-variable bias. No causal zoning-effect or population-wide monitoring claim is made.
