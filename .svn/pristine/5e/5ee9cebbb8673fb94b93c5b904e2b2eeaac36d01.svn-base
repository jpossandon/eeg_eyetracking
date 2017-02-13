function modelos = sigclusthresh(modelos,elec,alfa)
[ch,betas,times,subjects] = size(modelos.B);
tiempo = modelos.time;
thresholds = prctile(modelos.MAXTCFEDIST,100*(1-alfa)); % TODO: Check this 
    for b = 1:size(modelos.Bt,2)
      
        modelos.pval(:,:,b) = squeeze(sum((abs(permute(repmat(squeeze(modelos.TCFE(:,:,b)),[1 1 size(modelos.MAXTCFEDIST,1)]),[3 1 2]))-repmat(modelos.MAXTCFEDIST(:,b),[1 ch times]))<0,1))/size(modelos.MAXTCFEDIST,1);

        posclus = findclus(squeeze(modelos.TCFE(:,:,b))'>thresholds(b),elec.channeighbstructmat,'id'); % cluster TCFE values above threshold
        modelos.TCFEstat(b).time = tiempo;
        if find(posclus(:)>0)
            modelos.TCFEstat(b).posclusterslabelmat = posclus;
            for ei = [unique(modelos.TCFEstat(b).posclusterslabelmat)]'
                if ei>0
                modelos.TCFEstat(b).posclusters(ei).prob = .001; % this need to be fixed 
                end
            end
        else
            modelos.TCFEstat(b).posclusterslabelmat = [];
            modelos.TCFEstat(b).posclusters = []; 
        end
        negclus = findclus(squeeze(modelos.TCFE(:,:,b))'<-thresholds(b),elec.channeighbstructmat,'id'); % cluster TCFE values above threshold
        if find(negclus(:)>0)
            modelos.TCFEstat(b).negclusterslabelmat = negclus;
            for ei = unique(modelos.TCFEstat(b).negclusterslabelmat)'
                if ei>0
                modelos.TCFEstat(b).negclusters(ei).prob = .001; % this need to be fixed 
                end
            end
        else
            modelos.TCFEstat(b).negclusters = []; 
            modelos.TCFEstat(b).negclusterslabelmat = [];
        end
    end

%         
        
 