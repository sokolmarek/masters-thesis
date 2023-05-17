# Load libraries
library(tidyverse)
library(sjPlot)
library(patchwork)
library(extrafont)
fonts()

# Load data
file_list <- paste0("processed_tests_raw/",
                    list.files(path = "processed_tests_raw", pattern = "*.csv"))
data <- read_delim(file_list, id = "file_name") %>%
  rename("id" = "file_name")
# data <- read_delim("processed_tests_DP/Lander1.csv")

# Extract id from filename and create groups
data$id <- str_split_i(data$id, "/", 2)
data$id <- substr(data$id, 1, nchar(data$id) - 4)
data$group <- gsub("[0-9]+", "", data$id)

# Set factors
data$group <- factor(data$group, levels = c("MotherShip", "Lander"))
data$id <- as.factor(data$id)
data$program <- as.factor(data$program)
data$day <- unclass(data$day)
data$day <- factor(data$day, levels = c("Saturday", "Sunday", "Monday",
                                        "Tuesday", "Wednesday", "Thursday"))
data$day <- as.integer(data$day)

# Remove outliers
data <- filter(data, rmssd < 200 & rmssd > 0)
data <- filter(data, sdnn < 200 & sdnn > 0)
data <- filter(data, pnn50 < 60)

# Some merges
data <- data %>% mutate(day = ifelse(id == "Lander4" & day == 6, 4, day))
data <- data %>% mutate(day = ifelse(id == "MotherShip2" & day == 6, 5, day))
data <- data %>% mutate(day = ifelse(id == "MotherShip3" & day == 6, 5, day))

# Change days numbering
data <- data %>% mutate(day = ifelse(id == "MotherShip1" & day == 2, 1, day))
data <- data %>% mutate(day = ifelse(group == "Lander" & day == 2, 1, day))
data <- data %>% mutate(day = ifelse(id == "Lander4" & day == 4, 5, day))
data <- data %>% mutate(day = ifelse(id == "Lander1" & day == 4, 3, day))

# Create factor for days
data$day <- factor(data$day)
levels(data$day) <- c("F", "M", "L")

m1 <- lmer(log(rmssd) ~ day * group * program + (day | group/id), data, REML = FALSE)
m2 <- lmer(pnn50 ~ day * group * program  + (day | id), data, REML = FALSE)
m3 <- lmer(log(sdnn) ~ day * group * program + (day | id), data, REML = FALSE)
m4 <- lmer(log(hf) ~ day * group * program + (day | id), data, REML = FALSE)

summary(m1)
