function [data] = reref_prepro(cfg, data)

%re-references data that was preprocessed in fieldtrip. input [data] is a structure obtained with 
%fieldtrip's "preprocessing" function.
%cfg.refchannel = channel(s) used as reference (default all channels)

dat = data.trial;

if isfield(cfg, 'refchannel')
    sel = cfg.refchannel;
else
    sel = length(data.label);
end

if isfield(cfg, 'torefchannel')
    for reflop = 1:length(dat)
        dat2 = dat{reflop}(cfg.torefchannel,:);
        data.trial{reflop}(cfg.torefchannel,:) = avgref(dat2, sel);    
    end
        
else
    for reflop = 1:length(dat)
    data.trial{reflop} = avgref(dat{reflop}, 1:sel);    
    end
end





