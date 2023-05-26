function plotSplinesTopos2D(cfg_eeg,resultSplines,method,pathfig,plotinterval,collimb,half,difference)

if ~isempty(pathfig)
   mkdir(pathfig)
end

setAbsoluteFigureSize
% splnames = cellfun(@(x) x{1},regexp(resultSplines.coeffs,'^([.*_]?.*_)','match'), 'UniformOutput', false)
splnames = cellfun(@(x) x{1},regexp(resultSplines.coeffs,'^(.*?)_(.*?)_','match'), 'UniformOutput', false);

if ~difference
    for splType=unique(splnames)'
        auxcoeffs   = resultSplines.coeffs(strmatch(splType,resultSplines.coeffs));
        secondval   = cellfun(@str2num,(cellfun(@(x) x{1},regexp(auxcoeffs,'[^_]+$','match'), 'UniformOutput', false)));
        firstval    = cellfun(@str2num,(strtok(cellfun(@(x) x{1},regexp(auxcoeffs,'(?<=^(.*?)_(.*?)_)(.*)(?=_.*)','match'), 'UniformOutput', false),'_')));

        splb        = strmatch(splType,splnames);
        betas.dof   = 1;
        betas.n     = size(resultSplines.B,4);
        betas.time  = resultSplines.times;
        betas.firstval = firstval;
        betas.secondval = secondval;
         if isfield(resultSplines,'clusters')
    %        if ~isempty(resultSplines.cluster(b))
    %            stat = resultSplines.cluster(b);
    %        else
    %             stat.time   = resultSplines.times;
    %        end
        else
             stat.time   = resultSplines.times;
         end
        if isempty(collimb)
             collim      =round([-6*nanstd(betas.avg(:)) 6*nanstd(betas.avg(:))]*10)/10; 
        else
            collim = collimb;
        end
            if strcmp(method,'median')
                betas.avg   = squeeze(median(resultSplines.B(:,splb,:,:),4));
            elseif strcmp(method,'mean')
                betas.avg   = squeeze(mean(resultSplines.B(:,splb,:,:),4));
            elseif strcmp(method,'tr_m')
                betas.avg   = squeeze(resultSplines.tr_m(:,:,splb));
            end
    %         collim      =round([-6*nanstd(betas.avg(:)) 6*nanstd(betas.avg(:))]*10)/10; 
    %     
    [cc,rr] = meshgrid(unique(secondval),unique(firstval));
    plotgrid = cat(3,rr,cc);
    plotTimes   = plotinterval(1):plotinterval(3):plotinterval(2);
             for pint = 1:length(plotTimes)
                fh = topo2D(cfg_eeg,stat,betas,plotgrid,[plotTimes(pint) plotinterval(3)],collim,half)   
                fh.Name = num2str(plotTimes(pint));
                  [ax4,h3]=suplabel(sprintf('%s    t:%1.3f (%1.3f)   N:%d',splType{1},plotTimes(pint),plotinterval(3),betas.n)  ,'t');
                    h3.Position(2) = .97;
                    h3.FontSize=14;
                    h3.Interpreter = 'none';
                figsize  = [17.6*.9 17.6*.9*fh.Position(4)/fh.Position(3)];
                doimage(gcf,pathfig,'tiff',[splType{1} strjoin('_2D_',{num2str(plotTimes(pint)),num2str(plotinterval(3))})],'300','opengl',figsize,1)
             end
    %             fh       = topomitlines(cfg_eeg,stat,betas,plotinterval(pint,:),collim,half);
    %             figsize  = [17.6 17.6*fh.Position(4)/fh.Position(3)];
    %                doimage(gcf,pathfig,'pdf',[resultSplines.coeffs{splVal} '_' strjoin('_',{num2str(plotinterval(pint,1)),num2str(plotinterval(pint,2))})],'600','opengl',figsize,1)
    %         end
    %     end
    end
end
if difference
    for splType=unique(splnames)'
        auxcoeffs   = resultSplines.coeffs(strmatch(splType,resultSplines.coeffs));
        secondval   = cellfun(@str2num,(cellfun(@(x) x{1},regexp(auxcoeffs,'[^_]+$','match'), 'UniformOutput', false)));
        firstval    = cellfun(@str2num,(strtok(cellfun(@(x) x{1},regexp(auxcoeffs,'(?<=^(.*?)_(.*?)_)(.*)(?=_.*)','match'), 'UniformOutput', false),'_')));
    
        if difference ==2
            auxord  = unique(firstval);
            auxord2  = unique(secondval);
        elseif difference ==1
            auxord  = unique(secondval);
            auxord2  = unique(firstval);
        end    
        
        % find pairs
        pairs = [];
        checks = ones(length(auxord),1);
        betassel = [];
%         betas2 = [];
        for pp = 1:length(auxord)
            if find(-auxord(pp)) & auxord(pp)~=0 & checks(pp)==1
                pairs(pp,:) = [auxord(pp) -auxord(pp)];
                checks(find(auxord==-auxord(pp))) = 0;
                for pp2 = 1:length(auxord2)
                    if difference ==2
                        betassel = [betassel;find(firstval==pairs(pp,1) & secondval==auxord2(pp2)) find(firstval==pairs(pp,2) & secondval==auxord2(pp2))];
                    elseif difference ==1
                        betassel = [betassel;find(firstval==auxord2(pp2) & secondval==pairs(pp,1)) find(firstval==auxord2(pp2) & secondval==pairs(pp,2))];
                    end
                end
            end
        end
%         splb        = strmatch(splType,splnames);
        betas.dof   = 1;
        betas.n     = size(resultSplines.B,4);
        betas.time  = resultSplines.times;
%         if difference ==1
            betas.firstval = firstval(betassel(:,1));
            betas.secondval = secondval(betassel(:,1));
%         else
%             betas.firstval = firstval(betassel(:,2));
%             betas.secondval = secondval(betassel(:,1));
%         end
         if isfield(resultSplines,'clusters')
    %        if ~isempty(resultSplines.cluster(b))
    %            stat = resultSplines.cluster(b);
    %        else
    %             stat.time   = resultSplines.times;
    %        end
        else
             stat.time   = resultSplines.times;
         end
        if isempty(collimb)
             collim      =round([-6*nanstd(betas.avg(:)) 6*nanstd(betas.avg(:))]*10)/10; 
        else
            collim = collimb;
        end
        if strcmp(method,'median')
            betas.avg   = squeeze(median(resultSplines.B(:,betassel(:,1),:,:)-resultSplines.B(:,betassel(:,2),:,:),4));
        elseif strcmp(method,'mean')
            betas.avg   = squeeze(mean(resultSplines.B(:,betassel(:,1),:,:)-resultSplines.B(:,betassel(:,2),:,:),4));
        elseif strcmp(method,'tr_m')
            betas.avg   = squeeze(resultSplines.tr_m(:,:,betassel(:,1))-resultSplines.tr_m(:,:,betassel(:,2)));
        end
%         collim      =round([-6*nanstd(betas.avg(:)) 6*nanstd(betas.avg(:))]*10)/10; 
%     
        if difference ==1
            [cc,rr] = meshgrid(unique(secondval),pairs(:,1));
        elseif difference ==2
            [cc,rr] = meshgrid(pairs(:,1),unique(firstval));
        end
        plotgrid = cat(3,rr,cc);
        plotTimes   = plotinterval(1):plotinterval(3):plotinterval(2);
         for pint = 1:length(plotTimes)
            fh = topo2D(cfg_eeg,stat,betas,plotgrid,[plotTimes(pint) plotinterval(3)],collim,half)   
            fh.Name = num2str(plotTimes(pint));
            [ax4,h3]=suplabel(sprintf('%s diff %d dim   t:%1.3f (%1.3f)   N:%d',splType{1},difference,plotTimes(pint),plotinterval(3),betas.n)  ,'t');
            h3.Position(2) = .97;
            h3.FontSize=14;
            h3.Interpreter = 'none';
            if difference ==2
                figsize  = [17.6*.9*.5 17.6*.9*fh.Position(4)/fh.Position(3)];
            else
                figsize  = [17.6*.9 17.6*.9*.5*fh.Position(4)/fh.Position(3)]
            end
            doimage(gcf,pathfig,'tiff',[splType{1} strjoin(['_2D_diff',num2str(difference) '_t'] ,{num2str(plotTimes(pint)),num2str(plotinterval(3))})],'300','opengl',figsize,1)
         end
    end
end
