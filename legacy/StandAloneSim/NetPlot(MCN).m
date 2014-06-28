function NetPlot()
% Look at data outputted from RTXI
close all; clc;
addpath('C:\Mike\MyFunLib');
plotpos('w');
myfile = 'DATA/GenNet_Aug_11_08_A1.dat';
Ncells = 100;

NumChan=Ncells+1;

Pts=inf;

fid = fopen(myfile);
a = fread(fid,[NumChan,Pts], 'double');
fclose(fid);
a=a';

Channels = 2:Ncells+1;
N = length(Channels);




cnt=0;
if (Ncells < 20)
    figure(1);
    for i=Channels
        cnt=cnt+1;
        plotdata(a(:,1), a(:,i), cnt, N);
    end;
else

    spkinds = spike_detect(1e3*reshape(fliplr(a(:,2:Ncells+1)), 1,size(a,1)*Ncells),50);
    spkmat=zeros(Ncells*size(a,1),1);

    spkmat(spkinds)=1;

    
    spkmat = reshape(spkmat, size(a,1), Ncells);

    freqs = sum(spkmat,1)/5;
    [junk, IX] = sort(freqs,'ascend');
%    IX=1:Ncells;

    spkmat=spkmat(:,IX);
    spkmat=reshape(spkmat,1,size(a,1)*Ncells);
    newspkinds=find(spkmat);


    rasterplot(newspkinds, Ncells, length(a(:,1)));
end




function plotdata(time, data, i, N)
EphysPlot(N,1,i);
plot(time, data*1000);
text(0.1, 0.9, num2str(i-1), 'Units', 'Normalized')
xlim([0 time(end)/1]);
axis off;


