# Load libraries
library(tidyverse)
library(easystats)
library(lme4)
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
data$group <- as.factor(data$group)
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

data$hourly <- as_datetime(cut(data$datetime, breaks = "10 min"))
data <- filter(data, id == "Lander3", day > 1)

# Aggregate for subject and param
hourly_rmssd <- aggregate(HRV_RMSSD ~ id + hourly, data, median)
hourly_rmssd <- filter(hourly_rmssd, HRV_RMSSD < 180)
# hourly_rmssd <- filter(hourly_rmssd, !(id == "Lander1" & hourly < hourly_rmssd$hourly[100]))

hourly_pnn50 <- aggregate(HRV_pNN50 ~ id + hourly, data, median)
hourly_pnn50 <- filter(hourly_pnn50, HRV_pNN50 < 65)
# hourly_pnn50 <- filter(hourly_pnn50, !(id == "Lander1" & hourly < hourly_pnn50$hourly[50]))
hourly_pnn50 <- filter(hourly_pnn50, !(id == "Lander4" & HRV_pNN50 > 10))

hourly_sdnn <- aggregate(HRV_SDNN ~ id + hourly, data, median)
hourly_sdnn <- filter(hourly_sdnn, HRV_SDNN < 200)
# hourly_sdnn <- filter(hourly_sdnn, !(id == "Lander1" & hourly < hourly_sdnn$hourly[50]))
hourly_sdnn <- filter(hourly_sdnn, !(id == "Lander4" & HRV_SDNN > 65))

hourly_hf <- aggregate(HRV_HF ~ id + hourly, data, median)
# hourly_hf <- filter(hourly_hf, HRV_HF < 0.09)
# hourly_hf <- filter(hourly_hf, !(id == "Lander1" & hourly < hourly_hf$hourly[50]))

# Plot metrics for lander3
p1 <- ggplot(hourly_sdnn, aes(x = hourly, y = HRV_SDNN)) +
  geom_point(size = 0.5) + 
  geom_smooth(span = 0.1, se = FALSE) +
  labs(y = "SDNN (ms)", x = "Den mise") + 
  theme_bw() + 
  theme(text = element_text(size=14, family="LM Roman 10"),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

p2 <- ggplot(hourly_rmssd, aes(x = hourly, y = HRV_RMSSD)) +
  geom_point(size = 0.5) + 
  geom_smooth(span = 0.1, se = FALSE) +
  labs(y = "RMSSD (ms)", x = "Den mise") + 
  theme_bw() + 
  theme(text = element_text(size=14, family="LM Roman 10"),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

p3 <- ggplot(hourly_pnn50, aes(x = hourly, y = HRV_pNN50)) +
  geom_point(size = 0.5) + 
  geom_smooth(span = 0.1, se = FALSE) +
  labs(y = "pNN50 (%)", x = "Den mise") + 
  theme_bw() + 
  theme(text = element_text(size=14, family="LM Roman 10"),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

p4 <- ggplot(hourly_hf, aes(x = hourly, y = HRV_HF)) +
  geom_point(size = 0.5) + 
  geom_smooth(span = 0.1, se = FALSE) +
  labs(y = bquote("HF"~(ms^2/Hz)), x = "Den mise") + 
  theme_bw() + 
  theme(text = element_text(size=14, family="LM Roman 10"))


p1 / p2 / p3 / p4
ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/hourly_params.pdf", 
       width = 20, height = 15, units = "cm", device = cairo_pdf, dpi = 600)


# Plot hourly data for each subject
ggplot(hourly_rmssd, aes(x = hourly, y = HRV_RMSSD)) +
  geom_point(size = 0.6) + 
  geom_smooth(span = 0.1, se = FALSE) +
  facet_wrap(~ id, scales = "free", ncol = 1) +
  labs(y = "RMSSD (ms)", x = "Den mise") + 
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/hourly_rmssd.pdf", 
       width = 22, height = 14, units = "cm", device = cairo_pdf, dpi = 600)

ggplot(hourly_pnn50, aes(x = hourly, y = HRV_pNN50)) +
  geom_point(size = 0.6) + 
  geom_smooth(span = 0.1, se = FALSE) +
  facet_wrap(~ id, scales = "free", ncol = 2) +
  labs(y = "pNN50 (%)", x = "Den mise") + 
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/hourly_pnn50.pdf", 
       width = 22, height = 14, units = "cm", device = cairo_pdf, dpi = 600)

ggplot(hourly_sdnn, aes(x = hourly, y = HRV_SDNN)) +
  geom_point(size = 0.6) + 
  geom_smooth(span = 0.1, se = FALSE) +
  facet_wrap(~ id, scales = "free", ncol = 2) +
  labs(y = "SDNN (ms)", x = "Den mise") + 
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/hourly_sdnn.pdf", 
       width = 22, height = 14, units = "cm", device = cairo_pdf, dpi = 600)

ggplot(hourly_hf, aes(x = hourly, y = HRV_HF)) +
  geom_point(size = 0.6) + 
  geom_smooth(span = 0.1, se = FALSE) +
  facet_wrap(~ id, scales = "free", ncol = 2) +
  labs(y = bquote("HF"~(ms^2/Hz)), x = "Den mise") + 
  theme_bw() + 
  scale_y_continuous(labels = function(x) sprintf("%.2f", x)) + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/hourly_hf.pdf", 
       width = 22, height = 14, units = "cm", device = cairo_pdf, dpi = 600)

