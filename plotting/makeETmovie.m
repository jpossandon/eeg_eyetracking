function [movieFileName proc_times rawFrames] = makeETmovie(data, outputFileBaseName, showAbsoluteEEG)

stimulusImage = data.stimulusImage;
etData = data.et;
eegData = data.eeg;
electrodes = data.electrodes;

%display of 1600x1200 picture in center of 2560x1600 monitor
%DEF_X_CORRECTION=480;
%DEF_Y_CORRECTION=200;
% 
% displayResX=2560;
% displayResY=1600;
% 
 picResY = size(stimulusImage,1);
 picResX = size(stimulusImage,2);
% xCorrection=(displayResX/2)-(picResX/2);
% yCorrection=(displayResY/2)-(picResY/2);

xCorrection=0;
yCorrection=0;

DEF_FRAME_RATE=500;
DEF_OUTPUTFILEBASENAME='etMovie';
DEF_SHOWABSOLUTE=false;

if ~exist('frameRate','var'); frameRate = DEF_FRAME_RATE; end
if ~exist('outputFileBaseName','var'); outputFileBaseName = DEF_OUTPUTFILEBASENAME; end
if ~exist('showAbsoluteEEG', 'var'); showAbsoluteEEG = DEF_SHOWABSOLUTE; end

%EEG plotting parameters
windowSize=.02; %seconds

timeTextColor = 'yellow';
backgroundColor = [0.7 0.7 0.7];

cfg = [];
cfg.colorbar    ='false';
cfg.showlabels  ='no';
cfg.elec = electrodes;
cfg.xparam = 'time';
cfg.electrodes = 'on';
cfg.verbose = 'off';
cfg.hcolor = 'k';

% cfg.baseline   = [-.1 0];
% cfg.zlim = [-.5 .9]

h=figure;
hEEGAxes = subplot(2,6,12);
cfg.xlim = [eegData.time(1) eegData.time(1)+windowSize];
cfg.comment = 'auto';
topoplotER(cfg, eegData);
cmapEEG = colormap(hEEGAxes);
cl2 = get(hEEGAxes,'CLim');

if (exist('showAbsoluteEEG', 'var') && showAbsoluteEEG);
    hEEG2Axes = subplot(2,6,6);
    cfg.xlim = [eegData.time(1) eegData.time(1)+windowSize];
    cfg.comment = 'no';
    topoplotER(cfg, eegData);
    cmapEEG2 = colormap(hEEG2Axes);
    if (sum(cmapEEG2 ~= cmapEEG))
        fprintf('--------\nWARNING: EEG Colormaps differ!\n-------------\n');
    end
end

hStimulusAxes = subplot(2,6,[1 2 3 4 5 7 8 9 10 11]);
hStimulusImage = imshow(stimulusImage);
set(hStimulusImage,'HandleVisibility','off');
cmapStimulus = colormap(hStimulusAxes);
cl1  = get(hStimulusAxes,'CLim');		   % CLim values for each axis
hold on

cmap = [cmapStimulus; cmapEEG];

scmapsz = size(cmapStimulus);
eegcmapsz = size(cmapEEG);

fprintf('Colormap sizes: stimulus: %dx%d; eeg: %dx%d\n', ...
    scmapsz(1),scmapsz(2),eegcmapsz(1),eegcmapsz(2));

colormap(cmap);

if (exist('showAbsoluteEEG', 'var') && showAbsoluteEEG);
    fprintf('Determining absolute CLims of EEG data...');
    eegAbsoluteCLim = determineCLims(eegData.avg);
    fprintf('success.\n');
    
    fprintf('Clamping EEG Data to CLims...');
%     eegDataAbs = max(min(eegData,eegAbsoluteCLim(1)),eegAbsoluteCLim(2));
end

CmLength   = length(colormap);	   % Colormap length
BeginSlot1 = 1;					   % Beginning slot
EndSlot1   = length(cmapStimulus); 	% Ending slot
BeginSlot2 = EndSlot1+1; 
EndSlot2   = CmLength;

climStimulus = newclim(BeginSlot1,EndSlot1,cl1(1),cl1(2),CmLength);
climEEG = newclim(BeginSlot2,EndSlot2,cl2(1),cl2(2),CmLength);
if (exist('showAbsoluteEEG', 'var') && showAbsoluteEEG);
    climEEG2 = newclim(BeginSlot2,EndSlot2,eegAbsoluteCLim(1),eegAbsoluteCLim(2),CmLength);
end

set(hStimulusAxes,'CLim',climStimulus);
set(hEEGAxes,'CLim', climEEG);
if (exist('showAbsoluteEEG', 'var') && showAbsoluteEEG);
    set(hEEG2Axes,'CLim', climEEG2);
end

set(hStimulusAxes,'Units','pixels');
set(hEEGAxes,'Units','pixels');

picWidth=floor(picResX/2);
picHeight=floor(picResY/2);
eegWidth=200;
eegHeight=200;
set(h,'Position',[100 100 picWidth+eegWidth picHeight],'Color',backgroundColor);
set(hStimulusAxes,'Position',[0 0 picWidth picHeight]);
set(hEEGAxes,'Position',[picWidth+5 20 eegWidth eegHeight]);
    
if (exist('showAbsoluteEEG', 'var') && showAbsoluteEEG);
    set(hEEG2Axes,'Units','pixels');
    set(hEEG2Axes,'Position',[picWidth+5 eegHeight+20+160 eegWidth eegHeight]);
end

downSampling = data.etSampleRate/data.eegSampleRate;

numPoints = size(etData.time,2);
numFrames = floor(numPoints/downSampling);

tic;
firstFrame = getframe(h);
rawFrames = repmat(firstFrame,1,numFrames); % preallocate the movie
proc_times=zeros(3,numFrames);
t=toc;
fprintf('Preallocated rawFrames in %4.2f seconds.\n', t);

for j = 1:numPoints;
    frameNum = ceil(j/downSampling);
    tic;
    set(h,'CurrentAxes',hStimulusAxes);
    cla;
    proc_times(1,j)=toc;
    hCurrentDot = plot(hStimulusAxes,etData.x(j)-xCorrection, etData.y(j)-yCorrection,'.b','MarkerSize',10);
    set(hCurrentDot,'HandleVisibility','off');
    plot(hStimulusAxes,etData.x(j)-xCorrection, etData.y(j)-yCorrection,'or','MarkerSize',20);
    
    if (mod(j,downSampling) == 1);
        text(picResX+170, eegHeight*3, sprintf('Time: %d', etData.time(j)), 'BackgroundColor',timeTextColor);

        set(h,'CurrentAxes',hEEGAxes);
        cfg.xlim = [eegData.time(frameNum) eegData.time(frameNum)+windowSize];
        cfg.comment = 'auto';
        topoplotER(cfg, eegData);
        cl2 = get(hEEGAxes,'CLim');
        climEEG = newclim(BeginSlot2,EndSlot2,cl2(1),cl2(2),CmLength);
        set(hEEGAxes,'CLim', climEEG);

        if (exist('showAbsoluteEEG', 'var') && showAbsoluteEEG);
            set(h,'CurrentAxes',hEEG2Axes);
            cfg.comment = 'no';
            topoplotER(cfg, eegData);
            set(hEEG2Axes,'CLim', climEEG2);
        end
    end
        
    proc_times(2,j)=toc;
    
    if (mod(j,downSampling) == 1);
        rawFrames(frameNum) = getframe(h);
    end
    proc_times(3,j)=toc;
    if mod(j,10) == 0
        proc_time_sum = sum(proc_times,2);
        fprintf('frame %d/%d: %.3f secs (%.2f|%.2f|%.2f)\n', frameNum, numFrames, ...
            proc_time_sum(3), proc_time_sum(1), ...
            proc_time_sum(2)-proc_time_sum(1), ...
            proc_time_sum(3)-(proc_time_sum(1)+proc_time_sum(2)));
    end
end

%close all
%close hidden

proc_time_sum = sum(proc_times,2);
fprintf('Finished producing rawFrames: %.3f secs\n', proc_time_sum(3));
fprintf(' -> clearing axes: %.2f secs; plotting data: %.2f secs; getframe(): %.2f secs\n', proc_time_sum(1), proc_time_sum(2)-proc_time_sum(1), proc_time_sum(3)-(proc_time_sum(1)+proc_time_sum(2)));

fps = frameRate;

movieExt = '.uncompressed.avi';

fileCounter=0;

while exist(sprintf('%s.%d%s', outputFileBaseName, fileCounter, movieExt), 'file')
    fileCounter = fileCounter + 1;
end

movieFileName = sprintf('%s.%d%s', outputFileBaseName, fileCounter, movieExt);
fprintf('Creating %s from rawFrames...\n', movieFileName);
tic;
movie2avi(rawFrames,movieFileName,'compression','none','fps',fps,'quality',100)
t=toc;

fprintf('File %s created in %4.1f seconds\n',movieFileName,t);