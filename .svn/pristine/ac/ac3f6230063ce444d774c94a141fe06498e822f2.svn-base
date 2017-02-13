function  result = pvalclus(result,elec,tiempo)

[ch,times,betas] = size(result.TCFE);
for b = 1:size(result.B,2)
    result.pval(:,:,b) = squeeze(sum((abs(permute(repmat(squeeze(result.TCFE(:,:,b)),[1 1 size(result.MAXTCFEDIST,1)]),[3 1 2]))-repmat(result.MAXTCFEDIST(:,b),[1 ch times]))<0,1))/size(result.MAXTCFEDIST,1);
end

alfa = .05;

thresholds = prctile(result.MAXTCFEDIST,100*(1-alfa)); % TODO: Check this 
for b = 1:size(result.B,2)
    posclus = findclus(squeeze(result.TCFE(:,:,b))'>thresholds(b),elec.channeighbstructmat,'id'); % cluster TCFE values above threshold
    result.TCFEstat(b).time = tiempo;
    if find(posclus(:)>0)
        result.TCFEstat(b).posclusterslabelmat = posclus;
        for ei = [unique(result.TCFEstat(b).posclusterslabelmat)]'
            if ei>0
            result.TCFEstat(b).posclusters(ei).prob = .001; % this need to be fixed 
            end
        end
    else
        result.TCFEstat(b).posclusterslabelmat = [];
        result.TCFEstat(b).posclusters = []; 
    end
    negclus = findclus(squeeze(result.TCFE(:,:,b))'<-thresholds(b),elec.channeighbstructmat,'id'); % cluster TCFE values above threshold
    if find(negclus(:)>0)
        result.TCFEstat(b).negclusterslabelmat = negclus;
        for ei = unique(result.TCFEstat(b).negclusterslabelmat)'
            if ei>0
            result.TCFEstat(b).negclusters(ei).prob = .001; % this need to be fixed 
            end
        end
    else
        result.TCFEstat(b).negclusters = []; 
        result.TCFEstat(b).negclusterslabelmat = [];
    end
end
