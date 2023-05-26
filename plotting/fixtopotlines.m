bla = get(gca);
for child = 1:length(bla.Children)
    if strcmp(bla.Children(child).Type,'line')
        bla.Children(child).LineWidth = .4;
    end
    if strcmp(bla.Children(child).Type,'contour')
        bla.Children(child).LineWidth = .2;
    end
end