function [F,B,p] = dfa(data,p)

%  data         - data to analyze in matrix form win row channelsand column
%               samples
%                  
%  p.           - analysis parameter structure
%   .winrange   [low high], lower and higer analysis window size in
%               seconds
%   .nwin       # of logspaces windows to analyze within winrange
%   .sr         samplin rate of the data in Hz
%   .rangefit   [low high], lower and higer analysis window size in
%               seconds for linear fit, if empty == winrange

twin        = logspace(log10(p.winrange(1)),log10(p.winrange(2)),p.nwin);    % window sizes lineared spaced in log scale
p.winS      = round(twin*p.sf);                  % in number of samples, adjusted to sampling frequency

if isempty(p.rangefit)
    p.rangefit = p.winrange;
end
F = [];
for ch = 1:size(data,1)
    for tw = 1:length(p.winS)
        thiswin     = p.winS(tw);
        winStarts   = 1:floor(thiswin.*p.over):size(data,2);
        auxSD       = [];
        for ts = 1:length(winStarts)-round(1/p.over)-1
            thisData = data(ch,winStarts(ts):winStarts(ts)+thiswin-1);
            [~,~,thisData] = regress(thisData',[ones(length(thisData),1) [1:length(thisData)]']);
            auxSD(ts)   = rms(thisData);
        end
        F(ch,tw)  =mean(auxSD);
    end
    indxF = find(p.winS/p.sf>p.rangefit(1) & p.winS/p.sf<p.rangefit(2));
    B(:,ch) = regress(log10(F(ch,indxF))',[ones(length(F(ch,indxF)),1) log10(p.winS(indxF)/p.sf)']);

end