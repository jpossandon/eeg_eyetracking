function leghandle = adjustLegend(leghandle,objleg,fontsize,position)

for oo = 1:length(objleg)
    if strcmp(objleg(oo).Type,'text')
        objleg(oo).Position(1) = .2;
    elseif strcmp(objleg(oo).Type,'line') 
        objleg(oo).XData    = [.05 .15];
    end
end
leghandle.Box = 'off';
leghandle.FontSize = fontsize;
leghandle.Position = position;
