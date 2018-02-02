function fh = topomitlines(cfg,stat,diffFreq,plotinterval,collim,freqs)

%%
% topotime    = .02;
% betastoplot = [1];

% plotinterval = [st_end topotime];
topotime    = plotinterval(3);
plotTimes    = plotinterval(1):plotinterval(3):plotinterval(2);

sp_c        = length(plotTimes)-1;

% pclus       = find([stat.posclusters.prob]<.05);
% nclus       = find([stat.posclusters.prob]<.05);
% nplots      = [pclus,-nclus];
% times       = stat.time;
% butall      = [];
% nSubj       = 1;
 if ndims(diffFreq.powspctrm)>3
     avgPow   = squeeze(mean(diffFreq.powspctrm));
%     butall   = squeeze(nanmean(nanmean(diffFreq.powspctrm(:,chans,find(diffFreq.freq>freqs(1) & diffFreq.freq<freqs(2)),:),2),3));
     nSubj    = size(diffFreq.powspctrm,1);
 else
     avgPow   = diffFreq.powspctrm;
 end
% butplot     = squeeze(nanmean(nanmean(avgPow(chans,find(diffFreq.freq>freqs(1) & diffFreq.freq<freqs(2)),:),2)));

    
% for np = 1:length(nplots)
   fh = figure;
%     figurewidthincms = 28.7;%17.6;
%     set(gcf,'Units','centimeters','Position',[0 10 figurewidthincms figurewidthincms/(length(plotTimes)-1)/.7])  %17.6 is the largest size in centimeters for a jneurosci figure
figurewidthinpix = 1200;
set(gcf,'Position',[0 10 figurewidthinpix figurewidthinpix/(length(plotTimes)-1)/.7])  %17.6 is the largest size in centimeters for a jneurosci figure
    betas.avg = squeeze(mean(avgPow(:,find(diffFreq.freq>freqs(1) & diffFreq.freq<freqs(2)),:),2));
    betas.time  = diffFreq.time;
    betas.dof   = 1;
    betas.n     = nSubj;
    spwidth     = .98/sp_c;
    botleft     = .01;
    stat.freqstoplot = freqs;
    for t = 1:length(plotTimes)-1
        subplot('Position',[botleft 0.3 spwidth 0.7])
%         plot_stat(cfg,stat.TCFEstat(np),betas,[],[plotTimes(t) plotTimes(t+1) topotime],collim,.05,[],0);
        plot_stat(cfg,stat,betas,[],[plotTimes(t) plotTimes(t+1) topotime],collim,.05,[],0);
        botleft = botleft+spwidth;
    end
    
    subplot('Position',[.01 0.3 .98 0.0])
    box off
    xlim([plotinterval(1) plotinterval(2)])
    set(gca,'YTick',[],'XTick',plotinterval(1):plotinterval(3):plotinterval(2),'FontSize',8)
    xTickLabels = cell(1,length(plotTimes));  % Empty cell array the same length as xAxis
    tuptick = get(gca,'XTick');
    for ip = 1:2:length(xTickLabels)
        xTickLabels{ip} = tuptick(ip);
    end
    ylim(collim*2)
    set(gca,'XTickLabel',xTickLabels);   % Update the tick labels
% end