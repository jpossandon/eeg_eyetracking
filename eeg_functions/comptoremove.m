function [ratio] = comptoremove(cfg,cfg_ica,event_file,eyedata)

% cfge = basic_preproc_cfg(cfg,event_file);
cfge                            = basic_preproc_cfg(cfg,cfg.event,'lpfilter','yes','lpfreq',cfg.lpfreq,'demean','yes');
% load([cfg.eyeanalysisfolder cfg.EDFname(1:end-4) 'eye'])

[trlfix,eventfix]       = define_event(cfg,eyedata,1,{'dur','>20'},[10 1000]);
trlfix(:,2)             =[trlfix(:,1)+eventfix.dur'+10];
[trlsacaux,eventsacaux] = define_event(cfg,eyedata,2,{'amp','>2.5'},[10 1000]);   % rather long saccades work better
trlsac                  =[trlsacaux(:,1) trlsacaux(:,1)+[eventsacaux.dur]'+10 trlsacaux(:,3)];
[trlblink,eventsblink]  = define_event(cfg,eyedata,3,{'dur','>20'},[10 1000]);
if ~isempty(trlblink)
    trlsac              = [trlsac;[trlblink(:,1),trlblink(:,1)+[eventsblink.dur]'+10,trlblink(:,3)]];
end
[trlsacaux,eventsacaux] = define_event(cfg,eyedata,4,{'dur','>20'},[10 1000]);
if ~isempty(trlsacaux)
    trlsac              = [trlsac;[trlsacaux(:,1),trlsacaux(:,1)+[eventsacaux.dur]'+10,trlsacaux(:,3)]];
end

cfge.trl            = double(trlfix);
fxn                 = ft_preprocessing(cfge);
if ~isempty(cfg.correct_chan)
    for e=1:length(fxn.trial)
        fxn.trial{e}    = fxn.trial{e}(cfg.correct_chan,:);
    end
end
if ~isempty(cfg.elim_chan)
    for e=1:length(fxn.trial)
        fxn.trial{e}(cfg.elim_chan,:) = [];
    end
    fxn.label(cfg.elim_chan,:) = [];
end
toelimfix           = elimtrl(fxn);
fxn.trial(toelimfix)= [];
fxn.time(toelimfix) = [];
fxn.cfg.trl(toelimfix,:) = [];

trlsac(diff(trlsac(:,1:2)')<20,:) = [];   % there is aproblem with the filtering with very small segments
cfge.trl            = double(trlsac);
sac                 = ft_preprocessing(cfge);
if ~isempty(cfg.correct_chan)
    for e=1:length(sac.trial)
        sac.trial{e}    = sac.trial{e}(cfg.correct_chan,:);
    end
end
if ~isempty(cfg.elim_chan)
    for e=1:length(sac.trial)
        sac.trial{e}(cfg.elim_chan,:) = [];
    end
    sac.label(cfg.elim_chan,:) = [];
end
toelimsac           = elimtrl(sac);
sac.trial(toelimsac)= [];
sac.time(toelimsac) = [];
sac.cfg.trl(toelimsac,:) = [];
% 
cfge                = [];
cfge.resamplefs     = 500;
cfge.detrend        = 'no';
sac                 = ft_resampledata(cfge, sac);
cfge.detrend        = 'yes';                    %change to detrend in fix periods, otherwise dc shifts can increase the variance artificially
fxn                 = ft_resampledata(cfge, fxn);
        
[cmpsac]            = ft_componentanalysis(cfg_ica, sac);
[cmpfix]            = ft_componentanalysis(cfg_ica, fxn);
% sacmat = cell2mat(cmpsac.trial);
% fixmat = cell2mat(cmpfix.trial);
varsac = zeros(length(cmpsac.label),length(cmpsac.trial));
for e=1:length(cmpsac.trial)
    for comp =1:length(cmpsac.label)
    varsac(comp,e)=var(cmpsac.trial{e}(comp,:),1,2);
    end
end

varsfix = zeros(length(cmpfix.label),length(cmpfix.trial));
for e=1:length(cmpfix.trial)
    for comp =1:length(cmpfix.label)
    varsfix(comp,e)=var(cmpfix.trial{e}(comp,:),1,2);
    end
end
ratio        = mean(varsac,2)./mean(varsfix,2);
% cfg_ica.comptoremove = find(cfg_ica.ratio>1.1);