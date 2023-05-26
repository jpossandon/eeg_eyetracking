function result = coh_cluster(cfg,data1,data2,npermute)

if isfield(cfg,'chanfile')
    load(cfg.chanfile)
elseif isfield(cfg,'elec')
    elec = cfg.label;
end
    
if ndims(data1)==4
[nch1,nch2,ntimes,subjs] = size(data1);
else
    [nch1,nch2,subjs] = size(data1);
    ntimes = 1;
end
nchans      = length(elec.label);
if nch1~=nch2 | nch1~=nchans
    error('Channels do not match')
end
elec        = bineigh(elec);
alfa        = .001;%.1/nchoosek(nchans,2);
if ntimes>1
    data1 =  permute(data1,[4,1,2,3]);
else
    data1 =  permute(data1,[3,1,2]);
end
% to only measure clusters against 0 without permutation testing (this make sense only for measure that can be 0 like wpli imcoh, NOT for coherence)
if ~isempty(data2)
    if ntimes>1
        data2 = permute(data2,[4,1,2,3]);
    else
        data2 = permute(data2,[3,1,2]);
    end
        
else
    data2 = [];
    npermute=0;
end
for np = 1:npermute+1
    if np == 1
        auxdat1    = data1;
        auxdat2    = data2;
    else        %here need to change randomly ...
        auxdat1        = [];
        auxdat2         = [];
        for suj=1:subjs
            if round(rand(1))
                auxdat1    = cat(1,auxdat1,data1(suj,:,:,:));
                auxdat2    = cat(1,auxdat2,data2(suj,:,:,:));
            else
                auxdat1    = cat(1,auxdat1,data2(suj,:,:,:));
                auxdat2    = cat(1,auxdat2,data1(suj,:,:,:));
            end
        end
        auxdat1    = squeeze(auxdat1);
        auxdat2    = squeeze(auxdat2);
    end
    
    if ~isempty(auxdat2)
        [h,p,ci,stats] = ttest(auxdat1,auxdat2,alfa);
    else
        [h,p,ci,stats] = ttest(auxdat1,0,'alpha',alfa);
    end
    % reshape H(1,nchans,nchans,ntimes) to hh(chcombsxntime)
    if ntimes > 1
    hh             = reshape(h(sub2ind([nchans nchans ntimes],...            % rehs
                                repmat(elec.bi.chan_comb(:,1),ntimes,1),...
                                repmat(elec.bi.chan_comb(:,2),ntimes,1),...
                                reshape(repmat(1:ntimes,size(elec.bi.chan_comb,1),1),ntimes*size(elec.bi.chan_comb,1),1))),...
                        [size(elec.bi.chan_comb,1),size(h,ndims(h))]);
    st             = reshape(stats.tstat(sub2ind([nchans nchans ntimes],...            % rehs
                                repmat(elec.bi.chan_comb(:,1),ntimes,1),...
                                repmat(elec.bi.chan_comb(:,2),ntimes,1),...
                                reshape(repmat(1:ntimes,size(elec.bi.chan_comb,1),1),ntimes*size(elec.bi.chan_comb,1),1))),...
                        [size(elec.bi.chan_comb,1),size(h,ndims(h))]);
    else
        hh             = reshape(h(sub2ind([nchans nchans],...            % rehs
                                repmat(elec.bi.chan_comb(:,1),1),...
                                repmat(elec.bi.chan_comb(:,2),1),...
                                reshape(repmat(1:ntimes,size(elec.bi.chan_comb,1),1),ntimes*size(elec.bi.chan_comb,1),1))),...
                        [size(elec.bi.chan_comb,1),1]);
        st             = reshape(stats.tstat(sub2ind([nchans nchans],...            % rehs
                                repmat(elec.bi.chan_comb(:,1),1),...
                                repmat(elec.bi.chan_comb(:,2),1),...
                                reshape(repmat(1:ntimes,size(elec.bi.chan_comb,1),1),ntimes*size(elec.bi.chan_comb,1),1))),...
                        [size(elec.bi.chan_comb,1),1]);
    end
    if np == 1
        if ~isempty(auxdat2)
            result.auxconn     = squeeze(mean(auxdat1-auxdat2));
        else
            result.auxconn     = mean(auxdat1);
        end
        for tt = 1:ntimes
            result.sigcohim(:,:,tt)     = triu(squeeze(h(1,:,:,tt)));
            result.st(:,:,tt)           = triu(squeeze(stats.tstat(1,:,:,tt)));
        end
        [result.clusters]   = clustereeg(st',hh',elec.bi,size(elec.bi.chan_comb,1),ntimes);
    else
        [auxcluster]   = clustereeg(st',hh',elec.bi,size(elec.bi.chan_comb,1),ntimes);
        result.clusters.MAXst(np-1) = auxcluster.MAXst;
        result.clusters.MAXst_noabs(np-1,:) = auxcluster.MAXst_noabs;
    end
    np
end

    