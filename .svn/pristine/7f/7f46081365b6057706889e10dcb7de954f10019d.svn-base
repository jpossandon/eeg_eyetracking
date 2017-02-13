function  S = struct_elim(S,indxs,dim,woff)

%function  S = struct_elim(S,indxs,dimm,woff)
%       S             - Original Structure
%       indxs         - indxs elements to eliminate
%       dim           - dimension to eliminate, it can be one
%                     number or a vector with the corresponding dimension for each field
%       woff          - warning off
% JPO, Osna 30/10/09
%
 
name = fieldnames(S);

if length(dim) == 1
    dim = repmat(dim,1,length(name));
end

for e = 1:length(name)
    if dim(e)==1
        if size(S.(name{e}),1)>=indxs
            S.(name{e})(indxs,:) = [];
        elseif woff==1
            warning(['element not eliminated in field ' name{e}])
        end
    elseif dim(e)==2
         if size(S.(name{e}),2)>=indxs 
            S.(name{e})(:,indxs) = [];
        elseif woff==1
            warning(['element not eliminated in field ' name{e}])
        end
    end
end