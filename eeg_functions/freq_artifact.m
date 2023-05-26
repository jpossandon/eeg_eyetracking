function [value,sample,chann_label] = freq_artifact(cfg,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [value,sample] = freq_artifact(cfg,mov_step,win_length,foi)
% Reads the respective eeg file (cfg.filename) and calculates the total
% power for (cfg.foi) frequencies for all channels with a moving window of length
% (cfg.win_length, in seconds) and moving steps of (cfg.mov_step, in seconds)
% value     - the power values for the respective channelxsample
% sample    - samples in eeg time where the moving window are centered
%
% JPO, OSNA, 27.03.13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


win_length                      = cfg.clean_movwin_length;
mov_step                        = cfg.clean_mov_step;
foi                             = cfg.clean_foi;
hdr                             = ft_read_header([cfg.eegfolder, cfg.filename, '.vhdr']);
cfge                            = basic_preproc_cfg(cfg,[cfg.filename, '.vmrk'],varargin{:});
% process data in segment of ~100MB for fs = 1000 hz which is around 3 min
% to get it overlap we need to make it overlapping the size of the moving
% window (this is for 64 channel data)
segl                            = 30;        % in seconds, make it multipe of mov_step

% fourier parameters
cfgf                            = [];
cfgf.method                     = 'mtmconvol';
cfgf.output                     = 'pow';
cfgf.foi                        = foi;
cfgf.t_ftimwin                  = win_length*ones(1,length(cfgf.foi));
cfgf.taper                      = 'hanning';
cfgf.toi                        = 0:mov_step:segl-mov_step;

if strcmp(cfg.clean_ica_correct,'yes')
   load([cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'])
end
% segment to cut, taking care that they will overlap
times                           = win_length*hdr.Fs:segl*hdr.Fs:hdr.nSamples;
if hdr.nSamples-times(end)<win_length*hdr.Fs % in case the rest is shorther than win_length 
    times(end) = [];
end

sample                  = [];
value                   = [];
ixx = 1;
for t = times
    sprintf('Processing %d/%d segments \n',ixx,length(times))
    ixx = ixx + 1;
    if t~=times(end)
       cfge.trl         = [t-win_length*hdr.Fs/2 t+segl*hdr.Fs+win_length*hdr.Fs -win_length*hdr.Fs/2];
    else
       cfge.trl         = [t-win_length*hdr.Fs/2 hdr.nSamples -win_length*hdr.Fs/2];
       cfgf.toi         = 0:mov_step:-win_length+(cfge.trl(2)-cfge.trl(1)+cfge.trl(3))./hdr.Fs;
    end
    cfge.padding        = segl+2;
    data                = ft_preprocessing(cfge);
    old_label           = data.label;
    [cfg, data]         = correct_channels(cfg, data);
    if strcmp(cfg.clean_ica_correct,'yes')
        data                = ICAremove(data,cfg_ica,unique([cfg_ica.comptoremove;cfg_ica.comptoremove_m]),data.label,[],[]);               % removing of eye artifact ICA components
    end
    [freq]                  = ft_freqanalysis(cfgf, data);
    [c,ia]                  = intersect(old_label,freq.label);              % this works. intersect gives sorted output s it need to be rearrenfe in the next lines
    stupid_aux              = nan(length(old_label),length(freq.time));
    stupid_aux(sort(ia),:)  =  squeeze(sum(freq.powspctrm,2));
    value                   = [value stupid_aux];
    sample                  = [sample  round(cfge.trl(1)-cfge.trl(3)+freq.time*hdr.Fs)];  % rounding error in matlab!!!!
end
% label = prearti.label;

% % % test
% chan = 64
%  figure,plot(data.time{1}+cfge.trl(1)/1000-cfge.trl(3)/1000,data.trial{1}(chan,:))
% hold on
% plot(sample/1000,value(chan,:),'r')