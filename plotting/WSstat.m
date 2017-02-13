function [stat GA1 GA2] = WSstat(cfg,filename,cond1,cond2,subject_sel,newbsl,latency)

load([cfg.eeganalysisfolder, cfg.analysisname, '/' filename],'GA')

GA1             = GA.(cond1);
GA1.individual  = GA.(cond1).individual(subject_sel,:,:);
sample_time     = GA1.time>newbsl(1) & GA1.time<newbsl(2);
GA1.individual  = GA1.individual-repmat(mean(GA1.individual(:,:,sample_time),3),[1,1,length(GA1.time)]);
GA1.avg         = squeeze(mean(GA1.individual));
GA1.var         = squeeze(var(GA1.individual,0,1));

GA2             = GA.(cond2);
GA2.individual  = GA.(cond2).individual(subject_sel,:,:);
sample_time     = GA2.time>newbsl(1) & GA2.time<newbsl(2);
GA2.individual  = GA2.individual-repmat(mean(GA2.individual(:,:,sample_time),3),[1,1,length(GA2.time)]);
GA2.avg         = squeeze(mean(GA2.individual));
GA2.var         = squeeze(var(GA2.individual,0,1));

stat = erp_stat(GA1,GA2,'WS',length(subject_sel),latency);
% plot_stat(stat,GA1,GA2,[latency abs(latency(2)-latency(1))./30],[-1 1])




