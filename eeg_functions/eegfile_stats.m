function stat = eegfile_stats(cfg, data_chunk_size,varargin)  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function eegfile_stats(cfg, event_file, data_chunk_size)    
%
% Calculates statistics (range, variance, kurtosis, trend entropy, low- and high-gamma)
% of data chunks size data_chunk_size
% Data chunks are obtained from:
%   cfg.datastats   = 'all', over the complete eeg data file from the first to the
%                  last event in the corresponding event file
%                   = 'events', chunks taken from segments around certain
%                   event type between cfg.trialtime(1) and
%                   cfg.trialtime(3)
%                   = 'given', chunks of data taken from segments given in
%                   a varargin matrix in which column 1 and 2 represent the
%                   segments start and end time respectively (in eeg sample time)
%   Output is a stat structure with field for each measure containing
%   matrices with measure values for nchansxsegments and the corresponding
%   trl structure
%
% JPO, OSNA 02/08/2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg                             = correct_channels(cfg);  %if we need to correct for changed or dead files
event                           = ft_read_event([cfg.eegfolder, cfg.filename, '.vmrk']);
hdr                             = ft_read_header([cfg.eegfolder, cfg.filename, '.vhdr']);
if strcmp(cfg.datastats,'all')
    starts                      = [event(2).sample:data_chunk_size:event(end).sample]';        % we look at data between first and last trigger
elseif strcmp(cfg.datastats,'events')
    startsaux = [];
    for e=1:length(cfg.trial_trig_eeg)
        indxevents                  = find(strcmp(cfg.trial_trig_eeg{e}, {event.value}));
        samples                     = [event.sample];
        startsaux                   = [startsaux;samples(indxevents)'];
    end
    startsaux=sort(startsaux);
elseif strcmp(cfg.datastats,'given')
    if isempty(varargin)
        error('''Given'' option requires input times')
    else
        startsaux                      = varargin{1};
    end
end
cfge                            = basic_preproc_cfg(cfg,[cfg.filename, '.vmrk']);
cfge.continuous                 = 'yes';
if strcmp(cfg.datastats,'events') 
     starts = [];
     chunksper = (cfg.trial_time(2)-cfg.trial_time(1))./data_chunk_size;
     for e = 1:length(startsaux)
         starts = [starts;[startsaux(e)+cfg.trial_time(1):data_chunk_size:startsaux(e)+chunksper*data_chunk_size]'];
     end
elseif strcmp(cfg.datastats,'given')
    starts = [];
    if size(startsaux,1)==1
        starts = [starts;[startsaux(1,1):data_chunk_size:startsaux(1,2)]'];
    else
        for e = 1:size(startsaux,1)
            if e==size(startsaux,1) && startsaux(e,2)+cfg.trial_time(2)*hdr.Fs/1000+1000>hdr.nSamples
                starts = [starts;[startsaux(e,1)-30000*hdr.Fs/1000:data_chunk_size:hdr.nSamples-data_chunk_size]'];
            elseif e==1 && startsaux(e,1)-30000*hdr.Fs/1000<1
                starts = [starts;[1:data_chunk_size:startsaux(e,2)+cfg.trial_time(2)*hdr.Fs/1000]'];
            else
                starts = [starts;[startsaux(e,1)-30000*hdr.Fs/1000:data_chunk_size:startsaux(e,2)+cfg.trial_time(2)*hdr.Fs/1000]'];
            end
        end    
    end
end
trl                             = [starts,starts+data_chunk_size-1,zeros(length(starts),1)];
    
    
% process data by steps of ~ 100MB
steps = 1:150:length(trl);
n = 1;
stat.theta = [];stat.beta = [];stat.gamma = [];stat.up = [];
for ip = steps
    if ip == steps(end)
        cfge.trl                        =  trl(ip:end,:);
    else
        cfge.trl                        =  trl(ip:ip+149,:); 
    end
    data                                = ft_preprocessing(cfge);
    if ~isempty(cfg.correct_chan)                                           % in case channels are changed
        for ip=1:length(data.trial)
            data.trial{ip}    = data.trial{ip}(cfg.correct_chan,:);
        end
    end
    cfgf.method                   = 'mtmfft';
    cfgf.output                   = 'pow';
    cfgf.taper                    = 'dpss';
    cfgf.tapsmofrq                = 4;
    cfgf.foi                      = 30:2:120;
    cfgf.keeptrials               = 'yes';
    [freq]                        = ft_freqanalysis(cfgf, data);
%     stat.freq                          = cat(1,stat.freq,freq.powspctrm);
%     stat.theta                        = cat(2,stat.theta,mean(freq.powspctrm(:,:,1:5),3)');
%     stat.beta                        = cat(2,stat.beta,mean(freq.powspctrm(:,:,6:15),3)');
    stat.gamma                    = cat(2,stat.gamma,mean(freq.powspctrm(:,:,1:26),3)');
    stat.up                       = cat(2,stat.up,mean(freq.powspctrm(:,:,26:end),3)');
    for e = 1:length(data.trial)
        stat.absolute_range(:,n)            = max(data.trial{e},[],2)-min(data.trial{e},[],2);          % segment absolut amplitude distribution
        stat.check(:,n)                     = std(data.trial{e},0,2);                                   % segments std distribution
        stat.kurtosis(:,n)                  = kurtosis(data.trial{e},0,2);                              % segments kurtosis distribution
        for ch = 1:size(data.trial{e},1)                                                                % check for linear trends
            p                               = polyfit(1:size(data.trial{e},2),data.trial{e}(ch,:),1);
            stat.trend(ch,n)                = p(1);
            ni                               = histc(data.trial{e}(ch,:),-200:1:200);
            prob                            = .0000000000001+ni./sum(ni);                               
            stat.entropy(ch,n)              = -sum(prob.*log2(prob));
        end
        n=n+1;
    end
end
% if ~isempty(cfg.elim_chan)                                           % in case channels were dead
% %     stat.freq(:,cfg.elim_chan,:)            =NaN;
%     stat.absolute_range(cfg.elim_chan,:)    =NaN;
%     stat.check(cfg.elim_chan,:)             =NaN;
%     stat.kurtosis(cfg.elim_chan,:)          =NaN;
% end
stat.trl                        = trl;
stat.chunksize                  = data_chunk_size;
