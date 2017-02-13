

curdir = pwd;
if exist([curdir ,'/figfiles'],'dir') ~= 7
    mkdir([curdir ,'/figfiles'])
end
list = dir;
for e = 1:length(list)
    if ~isempty(strfind(list(e).name,'.fig'))
        uiopen([curdir '/' list(e).name],1)
        doimage(gcf,[curdir '/'],'tiff',list(e).name(1:end-4),1)
        eval(['!mv ' list(e).name ' ' curdir '/figfiles/'])
    end
end