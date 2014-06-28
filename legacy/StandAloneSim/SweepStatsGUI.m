function SweepStatsGUI()
clear; clc; close all;

% Create figure UI elements
set(0, 'DefaultFigureUnits', 'Normalized');

% [left bottom width height]
% the figure itself
h.fig = figure();
set(h.fig, 'Position', [0.05 0.05 0.9 0.8], 'color', [1 1 0.8]);

% plots
h.ax1 = axes('OuterPosition', [0.2 0.5 0.8 0.5]);
h.ax2 = axes('OuterPosition', [0.2 0.0 0.8 0.5]);

% list for dat files
h.list = uicontrol('Style', 'listbox', 'Units', 'Normalized', 'Position', ...
    [0.05 0.4 0.18 0.5], 'String', 'No Data Found', 'Callback', ...
    {@list_clickFcn, h.fig});

% button to load the files
h.load_button = uicontrol('Style', 'pushbutton', 'Units', 'Normalized', ...
    'Position', [0.05 0.35 0.18 0.05], 'String', 'Load Dat Dir', 'Callback', ...
    {@load_buttonFcn,h.fig}, 'Backgroundcolor', [0.6 1 0.6]);

% error messages
h.err_msg = uicontrol('Style', 'text', 'Units', 'Normalized', ...
    'Position', [0.01 0.95 0.18 0.05], 'String', '', 'BackgroundColor', [1 1 0.8]);

% field to show original netfile
h.netfile = uicontrol('Style', 'edit', 'Units', 'Normalized', ...
    'Position', [0.05 0.05 0.18 0.30], 'String', '', 'BackgroundColor', [1 1 1], ...
    'Min', 1, 'Max', 200, 'HorizontalAlignment', 'left');

guidata(h.fig, h);






function load_buttonFcn(hObject, eventdata, fig)
h = guidata(fig);
% get(h.list, 'String')

h.mydir = uigetdir('DATA/'); 
% mydir = 'DATA/';

% read list of dat files
list = dir([h.mydir '/*.dat']);

res = {};
for i = 1:length(list)
    res{i} = list(i).name;
end

% set file names to text box
set(h.list, 'String', res);

% set netfile to its spot
if (exist([h.mydir '/sm.net']))
    str = textread([h.mydir '/sm.net'], '%s', 'whitespace', '');
    set(h.netfile, 'String', str);
else
    set(h.netfile, 'String', 'no netfile found');
end
    
guidata(fig, h);


function list_clickFcn(hObject, eventdata, fig)
h = guidata(fig);

% reset error message
set(h.err_msg, 'String', '');

% get the clicked item
list = get(h.list, 'String');
clicked = get(h.list, 'Value');

filename = list{clicked};
filename = regexp(filename, '\.', 'split');
SweepStats([h.mydir '/' filename{1}], h);

% send the data file
% list{clicked}
guidata(fig, h);


