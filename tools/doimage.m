function doimage(handle,dirp,format,name,cl)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doimage(handle,dirp,format,name,cl)
%
% - handle: figure handle
% - dirp: path to save the figure
% - name: figure name whitout extension
% - format: uh?
% - cl: if 1 image is closed after saving
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = [dirp name '.' format];
if strcmp(format,'epsc')
    filename = filename(1:end-1);
elseif strcmp(format,'epsc2')
    filename = filename(1:end-2);
elseif strcmp(format,'tiffnocompression')
    filename = filename(1:end-14);
end
set(handle, 'PaperPositionMode', 'auto')

%   print(handle, '-r0', [dirp name '.' format], ['-d' format]);

print(handle,filename, ['-d' format]);
% print(handle, '-opengl', ['-d' format], filename)

  if cl
    close(handle)
 end
 