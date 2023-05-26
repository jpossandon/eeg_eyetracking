function elec = bineigh(elec)

% bivariate neighbours

% all possible combinations of channels
bi.chan_comb            = nchoosek(1:length(elec.label),2);                 

% neighbour structure for pairs of channels, for a given pair (1,2) this 
% consist in all other pairs of channels with channels that neighbours
% one of the element of the given pair
bi.channeighbstructmat    = zeros(length(bi.chan_comb));                    

% pairs of channels which do not share neighbours
% bi.chan_comb_noneigh    = nchoosek(1:length(elec.label),2);                 

% search for the neighbours pairs
chan_neigh_same         = elec.channeighbstructmat+diag(ones(1,size(elec.channeighbstructmat,1))); % this is necessary to find neighbour connection in which one of the nodes is memebr of the given pair
for bc = 1:length(bi.chan_comb)
    ch1             = bi.chan_comb(bc,1);
    ch2             = bi.chan_comb(bc,2);
    neighch1        = chan_neigh_same(ch1,:); 
    neighch2        = chan_neigh_same(ch2,:);
    bi.channeighbstructmat(bc,:) = (ismember(bi.chan_comb(:,1),find(neighch1)) & ...
        ismember(bi.chan_comb(:,2),find(neighch2))) | ...
        (ismember(bi.chan_comb(:,2),find(neighch1))&ismember(bi.chan_comb(:,1),find(neighch2)));
    bi.noneigh(bc)  = ~chan_neigh_same(ch1,ch2)';
end
bi.noneigh  = bi.noneigh';
elec.bi     = bi;