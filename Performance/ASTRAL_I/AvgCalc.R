#########################################################
# For writing to R window comment out the following line
# in each graph
# theme_bw(base_size = 36, base_family = "") +
#########################################################

fileName = c(
  "rtQFM_scale5d.200g.500b.txt",
  "rtQFM_scale2d.200g.500b.txt",
  "rtQFM_noscale.200g.500b.txt",
  "rtQFM_scale2u.200g.500b.txt",
  "rtQFM_noscale.50g.500b.txt",
  "rtQFM_noscale.100g.500b.txt",
  # "rtQFM_noscale.400g.500b.txt",
  "rtQFM_noscale.800g.500b.txt",
  "rtQFM_noscale.200g.250b.txt",
  "rtQFM_noscale.200g.1000b.txt",
  "rtQFM_noscale.200g.true.txt"
  );

for (file in fileName) {
  
  data = read.csv(file);
  avg = round(mean(data[,1]/60),2);
  cat("", avg, "\n")
}