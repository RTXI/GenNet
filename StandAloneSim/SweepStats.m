function [varargout] = SweepStats(varargin)

% close all; clc; clear all;
varargout = {};
dsrate = 5;
dt = 0.02 * dsrate;

% figure out the argument list
if (nargin == 0) 
    myfile = makefilename();
    doplot = 0;
elseif (nargin == 1) 
    myfile = varargin{1};
    doplot = 0;
else
    % this is the case where we are called by the gui
    myfile = varargin{1};
    handle = varargin{2};
    doplot = 1;
end


datfile = [myfile, '.dat'];
infofile = [myfile, '.info'];

% disp(datfile);

% attempt to read how many columns we are using from the data file
% and if we have a ghost cell
numcols = 0;
hasghost = 0;
if (exist(infofile, 'file'))
    
    fid = fopen(infofile,'r');
    C = textscan(fid, '%s');
   
    if(regexp([C{1}{:}], '@3'))
        hasghost = 1;
    end

    tok = regexp([C{1}{:}], 'numcols:([\d]+)', 'tokens');
    numcols = str2double(tok{1}{1});
    fclose(fid);
end

% do it nicely
plotpos('w');

% read data file
if(numcols == 0)
    'Warning: Attempting to read 0 columns.'
end
a = readDataFile(datfile, numcols) .* 1000;


if (doplot)
    axes(handle.ax1);
    plot(a(:,1), a(:,2), 'r', a(:,1), a(:,3), 'b', a(:,1), a(:,4), 'k');
%     legend('E', 'I', 'O');
    axis tight;
end

traces = [];
clip = 0.5;
for i = 1:4 
    tmp = a(:,i); 
    tmp = tmp(round(length(tmp)*clip):end);
    traces(:,i) = tmp;
end

% test
% cut = 500;  wt = 1;
% tmp = traces(:,wt);
% tmp1 = tmp(1:cut);
% tmp2 = tmp((cut+1):end);
% traces(:,wt) = [tmp2; tmp1];

% time = time(round(length(time)*clip):end);
if (doplot)
    axes(handle.ax2);
    plot(traces(:,1), traces(:,2), 'r', traces(:,1), traces(:,3), 'b', traces(:,1), traces(:,4), 'k');
    axis tight; ylim([-100 80]);
end

% spike inds
einds = spike_detect(traces(:,2), 10);
iinds = spike_detect(traces(:,3), 10);
oinds = spike_detect(traces(:,4), 10);

% check for empty
if (isempty(einds) || isempty(iinds) || isempty(oinds)) 
    if (doplot) 
        set(handle.err_msg, 'String', 'Missing spikes');
    end
    varargout(1:2) = {[0 0]};
    return
end

% check they are all spiking the same (should be within 1 of each other)
if (max([length(einds), length(iinds), length(oinds)]) - 1 > ...
        min([length(einds), length(iinds), length(oinds)]))
    if (doplot)
        set(handle.err_msg, 'String', 'Frequencies Different');
    end
    varargout(1:2) = {[0 0]};
    return
end

% mark spikes
if (doplot)
    hold on;
    plot(handle.ax2, einds .* dt + 500, 0, 'rx');
    plot(handle.ax2, iinds .* dt + 500, 0, 'bx');
    plot(handle.ax2, oinds .* dt + 500, 0, 'kx');
    hold off;
end

diffInds = zeros(3,2);

% want to do this....
% diffInds(1,:) = getSpikeDiff(einds, iinds)
[tmp1, tmp2] = getSpikeDiff(einds, iinds);
diffInds(1,:) = [tmp1, tmp2];
[tmp1, tmp2] = getSpikeDiff(einds, oinds);
diffInds(2,:) = [tmp1, tmp2];
[tmp1, tmp2] = getSpikeDiff(iinds, oinds);
diffInds(3,:) = [tmp1, tmp2];

% change to figure coords
diffCoords = diffInds .* dt + 500;

if (doplot)
    hold on;
    multicolorline([diffCoords(1,1) diffCoords(1,2)], [68 68], 'b','r');
    multicolorline([diffCoords(2,1) diffCoords(2,2)], [64 64], 'r','k');
    multicolorline([diffCoords(3,1) diffCoords(3,2)], [60 60], 'b','k');
    hold off;
end

% output
% format: EI, EO, IO    relative spike times
%         Ef, If, Of    frequencies
% first order difference along 2nd dimension
varargout(1) = {diff(diffCoords, 1, 2)};
varargout(2) = {[1 / (mean(diff(einds)) .* dt ./1000); ...
                 1 / (mean(diff(iinds)) .* dt ./1000); ...
                 1 / (mean(diff(oinds)) .* dt ./1000)]};



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

function a = readDataFile(df, nc)
Pts=inf;
fid = fopen(df);
a = fread(fid,[nc,Pts], 'double');
fclose(fid);
a=a';

function multicolorline(x, y, leftcolor, rightcolor)

x1 = x(1); x2 = x(2);
y1 = y(1); y2 = y(2);
xmid = abs((x1 - x2)/2); 

if (x1 < x2)  
    % from x1 to mid w/ one color
    line([x1 x1+xmid], [y1 y2], 'Color', leftcolor);
    % from mid to x2 w/ second color
    line([x1+xmid x2], [y1 y2], 'Color', rightcolor);
else
    % from x1 to mid w/ one color
    line([x2 x2+xmid], [y1 y2], 'Color', leftcolor);
    % from mid to x2 w/ second color
    line([x2+xmid x1], [y1 y2], 'Color', rightcolor);
end



function [xind, yind] = getSpikeDiff(x, y)

% remember if we switch the 'first' and 'last' vectors
% so the inds we return can be mapped back to the right vectors
swap = 0;

% check which happens last
if (x(end) > y(end))
    last = x;
    first = y;
else
    last = y;
    first = x;
    swap = 1;
end

% check periodic
if (last(end-1) > first(end))
    % spikes aren't happening periodically, can't compute for this case
    xind = 0;
    yind = 0;
    return;
end

% now just check if the first(end) is closer to last(end) or last(end-1)
if((last(end) - first(end)) < (first(end) - last(end-1)))
    xind = last(end);
    yind = first(end);
    
    % reverse the order we return in if needed
    if(swap)
        xind = first(end);
        yind = last(end);
    end
else
    xind = last(end-1);
    yind = first(end);
    
    % reverse the order we return in if needed
    if(swap)
        xind = first(end);
        yind = last(end-1);
    end
end
