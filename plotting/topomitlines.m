function fh = topomitlines(cfg,stat,betas,plotinterval,collim)

%%
topotime    = plotinterval(3);
plotTimes   = plotinterval(1):plotinterval(3):plotinterval(2);

sp_c        = length(plotTimes)-1;

fh          = figure;
figurewidthinpix = 1200;
set(gcf,'Position',[0 10 figurewidthinpix figurewidthinpix/(length(plotTimes)-1)/.7])  %17.6 is the largest size in centimeters for a jneurosci figure

spwidth     = .98/sp_c;
botleft     = .01;
for t = 1:length(plotTimes)-1
    subplot('Position',[botleft 0.3 spwidth 0.7])
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
