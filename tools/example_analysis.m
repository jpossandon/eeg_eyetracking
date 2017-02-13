%%
figure
plot(modelos_sac.time,squeeze(sacB(42,2,:,:)),'k')
line([-.8 .2],[0 0],'LineWidth',2,'Color',[.7 .7 .7]),
xlim([-.8 .2])
hold on
tr_m        = trimmean(squeeze(sacB(42,2,:,:))',.25*100*2,'floor',1);
                   
tmSE        = winvar(squeeze(sacB(42,2,:,:))',.25);
st           = tr_m./tmSE;
plot(modelos_sac.time,squeeze(modelos_sac.B(42,2,:)),'g','LineWidth',2)
plot(modelos_sac.time,tr_m,'Color',[1 0 0],'LineWidth',2)
plot(modelos_sac.time,st,'Color',[0 0 1],'LineWidth',2)
 neighboursmat = 0
 [T,tstat] = tfce(st,[],neighboursmat,'stat');
 
 %%
 figure,
 plot(modelos_sac.time,st,'Color',[0 0 1],'LineWidth',2)
 hold on
plot(modelos_sac.time,T,'Color',[1 .5 0],'LineWidth',2)
%  plot(modelos_sac.time,T,'Color',[0 1 0],'LineWidth',2)
 
 %%
 % boot sample
 close all
 % example bootsample centering
 for ex = 1:4
 figure
  randsuj             = randsample(1:size(sacB,4),size(sacB,4),'true');
    auxdatab            = sacB(:,:,:,randsuj);
    plot(modelos_sac.time,squeeze(auxdatab(42,2,:,:))','Color',[0 0 0])
    hold on
    
    line([-.8 .2],[0 0],'LineWidth',2,'Color',[.7 .7 0])

    plot(modelos_sac.time,tr_m,'Color',[1 0 0],'LineWidth',2)
   stb                  = trimmean(squeeze(auxdatab(42,2,:,:))',.25*100*2,'floor',1)-tr_m;
    plot(modelos_sac.time,squeeze(auxdatab(42,2,:,:))'-repmat(tr_m,[size(sacB,4),1]),'Color',[.7 .7 .7])
    plot(modelos_sac.time,stb,'Color',[.7 0 0],'LineWidth',2)
    xlim([-.8 .2])
 end
%%
 figure
 for b =1:1000
    randsuj             = randsample(1:size(sacB,4),size(sacB,4),'true');
    auxdatab            = sacB(:,:,:,randsuj);
   
%     plot(modelos_sac.time,squeeze(auxdatab(42,2,:,:))','Color',[0 0 0])
    hold on
%     plot(modelos_sac.time,squeeze(auxdatab(42,2,:,:))'-repmat(tr_m,[size(sacB,4),1]),'Color',[.7 .0 0])
    tmSE                = winvar(squeeze(auxdatab(42,2,:,:))',.25);
    stb                  = (trimmean(squeeze(auxdatab(42,2,:,:))',.25*100*2,'floor',1)-tr_m)./tmSE;
     [stbT,tstat] = tfce(stb,[],neighboursmat,'stat');
    plot(modelos_sac.time,stbT,'Color',[0 0 0])
    [Y(b),I] = max(abs(stbT));
    plot(modelos_sac.time(I),stbT(I),'.','MarkerSize',16,'Color',[1 0 0])
    hold on
 end
  plot(modelos_sac.time,T,'Color',[1 .5 0],'LineWidth',2)
figure
Y((Y>10000)) = 10000;
hist(Y,100,'FaceColor',[1 0 0])
line([prctile(Y,95) prctile(Y,95)],[0 150])

line([-.8 .2],[prctile(Y,95) prctile(Y,95)])
