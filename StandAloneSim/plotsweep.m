function plotsweep

clc;close all;clear all;
% 
% [key,val] = getSweepData();
% plot(key,val, 'bo-')
% ylabel('Frequency (Hz)');
% xlabel('Iapp');
% title('IZ Cell');
% 
% return

% p-p-p-plot
[key,val] = getSweepData('DATA/saved/Jun03/16:55:29/');
subplot(2,2,1);
plot(key,val, 'b-')
ylabel('Frequency (Hz)');
xlabel('Iapp');
title('IZ Cell');

% pause

[key,val] = getSweepData('DATA/saved/Jun03/17:05:04/');
subplot(2,2,2);
plot(key,val, 'r-')
ylabel('Frequency (Hz)');
xlabel('Gsyn_{E-E}');
title('IZ Cell');

% pause

[key,val] = getSweepData('DATA/saved/Jun03/17:07:33/');
subplot(2,2,3);
plot(key,val, 'b-')
ylabel('Frequency (Hz)');
xlabel('Iapp');
title('WB Cell');

% pause

[key,val] = getSweepData('DATA/saved/Jun03/17:12:27/');
subplot(2,2,4);
plot(key,val, 'r-')
ylabel('Frequency (Hz)');
xlabel('Gsyn_{E-E}');
title('WB Cell');



function [key,val] = getSweepData(varargin)

if(nargin == 0) 
    mydir = 'DATA/latest/';
elseif (nargin == 1) 
    mydir = varargin{1};
end

% assume we are looking at 'latest' run
list = dir([mydir,'*.dat']);

key = [];
val = [];

% for all data files
for i = 1:length(list)
    str = list(i).name;
    
    % read data file
    fid = fopen([mydir str]);
    a = fread(fid,[2,Inf], 'double');
    fclose(fid);
    a=a';
  
    % plot traces if you want
    % plot(a(:,2))
    % pause
    % detect spikes (convert to mV)
    spks = spike_detect(a(:,2) * 1000, 20);
    
    % parse out the file names so we can sort things
    pat = '([0-9]*\.?[0-9]+)\.dat';
    [first,last,tok] = regexp(str,pat);

    % save the param value run at (file name) and number of spikes
    key = [key, str2double(str(tok{1}(1):tok{1}(2)))];
    val = [val length(spks)];
end

% sort everything based on filename
[key,i] = sort(key);
val = val(i);

