function [clusters,cfgs] = cluster_components(icas)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [clusters,cfgs] = cluster_components(cfgs)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X = icas(1).topo';
ai = 1; f=0;
for e = 1:64
    for ip = 2:length(icas)
        Y = icas(ip).topo';
        D = pdist2(abs(Y),abs(X),'euclidean');          % distance between the two sets of components topographies, (Y and X are components x channels)
            if sum(D(:,e)<4)>0                          % D values 
                ICA_match(ai,1) = e;
                indx = find(D(:,e)<.4);
                aux = I(indx(1),e);
                [D2,I2] = pdist2(Y,X,'euclidean','smallest',10);
                [D3,I3] = pdist2(-Y,X,'euclidean','smallest',10);
                if D3(indx(1),e)<D2(indx(1),e)
                    ICA_match(ai,ip) = -aux;
                else
                    ICA_match(ai,ip) = aux;
                end
                f=1;
            end
    end
    if f,ai=ai+1;end
    f=0;
end
ICA_match(find(sum(ICA_match==0,2)),:)=[];
