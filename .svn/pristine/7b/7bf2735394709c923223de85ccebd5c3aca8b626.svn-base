function [tmSE,yuenSE,wva] = winvar(data,trim)


lD                  = size(data,1);
ga                  = floor(trim*lD);
   
asort               = sort(data,1);
wa                  = asort;

wa(1:ga+1,:,:)      = repmat(asort(ga+1,:,:),[ga+1 1 1]);
wa(lD-ga:end,:,:)   = repmat(asort(lD-ga,:,:),[ga+1 1 1]);

wva                 = var(wa,0,1);

% yuen's estimate of standard error (for bootstrap t comparison of two
% mean), actually is the squeared SE (p. 329 Wilcox, Modern statistic for the social and behavioral sciences)
ha                  = lD-2*ga;
yuenSE              = ((lD-1)*wva)/(ha*(ha-1));
      
% standard error of the trimmed mean (p. 61 Wilcox, Introduction to robust
% estimation and hypothesis testing)
tmSE                = sqrt(wva./lD)./(1-2*trim);