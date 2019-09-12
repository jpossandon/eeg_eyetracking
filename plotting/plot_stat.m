function fh = plot_stat(cfgp,stat,data1,data2,times,zlim,alpha,name,makefig)

% alpha works for a two-tailed test if the statistics was done with
% cfg.correcttail = 'prob'
if ~isempty(data1) & ~isempty(data2)
    cfg= [];
    cfg.keepindividual = 'no';
    % if isfield(data1,'dimord')
    %     if strmatch('subj',data1.dimord)
    %         data1TL = timelockgrandaverage(cfg,data1);
    %         data2TL = timelockgrandaverage(cfg,data2);
    %     else
    %         data1TL     = timelockanalysis(cfg, data1);
    %         data2TL     = timelockanalysis(cfg, data2);
    %     end
    % else
    data1TL             = timelockanalysis(cfg, data1);
    data2TL             = timelockanalysis(cfg, data2);
    % end
    data1vsdata2        = data1TL;
    data1vsdata2.avg    = data1TL.avg-data2TL.avg;
else
    data1vsdata2 = data1;
    cfg= [];
end
if isfield(stat,'posclusterslabelmat')
    pos = zeros(size(stat.posclusterslabelmat)); 
else 
    pos = [];
end
if isfield(stat,'negclusterslabelmat')
    neg = zeros(size(stat.negclusterslabelmat)); 
    else 
    neg = [];
end
if isfield(stat,'posclusterslabelmat')
    if ndims(stat.posclusterslabelmat)>2
        strprob = 'prob';
    else
        strprob = 'prob_abs';
    end
end
if isfield(stat,'posclusters')
    if ~isempty(stat.posclusters)
        for e = 1:length(stat.posclusters)
            if stat.posclusters(e).(strprob) < alpha
                pos = pos + (stat.posclusterslabelmat==e);
            end
        end
    end
end

if isfield(stat,'negclusters')
    if ~isempty(stat.negclusters)
        for e = 1:length(stat.negclusters)
            if stat.negclusters(e).(strprob) < alpha
                neg = neg + (stat.negclusterslabelmat==e);
            end
        end
    end
end


if isfield(stat,'posclusterslabelmat')
    if ndims(stat.posclusterslabelmat)>2
        auxF = stat.freq>stat.freqstoplot(1) & stat.freq<stat.freqstoplot(2);
        pos  = squeeze(any(pos(:,auxF,:),2));
        neg  = squeeze(any(neg(:,auxF,:),2));
    end
end
neg     = neg*(-1);
if isfield(stat,'time')
    datatime = stat.time;
else
    datatime = data1vsdata2.time;
end
% segms   = (stat.time(end)-stat.time(1))/times(3);
% t = stat.time;
 load(cfgp.chanlocs)
% elimchanloc = [];
%     for ch =1:length(chanlocs)
%         if isempty(strmatch(chanlocs(ch).labels(1:end),data.label,'exact'))   %before labels(2:end) need to do a general fix for all types of channel info
%             elimchanloc = [elimchanloc,ch];
%         end
%     end
%     if ~isempty(elimchanloc), chanlocs(elimchanloc) = [];end            
%  
% chanlocs = readlocs(cfgp.chanloc,'filetype','custom',...
%          'format',{'channum','sph_phi_besa','sph_theta_besa','ignore'},'skiplines',0);
load('cmapjp','cmap') 
% cmap = cmocean('curl');
% data                                = rebsl(data,baseline);
if makefig
    fh = figure;
    set(gcf,'Position', [7 31 1428 770])
end
numsp = 1;
tiempos = floor(times(1)*1000):round(times(3)*1000):round(times(2)*1000-times(3)*1000);
tiempos = tiempos/1000;
for t = tiempos
    if makefig
        subplot(ceil(sqrt(length(tiempos))),ceil(sqrt(length(tiempos))),numsp)
    end
      if sum(pos(:))~=0
        pos_int = mean(pos(:,find(datatime>=t,1):find(datatime>=t+times(3),1))'); 
      end
      if sum(neg(:))~=0
        neg_int = mean(neg(:,find(datatime>=t,1):find(datatime>=t+times(3),1))');
      end
     if sum(pos(:))~=0 & sum(neg(:))~=0
        cfg.highlightchannel = find((pos_int~=0 | neg_int~=0)& ~isnan(pos_int));
     elseif sum(pos(:))~=0
         cfg.highlightchannel = find(pos_int~=0 & ~isnan(pos_int));
     elseif sum(neg(:))~=0
         cfg.highlightchannel = find(neg_int~=0 & ~isnan(neg_int));
     end
     if isfield(cfg,'highlightchannel')
%         cfg.highlightchannel(cfg.highlightchannel>61)=[];
        cfg.highlight = 'on';
     end
  
     indxsamples    = data1vsdata2.time>=t & data1vsdata2.time<t+times(3);
%      topoplot(mean(data1vsdata2.avg(:,indxsamples),2),chanlocs,'emarker',{'.','k',5,1},'emarker2',{cfg.highlightchannel,'.','k',15,1},'maplimits',zlim);
     if isfield(cfg,'highlightchannel')
          topoplot(mean(data1vsdata2.avg(:,indxsamples),2),chanlocs,'emarker2',{cfg.highlightchannel,'.',[0 0 0],8,1},'maplimits',zlim,'colormap',cmap,'headrad','rim','electrodes','off');
%               topoplot(mean(data1vsdata2.avg(:,indxsamples),2),chanlocs,'emarker2',{cfg.highlightchannel,'.',[0.4 0.4 0.4],11,1},'maplimits',zlim,'colormap',cmap,'headrad','rim','electrodes','off');
%            topoplot(mean(data1vsdata2.avg(:,indxsamples),2),chanlocs,'emarker2',{cfg.highlightchannel,'.',[0 0 0],5,1},'maplimits',zlim,'colormap',cmap,'electrodes','off');
           
           axis([-.6 .6 -.6 .6])
           %           brill
     else
           topoplot(mean(data1vsdata2.avg(:,indxsamples),2),chanlocs,'maplimits',zlim,'colormap',cmap,'headrad','rim','electrodes','off');
%           topoplot(mean(data1vsdata2.avg(:,indxsamples),2),chanlocs,'maplimits',zlim,'colormap',cmap,'electrodes','off');
            axis([-.6 .6 -.6 .6])
     end
    if makefig
     title(sprintf('%2.2f < t < %2.2f',t,t+times(3)))
    end
     numsp = numsp +1;
     if makefig
        if round(t*1000)==0
          text(-1,0,'t=0','FontWeight','demi','FontSize',14)
        end
     end
     if isfield(cfg,'highlightchannel')
        cfg = rmfield(cfg,'highlightchannel');
        cfg.highlight = 'off';
    end
end

if makefig
axes('position',[.9 .2 .005 .6])
axis off
hc = colorbar;
set(hc,'Position',[0.9 0.2 0.01 0.6])
caxis(zlim)

if ~isempty(data1) & ~isempty(data2)
    [ax,h]=suplabel(sprintf('%s  n1=%d , n1=%d',name, size(data1.trial,1), size(data2.trial,1)),'t',[.075 .1 .9 .87]);
else
    [ax,h]=suplabel(sprintf('%s  n1=%d',name, data1.n), 't',[.075 .1 .9 .87]);
end
set(h,'FontSize',18)
end







% load(cfgp.chanfile)
% cfg = [];
% cfg.rotate = 0;
% cfg.showlabels = 'no'; 
% cfg.fontsize = 12; 
% cfg.elec = elec;
% cfg.interactive = 'yes';
% cfg.baseline      = 'no';
% cfg.xlim = times(1:2);
% cfg.xlim = [times(1) times(2)];
% % cfg.ylim = [times(1) times(3)];
% figure,multiplotER(cfg,data1TL,data2TL,data1vsdata2)
