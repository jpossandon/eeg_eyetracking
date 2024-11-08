function fh = plotICA_labels(EEG,iclabelthresh,nchantopplot,nrows,ncols)

% figure for checking ICA
pop_topoplot(EEG, 0, [1:nchantopplot] ,'',[nrows ncols],'electrodes','off');
fh = gcf;
axesHandle = get(fh,'Children');
for axs = 1:length(axesHandle )
    for ics = 1:nchantopplot
        if strcmp(axesHandle(axs).Title.String,['IC ' num2str(ics)])
            if isfield(EEG,'dipfit')
                resvar = num2str(round(1000*EEG.dipfit.model(ics).rv)/10) ;
                addstr = [resvar  '%'];
            else
                addstr = [''];
            end
            if EEG.etc.ic_classification.ICLabel.classifications(ics,2)>= iclabelthresh
                axesHandle(axs).Title.String = ['IC ' num2str(ics) ' M ' addstr];
                axesHandle(axs).Title.Color = [.5 0 0];
            elseif EEG.etc.ic_classification.ICLabel.classifications(ics,3)>= iclabelthresh
                axesHandle(axs).Title.String = ['IC ' num2str(ics) ' E ' addstr];
                axesHandle(axs).Title.Color = [.5 0 0];
            elseif EEG.etc.ic_classification.ICLabel.classifications(ics,4)>= iclabelthresh
                axesHandle(axs).Title.String = ['IC ' num2str(ics) ' N ' addstr];
                axesHandle(axs).Title.Color = [.5 0 0];
            elseif EEG.etc.ic_classification.ICLabel.classifications(ics,6)>= iclabelthresh
                axesHandle(axs).Title.String = ['IC ' num2str(ics) ' H' addstr];
                axesHandle(axs).Title.Color = [.5 0 0];
            else
                axesHandle(axs).Title.String = ['IC ' num2str(ics) ' ' addstr];
                axesHandle(axs).Title.Color = [0 0 0];
            end
            
        end
    end
end
annotation('textbox',[.1 .01 .5 .1],'String',sprintf('Muscle components: %s ( ICs %s )\nEye components: %s ( ICs %s )\nECG components: %s ( ICs %s )\nnoise components: %s ( ICs %s )\n',...
    num2str(sum(EEG.etc.ic_classification.ICLabel.classifications(:,2) >= iclabelthresh)),num2str(find(EEG.etc.ic_classification.ICLabel.classifications(:,2)' >= iclabelthresh)),...
    num2str(sum(EEG.etc.ic_classification.ICLabel.classifications(:,3) >= iclabelthresh)),num2str(find(EEG.etc.ic_classification.ICLabel.classifications(:,3)' >= iclabelthresh)),...
    num2str(sum(EEG.etc.ic_classification.ICLabel.classifications(:,4) >= iclabelthresh)),num2str(find(EEG.etc.ic_classification.ICLabel.classifications(:,4)' >= iclabelthresh)),...
    num2str(sum(EEG.etc.ic_classification.ICLabel.classifications(:,6) >= iclabelthresh)),num2str(find(EEG.etc.ic_classification.ICLabel.classifications(:,6)' >= iclabelthresh))))
 if isfield(EEG,'dipfit')
     addstr1 =  sprintf('Near-dipolar ICs (r.v.< 5%%): (%d/%d) %1.1f%%',...
    sum(cell2mat( { EEG.dipfit.model.rv } )<.05),length(EEG.dipfit.model),sum(cell2mat( { EEG.dipfit.model.rv } )<.05)./length(EEG.dipfit.model)*100);
 else
     addstr1 = '';
 end
  if isfield(EEG,'ICAmir')
      addstr2 = sprintf('MIR: %1.2f (Kbits/s)',EEG.ICAmir);
  else
      addstr2 = '';
  end
annotation('textbox',[.65 .01 .25 .1],'String',sprintf('ICAlabel Threshold: %1.2f\n%s\n%s',...
    iclabelthresh,addstr1,addstr2))
