# Load libraries
library(tidyverse)
library(easystats)
library(patchwork)
library(extrafont)
fonts()

# Load diana data
file_list <- paste0("processed_tests_raw/",
                    list.files(path = "processed_tests_raw", pattern = "*.csv"))
data_diana <- read_delim(file_list, id = "file_name") %>%
  rename("id" = "file_name") %>% 
  select(rmssd, hf, sdnn, pnn50, id)

# Extract id from filename and create groups
data_diana$id <- str_split_i(data_diana$id, "/", 2)
data_diana$id <- substr(data_diana$id, 1, nchar(data_diana$id) - 4)
data_diana$group <- gsub("[0-9]+", "", data_diana$id)
data_diana$exp <- "Post"

# Remove outliers
data_diana <- filter(data_diana, rmssd < 200 & rmssd > 0)
data_diana <- filter(data_diana, sdnn < 200 & sdnn > 0)
data_diana <- filter(data_diana, pnn50 < 60)

# Load pilot data
file_list <- paste0("pilot/",
                    list.files(path = "pilot", pattern = "*.csv"))
data_pilot <- read_delim(file_list)

# Extract id from filename and create groups
data_pilot$id <- as.factor(data_pilot$id)
data_pilot$group <- gsub("[0-9]+", "", data_pilot$id)
data_pilot$exp <- "Pre"

# Merge data
data <- rbind(data_diana, data_pilot)
data$exp <- factor(data$exp, levels = c("Pre", "Post"))

# Plots
ggplot(data, aes(x = exp, y = log(rmssd), group = exp)) +
  geom_boxplot() +  
  geom_point(stat = "summary", fun = mean, color = "red") + 
  # geom_line(
  #   mapping = aes(x = day, y = log(rmssd), group = id),
  #   stat = "summary", 
  #   fun = median,
  #   linetype = "dashed",
  #   color = "#3366FF"
  # ) +  
  facet_wrap(~ id, scales = "free_y")






