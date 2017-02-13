function new = insertelement(old,indxs,newelem)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function insertelemen(old,indxs,newelem)
% old     - original old
% indxs      - indexes to insert new elements, all indexs correspond to the
%               final matrix
%
% JPO, Osna 3/11/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

indxs = sort(indxs); % make shure that indx are in order
[m,n] = size(old);
if m>1 & n>1
    error('old is not a vector')
elseif n>1
    old = old'
end
new = old;
for e = 1:length(indxs)
    new = [new(1:indxs(e)-1);newelem(e);new(indxs(e):end)];
end