% Automatic cleaning script
% It requires
% eeg_eyetracking code "https://svn.ikw.uni-osnabrueck.de/dav/nbp/projects/eeg_eyetracking' 
% it works well with the following versions of eeglab and fieldtrip:
% eeglab11_0_5_4b
% fieldtrip-20130324


% tk = str2num(getenv('SGE_TASK_ID'));     % to use with the gridengine

% definition of paths and other relevant information
cfg             = eeg_etParams('expname','CEM',...
                                'expfolder','/net/store/nbp/EEG/CEM/',...     
                                'datapath','/net/store/nbp/EEG/CEM/data/',...
                                'chanlocs','/net/store/nbp/EEG/CEM/locs_new.sph',...
                                'chanfile','/net/store/nbp/EEG/CEM/channel_loc',...
                                'analysisfolder','/net/store/nbp/EEG/CEM/analysis',...
                                'eegfolder','/net/store/nbp/EEG/CEM/data/al/fv/eeg/',...
                                'eyeanalysisfolder','/net/store/nbp/EEG/CEM/analysis/eyedata/al/',...
                                'channelcorfolder','/net/store/nbp/EEG/CEM/subjects_master_files/',...
                                'sujid','al',...
                                'filename','al05fv01.eeg');
% load(cfg.masterfile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clean eye correction from this specific file
pause(rand(1)*30)   % to get rid of that random error that seem to be cause
% by many computers accesing and saving the same file at the same moment 

if exist([cfg.channelcorfolder 'al_channels_corrections.mat'])
    load([cfg.channelcorfolder 'al_channels_corrections.mat'])
    ix  =  strmatch(cfg.filename,chan_cor.filestochange);
    if ~isempty(ix)
        remove = [];
        for e = 1:length(ix)
            if chan_cor.pre(ix(e))==0
                remove = [remove,ix(e)];
            end
        end
        chan_cor.filestochange(remove) = [];
        chan_cor.correct_chan(remove)  = [];
        chan_cor.elim_chan(remove)     = [];
        chan_cor.pre(remove)           = [];
    
    save([cfg.channelcorfolder 'al_channels_corrections.mat'],'chan_cor')
    end
	clear chan_cor ix remove e
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% correct channels (inversions) (this is inside all code)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a first sweep to remove absurdely bad segments independently of eye
% movements
cfg             = eeg_etParams(cfg,...
                                   'filename',exp.tasks_done.filename{task},...
                                   'event',[exp.tasks_done.filename{task} '.vmrk'],...
                                   'analysisname','cleaning',...
                                   'clean_exclude_eye',0,...
                                   'clean_foi',30:5:120,...
                                   'clean_freq_threshold',400,...
                                   'clean_range_threshold',[5 600],...
                                   'clean_ica_correct',[],...
                                   'clean_trend_threshold',200,...
                                   'clean_minclean_interval',100,...
                                   'clean_movwin_length',.256,...
                                   'clean_mov_step',.006,...
                                    'clean_name','pre');
                                
% bad because of gamma
[value_g,tot_sample_g]              = freq_artifact(cfg);
[bad_g,badchans_g,channelbad_g]     = badsegments(cfg,value_g,tot_sample_g,cfg.clean_freq_threshold);
% 
% % bad because of amplitude
[value_a,tot_sample_a]              = range_artifact(cfg);
[bad_a,badchans_a,channelbad_a]     = badsegments(cfg,value_a,tot_sample_a,cfg.clean_range_threshold);

[bad,badchans]                      = combine_bad({bad_a;bad_g},{badchans_a,badchans_g},cfg.clean_minclean_interval);
channelbad                          = combine_bad([channelbad_a;channelbad_g],[],cfg.clean_minclean_interval);

cfg_clean                           = cfg;

% save([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name],'bad','badchans','channelbad','cfg_clean','value_g','tot_sample_g','value_a','tot_sample_a') % we save all this for now until we now the good seetings
save([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name],'bad','badchans','channelbad','cfg_clean') % TODO: info about the cleaning parameters

% here we check if there is a channel that is continuously bad even for the
% lax criteria were using
cfg                                 = eeg_etParams(cfg,'clean_bad_channel_criteria',.25);
check_session(cfg)

% re-check bad segments now whitout taking in accound bad channels (done in badsegments and check_session)
 cfg                                = eeg_etParams(cfg,'clean_movwin_length',.256,'clean_mov_step',.006);
[bad_g,badchans_g]                  = badsegments(cfg,value_g,tot_sample_g,cfg.clean_freq_threshold);
[bad_a,badchans_a]                  = badsegments(cfg,value_a,tot_sample_a,cfg.clean_range_threshold);
[bad,badchans]                      = combine_bad({bad_a;bad_g},{badchans_a,badchans_g},cfg.clean_minclean_interval);
save([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name],'bad','badchans','bad_a','badchans_a','-append') % TODO: info about the cleaning parameters

% run first ICA
if strcmp(cfg.task_id,'eo') || strcmp(cfg.task_id,'ec') || strcmp(cfg.task_id,'p3'),cfg.eyedata = 'no';end
expica(cfg)

% the second sweep is over data clean from eye-movement compontent and muscle artifact components, we can
% use narrower thresholds here, we check visually that everything is ok and then we run ICA again
cfg             = eeg_etParams(cfg,...
                                   'task_id',exp.tasks_done.task_id{task},...
                                   'filename',exp.tasks_done.filename{task},...
                                   'event',[exp.tasks_done.filename{task} '.vmrk'],...
                                   'analysisname','cleaning',...
                                   'clean_exclude_eye',0,...
                                   'clean_foi',30:5:120,...
                                   'clean_freq_threshold',125,...
                                   'clean_range_threshold',[5 125],...
                                   'clean_trend_threshold',70,...
                                   'clean_minclean_interval',500,...
                                   'clean_ica_correct','yes',...
                                   'clean_movwin_length',.256,...
                                   'clean_mov_step',.006,...
                                   'clean_name','general');

% bad because of gamma
[value_g,tot_sample_g]              = freq_artifact(cfg);
[bad_g,badchans_g,channelbad_g]     = badsegments(cfg,value_g,tot_sample_g,cfg.clean_freq_threshold);
% 
% % bad because of amplitude
[value_a,tot_sample_a]              = range_artifact(cfg);
[bad_a,badchans_a,channelbad_a]     = badsegments(cfg,value_a,tot_sample_a,cfg.clean_range_threshold);
% 
% % bad because of trend, longer
 cfg                                = eeg_etParams(cfg,'clean_movwin_length',1,...
                                          'clean_mov_step',.06);
[value,tot_sample]                  = trend_artifact(cfg);
[bad_t,badchans_t,channelbad_t]     = badsegments(cfg,value,tot_sample,cfg.clean_trend_threshold); %TODO: borders need to be readjusted to hthe length of gthe moving window
%                    
% % combine info and save,[channelbad_a;channelbad_g;channelbad_t]
[bad,badchans]                      = combine_bad({bad_a;bad_g;bad_t},{badchans_a,badchans_g,badchans_t},cfg.clean_minclean_interval);
channelbad                          = combine_bad([channelbad_a;channelbad_g;channelbad_t],[],cfg.clean_minclean_interval);

cfg_clean                           = cfg;

% save([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name],'bad','badchans','channelbad','cfg_clean','value_g','tot_sample_g','value_a','tot_sample_a') % we save all this for now until we now the good seetings
save([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name],'bad','badchans','channelbad','cfg_clean') % TODO: info about the cleaning parameters

cfg                                 = eeg_etParams(cfg,'clean_bad_channel_criteria',.20);
check_session(cfg)

% re-check bad segments now whitout taking in accound bad channels (done in badsegments)
cfg                                = eeg_etParams(cfg,'clean_movwin_length',.256,'clean_mov_step',.006);
[bad_g,badchans_g]                 = badsegments(cfg,value_g,tot_sample_g,cfg.clean_freq_threshold);
[bad_a2,badchans_a2]                 = badsegments(cfg,value_a,tot_sample_a,cfg.clean_range_threshold);
cfg                                = eeg_etParams(cfg,'clean_movwin_length',1,'clean_mov_step',.06);
[bad_t,badchans_t]                 = badsegments(cfg,value,tot_sample,cfg.clean_trend_threshold); %TODO: borders need to be readjusted to hthe length of gthe moving window

% we reuse the very bad segments becuase of range of step1 to get rid of
% problems with some dataset where there is a very bad segment that gets
% celan by ICA
load([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename 'pre'],'bad_a','badchans_a') % TODO: info about the cleaning parameters

[bad,badchans]                     = combine_bad({bad_a;bad_a2;bad_g;bad_t},{badchans_a,badchans_a2,badchans_g,badchans_t},cfg.clean_minclean_interval);
save([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name],'bad','badchans','-append') % TODO: info about the cleaning parameters

% visual_clean(cfg)
% 
% run second definitive ICA
if strcmp(cfg.task_id,'eo') || strcmp(cfg.task_id,'ec') || strcmp(cfg.task_id,'p3'),cfg.eyedata = 'no';end
 expica(cfg)


% and we do the cleaning one more time with the final ICA weights
clear cfg
cfg             = eeg_etParams('sujid',suj);
cfg             = eeg_etParams(cfg,...
                                   'task_id',exp.tasks_done.task_id{task},...
                                   'filename',exp.tasks_done.filename{task},...
                                   'event',[exp.tasks_done.filename{task} '.vmrk'],...
                                   'analysisname','cleaning',...
                                   'clean_exclude_eye',0,...
                                   'clean_foi',30:5:120,...
                                   'clean_freq_threshold',75,...
                                   'clean_range_threshold',[5 125],...
                                   'clean_trend_threshold',70,...
                                   'clean_minclean_interval',500,...
                                   'clean_ica_correct','yes',...
                                   'clean_movwin_length',.256,...
                                   'clean_mov_step',.006,...
                                   'clean_name','final');

% bad because of gamma
[value_g,tot_sample_g]              = freq_artifact(cfg);
[bad_g,badchans_g,channelbad_g]     = badsegments(cfg,value_g,tot_sample_g,cfg.clean_freq_threshold);
% 
% % bad because of amplitude
[value_a,tot_sample_a]              = range_artifact(cfg);
[bad_a,badchans_a,channelbad_a]     = badsegments(cfg,value_a,tot_sample_a,cfg.clean_range_threshold);
% 
% % bad because of trend, longer
 cfg                                = eeg_etParams(cfg,'clean_movwin_length',1,...
                                          'clean_mov_step',.06);
[value,tot_sample]                  = trend_artifact(cfg);
[bad_t,badchans_t,channelbad_t]     = badsegments(cfg,value,tot_sample,cfg.clean_trend_threshold); %TODO: borders need to be readjusted to hthe length of gthe moving window
%                    
% % combine info and save,[channelbad_a;channelbad_g;channelbad_t]
[bad,badchans]                      = combine_bad({bad_a;bad_g;bad_t},{badchans_a,badchans_g,badchans_t},cfg.clean_minclean_interval);
channelbad                          = combine_bad([channelbad_a;channelbad_g;channelbad_t],[],cfg.clean_minclean_interval);

cfg_clean                           = cfg;
save([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name],'bad','badchans','channelbad','cfg_clean')  % TODO: info about the cleaning parameters
