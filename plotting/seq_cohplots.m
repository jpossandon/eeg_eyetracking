    function fh = seq_cohplots(cfg_eeg,cohData,times,cohlims,alpha)

%%
% get the position of the channels in the plot
load(cfg_eeg.chanfile)
load(cfg_eeg.chanlocs)
elec        = bineigh(elec);
nchans  = length(chanlocs);
hfd     = figure;
topoplot(zeros(nchans,1),chanlocs,'electrodes','on');
da      = get(gca,'Children');
xpos    = da(1).XData;
ypos    = da(1).YData;
close(hfd)
    
                 
%%
% cohimthr =.15;
% alfa     = .001;

fh = figure;
if ~isempty(times)
    sactimes    = times(1):times(3):times(2);
    sp_c        = length(sactimes)-1;
    figurewidthinpix = 1200;
    set(gcf,'Position',[0 10 figurewidthinpix figurewidthinpix/(length(sactimes)-1)/.7])  %17.6 is the largest size in centimeters for a jneurosci figure
    botbottom = 0.3;
else
    sactimes = [NaN NaN];
    sp_c=1;
     set(gcf,'Position',[0 10 400 400])
     botbottom = 0.01;
end
load('cmapjp','cmap')
cmap2 = flipud(cbrewer('seq','YlGnBu',128));
cmap3 = cbrewer('qual','Set3',12);
spwidth     = .98/sp_c;
botleft     = .01;
% compDist    = 'MAXst';
compDist    = 'MAXst_noabs';

for t = 1:length(sactimes)-1
    subplot('Position',[botleft botbottom spwidth 1-botbottom])
    tp = topoplot(zeros(nchans,1),chanlocs,'colormap',cmap,'emarker',{'.','k',1,1},'whitebk','on','shading','interp','electrodes','on');
    axis([-.6 .6 -.6 .6])
            fixtopotlines
    hold on
    if ~isempty(times)
  	 s_T         = find(cohData.time>sactimes(t) &cohData.time<sactimes(t+1));
    else
        s_T = 1;
    end
    if isfield(cohData,'clusters')    %STAT DATA
        if strcmp(compDist,'MAXst')
            if size(cohData.clusters.MAXst,1)>1
            thrpos = prctile(cohData.clusters.MAXst,1-alpha*100);
            else
                thrpos = 0;
            end
            thrneg = thrpos;
        elseif strcmp(compDist,'MAXst_noabs')
             if size(cohData.clusters.MAXst_noabs,1)>1
            thrpos = prctile(cohData.clusters.MAXst_noabs(:,1),100-alpha/2*100);
            thrneg = prctile(cohData.clusters.MAXst_noabs(:,2),alpha/2*100);
             else
                  thrpos = 0;
                   thrneg = 0;
             end
        end
       
        
        posColor2 = cohData.clusters.maxt_pos>thrpos;
        posColor = nan(1,length(posColor2));
        if ~isempty(posColor)
            posColor(find(posColor2)) = 0:sum(posColor2)-1;
            for posc = 1:length(cohData.clusters.maxt_pos)
                if cohData.clusters.maxt_pos(posc)>thrpos
                    cv = elec.bi.chan_comb(find(any(cohData.clusters.clus_pos(:,s_T) ==posc,2)),:);

                    if ~isempty(cv)
                        if strcmp(compDist,'MAXst')
                            cluspval = sum(cohData.clusters.MAXst >cohData.clusters.maxt_pos(posc))./length(cohData.clusters.MAXst);
                        elseif strcmp(compDist,'MAXst_noabs')
                            cluspval = 2*sum(cohData.clusters.MAXst_noabs(:,1)>cohData.clusters.maxt_pos(posc))./length(cohData.clusters.MAXst_noabs(:,1));
                        end
                        display(sprintf('Positive cluster %d time %2.2f-%2.2f pval = %4.4f',posc,sactimes(t),sactimes(t+1),cluspval))
                        for ia = 1:size(cv,1)
                            cval = cmap3(1+posColor(posc),:);
                             pl = plot([xpos(cv(ia,1)) xpos(cv(ia,2))],[ypos(cv(ia,1)) ypos(cv(ia,2))],'Color',cval,'LineWidth',1);
% patch([xpos(cv(ia,1)) xpos(cv(ia,2))],[ypos(cv(ia,1)) ypos(cv(ia,2))],cval,'EdgeAlpha',1)
                        end
                    end
                end
            end
        end
        negColor2 = abs(cohData.clusters.maxt_neg)>abs(thrneg);
        negColor = nan(1,length(negColor2));
        if ~isempty(negColor)
            negColor(find(negColor2)) = 0:sum(negColor2)-1;
         for negc = 1:length(cohData.clusters.maxt_neg)
            if abs(cohData.clusters.maxt_neg(negc))>abs(thrneg)
                cv = elec.bi.chan_comb(find(any(cohData.clusters.clus_neg(:,s_T) ==negc,2)),:);
                
                if ~isempty(cv)
                    if strcmp(compDist,'MAXst')
                        cluspval = sum(cohData.clusters.MAXst >abs(cohData.clusters.maxt_neg(negc)))./length(cohData.clusters.MAXst);
                    elseif strcmp(compDist,'MAXst_noabs')
                        cluspval = 2*sum(cohData.clusters.MAXst_noabs(:,2)<cohData.clusters.maxt_neg(negc))./length(cohData.clusters.MAXst_noabs(:,2));
                    end
                    display(sprintf('Negative cluster %d time %2.2f-%2.2f pval = %4.4f',negc,sactimes(t),sactimes(t+1),cluspval))
                    for ia = 1:size(cv,1)
                        cval = cmap3(end-negColor(negc),:);
                        pl = plot([xpos(cv(ia,1)) xpos(cv(ia,2))],[ypos(cv(ia,1)) ypos(cv(ia,2))],'Color',cval,'LineWidth',1);
                    end
                end
            end
         end
        end
    else
        
        if isempty(times)
            s_T = 1;
        end
        h           = cohData.p(:,:,s_T);
        h           = any(h<=alpha,3);    % if any value in the time segment is significant
        auxcohim    = nanmean(cohData.cohspctrm(:,:,s_T),3);
    %             maxdif      = max(max(max(mean(cohim(:,:,:,:)))));
        sigcohim    = triu(h);
        for ch = 1:nchans
            cv = find(sigcohim(ch,:)==1);
            if ~isempty(cv)
                for ia = 1:length(cv)
    %                 cval = [1 0 0];
                    if auxcohim(ch,cv(ia))>=cohlims(2)
                        cval = cmap2(end,:);
                    elseif auxcohim(ch,cv(ia))<=cohlims(1)    
                        cval = cmap2(1,:);
                    else
                        cval = cmap2(find(linspace(cohlims(1),cohlims(2),size(cmap2,1))>auxcohim(ch,cv(ia)),1),:);
                    end
    %                 cval = cmap3(1+round((auxcohim(ch,cv(ia))+maxdif)/2/maxdif*(size(cmap3,1)-1)),:);
                    plot([xpos(ch) xpos(cv(ia))],[ypos(ch) ypos(cv(ia))],'Color',cval,'LineWidth',1.5)
                end
            end
        end
    end
    botleft = botleft+spwidth;
end
   
if ~isempty(times)
subplot('Position',[.01 botbottom .98 0.0])
box off
xlim([times(1) times(2)])
set(gca,'YTick',[],'XTick',sactimes,'FontSize',8)
xTickLabels = cell(1,length(sactimes));  % Empty cell array the same length as xAxis
tuptick = get(gca,'XTick');
for ip = 1:2:length(xTickLabels)
    xTickLabels{ip} = tuptick(ip);
end
% ylim(collim*2)
set(gca,'XTickLabel',xTickLabels); 
end   
 
