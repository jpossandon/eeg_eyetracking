function save_log(logstr,logfile)

display(logstr(:)');
fid = fopen(logfile,'a');
fprintf(fid,[logstr '\n']);
fclose(fid);
