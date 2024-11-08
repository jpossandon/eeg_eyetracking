function [result] = regmodel2ndstat_ind(data1,data2,tiempo,elec,npermute)
 rng('shuffle')
[ch,betas,times,subjects1] = size(data1);
[ch,betas,times,subjects2] = size(data2);

for p = 1:npermute+1
tic
    for b = 1:betas
        if ch>1
            auxdata1             = permute(squeeze(data1(:,b,:,:)),[3 1 2]);
            auxdata2             = permute(squeeze(data2(:,b,:,:)),[3 1 2]);
        else
            auxdata1             = squeeze(data1);
            auxdata1             = permute(auxdata1(b,:,:),[3 1 2]);
            auxdata2             = squeeze(data2);
            auxdata2             = permute(auxdata2(b,:,:),[3 1 2]);
        end
        if p >1
            % this is changing the sign of the beta 
%                mask            = repmat(randsample([-1 1],subjects,'true')',[1,ch,times]);
%                auxdata         = auxdata.*mask;
            % this is centering and bootstraping the data
%              auxdata_center      = auxdata-repmat(mean(auxdata),[subjects 1 1 1]);
%              auxdata             = auxdata_center(randsample(1:subjects,subjects,'true'),:,:);
                alldata = cat(1,auxdata1,auxdata2);
    
     aux_R = randsample(1:subjects1+subjects2,subjects1+subjects2) ;         % TODO rand seed
     % [tclus,tstat]          = tfce(alldata(aux_R(1:t1),:,:),alldata(aux_R(t1+1:end),:,:),elec.channeighbstructmat,'unpaired');
  
                auxdata1     = alldata(aux_R(1:subjects1),:,:); 
                auxdata2     = alldata(aux_R(subjects1+1:end),:,:); 
              
        end
        
        [~,~,~,s]       = ttest2(auxdata1,auxdata2);

%         T(:,:,b) = tfce(squeeze(s.tstat),[],elec.channeighbstructmat,'stat');
         if ch>1
            T(:,:,b) = tfce(squeeze(s.tstat),[],elec.channeighbstructmat,'stat');
         else
             T(:,:,b) = tfce(squeeze(s.tstat)',[],elec.channeighbstructmat,'stat');
         end

        if p ==1
            result.TCFE = T;
        else  % this is the correct grouping
       result.MAXTCFEDIST(p-1,b) = max(max(abs(T(:,:,b))));
     end
    end
    fprintf ('Permutation %d/%d %4.2f s \r', p,npermute,toc)
%   if p ==16
%       p
%   end
end

for b = 1:betas
    result.pval(:,:,b) = squeeze(sum((abs(permute(repmat(squeeze(result.TCFE(:,:,b)),[1 1 size(result.MAXTCFEDIST,1)]),[3 1 2]))-repmat(result.MAXTCFEDIST(:,b),[1 ch times]))<0,1))/size(result.MAXTCFEDIST,1);
end

alfa = .05;

thresholds = prctile(result.MAXTCFEDIST,100*(1-alfa)); % TODO: Check this 
for b = 1:betas
    posclus = findclus(squeeze(result.TCFE(:,:,b))'>thresholds(b),elec.channeighbstructmat,'id'); % cluster TCFE values above threshold
    result.TCFEstat(b).time = tiempo;
    if find(posclus(:)>0)
        result.TCFEstat(b).posclusterslabelmat = posclus;
        for ei = [unique(result.TCFEstat(b).posclusterslabelmat)]'
            if ei>0
            result.TCFEstat(b).posclusters(ei).prob_abs = .001; % this need to be fixed 
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
            result.TCFEstat(b).negclusters(ei).prob_abs = .001; % this need to be fixed 
            end
        end
    else
        result.TCFEstat(b).negclusters = []; 
        result.TCFEstat(b).negclusterslabelmat = [];
    end
end

%         
        
 