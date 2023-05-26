function plotSplinesTopos(cfg_eeg,resultSplines,method,pathfig,plotinterval,collimb,half,difference)

if ~isempty(pathfig)
   mkdir(pathfig)
end

setAbsoluteFigureSize
splnames = cellfun(@(x) x{1},regexp(resultSplines.coeffs,'^([.*_]?.*_)','match'), 'UniformOutput', false)

for splType=unique(splnames)'
    splb        = strmatch(splType,splnames);
    betas.dof   = 1;
    betas.n     = size(resultSplines.B,4);
    betas.time  = resultSplines.times;
    if isfield(resultSplines,'clusters')
       if ~isempty(resultSplines.cluster(b))
           stat = resultSplines.cluster(b);
       else
            stat.time   = resultSplines.times;
       end
   else
        stat.time   = resultSplines.times;
   end
    %     collim      =[-6 6]; 
    for splVal = splb'
        if strcmp(method,'median')
            betas.avg   = squeeze(median(resultSplines.B(:,splVal,:,:),4));
        elseif strcmp(method,'mean')
            betas.avg   = squeeze(mean(resultSplines.B(:,splVal,:,:),4));
        elseif strcmp(method,'tr_m')
            betas.avg   = squeeze(resultSplines.tr_m(:,:,splVal));
        end
        collim      =round([-6*nanstd(betas.avg(:)) 6*nanstd(betas.avg(:))]*10)/10; 
    
        for pint = 1:size(plotinterval,1)
            fh       = topomitlines(cfg_eeg,stat,betas,plotinterval(pint,:),collim,half);
            figsize  = [17.6 17.6*fh.Position(4)/fh.Position(3)];
               doimage(gcf,pathfig,'pdf',[resultSplines.coeffs{splVal} '_' strjoin('_',{num2str(plotinterval(pint,1)),num2str(plotinterval(pint,2))})],'600','opengl',figsize,1)
        end
    end
end

% difference at same vector
if difference
    for splType=unique(splnames)'
        splb        = strmatch(splType,splnames);
        betas.dof   = 1;
        betas.n     = size(resultSplines.B,4);
        betas.time  = resultSplines.times;
        stat.time   = resultSplines.times;
        %     collim      =[-6 6]; 
        for splVal = 1:floor(length(splb)/2)
            if strcmp(method,'median')
                betas.avg   = squeeze(median(resultSplines.B(:,splb(end-splVal+1),:,:)-resultSplines.B(:,splb(splVal),:,:),4));
            elseif strcmp(method,'mean')
                betas.avg   = squeeze(mean(resultSplines.B(:,splb(end-splVal+1),:,:)-resultSplines.B(:,splb(splVal),:,:),4));
            elseif strcmp(method,'tr_m')
          %      betas.avg   = squeeze(resultSpline.tr_m(:,:,b));
            end
             collim      =round([-6*std(betas.avg(:)) 6*std(betas.avg(:))]*10)/10; 

            for pint = 1:size(plotinterval,1)
                fh       = topomitlines(cfg_eeg,stat,betas,plotinterval(pint,:),collim,half);
                figsize  = [17.6*.9 17.6*.9*fh.Position(4)/fh.Position(3)];
                  doimage(gcf,pathfig,'pdf',[resultSplines.coeffs{splb(end-splVal+1)} '_minus_' resultSplines.coeffs{splb(splVal)} '_' strjoin('_',{num2str(plotinterval(pint,1)),num2str(plotinterval(pint,2))})],'600','opengl',figsize,1)
            end
        end
    end
end