function indeces = spike_detect(data,N)
% Mike Economo
% August 2006
% This is a fairly robust AP detector written to figure out the average
% firing rate in response to different stimuli in Julie Haas data.
% spike detector
avg = mean(data);

thresh = avg+35;

indeces = [];
spike = 0;
for i = 2:length(data)
    if ((data(i-1)<=thresh && data(i)>thresh) && spike<1)
        indeces(end+1) = i;
        spike = N;
    end;
    spike = spike-1;
end;

