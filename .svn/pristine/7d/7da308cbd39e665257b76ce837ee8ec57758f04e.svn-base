function fixmat = eeget2fixmat(cfg,eyetrl,subject)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fixmat = eeget2fixmat(cfg,eyetrl,subject)
% change from eyedata structure (all kind of events and the temporal
% relationship between them) to fixmat structure (only fixations) to use in
% condprob toolbox
%
% jpo 8/03/10 OSNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(cfg)
    if exist([cfg.eyeanalysisfolder cfg.EDFname '_fixmat.m'],'file')
        display([cfg.EDFname '_fixmat.m already exists']) 
        a=0;
    else
        a=1;
    end
else
    a=1;
end

if a
    indxfix = find(eyetrl.events.type==1);

    fixmat.start        = eyetrl.events.start(indxfix);
    fixmat.end          = eyetrl.events.end(indxfix);
    fixmat.x            = eyetrl.events.posx(indxfix);
    fixmat.y            = eyetrl.events.posy(indxfix);
    fixmat.fix          = eyetrl.events.event_order(1,indxfix);
    fixmat.subject      = repmat(subject,1,length(fixmat.start));
    fixmat.trial        = eyetrl.events.trial(1,indxfix);
    fixmat.origstart    = eyetrl.events.origstart(indxfix);
    fixmat.origend      = eyetrl.events.origend(indxfix);
    if isfield(eyetrl.events,'image')
        fixmat.image        = eyetrl.events.image(1,indxfix);
    end
    if isfield(eyetrl.events,'condition')
        fixmat.condition    = eyetrl.events.condition(1,indxfix);
    end

else
    fixmat=[];
end