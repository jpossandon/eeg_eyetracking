function plotBetas(cfg_eeg,result,pathfig,plotinterval,collimb)

if isempty(plotinterval)
    plotinterval = [-.16  .36 .02];
end
mkdir(pathfig)
plotinterval = [-.3  .2 .02;.2 .7 .02];
setAbsoluteFigureSize
for b=1:size(result.B,2)
    betas.dof   = 1;
    betas.n     = size(result.B,4);
    betas.avg   = squeeze(mean(result.B(:,b,:,:),4));
    betas.time  = result.clusters(1).time;
    
    % topoplot across time according to interval with significant
    % clusters
    if isempty(collimb)
        collim     = [-6*std(betas.avg(:)) 6*std(betas.avg(:))]; 
    else
        collim     = collimb
    end
    for pint = 1:size(plotinterval,1)
        fh       = topomitlines(cfg_eeg,result.clusters(b),betas,plotinterval(pint,:),collim);
        figsize  = [17.6 17.6*fh.Position(4)/fh.Position(3)];
        doimage(gcf,pathfig,'pdf',[result.coeffs{b} '_' strjoin('_',{num2str(plotinterval(pint,1)),num2str(plotinterval(pint,2))})],figsize,1)
   
    end
end