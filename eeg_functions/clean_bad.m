function [trl,toelim,events] = clean_bad(cfg, trl, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [trl,event] = clean_bad(cfg,trl,varargin)
%
% input -
%           cfg         : experimental parameters obtained with eeg_etParams
%           EDF_name    :
%           trl         : original trial definition
%           varargin    :
%                           'events',events = event structure obtained with
%                           the trl definition
%
% output -
%           trl      : new trl definition now whitout trials including
%                           data segemts with artifacts
%           toelim   : row indexes of elimined trials of trl
%
%           events   : new event structure without the events (and possible 
%                      pre or post events) corresponding to the trials
%                      elimined
%
% jpo OSNA 26/05/2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for e = 1:length(varargin)
    if strcmp(varargin(e),'events')
        events = varargin{e+1};
    end
end

% if strcmp(cfg.artifact_reject,'continous')
%     if strcmp(cfg.artifact_reject_type,'automatic')
%         filename = [cfg.filename '_auto_continous_chunk' num2str(cfg.artifact_chunks_length) '.mat'];
%     elseif strcmp(cfg.artifact_reject_type,'visual')
%         filename = [cfg.filename '_visual_continous_chunk' num2str(cfg.artifact_chunks_length) '.mat'];
%     end
    load([cfg.preprocanalysisfolder 'cleaning/' cfg.sujid '/' cfg.filename cfg.clean_name],'bad');
  
%     load([cfg.preprocanalysisfolder 'preanalysis/' EDF_name(1:end-4) '_expgen_' cfg.artifact_reject '_var' num2str(cfg.zthreshold) '_muscle' num2str(cfg.muscle_threshold) ],'bad')             % load trials previously selected for elimination (line69)
    
    toelim = [];
    for e = 1:size(bad,1)                                               
        badstart    = find(trl(:,1)>bad(e,1) & trl(:,1)<bad(e,2));
        badend      = find(trl(:,2)>bad(e,1) & trl(:,2)<bad(e,2));
        for t = 1:size(trl,1)
            inbetween = find(trl(t,1)<bad(e,1) & trl(t,2)>bad(e,2));
            if ~isempty(inbetween)
                toelim = union(toelim,t);
            end
        end
        toelim      = union(toelim,union(badstart,badend));
    end
    
% elseif strcmp(cfg.artifact_reject,'trial')
% 
% %     load([cfg.preprocanalysisfolder cfg.analysisname '/' EDF_name  EDF_name '_expgen_continous_var' num2str(cfg.zthreshold) '_muscle' num2str(cfg.muscle_threshold) '.mat'],'toelim'); 
% 
% end

toelim                  = sort(toelim);


if exist('events','var')

    excess_event = length(events.start)/size(trl,1);
    if excess_event==round(excess_event)
        toelim2 = [];
        for i = 1:excess_event
            toelim2 = [toelim2,toelim*(excess_event-i+1)];
        end
        events = struct_elim(events,sort(toelim2),2,0);
    else
        error('event length is not a multiple of trl length')
    end
end
trl(toelim,:)           = [];