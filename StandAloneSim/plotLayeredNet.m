function plotLayeredNet()

close all; plotpos();

nlayers = 4;
ndiff = 15;
ncells = 50;  
psyn = 0.02;


% generate cells, make each layer smaller and center them
cells = {};
for i = 1:nlayers
    n = ncells - (ndiff * (i-1));
    cells{i} = linspace(0-(n/2),n-(n/2),n);
end

figure; 
hold on;
% plot cell dots
for i = 1:length(cells)
    plot(cells{i},i,'.k');
end

% do synapses, don't have to draw any syns from last layer

% for each layer
for i = 1:length(cells)-1
    i
    psyn*(i^2)
    cnt = 0;
    % for each cell in the layer
    for j = 1:length(cells{i})
        % for each possible post synaptic target cell
       
        for k = 1:length(cells{i+1});
            if (rand < psyn*(i*1.2))
                
                % draw a synapse
                p1 = [cells{i}(j) i];
                p2 = [cells{i+1}(k) i+1];
                
                line([p1(1) p2(1)], [p1(2) p2(2)], 'Color', 'k');
                cnt = cnt + 1;
            end
        end 
    end
    cnt
end

% to remember how I made this
% nlayers = 4;
% ndiff = 15;
% ncells = 50;  
% psyn = 0.02;
title(['plotLayeredNet.m: 4, 15, 50, 0.02']);

function plotpos()
    set(0, 'DefaultFigureUnits', 'Normalized');
    set(0, 'DefaultFigurePosition', [0.05, 0.05, .9, .85]); % Whole Screen
    set(0, 'DefaultLineMarkerSize',30);
    set(0, 'DefaultAxesFontSize',18);
    set(0, 'DefaultLineLineWidth',2);

    