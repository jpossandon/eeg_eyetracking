function [trl,events] = define_event(cfg,eyedata,type,cond,time,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [trl,events] = define_event(cfg,eyedata,type,cond,time,varargin)
%
% input -
%           type     = (1) - Fix   (2) - Sac    (3) - Blink
%                       (4) - Sac with Blink inside (5) - Blink inside saccade
%                       'string' - i.e 'ETtrigger','trigger','button',etc
%
%           cond     = {'fieldname1',value;'fieldname2',value . . .}
%                       the first character in fieldname might be a & or | logical
%                       operator for intersection or union of that specific condition with the
%                       others. If nixed operator at the end the result is the intersection between the & and |
%                       conditions. No logical operator results in the intersection of
%                       all conditions
%
%           time     = [time_before_event_in_ms time_after_event_in_ms]
%           varargin = conditions pre or post events, first column correspond to
%                       event index relative to main event (i.e -1 : inmediately previous event)
%                       {-1,type,'Fieldname1',value;
%                       -1,type,'Fieldname2',value;
%                       -2,type,'Fieldname1',value ...}
%                       more than condition for one events has to be added
%                       as a new raw (as the first two rows in the example)
%                       For now it is only possible to select the
%                       intersection between events, events are given in
%                       the entry order
%                       EVENTS MUST BE GIVEN IN REVERSED TEMPORAL ORDER +1,-1,etc    
%
% output - 
%           trl      = trial times for using in fieldtrip preprocessing in the form:
%                       [start_time end_time latency_first_sample]
%
%           events   = selection of eyedata events, it includes possible pre or post
%                       events specified in varargin, in the corresponding
%                       order. So if the pre- or post event indexes are [-2
%                       -1 2], ther order of the events will be : -2 -1
%                       main_event 2 -2 -1 main_event 2 -2 ....
%
% jpo 08/03/10, OSNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isnumeric(type)
    main_event_indx = find(eyedata.events.type==type);
    select_indx     = main_event_indx;
    % ok for now to remove events around blinks, this does not seem to be
    % necessary so as i am getting data now, there is saccade that end
    % after the blink - blink - fixation, so i will remove only events
    % prior to blink, previos line was wrong, does not invalidate previous analysis but it was keepin saccades opre and removin fixation post 
    % also: -1 indicates to selected events that occur after a blink and +1 the other way aroub 
%      select_indx(find(eyedata.events.type(select_indx(2:end-1)-1)==3 | eyedata.events.type(select_indx(2:end-1)+1)==3)+1) = []; % this was wrong, removing only events after (beacuse of the +1) and the one wnat to remove is the previos one (the saccade)

     blink_indx = find(eyedata.events.type==3);
     %removes events occuring before a blink
    [~,IA] = intersect(select_indx,blink_indx-1);
    select_indx(IA) = [];
     %removes events occuring after a blink
%     [~,IA] = intersect(select_indx,blink_indx+1);
%     select_indx(IA) = [];
    
     or_indx         = [];
    for e = 1:size(cond,1)
        if strcmp(cond{e,1}(1),'|')
            eval(['auxindx = find(eyedata.events.(cond{e,1}(2:end))' cond{e,2} ');']); 
            or_indx = union(auxindx,or_indx);
        elseif strcmp(cond{e,1}(1),'&')
            eval(['auxindx = find(eyedata.events.(cond{e,1}(2:end))' cond{e,2} ');']); 
            select_indx = intersect(select_indx,auxindx);
        else  % if there si no logical operator it takes is as an AND
            eval(['auxindx = find(eyedata.events.(cond{e,1})' cond{e,2} ');']); 
            select_indx = intersect(select_indx,auxindx);
        end
    end
    if ~isempty(or_indx)
        if ~isrow(or_indx),or_indx = or_indx';,end
        select_indx = intersect(select_indx,or_indx);
    end
%      other_events = [];
    if ~isempty(varargin)
        
        for e = 1:size(varargin{1},1)
                aux = select_indx;
                for u = 1:abs(varargin{1}{e,1})
                    if u>1
                        select_indx     = select_indx(aux>0);           %looking for NaNs
                        if e>1
                            other_events    = other_events(:,aux>0);
                        end
%                          aux             = double(int16(aux(aux>0)));             % i do not knwo what this line was necessary but it obiously makes problem for index above (2^16)/2
                        aux             = double((aux(aux>0)));            
                   
                    end
                    if varargin{1}{e,1}<0
                        aux = aux+eyedata.events.pre(aux);
                    elseif varargin{1}{e,1}>0
                        aux = aux+eyedata.events.next(aux);
                    end
                end
                select_indx     = select_indx(aux>0);           %looking for NaNs
                if e>1
                    other_events    = other_events(:,aux>0);
                end
                aux             = int32(aux(aux>0));            % tis was before int16 so it did not work for long data structures
                select_indx     = select_indx(eyedata.events.type(aux)==varargin{1}{e,2});
                aux             = aux(eyedata.events.type(aux)==varargin{1}{e,2});
                eval(['auxindx = find(eyedata.events.(varargin{1}{e,3})(aux)' varargin{1}{e,4} ');']); 
                select_indx     = select_indx(auxindx);
                if e==1
                     other_events    = aux(:,auxindx);  
                elseif e>1
                    other_events    = other_events(:,auxindx);
                    if varargin{1}{e,1}==varargin{1}{e-1,1}
                        continue
                    else
                        other_events    = [other_events;aux(auxindx)];  
                    end
                end
%                 other_events    = [other_events,aux(auxindx)];  
        end
     
    end
    
    trl            = double([eyedata.events.start(select_indx)'-time(1),eyedata.events.start(select_indx)'+time(2),repmat(-time(1),length(select_indx),1)]);
    
    if isempty(trl)
        events = [];
    else
        if ~isempty(varargin) 
            [a,ordindx]    = sort([flipud(unique(cell2mat(varargin{1}(:,1))));0]);  %4.02.15 I change this, the order was updow, check if this change any analysis
            tap            = [other_events;select_indx];
            tap            = tap(ordindx,:);
            events         = struct_realign(eyedata.events,tap(:),2);
        else
            events         = struct_realign(eyedata.events,select_indx,2);
        end
    end
else
     select_indx  = find(strcmp(eyedata.marks.type,type));
    for e = 1:size(cond,1)
        eval(['auxindx = find(eyedata.marks.(cond{e,1})' cond{e,2} ');']); 
        select_indx = intersect(select_indx,auxindx);
    end
    trl = double([eyedata.marks.time(1,select_indx)'-time(1),eyedata.marks.time(1,select_indx)'+time(2),repmat(-time(1),length(select_indx),1)]);
    events = struct_realign(eyedata.marks,select_indx,2);
end