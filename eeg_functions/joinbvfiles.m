function joinbvfiles(path,filestojoin,newfilename)

%%
% check that merged files do not exist
if exist([path newfilename '.eeg']) || exist([path newfilename '.vhdr']) || exist([path newfilename '.vmrk'])
    error(sprintf(' %s files already exist, aborting merge',newfilename)),
end
% create the new .eeg file
newdat = [];
for f = 1:length(filestojoin)
    hdr = ft_read_header([path filestojoin{f} '.vhdr']);
    if f==1
        prevBinaryFormat = hdr.orig.BinaryFormat;
        switch lower(hdr.orig.BinaryFormat)
        case 'int_16'
          sampletype = 'int16';
          samplesize = 2;
        case 'int_32'
          sampletype = 'int32';
          samplesize = 4;
        case 'ieee_float_32'
          sampletype = 'float32';
          samplesize = 4;
        end 
    else
        if ~strcmp(prevBinaryFormat,hdr.orig.BinaryFormat) 
            error('Files binary format do not match and cannot be joined')
        end
    end
    nsamples(f) = hdr.nSamples;
    fid = fopen([path hdr.orig.DataFile], 'rb', 'ieee-le');
    dat  = fread(fid, [hdr.orig.NumberOfChannels, hdr.orig.nSamples], sampletype);
    fclose(fid);
    newdat = [newdat,dat];
end
nsamcum     = cumsum(nsamples);
if sum(nsamples)~=size(newdat,2)
    error('Files length not equal to the header number of samples')
end


fid = fopen([path newfilename '.eeg'], 'wb', 'ieee-le');
fwrite(fid,newdat,sampletype);
fclose(fid);
  
%%
% new header with the right name % TODO:format is wrong, missing microvolt sign 
fid = fopen([path filestojoin{1} '.vhdr'],'rt'); % open the first header file
k= 1;
while (1)
    line = fgetl(fid);
  if ~isempty(line) && isequal(line, -1)
    % prematurely reached end of file
    fclose(fid);
    break
  end
  mydata{k} = line;
  k = k+1;
end
% find the file name lines
ss          = strmatch('DataFile',mydata);
mydata{ss}  = [mydata{ss}(1:9),newfilename,'.eeg'];
ss          = strmatch('MarkerFile',mydata);
mydata{ss}  = [mydata{ss}(1:11),newfilename,'.eeg'];

% write the new file
fid = fopen([path newfilename '.vhdr'],'w');
fprintf(fid, '%s\n', mydata{:});
fclose(fid);

%%
% new marker file
copyfile([path filestojoin{1} '.vmrk'],[path newfilename '.vmrk'])         % use the first marker file to append next ones
fid = fopen([path newfilename '.vmrk'],'r');
while ~feof(fid) % this is to get the last line of the first marker file
    line = fgetl(fid);
end
 fclose(fid);
lastline = textscan(line,'%s %*s %d %*d %*d','Delimiter',',');
lastmknum = strtok(lastline{1},'=');
lastmknum = str2num(lastmknum{1}(3:end));

k= 1;
for f = 2:length(filestojoin)
    fid = fopen([path filestojoin{f} '.vmrk'],'r'); % open the first header file
    
    transf = 0;
    while (1)
        line = fgetl(fid);
      if ~isempty(line) && isequal(line, -1)
        % prematurely reached end of file
        fclose(fid);
        break
      end
      if strfind(line,'Mk2=')
          transf = 1;
      end
      if transf
          addlinebits   = textscan(line,'%s %s %d %d %d','Delimiter',',');
          oldmknum      = regexp(addlinebits{1}(:),'\d*','match');
          newmk         = str2num(oldmknum{1}{:})+lastmknum-1;
          newtim        = addlinebits{3}+nsamcum(f-1);
          addline       = sprintf('Mk%d=Stimulus,%s,%d,%d,%d',newmk,addlinebits{2}{:},newtim,addlinebits{4},addlinebits{5});
          addmarker{k}  = addline;
          k             = k+1;
      end
    end
    lastmknum = newmk;
end

fid = fopen([path newfilename '.vmrk'],'a');
fprintf(fid, '%s\n', addmarker{:});
fclose(fid);