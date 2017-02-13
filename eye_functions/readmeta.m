function [eyes] = readmeta(meta,totalnumtrials)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [] = readmeta(meta)
% read meta data from eyetracker data obtained with edfread
% Output:
%       eyes
%           .sindx          = SUBJECTINDEX
%           .trialsxcalib   = number of trials for each calibration
%           .Lerr_avg       = vector with error averages for each calibration for
%                               left eye (.Rerr_avg for Right eye if available) 
%           .Lerr_mac       = idem for max error(.Rerr_mac for Right eye if
%                               available) 
%           .besteye        = vector with the eye (0 - left 1 - right) with best
%                               calibration for each trial
%           .eyenums        = vector with number of eyes tracked for each
%                               trial
%           .Lerrorsmean    = mean value of Lerr_avg and Lerr_max
%                               (.Rerrorsmean for Right eye eye if
%                               available) 
%
% JPO 8/7/08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
eyes.sindx = str2num(meta.SUBJECTINDEX);
catch
    display('No Subjectindex')
end
remeta = [meta.calib];
aux = find([remeta.trial]==0);
tnums = [remeta.trial,totalnumtrials];
if aux>1
    firstcalib = aux(end);
    tnums = tnums(aux(end):end);
else
    firstcalib = 1;
end
eyes.trialsxcalib = diff(tnums);

eyes.Lerr_avg = [];eyes.Rerr_avg = [];
eyes.Lerr_max = [];eyes.Rerr_max = [];
eyes.besteye = [];
eyes.eyenums = [];

metaright = struct('err_avg',cell(1,length(remeta)),'err_max',cell(1,length(remeta)),...
    'off_deg',cell(1,length(remeta)),'off_x',cell(1,length(remeta)),'off_y',cell(1,length(remeta)),...
    'res_x',cell(1,length(remeta)),'res_y',cell(1,length(remeta)),'type',cell(1,length(remeta)),'coeff',cell(1,length(remeta)));
metaleft = metaright;

for e = 1:length(remeta)
    if isstruct(remeta(e).left)
        metaleft(e) = remeta(e).left;
        eyes.Lerr_avg = [eyes.Lerr_avg,metaleft(e).err_avg];
        eyes.Lerr_max = [eyes.Lerr_max,metaleft(e).err_max];
        
        fl = 0;
    else
       eyes.Lerr_avg = [eyes.Lerr_avg,NaN];
       eyes.Lerr_max = [eyes.Lerr_max,NaN];
    end
    if isstruct(remeta(e).right)
        metaright(e) = remeta(e).right;
        eyes.Rerr_avg = [eyes.Rerr_avg,metaright(e).err_avg];
        eyes.Rerr_max = [eyes.Rerr_max,metaright(e).err_max];
        fl = 1;
    else
        eyes.Rerr_avg = [eyes.Rerr_avg,NaN];
        eyes.Rerr_max = [eyes.Rerr_max,NaN];
    end
    if isstruct(remeta(e).left) & isstruct(remeta(e).right)
        eyes.eyenums = [eyes.eyenums,2];
        if eyes.Lerr_avg(e) <= eyes.Rerr_avg(e)
           eyes.besteye = [eyes.besteye,1];
        else
           eyes.besteye = [eyes.besteye,2];
        end
    else
        eyes.eyenums = [eyes.eyenums,1];
        if isstruct(remeta(e).left)
           eyes.besteye = [eyes.besteye,1];
        elseif isstruct(remeta(e).right)
           eyes.besteye = [eyes.besteye,2];
        end
    end
end

eyes.Lerrorsmeans = [nanmean(eyes.Lerr_avg) nanmean(eyes.Lerr_max)];
eyes.Rerrorsmeans = [nanmean(eyes.Rerr_avg) nanmean(eyes.Rerr_max)];

