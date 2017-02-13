function stat = freqpermBT(data1,data2,elec,rep)

cfgst = [];
% cfgst.channel          = {'MEG', '-MLP31', '-MLO12'};
cfgst.latency          = 'all';
% cfgst.frequency        = 20;
cfgst.method           = 'montecarlo';
cfgst.statistic        = 'ft_statfun_indepsamplesT';
cfgst.correctm         = 'cluster';
cfgst.clusteralpha     = 0.05;
cfgst.clusterstatistic = 'maxsum';%'wcm';%
cfgst.minnbchan        = 2;
cfgst.tail             = 0;
cfgst.clustertail      = 0;
cfgst.alpha            = 0.025;
cfgst.numrandomization = rep;
% cfgst.clusterthreshold = 'nonparametric_individual';
% prepare_neighbours determines what sensors may form clusters
cfgst_neighb.method    = 'distance';
cfgst.neighbours       = elec.neighbours;

design = zeros(1,size(data1.powspctrm,1) + size(data2.powspctrm,1));
design(1,1:size(data1.powspctrm,1)) = 1;
design(1,(size(data1.powspctrm,1)+1):(size(data1.powspctrm,1)+...
  size(data2.powspctrm,1))) = 2;

cfgst.design           = design;
cfgst.ivar             = 1;

[stat] = ft_freqstatistics(cfgst, data1, data2);