function EphysPlot(rows, cols, num)

if (num>rows*cols)
    disp('Plot number out of bounds');
else
    fig = gcf;
    ax = axes;
    set(ax, 'Units', 'Normalized');

    left = 0.025+.95*mod((num-1),cols)/(cols);
    width = .95/cols-.0125*(cols-1);

    bottom = 0.025+(1-ceil((num)/cols)/rows)*.95;
    height = .95/rows;

    set(ax,'Position', [left, bottom, width, height]);


end


