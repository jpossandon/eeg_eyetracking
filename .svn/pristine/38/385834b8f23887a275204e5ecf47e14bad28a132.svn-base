%  subjxcomp = [4 5 6 9 13 14 16 17 19 20 21 22 23 24 26 27 28 30 35 37 38 39;
%              6 8 22 12 18 9 12 15 19 23 8 14 24 27 10 17 24 11 11 22 21 10];

subj_num        = 13;
vis_comp        = 5;
trial_num       = 50;
cfg             = eeg_etParams('analysisname','vis_comp','sujid',sprintf('%03d',subj_num),'stimulifolder','/net/space/projects/EEG/features/Danja/Stimuli/');
trial2movie(cfg,trial_num,3500,'ica',setdiff(1:64,vis_comp));

!mplayer -fps 20 Suj_48_Trial_49.0.uncompressed.avi


% HIT thingy
eeglab
close all
clear all

cfg         = eeg_etParamsHIT('sujid','1');
eyedata         = eyeread(cfg,cfg.EDFname);                            % read EDF file

eyedata     = synchronEYEz(cfg, eyedata, cfg.EDFname, cfg.event);
[trl]         = define_event(cfg,eyedata,'ETtrigger',{'value','==10'},cfg.trial_time);    % this need to be fix $$$$
cfge = basic_preproc_cfg(cfg,cfg.event);
cfge.trl            = trl
prearti1             = preprocessing(cfge);   

cfg         = eeg_etParamsHIT('sujid','2');
eyedata         = eyeread(cfg,cfg.EDFname);                            % read EDF file

eyedata     = synchronEYEz(cfg, eyedata, cfg.EDFname, cfg.event);
[trl]         = define_event(cfg,eyedata,'ETtrigger',{'value','==10'},cfg.trial_time);    % this need to be fix $$$$
cfge = basic_preproc_cfg(cfg,cfg.event);
cfge.trl            = trl
prearti2             = preprocessing(cfge);   
    
combdata            = prearti1;
combdata.trial      = [prearti1.trial prearti2.trial];
combdata.time       = [prearti1.time prearti2.time];
cfg_ica = [];
cfg_ica.topolabel = combdata.label;

    

    datmat                              = cell2mat(combdata.trial);
    [cfg_ica.weights,cfg_ica.sphere]    = runica(datmat);
    cfg_ica.topo                        = inv(cfg_ica.weights * cfg_ica.sphere); 
  cfg_ica.topolabel =


plot_comp(cfg_ica)
save([cfg.analysisfolder 'ICA/' cfg.EDFname '_ICA.mat'],'cfg_ica')

vis_comp        = 1;
trial_num       = 1;
cfg             = eeg_etParams('analysisname','vis_comp','sujid',sprintf('%03d',subj_num));
trial2movie(cfg,trial_num,3500,'ica',setdiff(1:64,vis_comp));



