function SimpleGUI()
clear; clc;




% ----------------Enter correct path to data directory------------------
h.parent = fullfile('/', 'home', 'user', 'DATA');
% ----------------------------------------------------------------------




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
guidata(fig, h);




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
  xlim=[0,triallen/fs];

  axes(hresp);
  h=plot(xx, yy, plotcolor, 'linewidth',plotwidth);

  axis ([xlim,0,(numtrials)*1.5]);  

  set(hresp, 'Yticklabel', [], 'XTickLabel', []);
  
  

function data = sterilize(data, types)
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



function parts = strsplit(splitstr, str, option)
%STRSPLIT Split string into pieces.
%
%   STRSPLIT(SPLITSTR, STR, OPTION) splits the string STR at every occurrence
%   of SPLITSTR and returns the result as a cell array of strings.  By default,
%   SPLITSTR is not included in the output.
%
%   STRSPLIT(SPLITSTR, STR, OPTION) can be used to control how SPLITSTR is
%   included in the output.  If OPTION is 'include', SPLITSTR will be included
%   as a separate string.  If OPTION is 'append', SPLITSTR will be appended to
%   each output string, as if the input string was split at the position right
%   after the occurrence SPLITSTR.  If OPTION is 'omit', SPLITSTR will not be
%   included in the output.

   nargsin = nargin;
   error(nargchk(2, 3, nargsin));
   if nargsin < 3
      option = 'omit';
   else
      option = lower(option);
   end

   splitlen = length(splitstr);
   parts = {};

   while 1

      k = strfind(str, splitstr);
      if isempty(k)
         parts{end+1} = str;
         break
      end

      switch option
         case 'include'
            parts(end+1:end+2) = {str(1:k(1)-1), splitstr};
         case 'append'
            parts{end+1} = str(1 : k(1)+splitlen-1);
         case 'omit'
            parts{end+1} = str(1 : k(1)-1);
         otherwise
            error(['Invalid option string -- ', option]);
      end


      str = str(k(1)+splitlen : end);

   end



function indeces = spike_detect(data,N)
% Simple spike detector
% Look for threshold crossings separated by >N samples
avg = mean(data);

thresh = avg+30;

indeces = [];
spike = 0;
for i = 2:length(data)
    if ((data(i-1)<=thresh && data(i)>thresh) && spike<1)
        indeces(end+1) = i;
        spike = N;
    end;
    spike = spike-1;
end;


function c=col(num)
%% DEFINE COLOR PROGRESSION
c=[0 0 0];
num=mod(num,15);
switch num
    case 1
        c=[0.2 0.2 0.2];     
    case 2
        c=[0 160 0]/255;     
    case 3
        c=[0 0 255]/255;     
    case 4
        c=[104 34 139]/255;  
    case 5
        c=[255 0  0]/255;   
    case 6
        c=[225 118 0]/255;  
    case 7  
        c=[240 220 0]/255;   
    case 8
        c=[255 175 0]/255;   
    case 9
        c=[255 131 250]/255; 
    case 10
        c=[205 0 205]/255;  
    case 11
        c=[50 153 204]/255;  
    case 12
        c=[112 219 147]/255;    
    case 13
        c=[151 105 79]/255;     
    case 14
        c=[107 66 38]/255;  
    case 0
        c=[140 140 140]/255;  

end





