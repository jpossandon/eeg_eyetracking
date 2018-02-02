function [trial,meta] =totrial(filename,datafields)
% filename = '/Users/jossando/trabajo/nystagmus/data/s03/s03.edf';
% filename = '/Users/jossando/trabajo/E275/data/s20/s20.edf';
% datafields = {'raw','gaze'}
dac         = Edf2Mat(filename);

meta.sF     = dac.RawEdf.RECORDINGS(1).sample_rate;
meta.raw    = dac.Header.raw;

% loop through messages

trialIDs  = strmatch('TRIALID', dac.Events.Messages.info);
synctimes = strmatch('SYNCTIME', dac.Events.Messages.info);

if isempty(synctimes)
    display(sprintf('\n\nNO SYNTCTIMES\n\n'))
else
    if length(trialIDs)~=length(synctimes)
        error('TRIALID does not match SYNCTIME')
    end
end
messages  = strmatch('METATR', dac.Events.Messages.info);
if ~isempty(messages)
    mess      = regexp(dac.Events.Messages.info(messages),' ','split')';
    mess      = cat(1,mess{:});
    mess      = mess(:,2:end);
    messtime  = dac.Events.Messages.time(messages);
    messfield = (unique(mess(:,1)));
end
% triggers  = strmatch('!CMD 0 write_ioport', dac.Events.Messages.info);
triggers  = find(~cellfun(@isempty,regexp(dac.Events.Messages.info,'write_ioport')));
if ~isempty(triggers)
    trig      = regexp(dac.Events.Messages.info(triggers),' ','split')';
    trig      = cat(1,trig{:});
    trig      = trig(:,end);
    trigtime  = dac.Events.Messages.time(triggers);
%     trigfield = (unique(trig(:,1)));
end
for m = 1:length(trialIDs)
    t1 = dac.Events.Messages.time(trialIDs(m));
    
    if m == length(trialIDs)
        t2 = dac.Samples.time(end);    
    else
        t2 = dac.Events.Messages.time(trialIDs(m+1));
    end
    sampleindx      = find(dac.Samples.time>t1 & dac.Samples.time<t2);
    if isempty(synctimes)
        synctT      = 0;
        lag         = 0;
    else
        synctT      = dac.Events.Messages.time(synctimes(m));
        % when there is something after SYNCTIME is shopuld be delay between
        % message and actual trial start
        [a b] = strtok(dac.Events.Messages.info{synctimes(m)});
        if isempty(b)
            lag = 0;
        else
            lag = abs(str2num(rem));
        end
    end
    for ey = 1:2
        if ey==1
            ojo = 'left';
        else
            ojo = 'right';
        end
        
        indxfixevents = dac.Events.Efix.start>t1 & dac.Events.Efix.start<t2;
        if strcmp(upper(ojo),dac.Events.Start.eye{m}) || strcmp('BINOCULAR',dac.Events.Start.eye{m})
            fixevents = indxfixevents & strncmpi(ojo,dac.Events.Efix.eye,5);
            trial(m).(ojo).fixation.start   = dac.Events.Efix.start(fixevents)-synctT-lag;
            trial(m).(ojo).fixation.end     = dac.Events.Efix.end(fixevents)-synctT-lag;
            trial(m).(ojo).fixation.x       = dac.Events.Efix.posX(fixevents);
            trial(m).(ojo).fixation.y       = dac.Events.Efix.posY(fixevents);
            trial(m).(ojo).fixation.dur     = dac.Events.Efix.duration(fixevents);
            trial(m).(ojo).fixation.pupil   = dac.Events.Efix.pupilSize(fixevents);
        end
        
        indxsacevents = dac.Events.Esacc.start>t1 & dac.Events.Esacc.start<t2;
        if strcmp(upper(ojo),dac.Events.Start.eye{m}) || strcmp('BINOCULAR',dac.Events.Start.eye{m})
            sacevents = indxsacevents & strncmpi(ojo,dac.Events.Esacc.eye,5);
            trial(m).(ojo).saccade.start    = dac.Events.Esacc.start(sacevents)-synctT-lag;
            trial(m).(ojo).saccade.sx       = dac.Events.Esacc.posX(sacevents);
            trial(m).(ojo).saccade.sy       = dac.Events.Esacc.posY(sacevents);
            trial(m).(ojo).saccade.end      = dac.Events.Esacc.end(sacevents)-synctT-lag;
            trial(m).(ojo).saccade.ex       = dac.Events.Esacc.posXend(sacevents);
            trial(m).(ojo).saccade.ey       = dac.Events.Esacc.posYend(sacevents);
            trial(m).(ojo).saccade.speed    = dac.Events.Esacc.pvel(sacevents);
            trial(m).(ojo).saccade.dur      = dac.Events.Esacc.duration(sacevents);
            trial(m).(ojo).saccade.amp      = dac.Events.Esacc.hypot(sacevents);
        end
        
        indxblinkevents = dac.Events.Eblink.start>t1 & dac.Events.Eblink.start<t2;
        if strcmp(upper(ojo),dac.Events.Start.eye{m}) || strcmp('BINOCULAR',dac.Events.Start.eye{m})
            blinkevents = indxblinkevents & strncmpi(ojo,dac.Events.Eblink.eye,5);
            trial(m).(ojo).blink.start      = dac.Events.Eblink.start(blinkevents)-synctT-lag;
            trial(m).(ojo).blink.end        = dac.Events.Eblink.end(blinkevents)-synctT-lag;
            trial(m).(ojo).blink.dur        = dac.Events.Eblink.duration(blinkevents);
        end
        
        
        if isfield(dac.Samples,'gx') && any(strcmp('gaze',datafields)) % gaze data
            if length(unique(dac.Samples.gx(:,ey)))>1
                trial(m).(ojo).samples.x        = dac.Samples.gx(sampleindx,ey)';
                trial(m).(ojo).samples.y        = dac.Samples.gy(sampleindx,ey)';
                trial(m).(ojo).samples.xvel     = dac.Samples.gxvel(sampleindx,ey)'; % TODO: check what is 'fast' velocity (not this one)
                trial(m).(ojo).samples.yvel     = dac.Samples.gyvel(sampleindx,ey)';
            end
        end

        if isfield(dac.Samples,'px') && any(strcmp('raw',datafields))% raw data
            if length(unique(dac.Samples.px(:,ey)))>1
                trial(m).(ojo).samples.rawx     = dac.Samples.px(sampleindx,ey)';
                trial(m).(ojo).samples.rawy     = dac.Samples.py(sampleindx,ey)';
                trial(m).(ojo).samples.rawxvel  = dac.Samples.rxvel(sampleindx,ey)';
                trial(m).(ojo).samples.rawyvel  = dac.Samples.ryvel(sampleindx,ey)';
                  trial(m).(ojo).samples.rx  = dac.Samples.rx(sampleindx,1)';
                trial(m).(ojo).samples.ry  = dac.Samples.ry(sampleindx,1)';
            end
        end

        if isfield(dac.Samples,'hx') && any(strcmp('HREF',datafields))% HREF data
            if length(unique(dac.Samples.hx(:,ey)))>1
                trial(m).(ojo).samples.hrefx    = dac.Samples.hx(sampleindx,ey)';
                trial(m).(ojo).samples.hrefy    = dac.Samples.hy(sampleindx,ey)';
                trial(m).(ojo).samples.hrefxvel = dac.Samples.hxvel(sampleindx,ey)';
                trial(m).(ojo).samples.hrefyvel = dac.Samples.hyvel(sampleindx,ey)';
            end
        end
        if exist('trial')
            if  isfield(trial,ojo)
                trial(m).(ojo).samples.time         = dac.Samples.time(sampleindx)'-synctT-lag;
                trial(m).(ojo).samples.pctime       = dac.Samples.time(sampleindx)';
                trial(m).(ojo).samples.pupil        = dac.Samples.pa(sampleindx,ey)';
            end
        end
    end
    if ~isempty(messages)
        for mf = 1:length(messfield)
            indxfield   = find(strncmpi(messfield{mf},mess(:,1),20));
            indx        = indxfield(find(messtime(indxfield)>t1 & messtime(indxfield)<t2));
            if isempty(indx)
                trial(m).(messfield{mf}) = [];
            else
                trial(m).(messfield{mf}).time = messtime(indx)-synctT-lag;
                trial(m).(messfield{mf}).pctime = messtime(indx);
                trial(m).(messfield{mf}).msg  = cell2mat(mess(indx,2));
            end
        end
    end
    if ~isempty(triggers)
        indx        = find(trigtime>t1 & trigtime<t2);

        if isempty(indx)
            trial(m).trigger = [];
        else
            trial(m).trigger.time = trigtime(indx)-synctT-lag;
            trial(m).trigger.pctime = trigtime(indx);
            trial(m).trigger.value  = str2double(trig(indx));
        end

    end
 end