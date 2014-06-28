function PlotData()

% load the rtxi data
[t, s, v] = dataload('/usr/src/rtxi/DATA/hybrid_network_Jul_13_07_A1.dat', 4, 3);

% some versions of Iramp module give wrong time so correct it
% for i = 1:length(t)
%     t(i) = t(i) - 0.001*i;
% end

plot (t);

% subplot(2,2,1);
% plot(t,vm);
% xlabel('Time (s)');ylabel('Voltage (mv)');
% axis tight;
% 
% subplot(2,2,3);
% plot(t,cur);
% xlabel('Time (s)');ylabel('Current (pA)');
% axis tight;
% 
% 
% % binary vector with 1s where the spikes are
% thresh = -10;
% bin = ((vm(1:end-1) < thresh) .* (vm(2:end) >= thresh));
% 
% % compute rate during each window
% window = 5000;
% shift = 200;
% fs = 1000;
% 
% % don't preallocate result vector, slower but prevents 0 entries
% res = [];
% 
% i = 1;
% while (i + window <= length(vm))
%     
%     % average number of spikes and current for each window
%     num_spikes = sum(bin(i:i + window));
%     avg_cur = mean(cur(i:i + window));
%     
%     res(end + 1,:) = [num_spikes avg_cur];
%     i = i + shift;
% end
% 
% % convert spike number to rate
% rate = res(:,1) ./ (window / fs);
% 
% 
% subplot(2,2,[2 4]);
% plot(res(:,2), rate, 'ro-');
% xlabel('Current (pA)');ylabel('Frequency (Hz)');
% 
% % print out eps file
% print -depsc A6
