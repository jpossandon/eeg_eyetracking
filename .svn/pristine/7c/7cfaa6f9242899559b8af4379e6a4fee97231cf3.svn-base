function eeg_population_stats(cfg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for suj = cfg.subjects
        
        cfge        = eeg_etParams('sujid',sprintf('%03d',suj)); 
        filename    = [cfge.EDFname(1:end-4) '_eegstats_chunksize_' num2str(cfg.artifact_chunks_length) '.mat'];
        load([cfg.analysisfolder 'expstats/' filename],'stat')
        stat        = rmfield(stat,'trl');
        if suj==cfg.subjects(1)
            gen_stat = stat;
        else
            gen_stat = struct_cat(gen_stat,stat,2);
        end
end

save([cfg.analysisfolder 'expstats/allsubj_stat'],'gen_stat')
display(sprintf('General EEG stats from %d subjects from experiment %s saved',length(cfg.subjects),cfg.expname))

if strcmp(cfg.thresholds_otherexp,'yes')
    error('not yet implemented')
end

thresholds.absrange     = prctile(gen_stat.absolute_range,cfg.absthreshold,2);
thresholds.std          = prctile(gen_stat.check,cfg.stdthreshold,2);
thresholds.kurtosis     = prctile(gen_stat.kurtosis,cfg.kurtosisthreshold,2);
thresholds.chunksize    = cfg.artifact_chunks_length;
save([cfg.analysisfolder 'expstats/allsubj_thresholds'],'thresholds')