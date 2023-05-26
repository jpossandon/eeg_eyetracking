function fh = topo2D(cfg,stat,betas,plotgrid,plotinterval,collim,half)

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
%   plotinterval = [startpoint interval] in seonds
%   collim       = color caxis value [low high]
%   half         = plots only half hemisphere topoplot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    

topotime    = plotinterval(2);
plotTime    = plotinterval(1);

sp_c        = size(plotgrid,2);
sp_r        = size(plotgrid,1);

fh          = figure;
figurewidthinpix = 1200;
if half
    set(gcf,'Position',[10 10 figurewidthinpix figurewidthinpix])  %17.6 is the largest size in centimeters for a jneurosci figure
else
    set(gcf,'Position',[10 10 figurewidthinpix figurewidthinpix])  %17.6 is the largest size in centimeters for a jneurosci figure
end
spwidth     = .93/sp_c;

spheigth    = .93/sp_r;
botbot      = .03;
for rr = 1:sp_r
    botleft     = .03;
    for cc = 1:sp_c
        subplot('Position',[botleft botbot spwidth spheigth])
        indxbeta = find(betas.firstval==plotgrid(rr,cc,2) & betas.secondval==plotgrid(rr,cc,1));
        auxbeta = betas;
        auxbeta.avg = squeeze(auxbeta.avg(:,indxbeta,:));
        plot_stat(cfg,stat,auxbeta,[],[plotTime plotTime+topotime topotime],collim,.05,[],0);
        if half
            xlim([-.5 0])
        end
        botleft = botleft+spwidth;
    end
    botbot = botbot+spheigth;
end

 subplot('Position',[.03 0.02 .93 0.0])
box off
xlim([0 sp_c])
if half
%      set(gca,'YTick',[],'XTick',round([plotinterval(1):plotinterval(3)*2:plotinterval(2)]*1000)/1000,'FontSize',8)
%      xTickLabels = cell(1,(length(plotTimes)+1)/2);  % Empty cell array the same length as xAxis
else
    set(gca,'YTick',[],'XTick',.5:1:sp_c+.5,'XTickLabel',plotgrid(1,:,2),'FontSize',8)
end
 
 subplot('Position',[.025 0.03 0.0 .93])
box off
ylim([0 sp_r])
if half
%      set(gca,'YTick',[],'XTick',round([plotinterval(1):plotinterval(3)*2:plotinterval(2)]*1000)/1000,'FontSize',8)
%      xTickLabels = cell(1,(length(plotTimes)+1)/2);  % Empty cell array the same length as xAxis
else
    set(gca,'XTick',[],'YTick',.5:1:sp_r+.5,'YTickLabel',plotgrid(:,1,1),'FontSize',8)
end   
% ylim(collim*2)
% set(gca,'XTickLabel',xTickLabels,'TickLength', [0.0075 0.002]);   % Update the tick labels

% colorbar
% subplot('Position',[botleft 0.2 .02 0.8])
% axis off
% hc = colorbar;
% hc.Position = [botleft+.007 0.3 .008 0.6];
% hc.FontSize = 4;
% caxis(collim)
% hc.XTick = [ceil(collim(1).*100) 0 floor(collim(2).*100)]/100;