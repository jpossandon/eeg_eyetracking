function [hilbert_data,toelim] = getHilbertfromtrl(cfgs,trls,bp_freq,resamplef)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [hilbert_data] = getHilbertfromtrl(cfgs,trls)
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for e = 1:length(trls)
    cfg          = cfgs{e};
    cfg          = correct_channels(cfg);
    trl          = trls{e};
    [trl toel]   = clean_bad(cfg, trl);
    toelim{e}    = toel;     
    
    %    cfge            = basic_preproc_cfg(cfg,cfg.event,'lpfilter','yes','lpfreq',40,'demean','yes'); %check
    cfge         = basic_preproc_cfg(cfg, cfg.event,'bpfilter','yes','bpfreq',bp_freq);
    cfge.trl     = double(trl);
    data         = ft_preprocessing(cfge);                                % correct saccades to the left valid trials

    if ~isempty(resamplef)
        cfgr.resamplefs     = 250;
        cfgr.detrend        = 'no';
        [data]              = ft_resampledata(cfgr, data);
    end

    for t=1:length(data.trial)
        hilb_aux                         = hilbert(data.trial{t}')';
        hilbert_data(e).env{t}           = abs(hilb_aux);
        hilbert_data(e).phase{t}         = angle(hilb_aux);
    end
    hilbert_data(e).time        = data.time{1};
end
