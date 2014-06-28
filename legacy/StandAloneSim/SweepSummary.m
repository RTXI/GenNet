function [hasDiffs, hasTheta, hasBoth] = SweepSummary(varargin)

clc; clear all;

% select data dir
mydir = uigetdir('DATA/'); 
% mydir = 'DATA/latest';

% read list of dat files
list = dir([mydir '/*.dat']);

res = {};
hasTheta = {};
hasDiffs = {};
hasBoth = {};

for i = 1:length(list)
    res{i} = list(i).name;
    filename = res{i};
    
    filename = regexp(filename, '\.', 'split');
    [diffs, freqs] = SweepStats([mydir '/' filename{1}]);
    
    if (hasRightSpikeTimes(diffs))
        hasDiffs{end+1} = filename{1};
    end
    
    if (isTheta(freqs))
        hasTheta{end+1} = filename{1};
    end
    
    if (hasRightSpikeTimes(diffs) && isTheta(freqs))
        hasBoth{end+1} = filename{1};
    end
    
    if(mod(i, 100) == 0)
        i
    end
end

size(hasDiffs)
size(hasTheta)
size(hasBoth)

if(0)
end


function m = hasRightSpikeTimes(x)

m = false;
if(x == 0)
    m = false;
    return;
else
    m = true;
    return;
end

function m = isTheta(x)

m = false;
if (sum(x < 3) || sum(x > 15))
    m = false;
    return;
else
    m = true;
    return;
end
            