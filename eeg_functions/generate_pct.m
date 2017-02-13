function [pct_a,pct_k,pct_z] = generate_pct(cfg,stat_files)

abs_range = [];
for e = 1:length(stat_files)
    if strcmp(cfg.thresholds,'subj')
        load([cfg.eegstats stat_files{e}])
    elseif strcmp(cfg.thresholds,'pop')
        load([stat_files{e}])
    end
        abs_range = [abs_range,stat.absolute_range];
end
pct_a       = prctile(abs_range',cfg.absthreshold);
clear abs_range stat

kurt = [];
for e = 1:length(stat_files)
    if strcmp(cfg.thresholds,'subj')
        load([cfg.eegstats stat_files{e}])
    elseif strcmp(cfg.thresholds,'pop')
        load([stat_files{e}])
    end
    kurt = [kurt,stat.kurtosis];
end
pct_k       = prctile(kurt',cfg.kurtosisthreshold);
clear kurt stat

zet = [];
for e = 1:length(stat_files)
    if strcmp(cfg.thresholds,'subj')
        load([cfg.eegstats stat_files{e}])
    elseif strcmp(cfg.thresholds,'pop')
        load([stat_files{e}])
    end
    zet = [zet,stat.check];
end
pct_z       = prctile(zet',cfg.stdthreshold);
clear zet stat
% save([cfg.eegstats cfg.sujid '_pct'],'pct_a','pct_k','pct_z')

        %             load([cfg.analysisfolder 'eeg_stats/' cfg.sujid '_geneegstat'])
%             abs_range   = [allstat.absolute_range];
%             pct_a       = prctile(abs_range',cfg.absthreshold);
%             kurt        = [allstat.kurtosis];
%             pct_k       = prctile(kurt',cfg.kurtosisthreshold);   
%             zet         = [allstat.check];
%             pct_z       = prctile(zet',cfg.stdthreshold);
%             task_indx   = find(strcmp(cfg.filename,tasks_info.filename));

        
        
        
