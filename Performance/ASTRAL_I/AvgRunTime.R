
rtQFMFiles = c(
  "rtQFM_scale5d.200g.500b.txt",
  "rtQFM_scale2d.200g.500b.txt",
  "rtQFM_noscale.200g.500b.txt",
  "rtQFM_scale2u.200g.500b.txt",
  "rtQFM_noscale.50g.500b.txt",
  "rtQFM_noscale.100g.500b.txt",
  "rtQFM_noscale.400g.500b.txt",
  "rtQFM_noscale.800g.500b.txt",
  "rtQFM_noscale.200g.250b.txt",
  "rtQFM_noscale.200g.1000b.txt",
  "rtQFM_noscale.200g.true.txt"
  );

rtDcmQfmFiles = c(
  "rtDcmQfm_scale5d.200g.500b.txt",
  "rtDcmQfm_scale2d.200g.500b.txt",
  "rtDcmQfm_noscale.200g.500b.txt",
  "rtDcmQfm_scale2u.200g.500b.txt",
  "rtDcmQfm_noscale.50g.500b.txt",
  "rtDcmQfm_noscale.100g.500b.txt",
  "rtDcmQfm_noscale.400g.500b.txt",
  "rtDcmQfm_noscale.800g.500b.txt",
  "rtDcmQfm_noscale.200g.250b.txt",
  "rtDcmQfm_noscale.200g.1000b.txt",
  "rtDcmQfm_noscale.200g.true.txt"
);


for (i in 1:length(rtQFMFiles)) {
  qfmFile = rtQFMFiles[i];
  dcmQfmFile = rtDcmQfmFiles[i];


  data = read.csv(qfmFile);
  qfmAvg = round(mean(data[,1]/60),2);

  data = read.csv(dcmQfmFile);
  dcmQfmSAvg = round(mean(data[,1]/60),2);
  dcmQfmPAvg = round(mean(data[,2]/60),2);
  
  
  cat(qfmFile, "        & ", qfmAvg, "  & ", dcmQfmSAvg, "         & ", dcmQfmPAvg, " \\\\ \\hline %", round(qfmAvg/dcmQfmSAvg, 1), round(qfmAvg/dcmQfmPAvg, 1), "\n");
}