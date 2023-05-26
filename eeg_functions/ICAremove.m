function [cleandata comp]= ICAremove(data,cfg_ica,badcomp,datalabel,refchan,torefchan)

if length(intersect(datalabel,cfg_ica.topolabel))<length(union(datalabel,cfg_ica.topolabel))
    error('Channels in data do not match channels in ICA decomp')
end

cfg_ica.channel = 1:length(datalabel);
cfg_ica         = rmfield(cfg_ica,'topo'); % to avoid unnecessarty warnings from fieldtrip
comp            = ft_componentanalysis(cfg_ica,data);
cfgr.component  = badcomp;
cleandata       = ft_rejectcomponent(cfgr, comp);

if ~isempty(refchan) && ~isempty(torefchan)
   cfgr              = [];
   cfgr.refchannel   = refchan;
   cfgr.torefchannel = torefchan;
   cleandata         = reref_prepro(cfgr, cleandata); 
end