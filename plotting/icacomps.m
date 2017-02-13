function icacomps(cfg,trl)

% load([cfg.eyeanalysisfolder cfg.EDFname 'eye'])         % eye data
cfge          = basic_preproc_cfg(cfg, cfg.event,'lpfilter','yes','lpfreq',100,'blc','yes');
cfge.trl      = double(trl);
data          = ft_preprocessing(cfge);                                      
load([cfg.analysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'],'cfg_ica') % ica weights
comp                       = ft_componentanalysis(cfg_ica, data);
% 
% all = cell2mat(comp.trial);
% for c = 1:length(cfg_ica.topolabel)
%     [Pxx0(c,:),f0] = pwelch(all(c,:),4*data.fsample,[],[],data.fsample);
%     [Pxx1(c,:),f1] = pwelch(all(c,:),2*data.fsample,[],[],data.fsample);
%     [Pxx2(c,:),f2] = pwelch(all(c,:),1*data.fsample,[],[],data.fsample);
%     [Pxx3(c,:),f3] = pwelch(all(c,:),.5*data.fsample,[],[],data.fsample);
% end

load(cfg.chanfile)
cfge                = [];
cfge.elec           = elec;
% cfge.rotate         = 0;
cfge.markers        = 'numbers';
cfge.comment        = 'no';
cfge.fontsize       = 8;
% set(gcf,'Position',[7 31 1428 770])
cfg_ica.dimord = 'chan_comp';
cfg_ica.topolabel = elec.label(6:end); % this need to be more general
% allow multiplotting
mkdir([cfg.analysisfolder 'ICAm/' cfg.sujid '/images/' cfg.filename ])
for selcomp = 1:length(cfg_ica.topolabel)
    figure
    subplot(1,2,1);
    cfge.component = selcomp;
    ft_topoplotER(cfge, cfg_ica);
    subplot(1,2,2);
    hold on
    h(1)    =   plot(f0(2:240),log(Pxx0(selcomp,2:240)));
    h(2)    =   plot(f1(2:120),log(Pxx1(selcomp,2:120)));
    h(3)    =   plot(f2(2:60),log(Pxx2(selcomp,2:60)),'r');
    h(4)    =   plot(f3(2:30),log(Pxx3(selcomp,2:30)),'k');
    ylim([-4 10])
    legend(h,'bw = 0.25 Hz','bw = 0.5 Hz','bw = 1 Hz','bw = 2 Hz')
    doimage(gcf,[cfg.analysisfolder 'ICAm/' cfg.sujid '/images/' cfg.filename '/'],'tiff',['comp_' num2str(selcomp)],1)


% % component source
% how to prject electrodes to vol?
load(cfg.volfile)
cfgs = [];
cfgs.numdipoles = 1;
cfgs.vol = vol;
cfgs.component = selcomp;
cfgs.elec = elec;
cfgs.inwardshift = 0;
 comp.topolabel = cfg_ica.topolabel
dip = ft_dipolefitting(cfgs,comp);
load(cfg.mrifile)
ft_sourceplot(cfg, mri)
% 
end