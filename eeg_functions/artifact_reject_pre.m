function artifact_reject_pre(cfg,EDF_name,event_file,event_type,value,time,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function artifact_reject_pre(cfg,EDF_name,event_file,event_type,value,time,varargin)
% 
% input:
% cfg               : obtained with eeg_etParams
%      .artreject   : 'visual' - visual rejection
%                     'var'    - rejects trial with outlier (2sd) variance
% EDF_name
% event_file        : eeg .vmrk file
% event_type        : event used to cut the eegdata, it can be an integer (eyedata.events) or a strink (eyedata.marks) 
% value             : {'fieldname','==?'} as in define_event, specify what property (and its value) of the event is used to define the 0 moment 
% time              : [pre_event post_event] in ms, define the length of the eeg segment cut for each event 
% 
% varagin           : specifies pre and post events condition than need to be fullfiled (see define_event)
%
% output: saves a file *_expgen_epoch2reject.mat in the respective analysis
%           folder (cfg.analysisname) a vector with the number of the trials to elim
% 
% jpo 08/03/10 OSNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfge = basic_preproc_cfg(cfg,event_file,'detrend','yes','reref','yes');
    
load([cfg.eyeanalysisfolder EDF_name 'eye'])
[trl]               = define_event(cfg,eyedata,event_type,value,time,varargin{:});
cfge.trl            = double(trl);
prearti             = preprocessing(cfge);
if ~isempty(cfg.correct_chan)
    for e=1:length(prearti.trial)
        prearti.trial{e}    = prearti.trial{e}(cfg.correct_chan,:);
    end
end

if strcmp(cfg.artreject,'visual')
     cfge                 = [];
    cfgre.bpfilter        = 'yes';
    cfgre.bpfiltertype    = 'but';
    cfgre.bpfreq          = [0.5 100];
    cfgre.method          = 'trial';
    cfgre.alim            = 100;
    art                  = rejectvisual(cfgre, prearti);
    [b ind]=intersect(art.cfg.trlold(:,1), art.cfg.trl(:,1));
    toelim = setdiff(1:size(art.cfg.trlold,1),ind);
elseif strcmp(cfg.artreject,'var')
    vars = zeros(64,length(prearti.trial));
    for e=1:length(prearti.trial)
        vars(:,e)=std(prearti.trial{e},1,2);
    end
    toelim = [];
    for e=1:64
        varss(e)=std(vars(e,:),1,2);
        aux = find(vars(e,:)>mean(vars(e,:))+2*varss(e) | vars(e,:)<mean(vars(e,:))-2*varss(e));
        toelim = union(toelim,aux);
    end    
end 
 save([cfg.analysisfolder cfg.analysisname '/' EDF_name '_expgen_epoch2reject.mat'],'toelim')
 save_log([datestr(now) '   Saving file ' cfg.analysisfolder cfg.analysisname '/' EDF_name '_expgen_epoch2reject.mat' ] ,[cfg.logfolder EDF_name ,'.log'])

