function ploteffectChannels(cfg_eeg,result,whstat,chnstoPlot,signs,Bnames,Blabels,filled,lineColors,pathfig,axLim,figname)

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

for ch = 1:length(chnstoPlot)
    auxChns         = find(ismember({chanlocs.labels},chnstoPlot{ch}));
    datatoPlot      = [];
    clusandP        = {};
 
    for b = 1:length(Bnames)
        ixB = ismember(result.coeffs,Bnames{b});
           
        if size(signs,3)>1
            datatoPlot  = cat(3,datatoPlot,permute(squeeze(sum(squeeze(mean(result.B(auxChns,ixB,:,:))).*repmat(signs(b,:,1)',[1,size(result.B,3),size(result.B,4)]))),[2 1])-...
                permute(squeeze(sum(squeeze(mean(result.B(auxChns,ixB,:,:))).*repmat(signs(b,:,2)',[1,size(result.B,3),size(result.B,4)]))),[2 1]));
      
        else
             datatoPlot  = cat(3,datatoPlot,permute(squeeze(sum(squeeze(mean(result.B(auxChns,ixB,:,:))).*repmat(signs(b,:)',[1,size(result.B,3),size(result.B,4)]))),[2 1]));
        end
        if whstat(b)>0
             if isfield(result,'clusters')
                    if isfield(result.clusters(whstat(b)),'posclusters_prob_abs')
                        clusandP{b,1}    = cat(3,result.clusters(whstat(b)).posclusterslabelmat(auxChns,:),result.clusters(whstat(b)).posclusters_prob_abs(auxChns,:));      
                        clusandP{b,2}    = cat(3,result.clusters(whstat(b)).negclusterslabelmat(auxChns,:),result.clusters(whstat(b)).negclusters_prob_abs(auxChns,:));      
                    else
                        clusandP{b,1} = [];
                    clusandP{b,2} = [];
                    end
                else
                    clusandP{b,1} = [];
                    clusandP{b,2} = [];
             end
        else
             clusandP{b,1} = [];
             clusandP{b,2} = [];
        end
    end
%     lineNames   = strtok(Bnames,'_');
% %     lineNames   = Bnames;
    lineNames = Blabels;
%         result.clusters(ixB).mask
%         signf        = squeeze(any(any(statUCIci.mask(auxChns,freqs,:),1),2))';
    [fh,hc] = fillPlot(datatoPlot,clusandP,[],xaxis,axLim,'mean',filled,lineColors,lineNames);
    fh.Name = strjoin(' ',chnstoPlot{ch});
%     xlabel('Time (s)','FontSize',8);
    yl = ylabel('dB','Interpreter','tex','FontSize',8);
    yl.Units = 'normalized';
    yl.Position(1) = -0.048;
    if hc~=0 
        hc.Position = [.92 .3 .02 .4];
        hc.FontSize = 5;
    end
    set(gca,'Position',[.08 .175 .83 .76],'XTick',axLim(1):abs(axLim(1)):axLim(2),'YTick',[axLim(3) 0 axLim(4)])
     set(gca,'XTick',-.8:.1:.8), grid on

%     xlabel('Time (s)','FontSize',6)
%     ylabel('\beta','Interpreter','tex','FontSize',6)
%     set(gca,'Position',[.11 .175 .85 .76],'XTick',axLim(1):abs(axLim(1)):axLim(2),'YTick',[axLim(3) 0 axLim(4)])
     figsize     = [2*4.6 2*4.6*fh.Position(4)/fh.Position(3)];
    doimage(gcf,pathfig,'pdf',[figname '_' cell2mat(chnstoPlot{ch})],'1200','painters',figsize,0)
end