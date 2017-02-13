function cfge = basic_preproc_cfg(cfg,event_file,varargin)

cfge                 = [];
cfge.datafile        = [cfg.eegfolder,event_file(1:end-5),'.eeg'];
cfge.headerfile      = [cfg.eegfolder,event_file(1:end-5),'.vhdr'];
cfge.event           = [cfg.eegfolder,event_file];
cfge.detrend         = 'no';
cfge.demean          = 'no';
cfge.reref           = 'no';
% cfge.refchannel      = cellstr(num2str([1:61]'));
% cfge.refchannel      = 1:61;

for nv = 1:2:length(varargin)
    cfge.(varargin{nv}) = varargin{nv+1};
end