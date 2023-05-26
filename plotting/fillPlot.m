function [fh,hc] = fillPlot(datatoPlot,prob,graybkg,xaxis,axLim,method,filled,lineColors,lineNames)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [fh] = fillPlot(datatoPlot,graybkg,xaxis,axLim,method,lineColors,lineNames)
%
%   datatoPlot  - matrix in the form nsubjectsxntimesxnlines
%   graybks     - logical vector length xaxis/ntimes indicating where to
%               display a gray patch
%   xaxis       - vector length equal to ntimes with the units to plot
%   axlim       - axis function input
%   method      -
%               'mean'  - lines correspond to nsubjects means + SEM
%               'median - lines correspond to nsubjects median and IQR
%   linecolor   - matrix size nlinesx3 indicating the color of the lines
%   lineNames   - that
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nSubj,nTimes,nLines] = size(datatoPlot);

fh =figure;
fh.Position(4) = fh.Position(4)/2;
hold on
hc = 0;
% gray background patch
if any(graybkg)
    
    if length(graybkg)~=nTimes
        error('Graybkg lenght different to times length')
    end
    grSt    = find(diff(graybkg)==1)+1;
    grEnd   = find(diff(graybkg)==-1);
    if length(grSt)<length(grEnd)               % in case  graybkg starts or ends with a 1
        grSt = [1 grSt];
    elseif length(grSt)>length(grEnd)
        grEnd = [grEnd length(graybkg)];
    end
    patch(xaxis([grSt;grEnd;grEnd;grSt]),...
        [axLim(3);axLim(3);axLim(4);axLim(4)]*ones(1,length(grSt)),...
        [.9 .9 .9],'EdgeColor','none')
end

axis(axLim)
hl              = hline(0);
hl.LineWidth    = .25;
hl.Color        = [0.5 0.5 0.5];
vl              = vline(0);
vl.LineWidth    = .25;
vl.Color        = [0.5 0.5 0.53];
movdown         = (axLim(4)-axLim(3))*.02;

for ll = 1:nLines
    if strcmp(method,'mean')
        auxM    = mean(datatoPlot(:,:,ll),1);
        auxSE   = std(datatoPlot(:,:,ll),0,1)./sqrt(nSubj);
        upper   = auxM+auxSE;
        lower   = auxM-auxSE;
    elseif strcmp(method,'median')
        auxM    = median(datatoPlot(:,:,ll),1);
        upper   = prctile(datatoPlot(:,:,ll),75);
        lower   = prctile(datatoPlot(:,:,ll),25);
    elseif strcmp(method,'boot_se')
        auxM    = datatoPlot(1,:,ll);
        auxSE   = datatoPlot(2,:,ll);
        upper   = auxM+auxSE;
        lower   = auxM-auxSE;
    end
    %     plot(xaxis,datatoPlot(:,:,ll),'Color',lineColors(ll,:),'LineWidth',.1)
    if filled(ll)==1
        jbfill(xaxis,upper,lower ,lineColors(ll,:),lineColors(ll,:),1,.4,0);
    end
    hold on
    lp(ll) = plot(xaxis,auxM,'Color',lineColors(ll,:),'LineWidth',.25);
end
a=0;
for ll = 1:nLines
    if strcmp(method,'mean')
        auxM    = mean(datatoPlot(:,:,ll),1);
    elseif strcmp(method,'median')
        auxM    = median(datatoPlot(:,:,ll),1);
    elseif strcmp(method,'boot_se')
        auxM    = datatoPlot(1,:,ll);
    end
    %lp(ll)     = plot(xaxis,auxM,'Color',lineColors(ll,:),'LineWidth',.5);
    %     siglinpos  = any(squeeze(prob{ll,1}(:,:,2)<.05));
    %     siglinneg  = any(squeeze(prob{ll,2}(:,:,2)<.05));
    %     plot(xaxis(siglinpos),auxM(siglinpos),'.k');
    %     plot(xaxis(siglinneg),auxM(siglinneg),'.k');
    someLine = 0;
    for pn = 1:2
        auxpos      = unique(prob{ll,pn}(:,:,1));
        if ~isempty(prob{ll,pn})
            pp          = prob{ll,pn}(:,:,2);
        end
        if ~isempty(auxpos)
            for pc = 1:length(auxpos)
                if auxpos(pc)~=0
                    thisclus = find(prob{ll,pn}(:,:,1)==auxpos(pc));
                    if ~isempty(prob{ll,pn})
                        thisp    = unique(pp(thisclus));
                        if thisp<.05
                            if 0.005<thisp & thisp<0.05
                                pstr = '\ast';
                            elseif 0.0005<thisp & thisp<=0.005
                                pstr = '\ast\ast';
                            elseif thisp<=0.0005
                                pstr = '\ast\ast\ast';
                            end
                            if xaxis(find(any(prob{ll,pn}(:,:,1)==auxpos(pc)),1,'first'))<axLim(2)
                                line([xaxis(find(any(prob{ll,pn}(:,:,1)==auxpos(pc)),1,'first')) xaxis(find(any(prob{ll,pn}(:,:,1)==auxpos(pc)),1,'last'))],[axLim(4)-a*movdown axLim(4)-a*movdown],'Color',lineColors(ll,:),'LineWidth',.1), hold on
                                text(mean(xaxis(find(any(prob{ll,pn}(:,:,1)==auxpos(pc))))),axLim(4)-a*movdown,pstr,'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',4)
                                plot(xaxis(find(any(prob{ll,pn}(:,:,1)==auxpos(pc)))),auxM(find(any(prob{ll,pn}(:,:,1)==auxpos(pc)))),'.','MarkerSize',2,'Color',lineColors(ll,:));
                                someLine = 1;
                            end
                        end
                    end
                end
            end
        end
    end
    if someLine
        a = a+1;
    end
end

% if ~isempty(lineNames)
%      [leghandle objleg] = legend(lp,lineNames,'interpreter','none');
%      leghandle = adjustLegend(leghandle,objleg,6,[.21 .28 .05 .005]);
%  end
if ~isempty(lineNames{1})
    if ischar(lineNames{1})
        movdown         = (axLim(4)-axLim(3))*.08;
        for ll = 1:nLines
            line([axLim(1)+(axLim(2)-axLim(1)).*.02 axLim(1)+(axLim(2)-axLim(1)).*.05],[axLim(3)+movdown*ll axLim(3)+movdown*ll],'Color',lineColors(ll,:))
            text(axLim(1)+(axLim(2)-axLim(1)).*.06,axLim(3)+movdown*ll,lineNames{ll},'FontSize',6)
        end
        
    else
        hc = colorbar;
        colormap(lineColors);
        hc.Limits = [lineNames{1}(1) lineNames{1}(end)];
        caxis([lineNames{1}(1) lineNames{1}(end)])
        hc.Ticks = [lineNames{1}(1) lineNames{1}(ceil(end/2)) lineNames{1}(end)];
        
    end
        
end
