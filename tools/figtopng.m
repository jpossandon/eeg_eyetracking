prtdir = pwd;

if exist([prtdir ,'/images'],'dir')
    cd([prtdir ,'/images'])
    curdir = pwd;
    if exist([curdir ,'/figfiles'],'dir') ~= 7
        mkdir([curdir ,'/figfiles'])
    end
    list = dir;
    for e = 1:length(list)
        if ~isempty(strfind(list(e).name,'.fig'))
            uiopen([curdir '/' list(e).name],1)
            doimage(gcf,[curdir '/'],'tiff',list(e).name(1:end-4),'150','painters',[],1)
            eval(['!mv ' list(e).name ' ' curdir '/figfiles/'])
        end
    end
else
    prtList = dir(prtdir);
    for pL = 1:length(prtList)
        if ~strcmp(prtList(pL).name,'.') && ~strcmp(prtList(pL).name,'..') &&...
                ~strcmp(prtList(pL).name,'.DS_Store')
            if exist(fullfile(prtdir,prtList(pL).name,'images'),'dir')
                cd(fullfile(prtdir,prtList(pL).name,'images'))
                curdir = pwd;
                if exist([curdir ,'/figfiles'],'dir') ~= 7
                    mkdir([curdir ,'/figfiles'])
                end
                list = dir;
                for e = 1:length(list)
                    if ~isempty(strfind(list(e).name,'.fig'))
                        uiopen([curdir '/' list(e).name],1)
                        doimage(gcf,[curdir '/'],'tiff',list(e).name(1:end-4),'150','painters',[],1)
                        eval(['!mv ' list(e).name ' ' curdir '/figfiles/'])
                    end
                end
            end
        end
    end
end
        