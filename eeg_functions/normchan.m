function data = normchan(data,chan,time)

times = (data.time>time(1) & data.time<time(2));
for suj = 1:size(data.individual,1)
    data.individual(suj,:,:)   = data.individual(suj,:,:)./max(abs(data.individual(suj,chan,times))); 
end
data                       = rebsl(data,[-.5 -.1]); % only for get averages with the normalized units
