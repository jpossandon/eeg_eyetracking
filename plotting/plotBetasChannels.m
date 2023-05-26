function plotBetasChannels(cfg_eeg,method,result,chnstoPlot,Bnames,Blabels,filled,lineColors,pathfig,axLim,figname)

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
        if strcmp(Bnames{b}(1:5),'diff:')
            splnames = regexp(Bnames{b}(6:end),':','split')
            ixB1 = strmatch(splnames{1},result.coeffs);
            ixB2 = strmatch(splnames{2},result.coeffs);
            datatoPlot  = cat(3,datatoPlot,permute(squeeze(mean(result.B(auxChns,ixB1,:,:)-result.B(auxChns,ixB2,:,:))),[2 1]));
        clusandP{b,1} = [];
                clusandP{b,2} = [];
        else
            ixB = strmatch(Bnames{b},result.coeffs,'exact');
            if strcmp(method,'boot_se')
                 datatoPlot  = cat(3,datatoPlot,[squeeze(mean(result.tr_m(auxChns,:,ixB))); squeeze(mean(result.tmSE(auxChns,:,ixB)))]);
            else
                datatoPlot  = cat(3,datatoPlot,permute(squeeze(mean(result.B(auxChns,ixB,:,:))),[2 1]));
            end
            
            if isfield(result,'clusters')
                if isfield(result.clusters,'posclusters_prob_abs')
                    clusandP{b,1}    = cat(3,result.clusters(ixB).posclusterslabelmat(auxChns,:),result.clusters(ixB).posclusters_prob_abs(auxChns,:));      
                    clusandP{b,2}    = cat(3,result.clusters(ixB).negclusterslabelmat(auxChns,:),result.clusters(ixB).negclusters_prob_abs(auxChns,:));      
                else
                    clusandP{b,1} = [];
                clusandP{b,2} = [];
                end
            else
                clusandP{b,1} = [];
                clusandP{b,2} = [];
            end
        end
    end
%     lineNames   = strtok(Bnames,'_');
% %     lineNames   = Bnames;
    lineNames = Blabels;
%         result.clusters(ixB).mask
%         signf        = squeeze(any(any(statUCIci.mask(auxChns,freqs,:),1),2))';
    [fh,hc]= fillPlot(datatoPlot,clusandP,[],xaxis,axLim,method,filled,lineColors,lineNames);
    fh.Name = cell2mat(chnstoPlot{ch});
    xlabel('Time (s)','FontSize',8);
    yl = ylabel('\beta','Interpreter','tex','FontSize',8);
    yl.Units = 'normalized';
    yl.Position(1) = -0.048;
    if hc~=0 
        hc.Position = [.92 .3 .02 .4];
        hc.FontSize = 5;
    end
    set(gca,'Position',[.08 .175 .83 .76],'XTick',axLim(1):abs(axLim(1)):axLim(2),'YTick',[axLim(3) 0 axLim(4)])
    set(gca,'XTick',-.8:.1:.8), grid on
    title(figname)
    figsize     = [2*4.6 2*4.6*fh.Position(4)/fh.Position(3)];
    doimage(gcf,pathfig,'pdf',[figname '_' cell2mat(chnstoPlot{ch})],'1200','painters',figsize,0)
end