function [eyedata] = feat2eye(cfg,eyedata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [eyedata] = feat2eye(cfg,eyedata)
% this function add to the eyedata structure the feature values at pos,
% posini and posend locations
%
%
% jpo, 8/03/10, OSNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for feat = 1:length(cfg.features)
    cd([cfg.featurefolder cfg.features{feat}])  
    eval(['eyedata.events.' cfg.features{feat} '_pos = NaN(1,length(eyedata.events.posx));']);
    eval(['eyedata.events.' cfg.features{feat} '_posini = NaN(1,length(eyedata.events.posinix));']);
    eval(['eyedata.events.' cfg.features{feat} '_posend = NaN(1,length(eyedata.events.posendx));']);
    
    for e = unique(eyedata.events.image)
        load(sprintf('image_%03d.mat',e))
        indx    = find(eyedata.events.image==e & eyedata.events.type==1 & ...
            round(eyedata.events.posy)>0 & round(eyedata.events.posx)>0 & ...
            round(eyedata.events.posy)<cfg.imsize(1) & round(eyedata.events.posx)<cfg.imsize(2));
        
        IND     = sub2ind(cfg.imsize,round(eyedata.events.posy(indx)),round(eyedata.events.posx(indx)));
        eval(['eyedata.events.' cfg.features{feat} '_pos(indx) = f(IND);']);
        
        indx    = find(eyedata.events.image==e & (eyedata.events.type==1 |eyedata.events.type==2) & ...
            round(eyedata.events.posiniy)>0 & round(eyedata.events.posinix)>0 & ...
            round(eyedata.events.posiniy)<cfg.imsize(1) & round(eyedata.events.posinix)<cfg.imsize(2));
        
        IND     = sub2ind(cfg.imsize,round(eyedata.events.posiniy(indx)),round(eyedata.events.posinix(indx)));
        eval(['eyedata.events.' cfg.features{feat} '_posini(indx) = f(IND);']);
        
        indx    = find(eyedata.events.image==e & (eyedata.events.type==1 |eyedata.events.type==2) & ...
            round(eyedata.events.posendy)>0 & round(eyedata.events.posendx)>0 & ...
            round(eyedata.events.posendy)<cfg.imsize(1) & round(eyedata.events.posendx)<cfg.imsize(2));
        IND     = sub2ind(cfg.imsize,round(eyedata.events.posendy(indx)),round(eyedata.events.posendx(indx)));
        eval(['eyedata.events.' cfg.features{feat} '_posend(indx) = f(IND);']);
    end
end

save([cfg.eyeanalysisfolder cfg.EDFname(1:end-4) 'eye_feat'],'eyedata')
save_log([datestr(now) '   Saving file ' cfg.eyeanalysisfolder cfg.EDFname(1:end-4) 'eye_feat.mat' ] ,[cfg.logfolder cfg.EDFname(1:end-4) ,'.log'])