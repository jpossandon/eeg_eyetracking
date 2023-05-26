function doimage(handle,dirp,format,name,res,mode,figsize,cl)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doimage(handle,dirp,format,name,figsize,cl)
%
% - handle: figure handle
% - dirp: path to save the figure
% - name: figure name whitout extension
% - format: uh?
% - cl: if 1 image is closed after saving
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = fullfile(dirp,[name '.' format]);
if strcmp(format,'epsc')
    filename = filename(1:end-1);
elseif strcmp(format,'epsc2')
    filename = filename(1:end-2);
elseif strcmp(format,'tiffnocompression')
    filename = filename(1:end-14);
end

if isempty(figsize)
    set(handle, 'PaperPositionMode', 'auto')
else
    set(handle,'paperunits','centimeter')
    set(handle,'papersize',[figsize])
    set(handle,'paperposition',[0 0 figsize]);
end
if strcmp(mode,'painters')
    print(handle,filename, ['-d' format],['-r' res],'-painters');%600
elseif strcmp(mode,'opengl')
    print(handle,filename, ['-d' format],['-r' res],'-opengl');%1200
end
% print(handle, '-opengl', ['-d' format], filename)

  if cl
    close(handle)
 end
 