%[STATS] = area_cunder_curve(Act, Con, varargin)
%Function to compute area under curve (auc) for two classes of observations. 
%If the function is called like:
%
%   area_under_curve(Act, Con)
%
%then the STATS output will have one field for auc. If confidence intervals
%are needed, call like: 
%
%   area_under_curve(Act, Con, method)
%
%or
%
%   area_under_curve(Act, Con, method, alph) 
%
%Method can be 'MW' (CI for Mann-Whitney-U statistic, which is the auc) or
%'MW-LT' (logit transformed CI). The latter should be preferred for auc
%values close to one. 'alph' is the desired alpha level, the default is
%0.05 for 95% confidence intervals. If method is specified STATS will have
%fields: uCI (upper CI), lCI (lower CI), CIcover (like 95 or 99, depending
%on your alph)
%
%In order to understand what is going on, please refer to:  
%Qin, C. & Hotilovac, L. (2008). Comparison of non-parametric confidence 
%intervals for the area under the ROC curve of a continuous-scale diagnostic
%test. Statistical Methods in Medical Research,17:207.

function [auc,STATS] = area_under_curve(Act, Con, varargin)

%ATTENTION: In the LC modification framework, for negative modifications, I
%call the function with controls as the first input and actuals as the
%second; since I prefer to have values over 0.50 for all attention 
%attracting effects, and values below 0.50 for repulsion effects.

Act = sort(Act(:)); Con = sort(Con(:));
m = length(Act); n = length(Con);
thelist = [Act(:); Con(:)];
thetruth = [ones(length(Act), 1); zeros(length(Con), 1)];
ranks = tiedrank(thelist);  
auc = (sum(ranks(thetruth == 1)) - (m^2 + m)/2) / (m * n);


if nargin > 2
    method = varargin{1};
    
    if nargin == 3
        alph = 0.05;
    else
        alph = varargin{2};
    end

    ranksAct = ranks(1:m);
    ranksCon = ranks(m+1:end);
    S10 = sub_S(ranksAct, ranksCon); %sub_S function is defined below.
    S01 = sub_S(ranksCon, ranksAct);
    S = ((m*S01+n*S10)/(length([Act; Con])))^0.5;
    if strcmp(method, 'MW')
        lCI = auc - (norminv(1-alph/2)*(((m+n)*S^2)/(m*n))^0.5);
        uCI = auc + (norminv(1-alph/2)*(((m+n)*S^2)/(m*n))^0.5);
    elseif strcmp(method, 'MW-LT')
        
        varauc = ((m+n)*S^2)/(m*n);

        LL = log(auc/(1-auc)) - norminv(1-alph/2)*(sqrt(varauc)/(auc*(1-auc)));
        UL = log(auc/(1-auc)) + norminv(1-alph/2)*(sqrt(varauc)/(auc*(1-auc)));

        lCI = (exp(LL)/(1+exp(LL))); %Please note that this definition of
        %                            lCI is identical with the other one. 
        %                            Only uCI changes between the two
        %                            methods, here they are given for
        %                            completeness only
        uCI = (exp(UL)/(1+exp(UL)));
    end
    
    STATS.uCI = uCI;
    STATS.lCI = lCI;
    STATS.CIcover = 100*(1-alph);
end

STATS.AUC = auc;
STATS = orderfields(STATS);

function Ssub = sub_S(one, two)
m = length(one); n = length(two);
outerel  = 1/((m-1)*(n^2));
inds = 1:m;
inds = inds(:);
innerel1 = sum((one - inds).^2); 
innerel2 = m*(mean(one)-((m+1)/2)^2);
Ssub = outerel*(innerel1 - innerel2);

