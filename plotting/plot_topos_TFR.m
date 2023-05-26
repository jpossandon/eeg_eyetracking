function fh = plot_topos_TFR(cfg,data,times,freqs,baseline,collim,name)

% load(cfg.chanfile)
% cfgp = [];
% cfgp.showlabels = 'no'; 
% cfgp.fontsize = 12; 
% cfgp.elec = elec;
% cfgp.elec.chanpos = elec.pnt;
% cfgp.rotate = 0;
% cfgp.interactive = 'yes';
% cfgp.baseline      = baseline;
% cfgp.baselinetype     = 'relative';
% cfgp.ylim = freqs;
% cfgp.zlim = collim;
% tiempos = times(1):times(3):times(2)-times(3);
% 
% fh = figure;
% set(gcf,'Position', [7 31 1428 770])
% numsp = 1;
% for t = tiempos
%      subplot(ceil(sqrt(length(tiempos))),ceil(sqrt(length(tiempos))),numsp)
%      cfgp.xlim=[t t+times(3)];
%      cfgp.comment = 'xlim'; 
%      cfgp.commentpos = 'title'; 
%      ft_topoplotTFR(cfgp, data); 
%      numsp = numsp +1;
% end

load(cfg.chanlocs)
  elimchanloc = [];
    for ch =1:length(chanlocs)
        if strmatch(chanlocs(1).labels(1),'E','exact') & strmatch(chanlocs(2).labels(1),'E','exact') % this is due to the problem with the labels of NBP lab
          if isempty(strmatch(chanlocs(ch).labels(2:end),data.label,'exact'))   %before labels(2:end) need to do a general fix for all types of channel info
            elimchanloc = [elimchanloc,ch];
          end
        else
            if isempty(strmatch(chanlocs(ch).labels(1:end),data.label,'exact'))   %before labels(2:end) need to do a general fix for all types of channel info
            elimchanloc = [elimchanloc,ch];
            end
        end
    end
    if ~isempty(elimchanloc), chanlocs(elimchanloc) = [];end            
    
%chanlocs = readlocs(cfg.chanloc,'filetype','custom',...
%        'format',{'channum','sph_phi_besa','sph_theta_besa','ignore'},'skiplines',0);
load('cmapjp','cmap')
if ~isempty(baseline)
data                                = rebsl(data,baseline);
end
fh = figure;
set(gcf,'Position', [7 31 1428 770])
numsp = 1;
tiempos = times(1):times(3):times(2)-times(3);
for t = tiempos
      subplot(ceil(sqrt(length(tiempos))),ceil(sqrt(length(tiempos))),numsp)
     indxsamples    = data.time>=t & data.time<t+times(3);
      indxfreq    = data.freq>=freqs(1) & data.freq<=freqs(2);
     topoplot(mean(mean(data.powspctrm(:,indxfreq,indxsamples),3),2),chanlocs,'emarker',{'.','k',5,1},'maplimits',collim,'colormap',cmap,'electrodes','off');
     title(sprintf('%2.2f < t < %2.2f',t,t+times(3)))
     numsp = numsp +1;
     if round(t*1000)==0
         text(-1,0,'t=0','FontWeight','demi','FontSize',14)
     end
end

axes('position',[.9 .2 .005 .6])
axis off
hc = colorbar;
set(hc,'Position',[0.9 0.2 0.01 0.6])
caxis(collim)

try
 [ax,h]=suplabel(sprintf('%s    n=%d   zlim = [%2.2f %2.2f]',name, size(data.cumtapcnt,1),collim(1),collim(2)),'t',[.075 .1 .85 .85])
catch
  [ax,h]=suplabel(sprintf('%s    n=%d   zlim = [%2.2f %2.2f]',name, size(data.powspctrm,1),collim(1),collim(2)),'t',[.075 .1 .85 .85])
end
 set(h,'FontSize',18)