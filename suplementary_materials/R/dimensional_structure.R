library(tidyverse)
library(easystats)

r <- correlation::correlation(data[param_cols]) %>%
  as.matrix() %>%
  correlation::cor_smooth(verbose = FALSE)

set.seed(42)

n <- parameters::n_components(
  data[param_cols],
  cor = r,
  rotation = "promax",
  package = "all",
  n_max = 39
)

plot(n)

pca <- parameters::principal_components(data[param_cols],
                                        n = 15,
                                        rotation = "promax")
plot(pca, size_text = 3) + theme(axis.text.y = element_text(size = 5))

n <- parameters::n_factors(
  data[param_cols],
  cor = r,
  type = "FA",
  package = "all",
  n_max = 39
)

plot(n)

efa <- parameters::factor_analysis(
  data[param_cols],
  cor = r,
  n = 15,
  rotation = "promax",
  fm = "ml"
)
plot(efa, size_text = 3) + theme(axis.text.y=element_text(size=5))


