# Load libraries
library(tidyverse)
library(easystats)

# Load data
file_list <- paste0("data/data_30s_15s/",
                    list.files(path = "data/data_30s_15s", pattern = "*.csv"))
data <- read_delim(file_list, id = "file_name") %>%
  select_if( ~ !any(is.na(.)))

# Replace corresponding
data$id <-
  gsub(pattern = "Lander2",
       replacement = "Lander3",
       x = as.character(data$id))
data$id <-
  gsub(pattern = "MotherShip4",
       replacement = "MotherShip2",
       x = as.character(data$id)) 

# Set factors
data$id <- as.factor(data$id)
data$sw_cycle <- as.factor(data$sw_cycle)
data$segment_day <- as.factor(data$segment_day)


ID <- "MotherShip1"
subject_data <- filter(data, data$id == ID)

# Remove equivalent
subject_data %>%
  select(
    -file_name,
    -segment_day,
    -segment_length,
    -segment_start,
    -segment_stop,
    -sw_cycle,
    -exercise,
    -cl,
    -id
  ) %>%
  correlation::correlation() %>%
  filter(abs(r) > 0.999) %>%
  arrange(Parameter1, desc(abs(r))) %>%
  format()

subject_data <- subject_data %>% 
  select(-HRV_SDSD, HRV_SD1) %>%
  select(-HRV_C1d, -HRV_C1a) %>%
  select(-HRV_Cd) %>%
  select(-EDA_Tonic_mean, -HRV_SampEn) %>% 
  select(-EDA_mean, -EDA_median)

# Remove outliers
param_cols <- names(
  select(
    subject_data,
    -...1,
    -file_name,
    -RSP_Phase_Completion,
    -segment_day,
    -segment_length,
    -segment_start,
    -segment_stop,
    -sw_cycle,
    -exercise,
    -cl,
    -id,
  )
)

df_outliers <-
  data.frame(
    param_cols = vector(mode = "character", length = length(param_cols)),
    outliers = vector(mode = "integer", length = length(param_cols))
  )

for(i in 1:length(param_cols)) {
  col <- param_cols[i]
  outliers <-
    as.logical(performance::check_outliers(subject_data[[col]],
                                           method = "zscore_robust",
                                           threshold = qnorm(0.9999)))
  subject_data[outliers, col] <- NA
  df_outliers$param_cols[i] <- col
  df_outliers$outliers[i] <-
    insight::format_value(sum(outliers) / nrow(data))
  cat(
    paste0(
      "\n-",
      col,
      ": ",
      sum(outliers),
      " outliers (",
      insight::format_value(sum(outliers) / nrow(data), as_percent = TRUE),
      ") detected and removed."
    )
  )
}

# Save cleaned data
write_csv(subject_data, "data_clean/MotherShip3.csv")


# data[param_cols] %>%
#   normalize() %>%
#   estimate_density() %>%
#   plot() +
#   facet_wrap( ~ Parameter, scales = "free") +
#   theme(
#     legend.position = "none",
#     axis.title.x = element_blank(),
#     axis.title.y = element_blank(),
#     axis.text.y = element_blank()
#   )
# 
# cat(
#   paste0(
#     "\n-On average, " ,
#     insight::format_value(sum(as.double(
#       df_outliers$outliers
#     )) / length(param_cols), as_percent = TRUE),
#     " of data was detected as outliers and removed."
#   )
# )
