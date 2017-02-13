function plot_compTL(cfg,cfgs,data,interval)

load(cfg.chanfile)
cfge                = [];
cfge.elec           = elec;
cfge.rotate         = 0;
cfge.markers        = 'numbers';
cfge.comment        = 'no';
cfge.fontsize       = 8;

for c=1:length(cfgs{1}.comptoanal);
    figure
    for e = 1:length(cfgs)
        cfg = cfgs{e};
        load([cfg.analysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'],'cfg_ica') % ica weights
        cfg_ica.dimord      = 'chan_comp';
        cfge.component = abs(cfg.comptoanal(c));
        subplot(3,4,e)
        ft_topoplotER(cfge, cfg_ica);
        text(-.6,.8,sprintf('ICA,%d',cfg.comptoanal(c)));
    end
    subplot(3,4,[9 10 11 12])
    times = find(data.comp.time>interval(1) & data.comp.time<interval(2));
    plot(data.comp.time(times),data.comp.avg(c,(times)))
end


