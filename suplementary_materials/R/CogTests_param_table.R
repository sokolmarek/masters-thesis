name <- "Lander1"
s1 <- filter(data, id == name)
s2 <- filter(data, id == name)
s3 <- filter(data, id == name)
s4 <- filter(data, id == name)

idx <- 1

d1 <- c(
  mean(subset(s1, day == 1)$rmssd, na.rm = TRUE),
  sd(subset(s1, day == 1)$rmssd, na.rm = TRUE),
  mean(subset(s1, day == 3)$rmssd, na.rm = TRUE),
  sd(subset(s1, day == 3)$rmssd, na.rm = TRUE),
  mean(subset(s1, day == 5)$rmssd, na.rm = TRUE),
  sd(subset(s1, day == 5)$rmssd, na.rm = TRUE)
)

d2 <- c(
  mean(subset(s2, day == 1)$pnn50, na.rm = TRUE),
  sd(subset(s2, day == 1)$pnn50, na.rm = TRUE),
  mean(subset(s2, day == 3)$pnn50, na.rm = TRUE),
  sd(subset(s2, day == 3)$pnn50, na.rm = TRUE),
  mean(subset(s2, day == 5)$pnn50, na.rm = TRUE),
  sd(subset(s2, day == 5)$pnn50, na.rm = TRUE)
)

d3 <- c(
  mean(subset(s3, day == 1)$sdnn, na.rm = TRUE),
  sd(subset(s3, day == 1)$sdnn, na.rm = TRUE),
  mean(subset(s3, day == 3)$sdnn, na.rm = TRUE),
  sd(subset(s3, day == 3)$sdnn, na.rm = TRUE),
  mean(subset(s3, day == 5)$sdnn, na.rm = TRUE),
  sd(subset(s3, day == 5)$sdnn, na.rm = TRUE)
)

d4 <- c(
  mean(subset(s4, day == 1)$hf, na.rm = TRUE),
  sd(subset(s4, day == 1)$hf, na.rm = TRUE),
  mean(subset(s4, day == 3)$hf, na.rm = TRUE),
  sd(subset(s4, day == 3)$hf, na.rm = TRUE),
  mean(subset(s4, day == 5)$hf, na.rm = TRUE),
  sd(subset(s4, day == 5)$hf, na.rm = TRUE)
)

cat(paste(round(d3, 2), collapse = " & "))
cat(paste(round(d1, 2), collapse = " & "))
cat(paste(round(d2, 2), collapse = " & "))
cat(paste(round(d4, 2), collapse = " & "))
