# Load libraries
library(tidyverse)
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

ggplot(data, aes(x = day, y = log(rmssd), group = day)) +
  geom_boxplot() +  
  geom_point(stat = "summary", fun = median) + 
  geom_line(
    mapping = aes(x = day, y = log(rmssd), group = id),
    stat = "summary", 
    fun = median,
    linetype = "dashed",
    color = "#3366FF"
    ) +  
  facet_wrap(~ id, scales = "free_y") +
  scale_y_continuous(breaks = c(2, 3, 4, 5)) +
  labs(y = "lnRMSSD (ms)", x = "Sezení") + 
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/boxplot_rmssd_tests.pdf", 
       width = 22, height = 11, units = "cm", device = cairo_pdf, dpi = 600)

ggplot(data, aes(x = day, y = log(sdnn), group = day)) +
  geom_boxplot() +  
  geom_point(stat = "summary", fun = median) + 
  geom_line(
    mapping = aes(x = day, y = log(sdnn), group = id),
    stat = "summary", 
    fun = median,
    linetype = "dashed",
    color = "#3366FF"
  ) +  
  facet_wrap(~ id, scales = "free_y") +
  scale_y_continuous(breaks = c(2, 3, 4, 5)) + 
  labs(y = "lnSDNN (ms)", x = "Sezení") + 
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/boxplot_sdnn_tests.pdf", 
       width = 22, height = 11, units = "cm", device = cairo_pdf, dpi = 600)

ggplot(data, aes(x = day, y = pnn50, group = day)) +
  geom_boxplot() +  
  geom_point(stat = "summary", fun = median) + 
  geom_line(
    mapping = aes(x = day, y = pnn50, group = id),
    stat = "summary", 
    fun = median,
    linetype = "dashed",
    color = "#3366FF"
  ) +  
  facet_wrap(~ id, scales = "free_y") +
  #scale_y_continuous(breaks = c(2, 3, 4, 5)) + 
  labs(y = "pNN50 (%)", x = "Sezení") + 
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/boxplot_pnn50_tests.pdf", 
       width = 22, height = 11, units = "cm", device = cairo_pdf, dpi = 600)

ggplot(data, aes(x = day, y = log(hf), group = day)) +
  geom_boxplot() +  
  geom_point(stat = "summary", fun = median) + 
  geom_line(
    mapping = aes(x = day, y = log(hf), group = id),
    stat = "summary", 
    fun = median,
    linetype = "dashed",
    color = "#3366FF"
  ) +  
  facet_wrap(~ id, scales = "free_y") +
  #scale_y_continuous(breaks = c(2, 3, 4, 5)) + 
  labs(y = bquote("lnHF"~(ms^2/Hz)), x = "Sezení") + 
  theme_bw() + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/boxplot_hf_tests.pdf", 
       width = 22, height = 11, units = "cm", device = cairo_pdf, dpi = 600)

