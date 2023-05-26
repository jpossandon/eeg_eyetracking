hfd         = figure;
topoplot(zeros(length(chanlocs),1),chanlocs,'colormap',cmap,'whitebk','on','shading','interp','electrodes','on');
da      = get(gca,'Children');
xpos    = get(da(1),'XData');
ypos    = get(da(1),'YData');
close(hfd)