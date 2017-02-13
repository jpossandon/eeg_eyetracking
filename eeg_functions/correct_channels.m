function [cfg, varargout] = correct_channels(cfg, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [cfg, varargout] = correct_channels(cfg, varargin)
% This function check a file that contain information about what channel to
% switch (in case channel are wrongly assigned in the eeg file) and what
% channel to remove (deciced somewhere else)
% If only cfg structure is given, it will return only a cgf structure with
% added (or modified) fields correct_chan and elim_chan
% If a fieldtrip data strcture is given as additional variable, the
% function will switch and remove the corresponding channels and give back
% the corrected structure
% This functions need a folder subjecs_master_files in cfg.expfolder to
% work
% 
% Somewhen, JPO, OSNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist([cfg.expfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'])    % check if there is a file that contain subject channels to correct exits (this is specially the case for multisession data)
    load([cfg.expfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'])
        cfg.correct_chan = [];
        cfg.elim_chan = [];
    if sum(strcmp(cfg.filename,chan_cor.filestochange))>0                                          % look is there is information of channel to remove for this specific session/file
        if ~isempty(cell2mat(chan_cor.correct_chan(strcmp(cfg.filename,chan_cor.filestochange))))  % this is for the case when channels are changed in the data structure
            cfg.correct_chan = cell2mat(chan_cor.correct_chan(strcmp(cfg.filename,chan_cor.filestochange)));
        end
        if  ~isempty(cell2mat(chan_cor.elim_chan(strcmp(cfg.filename,chan_cor.filestochange))))    % this is for channel tagged to be elimined
            cfg.elim_chan = cell2mat(chan_cor.elim_chan(strcmp(cfg.filename,chan_cor.filestochange)));
        end
    end
else              % if there is no info we give an structure with empty fields
    cfg.correct_chan = [];
    cfg.elim_chan = [];
end

% when a data structure is given, channels are switched and elimined
% we always change channels first and after that we eliminate if necessary
if ~isempty(varargin)
    prearti = varargin{1};
    if ~isempty(cfg.correct_chan)                                           % in case channels are changed
        for ip=1:length(prearti.trial)
            prearti.trial{ip}    = prearti.trial{ip}(cfg.correct_chan,:);
        end
    end

    if ~isempty(cfg.elim_chan)                                           % in case channels are changed
        for ip=1:length(prearti.trial)
            prearti.trial{ip}    = prearti.trial{ip}(setdiff(1:length(prearti.label),cfg.elim_chan),:);
        end 
        prearti.label            = prearti.label(setdiff(1:length(prearti.label),cfg.elim_chan));
    end
    
    varargout{1} = prearti;
end