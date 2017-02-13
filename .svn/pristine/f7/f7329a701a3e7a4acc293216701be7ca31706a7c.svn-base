function [bad,badchans,channelbad] = badsegments(cfg,values,indexs,threshold)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [bad,badchans,channelbad] = badsegments(cfg,values,indexs,threshold)
% this function is used together with the functions that measure different
% data properties at different time intervals (freq_artifact.m,
% range_artifact.m and trend_artifact.m) and it determines which segments
% are bad according to the threshold variable
%
% INPUT -
%            cfg        - structure with file and cleaning specs
%            values     - feature values (e.g frequency, range, trend)
%            indexes    - eeg sample at the center of the intervals
%                          from where values were obtained
%            threshold  - value considered bad for the analyzed feature, if
%            it is a single value, the function will report as bad segments
%            the one with feature values>threshold. if it is two
%            value, reported bad segment with values<threshold(1) and values>threshold(2)
%
% OUTPUT
%            bad            - matrix with two columns, each row is a bad eeg
%                               segment start and end times in eeg samples
%            badchans       - matrix [chan x size(bad,1)], that indicates
%                           which channel(s) was the one with a feature
%                           value beyond the threshold
%            channelbad     - cell array of length equalt to number of
%                               channels, each cell entry is like 'bad'
%                               above but for the specific channel
% JPO, OSNA,somewhen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hdr                 = ft_read_header([cfg.eegfolder, cfg.filename, '.vhdr']);
borders             = cfg.clean_movwin_length*hdr.Fs./2;
step                = cfg.clean_mov_step*hdr.Fs;
% check if there is a channel to remove
cfg = correct_channels(cfg);

if ~isempty(cfg.elim_chan)
    values(cfg.elim_chan,:) = NaN;
end
if length(threshold)>1
    badg            = values<threshold(1) | values>threshold(2);             % set channels and segments of data that are higher than threshold to zero
else
    badg            = values>threshold;             % set channels and segments of data that are higher than threshold to zero
end

for e = 1:size(badg,1)
    init_rem            = find(badg(e,:)>0);            % get indexs of bad data independtly of how many bad channels
    pre_bad_sample      = indexs(init_rem);             % get the actual samples that are bad

    if cfg.clean_exclude_eye == 1 && ~isempty(pre_bad_sample)                   % if we do not take in account bad segments when there is an eye movement
        load([cfg.eyeanalysisfolder cfg.filename 'eye'],'eyedata')
        eyemov          = [eyedata.events.start(eyedata.events.type>1)',eyedata.events.end(eyedata.events.type>1)'];   % movements types that are not fixations
        bad_witheye     = [];
            for ei = 1:size(eyemov,1)                    % finds the samples that are bad but that are within an eye movement so they do not need to be removed
                bad_witheye     = union(bad_witheye,find(pre_bad_sample>eyemov(ei,1)-borders & pre_bad_sample<eyemov(ei,2)+borders));
            end
        pre_bad_sample(bad_witheye)  = [];
        init_rem(bad_witheye)        = [];
    end
%     pre_bad_channels    = badg(:,init_rem);             % a matrix with rows as channels and columns as bad samples there are. the channels that are the cause of this segments to be bad are 1  

    % here we generate the output which is the continuous segments of bad
    % samples and the respective bad channels
    if ~isempty(pre_bad_sample)
            segments            = find(diff(pre_bad_sample)>step);
        if ~isempty(segments)
            bad                 = [pre_bad_sample(1),pre_bad_sample(segments(1));...
                            pre_bad_sample(segments(1:end-1)+1)',pre_bad_sample(segments(2:end))';...
                            pre_bad_sample(segments(end)+1),pre_bad_sample(end)];
            bad                 = [bad(:,1)-borders bad(:,2)+borders];
        else
            bad                 = [pre_bad_sample(1)-borders pre_bad_sample(end)+borders];
        end
        channelbad{e}       = bad;
    else
        channelbad{e}       = [];
    end
end

init_rem            = find(sum(badg)>0);            % get indexs of bad data independtly of how many bad channels
pre_bad_sample      = indexs(init_rem);             % get the actual samples that are bad
chan_ratio          = sum(badg>0,2)./size(badg,2);

if cfg.clean_exclude_eye == 1                    % if we do not take in account bad segments when there is an eye movement
    load([cfg.eyeanalysisfolder cfg.filename 'eye'],'eyedata')
    eyemov          = [eyedata.events.start(eyedata.events.type>1)',eyedata.events.end(eyedata.events.type>1)'];   % movements types that are not fixations
    bad_witheye     = [];
        for e = 1:size(eyemov,1)                    % finds the samples that are bad but that are within an eye movement so they do not need to be removed
            bad_witheye     = union(bad_witheye,find(pre_bad_sample>eyemov(e,1)-borders & pre_bad_sample<eyemov(e,2)+borders));
        end
    pre_bad_sample(bad_witheye)  = [];
    init_rem(bad_witheye)        = [];
end
pre_bad_channels    = badg(:,init_rem);             % a matrix with rows as channels and columns as bad samples there are. the channels that are the cause of this segments to be bad are 1  

% here we generate the output which is the continuous segments of bad
% samples and the respective bad channels
if ~isempty(pre_bad_sample)
segments            = find(diff(pre_bad_sample)>step);
    if ~isempty(segments)
        bad                 = [pre_bad_sample(1),pre_bad_sample(segments(1));...
                            pre_bad_sample(segments(1:end-1)+1)',pre_bad_sample(segments(2:end))';...
                            pre_bad_sample(segments(end)+1),pre_bad_sample(end)];
        bad                 = [bad(:,1)-borders bad(:,2)+borders];  
        badchans            = sum(pre_bad_channels(:,1:segments(1)),2)>0;
        for e = 1:length(segments)-1
            badchans        = [badchans,sum(pre_bad_channels(:,segments(e)+1:segments(e+1)),2)>0];
        end
        badchans            = [badchans,sum(pre_bad_channels(:,segments(end)+1:end),2)>0];
        [bad,badchans]      = combine_bad({bad},{badchans},cfg.clean_minclean_interval);
    else
        bad                 = [pre_bad_sample(1)-borders pre_bad_sample(end)+borders];
        badchans            = sum(pre_bad_channels,2)>0;
    end
else
    bad =[];
    badchans = logical([]);
end
    
