function plot_spec (mypath)
close all; clc;
plotpos('w')

% save current dir, go to data dir
% curr_dir = pwd;
% cd (mypath);



% get list of all dat files
% list = dir('*.dat');

% ghost cell voltaget (field potential is last channel)
time = 1;
numchan = 5;
fpchan = 7;

% concatinated FP from all files 
signal = [];
tot_time = [];

% for i = 1:length(list) 
    % get file name
%     str = list(i).name
str = mypath;

    % read data file
    pts = inf;
    fid = fopen(str);
%    a = fread(fid,[fpchan,pts], 'double');
   a = fread(fid,[7,pts], 'double');
    fclose(fid);
    a = a';

    % get field potential
    fp = a(:,fpchan);
    fp = fp - mean(fp);
    fp = fp * 1e3;
    
    fp = fp(4000:end);
    
    signal = [signal; fp];
    
    % concat, but have to not increment time the first time
%     if (i == 1)
        tot_time = [tot_time; a(:,time)];
%     else 
%         tot_time = [tot_time; (a(:,time) + tot_time(end))];
%     end
    
% end

% Equiripple Lowpass filter designed using the FIRPM function.

% All frequency values are in Hz.
% Fs = 50000;  % Sampling Frequency
% 
% N     = 20;   % Order
% Fpass = 50;  % Passband Frequency
% Fstop = 80;  % Stopband Frequency
% Wpass = 1;    % Passband Weight
% Wstop = 1;    % Stopband Weight
% dens  = 20;   % Density Factor
% 
% % Calculate the coefficients using the FIRPM function.
% b  = firpm(N, [0 Fpass Fstop Fs/2]/(Fs/2), [1 1 0 0], [Wpass Wstop], ...
%            {dens});
% filt_sig = filtfilt(b, 1, signal);       


filt_sig = signal;


%subplot(1,2,1)
spectrogram(filt_sig, length(fp)/6, round(length(fp)/6*.95),[1:1:80],5e4,'yaxis');
xlabel('Time (s)');
%subplot(1,2,2)
%plot(tot_time(4000:end), signal);
%ylabel('Voltage (mV)'); xlabel('Time (s)');axis tight;

% cd(curr_dir);
