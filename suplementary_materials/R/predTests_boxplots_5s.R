# Load libraries
library(tidyverse)
library(zoo)
library(extrafont)
fonts()

# Load data
file_list <- paste0("predTests_5s/",
                    list.files(path = "predTests_5s", pattern = "*.csv"))
data <- read_delim(file_list)

# Convert posix to datetime and create days
data$datetime <- as.POSIXct(data$end,
                            origin = "1970-01-01",
                            tz = "GMT")
data$day <- as.numeric(format(data$datetime, "%d"))
data$day <- data$day - 19
data$group <- gsub("[0-9]+", "", data$id)

# Some merges
data <- data %>% mutate(day = ifelse(id == "Lander3" & day == 6, 5, day))
data <- data %>% mutate(day = ifelse(id == "Lander4" & day == 6, 4, day))
data <- data %>% mutate(day = ifelse(id == "MotherShip2" & day == 6, 5, day))
data <- data %>% mutate(day = ifelse(id == "MotherShip3" & day == 6, 4, day))

# Change days numbering
data <- data %>% mutate(day = ifelse(id == "MotherShip1" & day == 2, 1, day))
data <- data %>% mutate(day = ifelse(id == "MotherShip3" & day == 4, 5, day))
data <- data %>% mutate(day = ifelse(group == "Lander" & day == 2, 1, day))
data <- data %>% mutate(day = ifelse(id == "Lander4" & day == 4, 5, day))
data <- data %>% mutate(day = ifelse(id == "Lander1" & day == 4, 3, day))

# Create factor for days
data$day <- factor(data$day)
levels(data$day) <- c("F", "M", "L")

# Plot
ggplot(data, aes(x = day, y = pred, group = id)) +
  geom_pointrange(
    stat = "summary",
    fun.min = min,
    fun.max = max,
    fun = median,
    fill="black", color="darkgray", shape=21, fatten = 1, size = 2.2) +  
  geom_line(stat = "summary", fun = median) +
  facet_wrap(~ id) + 
  theme_bw() + 
  labs(y = "Predikce", x = "Sezení") + 
  theme(text = element_text(size=16, family="LM Roman 10"))

ggsave("C:/Users/Marek/OneDrive/School/DP/masters-thesis/assets/figures/stats/hydro_test.pdf", 
       width = 22, height = 10, units = "cm", device = cairo_pdf, dpi = 600)
