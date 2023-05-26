function [Values,reconst] = gaussdecomp(Acomp,t,Awave,MinPeakProminence,MinPeakHeight,plotit)

gaus = @(x,mu,sig,amp)amp*exp(-(((x-mu).^2)/(2*sig.^2)));

if isempty(t)
    t = 1:length(Acomp);
end
% Acomp = alphaHn(:,2);
% Awave = alphaCn(2,:);

tt = [nan(1,600) t nan(1,600)];
Acomp = [nan(1,600) Acomp' nan(1,600)];
reconst = zeros(1,length(Acomp));
if plotit
    figure,hold on
    plot(tt,Acomp)
end
pks         = 1;
newAcomp    = Acomp;
aa          = 1;
Values      = [];
while 1
    % find peaks a least 1SD from background
    [pks,locs,widths,proms] = findpeaks(newAcomp,'SortStr','descend','MinPeakProminence',MinPeakProminence,'MinPeakHeight',MinPeakHeight);
    if isempty(pks)
        break
    end
    
    if locs(1)-2*round(widths(1))>0 & locs(1)+2*round(widths(1))<length(newAcomp)
        aboveFWHM       = newAcomp(locs(1)-2*round(widths(1)):locs(1)+2*round(widths(1)))>pks(1)-proms(1)/2;
    elseif locs(1)-2*round(widths(1))<0 
        aboveFWHM       = newAcomp(1:locs(1)+2*round(widths(1)))>pks(1)-proms(1)/2;
    elseif locs(1)+2*round(widths(1))>length(newAcomp)
       aboveFWHM       = newAcomp(locs(1)-2*round(widths(1)):end)>pks(1)-proms(1)/2;
    end
    if sum(aboveFWHM==0)>0
    ixDiff          = 2*round(widths(1))-find(diff(aboveFWHM));
    else
        %%%
        %
    end
    [shortFWHM I]   = min(abs(ixDiff));
    ssF             = sign(ixDiff(I));
    sdPeak          = 2*shortFWHM/(2*sqrt(2*log(2)));
    xx = locs(1)-round(3*sdPeak):locs(1)+round(3*sdPeak);
    % y = gaus(xx,locs(1),sdPeak,double(proms(1)));
    y = gaus(xx,locs(1),sdPeak,newAcomp(locs(1)));  % calculatd peak gaussian
    Values(aa,:) = [tt(locs(1)),newAcomp(locs(1)),sdPeak];%1.96*2*sdPeak.*1000/ICAcomp.srate];
    
    newAcomp(xx) = newAcomp(xx)-y;
    reconst(xx) = reconst(xx)+y;
    aa = aa+1;
    if plotit
        plot(tt(locs(1)),Acomp(locs(1)),'.r')  % plot red dot in found peak in original envelope
        %surrounding point above hal maximum, this si to find the closest border
        %and derive the sd according to 2*this distance to the peak
        plot(tt(locs(1)-ssF.*shortFWHM),Acomp(locs(1)-ssF.*shortFWHM),'.g') % plot a green dot in the closer border at FWHM
        plot (tt(xx),y,'r')
    end
    
end
if plotit
    hold on, plot(t,Awave)
    
    figure,hold on
    plot(tt,Acomp)
    plot(tt,reconst,'k')
end
reconst = reconst(601:end-600);
% figure,plot(Values(:,2),Values(:,3),'.')

% [r,p]=corr(Acomp(601:end-600)',reconst(601:end-600)')