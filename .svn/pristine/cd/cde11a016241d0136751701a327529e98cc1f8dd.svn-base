function plot_topos_TFR(cfg,data,times,freqs,baseline,collim)

load(cfg.chanfile)
cfgp = [];
cfgp.showlabels = 'no'; 
cfgp.fontsize = 12; 
cfgp.elec = elec;
cfgp.rotate = 0;
cfgp.interactive = 'yes';
cfgp.baseline      = baseline;
cfgp.baselinetype     = 'relative';
cfgp.ylim = freqs;
cfgp.zlim = collim;
tiempos = times(1):times(3):times(2)-times(3);

figure
set(gcf,'Position', [7 31 1428 770])
numsp = 1;
for t = tiempos
     subplot(ceil(sqrt(length(tiempos))),ceil(sqrt(length(tiempos))),numsp)
     cfgp.xlim=[t t+times(3)];
     cfgp.comment = 'xlim'; 
     cfgp.commentpos = 'title'; 
     ft_topoplotTFR(cfgp, data); 
     numsp = numsp +1;
end
