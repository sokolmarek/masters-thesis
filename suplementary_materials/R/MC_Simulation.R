# Load libraries
library(tidyverse)
library(simr)
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

data$hourly <- cut(data$datetime, breaks = "1 hour")

# Aggregate for subject and param
hourly_rmssd <- aggregate(HRV_RMSSD ~ id + hourly + day + group, data, median)
hourly_rmssd <- filter(hourly_rmssd, HRV_RMSSD < 200 & HRV_RMSSD > 10)
hourly_rmssd <- filter(hourly_rmssd, !(id == "Lander1" & hourly < hourly_rmssd$hourly[10]))

hourly_pnn50 <- aggregate(HRV_pNN50 ~ id + hourly + day + group, data, median)
hourly_pnn50 <- filter(hourly_pnn50, HRV_pNN50 < 65)
hourly_pnn50 <- filter(hourly_pnn50, !(id == "Lander1" & hourly < hourly_pnn50$hourly[20]))
hourly_pnn50 <- filter(hourly_pnn50, !(id == "Lander4" & HRV_pNN50 > 20))

hourly_sdnn <- aggregate(HRV_SDNN ~ id + hourly + day + group, data, median)
hourly_sdnn <- filter(hourly_sdnn, HRV_SDNN < 200)
hourly_sdnn <- filter(hourly_sdnn, !(id == "Lander1" & hourly < hourly_sdnn$hourly[20]))
hourly_sdnn <- filter(hourly_sdnn, !(id == "Lander4" & HRV_SDNN < 10))

hourly_hf <- aggregate(HRV_HF ~ id + hourly + day + group, data, median)
# hourly_hf <- filter(hourly_hf, HRV_HFn > 0.90)
hourly_hf <- filter(hourly_hf, !(id == "Lander1" & hourly < hourly_hf$hourly[20]))

m1 <- lmer(log(HRV_RMSSD) ~ day * group + (day | id), hourly_rmssd, REML = FALSE)
m2 <- lmer(HRV_pNN50 ~ day * group + (day | id), hourly_pnn50, REML = FALSE)
m3 <- lmer(log(HRV_SDNN) ~ day * group + (day | id), hourly_sdnn, REML = FALSE)
m4 <- lmer(log(HRV_HF) ~ day * group + (day | id), hourly_hf, REML = FALSE)

sim_treat <- powerSim(m1, nsim=100, test = fcompare(log(HRV_RMSSD) ~ day))
sim_treat

model_ext_class <- extend(m1, along="id", n=15)
sim_treat_class <- powerSim(model_ext_class, nsim=100, test = fcompare(log(HRV_RMSSD) ~ day))
sim_treat_class

# p_curve_treat <- powerCurve(model_ext_class, test=fcompare(log(HRV_RMSSD) ~ day), along="id", breaks=c(5,10,15,20))
# plot(p_curve_treat)








