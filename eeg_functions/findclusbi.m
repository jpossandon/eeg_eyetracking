function  [cluster] = findclusbi(data,bineighboursmat,chan_comb,tipo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function  = findclusbi(data,neighboursmat,type)
% find cluster in channel vs channel dimension
% data          = logical array channels x channels , 1s are the event to cluster
% neighboursmat = neighbour pairs matric
% tipo          = 'id'  , gives to every cluster element the same corelative number
%                 'sum' , gives to every cluster element the number of the
%                 sum of element that are part of the cluster (used for TCFE)
%
% JPO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






data                = double(triu(data));
[r,c]               = size(data);
[i,j]               = ind2sub(size(data),find(data==1));

% 
% clusaux             = zeros(r+2,c);    % two more rows to find cluster at the begining and end
% clusaux(2:end-1,:)  = data;
% clusaux             = diff(clusaux);   % find start and end of continuous segments of 1s
% [~,j]               = ind2sub(size(clusaux),find(clusaux==1));
% [~,jj]              = ind2sub(size(clusaux),find(clusaux==-1));
% indx_chclus         = [find(clusaux==1)-j+1,find(clusaux==-1)-jj+1-1];
% for e = 1:size(indx_chclus,1)          % here we give to every cluster (only in the time[rows] dimension)
%     data(indx_chclus(e,1):indx_chclus(e,2)) = e;
% end
% data = data';
% this is adapted from fieldtrip findcluster, it extends the cluster in the channel dimension 
% replaceby=1:max(data(:));
for chs = 1:length(i)
    aux_chcomb      = find((chan_comb(:,1)==i(chs) & chan_comb(:,2) ==j(chs)) | (chan_comb(:,2)==i(chs) & chan_comb(:,1) ==j(chs)));
      = find(bineighboursmat(aux_chcomb,:));
    
    
    
    for nbindx=neighbours
        indx = find((data(chan_comb(1),chan_comb(2))~=0) & (data(nbindx,:)~=0));
        for i=1:length(indx)
          a = data(chan, indx(i));
          b = data(nbindx, indx(i));
          if replaceby(a)==replaceby(b)
            % do nothing
            continue;
          elseif replaceby(a)<replaceby(b)
            % replace all entries with content replaceby(b) by replaceby(a).
            replaceby(find(replaceby==replaceby(b))) = replaceby(a); 
          elseif replaceby(b)<replaceby(a)
            % replace all entries with content replaceby(a) by replaceby(b).
            replaceby(find(replaceby==replaceby(a))) = replaceby(b); 
          end
        end
    end
end

% renumber the cluster to the number of element withint th cluster(the support)
switch tipo
    case ('sum')
        cluster = zeros(size(data));
        for uniquelabel=unique(replaceby(:))'
            clusauxindx = ismember(data(:),find(replaceby==uniquelabel)); 
            cluster(clusauxindx) = sum(clusauxindx);
        end
    case ('id') 
        cluster = zeros(size(data));
        a = 1;
        for uniquelabel=unique(replaceby(:))'
            clusauxindx = ismember(data(:),find(replaceby==uniquelabel)); 
            cluster(clusauxindx) = a;
            a = a+1;
        end
end