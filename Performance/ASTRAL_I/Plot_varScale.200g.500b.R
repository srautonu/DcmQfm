#########################################################
# For writing to R window comment out the following line
# in each graph
# theme_bw(base_size = 18, base_family = "") +
#########################################################

library(ggplot2)

algoNames = c("MRL", "ASTRAL", "DCM2QFM", "DCM5QFM");
ILS = c("scale5d", "scale2d", "noscale", "scale2u");

algoNames2 = c("MRP", "ASTRAL", "QFM(DACTAL,2)", "QFM(DACTAL,5)");
ILS2 = c("0.2X", "0.5X", "1X", "2X");

fnData = NULL;

for (i in 1:length(ILS)) {
  fileName = paste0(ILS[i], ".200g.500b.csv");
  data = read.csv(fileName);

  for (j in 1:length(algoNames)) {
    fnCol = paste(algoNames[j], "FN", sep="_");
    temp = data.frame(
              algo = rep(algoNames2[j], length(data[,1])),
              ils = rep(ILS2[i], length(data[,1])), 
              fn = data[,fnCol]
              );
    fnData = rbind(fnData, temp);
  }
}

# grouped boxplot
plot = ggplot(fnData, aes(x=ils, y=fn, fill=algo))
plot = plot + 
    theme_bw(base_size = 18, base_family = "") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    theme(legend.title = element_blank()) +
    theme(aspect.ratio = 0.6) +
    geom_boxplot() +
    labs(x = "species tree branch length", y = "FN rate")

postscript(file = "varScale_200g_500b.eps", paper = "letter");
plot;
dev.off();


# One box per gene length
#plot + geom_boxplot() + facet_wrap(~bp, scale="free")

# One box per gene length
#plot + geom_boxplot() + facet_wrap(~algo)
