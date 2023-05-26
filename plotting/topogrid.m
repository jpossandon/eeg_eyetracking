function fh = topogrid(cfg,stat,betas,timetoplot,collim)

%%
% indxT       = find(betas.time>=timetoplot,1);
parval      = cell2mat({betas.param.value}');
xplots      = unique(parval(:,1))';
yplots      = unique(parval(:,2))';

% topotime    = plotinterval(3);
% plotTimes   = plotinterval(1):plotinterval(3):plotinterval(2);

sp_c        = length(xplots);
sp_d        = length(yplots);

fh          = figure;
figurewidthinpix = 1200;
set(gcf,'Position',[0 10 figurewidthinpix figurewidthinpix])  %17.6 is the largest size in centimeters for a jneurosci figure

spwidth     = .97/sp_c;
spheigh     = .97/sp_d;
botleft     = .015;
botup       = .985;%-spheigh;
t=1
for xx = xplots
    for yy = yplots
        ixyp            = find(parval(:,1)==xx & parval(:,2)==yy);
        ixp             = find(xplots==xx);
        iyp             = find(yplots==yy);
        auxbeta         = betas;
        auxbeta.avg     = squeeze(auxbeta.avg(:,:,ixyp));
%         botleft         = botleft+(ixp-1).*spwidth;
%         botup           = botup-(iyp).*spheigh;
        subplot('Position',[botleft+(ixp-1).*spwidth botup-(iyp).*spheigh spwidth spheigh])
        plot_stat(cfg,stat,auxbeta,[],timetoplot,collim,.05,[],0);
        
        
        t =t+1;
    end
end

subplot('Position',[.015 0.015 .97 0.0])
box off
% xlim([xplots(1) xplots(end)])
set(gca,'YTick',[],'XTick',(1/length(xplots))/2:(1/length(xplots)):1,...
    'XTickLabels',xplots,'FontSize',6)

subplot('Position',[.015 0.015 0.0 .97])
box off
% xlim([xplots(1) xplots(end)])
set(gca,'XTick',[],'YTick',(1/length(yplots))/2:(1/length(yplots)):1,...
    'YTickLabels',yplots,'FontSize',6)
axis ij % top is negative 

% % colorbar
% subplot('Position',[botleft 0.3 .02 0.7])
% axis off
% hc = colorbar;
% hc.Position = [botleft+.007 0.3 .006 0.6];
% hc.FontSize = 5;
% caxis(collim)
% hc.XTick = [ceil(collim(1).*100) 0 floor(collim(2).*100)]/100;