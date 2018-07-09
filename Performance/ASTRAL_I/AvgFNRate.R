#########################################################
# For writing to R window comment out the following line
# in each graph
# theme_bw(base_size = 36, base_family = "") +
#########################################################

fileName = c(
  "scale5d.200g.500b.csv",
  "scale2d.200g.500b.csv",
  "noscale.200g.500b.csv",
  "scale2u.200g.500b.csv",
  "noscale.50g.500b.csv",
  "noscale.100g.500b.csv",
  "noscale.400g.500b.csv",
  "noscale.800g.500b.csv",
  "noscale.200g.250b.csv",
  "noscale.200g.1000b.csv",
  "noscale.200g.true.csv"
  );

for (file in fileName) {
  
  data = read.csv(file);
  cat(file, " ", round(mean(data$QFM_FN),4), "\n")
  
}