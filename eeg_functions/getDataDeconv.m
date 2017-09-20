function [EEG,winrej] = getDataDeconv(cfg,epochevents)    
EEG         = toeeglabnew(cfg,cfg.filename,epochevents,[]);                       
    EEG.event   = rmfield(EEG.event,'value');                   
    EEG         = eeg_checkset( EEG );

        % resampling otherwise the deconvolution matirx is imposible
    rsf         = 100;
    oldsf       = EEG.srate;
    EEG         = pop_resample( EEG, rsf);

    % bad data from my cleaning procedure
    load([cfg.analysisfolder 'cleaning/' cfg.sujid '/' cfg.filename cfg.clean_name],'bad');  
    winrej      = round(bad/(oldsf/rsf));                              % to match the resampling
       % removal of channels
    cfg         = correct_channels(cfg);
    if ~isempty(cfg.elim_chan)
        origChanloc = EEG.chanlocs;
        EEG         = pop_select( EEG,'nochannel',cfg.elim_chan);
        EEG         = eeg_checkset( EEG );
    end
    % this takes out the ICA component considered artefactual
    load([cfg.analysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'],'cfg_ica')   
    EEG = pop_subcomp( EEG, unique([cfg_ica.comptoremove;cfg_ica.comptoremove_m])', 0); 

     % after ICA removal we interpolate missing channels
    if ~isempty(cfg.elim_chan)
        EEG         = pop_interp(EEG, origChanloc, 'spherical');
        clear origChanloc
    end
    %need to filter the data, otherwise betas all disalignes
    EEG = pop_eegfiltnew(EEG, [], 0.2, 4126, true, [],0);
    EEG = eeg_checkset( EEG );