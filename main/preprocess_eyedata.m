%%
% Preprocessing of eye-tracking data (from eyelink systems, read with
% .../eye_functions/eyeread.m and edfread.m)
% This syncronize eeg with eye-tracking data
    suj             = sprintf('s%02d',s);
    cfg             = eeg_etParams_feat(cfg,'sujid',suj,...%'expfolder','/net/store/nbp/projects/EEG/E275/',...      % to run things in different environments
                                    'task_id','fv_touch',...
                                    'filename',eegfilename,...
                                    'event',[eegfilename '.vmrk'],...
                                    'trial_trig_eeg',{'S 96'},...
                                    'trial_trig_et',{'96'});      % experiment parameters, this is some trigger that is uniquely present in every trial and that needs to be used for the synch 
    eyedata         = synchronEYEz(cfg, eyedata);
    save(sprintf('%s%seye',cfg.eyeanalysisfolder,suj),'eyedata')

 