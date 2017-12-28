function [eyedata] = eyeread(cfg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [eyedata] = eyeread(cfg,filetoread)
% Read EDf file and creates the data structure used by the eeg_eyetracking
% functions
% Input: 
%   cfg - structure defined with eeg_etParams
%       .edfreadpath    : EDF data folder
%       .resolution     : pixels per visual degree stimuli resoltion
%       .eyes           : eye data to use - 'monocular' / 'binocular
%       .recalculate_eye: to recalculate eye/movements with Engbert algorithm: 'yes' / 'no'
%
%       if recalculate eye movemens:
%       .vfac           : relative velocity threshold (default 5 sd)
%       .sacmindur      : min tim in ms for a saccade event (default == 12 ms)
%       .threshold      : velocity threshold for sacadde (default == 25 degrees/sec) 
%                           - [0]    : it uses relative velocity threshold, 
%                                         making it able to detect microssacades 
%                                         but more suceptible to noise (false positive saccades)  
%                           - #      : any other number, velocity threshold
%                                       for saccade detection
%       .blinkmindur    : min tim in ms for a blink event  (default == 20 ms),
%                           it is neccesary in order to not detect missing samples as
%                           blinks
%       .fixmindur      : min tim in ms for a fixation event (default == 20 ms),
%       .betweenmindur  : min tim between events of the same kind to be
%                       considered different events (default == 10 ms),
%   filetoread - name of EDF file 
%
% Output:
%
%      eyedata.events
%                    .start
%                    .end
%                    .pv            : saccade peak velocity
%                    .amp           : amplitude in visual degrees between start or end position (saccade&fixations) 
%                    .dur           : duration in ms 
%                    .posx          : fixation x position
%                    .posy          : fixation y position
%                    .pre           : index of previous event relative to actual event
%                    .next          : index of next event relative to actual event
%                    .type          : (1) - Fix   (2) - Sac    (3) - Blink
%                                     (4) - Sac with Blink inside
%                                     (5) - Blink inside saccade
%                    .angle         : hexadecimal angle between end and start position
%                    .index         : event start (1row) and end sample
%                    .pupil_m       : fix mean pupil size
%                    .pupil_std     : fix std pupil size
%                    .pupil_max     : fix max pupil size
%                    .pupil_min     : fix min pupil size
%                    .trial         
%                    .posinix
%                    .posiniy
%                    .posendx
%                    .posendy
%                    .event order   : event order in the trial and within the event type
%                    .image         : image associated to the event
%                    .condition     : event experimental condition 
%             .samples
%                     .time         : time samples in eye-tracker time
%                     .pos          : position samples(1rst-row:xpos 2nd-row:ypos)
%                     .pupil        : pupil size samples
%                     .trial        : trial number of each sample
%             .marks
%                   .value
%                   .time
%                   .type           :'ETtrigger' - ttl trigger send by the
%                                                   eye-tracker throughthe parallel port
%                                    'button'
%                                    '?'         - and any data in the EDF file with the
%                                                       ... command
%                   .trial
%             .meta
%                  .sindx
%                  .trialscalib
%                  .Lerr_avg
%                  .Rerr_avg
%                  .Lerr_max
%                  .Rerr_max
%                  .besteye
%                  .eyenums
%                  .Lerrorsmeans
%                  .Rerrormeans
%
% JPO 8/03/2010,OSNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%export
%LD_LIBRARY_PATH=/net/space/projects/eeg_et/tools/edfread/build/linux64/
% matlab need to be restartedafter isntallin edfapi library

if ~isfield(cfg, 'resolution'),         cfg.resolution      = deg2px(cfg, 1); end
if ~isfield(cfg, 'vfac'),               cfg.vfac            = 6;              end
if ~isfield(cfg, 'sacmindur'),          cfg.sacmindur       = 12;              end
if ~isfield(cfg, 'threshold'),          cfg.threshold       = 25;             end
if ~isfield(cfg, 'recalculate_eye'),    cfg.recalculate_eye = 'no';          end
if ~isfield(cfg, 'blinkmindur'),        cfg.blinkmindur     = 20;              end
if ~isfield(cfg, 'fixmindur'),          cfg.fixmindur       = 20;              end
if ~isfield(cfg, 'betweenmindur'),      cfg.betweenmindur   = 10;              end

% read EDF file
current = pwd;
cd(cfg.edfreadpath)
%try
%[trial, meta] = edfread([cfg.EDFfolder cfg.filename  '.EDF'],'write');
%catch
%    [trial, meta] = edfread([cfg.EDFfolder cfg.filename  '.edf'],'write');
%end
error('do not use')
[trial,meta] =totrial('/Volumes/nibaldo/trabajo/E283/data/s31vs/s31vs.edf',{'gaze'});
% an ugly fix for an error in the task free_viewing experiment CEM
if isfield(cfg,'task_id')
    if strcmp(cfg.task_id,'fv')
        try
            trial2 = edfread([cfg.EDFfolder cfg.filename  '.EDF'],'image');
        catch
            trial2 = edfread([cfg.EDFfolder cfg.filename  '.edf'],'image');
        end
        for e = 1:length(trial), 
            trial(e).image.time = trial2(e).image.time;
            [~,trial(e).image.msg] = strtok(trial2(e).image.msg);
        end
        clear trial2
    end
end
    cd(current)

%read metainformation 
metainfo = readmeta(meta,length(trial));
if isfield(cfg,'eyes')
    if strcmp(cfg.eyes,'monocular') && length(unique(metainfo.besteye))==1
       loopeyes = metainfo.besteye(1);
    else
       loopeyes = [1,2];   
       selecteye = [metainfo.trialsxcalib(find(metainfo.trialsxcalib));metainfo.besteye(find(metainfo.trialsxcalib))];
    end
end

%determine sampling rate, why I did this if everything is done in time?
try                 
    cfg.fs = single(1000/(trial(1).left.samples.time(2)-trial(1).left.samples.time(1)));
catch
    cfg.fs = single(1000/(trial(1).right.samples.time(2)-trial(1).right.samples.time(1)));
end

limitblink   = cfg.fs*cfg.blinkmindur/1000;             %10ms?
limitfix     = cfg.fs*cfg.fixmindur /1000;             %6ms?
limitbetween = cfg.fs*cfg.betweenmindur/1000; 
cfg.mindur   = cfg.fs*cfg.sacmindur/1000; 

%restructure edfread output
LR = {'left','right'};

eye1.events = struct('start',[],'end',[],'pv',[],'amp',[],'dur',[],'posx',[],'posy',[],'pre',[],'next',[],'type',[],'angle',[],'index',[],'pupil_m',[],...
        'pupil_std',[],'pupil_max',[],'pupil_min',[],'trial',[],'posinix',[],'posiniy',[],'posendx',[],'posendy',[],'event_order',[]);
if length(loopeyes)>1    
   eye2 = eye1;
   eyedata = eye1;
end
eyedata.samples =  struct('time',[],'pos',[],'pupil',[],'trial',[]);
 
for l=loopeyes       % loop through eyes
    % sample data
    valid = [];
    for e=1:length(trial)
        if isstruct(trial(e).(LR{l}))
            valid = [valid,e];
        end
    end
    if ~isempty(valid)
        aux        = [trial(valid).(LR{l})];
        aux        = [aux.samples];
        time       = [aux.time]; 
        pos        = [[aux.x];[aux.y]];
        pupil      = [aux.pupil];

        trialind   = zeros(1,length(time));
        a = 1;
        for e = 1:length(aux)
            trialind(a:a+length(aux(e).time)-1)=valid(e);
            a = a+length(aux(e).time);
        end
    end
    if l==1 && ~isempty(valid)
        eye1.samples.time   = single(time);
        eye1.samples.pos    = pos;
        eye1.samples.pupil  = pupil;
        eye1.samples.trial  = single(trialind);
    elseif l==2 && ~isempty(valid)
       eye2.samples.time   = single(time);
       eye2.samples.pos    = pos;
       eye2.samples.pupil  = pupil;
       eye2.samples.trial  = single(trialind);
    end
    % event data

    for trllop = 1:length(trial)        % loop through trials
         try
            events = struct('start',[],'end',[],'pv',[],'amp',[],'dur',[],'posx',[],'posy',[],'type',[],'angle',[],'index',[],'pupil_m',[],...
            'pupil_std',[],'pupil_max',[],'pupil_min',[],'trial',[],'posinix',[],'posiniy',[],'posendx',[],'posendy',[],'event_order',[]); 
            if isstruct(trial(trllop).(LR{l}));
                time = single(trial(trllop).(LR{l}).samples.time);
                pupil = trial(trllop).(LR{l}).samples.pupil; 
                %%%% Saccades
                if strcmp(cfg.recalculate_eye,'yes')                % recalculate events

                    % check for discontinuity in et data
                    dsample = find(diff(time)>2);
                    if length(dsample)==1
                        posvec   = [trial(trllop).(LR{l}).samples.x(dsample+1:end); trial(trllop).(LR{l}).samples.y(dsample+1:end)]';
                    elseif length(dsample)>1
                        error('More than one discontinuity in eyetracker data')
                    else
                        posvec   = [trial(trllop).(LR{l}).samples.x; trial(trllop).(LR{l}).samples.y]';
                        dsample  = 0;
                    end
                    % new events
                    if sum(posvec<10000)>0      % if there is any data there
                        [sacl] = saccade(cfg, posvec);      % saccade detection
                        if size(sacl,1)>0       % if there is any saccade there
                        events.posinix       = posvec(sacl(:,1),1)';
                        events.posiniy       = posvec(sacl(:,1),2)';
                        events.posendx       = posvec(sacl(:,2),1)';
                        events.posendy       = posvec(sacl(:,2),2)';
                        events.posx          = [events.posx;ones(1,size(sacl,1))*NaN];
                        events.posy          = [events.posy;ones(1,size(sacl,1))*NaN];
                        events.index         = [sacl(:,1)'+dsample;sacl(:,2)'+dsample];
                        events.start         = time(sacl(:,1)+dsample);
                        events.end           = time(sacl(:,2)+dsample);
                        events.pv            = sacl(:,3)';
                        for e = 1:size(sacl,1)
                        events.pupil_m       =  [events.pupil_m,mean(pupil(sacl(e,1)+dsample:sacl(e,2)+dsample))];
                        events.pupil_std     =  [events.pupil_std,std(pupil(sacl(e,1)+dsample:sacl(e,2)+dsample))];
                        events.pupil_max     =  [events.pupil_max,max(pupil(sacl(e,1)+dsample:sacl(e,2)+dsample))];
                        events.pupil_min     =  [events.pupil_min,min(pupil(sacl(e,1)+dsample:sacl(e,2)+dsample))];
                        end
                        events.event_order   = 1:size(sacl,1);
                        events.type          = ones(1,size(sacl,1))*2;
                        end
                    end
                    %%%% Blinks    
                    blinks = union(find(posvec(:,1)==100000000),find(posvec(:,2)==100000000)); % in edfread output, missed samples (blinks) have a value of 10 e-8 (in ASCII file is a . )    
                    tap = diff(blinks);
                    indxb = find(tap>1); 
                    indxb(tap(indxb)<limitblink)=[];                % join missed samples that are separated by data with shorther duration than minimus time decided to have an event       

                     if ~isempty(blinks)
                        events.posinix       = [events.posinix,NaN(1,length(indxb)+1)];
                        events.posiniy       = [events.posiniy,NaN(1,length(indxb)+1)];
                        events.posendx       = [events.posendx,NaN(1,length(indxb)+1)];
                        events.posendy       = [events.posendy,NaN(1,length(indxb)+1)];
                        events.posx          = [events.posx,ones(1,length(indxb)+1)*NaN];
                        events.posy          = [events.posy,ones(1,length(indxb)+1)*NaN];
                        events.pv            = [events.pv,ones(1,length(indxb)+1)*NaN];
                        events.pupil_m       = [events.pupil_m,NaN(1,length(indxb)+1)];
                        events.pupil_std     = [events.pupil_std,NaN(1,length(indxb)+1)];
                        events.pupil_max     = [events.pupil_max,NaN(1,length(indxb)+1)];
                        events.pupil_min     = [events.pupil_min,NaN(1,length(indxb)+1)];
                        events.type          = [events.type,ones(1,length(indxb)+1)*3];
                    end
                    fin = [];
                    if ~isempty(indxb)                   % more than one blink
                        if length(indxb)==1              % two blinks
                        events.index         = [events.index,[blinks(1)+dsample;blinks(indxb(1))+dsample],[blinks(indxb(1)+1)+dsample;blinks(end)+dsample]];
                        elseif length(indxb)>1           % more than two blinks 
                        events.index         = [events.index,[[blinks(1)+dsample;blinks(indxb(1))+dsample],[blinks(indxb(1:end)+1)'+dsample;[blinks(indxb(2:end))'+dsample,blinks(end)+dsample]]]];
                        end
                        events.start         = [events.start,time(events.index(1,end-length(indxb):end))];
                        events.end           = [events.end,time(events.index(2,end-length(indxb):end))];
                        events.event_order   = [events.event_order,1:length(indxb)+1];
                        fin = length(indxb)+1;
                    elseif ~isempty(blinks)             % just one blink
                        events.index         = [events.index,[blinks(1)+dsample;blinks(end)+dsample]];
                        events.start         = [events.start,time(events.index(1,end))];
                        events.end           = [events.end,time(events.index(2,end))];
                        events.event_order   =  [events.event_order,1];
                        fin = 1;
                    end

                    if ~isempty(fin)   % retype blinks and saccades when blinks are between two saccades
                        for e = 0:fin-1
                                previndx         = find(events.index(1,end-e)-events.index(2,:)<=limitbetween & events.index(1,end-e)-events.index(2,:)>0);                    % limit 5 samples (10 ms)?
                                postindx         = find(events.index(1,:)-events.index(2,end-e)<=limitbetween & events.index(1,:)-events.index(2,end-e)>0); 
                                if ~isempty(previndx) && ~isempty(postindx)
                                    events.posendx(:,previndx)  = events.posendx(:,postindx);
                                    events.posendy(:,previndx)  = events.posendy(:,postindx);
                                    events.index(2,previndx)    = events.index(2,postindx);
                                    events.end(1,previndx)      = events.end(1,postindx);
                                    events.pupil_m(previndx)    = NaN;
                                    events.pupil_std(previndx)  = NaN;
                                    events.pupil_max(previndx)  = NaN;
                                    events.pupil_min(previndx)  = NaN;
                                    events.pv(:,previndx)       = NaN;
                                    events.type(:,previndx)     = 4;
                                    events.type(:,end-e)        = 5;
                                    events = struct_elim(events,postindx,2,0);
                                end
                        end
                    end

                    %%%% Fixations and relationship between events
                    if trial(trllop).(LR{l}).fixation.start ~= 0
                        auxindexs = events.index(:,(events.type==2 | events.type==3 | events.type==4));
                        [B,IX] = sort(auxindexs(1,:));
                        auxindexs = auxindexs(:,IX);
                        if auxindexs(1)~=dsample && dsample~=0
                            allindx             = [dsample+1;auxindexs(:);size(posvec,1)+dsample];
                            auxdif              = diff(allindx);
                            fixaux              = find(auxdif(1:2:end)>limitfix);
                            fixs                = [allindx(fixaux*2-1)'+1;allindx(fixaux*2)'-1];
                        else
                            allindx             = [auxindexs(:);size(posvec,1)+dsample];
                            auxdif              = diff(allindx);
                            fixaux              = find(auxdif(2:2:end)>limitfix);
                            fixs                = [allindx(fixaux*2)'+1;allindx(fixaux*2+1)'-1];
                        end
                            events.index        = [events.index, fixs ];
                            events.type         = [events.type,ones(1,length(fixaux))];
                            events.start        = [events.start,time(fixs(1,:))];
                            events.end          = [events.end,time(fixs(2,:))];
                            events.posinix      = [events.posinix,posvec(fixs(1,:)-dsample,1)'];
                            events.posiniy      = [events.posiniy,posvec(fixs(1,:)-dsample,2)'];
                            events.posendx      = [events.posendx,posvec(fixs(2,:)-dsample,1)'];
                            events.posendy      = [events.posendy,posvec(fixs(2,:)-dsample,2)'];
                            events.pv           = [events.pv,ones(1,length(fixaux))*NaN];
                            events.event_order  = [events.event_order,1:length(fixs)];
                            for e = 1:length(fixaux)
                            events.pupil_m       = [events.pupil_m,mean(pupil(fixs(1,e):fixs(2,e)))];
                            events.pupil_std     = [events.pupil_std,std(pupil(fixs(1,e):fixs(2,e)))];
                            events.pupil_max     = [events.pupil_max,max(pupil(fixs(1,e):fixs(2,e)))];
                            events.pupil_min     = [events.pupil_min,min(pupil(fixs(1,e):fixs(2,e)))];
                            events.posx           = [events.posx,median(posvec(fixs(1,e)-dsample:fixs(2,e)-dsample,1))];                     
                            events.posy           = [events.posy,median(posvec(fixs(1,e)-dsample:fixs(2,e)-dsample,2))];                     
                            end
                    end   

                else % no recalculate
                    % saccades
                    if sum(abs(trial(trllop).(LR{l}).saccade.start))>0
                        [c, stindx]          = intersect(time,single(trial(trllop).(LR{l}).saccade.start));                      %%% check if it works always, sometimes parser calculation fall between time 
                        if length(c)<length(trial(trllop).(LR{l}).saccade.start)          % if it does not find the start of the first saccade in sample data
                            f = 2;
                        else
                            f = 1;
                        end
                        [c, endindx]         = intersect(time,single(trial(trllop).(LR{l}).saccade.end(f:end)));
                        if length(c)<length(trial(trllop).(LR{l}).saccade.end(f:end))          % if it does not find the start of the first saccade in sample data
                            fe = 1;
                            stindx(end) = [];
                        else
                            fe = 0;
                        end
                        events.posinix       = trial(trllop).(LR{l}).saccade.sx(f:end-fe);
                        events.posiniy       = trial(trllop).(LR{l}).saccade.sy(f:end-fe);
                        events.posendx       = trial(trllop).(LR{l}).saccade.ex(f:end-fe);
                        events.posendy       = trial(trllop).(LR{l}).saccade.ey(f:end-fe);
                        events.posx          = ones(1,length(trial(trllop).(LR{l}).saccade.start(f:end-fe)))*NaN;
                        events.posy          = ones(1,length(trial(trllop).(LR{l}).saccade.start(f:end-fe)))*NaN;

                        events.index         = [stindx';endindx'];
                        events.start         = single(trial(trllop).(LR{l}).saccade.start(f:end-fe));
                        events.end           = single(trial(trllop).(LR{l}).saccade.end(f:end-fe));
                        events.pv            = trial(trllop).(LR{l}).saccade.speed(f:end-fe);
                        for e = 1:length(stindx)
                            events.pupil_m       = [events.pupil_m,mean(pupil(stindx(e):endindx(e)))];
                            events.pupil_std     = [events.pupil_std,std(pupil(stindx(e):endindx(e)))];
                            events.pupil_max     = [events.pupil_max,max(pupil(stindx(e):endindx(e)))];
                            events.pupil_min     = [events.pupil_min,min(pupil(stindx(e):endindx(e)))];
                        end
                        events.event_order   = 1:length(stindx);
                        events.type          = 2*ones(1,length(stindx));
                    end
                    %%%% Blinks
                    if ~isempty(trial(trllop).(LR{l}).blink.start)           % this is not very clear to me know the saccade include the blink or the blink is flanked by two non-existing saccades?
                        if sum(abs(trial(trllop).(LR{l}).blink.start))>0
                            [c, stindx]          = intersect(time,single(trial(trllop).(LR{l}).blink.start));                      % check if it works always, sometimes parser calculation fall between time 
                            if length(c)<length(trial(trllop).(LR{l}).blink.start)
                                f = 2;
                            else
                                f = 1;
                            end
                            [c, endindx]         = intersect(time,single(trial(trllop).(LR{l}).blink.end(f:end)));
                            if length(c)<length(trial(trllop).(LR{l}).blink.end(f:end))
                                fe = 1;
                                stindx(end) = [];
                            else
                                fe = 0;
                            end
                            events.posinix       = [events.posinix,NaN(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))];
                            events.posiniy       = [events.posiniy,NaN(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))];
                            events.posendx       = [events.posendx,NaN(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))];
                            events.posendy       = [events.posendy,NaN(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))];
                            events.posx          = [events.posx,ones(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))*NaN];
                            events.posy          = [events.posy,ones(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))*NaN];
                            events.pv            = [events.pv,ones(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))*NaN];
                            events.pupil_m       = [events.pupil_m,NaN(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))];
                            events.pupil_std     = [events.pupil_std,NaN(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))];
                            events.pupil_max     = [events.pupil_max,NaN(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))];
                            events.pupil_min     = [events.pupil_min,NaN(1,length(trial(trllop).(LR{l}).blink.start(f:end-fe)))];
                            events.index         = [events.index,[stindx';endindx']];
                            events.start         = [events.start,single(trial(trllop).(LR{l}).blink.start(f:end-fe))];
                            events.end           = [events.end,single(trial(trllop).(LR{l}).blink.end(f:end-fe))];
                            events.event_order   = [events.event_order,1:length(trial(trllop).(LR{l}).blink.start(f:end-fe))];
                            events.type          = [events.type,3*ones(1,length(stindx))];

                            for e = 0:length(c)-1       %TODO: remove saccades that are to close to blinks and blinks events that are missing data
                                previndx         = find(events.index(1,end-e)-events.index(2,:)<=limitbetween & events.index(1,end-e)-events.index(2,:)>0);                    % limit 5 samples (10 ms)?
                                postindx         = find(events.index(1,:)-events.index(2,end-e)<=limitbetween & events.index(1,:)-events.index(2,end-e)>0); 
                                if ~isempty(previndx) && ~isempty(postindx)
                                    events.posendx(:,previndx)  = events.posendx(:,postindx);
                                    events.posendy(:,previndx)  = events.posendy(:,postindx);
                                    events.index(2,previndx)    = events.index(2,postindx);
                                    events.end(1,previndx)      = events.end(1,postindx);
                                    events.pupil_m(previndx)    = NaN;
                                    events.pupil_std(previndx)  = NaN;
                                    events.pupil_max(previndx)  = NaN;
                                    events.pupil_min(previndx)  = NaN;
                                    events.pv(:,previndx)       = NaN;
                                    events.type(:,previndx)     = 4;
                                    events.type(:,end-e)        = 5;
                                    events                      = struct_elim(events,postindx,2,0);
                                end
                            end
                        end
                    end

                    % fixations
                    if sum(abs(trial(trllop).(LR{l}).fixation.start))>0
                        [c, stindx]          = intersect(time,single(trial(trllop).(LR{l}).fixation.start));                      %%% check if it works always, sometimes parser calculation fall between time 
                        if length(c)<length(trial(trllop).(LR{l}).fixation.start)          % if it does not find the start of the first saccade in sample data
                            f = 2;
                        else
                            f = 1;
                        end
                        [c, endindx]         = intersect(time,single(trial(trllop).(LR{l}).fixation.end(f:end)));
                        if length(c)<length(trial(trllop).(LR{l}).fixation.end(f:end))          % if it does not find the start of the first saccade in sample data
                            fe = 1;
                            stindx(end) = [];
                        else
                            fe = 0;
                        end
                        events.posx          = [events.posx,trial(trllop).(LR{l}).fixation.x(f:end-fe)];
                        events.posy          = [events.posy,trial(trllop).(LR{l}).fixation.y(f:end-fe)];

                        events.index         = [events.index,[stindx';endindx']];
                        events.posinix       = [events.posinix,trial(trllop).(LR{l}).samples.x(stindx)];
                        events.posiniy       = [events.posiniy,trial(trllop).(LR{l}).samples.y(stindx)];
                        events.posendx       = [events.posendx,trial(trllop).(LR{l}).samples.x(endindx)];
                        events.posendy       = [events.posendy,trial(trllop).(LR{l}).samples.y(endindx)];
                        events.start         = [events.start,single(trial(trllop).(LR{l}).fixation.start(f:end-fe))];
                        events.end           = [events.end,single(trial(trllop).(LR{l}).fixation.end(f:end-fe))];
                        events.pv            = [events.pv,ones(1,length(trial(trllop).(LR{l}).fixation.start(f:end-fe)))*NaN];
                        for e = 1:length(stindx)
                            events.pupil_m       = [events.pupil_m,mean(pupil(stindx(e):endindx(e)))];
                            events.pupil_std     = [events.pupil_std,std(pupil(stindx(e):endindx(e)))];
                            events.pupil_max     = [events.pupil_max,max(pupil(stindx(e):endindx(e)))];
                            events.pupil_min     = [events.pupil_min,min(pupil(stindx(e):endindx(e)))];
                        end

                        events.event_order   = [events.event_order,1:length(stindx)];
                        events.type          = [events.type,ones(1,length(stindx))];
                    end    


                end
                        % general data 
                    if ~isempty(events.start)
                        events.dur           = events.end-events.start;
                        [THETA,RHO]          = cart2pol(events.posendx-events.posinix,...
                                                events.posendy-events.posiniy);
                        events.amp           = RHO/cfg.resolution;
                        events.angle         = (THETA*180)./pi;
                        events.trial         = trllop.*ones(1,length(events.dur(:)));
                        [B,IX]              = sort(events.index(1,:));
                        events              = struct_realign(events,IX,2);
                        noinsideblink       = find(events.type~=5 & events.type~=3);
                        auxindexs           = events.index(:,noinsideblink);
                        auxdif              = diff(auxindexs(:));
                        events.pre = ones(1,length(events.type))*NaN;
                        events.next = ones(1,length(events.type))*NaN;
                        if length(noinsideblink)>1
                        events.pre(noinsideblink(logical([0;auxdif(2:2:end)<limitbetween])))=-(noinsideblink(logical([0;auxdif(2:2:end)<limitbetween]))-noinsideblink(logical(auxdif(2:2:end)<limitbetween)));
                        events.next(noinsideblink(auxdif(2:2:end)<limitbetween))=noinsideblink(logical([0;auxdif(2:2:end)<limitbetween]))-noinsideblink(logical(auxdif(2:2:end)<limitbetween));
                        end
                    end

                if length(loopeyes)==1 || (length(loopeyes)==2 && l==1)
                   eye1.events = struct_cat(eye1.events,events,2); 
                else
                   eye2.events = struct_cat(eye2.events,events,2);
                end
            end
         catch problem
             display(sprintf('\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'))
             display(sprintf('\nTrial %d skipped',trllop))
             display(sprintf('Error in %s at %d',problem.stack.name,problem.stack.line))
             display(sprintf('%s',problem.message))
             display(sprintf('\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'))
%              save_log([datestr(now) sprintf('   - Error in %s at %d :
%              "%s"',problem.stack.name,problem.stack.line,problem.message) sprintf(' - Trial %d skipped in file %s',trllop,filetoread(1:end-4)) 'eye.mat' ] ,[cfg.logfolder filetoread(1:end-4) ,'.log'])
         end
    end
end

% trigerrs & others
% relationship between events in the same trial

fnames = fieldnames(trial);
marks = struct('value',[],'time',[],'type',[],'trial',[]);
for trllop = 1:length(trial)
    for e = 1:length(fnames)
        if ~strcmp(fnames{e},'left') && ~strcmp(fnames{e},'right')
            if strcmp(fnames{e},'button')
                marks.value        = [marks.value, trial(trllop).(fnames{e}).code];
                marks.time         = [marks.time,single(trial(trllop).(fnames{e}).time)];
                marks.type         = [marks.type,repmat({'button'},1,length(trial(trllop).(fnames{e}).time))];
                marks.trial        = [marks.trial,trllop];
            elseif strcmp(fnames{e},'write')
                marks.value        = [marks.value,str2double(cellstr(trial(trllop).(fnames{e}).msg(:,26:end)))'];
                marks.time         = [marks.time,single(trial(trllop).(fnames{e}).time)];
                marks.type         = [marks.type,repmat({'ETtrigger'},1,length(trial(trllop).(fnames{e}).time))];
                marks.trial        = [marks.trial,repmat(trllop,1,length(trial(trllop).(fnames{e}).time))];
            else
                if isstruct(trial(trllop).(fnames{e}))
                    marks.value        = [marks.value, str2double(trial(trllop).(fnames{e}).msg)];
                    marks.time         = [marks.time,single(trial(trllop).(fnames{e}).time)];
                    marks.type         = [marks.type,repmat(fnames(e),1,length(trial(trllop).(fnames{e}).time))];
                    marks.trial        = [marks.trial,repmat(trllop,1,length(trial(trllop).(fnames{e}).time))];
                end
            end
        end
    end
end

if length(loopeyes)==1
    eyedata     = eye1;
    eyedata.eye = LR{l};
    if loopeyes==2
        eyedata.samples = eye2.samples;
    end
else
    auxtrl = [0 cumsum(selecteye(1,:))];
    for e =1:size(selecteye,2)
        if selecteye(2,e)==1
            E = struct_select(eye1.events,{'trial','trial'},{sprintf('> %d',auxtrl(e)),sprintf('< %d',auxtrl(e+1)+1)},2);
            S = struct_select(eye1.samples,{'trial','trial'},{sprintf('> %d',auxtrl(e)),sprintf('< %d',auxtrl(e+1)+1)},2);
        elseif selecteye(2,e)==2
            E = struct_select(eye2.events,{'trial','trial'},{sprintf('> %d',auxtrl(e)),sprintf('< %d',auxtrl(e+1)+1)},2);
            S = struct_select(eye2.samples,{'trial','trial'},{sprintf('> %d',auxtrl(e)),sprintf('< %d',auxtrl(e+1)+1)},2);
        end
        eyedata.events = struct_cat(eyedata.events,E,2);
        eyedata.samples = struct_cat(eyedata.samples,S,2);
    end
end

if isfield(cfg,'imagefield')
    eyedata.events.image = zeros(1,length(eyedata.events.trial));
    for trllop = 1:length(trial)
        eyedata.events.image(eyedata.events.trial==trllop) = repmat(marks.value((strcmp(marks.type,cfg.imagefield) & marks.trial==trllop)),1,length(find(eyedata.events.trial==trllop))); 
    end
end

if isfield(cfg,'conditionfield')
    eyedata.events.condition = zeros(1,length(eyedata.events.trial));
    for trllop = 1:length(trial)
        if length(cfg.conditionfield)==1
            eyedata.events.condition(eyedata.events.trial==trllop) = repmat(marks.value((strcmp(marks.type,cfg.conditionfield) & marks.trial==trllop)),1,length(find(eyedata.events.trial==trllop))); 
        else
            value = marks.value(strcmp(marks.type,cfg.conditionfield{1}) & marks.trial==trllop);
            eyedata.events.condition(eyedata.events.trial==trllop) = repmat(value(cfg.conditionfield{2}),1,length(find(eyedata.events.trial==trllop))); 
        end
    end
end

eyedata.marks   = marks;
eyedata.meta    = metainfo;

% adding all marks fields that can be informative to the event structure,
% will work only for numeric data for now
mfields         = unique(eyedata.marks.type);
mfields         = mfields(~strcmp('ETtrigger',mfields));

% for f = 1:length(mfields)
%     eyedata.events.(mfields{f}) = zeros(1,length(eyedata.events.trial));
%     for trllop = 1:length(trial)
%         eyedata.events.(mfields{f})(eyedata.events.trial==trllop) = repmat(marks.value((strcmp(marks.type,mfields{f}) & marks.trial==trllop)),1,length(find(eyedata.events.trial==trllop))); 
%     end
% end

