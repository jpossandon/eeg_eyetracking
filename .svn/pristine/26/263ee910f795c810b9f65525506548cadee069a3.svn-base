function fh = figoverlay(bkg,fgnd,cmaps,alfa)  

if length(alfa)==1
    bslalfa = 0;
    maxalfa = alfa(1);
else
    bslalfa = alfa(1);
    maxalfa = alfa(2);
end
fh = figure;
cmax_mask           = max(max(fgnd));
set(gcf,'Visible', 'off','Position',[1 5 1280 960])
him                 = imshow(bkg./2);
set(him,'HandleVisibility','off');
hold on
hfix                = imshow(128+fgnd*128/cmax_mask);
alpha_mask          = zeros(size(fgnd));
alpha_mask(fgnd>0)  = bslalfa+fgnd(fgnd>0).*(maxalfa-bslalfa)./cmax_mask;
alpha(hfix,alpha_mask)
% alpha(hfix,alfa)
% hold off
eval(['colormap([' cmaps{1} '(128);' cmaps{2} '(128)])']);
caxis([1 256])
cb = colorbar;
set(cb,'YLim',[128 256],'YTick',128:32:256,'YTickLabel',round(100*[0:cmax_mask/4:cmax_mask])/100)
 