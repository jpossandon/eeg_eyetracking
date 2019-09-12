function h = newtplot(data,time,smooth,lines,cax,name)

h = figure;
%  set(h,'Position',[500 100 800 800])
%   set(h,'Position',[500 500 800 310])
% subplot(1,2,1)

g = gausswin(smooth)./sum(gausswin(smooth));

data = conv2(double(data),g,'valid');
f = pcolor(time,1:1:size(data,1),data);
set(f,'LineStyle','none')
line(zeros(size(data,1),1),linspace(0,size(data,1),size(data,1)),...
    'LineWidth',2,...
        'Color',[0 0 0])
% if ~isempty(lines)
%     for e = 1:size(lines,2)
%         linea = convn(lines(:,e),g,'valid');
% %         linea = lines(smooth/2:end-smooth/2,e);
%         line(linea,1:size(data,1),...
%             'LineWidth',2,...
%                 'Color',[0 0 0])
%     end
% end
        
% colormap('jet')
caxis(cax)
axis ij
% caxis([-1 1])
% % xlim([-200 300])
%  set(gca,'units','pixels','Position',[62,35,250,250],'box','off',...
%      'FontName','Helvetica',...
%      'FontSize',12,...
%      'TickDir','out')
 set(gca,'units','pixels','box','off',...
     'FontName','Helvetica',...
     'FontSize',12,...
     'TickDir','out')
 %      'YTick',[0 round(.005*size(data,1))*100 floor(.01*size(data,1))*100],...

set(h,'Name',name)

if ~isempty(lines)
    for e = 1:size(lines,2)
        linea = convn(lines(:,e),g,'valid');
%         linea = lines(smooth/2:end-smooth/2,e);
        line(linea,1:size(data,1),...
            'LineWidth',2,...
                'Color',[0 0 0])
    end
    ylim([0 size(data,1)])
    axis ij
%     set(gca,'units','pixels','Position',[312,35,60,250], 'Yaxislocation','right','XAxisLocation','top')
%     set(h,'Position',[500 500 470 310])
else
%     set(h,'Position',[500 500 370 310])
end

% this is for sorting that are in a different unit that time 
% so the line goes outside in a subplot
% if ~isempty(lines)
%     subplot(1,2,2)
%     for e = 1:size(lines,2)
%         linea = convn(lines(:,e),g,'valid');
% %         linea = lines(smooth/2:end-smooth/2,e);
%         line(linea,1:size(data,1),...
%             'LineWidth',2,...
%                 'Color',[0 0 0])
%     end
%     ylim([0 size(data,1)])
%     axis ij
%     set(gca,'units','pixels','Position',[312,35,60,250], 'Yaxislocation','right','XAxisLocation','top')
%     set(h,'Position',[500 500 470 310])
% else
%     set(h,'Position',[500 500 370 310])
% end