function [T,tstat] = tfce(dat1,dat2,neighboursmat,stat)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [T,tstat] = tfce(dat1,dat2,neighboursmat)
%
%       - stat: 'paired'    , uses ttest, make senses when doing whithin
%                           subjects contrasts
%               'unpaired'  , uses ttest2, make sense when doing between
%               subjects contrasts or whithin single subject comparison
%               'stat'      , input dat1 is already the stat map, dat2 is
%               not used
%
% JPO, OSNA, 23.05.13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(stat,'unpaired')
    [~,~,~,s]       = ttest2(dat1,dat2);  
    tstat           = squeeze(s.tstat);

elseif strcmp(stat,'paired')
    [~,~,~,s]       = ttest(dat1,dat2);               % TODO: I have not tried this option yet
    tstat           = squeeze(s.tstat);

elseif strcmp(stat,'stat')
    tstat           = dat1;
end
% tstat           = squeeze(s.tstat);
[ch,t]          = size(tstat);

% clustering support has to be done separatedly for negative and positive
% values, at the end we can sum everything

h_steps_pos     = [0:.1:max(tstat(:))]';           % this is the range of values the ttest took for this randomization
h_steps_neg     = [0:-.1:min(tstat(:))]';          
% if length(h_steps_neg)+length(h_steps_pos)>10000
%     ch
% end
t_pos           = tstat;
t_pos(t_pos<0)  = 0;
t_neg           = tstat;
t_neg(t_neg>0)  = 0;

% Here, we create logical arrays dimension channels x time x hvalue, 1 means 
% that the specifict channel and time sample has a t statistic over the corresponding h value 

h_pos           = repmat(t_pos,[1,1,length(h_steps_pos)])-repmat(reshape(h_steps_pos,[1 1 length(h_steps_pos)]),[ch,t,1])>0; 
h_neg           = repmat(t_neg,[1,1,length(h_steps_neg)])-repmat(reshape(h_steps_neg,[1 1 length(h_steps_neg)]),[ch,t,1])<0; 

% figure,plot(tstat),
tpos = clus_support(h_pos,neighboursmat);
tneg = clus_support(h_neg,neighboursmat);
% close all
E = 2/3;        %TODO: this are the parameters reported before, values and the basic equation come from "SMITH,S. (2009). Threshold-free cluster enhancement... .Neuroimage 44:83
H = 2;
T = sum(tpos.^E.*repmat(reshape(h_steps_pos,[1,1,length(h_steps_pos)]),[ch,t,1]).^H,3)-sum(tneg.^E.*repmat(reshape(h_steps_neg,[1,1,length(h_steps_neg)]),[ch,t,1]).^H,3); 

function clus_sup = clus_support(data,neighboursmat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function clus_sup = clus_support(data,neighboursmat)
%       This functions define the support in terms of time corresponding to
%       the numebrs of columns in data, and in terms of space according to
%       the electrode neighbours described in the logical matrix
%       neighboursmat. Suport is calculated for every electrodeXtimepoint
%       and h values that correspond to the 3rd dimension in data and it
%       correspond to the total number of contiguous elements in time and
%       space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [r,c,f] = size(data);
    clus_sup = zeros(size(data));
    for hsteps = 1:size(data,3)                % we go through all defined hsteps
        labelmat = double(data(:,:,hsteps)'); 
        [cluster] = findclus(labelmat,neighboursmat,'sum');
        clus_sup(:,:,hsteps) = cluster;
    end

