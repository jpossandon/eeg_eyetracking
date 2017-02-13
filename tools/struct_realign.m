function  S = struct_realign(S,indxs,dim)

%
%function  S = struct_select(S,indxfields,criteria)
%       S             - Original Structure
%       indxs         - vector with rearrengment idxs
%       dim           - dimension over the reassignments are done, it can be one
%                     number or a vector with the corresponding dimension for each field
%
% JPO, Osna 6/10/09
%
 
names = fieldnames(S);

if length(dim) == 1
    dim = repmat(dim,1,length(names));
end

for e = 1:length(names)
    if dim(e)==1
    S.(names{e}) = S.(names{e})(indxs,:);
    elseif dim(e)==2
      S.(names{e}) = S.(names{e})(:,indxs);
    end
end