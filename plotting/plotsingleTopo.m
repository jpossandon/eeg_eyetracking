function plotsingleTopo(cfg_eeg,result,signs,interval,Bnames,Blabels,collim,half,pathfig,figname)

load(cfg_eeg.chanlocs)
%  if strcmp(Bnames{1}(1:5),'diff:')
%     lineColors      = cbrewer('div','RdYlGn',length(Bnames));
%  else
%      lineColors      = cbrewer('qual','Set1',9);%[134 16 9;22 79 134;11 93 24]/255;
%  end
try 
xaxis           = result.clusters(1).time;
catch
xaxis           = result.times;
end
% axLim           = [-.7 .9 -15 15];

% for ch = 1:length(chnstoPlot)
%     auxChns         = find(ismember({chanlocs.labels},chnstoPlot{ch}));
    datatoPlot      = [];
    clusandP        = {};
 
    for b = 1:length(Bnames)
        ixB = ismember(result.coeffs,Bnames{b});
           
        if size(signs,3)>1
            datatoPlot  = squeeze(sum(squeeze(result.B(:,ixB,:,:)).*repmat(signs(b,:,1),[size(result.B,1),1,size(result.B,3),size(result.B,4)]),2))-...
               squeeze(sum(squeeze(result.B(:,ixB,:,:)).*repmat(signs(b,:,2),[size(result.B,1),1,size(result.B,3),size(result.B,4)]),2));
      
        else
            % check this
              datatoPlot  = squeeze(sum(squeeze(result.B(:,ixB,:,:)).*repmat(signs(b,:,1),[size(result.B,1),1,size(result.B,3),size(result.B,4)]),2));
        end
%         if whstat(b)>0
%              if isfield(result,'clusters')
%                     if isfield(result.clusters(whstat(b)),'posclusters_prob_abs')
%                         clusandP{b,1}    = cat(3,result.clusters(whstat(b)).posclusterslabelmat(auxChns,:),result.clusters(whstat(b)).posclusters_prob_abs(auxChns,:));      
%                         clusandP{b,2}    = cat(3,result.clusters(whstat(b)).negclusterslabelmat(auxChns,:),result.clusters(whstat(b)).negclusters_prob_abs(auxChns,:));      
%                     else
%                         clusandP{b,1} = [];
%                     clusandP{b,2} = [];
%                     end
%                 else
%                     clusandP{b,1} = [];
%                     clusandP{b,2} = [];
%              end
%         else
%             clusandP{b,1} = [];
%              clusandP{b,2} = [];
%         end
%     end
%     lineNames   = strtok(Bnames,'_');
% %     lineNames   = Bnames;
%     lineNames = Blabels;
%         result.clusters(ixB).mask
%         signf        = squeeze(any(any(statUCIci.mask(auxChns,freqs,:),1),2))';
%     [fh,hc] = fillPlot(datatoPlot,clusandP,[],xaxis,axLim,'mean',filled,lineColors,lineNames);
betas.avg = squeeze(mean(datatoPlot,3));
betas.time = xaxis;
stat.time = xaxis;
% collim = [-10 10]
fh=figure;
 plot_stat(cfg_eeg,stat,betas,[],interval,collim,.05,[],0);
  if half
        xlim([-.5 0])
    end
    fh.Name = Blabels{b};
%     xlabel('Time (s)','FontSize',8);
%     yl = ylabel('dB','Interpreter','tex','FontSize',8);
%     yl.Units = 'normalized';
%     yl.Position(1) = -0.048;
%     if hc~=0 
%         hc.Position = [.92 .3 .02 .4];
%         hc.FontSize = 5;
%     end
%     set(gca,'Position',[.08 .175 .83 .76],'XTick',axLim(1):abs(axLim(1)):axLim(2),'YTick',[axLim(3) 0 axLim(4)])
    
%     xlabel('Time (s)','FontSize',6)
%     ylabel('\beta','Interpreter','tex','FontSize',6)
%     set(gca,'Position',[.11 .175 .85 .76],'XTick',axLim(1):abs(axLim(1)):axLim(2),'YTick',[axLim(3) 0 axLim(4)])
    tightfig
figsize     = [17.6/5 17.6/5*fh.Position(4)/fh.Position(3)];
    doimage(gcf,pathfig,'pdf',[figname '_' Blabels{b}],'600','opengl',figsize,0)
    end
    load('cmapjp','cmap') 
    fh = figure;
    fh.Position= [360 350 80 348];
 axis off
hc = colorbar;
set(hc,'Position',[0.1 0.2 0.3 0.6])
colormap(cmap)
caxis(collim)
% hc.Limits = [collim(1) 0];

% hc.Ticks = [collim(1) collim(1)/2  0];
  hc.Limits = [collim];
  hc.Ticks = [collim(1) 0 collim(2)];
% hc.Limits = [collim(1) collim(1)+(-collim(1)+collim(2))/2];
% hc.Ticks = [collim(1) collim(1)+(-collim(1)+collim(2))/4 collim(1)+(-collim(1)+collim(2))/2];

hc.YAxisLocation = 'right';
hc.FontSize = 4;
figsize     = [17.6/5/10 17.6/5/10*fh.Position(4)/fh.Position(3)];
doimage(gcf,pathfig,'pdf',[figname '_cbar'],'600','opengl',figsize,0)