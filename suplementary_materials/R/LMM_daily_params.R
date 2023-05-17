# Load libraries
library(tidyverse)
library(lme4)
library(sjPlot)
library(emmeans)
library(extrafont)
fonts()

# Load data
file_list <- paste0("data/data_30s_15s/",
                    list.files(path = "data/data_30s_15s", pattern = "*.csv"))
data <- read_delim(file_list, id = "file_name") %>% 
  select(-file_name) %>% 
  select(HRV_RMSSD, HRV_pNN50, HRV_MeanNN, HRV_SDNN, HRV_HF,
         HRV_SD1, HRV_SD1SD2, id, segment_day, sw_cycle, segment_stop) %>% 
  rename("day" = "segment_day") %>% 
  filter(day > 0)

# data <- filter(data, sw_cycle == 0)

# Replace corresponding
data$id <-
  gsub(pattern = "Lander2",
       replacement = "Lander3",
       x = as.character(data$id))
data$id <-
  gsub(pattern = "MotherShip4",
       replacement = "MotherShip2",
       x = as.character(data$id)) 

# Convert posix to datetime
data$datetime <- as.POSIXct(data$segment_stop / 1000,
                            origin = "1970-01-01",
                            tz = "GMT")
data$hourly <- as_datetime(format(data$datetime, "%Y-%m-%d %H:00:00"))

# Add column group according to id
data$group <- gsub("[0-9]+", "", as.character(data$id))

# Set factors
data$id <- as.factor(data$id)
data$group <- factor(data$group, levels = c("MotherShip", "Lander"))
data$sw_cycle <- as.factor(data$sw_cycle)

# Select only awake data
# awake_data <- subset(data, sw_cycle == 0)

# Subset subjects
lander1 <- subset(data, id == "Lander1")
lander3 <- subset(data, id == "Lander3")
lander4 <- subset(data, id == "Lander4")
mothership1 <- subset(data, id == "MotherShip1")
mothership2 <- subset(data, id == "MotherShip2")
mothership3 <- subset(data, id == "MotherShip3")

data$hourly <- cut(data$datetime, breaks = "15 min")
hourly_rmssd <- aggregate(HRV_RMSSD ~ id + dt30 + day + group, data, median)
hourly_rmssd <- filter(hourly_rmssd, HRV_RMSSD < 200 & HRV_RMSSD > 0)

# Aggregate for subject and param
hourly_rmssd <- aggregate(HRV_RMSSD ~ id + dt30 + day + group, data, median)
hourly_rmssd <- filter(hourly_rmssd, HRV_RMSSD < 200 & HRV_RMSSD > 10)
hourly_rmssd <- filter(hourly_rmssd, !(id == "Lander1" & hourly < hourly_rmssd$hourly[10]))

hourly_pnn50 <- aggregate(HRV_pNN50 ~ id + dt30 + day + group, data, median)
hourly_pnn50 <- filter(hourly_pnn50, HRV_pNN50 < 65)
hourly_pnn50 <- filter(hourly_pnn50, !(id == "Lander1" & hourly < hourly_pnn50$hourly[20]))
hourly_pnn50 <- filter(hourly_pnn50, !(id == "Lander4" & HRV_pNN50 > 20))

hourly_sdnn <- aggregate(HRV_SDNN ~ id + dt30 + day + group, data, median)
hourly_sdnn <- filter(hourly_sdnn, HRV_SDNN < 200)
hourly_sdnn <- filter(hourly_sdnn, !(id == "Lander1" & hourly < hourly_sdnn$hourly[20]))
hourly_sdnn <- filter(hourly_sdnn, !(id == "Lander4" & HRV_SDNN < 10))

hourly_hf <- aggregate(HRV_HF ~ id + dt30 + day + group, data, median)
# hourly_hf <- filter(hourly_hf, HRV_HFn > 0.90)
hourly_hf <- filter(hourly_hf, !(id == "Lander1" & hourly < hourly_hf$hourly[20]))

m1 <- lmer(log(HRV_RMSSD) ~ day * group + (day | id), hourly_rmssd, REML = FALSE)
m2 <- lmer(HRV_pNN50 ~ day * group + (day | id), hourly_pnn50, REML = FALSE)
m3 <- lmer(log(HRV_SDNN) ~ day * group + (day | id), hourly_sdnn, REML = FALSE)
m4 <- lmer(log(HRV_HF) ~ day * group + (day | id), hourly_hf, REML = FALSE)

summary(m3)

# powerSim(m3, nsim=100, test = fcompare(log(HRV_SDNN)~day))
# sjPlot::plot_model(m1, type="diag")
# bquote("HF"~(ms^2/Hz))
plot(resid(m1, type = "pearson") ~ fitted(m1))
qqnorm(resid(m1, type = "pearson"))
qqline(resid(m1, type = "pearson"))

# Plot daily data for each subject
ggplot(hourly_pnn50, aes(x = day, y = (HRV_pNN50), group = id)) +
  geom_point(alpha = 0.2) + 
  facet_wrap(~ id, scales = "free_y") +
  geom_line(aes(y=fitted(m2)), linewidth = 1, color = "#377eb8") +
  scale_x_continuous(breaks = seq(1, 8)) + 
  labs(y = "pNN50 (%)", x = "Den mise") + 
  theme_bw() + 
  # ylim(-5.5, NA) +  
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/lmm_pnn50_fit.pdf", 
       width = 23, height = 11, units = "cm", device = cairo_pdf, dpi = 600)

# ggplot(hourly_rmssd, aes(x = day, y = log(HRV_RMSSD), group = id, color = id)) +
#   geom_point(alpha = 0.5) + 
#   facet_wrap(~ group, scales = "free_y") +
#   geom_line(aes(y=fitted(m1), color=id), linewidth = 1) +
#   scale_x_continuous(breaks = seq(1, 8)) + 
#   # ylim(0, 120) + 
#   labs(y = "RMSSD (ms)", x = "Den mise") + 
#   theme_bw() + 
#   theme(text = element_text(size=16, family="LM Roman 10"))


sjPlot::tab_model(
  m3,
  show.r2 = TRUE,
  show.icc = FALSE,
  show.re.var = FALSE,
  emph.p = TRUE,
  string.pred = "Prediktor",
  string.est = "Odhad")


# Plot estimates
sjPlot::plot_model(
  m1, 
  title = "", show.values = TRUE,
  value.offset = .3,
  axis.labels = c("Den * Lander", "Lander", "Den"),
  xlab =
  ) +
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/lmm_rmssd_coef.pdf", 
       width = 10, height = 7, units = "cm", device = cairo_pdf, dpi = 600)

sjPlot::plot_model(
  m2, 
  title = "", show.values = TRUE,
  value.offset = .3,
  axis.labels = c("Den * Lander", "Lander", "Den"),
  xlab =
) +
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/lmm_pnn50_coef.pdf", 
       width = 10, height = 7, units = "cm", device = cairo_pdf, dpi = 600)

sjPlot::plot_model(
  m3, 
  title = "", show.values = TRUE,
  value.offset = .3,
  axis.labels = c("Den * Lander", "Lander", "Den"),
  xlab =
) +
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/lmm_sdnn_coef.pdf", 
       width = 10, height = 7, units = "cm", device = cairo_pdf, dpi = 600)

sjPlot::plot_model(
  m4, 
  title = "", show.values = TRUE,
  value.offset = .3,
  axis.labels = c("Den * Lander", "Lander", "Den"),
  xlab =
) +
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/lmm_hf_coef.pdf", 
       width = 10, height = 7, units = "cm", device = cairo_pdf, dpi = 600)

