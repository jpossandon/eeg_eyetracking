function fh = plot_topos(cfg,data,times,baseline,collim,name,makefig)

% load(cfg.chanfile)
% cfgp = [];
% cfgp.showlabels = 'no'; 
% cfgp.fontsize = 12; 
% cfgp.elec = elec;
% cfgp.rotate = 0;
% cfgp.interactive = 'yes';
% cfgp.baseline      = baseline;
% cfg.highlight          =  'numbers';
% cfgp.zlim = collim;
% tiempos = times(1):times(3):times(2)-times(3);
% 
% figure
% set(gcf,'Position', [7 31 1428 770])
% numsp = 1;
% for t = tiempos
%      subplot(ceil(sqrt(length(tiempos))),ceil(sqrt(length(tiempos))),numsp)
%      cfgp.xlim=[t t+times(3)];
%      cfgp.comment = 'xlim'; 
%      cfgp.commentpos = 'title'; 
%      ft_topoplotER(cfgp, data); 
%      numsp = numsp +1;
%      if t==0
%          text(-1,0,'t=0','FontWeight','demi','FontSize',14)
%      end
% % end
%  [ax,h]=suplabel(sprintf('%s n=%d',name, data.dof(1)),'t',[.075 .1 .85 .85])
%   set(h,'FontSize',18)
%  figure, ft_multiplotER(cfgp,data)


% 
% 
%    chanlocs = readlocs(cfg.chanloc,'filetype','custom',...
%           'format',{'channum','sph_phi_besa','sph_theta_besa','ignore'},'skiplines',0);
load(cfg.chanlocs)
%   elimchanloc = [];
%     for ch =1:length(chanlocs)
%         if isempty(strmatch(chanlocs(ch).labels(2:end),data.label,'exact'))   %before labels(2:end) need to do a general fix for all types of channel info
%             elimchanloc = [elimchanloc,ch];
%         end
%     end
%     if ~isempty(elimchanloc), chanlocs(elimchanloc) = [];end            
    
    load('cmapjp','cmap')
 if ~isempty(baseline)
%     if ~iscell(data.time)
%         data.time = {data.time};
%     end
    data                                = rebsl(data,baseline);
 end
if makefig
    fh = figure;
    set(gcf,'Position', [7 31 1428 770])
end
numsp = 1;
tiempos = times(1):times(3):times(2)-times(3);
for t = tiempos
%      subplot(ceil(sqrt(length(tiempos))),ceil(sqrt(length(tiempos))),numsp)
    if makefig
        subplot(ceil(length(tiempos)/ceil(sqrt(length(tiempos)))),ceil(sqrt(length(tiempos))),numsp)
    end
        indxsamples    = data.time>=t & data.time<t+times(3);
     
     topoplot(mean(data.avg(:,indxsamples),2),chanlocs,'emarker',{'.','k',5,1},'maplimits',collim,'colormap',cmap,'electrodes','off');
      if makefig
     title(sprintf('%2.3f < t < %2.3f',t,t+times(3)))
      end
     numsp = numsp +1;
     if makefig
         if round(t*1000)==0
             text(-1,0,'t=0','FontWeight','demi','FontSize',14)
         end
     end
end
if makefig
    axes('position',[.9 .2 .005 .6])
    axis off
    hc = colorbar;
    set(hc,'Position',[0.92 0.2 0.01 0.6])
    caxis(collim)
    if isfield(data,'dof')
      [ax,h]=suplabel(sprintf('%s  n=%d',name, data.dof(1)),'t',[.075 .1 .9 .87]);
    else
      [ax,h]=suplabel(sprintf('%s',name),'t',[.075 .1 .9 .87]);  
    end
   set(h,'FontSize',18)
end