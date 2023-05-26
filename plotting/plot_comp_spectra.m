function fh = plot_comp_spectra(cfg,cfg_ica,comps)
% 
%  try
%  chanlocs = readlocs(cfg.chanloc,'filetype','custom',...
%         'format',{'channum','sph_phi_besa','sph_theta_besa','ignore'},'skiplines',0);
% catch
%     chanlocs = readlocs(cfg.chanloc,'filetype','custom',...
%         'format',{'channum','labels','sph_theta_besa','sph_phi_besa'},'skiplines',1);
%  end
 % remove from chanlocs channels that are not used
 load(cfg.chanlocs)
    elimchanloc = [];
    for ch =1:length(chanlocs)
        if isempty(strmatch(chanlocs(ch).labels(1:end),cfg_ica.topolabel,'exact'))
            elimchanloc = [elimchanloc,ch];
        end
    end
    if ~isempty(elimchanloc), chanlocs(elimchanloc) = [];end            
    
fh=figure
set(gcf,'Position',[7 31 1428 770])

for selcomp = comps
     subplot(ceil(sqrt(length(comps))), ceil(sqrt(length(comps))), selcomp);
     indx = find(cfg_ica.spectra_f<60);
     plot(cfg_ica.spectra_f(indx),cfg_ica.powspectra(selcomp,indx),'LineWidth',2)
     xlim([0 60])
     set(gca,'FontSize',8,'XTick',0:10:60,'XTickLabel',[])
     box off
     axis square
     ylimv = get(gca,'ylim');
     key(1) = {[sprintf('%d',selcomp) ' \alpha= ' sprintf('%4.1f',cfg_ica.comp_1overf_alpha(selcomp)) ' R^2 = ' sprintf('%0.1f',cfg_ica.comp_1overf_R2(selcomp)) ' /=' sprintf('%1.1f',cfg_ica.spectra_ratio20100(selcomp)) sprintf(' %2.1f',cfg_ica.spectra_powerover20(selcomp)) ]};
     if sum(cfg_ica.comptoremove_m==selcomp)>0 % cfg_ica.comp_1overf_R2(selcomp)<.65 && 
        title(key,'Color',[1 0 0])
     else
         title(key)
     end
 
end

