function [c_mask,posmax] = makecircle(x,y,radius,siz,redux,ploteo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function cmask = makecircle(x,y,gwinstd,siz,redux,ploteo)
%    input
%            x          - column with horizontal positions
%            y          - column with vertical positions
%            radius     - circle radius
%            siz        - size of the original image [y,x]
%            redux      - integer to reduce the size of the result
%                           image/matrix, a value of 2 reduce it to half
%            ploteo     - top plot or not plot
%   output
%            cmask      - the 2D fixation intersection map
%            posmax     - for every x,y point the max value whithin the 
%                       radius of the intersection map is given, this is
%                       not the same as how many fixations intersect with
%                       it
%
% JPO, OSNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


x2          = round(x(x>0 & x<siz(2) & y>0 & y<siz(1))./redux);
y2          = round(y(x>0 & x<siz(2) & y>0 & y<siz(1))./redux);
radius      = round(radius/redux);
siz         = round(siz/redux);
ix          = siz(2);
iy          = siz(1); 
c_mask      = zeros(iy,ix);

for f = 1:length(x2)
    [xx,yy]         = meshgrid(-(x2(f)-1):(ix-x2(f)),-(y2(f)-1):(iy-y2(f)));
    c_mask          = c_mask+((xx.^2+yy.^2)<=radius^2);
    if nargout>1
        fixindexs{f}    = find((xx.^2+yy.^2)<=radius^2);
    end
end

if nargout>1
    posmax  = nan(1,length(x));
    nonans  = find(x2>0 & x2<siz(2) & y2>0 & y2<siz(1));
    for f = 1:length(x2)
        posmax(nonans(f))     = max(c_mask(fixindexs{f}));
    end
end

if ploteo == 1
    figure,imshow(c_mask);
    caxis([0 max(c_mask(:))])
    colormap hot
    axis on
end


