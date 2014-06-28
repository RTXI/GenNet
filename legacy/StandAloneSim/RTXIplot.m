function[varargout] = RTXIplot(varargin)
% Look at data outputted from the DataLogger

close all;
varargout = {};

% run the current network, doesn't work
% [s,w] = system('./gn nets/sm.net');
% !./gn nets/sm.net

%% Config %%
%myfile = '/home/tilman/Z/Tilman/data/hybrid/Jan18/hybrid_network_Jan_18_08_B7';
%myfile = 'DATA/GenNet_Mar_22_08_A1';

% figure out the argument list
if (nargin == 0) 
    myfile = makefilename();
    doplot = 1;
elseif (nargin == 1) 
    myfile = varargin{1};
    doplot = 1;
else
    myfile = varargin{1};
    doplot = varargin{2};
end

datfile = [myfile, '.dat'];
infofile = [myfile, '.info'];
figfile = [myfile, '.fig'];


disp(myfile)

% attempt to read how many columns we are using from the data file
numcols = 0;
if (exist(infofile, 'file'))
    fid = fopen(infofile,'r');
    numcols = fscanf (fid, 'numcols: %d');
    fclose(fid);
end

% list of channel inds
Channels = [];
% ghost cell channel
gchan = numcols;

if (numcols ~= 0) 
    % subtract out the ghost channel
    Channels = 2:numcols-1;
else
     % this part is sort of old
    %NumChan=16;   % data from RTXI
    %NumChan=19;   % older data from RTXI
    %NumChan=21;   % data i sent to john
    %NumChan=12;    % GenNet
    NumChan=16;
    Channels = [7,8,9,11];
end

% ID strings for figure axes
info={'E Cell'; 'I Cell'; 'O Cell'; 'OCell'; 'OCell'};


%% Jan 18 RTXI Data:
% myfile =
% '/home/tilman/Z/Tilman/data/hybrid/Jan18/hybrid_network_Jan_18_08_B11';
% Channels = [7,8,9,11];
% subplot(N,2,[6 8]);

%% Plot the voltage traces

% do it nicely
plotpos('w');

% read data file
Pts=inf;
fid = fopen(datfile);
a = fread(fid,[numcols,Pts], 'double');
fclose(fid);
a=a';

% pretty!
if (doplot)
    figure('Color',[1 0.949 0.8667]);
end

% plot the voltage traces
cnt=0;
N = length(Channels);
for i=Channels
    cnt=cnt+1;
    
    % make sure we are in range, also collect the result
    if (cnt > length(info))
        varargout(end+1) = {plotdata(a(:,1), a(:,i), cnt, N, 'unknown', doplot)};
    else
        varargout(end+1) = {plotdata(a(:,1), a(:,i), cnt, N, info(cnt), doplot)};
    end

end;

if (doplot)
    % label the last x-axis
    xlabel('Time (sec)');
end

%% plot ghost potential and power spec, possibly
if (gchan)
    
    ghost = a(:,gchan);
    ghost = ghost - mean(ghost);
    
    % get correct right side plot numbers
    rplots = 2 * length(Channels);
    rplots = 2:2:rplots;
    mid = floor(length(rplots)/2);

    % filter some, whos knows what all this does
    w = kaiser(2000,10);
    tmp = conv(ghost, w);
    ghost = tmp(1:length(ghost));
    
    % first subplot up to the midpoint
    if (doplot)
        subplot(N,2,[rplots(1) rplots(mid)]);
        plot(a(:,1), ghost,'r');
        xlim ([0 1]);
        ylabel('Field Potential (mV)');
        xlabel('Time (sec)');
    end

    % power spec
    fs = 1 / (a(2,1) - a (1,1));   % compute sampl. freq from time vector
    [p,w] = psd(ghost, 4096*256, fs);
    t = find(w < 100);

    gamma = find (w < 80 & w > 25);
    theta = find (w < 12 & w > 4);
    beta = find (w < 25 & w > 12);
    tot = find (w < 80 & w > 0);

    ptot = sum (p(tot));
    gpow = sum (p(gamma));
    tpow = sum (p(theta));
    bpow = sum (p(beta));

    per_gamma = gpow / ptot * 100;
    per_theta = tpow / ptot * 100;
    per_beta = bpow / ptot * 100;

    if (doplot)
        % subplot the rest of the space
        subplot(N,2,[rplots(mid+1) rplots(end)]);
        plot(w(t), p(t),'r');
        ylabel('Power Spec (mV^2/Hz)');
        set(gca, 'YTickLabel', '');
        xlabel('Freq (Hz)');
        legend(['Gamma : ', num2str(round(per_gamma)), '% Theta : ', num2str(round(per_theta)), '%']);
    end
end

% output vararg style
% add network frequency to the output
[mval, mind] = max(p(t));
varargout(end+1) = {w(mind)};


% save the figure    
if (doplot)
    saveas(gcf,figfile);
end

%% helper functions

% plot a single cell and return its frequency
function cf = plotdata(time, data, i, N, info, dp)

inds = spike_detect(data*1000, 20);

if (dp)
    subplot(N,2,(2*i)-1);
    plot(time, data*1000,'r');
    % axis tight;
    ylim([-100 60]);
    xlim([0 1]);
    ylabel(info);
    grid on;
    legend(sprintf('Frequency: %dHz', length(inds)));
end

% output info stored in a struct
cf.name = info;
cf.freq = length(inds);



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
