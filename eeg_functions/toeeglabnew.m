function EEG = toeeglab(cfg,EDFname,events,marks)

% get EEG data
%EEG = pop_loadbv(cfg.eegfolder,[EDFname '.vhdr']); 
EEG = pop_fileio([cfg.eegfolder,EDFname '.vhdr']); 

load([cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'],'cfg_ica')
if strcmp(cfg_ica.type,'amica')
    EEG.icasphere = cfg_ica.mod.S;
    EEG.icaweights = cfg_ica.mod.W;
elseif strcmp(cfg_ica.type,'runica')
    EEG.icasphere = cfg_ica.sphere;
    EEG.icaweights = cfg_ica.weights;
end
%EEG.icachansind = cellfun(@str2num,cfg_ica.topolabel);
EEG.icachansind = find(ismember(cfg_ica.origtopolabel,cfg_ica.topolabel));
% make events
% Eventindx = {};
% if ~isempty(events)
%      Eventindx = [mat2cell([events.start'/EEG.srate],ones(size(events.start))),...
%          cellstr(num2str(events.type')),...
%          mat2cell(1./EEG.srate*ones(length(events.type),1),ones(size(events.type)))];
% end
Eventindx = {};

if ~isempty(events)
    fevents = fields(events);
    for ff = 1:length(fevents)
        if strcmp(fevents(ff),'latency')
            Eventindx = [Eventindx, mat2cell([events.(fevents{ff})'/EEG.srate],ones(size(events.(fevents{ff}))))];
        elseif strcmp(fevents(ff),'type')   
            if isnumeric(events.(fevents{ff}))
                Eventindx = [Eventindx,cellstr(num2str(events.(fevents{ff})'))];
            elseif  iscell(events.(fevents{ff}))
                Eventindx = [Eventindx,events.(fevents{ff})'];
            end
        else
            Eventindx = [Eventindx, mat2cell([events.(fevents{ff})'],ones(size(events.(fevents{ff}))))];
        end
    end
end
Eventindx    = [Eventindx,mat2cell(1./EEG.srate*ones(size(Eventindx,1),1),ones(size(Eventindx,1),1))];
fevents{end+1} = 'duration';
% channel locations
load(cfg.chanlocs)
EEG.chanlocs = chanlocs;

% EEG.chanlocs = readlocs(cfg.chanloc,'filetype','custom',...
%         'format',{'channum','sph_phi_besa','sph_theta_besa','ignore'},'skiplines',0);

    
% imports saccade start and end events
% EEG.event   = importevent('Eventindx',EEG.event,EEG.srate,  'append', 'yes', 'fields',{ 'latency', 'type','duration'}, 'timeunit',1);
  EEG.event   = importevent('Eventindx',EEG.event,EEG.srate,  'append', 'yes', 'fields',fevents, 'timeunit',1);
    
%     eeglab
%     Eventindx = [];
%     if ~isempty(events)
%         tipos = unique(events.type);
%         Eventindx = [Eventindx;[events.start'/1000,events.type']];
%     end
%     
  
    
        
%     if ~isempty(marks)
%         Eventindx = [Eventindx;[[marks.time(strcmp(marks.type,'ETtrigger'))/1000]',[marks.value(strcmp(marks.type,'ETtrigger'))]']];
%     end
%     assignin('base', 'Eventindx', Eventindx)     
 
% EEG = pop_loadbv(cfg.eegfolder,[EDFname '.vhdr'], [],...
%         [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64]);
% 
  
    % resample to 500 hz
%     EEG = pop_resample( EEG, 500);            % do not resample when using artifact rejection
    

    % ica
%     if exist([cfg.analysisfolder 'ICA/' cfg.EDFname(1:end-4) '_ICA.mat'])
%         load([cfg.analysisfolder 'ICA/' cfg.EDFname(1:end-4) '_ICA.mat'])
%         assignin('base', 'cfg_ica',cfg_ica) 
%         EEG = pop_editset(EEG, 'icaweights',  'cfg_ica.weights', 'icasphere',  'cfg_ica.sphere', 'icachansind', []);
%     end
%      assignin('base', 'EEG', EEG) 
%     eeglab redraw
   
%     EEG = pop_saveset(EEG, 'filename', name, 'filepath', '/net/space/projects/EEG/features/DATA/sets/');

    