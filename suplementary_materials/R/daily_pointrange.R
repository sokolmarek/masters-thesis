# Load libraries
library(tidyverse)
library(lme4)
library(extrafont)
fonts()

# Load data
file_list <- paste0("data/data_30s_15s/",
                    list.files(path = "data/data_30s_15s", pattern = "*.csv"))
data <- read_delim(file_list, id = "file_name") %>% 
  select(-file_name) %>% 
  select(HRV_RMSSD, HRV_pNN50, HRV_MeanNN, HRV_SDNN, HRV_HF, RSP_Rate_Baseline,
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
# data <- subset(data, sw_cycle == 0)

# Subset subjects
lander1 <- subset(data, id == "Lander1")
lander3 <- subset(data, id == "Lander3")
lander4 <- subset(data, id == "Lander4")
mothership1 <- subset(data, id == "MotherShip1")
mothership2 <- subset(data, id == "MotherShip2")
mothership3 <- subset(data, id == "MotherShip3")

# Aggregate for subject and param
hourly_rsp <- aggregate(RSP_Rate_Baseline ~ id + hourly + day, data, median)
# hourly_rsp <- filter(hourly_rsp, RSP_Rate_Mean < 150)
# hourly_rsp <- filter(hourly_rsp, !(id == "Lander1" & hourly < hourly_rsp$hourly[10]))

# Aggregate for subject and param
hourly_rmssd <- aggregate(HRV_RMSSD ~ id + hourly + day, data, median)
hourly_rmssd <- filter(hourly_rmssd, HRV_RMSSD < 150)
hourly_rmssd <- filter(hourly_rmssd, !(id == "Lander1" & hourly < hourly_rmssd$hourly[10]))

hourly_pnn50 <- aggregate(HRV_pNN50 ~ id + hourly + day, data, median)
hourly_pnn50 <- filter(hourly_pnn50, HRV_pNN50 < 65)
hourly_pnn50 <- filter(hourly_pnn50, !(id == "Lander1" & hourly < hourly_pnn50$hourly[20]))
hourly_pnn50 <- filter(hourly_pnn50, !(id == "Lander4" & HRV_pNN50 > 10))

hourly_sdnn <- aggregate(HRV_SDNN ~ id + hourly + day, data, median)
hourly_sdnn <- filter(hourly_sdnn, HRV_SDNN < 200)
hourly_sdnn <- filter(hourly_sdnn, !(id == "Lander1" & hourly < hourly_sdnn$hourly[20]))
hourly_sdnn <- filter(hourly_sdnn, !(id == "Lander4" & HRV_SDNN > 65))

hourly_hf <- aggregate(HRV_HF ~ id + hourly + day, data, median)
# hourly_hf <- filter(hourly_hf, HRV_HF < 0.05)
hourly_hf <- filter(hourly_hf, !(id == "Lander1" & hourly < hourly_hf$hourly[20]))


# Plot daily param for each subject
ggplot(hourly_rsp, aes(x = day, y = RSP_Rate_Baseline)) +
  geom_pointrange(
    stat = "summary",
    fun.min = ~quantile(.x, probs = .25),
    fun.max = ~quantile(.x, probs = .75),
    fun = median,
    fill="black", color="darkgray", shape=21, fatten = 1, size = 2.2) +  
  geom_line(stat = "summary", fun = median) +  
  facet_wrap(~ id, scales = "free_y") +
  scale_x_continuous(breaks = seq(1, 8)) +
  labs(y = "lnRMSSD (ms)", x = "Den mise") + 
  scale_y_continuous(labels = function(x) sprintf("%.1f", x)) +
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))




ggplot(hourly_rmssd, aes(x = day, y = log(HRV_RMSSD))) +
  geom_pointrange(
    stat = "summary",
    fun.min = ~quantile(.x, probs = .25),
    fun.max = ~quantile(.x, probs = .75),
    fun = median,
    fill="black", color="darkgray", shape=21, fatten = 1, size = 2.2) +  
  geom_line(stat = "summary", fun = median) +  
  facet_wrap(~ id, scales = "free_y") +
  scale_x_continuous(breaks = seq(1, 8)) +
  labs(y = "lnRMSSD (ms)", x = "Den mise") + 
  scale_y_continuous(labels = function(x) sprintf("%.1f", x)) +
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/pointrange_rmssd.pdf", 
       width = 22, height = 10, units = "cm", device = cairo_pdf, dpi = 600)

ggplot(hourly_pnn50, aes(x = day, y = HRV_pNN50)) +
  geom_pointrange(
    stat = "summary",
    fun.min = ~quantile(.x, probs = .25),
    fun.max = ~quantile(.x, probs = .75),
    fun = median,
    fill="black", color="darkgray", shape=21, fatten = 1, size = 2.2) +  
  geom_line(stat = "summary", fun = median) +  
  facet_wrap(~ id, scales = "free_y") +
  scale_x_continuous(breaks = seq(1, 8)) +
  labs(y = "pNN50 (%)", x = "Den mise") + 
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/pointrange_pnn50.pdf", 
       width = 22, height = 10, units = "cm", device = cairo_pdf, dpi = 600)

ggplot(hourly_sdnn, aes(x = day, y = log(HRV_SDNN))) +
  geom_pointrange(
    stat = "summary",
    fun.min = ~quantile(.x, probs = .25),
    fun.max = ~quantile(.x, probs = .75),
    fun = median,
    fill="black", color="darkgray", shape=21, fatten = 1, size = 2.2) +  
  geom_line(stat = "summary", fun = median) +  
  facet_wrap(~ id, scales = "free_y") +
  scale_x_continuous(breaks = seq(1, 8)) +
  labs(y = "lnSDNN (ms)", x = "Den mise") + 
  scale_y_continuous(labels = function(x) sprintf("%.1f", x)) +
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/pointrange_sdnn.pdf", 
       width = 22, height = 10, units = "cm", device = cairo_pdf, dpi = 600)

ggplot(hourly_hf, aes(x = day, y = log(HRV_HF))) +
  geom_pointrange(
    stat = "summary",
    fun.min = ~quantile(.x, probs = .25),
    fun.max = ~quantile(.x, probs = .75),
    fun = median,
    fill="black", color="darkgray", shape=21, fatten = 1, size = 2.2) +  
  geom_line(stat = "summary", fun = median) +  
  facet_wrap(~ id, scales = "free_y") +
  scale_x_continuous(breaks = seq(1, 8)) +
  labs(y = bquote("lnHF"~(ms^2/Hz)), x = "Den mise") + 
  scale_y_continuous(labels = function(x) sprintf("%.1f", x)) + 
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/pointrange_hf.pdf", 
       width = 22, height = 10, units = "cm", device = cairo_pdf, dpi = 600)


