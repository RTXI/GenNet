%%
% Original NetPlot from Woods Hole, a better time.
% Updated to automatically read the number of cells being used.
%%

% Look at data outputted from GenNet, specifically those with sparsely
% firing pyramidal cells
function NetPlot()
close all; clc;

plotpos('w');
myfile = 'DATA/GenNet_Jan_26_10_A1';


datfile = [myfile, '.dat'];
infofile = [myfile, '.info'];
figfile = [myfile, '.fig'];

% read in how many cells we simulated
Ncells = 0;
if (exist(infofile, 'file'))
    fid = fopen(infofile,'r');
    Ncells = fscanf (fid, 'numcols: %d');
    fclose(fid);
end



NumChan=Ncells;
Pts=inf;

fid = fopen(datfile);
a = fread(fid,[NumChan,Pts], 'double');
fclose(fid);
a=a';

Channels = 2:Ncells;
N = length(Channels);




cnt=0;
if (Ncells <= 21)
    h = figure(1);
    for i=Channels
        cnt=cnt+1;
        plotdata(a(:,1), a(:,i), cnt, N);
    end;
    saveas(h,figfile);
else

     %h = figure(1);
%    spkinds = spike_detect(1e3*reshape(fliplr(a(:,2:Ncells+1)), 1,size(a,1)*Ncells),50);
        
    spkinds = spike_detect(1e3*reshape(fliplr(a(:,2:Ncells)), 1,size(a,1)*N),50);
    spkmat=zeros(Ncells*size(a,1),1);

    spkmat(spkinds)=1;

    
    spkmat = reshape(spkmat, size(a,1), Ncells);

    %freqs = sum(spkmat,1)/5;
    %[junk, IX] = sort(freqs,'ascend');
%    IX=1:Ncells;

    %spkmat=spkmat(:,IX);
    %spkmat=reshape(spkmat,1,size(a,1)*Ncells);
    %newspkinds=find(spkmat);


    rasterplot(spkinds, Ncells, length(a(:,1)));
    %grid on;
    saveas(gcf,figfile);
end

% plot_scale([0.1 0.1], 1, 0.1);


function plotdata(time, data, i, N)
EphysPlot(N,1,i);
plot(time, data*1000);
text(0.1, 0.9, num2str(i-1), 'Units', 'Normalized')
xlim([0 time(end)/1]);
axis off;