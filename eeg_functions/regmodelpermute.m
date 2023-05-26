function [modelos] = regmodelpermute(cfgs,analysis_type,trl1,trl2,covariates1,covariates2,bsl,reref,npermute)

% npermute      = 100;
keep          = 'yes';
load(cfgs{1}.chanfile)
% here we create the permutation distribution 1000
% first entry third dimension is the actual data
[trl1p,trl2p]           = permute_trialsbysession(trl1,trl2,npermute);
  
for p = 1:npermute
    tic  
    [ERPall_1,toelim]   = getERPsfromtrl(cfgs,trl1p(:,:,p),bsl,reref,analysis_type,keep);
    Y                   = ERPall_1.(analysis_type).trial;
    categ               = ones(size(Y,1),1);
    if ~isempty(covariates1)
        for c = 1:length(covariates1)
            cova1(c).values = [];
            for ip = 1:length(trl1)
                cova1(c).values = [cova1(c).values;covariates1{c}{ip}(setdiff(1:length(covariates1{c}{ip}),toelim{ip}))'];
            end
        end
    end
    clear ERPall_1
%              
   [ERPall_2,toelim]    = getERPsfromtrl(cfgs,trl2p(:,:,p),bsl,reref,analysis_type,keep);
   Y                    = cat(1,Y,ERPall_2.(analysis_type).trial); 
   categ                = [categ;-1*ones(size(ERPall_2.(analysis_type).trial,1),1)];
    clear ERPall_2
    toc
   if ~isempty(covariates2)
        for c = 1:length(covariates2)
            for ip = 1:length(trl1)
                cova1(c).values = [cova1(c).values;covariates2{c}{ip}(setdiff(1:length(covariates2{c}{ip}),toelim{ip}))'];
            end
        end
   end
   if p>1
    fprintf ('Permutation %d/%d %4.2f s \r', p,npermute,toc)
   end
   %here compute the models for all channels time points        
 cova1 = [cova1.values];
 
  for model = 1
        if model==1 
              XY               = [categ,cova1]; % model only with side (regstats add by default a constant teerm)
%          XY = [categ];
        
        end
        [B,Bt,STATS,T] = regntcfe(Y,XY);
         if p==1  % this is the correct grouping
            modelos(model).B            = B;
            modelos(model).Bt           = Bt;
            modelos(model).STATS        = STATS;
%             modelos(model).TCFE         = T;
        else
%             for b = 1:size(modelos(model).Bt,2)
%                 modelos(model).MAXTCFEDIST(p-1,b) = max(max(abs(T(:,:,b))));
%             end
         end

    end
toc
end
toc

% possible models for alter
%                 this is to include covariate that correctfor the superposition of componentns (LATER)    
%                 elseif model==2
%                     XY = [categ,ERPall_1.ICAem.time(t)+auxrt/1000]; % model with side and covariate RT (need to adjust for mean?)
%                 elseif model==3
%                    tindx = floor((ERPall_1.ICAem.time(t)*1000+auxrt)/2)+501; % this numbers are specific for this fs and windowing
%                    covlock = [ERPall_targetl.ICAem.avg(ch,tindx(1:size(ERPall_1.ICAem.trial,1)))';ERPall_targetr.ICAem.avg(ch,tindx(1+size(ERPall_1.ICAem.trial,1):end))'];
%                    XY = [categ,covlock];
%                 
%                    tindx = floor((ERPall_targetl.ICAem.time(t)*1000-auxrtZ)/2)+501; % this numbers are specific for this fs and windowing
%                    covlock = [ERPall_1.ICAem.avg(ch,tindx(1:size(ERPall_targetl.ICAem.trial,1)))';ERPall_2.ICAem.avg(ch,tindx(1+size(ERPall_targetl.ICAem.trial,1):end))'];
%                    XZ = [categZ,covlock];
