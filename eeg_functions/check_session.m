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
load([cfg.preprocanalysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name],'channelbad')

% it is possible to define bad channels acordint to how much of the
% complete recording is bad, or how much of the relevant segments are bad
if isfield(cfg,'clean_bad_channel_denominator')
    if ~any(strcmp(cfg.clean_bad_channel_denominator,'all'))
        % get the relevant segments
        event  = ft_read_event([cfg.eegfolder cfg.event]);
        begind_eeg = []; 
        ev_sample = [event.sample]';
        for e = 1:size(cfg.clean_bad_channel_denominator,1)
            aux_indx            = find(strcmp(cfg.clean_bad_channel_denominator{e,1}, {event.value}));
            begind_eeg          = [begind_eeg;[ev_sample(aux_indx)-cfg.clean_bad_channel_denominator{e,2}(1) ...
                ev_sample(aux_indx)+cfg.clean_bad_channel_denominator{e,2}(2)]];
        end
        [qwe,I]     = sort(begind_eeg(:,1));
        begind_eeg  = begind_eeg(I,:);
        % consolidate overlaping segments
        cur_seg     = 1;
        while cur_seg<size(begind_eeg,1)
            whithinsegs = find(begind_eeg(:,1)>begind_eeg(cur_seg,1) & begind_eeg(:,2)<begind_eeg(cur_seg,2));
            if ~isempty(whithinsegs)
                begind_eeg(whithinsegs,:) = [];
            end
            st_whithin = find(begind_eeg(:,1)>begind_eeg(cur_seg,1) & begind_eeg(:,1)<begind_eeg(cur_seg,2));
            if ~isempty(st_whithin)
                begind_eeg(cur_seg,2) = begind_eeg(st_whithin(end),2);
                begind_eeg(st_whithin,:) = [];
            else
                cur_seg = cur_seg+1;
            end
        end
        denominator = sum(begind_eeg(:,2)-begind_eeg(:,1));
    else
        denominator = hdr.nSamples;
        begind_eeg  = [];
    end
 else
        denominator = hdr.nSamples;
        begind_eeg  = [];
 end
                
% here we check the % of bad data per channel
for ch = 1:hdr.nChans
%     indxbad         = find(badchans(ch,:));
% redo this to either do it for the compelte dataset or for windows around
% an event defining a trial
    if isempty(channelbad)
        ch_ratio        = zeros(1,hdr.nChans);
    else
        aux_bad         = channelbad{ch};
        if ~isempty(begind_eeg)
            elim_aux_bad = [];
            aditional_aux_bad = [];
            for ab = 1:size(aux_bad,1)
		      seg_in = find(begind_eeg(:,1)>aux_bad(ab,1) & begind_eeg(:,2)<aux_bad(ab,2));
                if ~isempty(seg_in)
                    aditional_aux_bad = [aditional_aux_bad;begind_eeg(seg_in,:)];
                end                
			 st_in  =  find(begind_eeg(:,1)<aux_bad(ab,1) & begind_eeg(:,2)>aux_bad(ab,1)); % start whithin a relevant segment
                end_in =  find(begind_eeg(:,1)<aux_bad(ab,2) & begind_eeg(:,2)>aux_bad(ab,2)); % end whithin a relevant segment
                if isempty(st_in) && isempty(end_in)
                    elim_aux_bad = [elim_aux_bad,ab];
                elseif isempty(st_in) && ~isempty(end_in)
                    aux_bad(ab,1) = begind_eeg(end_in,1);
                elseif ~isempty(st_in) && isempty(end_in)
                    aux_bad(ab,2) = begind_eeg(st_in,2);
                end
                
            end
            aux_bad(elim_aux_bad,:) = [];
            aux_bad = [aux_bad;aditional_aux_bad];
        end
        ch_ratio(ch)    = sum(diff(aux_bad'))./denominator;
    end
end
save([cfg.preprocanalysisfolder cfg.analysisname '/' cfg.sujid '/' cfg.filename cfg.clean_name '.mat'],'ch_ratio','-append')

% tag bad channel
rem_chan = find(ch_ratio>cfg.clean_bad_channel_criteria);
if ~isempty(rem_chan)
    if exist([cfg.preprocanalysisfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'])
        load([cfg.preprocanalysisfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'])
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
    save([cfg.preprocanalysisfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'],'chan_cor')
end
     
