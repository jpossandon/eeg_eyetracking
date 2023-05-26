function [modelos] = regmodelpermutef(cfgs,data,p)

pars        = {'analysis_typ','trls','covariates','interact','bsl','reref','npermute','coding','mirror'};
parsdef     = {'ICAem',[],[],[],[],'yes',1,'effect',[]};
for e = 1:length(pars)
    if ~isfield(p,pars{e})
        p.(pars{e}) = parsdef{e};
    end
end

% function [modelos] = regmodelpermutef(cfgs,analysis_typ,trls,covariates,interact,bsl,reref,npermute,coding,mirror)

% TODO: latency
% covariates cell including in columns each covariate as a cell, and nside
% every cell the respective session, rows are for the different variables
% specified in vars (which cut the data)
keep           = 'yes';
load(cfgs{1}.chanfile)
% here we create the permutation distribution 1000
% first entry of trlp third dimension is the actual data
trlp           = permute_trialsbysession(p.trls,p.npermute);

for pp = 1:p.npermute
     cova1                = struct('values',repmat({[]},1,size(p.covariates,2)));
       
    for vars = 1:size(trlp,1)
        if isempty(data)
            [ERPall,toelim]     = getERPsfromtrl(cfgs,trlp(vars,:,pp),p.bsl,p.reref,p.analysis_typ,keep);
        else
            ERPall          = data(vars);
            toelim          = ERPall.(p.analysis_typ).toelim;
            if pp>1
                error('Within subject permutation for data input not yet implemented')
                % here we need to do the within subject randomization
            end
        end
        nT(vars)            = size(ERPall.(p.analysis_typ).trial,1);
        tiempo              = ERPall.(p.analysis_typ).time;
        if ~isempty(p.mirror)
            if p.mirror(vars)==1
                mirindx         = mirrindex(ERPall.(p.analysis_typ).label,[cfgs{1}.expfolder '/channels/mirror_chans']); 
                ERPall.(p.analysis_typ).trial = ERPall.(p.analysis_typ).trial(:,mirindx,:);
            end
        end
        if vars ==1
            Y                   = ERPall.(p.analysis_typ).trial;
        else
            Y                    = cat(1,Y,ERPall.(p.analysis_typ).trial); 
        end
        switch p.coding
            case('dummy') 
              if vars ==1
                categ               = ones(size(Y,1),1);
              elseif vars < size(trlp,1)
                categ               = [[categ;zeros(nT(vars),size(categ,2))],[zeros(size(categ,1),1);ones(nT(vars),1)]];  
              else
                categ               = [categ;zeros(nT(vars),size(categ,2))];
              end
            case('effect')
               if vars ==1
                categ               = ones(size(Y,1),1);
              elseif vars < size(trlp,1)
                categ               = [[categ;zeros(nT(vars),size(categ,2))],[zeros(size(categ,1),1);ones(nT(vars),1)]];  
              else
                categ               = [categ;-1*ones(nT(vars),size(categ,2))];
              end
        end
        if ~isempty(p.covariates)
            for c = 1:size(p.covariates,2) % covariates
                for ip = 1:size(p.trls,2) % sessions
                    cova1(c).values = [cova1(c).values;p.covariates{vars,c}{ip}(setdiff(1:length(p.covariates{vars,c}{ip}),toelim{ip}))'];
                end
            end
        end
    end
    clear ERPall
%              
  
   if pp>1
    fprintf ('Permutation %d/%d %4.2f s \r', pp,p.npermute,toc)
   end
   tic
   %here compute the models for all channels time points    
   if ~isempty(p.covariates)
    cova1 = [cova1.values];
   end
    for model = 1
        if model==1 
            if ~isempty(p.covariates)
              XY               = [categ,cova1]; % model only with side (regstats add by default a constant teerm)
            else
              XY = [categ];
            end
            if ~isempty(p.interact)
                if iscell(p.interact)
                    for iua = 1:size(p.interact,1)
                        auxint = p.interact{iua};
                        auxstr = 'XY = [XY,';
                        for strint = 1:length(auxint)
                             auxstr = [auxstr,'XY(:,auxint(' num2str(strint) ')).*'];
                        end
                        eval([auxstr(1:end-2),'];']);
                       
                    end
                else
                    for iua = 1:size(p.interact,1)
                        XY = [XY,XY(:,p.interact(iua,1)).*XY(:,p.interact(iua,2))];
                    end
                end
            end
        end
        [B,Bt,STATS,T] = regntcfe(Y,XY,pp,p.coding,elec,p.npermute>1);
         if pp==1  % this is the correct grouping
            modelos(model).B            = B;
            modelos(model).Bt           = Bt;
            modelos(model).STATS        = STATS;
            modelos(model).TCFE         = T;
            modelos(model).n            = nT;
            modelos(model).time         = tiempo;
        else
             for b = 1:size(modelos(model).Bt,2)
                 modelos(model).MAXTCFEDIST(pp-1,b) = max(max(abs(T(:,:,b))));
             end
         end

    end
end

if pp>1
    modelos = sigclusthresh(modelos,elec,.05);
end
% [ch,betas,times,subjects] = size(modelos.B);
% if p >1
%     % clusters
%     alfa = .05;
%     
% 
%     thresholds = prctile(modelos(model).MAXTCFEDIST,100*(1-alfa)); % TODO: Check this 
%     for b = 1:size(modelos(model).Bt,2)
%       
%         modelos(model).pval(:,:,b) = squeeze(sum((abs(permute(repmat(squeeze(modelos(model).TCFE(:,:,b)),[1 1 size(modelos(model).MAXTCFEDIST,1)]),[3 1 2]))-repmat(modelos(model).MAXTCFEDIST(:,b),[1 ch times]))<0,1))/size(modelos(model).MAXTCFEDIST,1);
% 
%         posclus = findclus(squeeze(modelos(model).TCFE(:,:,b))'>thresholds(b),elec.channeighbstructmat,'id'); % cluster TCFE values above threshold
%         modelos(model).TCFEstat(b).time = tiempo;
%         if find(posclus(:)>0)
%             modelos(model).TCFEstat(b).posclusterslabelmat = posclus;
%             for ei = [unique(modelos(model).TCFEstat(b).posclusterslabelmat)]'
%                 if ei>0
%                 modelos(model).TCFEstat(b).posclusters(ei).prob = .001; % this need to be fixed 
%                 end
%             end
%         else
%             modelos(model).TCFEstat(b).posclusterslabelmat = [];
%             modelos(model).TCFEstat(b).posclusters = []; 
%         end
%         negclus = findclus(squeeze(modelos(model).TCFE(:,:,b))'<-thresholds(b),elec.channeighbstructmat,'id'); % cluster TCFE values above threshold
%         if find(negclus(:)>0)
%             modelos(model).TCFEstat(b).negclusterslabelmat = negclus;
%             for ei = unique(modelos(model).TCFEstat(b).negclusterslabelmat)'
%                 if ei>0
%                 modelos(model).TCFEstat(b).negclusters(ei).prob = .001; % this need to be fixed 
%                 end
%             end
%         else
%             modelos(model).TCFEstat(b).negclusters = []; 
%             modelos(model).TCFEstat(b).negclusterslabelmat = [];
%         end
%     end
% end
% %         
%         
%  