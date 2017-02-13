function topomitlines(cfg,stat,st_end,topotime,collim)

%%
% topotime    = .02;
% betastoplot = [1];
sacinterval = [st_end topotime];
sactimes    = sacinterval(1):sacinterval(3):sacinterval(2);

sp_c        = length(sactimes)-1;

nplots      = size(stat.B,2);
times       = stat.TCFEstat(1).time;

    
for np = 1:nplots
    figure
    set(gcf,'Position',[69 595 1532 361])
    subplot(2,sp_c,1:sp_c)

    if length(size(stat.B))>3
        butplot = squeeze(mean(stat.B(:,np,:,:),4));
    else
        butplot = squeeze(stat.B(:,np,:));
    end
    if isempty(collim)
        collim = [-3*std(butplot(:)) 3*std(butplot(:))];
    end
    plot(times,butplot,'Color',[.7 .7 .7],'Linewidth',.1)
    hold on
    pvalmask = nan(size(stat.B,1),size(stat.B,3));
    pvalmask(stat.pval(:,:,np)<.05) = butplot(stat.pval(:,:,np)<.05);
    plot(times,pvalmask,'Color',[.4 .4 1],'Linewidth',.1)


    line([sacinterval(1) sacinterval(2)],[0 0],'Color',[0 0 0],'LineWidth',2)
    line([0 0],[-1.5 1.5],'Color',[0 0 0],'LineWidth',2)
    box off
    axis([sacinterval(1) sacinterval(2) -2 2])
    set(gca,'YTick',[],'XTick',sacinterval(1):sacinterval(3):sacinterval(2),'Position',[0.01 0.583837 0.98 0.341163],'FontSize',16)
    xTickLabels = cell(1,length(sactimes));  % Empty cell array the same length as xAxis
    tuptick = get(gca,'XTick');
    for ip = 1:2:length(xTickLabels)
        xTickLabels{ip} = tuptick(ip);
    end
    ylim(collim)
    set(gca,'XTickLabel',xTickLabels);   % Update the tick labels


    betas.avg = butplot;
    

    betas.time  = times;
    betas.dof   = 1;
    betas.n     = size(stat.B,4);
    spwidth     = .98/sp_c;
    botleft     = .01;
    for t = 1:length(sactimes)-1
        subplot('Position',[botleft 0.11 spwidth 0.341163])
        plot_stat(cfg,stat.TCFEstat(np),betas,[],[sactimes(t) sactimes(t+1) topotime],collim,.05,[],0);
        botleft = botleft+spwidth;
    end
end