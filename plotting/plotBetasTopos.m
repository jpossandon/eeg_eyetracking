function plotBetasTopos(cfg_eeg,result,method,pathfig,plotinterval,collimb,half)

if isempty(plotinterval)
    plotinterval = [-.16  .36 .02];
end
if ~isempty(pathfig)
   mkdir(pathfig)
end
% setAbsoluteFigureSize
for b=1:size(result.B,2)
    betas.dof   = 1;
    betas.n     = size(result.B,4);
    if strcmp(method,'median')
        betas.avg   = squeeze(median(result.B(:,b,:,:),4));
    elseif strcmp(method,'mean')
        betas.avg   = squeeze(mean(result.B(:,b,:,:),4));
    elseif strcmp(method,'tr_m')
        betas.avg   = squeeze(result.tr_m(:,:,b));
    end
    if isfield(result,'clusters')
        betas.time  = result.clusters(1).time;
    elseif isfield(result,'TFCEstat')
        betas.time  = result.TFCEstat(1).time;
    end
    % topoplot across time according to interval with significant
    % clusters
    if isempty(collimb)
        collim      =round([-6*nanstd(betas.avg(:)) 6*nanstd(betas.avg(:))]*10)/10; 
        collim      =[-6*nanstd(betas.avg(:)) 6*nanstd(betas.avg(:))]; 
    else
        collim     = collimb;
    end
    for pint = 1:size(plotinterval,1)
        fh       = topomitlines(cfg_eeg,result.clusters(b),betas,plotinterval(pint,:),collim,half);
%         figsize  = [17.6*.75 17.6*.75*fh.Position(4)/fh.Position(3)];
        figsize  = [17.6*.9 17.6*.9*fh.Position(4)/fh.Position(3)];
        if ~isempty(pathfig)
%         doimage(gcf,pathfig,'pdf',[result.coeffs{b} '_' strjoin('_',{num2str(plotinterval(pint,1)),num2str(plotinterval(pint,2))})],'600','opengl',figsize,1)
            doimage(gcf,pathfig,'pdf',[result.coeffs{b} '_' num2str(plotinterval(pint,1)) '_' num2str(plotinterval(pint,2))],'300','painters',figsize,1)
        end
    end
end