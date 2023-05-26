function [trlp] = permute_trialsbysession(trls,npermute)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [trlp] = permute_trialsbysession(trls,npermute)
%
% Generatess npermute permutation sets for trls
% trls is a cell that contain fieltrip trl preprocessing definition matrices(trialx3)
% trls row are the different variables to permute (at least 2 makes sense)
% trls columns are possible different sessions 
% data is permuted across variables preserving group size
% trlp rows are the different variables, columns the session and the third
% dimension contain the permutation groups, the first entry is the actual
% data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trlp = trls;
for p = 1:npermute
    for sess = 1:size(trls,2)
        allaux = [];
        for vars = 1:size(trls,1)
            allaux              = [allaux;trls{vars,sess}];
        end
        for vars = 1:size(trls,1)
            if vars == 1
                auxr                = sort(randsample(1:size(allaux,1),size(trls{vars,sess},1)));
                auxra               = auxr;
            else
                auxr                = sort(randsample(setdiff(1:size(allaux,1),auxra),size(trls{vars,sess},1)));
                auxra               = [auxra,auxr];
            end
            trlp{vars,sess,p+1}    = allaux(auxr,:);
        end
    end
end
%     trlp1 = trl1;
%     trlp2 = trl2;
%     for p = 1:npermute
%         for sess = 1:size(trl1,2)
%             allaux              = [trl1{1,sess};trl2{1,sess}];
%             auxr                = sort(randsample(1:size(allaux,1),size(trl1{1,sess},1)));
%             trlp1{1,sess,p+1}    = allaux(auxr,:);
%             trlp2{1,sess,p+1}    = allaux(setdiff(1:size(allaux,1),auxr),:);
%         end
%     end
