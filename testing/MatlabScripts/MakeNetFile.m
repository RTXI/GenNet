function MakeNetFile()
clc;

fn = 'ring.net';

celltype = 10;
Ncells = 10;

% Define a vector of cells (in this case they are all the same)
cells = celltype*ones(Ncells,1);


% Applied current to each cell
Iapps = 150 + 10*randn(size(cells));

% Synaptic kinetics
rise = 0.5;  fall = 3;

% Amount of time to run simulation before synapses are turned on
negT = 100;

% Parameters for the Ornstein-Uhlenbeck noise process
Di = 0;
De = 0;
Gavge = 0;
Gavgi = 0;

% Leak conductance for the cells
Gl = 0.01;

% Reversal potential of synapses
Erev = 0;

% Maximal conductance of synapses
Gmax = 10;



%---- Make a ring network----
syns = zeros(2*Ncells,4);
counter = 1;



% Make all clockwise synapses
for i = 0:length(cells)-2
    syns(counter,:) = [i, i+1, Gmax, Erev];
    counter = counter+1;
end
syns(counter,:) = [Ncells-1, 0, Gmax, Erev];
counter = counter + 1;



% Make all counterclockwise synapses
syns(counter,:) = [0, Ncells-1, Gmax, Erev];
counter = counter + 1;
for i = 1:length(cells)-1
    syns(counter,:) = [i, i-1, Gmax, Erev];
    counter = counter + 1;
end



fid = fopen(fn,'w+');
disp('#Begin Cells');
fprintf(fid,'#Begin Cells\n');


for i = 1:length(cells)
    string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT) ...
        ',De=', num2str(De), ',Di=', num2str(Di), ',taue=', '4', ',taui=', '10', ...
        ',Gl=' num2str(Gl)];
%      ',Gavge=', num2str(Gavge), ',Gavgi=', num2str(Gavgi)
    disp(string);
        fprintf(fid, '%s\n', string);
end;

disp('#End cells and begin synpases');
fprintf(fid,'\n\n#End cells and begin synapses\n');


for i=1:size(syns,1)
    
    
    string = ['>' num2str(syns(i,1)) ',' num2str(syns(i,2)) ',' num2str(syns(i,3)) ...
        ',' num2str(syns(i,4)) ',psgrise=', num2str(rise), ',psgfall=' ...
        num2str(fall)];
    
    disp(string);
        fprintf(fid, '%s\n', string);
end
fclose(fid);
