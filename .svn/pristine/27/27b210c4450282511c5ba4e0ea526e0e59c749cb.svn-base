function cfg = eeg_etParams_feat(varargin)

if ~isstruct(varargin{1})
    % default parameter for experiment EEG features
    cfg.expname             = 'features';                         % used for eeg population stats and meta-analysis across experiments, keep the same name for all analysis done with the same experimental data

    % paths
    cfg.expfolder           = '/net/store/nbp/EEG/features/';
    cfg.edfreadpath         = '/net/store/users/jossando/edfread/build/linux64/';
%     cfg.fieldtrippath       = '/net/store/nbp/eeg_et/eeg_eyetracking/fieldtrip-20101204/';
    % cfg.stimulifolder       = '/net/store/nbp/EEG/features/Stimuli/Actually_used_Pics/FinalCondBigger_0.6/';
    % cfg.featurefolder       = '/net/store/nbp/EEG/features/Danja/FeatureMaps/';                                                % parent features folder


    % triggers and trial definition
    cfg.trial_trig_eeg          = {'S 10','S 20','S 30','S 40','S 50'};                          % 'S  1','S  2','S  3', vm task eeg triggers 
    cfg.trial_trig_et           = {'10','20','30','40','50'};                                % vm task EDF triggers
    cfg.trial_time              = [0 3500];                                    % experiment trial window

    cfg.correct_chan            = [];                                           % [neworder] if channels need to be re-arrenged (for example if electrodes were connected wrongly to the amps)

    % cleaning data
    cfg.artifact_reject         = 'continous';                                  % trial or continous data 
    cfg.artifact_reject_type    = 'automatic';                                     % automatic or visual
    cfg.artifact_chunks_length  = 500;                                         % in ms, defines size of non-overlapping chunks for continous automatic artifact rejection
    cfg.artifact_auto_stat      = 'yes';
    cfg.thresholds              = 'pop';                                        % 'pop' - bases in overall population statistics 'subj' = based only in subject statistics 'file' = base only in current file statistics
    cfg.thresholds_otherexp     = 'no';                                         % 'yes' - use also data from other eeg-eyetracking experiment to determine therhsolds, 'no', only data from current exp
    cfg.datastats               = 'events';                                     % 'events' - only look into event related data accoridng to cfg.trial_trig_eeg and cfg.trial_time in this case  cfg.artifact_chunks_length needs to be divisor of cfg.trial_time
    cfg.absthreshold            = [.1 99];                                       % absolute prctile threshold for absolute range
    cfg.stdthreshold            = [.1 99];                                       % absolute prctile threshold for variance
    cfg.kurtosisthreshold       = [.1 99];                                       % absolute prctile threshold for kurtosis
    
    cfg.artifact_auto_muscle    = 'no';                                         % use fieldtrip algorithm for detection of sefments with muscular artifacts (based in variance of trials at high frequencies)
    cfg.muscle_threshold        = 20;                                           % cutoff for fieldtripp muscle arifact filter, set differently for pre-experiment (20?), erp analysis (20?) and time-freq analysis (5?)

    
     % ICA
    cfg.ica_data                = 'all';
    cfg.ica_chunks_length       = 512;

    % eyedata
    cfg.imagefield              = 'image';                                      % name of the image field in EDF data
    cfg.conditionfield          = {'ETtrigger',1};                              % field that define trial condition. 'ETtrigger' correspond to the time and data send with the eye-tracker to eeg trigger 
    cfg.resolution              = 41;                                           % image resolution in pixels per degree
    cfg.recalculate_eye         = 'no';                                         % 'yes' to recalculate eye movements with Engbert algorithm (or with a fixed velocity threshold)
    cfg.eyes                    = 'monocular';

    % eyedata
    cfg.imagefield              = 'image';                                      % name of the image field in EDF data
    cfg.eyedata                 = 'yes';                                        %there is an EDF file associated
    cfg.conditionfield          = {'ETtrigger',1};                              % field that define trial condition. 'ETtrigger' correspond to the time and data send with the eye-tracker to eeg trigger 
    cfg.resolution              = 41;                               % image resolution in pixels per degree
    cfg.recalculate_eye         = 'no';                                         % 'yes' to recalculate eye movements with Engbert algorithm (or with a fixed velocity threshold)
    cfg.eyes                    = 'monocular';
              

    % cfg.times                   = [0 3500];

    % analysis
    cfg.analysisname            = 'cleaning';                                % name of the analysis, results are saved in corresponding analysis/* folder. preanalysis folder is used for the files that contain the artifact segments that are going to be elimined

    cfg.sujid                   = '009';                                        % id of the subject as how is in EdF and EEG files names
    % cfg.subjects                = [9:10,12:14,16:24,26:28, 30, 32:39];                          % subjects in the experiment

    % feature analysis
    % cfg.features                = {'LUM_C_Radius_21','LUM_C_Radius_21_C_Radius_165'};  % feature to add at eyedata structure        
    % cfg.imsize                  = [1200 1600];


    % cfg.session                 = 1;
%     cfg.task_id                 = 'vm';
%      cfg.filename                 = 'jo01vm01';
    % cfg.task_num                = 1;
    for nv = 1:2:length(varargin)                                           % redefintion of eeg_etParams
        cfg.(varargin{nv}) = varargin{nv+1};
    end
else
    cfg = varargin{1};
    for nv = 2:2:length(varargin)                                           % redefintion of eeg_etParams
        cfg.(varargin{nv}) = varargin{nv+1};
    end
end

cfg.datapath            = [cfg.expfolder 'data/'];
cfg.chanloc             = [cfg.expfolder 'channelsEEGlab.sph'];
cfg.chanfile            = [cfg.expfolder 'channel_loc'];
cfg.analysisfolder      = [cfg.expfolder 'analysis/'];

cfg.EDFfolder           = [cfg.datapath 'ET_raw/'];
cfg.eegfolder           = [cfg.datapath 'eeg/'];
cfg.eyeanalysisfolder   = [cfg.analysisfolder 'eyedata/'];
cfg.eegstats            = [cfg.analysisfolder 'eeg_stats/' cfg.sujid '/'];
% cfg.EDFname                 = ['NA0' cfg.sujid];
%   cfg.filename  = ['NA0' cfg.sujid];
% cfg.event                   = ['NA0' cfg.sujid '.vmrk'];
% cfg.preexp_EDF              = ['NAPRE' cfg.sujid];
% cfg.preexp_event            = ['pre' cfg.sujid '.vmrk'];

if ~isstruct(varargin{1})
   for nv = 1:2:length(varargin)                                           % redefintion of eeg_etParams
        cfg.(varargin{nv}) = varargin{nv+1};
    end
else
    for nv = 2:2:length(varargin)                                           % redefintion of eeg_etParams
        cfg.(varargin{nv}) = varargin{nv+1};
    end
end 
% create the folders if they don't exist
if ~isdir(cfg.eyeanalysisfolder), mkdir(cfg.eyeanalysisfolder),end
if ~isdir(cfg.eegstats), mkdir(cfg.eegstats),end

% if ~isdir(cfg.eeganalysisfolder), mkdir(cfg.eeganalysisfolder),end
if ~isdir(cfg.analysisfolder), mkdir(cfg.analysisfolder),end
%     if ~isdir([cfg.analysisfolder 'expstats']), mkdir([cfg.analysisfolder 'expstats']),end
if ~isdir([cfg.analysisfolder cfg.analysisname]), mkdir([cfg.analysisfolder cfg.analysisname]),end
if ~isdir([cfg.analysisfolder 'ICAm/' cfg.sujid]), mkdir([cfg.analysisfolder 'ICAm/' cfg.sujid]),end
if ~isdir([cfg.analysisfolder 'cleaning/' cfg.sujid]), mkdir([cfg.analysisfolder 'cleaning/' cfg.sujid]),end
if ~isdir([cfg.expfolder 'subjects_master_files/']), mkdir([cfg.expfolder 'subjects_master_files/']),end




