function topothis(cfg_eeg,data,time,plotinterval)
result.B = data;
result.clusters.time = time;
pathfig = [];
collimb = [];
half = 0;
plotBetasTopos(cfg_eeg,result,'median',pathfig,plotinterval,collimb,half)