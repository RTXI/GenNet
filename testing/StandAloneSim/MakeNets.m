function MakeNets()
% Construct Net files.
Eexc = 0;
Einh = -75;

Ncells=100;
%Cell Types
%0: E 
%1: I
%2: O
%3: Ghost
%4: Izhikevich
%5:

gdev=0.2;
p=0.5;

cells = 4*ones(1,Ncells);
Iapps = randn(1,Ncells)-0.5;

syns = SynProb(Ncells, p);
syns(:,3) = gdev*syns(:,3).*(rand(size(syns(:,3))));
syns(:,4) = Einh*(syns(:,3)<0) +  Eexc*(syns(:,3)>0);
syns(:,3) = abs(syns(:,3));

WriteNetFile('mattest.net', cells, Iapps, syns);




function WriteNetFile(fn, cells, Iapps, syns)
fid = fopen(fn,'w+');
fprintf(fid,'#Begin Cells\n');
for i=1:length(cells)
    string = ['@' num2str(cells(i)) ',' num2str(Iapps(i))];
    fprintf(fid, '%s\n', string);

end;

fprintf(fid,'\n\n#End Cells and Begin Synapses\n');
for i=1:size(syns,1)
    string = ['>' num2str(syns(i,1)) ',' num2str(syns(i,2)) ',' num2str(syns(i,3)) ',' num2str(syns(i,4))];
    fprintf(fid, '%s\n', string);
end
fclose(fid);



function syns = SynProb(Ncells, p)
syns = [];
for i=0:Ncells-1
    for j=0:Ncells-1
        rnum = rand(1);
        if (i~=j && rnum < p)
            syns = [syns; i j 1];
        end
    end
end







