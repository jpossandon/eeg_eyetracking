function fh = topomitlines(cfg,stat,betas,plotinterval,collim,half,xtickevery )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%   cfg.chanlocs = eeglab chanlocs structure
%   stat         = fieldtrip stat structure. It can be an empty variable
%   betas        = structure with the data, it needs to include the
%                   following field:
%                 betas.n    : amount of subjects (or trials for one subejct
%                           data)
%                 betas.avg  : actual data matric channels x times
%                 betas.time : time vector correspondinf to betas.avg time
%                           dimension
%   plotinterval = [startpoint endpoint interval] in seonds
%   collim       = color caxis value [low high]
%   half         = plots only half hemisphere topoplot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    

topotime    = plotinterval(3);
plotTimes   = plotinterval(1):plotinterval(3):plotinterval(2);

sp_c        = length(plotTimes)-1;

fh          = figure;
figurewidthinpix = 1200;
if half
    set(gcf,'Position',[0 10 figurewidthinpix figurewidthinpix/(length(plotTimes)-1)/.8*2])  %17.6 is the largest size in centimeters for a jneurosci figure
else
    set(gcf,'Position',[0 10 figurewidthinpix figurewidthinpix/(length(plotTimes)-1)/.8])  %17.6 is the largest size in centimeters for a jneurosci figure
end
spwidth     = .96/sp_c;
botleft     = .01;
for t = 1:length(plotTimes)-1
    subplot('Position',[botleft 0.2 spwidth 0.8])
    plot_stat(cfg,stat,betas,[],[plotTimes(t) plotTimes(t+1) topotime],collim,.05,[],0);
    if half
        xlim([-.5 0])
    end
    botleft = botleft+spwidth;
end

 subplot('Position',[.01 0.199 .96 0.0])
box off
xlim([plotinterval(1) plotinterval(2)])
if half
     set(gca,'YTick',[],'XTick',round([plotinterval(1):plotinterval(3)*2:plotinterval(2)]*1000)/1000,'FontSize',5)
     xTickLabels = cell(1,(length(plotTimes)+1)/2);  % Empty cell array the same length as xAxis
else
    set(gca,'YTick',[],'XTick',round([plotinterval(1):plotinterval(3):plotinterval(2)]*1000)/1000,'FontSize',5)
    xTickLabels = cell(1,length(plotTimes));  % Empty cell array the same length as xAxis
end
tuptick = get(gca,'XTick');
for ip = 1:xtickevery :length(xTickLabels)
    xTickLabels{ip} = tuptick(ip);
end
ylim(collim*2)
set(gca,'XTickLabel',xTickLabels,'TickLength', [0.0075 0.002]);   % Update the tick labels

% colorbar
subplot('Position',[botleft 0.2 .02 0.8])
axis off
hc = colorbar;
hc.Position = [botleft+.007 0.3 .008 0.6];
hc.FontSize = 3;
caxis(collim)
hc.XTick = [ceil(collim(1).*100) 0 floor(collim(2).*100)]/100;