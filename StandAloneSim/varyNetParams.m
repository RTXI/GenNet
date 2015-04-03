function varyNetParams()
clear; clc; close all;
drive = '/home/ndl/';
plotpos('w');

parent = fullfile(drive, 'DATA');
fn = makefilename();

%Cell Types
%0: E 
%1: I
%2: O
%3: Ghost
%4: Izhikevich tonic spiking
%5: Izhikevich Class 1 excitable
%6: Wang Buzsaki
%7: OLM
%8: Mainen-Sejnowski based pyramidal cell
%9: Golomb-Hansel FS cell
%10: LIF (excitatory params)
%11: LIF (inhibitory params)

Eexc = 0;
Einh = -65;
% GEI = 300;     pctEI = 0;  %variability in connection strengths (both total and individual)
% GIE = 3750;    pctIE =0;

pr = 0.75;
if (0)
%     GEI = 160/pr;     pctEI = 0;  %variability in connection strengths (both total and individual)
%     GIE = 160/pr;    pctIE = 0;
%     
%     GII = 32/pr;  pctII = 0;
% %     GEE = 22.5/pr;   pctEE = 0;
%     GEE = 4.5/pr;   pctEE = 0;
%     
%     Nexc = 200;     probEI = .4;      probEE = .15;
%     Ninh = 40;     probIE = .4;      probII = .4;
    
    
%     GEI = 350;     pctEI = 0;  %variability in connection strengths (both total and individual)
%     GIE = 1275;    pctIE = 0;
%     
%     GII = 5;  pctII = 5;
%     GEE = 2.5;   pctEE = 5;
%     
%     Nexc = 100;     probEI = .4;      probEE = .1;
%     Ninh = 40;     probIE = .4;      probII = .1;










    
%     cells = [10*ones(1, Nexc) 11*ones(1, Ninh)];
%     
%     Iapps(1:Nexc)           = 200 + 15*rand(1, Nexc); % RS LIF  
%     Iapps(Nexc+1:Nexc+Ninh) = 165 + 150*rand(1, Ninh);  %FS LIF
    
    
    
    
    
    
    GEI = 250/pr;     pctEI = 0;  %variability in connection strengths (both total and individual)
    GIE = 300/pr;    pctIE = 0;
    
    GII = 32/pr;  pctII = 0;
    GEE = 5/pr;   pctEE = 0;
    
    Nexc = 200;     probEI = .4;      probEE = .1;
    Ninh = 40;     probIE = .4;      probII = .4;


    cells = [12*ones(1, Nexc) 11*ones(1, Ninh)];
    
    Iapps(1:Nexc)           = 100 + 20*rand(1, Nexc); % RS LIF  
    Iapps(Nexc+1:Nexc+Ninh) = 150 + 150*rand(1, Ninh);  %FS LIF
    
    
    
    
    
    
    
    
    
    Gl(1:Nexc) = 1/60;
    Gl(Nexc+1:Nexc+Ninh) = 1/40;   
    
    
else
%     GEI = 200;     pctEI = 0;  %variability in connection strengths (both total and individual)
%     GIE = 700;    pctIE = 0;
%     
%     GII = 5;  pctII = 5;
%     GEE = 2.5;   pctEE = 5;
%     
%     
%     
%     Nexc = 30;     probEI = .4;      probEE = .1;
%     Ninh = 20;     probIE = .4;      probII = .1;
%     
%     cells = [8*ones(1, Nexc) 9*ones(1, Ninh)];
%     
%     Iapps(1:Nexc)           = 125 + 25*rand(1, Nexc); % RS
%     Iapps(Nexc+1:Nexc+Ninh) = -225 + 250*rand(1, Ninh);  %FS 
%     
%     Gl(1:Nexc) = .024;
%     Gl(Nexc+1:Nexc+Ninh) = 1/100;
    
    
    GEI = 250/pr;     pctEI = 75;  %variability in connection strengths (both total and individual)
    GIE = 300/pr;    pctIE = 0;
    
    GII = 32/pr;  pctII = 0;
    GEE = 5/pr;   pctEE = 0;
    
    Nexc = 200;     probEI = .4;      probEE = .05;
    Ninh = 40;     probIE = .4;      probII = .4;

    cells = [8*ones(1, Nexc) 9*ones(1, Ninh)];   
 
    
    Iapps(1:Nexc)           = 200 + 25*rand(1, Nexc); % RS
    Iapps(Nexc+1:Nexc+Ninh) = -50 + 30*rand(1, Ninh);  %FS 
    
    
    Gl(1:Nexc) = .024;
    Gl(Nexc+1:Nexc+Ninh) = 0.01;
    
 %   Gl(1:Nexc) = 0.02
    
end


% Applied currents
% RS: -25 (slow spiking)
% FS: -10 (near threshold)



%Iapps(1:Nexc)           = 650 + 200*rand(1, Nexc); % RS
%Iapps(1:Nexc)           = -45 + 60*rand(1, Nexc); %FS
%Iapps(Nexc+1:Nexc+Ninh) = -60 + 50*rand(1, Ninh);  %FS
%Iapps(Nexc+1:Nexc+Ninh) = -150 + 100*rand(1, Ninh); %FS new

%Iapps(Nexc+1:Nexc+Ninh) = -150 + 80*rand(1, Ninh);





totalPSGIE = GIE + (pctIE/100).*GIE.*(2*rand(1, Nexc)-1);
totalPSGEI = GEI + (pctEI/100).*GEI.*(2*rand(1, Ninh)-1);

totalPSGEE = GEE + (pctEE/100).*GEE.*(2*rand(1, Nexc)-1);
totalPSGII = GII + (pctII/100).*GII.*(2*rand(1, Ninh)-1);

syns = [];

for i = 0:Nexc-1
    totalG = 0;
    inds = [];
    for j = 0:Nexc-1
        if (i~=j && rand(1) < probEE)
            G = GEE + GEE.*pctEE/100*(2*rand(1)-1);
            syns(end+1, :) = [j, i, G, Eexc];
            totalG = totalG+G;
            inds(end+1) = size(syns,1);
        end
    end
    if(~isempty(inds))
        syns(inds, 3) = syns(inds,3).*(totalPSGEE(i+1)./totalG);
    end
end


for i = Nexc:Nexc+Ninh-1
    totalG = 0;
    inds = [];
    for j = Nexc:Nexc+Ninh-1
        if (i~=j && rand(1) < probII)
            G = GII + GII.*pctII/100*(2*rand(1)-1);
            syns(end+1, :) = [j, i, G, Einh];
            totalG = totalG+G;
            inds(end+1) = size(syns,1);
        end
    end
    
    if(~isempty(inds))
        syns(inds, 3) = syns(inds,3).*(totalPSGII(i-Nexc+1)./totalG);
    end
end




for i = Nexc:Nexc+Ninh-1
   totalG = 0;
   inds = [];
   for j = 0:Nexc-1
       
       if (i~=j && rand(1) < probEI)
           
           G = GEI + GEI.*pctEI/100*(2*rand(1)-1);
           syns(end+1, :) = [j, i, G, Eexc];
           totalG = totalG+G;
           inds(end+1) = size(syns,1);
       end
       
   end
   if(~isempty(inds))
       syns(inds, 3) = syns(inds,3).*(totalPSGEI(i-Nexc+1)./totalG);
   end
end



for i = 0:Nexc-1
   totalG = 0;
   inds = [];
   for j = Nexc:Nexc+Ninh-1
       if (i~=j && rand(1) < probIE)
           G = GIE + GIE.*pctIE/100*(2*rand(1)-1);
           syns(end+1, :) = [j, i, G, Einh];
           totalG = totalG+G;
           inds(end+1) = size(syns,1);
       end
       
   end
   if(~isempty(inds))
       syns(inds, 3) = syns(inds,3).*(totalPSGIE(i+1)./totalG);
   end
end

negT = 100+100*rand(size(cells));

%diffI = -50:25:100;
%diffI = linspace(0, 300, 10);

%FACT = 0.2:0.4:3.0;
%FACT = 1.0*ones(size(diffI));

FACT = 0.2:0.4:3.0;

diffI = 0*ones(size(FACT));

datfile = fullfile(parent, [fn '.dat']);
infofile = fullfile(parent, [fn '.info']);

sims = length(FACT);

cols = ceil(sqrt(sims));
rows = ceil(sims/cols);

[junk IX] = sort(Iapps(1:Nexc));

medCell = IX(round(Nexc/2));

Iinds = find(syns(:,4)<-30);
for i = 1:sims
    
    
    
    S = syns;
    
     
     
    
    
    G = Gl;
    %G(1:Nexc) = Gl(1:Nexc).*FACT(i);    
    %G(Nexc+1:Nexc+Ninh) = Gl(Nexc+1:Nexc+Ninh).*FACT(i);    
    
    Q = G./Gl;
    
  %  I = FindIapp(5, 0.25, cells(medCell), Iapps(medCell), G(medCell), datfile, Q(medCell));
    
 %   diffI(i) = I-Iapps(medCell);

    I = Iapps;
    I(1:Nexc) = I(1:Nexc)+diffI(i);
   
    WriteNetFile('TwoPys.net', cells, I, S, negT, G, Q);
   
    !LD_LIBRARY_PATH=/usr/lib; ./gn -p TwoPys.net
    disp(['>>>>>>>>>>>>START SIM ' num2str(i) ' of ' num2str(sims) ' <<<<<<<<<<<<<<<']);
    
    
    fid = fopen(infofile,'r');
    
    types = [];
    numcols = fscanf (fid, 'numcols: %d');
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        
        if (isempty(tline)), continue, end
        
        if (tline(1) == '@')
            tline = tline(2:end);
            res = strsplit(',', tline);
            
            types(end+1) = str2num(res{1});
        end
    end
    
    fclose(fid);
    
    exc = [find(types==8) find(types==10) find(types==12)];
    inh = [find(types==9) find(types==11)];
    
    Pts=inf;
    fid = fopen(datfile);
    a = fread(fid,[numcols,Pts], 'double');
    fclose(fid);
    a=a';
    
    time = a(:,1);
    data = a(:,2:end)*1000;
    clear a;

    [sm, smw, smwsm, Einfo(i)] = OscStats(time, data(:, exc));
    [sm, smw, smwsm, Iinfo(i)] = OscStats(time, data(:, inh));
    [sm, smw, smwsm, info(i)] = OscStats(time, data(:, [exc inh]));
    
    fs = 1./mean(diff(time));

    w = linspace(0,fs, length(time)+1)';
    w = w(1:end-1);

    figure(1); subplot(2, 6, 1:6); hold on;
    plot(w, smwsm, 'Color', col(i), 'LineWidth', 2);
    xlim([0 100]);
    
    if (legend)
        str = get(legend, 'String');
        str{end+1} = ['<Iapp_e> = ' num2str(mean(I(1:Nexc)))];
    else
        str = ['<Iapp_e> = ' num2str(mean(I(1:Nexc)))];
    end
    legend(str);
    
    pt1(i) = smwsm(info(i).incind);
    pt2(i) = smwsm(info(i).decind);
 
    figure(2);
    subplot(rows, cols, i);
    spkinds = spike_detect(reshape(fliplr(data), 1,size(data,1)*(Ninh+Nexc)), 10);
    rasterplot(spkinds, Ninh+Nexc, length(time), gca, fs);
    xlim([0 time(end)]);
  
end


figure(1);
set(legend, 'FontSize', 10);

for i = 1:sims
    mv(i) = info(i).maxval;
    hw(i) = info(i).halfwid;
    er(i) = info(i).energy_ratio;
    fr(i) = info(i).maxfreq;
    cc(i) = info(i).R(1,2);
    rt(i) = Einfo(i).rate;
    plot(w(info(i).incind), pt1(i), 'gx');
    plot(w(info(i).decind), pt2(i), 'gx');
end

x = FACT;


subplot(2, 6, 7);
plot(x, mv, '-bo');
ylabel('Max value');

subplot(2, 6, 8);
plot(x, hw, '-ro');
ylabel('Half width');

subplot(2, 6, 9);
plot(x, er, '-ko');
ylabel('Energy ratio');

subplot(2, 6, 10);
plot(x, fr, '-go');
ylabel('Osc freq');

subplot(2, 6, 11);
plot(x, cc, '-mo');
ylabel('Corr Coef');

subplot(2, 6, 12);
plot(x, rt, '-co');
ylabel('Avg Exc Rate');




function I = FindIapp(R0, dR, cell, I0, G, datfile, Q)

DONE = 0;
I = I0;
syns = [];
i = 0;
K=50;
N=10;
while ~DONE
    i = i+1;
    
    WriteNetFile('TwoPys.net', cell*ones(N,1), I*ones(N,1), syns, 250*ones(N,1), G*ones(N,1), Q*ones(N,1));
    
    
    !LD_LIBRARY_PATH=/usr/lib; ./gn -p TwoPys.net\
      
    Pts=inf;
    fid = fopen(datfile);
    a = fread(fid,[N+1,Pts], 'double');
    fclose(fid);
    a=a';
    
    Vs = a(:,2:end)*1000;
    
    Vs = reshape(fliplr(Vs), 1,size(Vs,1)*N);
    

    time = a(:,1);
    clear a;
    
    spkinds = spike_detect(Vs, 10);
    rate = length(spkinds)./time(end)/N;
    
    diffR = rate-R0;
    
    if (abs(diffR)<dR)
        DONE = 1;
    else
        dI = -(diffR/R0)*K;
        disp(['dI: ' num2str(dI)]);
        I = I + dI;
    end
    
    if (i>10)
        K = K/2;
        i=0;
    end
        
end
disp(['Ifinal: ' num2str(I)]);
disp(['Rate: ' num2str(rate)]);
    




function WriteNetFile(fn, cells, Iapps, syns, negT, Gl, Q)



fid = fopen(fn,'w+');
fprintf(fid,'#Begin Cells\n');

for i=1:length(cells)
     if (cells(i) == 8)
        De = 0.00015;     Di = 0.00001; 
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', num2str(De*Q(i)), ',Di=', num2str(Di*Q(i)), ',taue=', '2', ',taui=', '8', ',Gl=', num2str(Gl(i))];
    end
    if (cells(i) == 9)
        
        De = 0.000005;     Di = 0.000002; 
        
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', num2str(De), ',Di=', num2str(Di), ',taue=', '2', ',taui=', '8', ',Gl=', num2str(Gl(i))];
    end
    if (cells(i) == 10)
        De = 0.00002;
        Di = 0.00001;
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', num2str(De*Q(i)), ',Di=', num2str(Di*Q(i)), ',taue=', '2', ',taui=', '8', ',Gl=', num2str(Gl(i))];
    end
    if (cells(i) == 11)
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', '0.00001', ',Di=', '0.000004', ',taue=', '2', ',taui=', '8', ',Gl=', num2str(Gl(i))];
    end
    if (cells(i) == 12)
        De = 0.00001;
        Di = 0.000004;
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', num2str(De*Q(i)), ',Di=', num2str(Di*Q(i)), ',taue=', '2', ',taui=', '8', ',Gl=', num2str(Gl(i))];
    end
    fprintf(fid, '%s\n', string);
end;


fprintf(fid,'\n\n#End Cells and Begin Synapses\n');
for i=1:size(syns,1)
    if (syns(i,4) < -30)
        string = ['>' num2str(syns(i,1)) ',' num2str(syns(i,2)) ',' num2str(syns(i,3)) ...
             ',' num2str(syns(i,4)) ',psgrise=1,psgfall=6'];
    else
        string = ['>' num2str(syns(i,1)) ',' num2str(syns(i,2)) ',' num2str(syns(i,3)) ...
             ',' num2str(syns(i,4)) ',psgrise=0.5,psgfall=3'];
    end
    fprintf(fid, '%s\n', string);
end
fclose(fid);






function str = makefilename()

% generate current time stamp
c = clock;
months = ['Jan'; 'Feb'; 'Mar'; 'Apr'; 'May'; 'Jun'; 'Jul'; 'Aug'; 'Sep'; 'Oct'; 'Nov'; 'Dec'];
str = 'GenNet_';
str = [str, num2str(months(c(2),:)), '_'];

% prepend a '0' if needed
dy = c(3);
if (dy < 10)
    str = [str, '0', num2str(c(3))];
else
    str = [str, num2str(c(3))];
end
str = [str, '_'];

% prepend a '0' if needed
yr = c(1) - 2000; 
if (yr < 10) 
    str = [str, '0', num2str(yr)];
else
    str = [str, num2str(yr)];
end
str = [str, '_A1'];