function stat = tfce_stat(dat1,dat2,elec,nrand)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function stat = tfce_stat(dat1,dat2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: check that channels matrices and label are correct
% TODO: different stat functions
[tclusreal,tstatreal]          = tfce(dat1,dat2,elec.channeighbstructmat,'unpaired');
% TODO: reset randomization
fprintf('                                    ')
for r = 1:nrand
     alldata = cat(1,dat1,dat2);
     t1 = size(dat1,1);
     t2 = size(dat2,1);
     aux_R = randsample(1:t1+t2,t1+t2) ;         % TODO rand seed
     [tclus,tstat]          = tfce(alldata(aux_R(1:t1),:,:),alldata(aux_R(t1+1:end),:,:),elec.channeighbstructmat,'unpaired');
     [i,j] = max(abs(tclus(:)));
     maxvalues(r) = tclus(j);          % TODO, check the statistical rationale for max m=neg or pos values
     fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');%     figure,plot(time,tclus)    
     fprintf('%04d/%04d permutation clusters done.',r,nrand);%     figure,plot(time,tclus)
end

% TODO: alpha and tails
alpha = .05
[p] = prctile(maxvalues,[alpha*100/2 100-alpha*100/2])
stat.h = tclusreal<p(1)|tclusreal>p(2);
% maxvaluessorted = sort(maxvalues);
% stat.p = p;


