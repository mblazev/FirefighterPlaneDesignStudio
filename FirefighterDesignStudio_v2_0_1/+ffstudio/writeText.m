function writeText(path,content)
f=fopen(path,'w','n','UTF-8'); assert(f>0,'ffstudio:IO','Cannot write %s.',path);
cleanup=onCleanup(@()fclose(f)); fprintf(f,'%s',char(content)); clear cleanup;
end
