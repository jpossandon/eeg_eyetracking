function [result] = regmodel2ndstat(data,tiempo,elec,npermute,stattype,mc)
 
%
%
% stattype   - 
%       bootp  -  gives non corrected H and p-values estimates of the coefficient
%                   being different from 0 at a given channel x time, based 
%                   on percentile bootstrap, this does not make sense to control 
%                   with any multiple comparison procedure
%    
%       boottet  -  (equal tailesd)gives non corrected H and p-values based
%                   on bootstrap test, this can be combined with MC methods
%                   cluster and TFCE
%       boottsym  - (symmetric)gives non corrected H and p-values based
%                   on bootstrap test, this can be combined with MC methods
%                   maxst, cluster and TFCE but is the same as doing that with a
%                   simple ttest
%       boottrimet & boottrimsym are the same but for estimmates with
%       trimmed means (20%, that measns it takes only 60% of the data) and
%       winsoriced variance

alfa = .05;
trimming = .2;
rng('default') 
rng('shuffle')
[ch,betas,times,subjects] = size(data);
 result.B = data;
for b = 1:betas
     
    if ch>1 && times>1
            auxdata             = permute(squeeze(data(:,b,:,:)),[3 1 2]); % subj x chan x time 
     elseif ch==1 && betas==1 && times>1
            auxdata             = squeeze(data);
            auxdata             = permute(reshape(auxdata,[1 size(auxdata)]),[3 1 2]); %subj x 1 x t
        
    elseif ch==1 && times>1
            auxdata             = squeeze(data);
            auxdata             = permute(auxdata(b,:,:),[3 1 2]); %subj x 1 x t
        elseif ch>1 && times==1
            auxdata             = squeeze(data);
            auxdata             = permute(auxdata(:,b,:),[3 2 1]); % subj x 1 x chan
     end

    for p = 1:npermute+1
    tic
       
        if p == 1
            switch stattype
                case('bootp')
                    st                      = mean(auxdata);
                     result.T(:,:,b)        = st;
                case {'boottrimet','boottrimsym','bootet','bootsym'}   % TODO d.f. and H0 and check absolute thing
                    if strcmp(stattype,'bootet') || strcmp(stattype,'bootsym')
                        trim                = 0;  % this is equivalent tp a test
                    else
                        trim                = trimming;
                    end
                    tr_m                    = trimmean(auxdata,trim*100*2,'floor',1);
                    tmSE                    = winvar(auxdata,trim);
                    st                      = squeeze(tr_m./tmSE);
                    H                       = squeeze(tcdf(st,size(auxdata,1)-1)<alfa/2) + squeeze(tcdf(st,size(auxdata,1)-1)>(1-alfa/2));
                    result.T(:,:,b)         = st;
                    result.tr_m(:,:,b)      = squeeze(tr_m);
                    result.tmSE(:,:,b)      = squeeze(tmSE);
                case ('signpermT')
                    [H,pv,~,s]              = ttest(auxdata,0,alfa);   % this is double tailed by default
                    st                      = squeeze(s.tstat);
                    H                       = squeeze(H);
                    result.T(:,:,b)         = squeeze(st);
                    result.Hnc(:,:,b)       = squeeze(H);
                    result.pvalnc(:,:,b)    = squeeze(pv);
            end
                  
        else
            switch stattype
                case('bootp')
                    randsuj     = randsample(1:subjects,subjects,'true');
                    st          = mean(auxdata(randsuj,:,:));
%                     stboot(:,b,:,p-1) = st;   
                     stboot(:,:,b,p-1) = st;   
                case{'boottrimet','boottrimsym','bootet','bootsym'}
                    randsuj             = randsample(1:subjects,subjects,'true');
                    auxdatab            = auxdata(randsuj,:,:);
                    tmSE                = winvar(auxdatab,trim);
                    bootTMmean            = trimmean(auxdatab,trim*100*2,'floor',1);
                     if strcmp(stattype,'bootet') || strcmp(stattype,'boottrimet')
                        st                  = (bootTMmean-tr_m)./tmSE;
                     elseif strcmp(stattype,'bootsym') || strcmp(stattype,'boottrimsym')
                        st                  = abs(bootTMmean-tr_m)./tmSE;
                     end
                     st                     = squeeze(st);
%                     stboot(:,b,:,p-1)   = st; %WHY? 
                    stboot(:,:,b,p-1)       = st;   
                    bootM(:,:,b,p-1 )       = squeeze(bootTMmean);
                   H                        = squeeze(tcdf(st,size(auxdata,1)-1)<alfa/2) + squeeze(tcdf(st,size(auxdata,1)-1)>(1-alfa/2));
                    
%                     Tmax(p-1)   = max(Taux(p-1,:,:));
            % this is changing the sign of the beta 
                case('signpermT')
                    if round(rand(1)) % this si for the case of even subjects so there is no bias for -1 or 1
                        sss         = [ones(1,floor(subjects/2)),-1.*ones(1,ceil(subjects/2))];
                    else
                        sss         = [-1.*ones(1,floor(subjects/2)),ones(1,ceil(subjects/2))];
                    end
                    if (ch>1 && times>1) 
                        mask        = repmat(randsample(sss,subjects)',[1,ch,times]);
                    elseif (ch>1 && times==1) % this one is organized in a different way, it seems is not a problem
                        mask        = repmat(randsample(sss,subjects)',[1,times,ch]);
                    elseif (ch==1 && times>1)
                        mask        = repmat(randsample(sss,subjects)',[1,1,times]);
                    end
                    auxdatab        = auxdata.*mask;
                    [H,~,~,s]       = ttest(auxdatab,0,.05);
                    st              = squeeze(s.tstat);
                    H               = squeeze(H);
            end
        end
           
        switch mc
            case('tfce') % need to
                 if ch>1 && times>1
                    TFCE            = tfce(st,[],elec.channeighbstructmat,'stat');
                elseif ch==1 && times>1
                    TFCE            = tfce(squeeze(st)',[],elec.channeighbstructmat,'stat');
                elseif ch>1 && times==1
                    TFCE            = tfce(squeeze(st),[],elec.channeighbstructmat,'stat');
                 end
                if p ==1
                    result.TFCE(:,:,b)          = TFCE;
%                     result.T(:,:,b)        = st;
                else  % this is the correct grouping
                    result.MAXTFCEDIST(p-1,b)   = max(max(abs(TFCE)));
                    result.MAXTFCEpos(p-1,b)    = max(max(TFCE));
                    result.MAXTFCEneg(p-1,b)    = min(min(TFCE));
                end
             case('maxsT') 
                 if p ==1
                     result.T(:,:,b)      = st;
%                     result.Bt(:,:,b)     = T;
                else  % this is the correct grouping
                    result.MAXT(p-1,b) = max(max(abs(st)));
                end
             case('cluster')
                 [clusters] = clustereeg(st',H',elec,ch,times);
                 clusters.time = tiempo;
                 if p == 1
                     result.T(:,:,b)         = st;
                     result.clusters(b)      = clusters;
                 else
                     result.clusters(b).MAXst(p-1) = clusters.MAXst;
                     result.clusters(b).MAXst_noabs(p-1,:) = clusters.MAXst_noabs;
                 end
        end
        fprintf ('Beta %d Permutation %d/%d %4.2f s \r',b, p,npermute,toc)
    end
end
 

switch stattype
%     case ('signpermT')
%         result.Hnc      = H;
    case ('bootp')
        pb              = sum(stboot<0,4)./npermute;
        pb              = min(cat(4,pb,1-pb),[],4);
        pb(pb==0)       = 1/npermute;
        result.pvalnc   = pb*2;
        result.Hnc      = (pb*2)<alfa;
        result.boot95CI = prctile(stboot,[2.5 97.5],4);  
    case {'bootet','boottrimet'}
        pb              = sum((repmat(squeeze(result.T),[1 1 1 size(stboot,4)])-stboot)<0,4)./npermute;
        pb              = min(cat(4,pb,1-pb),[],4);
        pb(pb==0)       = 1/npermute;
        result.pvalnc   = pb*2;
        result.Hnc      = (pb*2)<alfa;
%         result.boot95CI = prctile(bootM,[2.5 97.5],4);  
    case {'bootsym','boottrimsym'}
        pb              = sum((repmat(squeeze(abs(result.T)),[1 1 1 size(stboot,4)])-stboot)<0,4)./npermute;
        pb(pb==0)       = 1/npermute;
        result.pvalnc   = pb;
        result.Hnc      = pb<alfa;
        result.boot95CI = prctile(stboot,[2.5 97.5],4);  
end
switch mc
    case('maxsT')
        % dot hsi tommorow
    case('tfce') % replace with sigclusthresh
        for b = 1:betas
            result.pval(:,:,b) = squeeze(sum((abs(permute(repmat(squeeze(result.TFCE(:,:,b)),[1 1 size(result.MAXTFCEDIST,1)]),[3 1 2]))...
                -repmat(result.MAXTFCEDIST(:,b),[1 ch times]))<0,1))/size(result.MAXTFCEDIST,1);
        end

        alfa = .05;

        thresholds = prctile(result.MAXTFCEDIST,100*(1-alfa)); % TODO: Check this 
        for b = 1:betas
            posclus = findclus(squeeze(result.TFCE(:,:,b))'>thresholds(b),elec.channeighbstructmat,'id'); % cluster TCFE values above threshold
            result.TFCEstat(b).time = tiempo;
            if find(posclus(:)>0)
                result.TFCEstat(b).posclusterslabelmat = posclus;
                auxei = [unique(result.TFCEstat(b).posclusterslabelmat)];
                if iscolumn(auxei),auxei=auxei';end
                for ei = auxei
                    if ei>0
                    result.TFCEstat(b).posclusters(ei).prob = NaN; % this need to be fixed 
                    end
                end
            else
                result.TFCEstat(b).posclusterslabelmat = [];
                result.TFCEstat(b).posclusters = []; 
            end
            negclus = findclus(squeeze(result.TFCE(:,:,b))'<-thresholds(b),elec.channeighbstructmat,'id'); % cluster TCFE values above threshold
            if find(negclus(:)>0)
                result.TFCEstat(b).negclusterslabelmat = negclus;
                 auxei = [unique(result.TFCEstat(b).negclusterslabelmat)];
                if iscolumn(auxei),auxei=auxei';end
               for ei = auxei
                    if ei>0
                    result.TFCEstat(b).negclusters(ei).prob = NaN; % this need to be fixed 
                    end
                end
            else
                result.TFCEstat(b).negclusters = []; 
                result.TFCEstat(b).negclusterslabelmat = [];
            end
        end
    case('cluster')
        for b = 1:betas
            result.clusters(b).texto = [];
            if find(result.clusters(b).clus_pos(:)>0)
                result.clusters(b).posclusterslabelmat = result.clusters(b).clus_pos;
                result.clusters(b).posclusters_prob_abs = nan(size(result.clusters(b).clus_pos));
                auxei = [unique(result.clusters(b).posclusterslabelmat)];
                if iscolumn(auxei),auxei=auxei';end
                for ei = auxei
                    if ei>0
                        result.clusters(b).posclusters(ei).prob = sum(result.clusters(b).MAXst>result.clusters(b).maxt_pos(ei))./length(result.clusters(b).MAXst);  % this is very conservative and unfair 
                        result.clusters(b).posclusters(ei).prob_abs = 2.*sum(result.clusters(b).MAXst_noabs(:,1)>result.clusters(b).maxt_pos(ei))./numel(result.clusters(b).MAXst_noabs(:)); % this needs the correction by btwo because we are doing two tests, one for negative and one for positive clusters
                        result.clusters(b).posclusters_prob_abs(result.clusters(b).posclusterslabelmat==ei) = result.clusters(b).posclusters(ei).prob_abs; 
                        if  result.clusters(b).posclusters(ei).prob_abs<alfa
                        indxclus = find(sum(result.clusters(b).posclusterslabelmat==ei));
                        result.clusters(b).texto = [result.clusters(b).texto;sprintf('Positive cluster %03d prob_abs = %1.4f, from t %+05d to %+05d ms',ei,...
                            result.clusters(b).posclusters(ei).prob_abs,round(1000*result.clusters(b).time(indxclus(1))),...
                            round(1000*result.clusters(b).time(indxclus(end))))];
                        end

                    end
                end
            else
                result.clusters(b).posclusterslabelmat = [];
                result.clusters(b).posclusters = []; 
                result.clusters(b).posclusters_prob_abs = [];
            end
            if find(result.clusters(b).clus_neg(:)>0)
                result.clusters(b).negclusterslabelmat = result.clusters(b).clus_neg;
                result.clusters(b).negclusters_prob_abs = nan(size(result.clusters(b).clus_neg));
                
               auxei = [unique(result.clusters(b).negclusterslabelmat)];
                if iscolumn(auxei),auxei=auxei';end
                for ei = auxei
                    if ei>0
                        result.clusters(b).negclusters(ei).prob = sum(result.clusters(b).MAXst>abs(result.clusters(b).maxt_neg(ei)))./length(result.clusters(b).MAXst);
                        result.clusters(b).negclusters(ei).prob_abs = 2.*sum(result.clusters(b).MAXst_noabs(:,2)<result.clusters(b).maxt_neg(ei))./numel(result.clusters(b).MAXst_noabs(:));
                        result.clusters(b).negclusters_prob_abs(result.clusters(b).negclusterslabelmat==ei) = result.clusters(b).negclusters(ei).prob_abs; 
                        
                        if result.clusters(b).negclusters(ei).prob_abs<alfa
                        indxclus = find(sum(result.clusters(b).negclusterslabelmat==ei));
                        result.clusters(b).texto = [result.clusters(b).texto;sprintf('Negative cluster %03d prob_abs = %1.4f, from t %+05d to %+05d ms',ei,...
                            result.clusters(b).negclusters(ei).prob_abs,round(1000*result.clusters(b).time(indxclus(1))),...
                            round(1000*result.clusters(b).time(indxclus(end))))];
                        end

                    end
                end
            else
                result.clusters(b).negclusters = []; 
                result.clusters(b).negclusterslabelmat = [];
                result.clusters(b).negclusters_prob_abs = [];
            end
        end
        
end
result.statlabel = [stattype,'_',mc];   

%         
        
 