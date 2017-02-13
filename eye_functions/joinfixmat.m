function [allfixmat] = joinfixmat(cfg)

cfge         = eeg_etParams('sujid',sprintf('%03d',cfg.subjects(1)));
load([cfg.eyeanalysisfolder  cfge.EDFname(1:end-4) '_fixmat'])
allfixmat = fixmat;
for e= cfg.subjects(2:end)
    cfge         = eeg_etParams('sujid',sprintf('%03d',e));
    load([cfg.eyeanalysisfolder  cfge.EDFname(1:end-4) '_fixmat'])
    allfixmat = struct_cat(allfixmat,fixmat,2);
end
fixmat = allfixmat;
save([cfg.eyeanalysisfolder cfg.analysisname '_allsubjects_fixmat'],'fixmat')
