library(tidyverse)
library(easystats)
library(lme4)

data <- read.csv(
  "data_detectors.csv",
  stringsAsFactors = FALSE
) %>%
  mutate(Method = fct_relevel(
    Method, "christov2004", "elgendi2010", "engzeemod2012",
    "gamboa2008", "hamilton2002", "kalidas2017",
    "martinez2003", "pantompkins1985", "rodrigues2020"
  ))

colors <- c(
  "pantompkins1985" = "#f44336",
  "hamilton2002" = "#FF5722", "martinez2003" = "#FF9800",
  "christov2004" = "#FFC107", "gamboa2008" = "#4CAF50",
  "elgendi2010" = "#009688", "engzeemod2012" = "#2196F3",
  "kalidas2017" = "#3F51B5", "rodrigues2020" = "#9C27B0"
)

data <- filter(data, Error == "None")
data <- filter(data, Method != "neurokit2020")
data <- filter(data, !is.na(Score))

# Normalize duration
data <- data %>%
  mutate(Duration = (Duration) / (Recording_Length * Sampling_Rate))

# Descriptive duration
data %>%
  ggplot(aes(x = Method, y = Duration, fill = Method)) +
  geom_jitter2(aes(color = Method, group = Database),
               size = 3, alpha = 0.2, position = position_jitterdodge()
  ) +
  geom_boxplot(aes(alpha = Database), outlier.alpha = 0) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  theme_modern() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_alpha_manual(values = seq(0, 1, length.out = 8)) +
  scale_color_manual(values = colors) +
  scale_fill_manual(values = colors) +
  scale_y_sqrt() +
  ylab("Délka (počet sekund za výběr)")

# Descriptive error
data <- data %>%
  mutate(Outlier = performance::check_outliers(
    Score,
    threshold = list(zscore = stats::qnorm(p = 1 - 0.000001))
  )) %>%
  filter(Outlier == 0)

data %>%
  ggplot(aes(x = Database, y = Score)) +
  geom_boxplot(aes(fill = Method), outlier.alpha = 0, alpha = 1) +
  geom_jitter2(
    aes(color = Method, group = Method),
    size = 3, alpha = 0.2, position = position_jitterdodge()
  ) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  theme_modern() +
  labs(
    x = "Databáze",
    y = "Výše chyby"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 20)
  ) +
  scale_color_manual(values = colors) +
  scale_fill_manual(values = colors) +
  scale_y_sqrt()

# Linear modeling
model <- lmer(
  Duration ~ Method + (1 | Database) + (1 | Participant),
  data = data
)
means <- modelbased::estimate_means(model)
arrange(means, Mean)
means %>%
  ggplot(aes(x = Method, y = Mean, color = Method)) +
  geom_line(aes(group = 1), size = 1) +
  geom_pointrange(aes(ymin = CI_low, ymax = CI_high), size = 1) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  theme_modern() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 14)) +
  scale_color_manual(values = colors) +
  ylab("Délka (počet sekund za výběr)")

model <- lmer(Score ~ Method + (1 | Database) + (1 | Participant), data = data)
means <- modelbased::estimate_means(model)
arrange(means, abs(Mean))
means %>%
  ggplot(aes(x = Method, y = Mean, color = Method)) +
  geom_line(aes(group = 1), size = 1) +
  geom_pointrange(aes(ymin = CI_low, ymax = CI_high), size = 1) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  theme_modern() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 14)) +
  scale_color_manual(values = colors) +
  ylab("Výše chyby")


table$Mean <- round(table$Mean, digits = 3)
table$SE <- round(table$SE, digits = 3)
table$CI_low <- round(table$CI_low, digits = 3)
table$CI_high <- round(table$CI_high, digits = 3)

library(kableExtra)
kable(table, "latex", booktabs = TRUE, digits = 4)




