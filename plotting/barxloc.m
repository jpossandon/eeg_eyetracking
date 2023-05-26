function x = barxloc(h)

for e = 1:length(h)
    aux     = get(get(h(e),'Children'),'xdata');
    x(e,:)  = mean(aux(1:2:end,:));
end