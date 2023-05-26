function stat = erp_stat(cfgc,data1,data2,type,subj,latency)

%
% type
%  BT  - Between condition data1 / data2 one subject
%  WS  - Within subjects two conditions (grand averages)
%  WT  - Within trial, comparison against baseline
% JPO
% between trials comparison

if strcmp(type,'BT')
    cfg = [];
    cfg.keeptrials = 'yes';
    if ~isfield(data1,'freq')
    if isfield(data1,'avg') & ~isfield(data1,'avg')
        error('stats need data structure with trials included')
    end
    if ~isfield(data1,'avg')
        data1     = ft_timelockanalysis(cfg, data1);
    end
    if ~isfield(data1,'avg')
        data2     = ft_timelockanalysis(cfg, data2);
    end
    end
%     data1TL     = rmfield(data1TL, 'dof'); 
%     data2TL     = rmfield(data2TL, 'dof'); 

    cfg = [];
    cfg.channel = {'all'};
    cfg.latency = latency;

    % this need to be changed to the corresponding electrode layout
    load(cfgc.chanfile)
    cfg.rotate = 0;
    cfg.elec = elec;

    cfg.method = 'montecarlo';
    cfg.statistic = 'indepsamplesT';
    cfg.correctm = 'cluster';
    cfg.clusteralpha = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.minnbchan = 2;
    cfg.tail = 0;
    cfg.clustertail = 0;
    cfg.alpha = 0.025;
    cfg.correcttail = 'prob';
    cfg.numrandomization = 1000;
    cfgrepair.neighbourdist = 5.5;            % check thsi value it might be too small for the 64 channel cap with larger coverage
    if ~isfield(data1,'freq')
    
        cfg.design=[ones(1,size(data1.trial,1)) 2*ones(1,size(data2.trial,1))];
    else
        cfg.design = [ones(1,size(data1.powspctrm,1)) 2*ones(1,size(data2.powspctrm,1))];
    end
    cfg.ivar  = 1;
 
%     cfgrepair.elec =elec;
%    cfgrepair.method         = 'distance';
%           cfg.neighbours = ft_prepare_neighbours(cfgrepair,data1);
cfg.neighbours = elec.neighbours;
    if ~isfield(data1,'freq')
        [stat] = ft_timelockstatistics(cfg, data1, data2);
    else
        [stat] = ft_freqstatistics(cfg, data1, data2);
    end
elseif strcmp(type,'WS')
    
    
    
    
    cfg = [];
    cfg.channel = {'all'};
    cfg.latency = latency;

    load(cfgc.chanfile)
    cfg.elec = elec;
    cfg.rotate = 0;
    cfg.method = 'montecarlo';
    cfg.statistic = 'ft_statfun_depsamplesT';
    cfg.correctm = 'cluster';
    cfg.clusteralpha = 0.01;
    cfg.clusterstatistic = 'maxsum';
    cfg.minnbchan = 2;
    cfg.tail = 0;
    cfg.clustertail = 0;
    cfg.alpha = 0.025;
    cfg.numrandomization = 1000;
    cfg.neighbours = elec.neighbours;
    design=zeros(2,2*subj);
    for i = 1:subj
      design(1,i) = i;
    end
    for i = 1:subj
      design(1,subj+i) = i;
    end
    design(2,1:subj)        = 1;
    design(2,subj+1:2*subj) = 2;

    cfg.design   = design;
    cfg.uvar  = 1;
    cfg.ivar  = 2;
    cfg.neighbourdist = 5.5;
 if ~isfield(data1,'freq')
        [stat] = ft_timelockstatistics(cfg, data1, data2);
    else
        [stat] = ft_freqstatistics(cfg, data1, data2);
    end    
elseif strcmp(type,'WT')
    cfg =[];
    cfg.toilim = latency(1,:);
    baseline = redefinetrial(cfg, data1);

    cfg = [];
    cfg.offset = latency(2,1)-latency(1,1)*data1.fsample;
    baseline = ft_redefinetrial(cfg, baseline);

    cfg = [];
    cfg.toilim = latency(2,:);
    data1 = ft_redefinetrial(cfg, data1);
    
    cfg = [];
    cfg.channel = {'all'};
    cfg.latency = 'all';

    cfg.method = 'montecarlo';
    cfg.statistic = 'actvsblT';
    cfg.correctm = 'cluster';
    cfg.clusteralpha = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.minnbchan = 2;
    cfg.tail = 0;
    cfg.clustertail = 0;
    cfg.alpha = 0.025;
    cfg.numrandomization = 1000;
cfg.neighbourdist = 5.5;
    ntrials = size(data1.individual,1);
    cfg.design = zeros(2,2*ntrials);
    cfg.design(1,:) = [ones(1,ntrials),ones(1,ntrials)*2];
    cfg.design(2,:) = [1:ntrials,1:ntrials];

    cfg.ivar  = 1;
    cfg.uvar  = 2;
    [stat] = timelockstatistics(cfg, data1, baseline);
end