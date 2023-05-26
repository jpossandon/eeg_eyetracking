function expica(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function expica(cfg)
% ICA of pre-experiment,experiement or both 
% 
% input:
% cfg. 
%    
% output: saves a figure of the topoplot of the ICA weigths calculated with 
%         the respective ratio (var_component_saccade/var_component_fixation) and
%         a (cfg.EDFname(1:end-4))_ICA.mat file in the analysis folder with 
%         the cfg_ica structure. 
% 
%         !ICA iteration is not working
% jpo 8/03/10 OSNA
% jpo 21.06.11 Eliminate a lot. There is no more distinction between
% pre-experiment and experimental data, now codes do ica for all cfg
% structures giver to the function. Also there is no iteration anymore,
% fixed things for running in new fieldtrip
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% 
cfg_ica                             = [];
for e = 1:length(varargin)              % loop through different datasets/sessions/blocks etc
    cfg                             = varargin{e}; 
   
    %%%%%%%%%%%%%
    % this is for experiment where many files are analyzed together
    cfg                             = correct_channels(cfg); % if we need to change channels locations, this need to be included in the same function file
    %%%%%%%%%%%%%
    
    [event]                         = ft_read_event([cfg.eegfolder cfg.event]);        % read for eeg events
    hdr                             = ft_read_header([cfg.eegfolder, cfg.filename, '.vhdr']);

    if strcmp(cfg.ica_data,'all') || strcmp(cfg.ica_data,'allfirsthp')
       if length(event)>2
            starts                      = [event(2).sample: cfg.ica_chunks_length:event(end).sample]';        % we look at data between first and last trigger
        else
            starts                      = [1: cfg.ica_chunks_length:hdr.nSamples-cfg.ica_chunks_length]';        % we look at data between first and last trigger
        end
    elseif strcmp(cfg.ica_data,'events')
        startsaux = [];
        for ip=1:length(cfg.trial_trig_eeg)
            indxevents                  = find(strcmp(cfg.trial_trig_eeg{ip}, {event.value}));
            samples                     = [event.sample];
            startsaux                   = [startsaux;samples(indxevents)'];
        end
        startsaux=sort(startsaux);
    end  
    cfge                            = basic_preproc_cfg(cfg,cfg.event,'padding',cfg.ica_chunks_length/hdr.Fs*2,'lpfilter','yes','lpfreq',cfg.lpfreq,'demean','yes');
    cfge.continuous                 = 'yes';
    if strcmp(cfg.ica_data,'events')
        starts = [];
        chunksper = (cfg.trial_time(2)-cfg.trial_time(1))./cfg.ica_chunks_length;
        for ip = 1:length(startsaux)
            starts = [starts;[startsaux(ip)+cfg.trial_time(1):cfg.ica_chunks_length:startsaux(ip)+chunksper*cfg.ica_chunks_length]'];
        end
    end
    cfge.trl                        = [starts,starts+cfg.ica_chunks_length-1,zeros(length(starts),1)];  
    
    [newtrl,toelim]                 = clean_bad(cfg,cfge.trl);              % eliminates egment that are bad according to the previos cleaning
    
    if strcmp(cfg.ica_data,'allfirsthp')
        cfge.hpfilter = 'yes';
        cfge.hpfreq   = 2.5;
        cfge.trl      = [newtrl(1,1) newtrl(end,2) 0];
        preartiALL    = ft_preprocessing(cfge);
        cfgaux.trl    = newtrl;
        prearti       = ft_redefinetrial(cfgaux, preartiALL);
    else
        cfge.trl                        = newtrl;
        prearti                         = ft_preprocessing(cfge);   
    end
    if ~isempty(cfg.correct_chan)                                           % in case channels are changed
        for ip=1:length(prearti.trial)
            prearti.trial{ip}    = prearti.trial{ip}(cfg.correct_chan,:);
        end
    end
    cfg_ica.elimined{e}             = toelim;
    cfg_ica.total{e}                = length(prearti.trial);
    % combine data of differen sets
    if e==1
        combdata            = prearti;
    else
        combdata.trial      = [combdata.trial prearti.trial];
        combdata.time       = [combdata.time prearti.time];
    end
    clear prearti
    if isfield(cfg,'spoverweight')
        if ~isempty(cfg.spoverweight)
            load([cfg.eyeanalysisfolder cfg.filename 'eye'])                                % use weight from pre_exp in experiment data to define artifact components
            [trlsacaux,eventsacaux] = define_event(cfg,eyedata,2,{'amp','<50'},[20 10]);   % rather long saccades work better
            [newtrl,toelim]                 = clean_bad(cfg, trlsacaux);              % eliminates egment that are bad according to the previos cleaning
            newtrl(find(newtrl(:,1)<preartiALL.sampleinfo(1)' | newtrl(:,2)>preartiALL.sampleinfo(2)' ),:)=[];
            cfgaux.trl     = newtrl;
            prearti        = ft_redefinetrial(cfgaux, preartiALL);
            sactodataratio = floor(50./cfg.spoverweight*floor(length(combdata.time{1})*length(combdata.trial)./(length(prearti.time{1})*length(prearti.trial))));
            for spn = 1:sactodataratio
                combdata.trial      = [combdata.trial prearti.trial];
                combdata.time       = [combdata.time prearti.time];
            end
        end
    end
    clear prearti
end

% ICA
cfg_ica.origtopolabel                   = combdata.label;
cfg_ica.topolabel                       = cfg_ica.origtopolabel;

datmat                              = cell2mat(combdata.trial);
clear combdata

    if ~isempty(cfg.elim_chan)                                           % in case channels are changed
        datmat(cfg.elim_chan,:) = [];
        cfg_ica.topolabel(cfg.elim_chan,:) = []; 
        cfg_ica.elim_chan = cfg.elim_chan;
    else
        cfg_ica.elim_chan = [];
    end

   if ~isdir([cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/images/']), mkdir([cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/images/']),end
cdir = pwd;
 cd(cfg.preprocanalysisfolder)
 % try to use amica otherwise we use runica
%  try
%     modres = runamica11(datmat,[cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/' cfg.filename],size(datmat,1),size(datmat,2),'max_iter',1000,'max_threads',8);
%     cfg_ica.mod                         = modres;
%     cfg_ica.topo                        = inv(modres.W * modres.S);
%     cfg_ica.type                        = 'amica';
%     use_runica = 0;
%  catch 
     use_runica = 1;
%  end
  cd(cdir)
    
 
 if use_runica 
    [cfg_ica.weights,cfg_ica.sphere]    = runica(datmat);
    cfg_ica.topo                        = inv(cfg_ica.weights * cfg_ica.sphere); 
    cfg_ica.type                        = 'runica';
 end  
 clear datmat   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg_ica.unmixing = pinv(cfg_ica.topo); %TODO: this need to be checked !!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % load('/net/store/nbp/EEG/CEM/analysis/ICAm/gs/gs04fv01_ICA.mat') % this
% is just for testing 

% chossing eye artifact component
    if strcmp(cfg.eyedata,'yes')
        for e = 1:length(varargin)              % loop through different datasets/sessions/blocks etc
            cfg                             = varargin{e}; 
            cfg                             = correct_channels(cfg); % if we need to change channels locations, this need to be included in the same function file
            load([cfg.eyeanalysisfolder cfg.filename 'eye'])                                % use weight from pre_exp in experiment data to define artifact components
            [ratio(:,e)]                    = comptoremove(cfg,cfg_ica,cfg.event,eyedata);
        end
        cfg_ica.ratio = mean(ratio,2);
        cfg_ica.comptoremove = find(cfg_ica.ratio>1.1);
    else
        cfg_ica.ratio           = [];
        cfg_ica.comptoremove    = [];
    end
    
% Getting components power spectra and chossing muscle types one
cfg_ica = icaspectra(cfg,cfg_ica);

for e = 1:length(varargin)
    cfg                             = varargin{e};
     save([cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'],'cfg_ica')
end

if use_runica==0
    rmdir([cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/' cfg.filename], 's')   % remove temporary directory for amica
end
%     
% ica figure
fh = plot_comp(cfg,cfg_ica,1:length(cfg_ica.topolabel));
fs = plot_comp_spectra(cfg,cfg_ica,1:length(cfg_ica.topolabel));
% fh
% [ax,h]                              =suplabel(['ICA components' cfg.EDFname],'t',[.075 .075 .9 .9]);
% set(h,'FontSize',20)
for e = 1:length(varargin)
    cfg                             = varargin{e};
    saveas(fh,[cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/images/' cfg.filename '_' cfg.clean_name],'fig')
    saveas(fs,[cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/images/' cfg.filename '_' cfg.clean_name '_pow'],'fig')
%      doimage(fh,[cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/images/'],'tiff',[cfg.filename],1)
end    
close(fh,fs)


% if strcmp(cfg.keepforotherexp,'yes')
%     if ~isdir(['/net/space/projects/EEG/ICApool/' cfg.expname])
%         mkdir(['/net/space/projects/EEG/ICApool/' cfg.expname '/'])
%     end
%     save(['/net/space/projects/EEG/ICApool/' cfg.expname '/' cfg.EDFname '_ICA.mat'],'cfg_ica')
% end
   
% save_log([datestr(now) '   ' cfg.EDFname ' ICA: ' num2str(it) ' iterations, done with ' num2str(length(elimined)) ' of ' num2str(length(trl)) 'possible trials'] ,[cfg.logfolder cfg.EDFname ,'.log'])
% save_log([datestr(now) '   Saving file ' cfg.preprocanalysisfolder 'ICA/' cfg.EDFname '_ICA.mat'] ,[cfg.logfolder cfg.EDFname ,'.log'])




