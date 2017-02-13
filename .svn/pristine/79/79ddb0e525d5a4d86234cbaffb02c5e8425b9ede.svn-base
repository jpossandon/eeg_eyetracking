function data = rebsl(data,bsltime)

if isfield(data,'individual')
    times = find(data.time>bsltime(1) & data.time<bsltime(2));
    aux_bsl         = repmat(mean(data.individual(:,:,times),3),[1 1 size(data.individual,3)]);
    data.individual = data.individual-aux_bsl; 
    data.avg        = squeeze(mean(data.individual));
    data.var        = squeeze(var(data.individual));
    
elseif isfield(data,'trial') & isfield(data,'avg')
    times = find(data.time>bsltime(1) & data.time<bsltime(2));
    aux_bsl         = repmat(mean(data.trial(:,:,times),3),[1 1 size(data.trial,3)]);
    data.trial = data.trial-aux_bsl; 
    data.avg        = squeeze(mean(data.trial));
    data.var        = squeeze(var(data.trial));
elseif isfield(data,'trial')
    for e = 1:length(data.trial)
        times           = find(data.time{e}>bsltime(1) & data.time{e}<bsltime(2));        
        aux_bsl         = repmat(mean(data.trial{e}(:,times),2),[1 size(data.trial{e},2)]);
        data.trial{e}   = data.trial{e}-aux_bsl;
    end
elseif isfield(data,'powspctrm')
    times           = find(data.time>bsltime(1) & data.time<bsltime(2));
    aux_bsl         = repmat(nanmean(data.powspctrm(:,:,times),3),[1 1 size(data.powspctrm, 3)]);
    data.powspctrm  = data.powspctrm./aux_bsl; % this si fieltrip 'relative' frequency baseline
else
    times = find(data.time>bsltime(1) & data.time<bsltime(2));
    aux_bsl         = repmat(mean(data.avg(:,times),2),[1 size(data.avg,2)]);
    data.avg        = data.avg-aux_bsl;
end