function artifact_continous(cfg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function artifact_continous(cfg,cfg.filename,cfg.event,varargin)
%  artifact rejection over the complete data file, it can be visually selected
%  bad segments or automatically selected segments 
% input -
%           cfg         : experimental parameters obtained with eeg_etParams
%
%                   cfg.artifact_reject_type :
%                           - 'visual': data can be rejected directly from scrolled data (eeglab)
%                           - 'automatic': dta is rejected automatically,
%                                   it anyways segments the data in non-overlapping
%                                   segments.
%
%                                   cfg.artifact_chunks_length  : length in 
%                                                               samples of non-overlapping segments 
%
%                                   cfg.artifact_auto_var       : 'yes','no', if selected, it selects 
%                                                               bad segments according to their variance and
%                                  
%                                   cfg.zthreshold              : Z-value trheshold for rejectinc trial according
%                                                               to their variance
%
%                                   cfg.artifact_auto_muscle    : 'yes'/'no', use fieldtrip
%                                                               muscle artifac rejection method
%                                   cfg.muscle_threshold        : Z-value trheshold for rejectinc trial according
%                                                               to their muscle activity variance
%
%           cfg.filename    : name of the original eye-tracking EDF file,
%           cfg.event  : name of the corresponding eeg eventfile (*.vmrk)
%
% output - it saves a matrix bad with the time segments to reject in the file : [cfg.filename(1:end-4) '_expgen_continous_var'
%           num2str(cfg.zthreshold) '_muscle' num2str(cfg.muscle_threshold) '.mat']
%
% jpo OSNA 25/05/2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load([cfg.eyeanalysisfolder cfg.filename 'eye.mat'])
if strcmp(cfg.artifact_reject_type,'visual')
    if strcmp(cfg.eyedata,'yes')
        load([cfg.eyeanalysisfolder cfg.filename 'eye.mat'])
    end
   
    event                           = ft_read_event([cfg.eegfolder, cfg.filename, '.vmrk']);
    hdr                               = ft_read_header([cfg.eegfolder, cfg.filename, '.vhdr']);
    if strcmp(cfg.datastats,'all_chunks')
        if length(event)>1
            starts                      = [event(2).sample: cfg.artifact_chunks_length:event(end).sample]';        % we look at data between first and last trigger
        else
            starts                      = [1: cfg.artifact_chunks_length:hdr.nSamples]';        % we look at data between first and last trigger
        end
    elseif strcmp(cfg.datastats,'events_chunks')
        startsaux = [];
        for e=1:length(cfg.trial_trig_eeg)
            indxevents                  = find(strcmp(cfg.trial_trig_eeg{e}, {event.value}));
            samples                     = [event.sample];
            startsaux                   = [startsaux;samples(indxevents)'];
        end
        startsaux=sort(startsaux);
        starts = [];
        chunksper = (cfg.trial_time(2)-cfg.trial_time(1))./cfg.artifact_chunks_length;
        for e = 1:length(startsaux)
             starts = [starts;[startsaux(e)+cfg.trial_time(1):cfg.artifact_chunks_length:startsaux(e)+chunksper*cfg.artifact_chunks_length]'];
        end
    end
    
    %adding eye movements
    if strcmp(cfg.datastats,'all')
        epochevents.start = eyedata.events.start;
        epochevents.type = eyedata.events.type;
    else
        epochevents.start = [starts'*1000./hdr.Fs, eyedata.events.start];
        epochevents.type = [ones(1,length(starts)),eyedata.events.type];
    end
    EEG = toeeglab(cfg,cfg.filename,epochevents,[])   ;
%     assignin('base', 'EEG', EEG)
    assignin('base', 'filename', [cfg.filename])
    assignin('base', 'cfg_ac', cfg)
   
    
    if ~strcmp(cfg.datastats,'all')
        assignin('base', 'starts', starts)
        EEG = pop_epoch( EEG, {  '1'  }, [0  cfg.artifact_chunks_length./EEG.srate]);
        assignin('base', 'EEG', EEG)
        EEG = pop_rmbase( EEG,[]);
        epoch_n = double(cfg.artifact_chunks_length./EEG.srate.*1000);
    end
    
    if  strcmp(cfg.datastats,'all_chunks')&& exist([cfg.analysisfolder 'cleaning/' cfg.sujid '/' cfg.filename '_auto_continous_chunk' num2str(cfg.artifact_chunks_length) '.mat']);
        load([cfg.analysisfolder 'cleaning/' cfg.sujid '/' cfg.filename '_auto_continous_chunk' num2str(cfg.artifact_chunks_length) '.mat'],'bad','badchans');
        autobadaux =bad(:,1);
        clear bad
    
        autobad = zeros(length(autobadaux),EEG.nbchan+5);
        [C,IA,IB] =intersect(starts,autobadaux(:,1));
        autobad(:,1) = (IA-1)*cfg.artifact_chunks_length;
        autobad(:,2) = autobad(:,1) + cfg.artifact_chunks_length;
        autobad(:,3) = .7;    
        autobad(:,4) = 1;    
        autobad(:,5) = .9;    
        autobad(:,6:end) = badchans'>0;
             eegplot( EEG.data, 'srate', EEG.srate, 'title', 'Scroll component activities -- eegplot()', ...
                 'limits', [EEG.xmin EEG.xmax]*1000 , 'winlength', 5, 'events', EEG.event, ...
                 'winrej',autobad, 'command', 'TMPREJI    = sort(TMPREJ(:,1));', 'eloc_file', EEG.chanlocs ); 
    elseif strcmp(cfg.datastats,'all') && exist([cfg.analysisfolder 'cleaning/' cfg.sujid '/' cfg.filename '_auto_continous.mat']);
        load([cfg.analysisfolder 'cleaning/' cfg.sujid '/' cfg.filename '_auto_continous.mat'],'bad','badchans');
        autobad = zeros(size(bad,1),EEG.nbchan+5);
        autobad(:,1) = bad(:,1);
        autobad(:,2) = bad(:,2);
        autobad(:,3) = .7;    
        autobad(:,4) = 1;    
        autobad(:,5) = .9;    
        autobad(:,6:end) = badchans'>0;
             eegplot( EEG.data, 'srate', EEG.srate, 'title', 'Scroll component activities -- eegplot()', ...
                 'limits', [EEG.xmin EEG.xmax]*1000 , 'winlength', 5, 'events', EEG.event, ...
                 'winrej',autobad, 'command', 'TMPREJI    = sort(TMPREJ(:,1));', 'eloc_file', EEG.chanlocs ); 
    else
                  eegplot( EEG.data, 'srate', EEG.srate, 'title', 'Scroll component activities -- eegplot()', ...
                 'limits', [EEG.xmin EEG.xmax]*1000 , 'winlength', 5, 'events', EEG.event, ...
                 'command', 'TMPREJI    = sort(TMPREJ(:,1));', 'eloc_file', EEG.chanlocs ); 
    end


     while strcmp(get(gcf,'Tag'),'EEGPLOT')
        pause(5)
     end
    
    evalin('base','badindx = 1+TMPREJI./double(cfg.artifact_chunks_length);');
    evalin('base',' bad = [starts(badindx) starts(badindx)+cfg.artifact_chunks_length];');
    
    evalin('base','save([cfg_ac.analysisfolder ''cleaning/'' cfg_ac.sujid ''/'' filename ''_visual_continous_chunk'' num2str(cfg.artifact_chunks_length) ''.mat''],''bad'')');
    evalin('base','clear badindx EEG EEGTMP Eventindx LASTCOM TMPREJ bad cfg_ac filename starts TMPREJI');

elseif strcmp(cfg.artifact_reject_type,'automatic')
    aux = [];
    if strcmp(cfg.artifact_auto_stat,'yes')
        if strcmp(cfg.thresholds,'file')
            filename = [cfg.filename '_eegstats_chunksize_' num2str(cfg.artifact_chunks_length) '.mat'];
            load([cfg.analysisfolder 'expstats/' filename],'stat')
            if strcmp(cfg.thresholds,'pop')
                if strcmp(cfg.thresholds_otherexp,'no')
                    load([cfg.analysisfolder 'expstats/allsubj_thresholds'],'thresholds')
                end
            elseif strcmp(cfg.thresholds,'subj')
                thresholds.absrange     = prctile(stat.absolute_range',[cfg.absthreshold]);
                thresholds.std          = prctile(stat.check',[cfg.stdthreshold]);
                thresholds.kurtosis     = prctile(stat.kurtosis',[cfg.kurtosisthreshold]);
            end

            [I,Jabs]                           = ind2sub(size(stat.absolute_range),find(stat.absolute_range>repmat(thresholds.absrange,1,size(stat.absolute_range,2))...
                                                    | stat.absolute_range==0));
            [I,Jstd]                           = ind2sub(size(stat.check),find(stat.check>repmat(thresholds.std,1,size(stat.check,2))));
            [I,Jkurt]                          = ind2sub(size(stat.kurtosis),find(stat.kurtosis>repmat(thresholds.kurtosis,1,size(stat.kurtosis,2))));

            aux = [aux;stat.trl(union(union(Jstd,Jabs),Jkurt),1:2)];
            total_trl = size(stat.trl,1);
        elseif strcmp(cfg.thresholds,'subj') || strcmp(cfg.thresholds,'pop')
           if strcmp(cfg.thresholds,'subj')
                load([cfg.eegstats '/' cfg.sujid '_pct'])
           else
                load([cfg.analysisfolder 'eeg_stats/all_pct'])
           end
           load([cfg.eegstats cfg.filename])
           
           n           = size(stat.absolute_range,2);
            outchunk_a  = zeros(64,n);
            outchunk_alow  = zeros(64,n);
            outchunk_k  = zeros(64,n);
            outchunk_z  = zeros(64,n);
            for e = 1:64
                outchunk_a(e,stat.absolute_range(e,:)<pct_a(1,e) | stat.absolute_range(e,:)>pct_a(2,e))=1;
                outchunk_k(e,stat.kurtosis(e,:)<pct_k(1,e) | stat.kurtosis(e,:)>pct_k(2,e))=1;
                outchunk_z(e,stat.check(e,:)<pct_z(1,e) | stat.check(e,:)>pct_z(2,e))=1;
                outchunk_alow(e,stat.absolute_range(e,:)==0)=1;
            end
            alloutchunk = outchunk_a+outchunk_k+outchunk_z+outchunk_alow;
            out_akz     = sum([sum(outchunk_a);sum(outchunk_k);sum(outchunk_z);sum(outchunk_alow)]);
            aux         = [aux;stat.trl(find(out_akz),1:2)];
            alloutchunk = alloutchunk(:,find(out_akz));
            total_trl   = size(stat.trl,1);
        end
    end
    
    [B,I]                               = sort(aux(:,1));
    bad                                 = aux(I,:);
   badchans                     = alloutchunk(:,I); 
    filename = [cfg.filename '_auto_continous_chunk' num2str(cfg.artifact_chunks_length) '.mat'];
    save([cfg.analysisfolder 'cleaning/' cfg.sujid '/' filename],'bad','total_trl','badchans');
    
else
    error('Artifact rejection type not defined')
end
        % close all
    
         