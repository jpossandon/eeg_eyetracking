function eeg_subject_stats(event_file)  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function eeg_population_stats(cfg, cfg.EDFname, cfg.event)  
%
% calculates statistics over the complete eeg data file of the subject
% taking % small chunks of size cfg.artifact_chunks_length
% Up to now, only range, variance and kurtosis over mean corrected chunks 
%
%
% JPO, OSNA 10/08/2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load([cfg.eyeanalysisfolder EDF_name 'eye.mat'])
event                           = ft_read_event(event_file);
starts                          = [event(2).sample:data_chunk_size:event(end).sample]';        % we look at data between first and last trigger
cfge                            = basic_preproc_cfg(cfg,event_name);
cfge.continuous                 = 'yes';
cfge.trl                        = [starts,starts+cfg.artifact_chunks_length-1,zeros(length(starts),1)];  
data                            = ft_preprocessing(cfge);


if length(data.trial)>60000*45/cfg.artifact_chunks_length                   % for overall statistic take a sample of 45 minutes of recording if it was longer
    newdata                         =cell2mat(data.trial(randsample(1:length(data.trial),round(60000*45/cfg.artifact_chunks_length))));
else
    newdata                         = cell2mat(data.trial);
end
stat.all_mean                   = mean(newdata,2);
stat.all_std                    = std(newdata,0,2);
stat.all_kurtosis               = kurtosis(newdata,0,2);
clear newdata

stat.chunksize                   = cfg.artifact_chunks_length;
for e = 1:length(data.trial)
    stat.absolute_range(:,e)    = max(data.trial{e},[],2)-min(data.trial{e},[],2);   % segment absolut amplitude distribution
    stat.check(:,e)             = std(data.trial{e},0,2);                                    % segments std distribution
    stat.kurtosis(:,e)          = kurtosis(data.trial{e},0,2);
end
k                               = size(stat.absolute_range,2)*(cfg.trim_percent/100)/2;
newabs                          = sort(stat.absolute_range,2);
stat.absolute_range_trimmean    = mean(newabs(:,round(k):end-round(k)),2);
stat.absolute_range_trimstd     = std(newabs(:,round(k):end-round(k)),0,2);
stat.trl                        = cfge.trl;

filename = [cfg.EDFname '_eegstats_chunksize_' num2str(cfg.artifact_chunks_length) '.mat'];
save([cfg.analysisfolder 'expstats/' filename],'stat')
if strcmp(cfg.keepforotherexp,'yes')
    if ~isdir(['/net/space/projects/EEG/EEGpool/' cfg.expname])
        mkdir(['/net/space/projects/EEG/EEGpool/' cfg.expname '/'])
    end
    save(['/net/space/projects/EEG/EEGpool/' cfg.expname '/' filename],'stat')
end
   
save_log([datestr(now) '   Saving file ' cfg.analysisfolder 'expstats/' filename] ,[cfg.logfolder cfg.EDFname ,'.log'])


