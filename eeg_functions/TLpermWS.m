function stat = TLpermWS(data1,data2,elec,rep)

%%%%%%%%%%%%%%%%%
% script to dperform whithin subjects comparision between two conditions
% data1 and data2 are fieldtrip ft_timelockgrandaverage structures
% (eg, data1 = ft_timelockgrandaverage(cfg, avg1, avg2, avg3, ...), with
% cfg.keepindividual = 'yes' and each avg# corresponding to the timelock 
% average structure of one subject)
% elec is the fieldtrip electrode structure
% rep is the number of permutation (e.g., 1000)


cfgst = [];
% cfgst.channel          = {'MEG', '-MLP31', '-MLO12'};
cfgst.latency          = 'all';
% cfgst.frequency        = 20;
cfgst.method           = 'montecarlo';
cfgst.statistic        = 'ft_statfun_depsamplesT';
cfgst.correctm         = 'cluster';
cfgst.clusteralpha     = 0.05;
cfgst.clusterstatistic = 'maxsum';%'wcm';%
cfgst.minnbchan        = 1;
cfgst.tail             = 0;
cfgst.clustertail      = 0;
cfgst.alpha            = 0.025;
cfgst.numrandomization = rep;
% cfgst.clusterthreshold = 'nonparametric_individual';
% prepare_neighbours determines what sensors may form clusters
cfgst_neighb.method    = 'distance';
cfgst.neighbours       = elec.neighbours;

subj = size(data1.individual,1);
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfgst.design   = design;
cfgst.uvar     = 1;
cfgst.ivar     = 2;


[stat] = ft_timelockstatistics(cfgst, data1, data2);