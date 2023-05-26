function fh = plot_comp(cfg,cfg_ica,comps)

% load(cfg.chanfile)
% cfge                = [];
% cfge.elec           = elec;
% cfge.rotate         = 0;
% cfge.markers        = 'numbers';
% cfge.comment        = 'no';
% cfge.fontsize       = 8;
% % fh =figure('visible','off');
% fh=figure
% set(gcf,'Position',[7 31 1428 770])
% cfg_ica.dimord = 'chan_comp';
% 
% % allow multiplotting
% for selcomp = comps
%     subplot(ceil(sqrt(length(comps))), ceil(sqrt(length(comps))), selcomp);
%     cfge.component = selcomp;
%      ft_topoplotER(cfge, cfg_ica);
%         if isfield(cfg_ica,'ratio')
%         if cfg_ica.ratio(selcomp)>1.1
%             text(-.6,.8,sprintf('ICA,%d Ratio:%2.1f',selcomp,cfg_ica.ratio(selcomp)),'Color',[1 0 0]);
%         else
%             text(-.6,.8,sprintf('ICA,%d Ratio:%2.1f',selcomp,cfg_ica.ratio(selcomp)));
%         end
%     end
% end
% try
%  chanlocs = readlocs(cfg.chanloc,'filetype','custom',...
%         'format',{'channum','sph_phi_besa','sph_theta_besa','ignore'},'skiplines',0);
% catch
%     chanlocs = readlocs(cfg.chanloc,'filetype','custom',...
%         'format',{'channum','labels','sph_theta_besa','sph_phi_besa'},'skiplines',1);
% end
load(cfg.chanlocs)
    % remove from chanlocs channels that are not used
    elimchanloc = [];
    for ch =1:length(chanlocs)
        if isempty(strmatch(chanlocs(ch).labels(1:end),cfg_ica.topolabel,'exact'))   %before labels(2:end) need to do a general fix for all types of channel info
            elimchanloc = [elimchanloc,ch];
        end
    end
    if ~isempty(elimchanloc), chanlocs(elimchanloc) = [];end            
    
fh=figure;
set(gcf,'Position',[7 31 1428 770])

for selcomp = comps
     subplot(ceil(sqrt(length(comps))), ceil(sqrt(length(comps))), selcomp);
     topoplot(cfg_ica.topo(:,selcomp),chanlocs,'emarker',{'.','k',5,1});
f=1;
     if isfield(cfg_ica,'comptoremove') & strcmp(cfg.eyedata,'yes')
        if sum(cfg_ica.comptoremove==selcomp)>0
             text(-.6,.8,sprintf('ICA,%d Ratio:%2.1f',selcomp,cfg_ica.ratio(selcomp)),'Color',[1 0 0]);
             f =0;
        end
     end
     if isfield(cfg_ica,'comptoremove_m')
        if sum(cfg_ica.comptoremove_m==selcomp)>0
             text(-.6,.8,sprintf('ICA,%d ',selcomp),'Color',[0 0 1]);
             f=0;
        end
     end
     if f==1
             text(-.6,.8,sprintf('ICA,%d ',selcomp));
     end
end

