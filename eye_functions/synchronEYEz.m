
function [eyedata] = synchronEYEz(cfg, eyedata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [eyetrl] = synchronEYEzfinal(cfg, eyetrl)
% Synchronize eye-tracker and EEG data trial by trial
% 
% input -
%           cfg         : experimental parameters obtained with eeg_etParams
%           eyedata     : structure with eyemovements data obtained with
%                           eyeread.m
%           EDF_name    : name of the original eye-tracking EDF file,
%           cfg.event  : name of the corresponding eeg eventfile (*.vmrk)
%
% output -  
%           eyedata     : modified eyedata structure, now with the fields
%                           eyedata.samples.time and eyedata.marks.time
%                           with the corresponding time values of the eeg
%                           data. It keeps original ET-times in the fields  
%                           eyedata.events.origstart and eyedata.events.origend 
%           
%           it saves the eyedata structure in the file:
%               [cfg.eyeanalysisfolder EDF_name 'eye']
%
% JPO, OSNA 20/11/2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% if exist([cfg.eyeanalysisfolder cfg.filename 'eye.mat'],'file')
%     display([cfg.EDFname(1:end-4) '_eye.m already exists']) 
%     load([cfg.eyeanalysisfolder cfg.filename 'eye.mat'])
% else
    %read eeg-events and eyedata
    current = pwd;
%     cd([cfg.fieldtrippath 'private'])
    event  = ft_read_event([cfg.eegfolder cfg.event]);
    head =  ft_read_header([cfg.eegfolder cfg.filename '.vhdr']);
     
    cd(current)

    if length(cfg.trial_trig_eeg)>1
        begind_eeg = []; begind_et  = [];
        trllop     = [];

%         event(find(strcmp('New Segment', {event.type}))) = []
        for e = 1:length(cfg.trial_trig_eeg)
            begind_eeg          = [begind_eeg,find(strcmp(cfg.trial_trig_eeg{e}, {event.value}))];
        end

        for e = 1:length(cfg.trial_trig_et)
           begind_et = [begind_et,find(strcmp(eyedata.marks.type,'ETtrigger') & eyedata.marks.value==str2num(cfg.trial_trig_et{e}))];
           trllop    = [trllop,eyedata.marks.trial(find(strcmp(eyedata.marks.type,'ETtrigger') & eyedata.marks.value==str2num(cfg.trial_trig_et{e})))];
        end
      

        begind_eeg = sort(begind_eeg);
        begind_et  = sort(begind_et);
    else
        begind_eeg  = find(strcmp(cfg.trial_trig_eeg, {event.value}));
        begind_et   = find(strcmp(eyedata.marks.type,'ETtrigger') & eyedata.marks.value==str2num(cfg.trial_trig_et{1}));
        trllop      = eyedata.marks.trial(find(strcmp(eyedata.marks.type,'ETtrigger') & eyedata.marks.value==str2num(cfg.trial_trig_et{1})));
        
    end
%     trllop = 1:length(begind_eeg);  % 19.06.16 change for the case of incomlpete files when eye-tracking trials do not start from 0 or do not end in the right number of trials. So now trllop get defined according to the trial numbering of the eyedata file. This solution should be more general 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Exeptions, this of course is only valid for my experiment, but
    % anyways I am the only one that is going to ever use this code
         if strcmp(cfg.filename,'al04vz01')   % :(
             begind_et          = begind_et(2:end);  % the first trigger is missing in the marker file so we remove the corresponding triger from the eye-tracker data
             trllop             = trllop+1;
         elseif strcmp(cfg.filename,'al19vz04')
             begind_et          = begind_et(1:end-10); % the last ten trials were not save in the eeg file so we remove the corresponding trials from the ET file
         end
         
         if strfind(cfg.filename,'p3')       % there is no synctime associated to a blcok start so we select the first trigger in the block from both eye-tracking and eeg
             if strcmp(cfg.filename,'al06p301')   % first block of eeg data had only the first 40 events:(
                begind_eeg     = begind_eeg(41:50:end);
                begind_et      = begind_et(51:50:end);
                trllop         = 1:length(begind_eeg);
                trllop         = trllop+1;
             else         
                begind_eeg     = begind_eeg(1:50:end);
                begind_et      = begind_et(1:50:end);
                trllop         = 1:length(begind_eeg);
             end
         end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(begind_eeg)~=length(begind_et)
        error('Number of triggers in eye-tracker and eeg file do not match')
    end

    for tr = 1:length(begind_eeg)
        %determine the time difference (take sampling rates into account,
        %information in eeg files is in sample number and in the
        %eye-tracker file in time). times in eye movement data are
        %therefore translated to sample?
        timetosample = head.Fs./1000;
        begeeg  = cell2mat({event(begind_eeg(tr)).sample});
        begeye  = eyedata.marks.time(begind_et(tr));
        diff    = single(begeye - begeeg);

        %adjust eyedata times
%         eyedata.samples.diff                                  = diff;
        eyedata.samples.time(eyedata.samples.trial==trllop(tr))   =  round(eyedata.samples.time(eyedata.samples.trial==trllop(tr)).*timetosample)-diff;
        eyedata.marks.time(eyedata.marks.trial==trllop(tr))       =  round(eyedata.marks.time(eyedata.marks.trial==trllop(tr)).*timetosample)-diff;
        eyedata.events.origstart(eyedata.events.trial==trllop(tr))=  eyedata.events.start(eyedata.events.trial==trllop(tr));
        eyedata.events.start(eyedata.events.trial==trllop(tr))    =  round(eyedata.events.start(eyedata.events.trial==trllop(tr)).*timetosample)-diff;
        eyedata.events.origend(eyedata.events.trial==trllop(tr))  =  eyedata.events.end(eyedata.events.trial==trllop(tr));
        eyedata.events.end(eyedata.events.trial==trllop(tr))      =  round(eyedata.events.end(eyedata.events.trial==trllop(tr)).*timetosample)-diff;
    end
 
     if strcmp(cfg.filename,'al04vz01')   % :(
             eyedata.events    = struct_elim(eyedata.events,find(eyedata.events.trial==1),2,0);
             eyedata.samples    = struct_elim(eyedata.samples,find(eyedata.samples.trial==1),2,0);
             eyedata.marks      = struct_elim(eyedata.marks,find(eyedata.marks.trial==1),2,0);
    elseif strcmp(cfg.filename,'al19vz04')
             eyedata.events     = struct_elim(eyedata.events,find(eyedata.events.trial>trllop(end)),2,0);
             eyedata.samples    = struct_elim(eyedata.samples,find(eyedata.samples.trial>trllop(end)),2,0);
             eyedata.marks      = struct_elim(eyedata.marks,find(eyedata.marks.trial>trllop(end)),2,0);
    end
         
         if strfind(cfg.filename,'p3')       % there is no synctime associated to a blcok start so we select the first trigger in the block from both eye-tracking and eeg
             if strcmp(cfg.filename,'al06p301')   % first block of eeg data had only the first 40 events:(
                 eyedata.events    = struct_elim(eyedata.events,find(eyedata.events.trial==1),2,0);
                eyedata.samples    = struct_elim(eyedata.samples,find(eyedata.samples.trial==1),2,0);
                eyedata.marks      = struct_elim(eyedata.marks,find(eyedata.marks.trial==1),2,0);
             end
         end
% end