function trial2movie(cfg,trialNum,dur,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function trial2movie(cfg,trialNum,dur)
%
%    input
%           cfg         - parameters structure obtained with eeg_etParams 
%           trialNum    - number of the trial for makin the movie
%           dur         - duration of the video
%           optional 
%               'ica'   - ICA components to remove from the data, the default
%                           is the components contained in the file
%                           [cfg.analysisfolder 'ICA/' cfg.EDFname '_ICA.mat']
%                           which removes only components associated to eye
%                           movements. Use as
%                           trial2movie(...,'ica',[components_to_remove])
%
% RM ,AM & JPO - OSNA 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
comptoremove = [];
for nv = 1:2:length(varargin)                                           % redefintion of eeg_etParams
    if strcmp(varargin{nv},'ica')
        comptoremove = varargin{nv+1}; 
    end
end
% cfg.analysisname = 'preanalysis';
cfg.sujid        = cfg.sujid;

load([cfg.eyeanalysisfolder cfg.EDFname 'eye'])
[trl]               = define_event(cfg,eyedata,'ETtrigger',{'value','>0'},cfg.trial_time);
% load([cfg.analysisfolder cfg.analysisname '/' cfg.EDFname '_expgen_epoch2reject.mat'],'toelim')

toelim=[];
if find(toelim==trialNum)
    sprintf('Skipping trial %d',trialNum)
else
    
    numEEGEventsToSkip = 1; %EEG Data contains events at the beginning that do not correspond to any eyetracking data. So, they must be skipped. This is usually 1 or 2.

    maxTimeToPlot = 10000; %milliseconds
    data.etSampleRate = 500; %Hz - this must match the et data
    data.eegSampleRate = 250; %Hz - this will be used to downsample the eeg data
    channelLocationFileName = '/net/space/projects/eeg_et/channel_loc';

    imageDir = cfg.stimulifolder ;

    fprintf('Beginning load of data for trial %d Subject %s \n', ...
        trialNum,cfg.sujid);

    if sum(strcmp(eyedata.marks.type,'image'))
        indxim  = find(strcmp(eyedata.marks.type,'image'));
%         [status,imageFileName] = system(sprintf('ls %s%01d.*',cfg.stimulifolder,eyedata.marks.value(indxim(trialNum))));
       [status,imageFileName] = system(sprintf('ls %simage_%03d.*',cfg.stimulifolder,eyedata.marks.value(indxim(trialNum))));
    else
        error('No image field in eyedata file')
    end
    data.stimulusImageFileName = imageFileName;

    fprintf('Loading Stimulus Image file from "%s"...', imageFileName);
    data.stimulusImage = imread(imageFileName(1:end-1));
    fprintf('success.\n');

    fprintf('Loading channel location data from "%s"...', channelLocationFileName);
    load(channelLocationFileName, 'elec');
    data.electrodes = elec;
    fprintf('success.\n');

    fprintf('Extracting Eyetracking data for stimulus duration...');
%ignore data before stimulus onset

    [trl] = define_event(cfg,eyedata,'ETtrigger',{'value','>0';'trial',['==' num2str(trialNum)]},[100 dur]);

    startIndex=find(eyedata.samples.time==trl(1));
    endIndex=find(eyedata.samples.time==trl(2));
    if isempty(startIndex) | isempty(endIndex)
        startIndex=find(eyedata.samples.time==trl(1)+1);
        endIndex=find(eyedata.samples.time==trl(2)+1);
        trl = trl+1;;
    end
    
    data.et.time=eyedata.samples.time(startIndex:endIndex);
    data.et.x=eyedata.samples.pos(1,startIndex:endIndex);
    data.et.y=eyedata.samples.pos(2,startIndex:endIndex);

    numETDataPoints = size(data.et.time,2);
    totalTrialTimeMs = data.et.time(end)-data.et.time(1);
    data.trialTime = totalTrialTimeMs;
    fprintf('success:\n\t->start=%d; end=%d; number of data points=%d; total time=%dmsecs.\n', ...
        startIndex, endIndex, numETDataPoints, totalTrialTimeMs);

    cfge = basic_preproc_cfg(cfg,cfg.event,'bpfilter',[.5 30],'blc','yes');
    cfge.trl = double(trl);

    data.eeg = preprocessing(cfge);
     load([cfg.analysisfolder 'ICA/' cfg.EDFname '_ICA.mat'],'cfg_ica')
%      load([cfg.analysisfolder, cfg.analysisname, '/ICA/' cfg.EDFname '_ICA.mat'],'cfg_ica')
   
    if ~isempty(comptoremove)
        cfg_ica.comptoremove = comptoremove;
    end
    [data.eeg]= ICAremove(data.eeg,cfg_ica,cfg_ica.comptoremove,1:64,[],[])
   
    cfgre.resamplefs = data.eegSampleRate;
    cfgre.detrend    = 'no';
    fprintf('Resampling EEG Data to %d fps...', cfgre.resamplefs);
    data.eeg = resampledata(cfgre, data.eeg);
    fprintf('success.\n');
    fprintf('Performing timelockanalysis (averaging) of EEG Data...');
    data.eeg = timelockanalysis([],data.eeg);
    fprintf('success.\n');
    fprintf('EEG Data loaded, with %d samples.\n', size(data.eeg.time, 2));
    fprintf('---do_load finished---\n');

    [movieFileName proc_times rawFrames] = makeETmovie(data,sprintf('%sSuj_%s_Trial_%d',[cfg.analysisfolder 'movies/'],cfg.sujid,trialNum), true)
    
    
    compAlgorithm = 'lavc';
    uncompressedExt = '.uncompressed.avi';
    compMovieFileName = sprintf('%s.%s.avi', ...
        movieFileName(1:end-length(uncompressedExt)), ...
        compAlgorithm);

    cmdStr = sprintf('mencoder -really-quiet %s -o %s -ovc %s', ...
        movieFileName, compMovieFileName, compAlgorithm);
    fprintf('compressing movie with mencoder, algorithm %s...\n', compAlgorithm);
    fprintf('->"%s"\n', cmdStr);

    tic;
    [retVal consoleOut] = system(cmdStr);
    tEncode=toc;
    if (retVal == 0);
        fprintf('success. ');
        fprintf('compression took %f seconds\n', tEncode);
    else
        fprintf('failure: retVal=%d. ', retVal);
    end
    clear movieFileName
    close all
    
    
    
    
end
