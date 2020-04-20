# articles that I only want to compile intentionally

library(knitr)

knit(
  # the leading `_` keeps pkgdown from re-rendering the original
  "vignettes/articles/_dates-and-times.Rmd.orig.Rmd",
  "vignettes/articles/dates-and-times.Rmd"
)
