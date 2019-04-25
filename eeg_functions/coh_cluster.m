function result = coh_cluster(cfg,data1,data2,npermute)

load(cfg.chanfile)
[nch1,nch2,ntimes,subjs] = size(data1);
nchans      = length(elec.label);
if nch1~=nch2 | nch1~=nchans
    error('Channels do not match')
end
elec        = bineigh(elec);
alfa        = .0005%.1/nchoosek(nchans,2);
data1 = permute(data1,[4,1,2,3]);
data2 = permute(data2,[4,1,2,3]);
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
    [h,p,ci,stats] = ttest(auxdat1,auxdat2,alfa);
    % reshape H(1,nchans,nchans,ntimes) to hh(chcombsxntime)
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
    
    if np == 1
        result.auxcohim     = squeeze(mean(auxdat1-auxdat2));
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

    