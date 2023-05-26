function [cfg_ica] = icaspectra(cfg, cfg_ica)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [cfg_ica] = icaspectra(cfg, cfg_ica)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

winlength           = 1;
hdr                 = ft_read_header([cfg.eegfolder, cfg.filename, '.vhdr']);
cfge                = basic_preproc_cfg(cfg,cfg.event,'lpfilter','yes','lpfreq',cfg.lpfreq);
trl                 = [1:winlength*hdr.Fs:hdr.nSamples-winlength*hdr.Fs-1]';
trl                 = [trl trl+winlength*hdr.Fs-1000/hdr.Fs zeros(length(trl),1)];

[newtrl,toelim]     = clean_bad(cfg,trl); 
if size(newtrl,1)>1000    % spectra is estimated over 1000 or all if less
    try
        sampletrl           = randsample(1:size(newtrl,1),1000);
    catch
        sampletrl           = randsamplex(1:size(newtrl,1),1000);
    end
        cfge.trl            = newtrl(sampletrl,:);
else
    cfge.trl            = newtrl;
end

data                 = ft_preprocessing(cfge);
data                 = ft_componentanalysis(cfg_ica, data);

cfgf                 = [];
cfgf.method          = 'mtmfft';
cfgf.output          = 'pow';
cfgf.foilim          = [1 100];
cfgf.taper           = 'hanning';

[freq]               = ft_freqanalysis(cfgf,data);

cfg_ica.powspectra          = freq.powspctrm;
cfg_ica.spectra_f           = freq.freq;
cfg_ica.spectra_ratio20100  = sum(freq.powspctrm(:,freq.freq>20),2)./sum(freq.powspctrm(:,freq.freq<20),2);
cfg_ica.spectra_powerover20 = sum(freq.powspctrm(:,freq.freq>20),2);

cfg_ica.comptoremove_m      = [];
for comp = 1:size(cfg_ica.powspectra,1)
    [b,bint,r,rint,stats]           = regress(log(cfg_ica.powspectra(comp,:))',[ones(length(cfg_ica.spectra_f),1) log(cfg_ica.spectra_f)']);
    cfg_ica.comp_1overf_alpha(comp) = b(2);
    cfg_ica.comp_1overf_R2(comp)    = stats(1);
    if cfg_ica.spectra_ratio20100(comp)>=cfg.ratio20thresh %%cfg_ica.comp_1overf_R2(comp)<.65 && 
        cfg_ica.comptoremove_m      = [cfg_ica.comptoremove_m;comp];
    end
end
% 
% 
% for tt = 1:length(data.trial)
 
% cfgf                 = [];
% cfgf.method          = 'mtmfft';
% cfgf.output          = 'pow';
% cfgf.foilim          = [1 100];
% cfgf.taper           = 'hanning';
%    cfgf.trials = tt ;
% [freq]               = ft_freqanalysis(cfgf,data);
% allfreq(tt,:)              = freq.powspctrm(7,:);
% end
% figure,imshow(allfreq,[])