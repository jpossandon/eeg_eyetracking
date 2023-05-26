load(cfg_eeg.chanfile)
cfgp                = [];
cfgp.showlabels     = 'no'; 
cfgp.fontsize       = 12; 
cfgp.elec           = elec;
cfgp.interactive    = 'yes';
% cfgp.channel        = mirindx(1:38);
% cfgp.trials         = 4
 cfgp.baseline       = p.bsl;
 cfgp.baselinetype   = 'db';
% cfgp.ylim           = [0 40];
 %  cfgp.xlim           = [-.75 0];
%  cfgp.zlim           = [-.5 .5];
%   cfgp.maskparameter  = 'mask';
%   cfgp.maskalpha      = 1;
% cfgp.parameter      = 'stat';

%   data = GAbsl.RpreT0vsRpre
 data = TFRav.Lsacpre.ICAem
%      data =GAbsl.C_Ici;
% %  data.mask = statUCIci.mask;
figure,ft_multiplotTFR(cfgp,data)
