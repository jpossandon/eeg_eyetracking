function  S = struct_select(S,indxfields,criteria,dim)

%
%function  S = struct_select(S,indxfields,criteria)
%       S             - Original Structure
%       indxfields    - cellaray with fields used for rearrenging the data
%       criteria      - cellaray with criteria strings for each field in the
%                     indxfield cellarray {'<something'}. If one
%                     filedname has more than one criteria, enter it as two
%                     different strings
%       dim           - dimension over the reassignments are done, it can be one
%                     number or a vector with the corresponding dimension for each field
% All indxfield   have to be the same length, structure fields without the
% same vector length (or at least one dimension match) will not be changed
%
% JPO, Osna 6/10/09
%
 woff=0;
names = fieldnames(S);

if length(dim) == 1
    dim = repmat(dim,1,length(names));
end

% check all indfields are the same length for the relevant dimension
for e = 1:length(indxfields)
    auxs            = size(S.(indxfields{e}));
    indxs_siz(e)    = auxs(dim(strcmp(names,indxfields{e})));
end

defsiz = unique(indxs_siz);
if ~(length(defsiz)==1)
    error('Indexing fields are not the same length')
end

cumelim = 0;
for e = 1:length(indxfields)
    eval(['auxindx = find(S.(indxfields{e})' criteria{e} ');']) 
    if size(auxindx,1)>1
        auxindx = auxindx';
    end
    for f = 1:length(names)
        siz = size(S.(names{f}));
        if ~(siz(dim(f))==defsiz) 
            if woff
            warning(['Field ''' names{f} ''' is not reassigned because it has a diferrent vector length than indexfields'])
            end
        elseif isstruct(S.(names{f}))
            if woff
            warning(['Field ''' names{f} ''' is not reassigned because it is a structure'])
            end
        else
            indxstr = '(';
            for t = 1:length(siz)
                if t == 1 & t == dim(f)
                    indxstr = [indxstr,'auxindx'];
                elseif t == 1
                    indxstr = [indxstr,':'];
                elseif t == dim(f)
                    indxstr = [indxstr,',auxindx'];
                else
                    indxstr = [indxstr,',:'];
                end
            end
            eval(['S.(names{f}) = S.(names{f})' indxstr ');']) 
        end
    end
    defsiz = length(auxindx);
end