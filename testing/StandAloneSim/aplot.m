function aplot
% Look at data outputted from RTXI
close all; clc;

% run the current network
[s,w] = unix('./gn nets/sm.net');

%% Config %%
myfile = makefilename();

datfile = [myfile, '.dat'];
infofile = [myfile, '.info'];
figfile = [myfile, '.fig'];

% attempt to read how many columns we are using from the data file
numcols = 0;
if (exist(infofile, 'file'))
    fid = fopen(infofile,'r');
    numcols = fscanf (fid, 'numcols: %d');
    fclose(fid);
end

Channels = [];
if (numcols ~= 0) 
    NumChan = numcols
    Channels = 2:numcols;
end

info={'ECell'};

%% end config  %%


% plot nicely
plotpos('w');

% read data file
Pts=inf;
fid = fopen(datfile);
a = fread(fid,[numcols,Pts], 'double');
fclose(fid);
a=a';

% pretty!
figure('Color',[1 0.949 0.8667]);

% plot the voltage traces
cnt=0;
N = length(Channels);
for i=Channels
    cnt=cnt+1;
    plotdata(a(:,1), a(:,i), cnt, N, info(cnt));

end;

% save the figure    
saveas(gcf,figfile);



function plotdata(time, data, i, N, info)
i;
N;

subplot(N,1,(2*i)-1);

plot(time, data*1000,'r');
axis tight;
%ylim([-100 50]);
xlim([0 1]);
ylabel(info);
grid on;
if (i == 4)
    xlabel('Time (sec)');
end

% Automatically create the date-based file name of sim results
function str = makefilename()

% generate current time stamp
c = clock;
months = ['Jan'; 'Feb'; 'Mar'; 'Apr'; 'May'; 'Jun'; 'Jul'; 'Aug'; 'Sep'; 'Oct'; 'Nov'; 'Dec'];
str = 'DATA/GenNet_';
str = [str, num2str(months(c(2),:)), '_'];

% prepend a '0' if needed
dy = c(3);
if (dy < 10)
    str = [str, '0', num2str(c(3))];
else
    str = [str, num2str(c(3))];
end
str = [str, '_'];

% prepend a '0' if needed
yr = c(1) - 2000; 
if (yr < 10) 
    str = [str, '0', num2str(yr)];
else
    str = [str, num2str(yr)];
end
str = [str, '_A1'];
