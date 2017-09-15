function [fixpdf,fixs] = makepdf(x,y,gwinstd,siz,redux,ploteo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [fixpdf,fixs] = makepdf(x,y,gwinstd,siz,redux,ploteo)
%    input
%            x          - column with horizontal positions
%            y          - column with vertical positions
%            gwinstd    - SD of the 2D gaussian smoothing filter
%            siz        - size of the original image
%            redux      - integer to reduce the size of the result
%                           image/matrix, a value of 2 reduce it to half
%            ploteo     - top plot or not plot
%   output
%            fixpdf     - the 2D fixation desnsity
%            fixs       - the 2D fixations counts per pixel
%
% JPO, OSNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gwinstd = round(gwinstd/redux);
siz = round(siz/redux);

lfixall = round([y,x])./redux;
lfixall(lfixall(:,1)<1 | lfixall(:,1)>siz(1),:)=[];
lfixall(lfixall(:,2)<1 | lfixall(:,2)>siz(2),:)=[];
fixs    = accumarray(double(round(lfixall)), 1,siz);

% [X,Y]   = meshgrid(-2.5*gwinstd:1:2.5*gwinstd);
% gauss   = 1./(2*pi*gwinstd^2).*exp(-(X.^2+Y.^2)./(2*gwinstd.^2));
% gauss = gauss./sum(gauss(:)); 
% fixpdf  = conv2(fixs,gauss, 'same');

X       = -2.5*gwinstd:1:2.5*gwinstd;
gauss   = 1./(2*pi*gwinstd^2).*exp(-(X.^2)./(2*gwinstd.^2));
gauss = gauss./sum(gauss(:));
fixpdf  = conv2(fixs,gauss, 'same');
fixpdf  = conv2(fixpdf,gauss', 'same');

fixpdf  = fixpdf/sum(fixpdf(:));

if ploteo == 1
       figure,imshow(fixpdf);
       caxis([0 max(fixpdf(:))])
    
%       figure,imshow(log10(fixpdf),[]);
%        figure,imagesc(log10(fixpdf));
%       caxis([log10(max(fixpdf(:))) 0])
      colormap parula
    axis on
end
