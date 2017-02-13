function check_session(cfg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function check_session(cfg)
% Check in a given eeg file (cfg.filename) the amount of bad data per
% channel according to previously generated clean file [cfg.filename
% cfg.clean_name] and save it in the same file. The clean file has variables
% 'bad' in which the bad segments in eeg samples are defined and badchans
% which codes which channel(s) meade the corresponding segment in 'bad' 
% Also if  ratio of bad data
% to total data is above a threshold (cfg.clean_bad_channel_criteria), then
% it marks the channel for removal in a subject specific field
%
% JPO OSNA 2/04/2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hdr                 = ft_read_header([cfg.eegfolder, cfg.filename, '.vhdr']);
load([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name],'channelbad')

% here we check the % of bad data per channel
for ch = 1:hdr.nChans
%     indxbad         = find(badchans(ch,:));
    if isempty(channelbad)
        ch_ratio        = zeros(1,hdr.nChans);
    else
        aux_bad         = channelbad{ch};
        ch_ratio(ch)    = sum(diff(aux_bad'))./hdr.nSamples;
    end
end
save([cfg.analysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name '.mat'],'ch_ratio','-append')

% tag bad channel
rem_chan = find(ch_ratio>cfg.clean_bad_channel_criteria);
if ~isempty(rem_chan)
    if exist([cfg.expfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'])
        load([cfg.expfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'])
    else   
        chan_cor.filestochange   = {};
        chan_cor.correct_chan    = {};
        chan_cor.elim_chan       = {};
        chan_cor.pre             = [];
    end
    for e = 1:length(rem_chan)
        already_tag = strmatch(cfg.filename,chan_cor.filestochange);   % the file might be already tag to elim
        skip = 0;
        if ~isempty(already_tag)                              % so we check it t
            for t = 1:length(already_tag)
                if chan_cor.elim_chan{already_tag(t)}==rem_chan(e)
                    skip = 1;
                end
            end
        end
        if skip == 0
            chan_cor.filestochange{end+1}    = cfg.filename;
            chan_cor.correct_chan{end+1}     = [];
            chan_cor.elim_chan{end+1}        = rem_chan(e);
            chan_cor.pre(end+1)              = 0;
        end
    end
    save([cfg.expfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'],'chan_cor')
end
     
