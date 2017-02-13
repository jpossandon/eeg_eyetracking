function  visual_clean(cfg)

if strcmp(cfg.eyedata,'yes') || cfg.eyedata ==1
        load([cfg.eyeanalysisfolder cfg.filename 'eye.mat'])
end
   
event                           = ft_read_event([cfg.eegfolder, cfg.filename, '.vmrk']);
hdr                               = ft_read_header([cfg.eegfolder, cfg.filename, '.vhdr']);


if strcmp(cfg.eyedata,'yes') || cfg.eyedata ==1
    epochevents.start = eyedata.events.start;
    epochevents.type = eyedata.events.type;
    EEG = toeeglab(cfg,cfg.filename,epochevents,[]);
else
    EEG = toeeglab(cfg,cfg.filename,[],[]);
end



if (cfg.remove_eye || cfg.remove_m) && cfg.raw
    EEG = eeg_checkset( EEG );
    load([cfg.analysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'],'cfg_ica')   
    if cfg.remove_eye && cfg.remove_m
        EEG = pop_subcomp( EEG, unique([cfg_ica.comptoremove;cfg_ica.comptoremove_m])', 0);
    elseif cfg.remove_eye
        EEG = pop_subcomp( EEG, cfg_ica.comptoremove', 0);
    elseif cfg.remove_m
        EEG = pop_subcomp( EEG, cfg_ica.comptoremove_m', 0);
    end
    EEG = eeg_checkset( EEG );
end

    
    if ~isempty(cfg.clean_name)
        load([cfg.analysisfolder 'cleaning/' cfg.sujid '/' cfg.filename cfg.clean_name '.mat'],'bad','badchans');
        autobad = zeros(size(bad,1),EEG.nbchan+5);
        autobad(:,1) = bad(:,1);
        autobad(:,2) = bad(:,2);
        autobad(:,3) = .7;    
        autobad(:,4) = 1;    
        autobad(:,5) = .9;    
        autobad(:,6:end) = badchans'>0;
        if cfg.raw
             eegplot( EEG.data, 'srate', EEG.srate, 'title', 'Scroll component activities -- eegplot()', ...
                 'limits', [EEG.xmin EEG.xmax]*1000  ,'spacing',50, 'winlength', 10, 'events', EEG.event, ...
                 'winrej',autobad, 'command', 'TMPREJI    = sort(TMPREJ(:,1:2));', 'eloc_file', EEG.chanlocs ); 
        else
              [EEG]       = eeg_checkset(EEG);
             eegplot( EEG.icaact, 'srate', EEG.srate, 'title', 'Scroll component activities -- eegplot()', ...
                 'limits', [EEG.xmin EEG.xmax]*1000 , 'winlength', 10, 'events', EEG.event, ...
                 'winrej',autobad, 'command', 'TMPREJI    = sort(TMPREJ(:,1:2));', 'eloc_file', EEG.icachansind ); 
        end
    else
                  eegplot( EEG.data, 'srate', EEG.srate, 'title', 'Scroll component activities -- eegplot()', ...
                 'limits', [EEG.xmin EEG.xmax]*1000 , 'winlength', 10, 'events', EEG.event, ...
                 'command', 'TMPREJI    = sort(TMPREJ(:,1));', 'eloc_file', EEG.chanlocs ); 
%                eegplot( EEG.icaact, 'srate', EEG.srate, 'title', 'Scroll component activities -- eegplot()', ...
%                  'limits', [EEG.xmin EEG.xmax]*1000 , 'winlength', 10, 'events', EEG.event, ...
%                  'command', 'TMPREJI    = sort(TMPREJ(:,1));', 'eloc_file', EEG.chanlocs ); 
    end

    

     while strcmp(get(gcf,'Tag'),'EEGPLOT')
        pause(5)
     end

     if evalin('base','exist(''TMPREJI'')') % TODO:iamo not sure this works well
        newbad = evalin('base','TMPREJI');
        [c,ia,ib]               = intersect(bad(:,1),newbad(:,1));
        newbadchans             = zeros(size(badchans,1),size(newbad,1));
        newbadchans(:,ib)       = badchans(:,ia);
        bad                     = round(newbad);
        badchans                = newbadchans;
        if strfind(cfg.clean_name,'vischeck')
           save([cfg.analysisfolder 'cleaning/' cfg.sujid '/' cfg.filename cfg.clean_name],'bad','badchans');
        else
            save([cfg.analysisfolder 'cleaning/' cfg.sujid '/' cfg.filename cfg.clean_name '_vischeck.mat'],'bad','badchans');
        end
         evalin('base','clear TMPREJ TMPREJI');
     end
    
