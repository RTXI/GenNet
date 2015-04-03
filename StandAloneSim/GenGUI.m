function GenGUI()
clear; clc;
drive = '/home/ndl/';
%drive = 'H:';
addpath(fullfile(drive, 'H', 'Mike', 'MyFunLib'))
h.parent = fullfile(drive, 'DATA');

fig1 = figure(66);
set(fig1, 'Units','Normalized','Position',[0.1 0.1 0.8 0.8], 'CloseRequestFcn',['g=get(0,''Children''); '...
 'for i=1:length(g), delete(g(i)); end;'...
 'clear all;']);
h.ax1 = axes('Outerposition',[0.2 0.6 0.8 0.4], 'YTick',[], 'Box', 'On', ...
    'Xgrid', 'On', 'XTickLabel', []);
h.ax2 = axes('Outerposition',[0.2 0.0 0.8 0.6], 'Box', 'On', 'XGrid', 'On');

h.fn = makefilename();
uipanel('Position', [0.01 0.8 0.26 0.175]);

h.fn_text = uicontrol('Style', 'text', 'String', h.fn,'Units','normalized', ...
    'BackgroundColor',[0.9255 0.9137 0.8471],'Position',[.07 .825 .185 .03],'HorizontalAlignment' ...
    ,'Left', 'FontSize', 11, 'FontWeight','Bold');
uicontrol('Style', 'text', 'String', 'Data file: ','Units','normalized' ...
    ,'BackgroundColor',[0.9255 0.9137 0.8471],'Position',[0.012 .825 .05 .025],'HorizontalAlignment','Right');
h.load_button = uicontrol('Style', 'pushbutton',  'Units', 'normalized', 'Position', ...
    [.11 .66 .16 .1], 'String', 'Load file','FontWeight','Bold', 'Callback', ...
    {@load_button_fcn,gcf});
h.change_button = uicontrol('Style', 'pushbutton',  'Units', 'normalized', 'Position', ...
    [.08 .89 .1 .05], 'String', 'Change file name','FontWeight','Bold', 'Callback', ...
    {@change_button_fcn,gcf});

h.channel_list = uicontrol('Style', 'listbox', 'Units', 'normalized', 'Position', ...
    [.01 0.01 .09 .75], 'FontWeight', 'Bold', 'String', {'No channels'}, 'Max', 2);
h.plot_button = uicontrol('Style', 'pushbutton',  'Units', 'normalized', 'Position', ...
    [.11 .1 .12 .45], 'String', 'Update plot','FontWeight','Bold', 'Callback', ...
    {@plot_button_fcn,gcf});

tempx = 0.47;
tempy = 0.335;
h.tstart_edit = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', ...
    [tempx+0.07 tempy+0.25 .06 0.025], 'String', '0', 'FontWeight', 'Bold', ...
    'BackgroundColor',[1 1 1], 'Callback', {@update_axes,gcf});
h.tend_edit = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', ...
    [tempx+0.16 tempy+0.25 .06 0.025], 'String', '1', 'FontWeight', 'Bold', ...
    'BackgroundColor',[1 1 1], 'Callback', {@update_axes,gcf});
uicontrol('Style', 'text', 'String', 'Plot from ','Units','normalized' ...
    ,'BackgroundColor',[ 0.8 0.8 0.8],'Position',[tempx+0 tempy+0.245 .06 0.025],'HorizontalAlignment','Right' ...
    ,'FontWeight','Bold');
uicontrol('Style', 'text', 'String', ' to ','Units','normalized' ...
    ,'BackgroundColor',[ 0.8 0.8 0.8],'Position',[tempx+0.13 tempy+0.245 .03 0.025],'HorizontalAlignment','Center' ...
    ,'FontWeight','Bold');
uicontrol('Style', 'text', 'String', ' Seconds ','Units','normalized' ...
    ,'BackgroundColor',[ 0.8 0.8 0.8],'Position',[tempx+0.23 tempy+0.245 .06 0.025],'HorizontalAlignment','Left' ...
    ,'FontWeight','Bold');

h.fft_button = uicontrol('Style', 'pushbutton',  'Units', 'normalized', 'Position', ...
    [.85 .575 .1 .05], 'String', 'Show FFT','FontWeight','Bold', 'Callback', ...
    {@fft_button_fcn,gcf});

h.EI_button = uicontrol('Style', 'pushbutton',  'Units', 'normalized', 'Position', ...
    [.3 .575 .1 .05], 'String', 'Compare E/I','FontWeight','Bold', 'Callback', ...
    {@EI_button_fcn,gcf});

h.Ecells_checkbox = uicontrol('Style', 'checkbox',  'Units', 'normalized', 'Position', ...
    [.77 .59 .065 .02], 'String', 'Excitatory','FontWeight','Bold', 'Value', 1);

h.Icells_checkbox = uicontrol('Style', 'checkbox',  'Units', 'normalized', 'Position', ...
    [.77 .565 .065 .02], 'String', 'Inhibitory','FontWeight','Bold', 'Value', 1);
h.Acells_checkbox = uicontrol('Style', 'checkbox',  'Units', 'normalized', 'Position', ...
    [.77 .615 .065 .02], 'String', 'All','FontWeight','Bold', 'Value', 1);



guidata(fig1, h);






function load_button_fcn(hObject, eventdata, fig)
h = guidata(fig);

datfile = fullfile(h.parent, [h.fn '.dat']);
infofile = fullfile(h.parent, [h.fn '.info']);

fid = fopen(infofile,'r');

types = [];
numcols = fscanf (fid, 'numcols: %d');

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    
    if (isempty(tline)), continue, end
    
    if (tline(1) == '@')
        tline = tline(2:end);
        res = strsplit(',', tline);
    
        types(end+1) = str2num(res{1});
    end
end

fclose(fid);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           

h.exc = [find(types==8) find(types==10) find(types==12)];
h.inh = [find(types==9) find(types==11)];

% read data file
Pts=inf;
fid = fopen(datfile);
a = fread(fid,[numcols,Pts], 'double');
fclose(fid);
a=a';

%check for infs and nans
h.time = a(:,1);
h.data = a(:,2:end)*1000;
clear a;

h.data = sterilize(h.data, types);



% for i = find(types==12)
%     inds = find(h.data(:,i)>20);
%     h.data(inds,i)=20;
% end
% 
% infcells = max(isinf(h.data)) + max(h.data>100) + max(h.data<-800);
% infcells = find(infcells);
% 
% if (~isempty(infcells))
%     disp(['Found inf in cell(s) ' mat2str(infcells-1) '! Not including in raster.']);
% end
% nancells = find(max(isnan(h.data)));
% if (~isempty(nancells))
%     disp(['Found inf in cell(s) ' mat2str(nancells-1) '! Not including in raster.']);
% end
% % h.data(:,[nancells infcells]) = -66.6;

dt = mean(diff(h.time(:,1)))*1000;
Ncells = numcols-1;

%Do raster on local copy of data (with replaced nans and infs)


spkinds = spike_detect(reshape(fliplr(h.data), 1,size(h.data,1)*Ncells), 10);

rasterplot(spkinds, Ncells, length(h.time), h.ax1, 1e3/dt);
set(h.ax1, 'Xgrid', 'On');

string_list = {};
for i = 1:Ncells
    string_list{end+1} = ['Cell ' num2str(i-1)];
end

set(h.channel_list, 'String', string_list);
set(h.tstart_edit, 'String', num2str(h.time(1)));
set(h.tend_edit, 'String', num2str(h.time(end)));
update_axes(hObject, eventdata, fig);

guidata(fig, h);





function change_button_fcn(hObject, eventdata, fig)
h = guidata(fig);

OK=0;
while (~OK)

    [file, path] = uigetfile('*.dat', 'Select data file', h.parent);

    if (file == 0)
        set(h.fn_text,'String', 'No valid file selected');
        return;
    end
    if (~strcmpi(file(end-3:end), '.dat'))
         set(h.fn_text,'String', 'No valid file selected');
    else
        OK=1;
        file = file(1:end-4);
        set(h.fn_text,'String',file);
    end
end;
h.fn = file;
h.parent = path;

guidata(fig, h);





function plot_button_fcn(hObject, eventdata, fig)
h = guidata(fig);

cells = get(h.channel_list, 'Value');
axes(h.ax2);
hold off;
cnt = 0;
for i=cells
    cnt = cnt + 1;
    plot(h.time, h.data(:,i), 'Color', col(cnt), 'LineWidth', 2);
    hold on;
end
set(h.ax2, 'Xgrid', 'On');
axis('tight');
xlabel('Time (ms)');
ylabel('Potential (mv)');





update_axes(hObject, eventdata, fig);
%ylim([10*floor(min(min(h.data(:,cells)))/10) 10*ceil(max(max(h.data(:,cells)))/10)]);

guidata(fig, h);



function EI_button_fcn(hObject, eventdata, fig)
h = guidata(fig);

E = h.data(:,end);
I = h.data(:,end-1);



Ipeaks = findPeaks(-I, h.time, 0.01);
Epeaks = findPeaks(E, h.time, 0.01);



[Epeaks, Ipeaks] = PairEvents(h.time, Epeaks, Ipeaks);

delay = mean(h.time(Ipeaks)-h.time(Epeaks));

xstart = find(h.time>0.01, 1, 'first');
xend  = find(h.time>0.025, 1, 'first');

Etrace = zeros(xstart+xend+1, 1);
Itrace = zeros(xstart+xend+1, 1);
cnt = 0;
for i = 1:length(Epeaks)
    if (Epeaks(i) - xstart > 0 && Epeaks(i) + xend < length(E))
        Etrace = Etrace + E(Epeaks(i)-xstart:Epeaks(i)+xend);
        Itrace = Itrace + I(Epeaks(i)-xstart:Epeaks(i)+xend);
        cnt = cnt+1;
    end
end

if (cnt>0)
    Etrace = Etrace./cnt;
    Itrace = Itrace./cnt;
end

R = corrcoef(E(Epeaks), -I(Ipeaks));


figure;
subplot(2,4,1:4); hold on;
plot(h.time, E, h.time, -I);
plot(h.time(Epeaks), E(Epeaks), 'r.', h.time(Ipeaks), -I(Ipeaks), 'g.');
ylabel('Synaptic currents (pA)');
xlabel('Time (sec)');

subplot(2,4,5); hold on;
plot(h.time(1:xstart+xend+1), -6*Etrace, h.time(1:xstart+xend+1), Itrace);
xlabel('Time (sec)');
ylabel('Average synaptic currents');

subplot(2,4,6); 
plot(h.time(1:xstart+xend+1), Etrace./-Itrace);
xlabel('Time (sec)');
ylabel('Excitation/Inhibition');

subplot(2,4,7); 
plot(h.time(1:xstart+xend+1), Etrace+Itrace);
xlabel('Time (sec)');
ylabel('Total current');


subplot(2,4,8);
plot(E(Epeaks), -I(Ipeaks), 'k.');
xlabel('EPSC magnitude (pA)');
ylabel('IPSC magnitude (pA)');
title(['Correlation = ' num2str(R(2,1))]);







function fft_button_fcn(hObject, eventdata, fig)

h = guidata(fig);

if get(h.Ecells_checkbox, 'Value')
    sme = SpikeStats(h, h.exc, 'b');
    %SpikeCorrs(h, h.exc, sme, 'b');
end
if get(h.Icells_checkbox, 'Value')
    smi = SpikeStats(h, h.inh, 'r');
end
if get(h.Acells_checkbox, 'Value')
    smei = SpikeStats(h, [h.exc h.inh], 'k');
end




guidata(fig, h);



function SpikeCorrs(h, cells, sm, colr)

N = length(h.exc);
xc = zeros(N,1);
for i = 1:N
    binary = zeros(size(h.time));
    spks = spike_detect(h.data(:,i), 10);
    binary(spks) = 1;
    %a = xcorr(binary - mean(binary), sm - mean(sm));
    a = binary.*(sm-mean(sm));
    xc(i) = sum(a)./length(spks);
    
    
    
end

figure;
[cnts, pos] = hist(xc, 30);
bar(pos, cnts, .90);
hold on;
plot(xc(N), max(cnts), 'rx');



function sm = SpikeStats(h, cells, colr)
figure(2);
set(gcf, 'Position', [0.02 0.05 0.7 0.9])

dat = h.data(:, cells);

fs = 1./mean(diff(h.time));

w = linspace(0,fs, length(h.time)+1)';
w = w(1:end-1);


[sm, smw, smwsm, info] = OscStats(h.time, dat);




subplot(2,4,1:4);
hold on;
plot(h.time, sm, colr, 'LineWidth', 2)
plot(h.time(info.peaks), sm(info.peaks), [colr '.']);
xlim([0 max(h.time)]);
str1 = ['<Rate> = ' num2str(info.rate) '  '];
str1 = [get(get(gca, 'Title'), 'String') str1];
title(str1);

subplot(2,4,5:6);
hold on;
plot(w, smw, colr, 'LineWidth', 1);
plot(w, smwsm, colr, 'LineWidth', 2);
plot(w(info.maxind), info.maxval, 'g.');
plot([w(1) w(info.lastind)], [info.halfamp, info.halfamp], 'k--','LineWidth', 1);
plot(w(info.incind), smwsm(info.incind), 'g.', w(info.decind), smwsm(info.decind), 'g.');
xlim([0 100]);


subplot(2,4,7:8);
hold on;
plot(sm(info.peaks(1:end-1))-mean(sm), diff(h.time(info.peaks)).*1000, [colr '.']);
xlabel('Interneuron recruitment');
ylabel('Subsequent period (ms)');
R = corrcoef(diff(h.time(info.peaks)), sm(info.peaks(1:end-1))-mean(sm));
str1 = ['Corr = ' num2str(R(1,2)) '  '];
str1 = [get(get(gca, 'Title'), 'String') str1];
title(str1);
axis square;



function update_axes(hObject, eventdata, fig)

h = guidata(fig);

axes(h.ax1);
tstart = str2double(get(h.tstart_edit, 'String'));
tend   = str2double(get(h.tend_edit, 'String'));

if (~isempty(tstart) && ~isempty(tend) && tend >tstart)
    xlim([tstart tend]);
end


axes(h.ax2);
tstart = str2double(get(h.tstart_edit, 'String'));
tend   = str2double(get(h.tend_edit, 'String'));

if (~isempty(tstart) && ~isempty(tend) && tend >tstart)
    xlim([tstart tend]);
end
guidata(fig, h);



function net_button_fcn(hObject, eventdata, fig)
h = guidata(fig);

fid = fopen([h.parent h.fn '.info']);
fig2 = figure(2);
set(fig2, 'Units', 'Normalized', 'Position', [0.35 0.4 0.6 0.3], 'CloseRequestFcn', 'delete(gcf);');
numcells = 0;
numsyn = 0;
conn = [];

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    
    if (isempty(tline)), continue, end
    
    if (tline(1) == '@')
        tline = tline(2:end);
        numcells = numcells + 1;
        res = strsplit(',', tline);
        types(end+1) = res{1};
    end
    
    if (tline(1) == '>')
        tline = tline(2:end);
        res = strsplit(',', tline);
        conn = [conn; str2double(res{1}), str2double(res{2}), str2double(res{3}), str2double(res{4})];
        
        numsyn = numsyn + 1;
    end
end
fclose(fid);

allcells=0:numcells-1;
postCells = intersect(allcells, conn(:,2)); % >=1 postsynaptic connection

Npre = min(postCells);
Npost  = numcells-Npre;

theta1 = linspace(0, 2*pi, Npre+1);
theta1 = theta1(1:end-1);

theta2 = linspace(0, 2*pi, Npost+1);
theta2 = theta2(1:end-1);
theta = [theta1 theta2];
if (length(theta1)>1)
    rad1 = (1/(theta1(2)-theta1(1)))/(1/(theta2(2)-theta2(1)));
else
    rad1=0;
end;

rho1 = rad1*ones(1,Npre);
rho2 = ones(1,Npost);
rho = [rho1 rho2];

% convert to cartesian coords
xmid1 = -1.5;
ymid1 = 0;
xmid2 = 1;
ymid2 = 0;

xmid = [xmid1*ones(size(rho1)) xmid2*ones(size(rho2))];
ymid = [ymid1*ones(size(rho1)) ymid2*ones(size(rho2))];

x = rho .* cos(theta);
y = rho .* sin(theta);

plot(x+xmid, y+ymid, 'k.');
set(gcf, 'Color', [0.95 0.95 0.95]);
hold on;
axis image;
axis off;
% xlim([xmid1 - rad1 xmid2+1]);
% yl = max(rad1, 1);
% ylim([-yl yl]);

maxweight = max(conn(:,3));
minweight = min(conn(:,3));

% plot syns
for i = 1:size(conn, 1)
    c = conn(i,1:2)+1;
    sign = (conn(i,4)>-40) - (conn(i,4)<-40);
    weight = conn(i,3);

    
    x0 = x(c(1))+xmid(c(1)); x1 = x(c(2))+xmid(c(2));
    y0 = y(c(1))+ymid(c(1)); y1 = y(c(2))+ymid(c(2));
    
    
    lfo = 0.15;  %Fraction of outgoing lines to plot
    lfi = 0.25;
    
    lw = 0.1 + 2*(weight-minweight)/(maxweight-minweight);
    
    % pre synaptic connections (eg. outgoing)
    line([x0 ((1-lfo)*x0 + lfo*x1)], [y0 ((1-lfo)*y0 + lfo*y1)], 'Color','k', 'LineWidth',lw);

    % post synaptic connections (eg. incoming)
    color = 'y';
    if (sign==1),  color = 'r'; end
    if (sign==-1), color = 'b'; end
    
    line([x1 ((1-lfi)*x1 + lfi*x0)], [y1 ((1-lfi)*y1 + lfi*y0)], 'Color',color, 'LineWidth',lw);
end

hold off;




function str = makefilename()

% generate current time stamp
c = clock;
months = ['Jan'; 'Feb'; 'Mar'; 'Apr'; 'May'; 'Jun'; 'Jul'; 'Aug'; 'Sep'; 'Oct'; 'Nov'; 'Dec'];
str = 'GenNet_';
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


function rasterplot(times,numtrials,triallen, varargin)

nin=nargin;

%%%%%%%%%%%%%% Plot variables %%%%%%%%%%%%%%
plotwidth=2;     % spike thickness
plotcolor='k';   % spike color
trialgap=1.5;    % distance between trials
defaultfs=50000;  % default sampling rate
showtimescale=0; % display timescale
showlabels=0;    % display x and y labels

%%%%%%%%% Code Begins %%%%%%%%%%%%
switch nin
 case 3 %no handle so plot in a separate figure
  figure;
  hresp=gca;
  fs=defaultfs;
 case 4 %handle supplied
  hresp=varargin{1};
  if (~ishandle(hresp))
    error('Invalid handle');
  end
  fs=defaultfs;
 case 5 %fs supplied
  hresp=varargin{1};
  if (~ishandle(hresp))
    error('Invalid handle');
  end
  fs = varargin{2};        
 otherwise
  error ('Invalid Arguments');
end


 % plot spikes

  trials=ceil(times/triallen);
  reltimes=mod(times,triallen);
  reltimes(~reltimes)=triallen;
  numspikes=length(times);
  xx=ones(3*numspikes,1)*nan;
  yy=ones(3*numspikes,1)*nan;

  yy(1:3:3*numspikes)=(trials-1)*trialgap;
  yy(2:3:3*numspikes)=yy(1:3:3*numspikes)+1;
  
  %scale the time axis to sec
  xx(1:3:3*numspikes)=reltimes/fs;
  xx(2:3:3*numspikes)=reltimes/fs;
  xlim=[1,triallen/fs];

  axes(hresp);
  h=plot(xx, yy, plotcolor, 'linewidth',plotwidth);
  
 axis ([xlim,0,(numtrials)*1.5]);  

  set(hresp, 'Yticklabel', [], 'XTickLabel', []);
  
  

function data = sterilize(data, types)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = find(types==12)
    inds = data(:,i)>20;
    data(inds,i)=20;
    
end


infcells = max(isinf(data)) + max(data>100) + max(data<-200);
infcells = find(infcells);

if (~isempty(infcells))
    disp(['Found inf in cell(s) ' mat2str(infcells-1) '! Not including in raster.']);
end
nancells = find(max(isnan(data)));
if (~isempty(nancells))
    disp(['Found inf in cell(s) ' mat2str(nancells-1) '! Not including in raster.']);
end
%data(:,[nancells infcells]) = -66.6;




function peaks = findPeaks(dat, time, delta)
pts = find(time>delta, 1, 'first');
ddat = diff(dat);
peaks = [];
for i = pts+1:length(dat)-pts
    if ((ddat(i-1) > 0) && (ddat(i) <= 0) && min(dat(i) > dat(i-pts:i-1)) && min(dat(i) >= dat(i+1:i+pts)))
        peaks(end+1) = i;
    end
end



function [out1 out2] = PairEvents(time, ev1, ev2)

out1 = zeros(size(ev1));
out2 = zeros(size(ev1));

max_delay = find(time>0.01, 1, 'first');

cnt = 1;
if (length(ev1)>1 && length(ev2)>1)
     for jj = ev1
         [junk, ci] = min(abs(ev2-jj));
         if (ci <= max_delay)
             out1(cnt) = jj;
             out2(cnt) = ev2(ci);
             cnt = cnt+1;
         end
     end
else
    out1 = 1;
    out2 = 1;
end

out1 = out1(out1~=0);
out2 = out2(out2~=0);













