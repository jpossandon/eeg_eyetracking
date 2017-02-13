function clean_channel_corrections(cfg,filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function clean_channel_corrections()
% 
% this function change the file <sujid>_channel_correction it it exist,
% removing previous information about which channels to swithc or remove.
% However if the field chan_cor.pre for the specific files is set to 1,
% previous information is not changes (becuase it was preset by the experimenter)
%
% JPO, OSNA, dec/2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist([cfg.expfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'])
    load([cfg.expfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'])
    ix  =  strmatch(filename,chan_cor.filestochange);
    if ~isempty(ix)
        remove = [];
        for e = 1:length(ix) % i do not remeber why this is a set for a loo, but it is not a problem when it isn't
            if chan_cor.pre(ix(e))==0
                remove = [remove,ix(e)];
            end
        end
        chan_cor.filestochange(remove) = [];
        chan_cor.correct_chan(remove)  = [];
        chan_cor.elim_chan(remove)     = [];
        chan_cor.pre(remove)           = [];
    
    save([cfg.expfolder 'subjects_master_files/' upper(cfg.sujid) '_channels_corrections.mat'],'chan_cor')
    sprintf('\n%s_channels_corrections was reset for file %s\n',upper(cfg.sujid),filename) 
    end
end
