function [ICA_match] = ICA_topo_clusters(cfgs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [ICA_match] = ICA_topo_clusters(cfgs)
%   Search for similar component accros different ICA decompositions
%
% Inputs: 
%               cfgs - cell structure configuration that should include parent
%                       eeg filenames and relevant paths
%Outputs:
%               ICA_match - matrix with component matchs, every column
%               correspond to components from a different decomposition in
%               the same order than the cfgs cell structure
%
% JPO, OSNA 18.05.12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for e = 1:length(cfgs)                       % loop through all ICA decompositions
    cfg = cfgs{e};
    load([cfg.analysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'])  
    cfg_ica.dimord = 'chan_comp';
    ica(e)=cfg_ica;
end

X = ica(1).topo';
ai = 1; f=0;
for e = 1:64
    for ip = 2:length(ica)
        Y = ica(ip).topo';
        [D,I] = pdist2(abs(Y),abs(X),'euclidean','smallest',10);
            if sum(D(:,e)<.4)>0
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
save([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '_comp_sel'],'ICA_match')