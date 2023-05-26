function [value,sample] = range_artifact(cfg,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [value,sample] = range_artifact(cfg)
% Reads the respective eeg file (cfg.filename) and calculates the rang
% for al channels in a moving window of length
% (cfg.clean_movwin_length, in seconds) and moving steps of (cfg.clean_mov_step, in seconds)
% value     - the range values for the respective channelxsample
% sample    - samples in eeg time where the moving window are centered
%
% JPO, OSNA, 27.03.13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

winl                            = cfg.clean_movwin_length;
step                            = cfg.clean_mov_step;

hdr                             = ft_read_header([cfg.eegfolder, cfg.filename, '.vhdr']);
cfge                            = basic_preproc_cfg(cfg,[cfg.filename, '.vmrk'],varargin{:});
% process data in segment of ~100MB for fs = 1000 hz which is around 3 min
% to get it overlap we need to make it overlapping the size of the moving
% window
segl                            = 201;        % in seconds, make it a multipe of step
toi                             = 0:step:segl-cfg.clean_mov_step;

% segment to cut, taking care that they will overlap
times                           = winl*hdr.Fs:segl*hdr.Fs:hdr.nSamples;
if hdr.nSamples-times(end)<winl*hdr.Fs % in case the rest is shorther than winl 
    times(end) = [];
end

if strcmp(cfg.clean_ica_correct,'yes')
   load([cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'])
end
sample                  = [];
value                   = [];
ixx = 1;
for t = times
    sprintf('Processing %d/%d segments \n',ixx,length(times))
    ixx = ixx + 1;
    if t~=times(end)
       cfge.trl         = [t-winl*hdr.Fs/2 t+segl*hdr.Fs+winl*hdr.Fs -winl*hdr.Fs/2];
    else
       cfge.trl         = [t-winl*hdr.Fs/2 hdr.nSamples -winl*hdr.Fs/2];
       toi              = 0:step:-winl+(cfge.trl(2)-cfge.trl(1)+cfge.trl(3))./hdr.Fs;
    end
    data                = ft_preprocessing(cfge);
    old_label           = data.label;
    [cfg, data]         = correct_channels(cfg, data);
    if strcmp(cfg.clean_ica_correct,'yes')
         data                = ICAremove(data,cfg_ica,unique([cfg_ica.comptoremove;cfg_ica.comptoremove_m]),data.label,[],[]);               % removing of eye artifact ICA compo% removing of eye artifact ICA components
    end
    aux_value           = nan(length(old_label),length(toi));
    local_time          = zeros(1,length(toi));
    time2               = round(1000*data.time{1});  % unfortunate rounding errors 
    toi2                = round(1000*toi);
    [c,ia]              = intersect(old_label,data.label);
    ia                  = sort(ia);
    for e=1:length(toi)
        center_e        = find(time2==toi2(e),1,'first'); 
        for ch = 1:size(data.trial{1},1)                                                                % check for linear trends
            p                       = polyfit([center_e-winl*hdr.Fs/2:center_e+winl*hdr.Fs/2]./hdr.Fs,...  % it is important that the fit is with respect to time and not to sample, otherwise it is in a diiferent range for different Fs
                data.trial{1}(ch,center_e-winl*hdr.Fs/2:center_e+winl*hdr.Fs/2),1);
            aux_value(ia(ch),e)     = abs(p(1));
        end
        local_time(e)   = data.time{1}(center_e);
    end
    value               = [value aux_value];
    sample              = [sample  round(cfge.trl(1)-cfge.trl(3)+local_time*hdr.Fs)];  % rounding error in matlab!!!!
end

%test
% figure
% chan=55
%  figure,plot(data.time{1}+(cfge.trl(1)-cfge.trl(3))/hdr.Fs,data.trial{1}(chan,:))
%  hold on
%  plot(round(cfge.trl(1)-cfge.trl(3)+local_time*hdr.Fs)/hdr.Fs,aux_value(chan,:),'r')