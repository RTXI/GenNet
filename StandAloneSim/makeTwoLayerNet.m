function makeTwoLayerNet()
clear; clc;
% Construct Net files.
Eexc = 0;
Einh = -80;

N1=30;
N2=30;
%Cell Types
%0: E           1: I            2: O
%3: Ghost       4: IZtonic      5: Noisy E
%6: WB          7: OLM          8: IZClass1

cells = 4*ones(1,N1+N2);

% NOTE: 2.65 Iapp = ~5Hz for #8
Imin1 = 5.65;
Imax1 = 10.65;

Imin2 = 2;
Imax2 = 4;

maxNT1 = 10;
maxNT2 = 10; %Negative time

negT = [maxNT1*rand(1, N1) maxNT2*rand(1, N2)];
Iapps = [Imin1 + (Imax1-Imin1)*rand(1,N1) Imin2 + (Imax2-Imin2)*rand(1,N2)];


% DEFINE SYNAPSES
syns=[];

%Feedforward synapses
ge=1.5;    gi=1.5;
pe=0.2;   pi=0.2;

preCells = 1:N1;
postCells = N1+1:N2+N1;

temp = makeSyns(preCells, postCells, pe, pi);
which_e = temp(:,3)>0;
which_i = temp(:,3)<0;

temp(:,4) = Einh*(which_i) +  Eexc*(which_e);
etotal = sum(which_e);  itotal = sum(which_i);
temp(:,3) = abs(temp(:,3));
temp(which_e,3) = temp(which_e,3)*(ge/etotal);
temp(which_i,3) = temp(which_i,3)*(gi/itotal);

syns=[syns; temp];


%Recurrent Synapses
ge=.1;    gi=0.1;
pe=0.0;   pi=0.1;

preCells = N1+1:N2+N1;
postCells = N1+1:N2+N1;

temp = makeSyns(preCells, postCells, pe, pi);
which_e = temp(:,3)>0;
which_i = temp(:,3)<0;

temp(:,4) = Einh*(which_i) +  Eexc*(which_e); % Set reversals

etotal = sum(which_e);  itotal = sum(which_i);

temp(:,3) = abs(temp(:,3)); % Set appropriate weights
temp(which_e,3) = temp(which_e,3)*(ge/etotal);
temp(which_i,3) = temp(which_i,3)*(gi/itotal);

syns=[syns; temp];
syns(:,3) = syns(:,3).*(1+((rand(size(syns(:,3)))-0.5))/2);

WriteNetFile('TwoLayer.net', cells, Iapps, syns, N1, negT);

%!gn TwoLayer.net


function WriteNetFile(fn, cells, Iapps, syns, N1, negT)
fid = fopen(fn,'w+');
fprintf(fid,'#Begin Cells\n');
for i=1:length(cells)
    string = ['@' num2str(cells(i)) ',' num2str(Iapps(i))];
    string = [string ',negT=' num2str(negT(i))];
    fprintf(fid, '%s\n', string);

end;
fprintf(fid,'\n\n#End Cells and Begin Synapses\n');
for i=1:size(syns,1)
    string = ['>' num2str(syns(i,1)) ',' num2str(syns(i,2)) ',' ...
        num2str(syns(i,3)) ',' num2str(syns(i,4)) ',psgrise=1,psgfall=8'];
    fprintf(fid, '%s\n', string);
end
fclose(fid);



function syns = makeSyns(preCells, postCells, pe, pi)
syns=[];
for i=(preCells-1)
    for j=(postCells-1)
        rnum = rand(1,2);
        if (rnum(1)<pe)
            syns = [syns; i j 1];
        end
        if (rnum(2)<pi)
            syns = [syns; i j -1];
        end
        
    end
end







