#########################################################
# For writing to R window comment out the following line
# in each graph
# theme_bw(base_size = 18, base_family = "") +
#########################################################

library(ggplot2)

algoNames = c("MRL", "ASTRAL", "DCM2QFM", "DCM5QFM");
geneTrees = c("50", "100", "200", "400", "800");

algoNames2 = c("MRP", "ASTRAL", "DCM2-QFM", "DCM5-QFM");

fnData = NULL;

for (i in 1:length(geneTrees)) {
  fileName = paste0("noscale.", geneTrees[i], "g.500b.csv");
  data = read.csv(fileName);

  for (j in 1:length(algoNames)) {
    fnCol = paste(algoNames[j], "FN", sep="_");
    temp = data.frame(
              algo = rep(algoNames2[j], length(data[,1])),
              ntrees = rep(geneTrees[i], length(data[,1])), 
              fn = data[,fnCol]
              );
    fnData = rbind(fnData, temp);
  }
}

# grouped boxplot
plot = ggplot(fnData, aes(x=ntrees, y=fn, fill=algo))
plot = plot + 
    theme_bw(base_size = 18, base_family = "") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    theme(legend.title = element_blank()) +
    theme(aspect.ratio = 0.6) +
    geom_boxplot() +
    labs(x = "number of gene trees", y = "FN rate")

postscript(file = "noscale_varG_500b.eps", paper = "letter");
plot;
dev.off();


# One box per gene length
#plot + geom_boxplot() + facet_wrap(~bp, scale="free")

# One box per gene length
#plot + geom_boxplot() + facet_wrap(~algo)
