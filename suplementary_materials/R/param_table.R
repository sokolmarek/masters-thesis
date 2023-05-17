name <- "MotherShip3"
s1 <- filter(hourly_rmssd, id == name)
s2 <- filter(hourly_pnn50, id == name)
s3 <- filter(hourly_sdnn, id == name)
s4 <- filter(hourly_hf, id == name)

idx <- 1

d1 <- c(
  mean(subset(s1, day == idx)$HRV_RMSSD, na.rm = TRUE),
  sd(subset(s1, day == idx)$HRV_RMSSD, na.rm = TRUE),
  mean(subset(s1, day == 4)$HRV_RMSSD, na.rm = TRUE),
  sd(subset(s1, day == 4)$HRV_RMSSD, na.rm = TRUE),
  mean(subset(s1, day == 8)$HRV_RMSSD, na.rm = TRUE),
  sd(subset(s1, day == 8)$HRV_RMSSD, na.rm = TRUE)
)

d2 <- c(
mean(subset(s2, day == idx)$HRV_pNN50, na.rm = TRUE),
sd(subset(s2, day == idx)$HRV_pNN50, na.rm = TRUE),
mean(subset(s2, day == 4)$HRV_pNN50, na.rm = TRUE),
sd(subset(s2, day == 4)$HRV_pNN50, na.rm = TRUE),
mean(subset(s2, day == 8)$HRV_pNN50, na.rm = TRUE),
sd(subset(s2, day == 8)$HRV_pNN50, na.rm = TRUE)
)

d3 <- c(
mean(subset(s3, day == idx)$HRV_SDNN, na.rm = TRUE),
sd(subset(s3, day == idx)$HRV_SDNN, na.rm = TRUE),
mean(subset(s3, day == 4)$HRV_SDNN, na.rm = TRUE),
sd(subset(s3, day == 4)$HRV_SDNN, na.rm = TRUE),
mean(subset(s3, day == 8)$HRV_SDNN, na.rm = TRUE),
sd(subset(s3, day == 8)$HRV_SDNN, na.rm = TRUE)
)

d4 <- c(
mean(subset(s4, day == idx)$HRV_HF, na.rm = TRUE),
sd(subset(s4, day == idx)$HRV_HF, na.rm = TRUE),
mean(subset(s4, day == 4)$HRV_HF, na.rm = TRUE),
sd(subset(s4, day == 4)$HRV_HF, na.rm = TRUE),
mean(subset(s4, day == 8)$HRV_HF, na.rm = TRUE),
sd(subset(s4, day == 8)$HRV_HF, na.rm = TRUE)
)

cat(paste(round(d3, 2), collapse = " & "))
cat(paste(round(d1, 2), collapse = " & "))
cat(paste(round(d2, 2), collapse = " & "))
cat(paste(round(d4, 2), collapse = " & "))
