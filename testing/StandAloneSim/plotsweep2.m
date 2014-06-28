function plotsweep2

close all;

% datdir = 'DATA/saved/Jun27/13:13:52/'; %gamma
datdir = 'DATA/saved/Jun27/16:24:23/'; %theta
% datdir = 'DATA/saved/Jun29/10:14:57/'; % sweep 0-LM iapp
% datdir = 'DATA/latest/';

% input path to data dir if you want to use something other than 'latest'
[key,val] = getSweepData(datdir);
ofreq = [];
efreq = [];
ifreq = [];
netfreq = [];

for i = 1:length(val)
    efreq = [efreq val{i}{1}.freq];
    ifreq = [ifreq val{i}{2}.freq];
    ofreq = [ofreq val{i}{3}.freq];
    netfreq = [netfreq val{i}{4}];
end

figure(111);
plot(key,efreq, 'ro-')
hold on;
plot(key,ifreq, 'bo-')
plot(key,ofreq, 'go-')
% plot(key,netfreq,'ko-')
hold off;

ylabel('Frequencies (Hz)');
xlabel('G_{h}');
% xlabel('Iapp_{O-LM}');
title('Parameter Sweep');
% ylim([0 25]);
% legend([val{1}{1}.name;val{1}{2}.name;val{1}{3}.name;'Network Frequency']);
legend([val{1}{1}.name;val{1}{2}.name;val{1}{3}.name]);

% save the file
saveas(gcf,[datdir 'figure.fig']);
% the end


function [key,val] = getSweepData(varargin)

if(nargin == 0) 
    mydir = 'DATA/latest/';
elseif (nargin == 1) 
    mydir = varargin{1};
end

% assume we are looking at 'latest' run
list = dir([mydir,'*.dat']);

key = [];
val = cell(length(list),1);

% for all data files
for i = 1:length(list)
    str = list(i).name;
    
    % read data file
%     fid = fopen([mydir str]);
%     a = fread(fid,[2,Inf], 'double');
%     fclose(fid);
%     a=a';

    % parse out the file names so we can sort things
    pat = '(-?[0-9]*\.?[0-9]+)\.dat';
    [first,last,tok] = regexp(str,pat);


    % here farm out the actual analysis
    % disp([mydir str])
    [ec,ic,oc,net] = RTXIplot([mydir str(tok{1}(1):tok{1}(2))],0);
    
    
    % save the param value run at (file name) and number of spikes
    key = [key, str2double(str(tok{1}(1):tok{1}(2)))];
    mycell = {ec ic oc net};
    val(i) = {mycell};
end

% sort everything based on filename
[key,i] = sort(key);
val = val(i);

