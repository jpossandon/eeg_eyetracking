function toelim = elimtrl(prearti)

vars = zeros(length(prearti.label),length(prearti.trial));
for e=1:length(prearti.trial)
    vars(:,e)=std(prearti.trial{e},1,2);
end
toelim = [];
for e=1:length(prearti.label)
    varss(e)=std(vars(e,:),1,2);
    aux = find(vars(e,:)>mean(vars(e,:))+2*varss(e) | vars(e,:)<mean(vars(e,:))-2*varss(e));
    toelim = union(toelim,aux);
end    
