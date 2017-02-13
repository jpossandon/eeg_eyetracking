function artifact_rej(cfg,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function artifact_rej(cfg,EDF_name,event_name,varargin)
% EEG artifact rejection can be done over the complete data file:
% cfg.artifact_reject = 'continous' ; or by slecting bad trials:
% cfg.artifact_reject = 'trials' , in this case it need a trial definition
% input -
%           cfg         : experimental parameters obtained with eeg_etParams
%           EDF_name    : name of the original eye-tracking EDF file,
%           event_name  : name of the corresponding eeg eventfile (*.vmrk)
%           varargin    : epoch specs for artifact_reject_pre, first three 
%                           variable should correspond to event_type,value,time
%                           only for trial type of artifact rejection
%
% jpo OSNA 25/05/2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(cfg.artifact_reject,'continous')
    artifact_continous(cfg)
elseif strcmp(cfg.artifact_reject,'trial')
    artifact_reject_pre(cfg,varargin)
end