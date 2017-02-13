% example of analysis: experiment EEG features
% 3.5 second free-viewing of grayscales images with and whitout contras modifications
% Each subject look ~100 image presented in 5 different conditions:\
% 10 no-contrast modification 
% 20 Left increase in contrast
% 30 Left decrese in contrast
% 40 Right increase in contrast
% 50 Right decrease in contrast

% eeglab, close all,  clear all, clc                 % some computers eeglab need to be initialized in order to use its scrips

%%%%%%%
% % Pre-processing of eye-tracking data and calculation of eye-movements artifacts ICA components
%%%%%%%

% % for subj_num=[1,3:14,16:24,26:28, 30, 32:39]%                      % loop through subjects
% %     
% %     cfg             = eeg_etParams('sujid',sprintf('%03d',subj_num));      % experiment parameters, eeg_etParams define a structure with the experiment data structure, triggers definition, kind of analysis, etc 
% %     
% %     % experiment preprocessing of eyedata
% %     eyedata         = eyeread(cfg,cfg.EDFname);                            % read EDF file
% %     eyedata         = correctcoord(eyedata,480,200);                       % Correct x,y coordinates (when th images do not cover completly the screen)
% %     eyedata         = synchronEYEz(cfg, eyedata, cfg.EDFname, cfg.event);  % synchronize eeg and eye tracker data, saves the eyedata strcutre to a file in the cfg.eyeanalysisfolder
% %     fixmat          = eeget2fixmat(cfg,eyedata,subj_num);                  % change from eyedata structure (all kind of events and the temporal relationship between them) to fixmat structure (only fixations, for feature analysis)
% %     
% %     % preexperiment preprocessing of eyedata
% %     eyedata_pre     = eyeread(cfg,cfg.preexp_EDF);                         % reads pre-experimen EDF file
% %     cfg             = eeg_etParams('trial_trig_eeg',cfg.prexp_trig,'trial_trig_et',{'2'},'sujid',sprintf('%03d',subj_num));
% %     eyedata_pre     = synchronEYEz(cfg, eyedata_pre, cfg.preexp_EDF, cfg.preexp_event);
% %     
% %     calculate of ica components for preexperiment data 
% %     if sum([5,6,7,8]==subj_num)                                             % some subject have the channel set wrong
% %         cfg             = eeg_etParams('analysisname','preanalysis',...
% %                                         'artifact_reject','continous',...
% %                                         'thresholds','subj',...
% %                                         'correct_chan',[33:64,1:32],...
% %                                         'muscle_threshold',20,...
% %                                         'sujid',sprintf('%03d',subj_num));      % experiment parameters
% %     else
% %         cfg             = eeg_etParams('analysisname','preanalysis',...
% %                                         'artifact_reject','continous',...
% %                                         'thresholds','subj',...
% %                                         'muscle_threshold',20,...
% %                                         'sujid',sprintf('%03d',subj_num)); 
% %     end
% %         artifact_rej(cfg, cfg.preexp_EDF, cfg.preexp_event)       % rejection of bad segments in preexperiment period
% %    
% % end
 
% % ICA done over pre-experiment data, it has to be defined in the field cfg.ica_type , the default is 'preexp' 
% for subj_num= [8,22,26,28,32] %[1,3:14,16:24,26:28, 30, 32:39]
%     if sum([5,6,7,8]==subj_num)                                             % correction of mixed channels
%         cfg             = eeg_etParams('correct_chan',[33:64,1:32],'sujid',sprintf('%03d',subj_num));      % experiment parameters
%     else
%         cfg             = eeg_etParams('sujid',sprintf('%03d',subj_num));      % experiment parameters
%     end 
%     expica(cfg)
% end

% subjects eeg overall statistics (range,variance and entropy)
% for subj_num= [9:14,16:24,26:28, 30, 32:39] %[1,3:14,16:24,26:28, 30, 32:39]
%     if sum([5,6,7,8]==subj_num)
%         cfg             = eeg_etParams('analysisname','preanalysis',...
%                                             'artifact_reject','continous',...
%                                             'artifact_reject_type','automatic',...
%                                             'correct_chan',[33:64,1:32],...
%                                             'sujid',sprintf('%03d',subj_num));      % experiment parameters
%     else
%         cfg             = eeg_etParams('analysisname','preanalysis',...
%                                             'artifact_reject','continous',...
%                                             'artifact_reject_type','automatic',...
%                                             'muscle_threshold',20,...
%                                             'sujid',sprintf('%03d',subj_num)); 
%     end
%     eeg_subject_stats(cfg, cfg.EDFname, cfg.event)  
% end
% % pop eeg stats
% cfg             = eeg_etParams; 
% eeg_population_stats(cfg)


 % rejection of bad segments in experiment data
for subj_num=[32:39]%[9:14,16:24,26:28, 30, 32:39]
   if sum([5,6,7,8]==subj_num)
       cfg             = eeg_etParams('analysisname','preanalysis',...
                                           'artifact_reject','continous',...
                                           'artifact_reject_type','automatic',...
                                           'zthreshold',5,...
                                           'muscle_threshold',20,...
                                           'correct_chan',[33:64,1:32],...
                                           'sujid',sprintf('%03d',subj_num));      % experiment parameters
   else
       cfg             = eeg_etParams('analysisname','preanalysis',...
                                           'artifact_reject','continous',...
                                           'artifact_reject_type','automatic',...
                                           'zthreshold',3,...
                                           'muscle_threshold',20,...
                                           'sujid',sprintf('%03d',subj_num)); 
   end
   artifact_rej(cfg, cfg.EDFname, cfg.event)  
end


%
% %%%%%%%%
% % To see the data in eeglab
% %%%%%%%%
% %  load([cfg.eyeanalysisfolder cfg.EDFname(1:end-4) 'eye.mat'])
% %  toeeglab(cfg,eyedata.events,eyedata.marks)   
% 

%%%%%%%%
% Example of one analysis
%%%%%%%%
% analysis of responses to image start


% % pre-processing the data and getting the ERPs per subject, per condition
%   mkdir([cfg.eeganalysisfolder, cfg.analysisname])
%   clear all
% for  subj_num=[1,3:14,16:24,26:28, 30, 32:39]%
%     if sum([5,6,7,8]==subj_num)                                                                                                         % experiment parameters
%         cfg              = eeg_etParams('analysisname','imstart','correct_chan',[33:64,1:32],'sujid',sprintf('%03d',subj_num));      
%     else
%          cfg             = eeg_etParams('analysisname','imstart','sujid',sprintf('%03d',subj_num)); 
%     end
%     
%     load([cfg.eyeanalysisfolder cfg.EDFname(1:end-4) 'eye'])        % eye data
%     
%     [trl,events]        = define_event(cfg,eyedata,1,{'origstart','<0';'origend','>250'},[500 500]);            % selection of trials, centered at the start of the fixation in which the image appear
%     trl(:,1:2)          = trl(:,1:2)-repmat(events.origstart',1,2);                                                      % correction by the latency to the start of the trial (image presentation), so trials are centered now at image start
%     
%     [trl,toelim,events] = clean_bad(cfg, cfg.EDFname, trl, 'events',events);
% 
%     cfge                = basic_preproc_cfg(cfg,cfg.event,'lpfilter','yes','lpfreq',40,'blcwindow',[-300 -50]);
%     
%     load([cfg.analysisfolder 'ICA/' cfg.EDFname '_ICA.mat'],'cfg_ica') % ica weights
%     for cond=10:10:50                       % preprocessing the data by experimental condition
%         cfge.trl        = double(trl(find(events.condition==cond),:));
%         data            = preprocessing(cfge);
%         if ~isempty(cfg.correct_chan)
%             for e=1:length(data.trial)
%                 data.trial{e}    = data.trial{e}(cfg.correct_chan,:);
%             end
%         end
%         data                = ICAremove(data,cfg_ica,cfg_ica.comptoremove,1:64,[],[]);               % removing of eye artifact ICA components
%         cfgerp.keeptrials   ='no';
%         eval(['[data_' num2str(cond) ']  = timelockanalysis(cfgerp, data);'])                        % erp by condition/subject, keeping individual trial
%     end
%     save([cfg.eeganalysisfolder, cfg.analysisname, '/subj_ica_keep_' num2str(subj_num)],'data_10','data_20','data_30','data_40','data_50' )
% end
% 
% % grand average percondition
% clear all
% cfg = eeg_etParams('analysisname','imstart'); 
% cfgGA =[];
% cfgGA.keepindividual = 'yes';
% for cond=10:10:50
%     auxstr = ['GA_' num2str(cond)  '= timelockgrandaverage(cfgGA'];
%         for  subj_num=[1,3:14,16:24,26:28, 30, 32:39]%
%             load([cfg.eeganalysisfolder, cfg.analysisname, '/subj_ica_keep_' num2str(subj_num)],['data_' num2str(cond)])
%             eval(['data_' num2str(subj_num) '=data_' num2str(cond) ';'])
%             auxstr  = [auxstr ,',data_' num2str(subj_num)];
%         end
%      eval([auxstr, ');'])
% %      save([cfg.eeganalysisfolder, cfg.analysisname, '/GA_' num2str(cond)],['GA_' num2str(cond)])
%       save([cfg.eeganalysisfolder, cfg.analysisname, '/newGA_keep_ica_' num2str(cond)],['GA_' num2str(cond)])
% end
% 
% % % basicploting
% load('/net/space/projects/eeg_et/channel_loc')
% cfg = [];
% cfg.showlabels = 'no'; 
% cfg.fontsize = 12; 
% cfg.elec = elec;
% cfg.interactive = 'yes';
% cfg.baseline      = [-.3 0];
% cfg.xlim = [-.5 .5];
% cfg.ylim = [-15 15];
% figure,multiplotER(cfg,GA_10,GA_20,GA_30,GA_40,GA_50)
% 
% % basic within subject stat
% for cond=10:10:50
%     load(['/net/space/projects/EEG/features/jose/eegdata/imstart/GA_keep_ica_' num2str(cond)])
% end
% stat = erp_stat(GA_10,GA_20,'WS',34,[-.5 .5]);
% plot_stat(stat,GA_10,GA_20,[-.5 .5 .05],.1)
