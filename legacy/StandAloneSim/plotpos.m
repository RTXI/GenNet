function plotpos(flag)
switch flag
    case 'l'
        set(0, 'DefaultFigureUnits', 'Pixels');
        set(0, 'DefaultFigurePosition', [60, 530, 512, 384]);   % Left Monitor
        set(0, 'DefaultLineMarkerSize',15);
        set(0, 'DefaultAxesFontSize',11);
    case 'r'
        set(0, 'DefaultFigureUnits', 'Pixels');
        set(0, 'DefaultFigurePosition', [1295, 560, 512, 384]); % Right Monitor
        set(0, 'DefaultLineMarkerSize',15);
        set(0, 'DefaultAxesFontSize',11);

    case 'b'
        set(0, 'DefaultFigureUnits', 'Normalized');
        set(0, 'DefaultFigurePosition', [.019, .295, .425, .63]); % Big Right Monitor
        set(0, 'DefaultLineMarkerSize',18);
        set(0, 'DefaultAxesFontSize',19);
    case 'w'
        set(0, 'DefaultFigureUnits', 'Normalized');
        set(0, 'DefaultFigurePosition', [.025, .085, .95, .8]); % Whole Screen
        set(0, 'DefaultLineMarkerSize',18);
        set(0, 'DefaultAxesFontSize',18);
        set(0, 'DefaultLineLineWidth', 3);
        set(0, 'DefaultLineColor', [0.847,0.161,0.0]);
end