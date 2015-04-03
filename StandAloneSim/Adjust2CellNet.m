function Adjust2CellNet()
plotpos('b');
clear; clc; close all;
% Construct Net files.

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
%12: Mainen-Sejnowski based pyramidal cell

Eexc = 0;
Einh = -65;
% GEI = 300;     pctEI = 0;  %variability in connection strengths (both total and individual)
% GIE = 3750;    pctIE =0;

pr = 0.75;
if (1)
    
    
%  Scanziani params   
%     GEI = 160/pr;     pctEI = 0;  %variability in connection strengths (both total and individual)
%     GIE = 160/pr;    pctIE = 0;
%     
%     GII = 32/pr;  pctII = 0;
%     GEE = 22.5/pr;   pctEE = 0;
%     
%     Nexc = 200;     probEI = .4;      probEE = .15;
%     Ninh = 40;     probIE = .4;      probII = .4;
     

%  Good params    
%     GEI = 250/pr;     pctEI = 0;  %variability in connection strengths (both total and individual)
%     GIE = 300/pr;    pctIE = 0;
%     
%     GII = 32/pr;  pctII = 0;
%     GEE = 5/pr;   pctEE = 0;
%     
%     Nexc = 200;     probEI = .4;      probEE = .1;
%     Ninh = 40;     probIE = .4;      probII = .4;

%     Iapps(1:Nexc)           = 225 + 15*rand(1, Nexc); % RS LIF  
%     Iapps(Nexc+1:Nexc+Ninh) = 165 + 150*rand(1, Ninh);  %FS LIF
    
    
    
%     GEI = 200;     pctEI = 0;  %variability in connection strengths (both total and individual)
%     GIE = 750;    pctIE = 0;
%     
%     GII = 75;  pctII = 0;
%     GEE = 20;   pctEE = 0;
%     
%     Nexc = 200;     probEI = .4;      probEE = .15;
%     Ninh = 40;     probIE = .4;      probII = .4;
    
    GEI = 250/pr;     pctEI = 0;  %variability in connection strengths (both total and individual)
    GIE = 300/pr;    pctIE = 0;
    
    GII = 32/pr;  pctII = 0;
    GEE = 5/pr;   pctEE = 0;
    
    Nexc = 60;     probEI = .4;      probEE = .1;
    Ninh = 20;     probIE = .4;      probII = .4;


    cells = [12*ones(1, Nexc) 12*ones(1, Ninh)];
    
    Iapps(1:Nexc)           = 250 + 20*rand(1, Nexc); 
    Iapps(Nexc+1:Nexc+Ninh) = 65 + 150*rand(1, Ninh); 
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   % Iapps(Nexc+1:Nexc+Ninh) = 0 + 150*rand(1, Ninh);  %FS LIF
    Gl(1:Nexc) = 1/60;
    Gl(Nexc+1:Nexc+Ninh) = 1/40;   
    
    
else
%     GEI = 350;     pctEI = 0;  %variability in connection strengths (both total and individual)
%     GIE = 1275;    pctIE = 0;
%     
%     GII = 5;  pctII = 5;
%     GEE = 2.5;   pctEE = 5;
%     
%     Nexc = 90;     probEI = .4;      probEE = .1;
%     Ninh = 30;     probIE = .4;      probII = .1;
%     
%     cells = [8*ones(1, Nexc) 9*ones(1, Ninh)];
%     
%     Iapps(1:Nexc)           =125 + 75*rand(1, Nexc); % RS
%     Iapps(Nexc+1:Nexc+Ninh) = -125 + 125*rand(1, Ninh);  %FS 
    
    GEI = 200;     pctEI = 0;  %variability in connection strengths (both total and individual)
    GIE = 700;     pctIE = 0;
    
    GII = 5;  pctII = 5;
    GEE = 2.5;   pctEE = 5;
    
    Nexc = 90;     probEI = .4;      probEE = .1;
    Ninh = 30;     probIE = .4;      probII = .1;
    
    cells = [8*ones(1, Nexc) 9*ones(1, Ninh)];
    
    
    
        
    
    
    
    GEI = 200*0.4/pr;     pctEI = 75;  %variability in connection strengths (both total and individual)
    GIE = 500/pr;    pctIE = 0;
    
    GII = 32/pr;  pctII = 0;
    GEE = 5/pr;   pctEE = 0;
    
    Nexc = 200;     probEI = .4;      probEE = .1;
    Ninh = 40;     probIE = .4;      probII = .4;

    cells = [8*ones(1, Nexc) 9*ones(1, Ninh)];   
    
    Gl(1:Nexc) = 0.024;
    Gl(Nexc+1:Nexc+Ninh) = 0.01;   
    
    Iapps(1:Nexc)           = 225 + 25*rand(1, Nexc); % RS
    Iapps(Nexc+1:Nexc+Ninh) = -50 + 30*rand(1, Ninh);  %FS 
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
            syns(end+1, :) = [j, i, G, -55];
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
           syns(end+1, :) = [j, i, G, -75];
           totalG = totalG+G;
           inds(end+1) = size(syns,1);
       end
       
   end
   if(~isempty(inds))
       syns(inds, 3) = syns(inds,3).*(totalPSGIE(i+1)./totalG);
   end
end


FactE = 1;
FactI = 1;

Gl(1:Nexc) = Gl(1:Nexc).*FactE;
Gl(Nexc+1:Nexc+Ninh) = Gl(Nexc+1:Nexc+Ninh).*FactI;

Q(1:Nexc) = FactE;
Q(Nexc+1:Nexc+Ninh) = FactI;



if (0)
    [junk IX] = sort(Iapps(1:Nexc));
    
    medCell = IX(round(Nexc/2));
    I = FindIapp(4, 0.25, cells(medCell), Iapps(medCell), G(medCell), datfile, Q(medCell));
    
    diffI = I-Iapps(medCell);
    
    Iapps = Iapps + diffI;
end

disp(['Cells: ' num2str(length(cells))]);
disp(['Synapses: ' num2str(size(syns,1))]);

negT = 500+250*rand(size(cells));
WriteNetFile('TwoPys.net', cells, Iapps, syns, negT, Gl);

%string = ['!LD_LIBRARY_PATH=/usr/lib; ./gn ' num2str(5) '-p TwoPys.net'];
 
 !LD_LIBRARY_PATH=/usr/lib; ./gn -p TwoPys.net
 
%system(string);

disp('>>>>>>>>>>>>DONE SIM<<<<<<<<<<<<<<<');

GenGUI();








function WriteNetFile(fn, cells, Iapps, syns, negT, Gl, Q)
fid = fopen(fn,'w+');
fprintf(fid,'#Begin Cells\n');

for i=1:length(cells)
     if (cells(i) == 8)
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', '0.00015', ',Di=', '0.00001', ',taue=', '2', ',taui=', '8', ',Gl=0.024'];
    end
    if (cells(i) == 9)
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', '0.000005', ',Di=', '0.000002', ',taue=', '2', ',taui=', '8', ',Gl=0.01'];
    end
    if (cells(i) == 10)
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', '0.00002', ',Di=', '0.00001', ',taue=', '2', ',taui=', '8', ',Gl=', num2str(Gl(i))];
    end
    if (cells(i) == 11)
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', '0.00001', ',Di=', '0.000004', ',taue=', '2', ',taui=', '8', ',Gl=', num2str(Gl(i))];
    end
    if (cells(i) == 12)
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', '0.00003', ',Di=', '0.00001', ',taue=', '2', ',taui=', '8', ',Gl=', num2str(Gl(i))];
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





