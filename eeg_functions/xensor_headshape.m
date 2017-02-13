function [headpoints] = xensor_headshape(files)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [headpoints] = xensor_headshape(files)
%
% Reads xensor electrode position file(s) to provide a matrix of nx3
% headpoints. Points that are likely to be measurement errors are elimined
%
% JPO, Osna, 20/07/2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read files
in = 1;
for e = 1:length(files)
    try
       [tp allelec(in)]= read_xensor(files{e},1,0);
       in = in+1;
    catch
        display([files{e} 'could not be read, skipping'])
    end
end


% normalize all electrodes and points to an average position between ears
% and nasion
 headpoints = [];
 for e=1:length(allelec)
     if ~isempty(allelec(e).points)
        headpoints = [headpoints;allelec(e).points];
         %          pointspos    = [pointspos,allelec(e).pointspos-repmat(center',1,size(allelec(e).pointspos,2))];
     end
 end