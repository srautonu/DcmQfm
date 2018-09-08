#########################################################
# For writing to R window comment out the following line
# in each graph
# theme_bw(base_size = 18, base_family = "") +
#########################################################

library(ggplot2)

algoNames = c("MRP", "ASTRAL", "DCM2QFM", "DCM5QFM");
geneLengths = c("250b", "500b", "1000b", "true");

algoNames2 = c("MRP", "ASTRAL", "DCM2-QFM", "DCM5-QFM");
geneLengths2 = c("250bp", "500bp", "1,000bp", "true-tree");

fnData = NULL;

for (i in 1:length(geneLengths)) {
  fileName = paste0("noscale.200g.", geneLengths[i], ".csv");
  data = read.csv(fileName);

  for (j in 1:length(algoNames)) {
    fnCol = paste(algoNames[j], "FN", sep="_");
    temp = data.frame(
              algo = rep(algoNames2[j], length(data[,1])),
              bp = rep(geneLengths2[i], length(data[,1])), 
              fn = data[,fnCol]
              );
    fnData = rbind(fnData, temp);
  }
}

# grouped boxplot
plot = ggplot(fnData, aes(x=bp, y=fn, fill=algo))
plot = plot + 
    theme_bw(base_size = 18, base_family = "") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    theme(legend.title = element_blank()) +
    theme(aspect.ratio = 0.6) +
    geom_boxplot() +
    labs(x = "sequence length", y = "FN rate")


postscript(file = "noscale_200g_varB.eps", paper = "letter");
print(plot + scale_fill_grey(start = 0, end = 0.6));
dev.off();


# One box per gene length
#plot + geom_boxplot() + facet_wrap(~bp, scale="free")

# One box per gene length
#plot + geom_boxplot() + facet_wrap(~algo)
