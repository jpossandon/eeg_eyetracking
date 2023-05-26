 % one channel plotting
 cfgp               = [];
 cfgp.channel       = 35;
%  cfgp.pred_value    = {{'pxini',-10:10}};
 cfgp.add_intercept = 0;
 cfgp.plotSeparate  = 'all';
 dc_plotParam(unfold,cfgp);

 %topos
%        warning off;
      cfgp = [];
      cfgp.channel = 1:64;
        cfgp.plotParam = {'pxdiff'};
%      %cfgp.plotParam = {'pyini'};
       cfgp.time   = [-.3 0];
       dc_plotParamTopo(unfold,cfgp)  