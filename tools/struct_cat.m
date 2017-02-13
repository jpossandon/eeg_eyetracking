function  S = struct_cat(S,new,dim)

%function  S = struct_cat(S,new,dim)
%       S             - Original Structure
%       new           - structure to cat
%       dim           - dimension to cat, it can be one
%                     number or a vector with the corresponding dimension for each field
%
% JPO, Osna 30/10/09
%
 
name_new = fieldnames(new);

if length(dim) == 1
    dim = repmat(dim,1,length(name_new));
end

for e = 1:length(name_new)
    if isfield(S,name_new{e}) 
        S.(name_new{e}) = cat(dim(e),S.(name_new{e}),new.(name_new{e}));
    else
        warning(sprintf('struct does not have field %s',name_new{e}))
    end
end