function fh = printcolorbar(cmap,axl,limits,cticks,cticklabels)

% axl - color axis values
% limits - what is plottes

fh = figure;
figsiz              = [17.6/6 17.6/3];
fh.Units            = 'centimeters';
fh.Position(3:4)    = figsiz;
% cmap2 = flipud(cbrewer('seq','YlGnBu',128));
cb =colorbar;
axis off
colormap(cmap)
% caxis(log10([.00001 .01]))
caxis(axl)

cb.Position = [.46 .2 .2 .6];
% cb.Ticks = log10([.00001 .0001 .001 .01]);

if ~isempty(limits)
cb.Limits =limits;
end
if ~isempty(cticks)
cb.Ticks = cticks;
else
    cb.Ticks = [cb.Ticks(1) cb.Ticks(1)+range(cb.Ticks)/2 cb.Ticks(end)]
end
% cb.TickLabels = [.00001 .0001 .001 .01];
if ~isempty(cticklabels)
cb.Ticks = cticklabels;
end
% doimage(fh,fullfile(['/Users/jossando/trabajo/India_restingState/07_Analysis/04_EEG/wpli/figures']),'pdf',sprintf('colorbar pval'),'300','painters',figsiz,1)
