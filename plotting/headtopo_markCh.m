function [fh,hp] = headtopo_markCh(chanlocs,markCh,sep)

%
% chanlocs = eeglab chanloc structure
% markCh   = cell of strings with channels to plot,e.g. {'O9','Cz'}
% sep      = separation of electrodes from scalp in % of radius, e.g. .1
% chanlocs = readlocs(chanlocfile,'filetype','custom',...
%         'format',{'labels','sph_theta_besa','sph_phi_besa'},'skiplines',1);
%       chanlocs = readlocs('/Users/jossando/trabajo/E283/07_Analysis/01_Channels/easycapM1E275.txt','filetype','custom',...
%         'format',{'channum','labels','sph_theta_besa','sph_phi_besa'},'skiplines',1);
headplot('setup',chanlocs,'splinefile');
fh=figure; 
hp = headplot(zeros(length(chanlocs),1),'splinefile','electrodes','off','electrodes3d','off','colormap',repmat([.7 .7 .7],64,1));
load('splinefile','-mat')
% markCh = {'PO9','O9'}'
chind = find(ismember({chanlocs.labels},markCh))
hold on
[TH,PHI,R] = cart2sph(newElect(:,1),newElect(:,2),newElect(:,3))
[X,Y,Z] = sph2cart(TH,PHI,R+R*sep);    
plot3(X(chind),Y(chind),Z(chind),'.k','MarkerSize',20)
