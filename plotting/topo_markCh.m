function tp = topo_markCh(cfg,markCh)
    
load(cfg.chanlocs)
nchans = length(chanlocs);
load('cmapjp','cmap')
if iscellstr(markCh)
    markCh = find(ismember({chanlocs.labels},markCh));
end
tp = topoplot(zeros(nchans,1),chanlocs,'colormap',cmap,'emarker',{'.','k',5,1},'emarker2',{markCh,'.',[1 0 0],10,1},'whitebk','on','electrodes','on','headrad','rim');
axis([-.6 .6 -.6 .6])