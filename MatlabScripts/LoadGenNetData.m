function LoadGenNetData()

datfile = 'ENTER FULL FILENAME';
infofile = fullfile([datfile(1:end-4) '.info']);

fid = fopen(infofile,'r');

numcols = fscanf (fid, 'numcols: %d');

Pts=inf;
fid = fopen(datfile);
a = fread(fid,[numcols,Pts], 'double');
fclose(fid);
a=a';

time = a(:,1);

hold on;
for i = 2:size(a,2)
    plot(time, a(:,i));
end

