function [TFRall,toelim,TFR] = getTFRsfromtrl(cfgs,trls,bsl,reref,tipo,keep,cfgTFR)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [ERPall,ERP] = getTFsfromtrl(cfgs,trls,bsl,tipo,keep)
%
%    Input
%         cfgs  - in the form {cfg1,cfg2,...,cfgn}, including for example 
%                   different sessions of different subject or the same subject, original fieldtrip cfg
%                   structure (contain information for removing bad trials)
%         trl   - in the form {trl1,trl2,...,trln},actual trials to cut 
%         bsl   - baseline correction window in the form [starttime,endtime]
%         tipo  - kind of output data, it can be plain, average referenced,
%                   ICA corrected for eye movements artifact or ICA
%                   components
%         keep  - 'yes' or 'no', if preserving or not trials after
%                   averaging, relevant wheter the data is for plotting ('no') or for
%                   stats ('yes')
%
%    output 
%         ERPall - when analyis involves more than one session includes al trials in the same ERP analysis
%         ERP    - separate ERP analysis for diferent session
%
% JPO, OSNA 13.09.11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cfgTFR  = [];
cfgr    = [];
for e = 1:length(trls)
    cfg                                 = cfgs{e};
    cfg                                 = correct_channels(cfg);
    [trl toel]                          = clean_bad(cfg, trls{e});
    toelim{e}                           = toel;   
        
   if ~isempty(strfind(tipo,'ICA'))                 % we cut differently the data depending if we are going to clean the data with ICA or not. Currently, I am doing ICA with mean corrected epochs (alternatively could be done with HP filter above .5 hz), and after ICA rebaseline to the required bsl. There is no clear procedure here but this works well
        cfge            = basic_preproc_cfg(cfg, cfg.event,'lpfilter','yes','lpfreq',120,'demean','yes');
    else
        cfge            = basic_preproc_cfg(cfg, cfg.event,'lpfilter','yes','lpfreq',40);
    end
    cfge.trl                            = double(trl);
    data                                = ft_preprocessing(cfge);                                      % correct saccades to the left valid trials 
    
    if ~isempty(cfg.correct_chan)                                           % in case channels are changed
        for ip=1:length(data.trial)
            data.trial{ip}  = data.trial{ip}(cfg.correct_chan,:);
        end
    end
    if ~isempty(cfg.elim_chan)                                              % in case channels are removed
        origdatalabel                       = data.label; 
        data.label(cfg.elim_chan)           = [];
        dataaux                             = cell2mat(data.trial);
        dataaux(cfg.elim_chan,:)            = [];
        data.trial                          = mat2cell(dataaux,length(data.label),size(data.trial{1},2)*ones(1,length(data.trial)));  
        clear dataaux
    end
    
     if ~isempty(strfind(tipo,'ICA'))
         load([cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'],'cfg_ica') % ica weights
        if strcmp(tipo,'ICAem')
            data                            = ICAremove(data,cfg_ica,unique([cfg_ica.comptoremove;cfg_ica.comptoremove_m]),cfg_ica.topolabel,1:length(cfg_ica.topolabel),1:length(cfg_ica.topolabel));               % removing of eye and muscleartifact ICA components
        elseif strcmp(tipo,'ICAm')
            data                            = ICAremove(data,cfg_ica,cfg_ica.comptoremove_m,cfg_ica.topolabel,1:length(cfg_ica.topolabel),1:length(cfg_ica.topolabel));               % removing of eye artifact ICA components
        elseif strcmp(tipo,'ICAe')
            data                            = ICAremove(data,cfg_ica,cfg_ica.comptoremove,cfg_ica.topolabel,1:length(cfg_ica.topolabel),1:length(cfg_ica.topolabel));               % removing of eye artifact ICA components
        end
%         data                                = rebsl(data,bsl);          %apply required baseline
    end

   if ~isempty(cfg.elim_chan)    
         enen                                           = size(data.trial{1},2);
         dataaux                                        = cell2mat(data.trial);
         replacedata                                    = nan(length(origdatalabel),size(dataaux,2));
%         replacedata(cellfun(@str2num,data.label),:)    = dataaux ;
         replacedata(ismember(origdatalabel,data.label),:) = dataaux;
         data.trial                                     = mat2cell(replacedata,length(origdatalabel),enen*ones(1,length(data.trial)));
         data.label                                     = origdatalabel;
         clear dataaux replacedata
         cfgrepair.badchannel                           = data.label(cfg.elim_chan);
%          cfgrepair.neighbourdist                        = 5.5; % this is important and depend on cap size and it matters for validity of result, fieldtrip default of 4 cms is to little for the 64 channels spetial coverage caps we have
         cfgrepair.method                               = 'distance';
         load(cfg.chanfile)
         data.elec                                      = elec;
         cfgrepair.elec                                      = elec;
%          cfgrepair.elec.elecpos                                     = elec.pnt;
%          cfgrepair.neighbours                           = ft_prepare_neighbours(cfgrepair);
         cfgrepair.neighbours                           = elec.neighbours;         
         cfgrepair.method                               = 'nearest';
         [data]                                         = ft_channelrepair(cfgrepair, data);
    end
%     cfgTFR.keeptrials               =keep;
%     
%     cfgTFR.channel    = 'all';	                
%     cfgTFR.method     = 'wavelet';                
%     cfgTFR.width      = 3; 
%     cfgTFR.output     = 'pow';	
%     cfgTFR.foi        = 1:3:90;	                
%     cfgTFR.toi        = data.time{1}(1):0.02:data.time{1}(end);		              

    if nargout>2
        
        if strcmp(tipo,'comp')
            load([cfg.preprocanalysisfolder 'ICAm/' cfg.sujid '/' cfg.filename '_ICA.mat'],'cfg_ica') % ica weights
            data                       = ft_componentanalysis(cfg_ica, data);
            for tr=1:length(data.trial)
                data.trial{tr} = repmat(sign(cfg.comptoanal),1,size(data.trial{1},2)).*data.trial{tr}(abs(cfg.comptoanal),:);
            end
            data.topo                  = data.topo(:,abs(cfg.comptoanal));
            data.label                 = data.label(1:length(cfg.comptoanal));
            data.topolabel             = data.topolabel(1:length(cfg.comptoanal));
%             ERP(e).comp                = ft_timelockanalysis(cfgerp, data);              % ICA components ERP
        end
        if strcmp(reref,'yes') %&& ~isempty(strfind(tipo,'ICA'))
            data                        = reref_prepro(cfgr, data);                         
        end
        data                            = rebsl(data,bsl);
        TRF(e).(tipo)                   = ft_freqanalysis(cfgTFR, data);    
    end
    if e == 1
        data_all                        = data;
    else
        data_all                        = ft_appenddata([],data_all,data) ;
    end
    clear data
end
 
    
if  strcmp(reref,'yes')
    data_all                            = reref_prepro(cfgr, data_all);
end
data_all                                = rebsl(data_all,bsl);
TFRall.(tipo)                           = ft_freqanalysis(cfgTFR, data_all);
cfgTFR.output        = 'pow';
auxTFR = ft_freqanalysis(cfgTFR,ft_timelockanalysis([],data_all));
TFRall.(tipo).erppow                    = auxTFR.powspctrm;