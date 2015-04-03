function GenNetFI()


clear; clc;
drive = '/home/ndl/';
addpath(fullfile(drive, 'H', 'Mike', 'MyFunLib'))
plotpos('w');

% Construct Net files.

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
%12: aeLIF
 
cells = 9;
syns  = [];
negT  = zeros(size(cells));

Iapps = 0:20:300;
Noise = 100;
Gl = 0.024;


datfile = fullfile(parent, [fn '.dat']);

allocate = 0;
i = 0;
for I = Iapps
    pause(0.1);
    i = i+1;
    
    WriteNetFile('TwoPys.net', cells, I, syns, negT, Gl, Noise);
    %WriteNetFile('TwoPys.net', cells, 200, syns, negT, Iapps(i), Noise);
    !LD_LIBRARY_PATH=/usr/lib; ./gn -p TwoPys.net\
    disp(['Finished step ' num2str(i) ' of ' num2str(length(Iapps))]);
    Pts=inf;
    fid = fopen(datfile);
    a = fread(fid,[2,Pts], 'double');
    fclose(fid);
    a=a';
    
    Vs = a(:,2)*1000;
    
    if (~allocate)
        V = zeros(length(Vs), length(Iapps));
        V(:,1) = Vs;
        
        allocate = 1;
        time = a(:,1);
    end
    V(:,i) = Vs;
    clear a;
    clear Vs;
end
V(V>30) = 30;

% figure;
% hold on;
% for i = 1:size(V,2)
%     plot(time*1000, V(:,i));
% end

FI(time, V, Iapps);




function WriteNetFile(fn, cells, Iapps, syns, negT, Gl, Noise)
fid = fopen(fn,'w+');
fprintf(fid,'#Begin Cells\n');



for i=1:length(cells)
    if (cells(i) == 3)
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=0.0,Di=0.0,taue=', '2', ',taui=', '8', ',Gl=0.0167'];
    end

     if (cells(i) == 8)

        Di = 0.00001*1;
        De = 0.00015*1;
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)*(Q)) ',negT=' num2str(negT(i)) ...
            ',De=', num2str(De*Q), ',Di=', num2str(Di*Q), ',taue=', '2', ',taui=', '8', ',Gl=', num2str(Gl)];
    end
    if (cells(i) == 9)
        De = 0.000005.*Noise*.005;
        Di = 0.000002.*Noise*.005*0;
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', num2str(De), ',Di=', num2str(Di), ',taue=', '2', ',taui=', '8', ',Gl=' num2str(Gl)];
    end
    if (cells(i) == 10)
        De = 0.00002*0;
        Di = 0.00001*0;
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', num2str(De), ',Di=', num2str(Di), ',taue=', '2', ',taui=', '8', ',Gl=0.0167'];
    end
    if (cells(i) == 11)
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', '0.00001', ',Di=', '0.000004', ',taue=', '2', ',taui=', '8'];
    end
    if (cells(i) == 12)
        De = 0.000012*Noise*0.01;
        Di = 0.00001*Noise*0.0;
        string = ['@' num2str(cells(i)) ',' num2str(Iapps(i)) ',negT=' num2str(negT(i)) ...
            ',De=', num2str(De), ',Di=', num2str(Di), ',taue=', '2', ',taui=', '2', ',Gl=' num2str(Gl)];
    end

    fprintf(fid, '%s\n', string);    

end;

fclose(fid);





% Automatically create the date-based file name of sim results
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





function FI(t, vm, cur)
figure;

cur = cur;
fs = 1./mean(diff(t));
% convert to pA and mV
gap = round(0.3*fs);

len = t(end);


tempt = (1:(length(t)+gap)*length(cur))./fs;
res = zeros(int32(len),5);
Rm = [];
Tau = [];

for i = 1:length(cur)
    
    % calc start and end points of step

    one_step = vm(:, i);
   

    i1 = 1+(i-1)*(length(t)+gap);
   % i2 = i1+length(t)-1;
    
    % detect spikes and return indeces
    spkinds = spike_detect(one_step, 5);
  
  %  figure(100+i);
  %  plot(.0002*(1:length(one_step)), one_step); pause;
    % count spikes and find max current from this step
    spknum = 3;
    if (isempty(spkinds))
        %res(i,:) = [0 0 mean(cur(ind1:ind2))];
        res(i,:) = [0 0 cur(i) 0 0];

        if (abs(res(i,3))>5)
            Rm(end+1,1) = 1e3*(mean(one_step(round(end/2):end)) - one_step(1))/res(i,3);
             Rm(end,2) = res(i,3);
%             pol = sign(cur(i));
%             dv = diff(one_step);
%             dv = smooth(dv, 40, 20);
%             peak = find((pol.*dv(1:end-1)>0).*(pol.*dv(2:end)<0), 1, 'first')+1;
%             if isempty(peak)
%                 peak = length(dv);
%             end
            
            
            fit_time = 30; %ms
            peak = find(t>(fit_time)/1000, 1, 'first');
            
            params = [one_step(1) one_step(peak)-one_step(1) 0.02];
            options=optimset('Display', 'Off');

            actual = fminsearch(@ErrFun,params,options,t(1:peak), one_step(1:peak));
            subplot(2,4,1:4);
            hold on;
            plot([tempt(i1) tempt(i1+length(t))], [one_step(1) one_step(1)], 'k--', 'Linewidth', 1);
            plot([tempt(i1) tempt(i1+length(t))], [mean(one_step(round(end/2):end)) ...
                mean(one_step(round(end/2):end))], 'k--', 'Linewidth', 1);          
            
            plot(tempt(i1:i1+peak), actual(1) + actual(2).*(1-exp(-t(1:peak+1)./actual(3))), 'g.');
            
            Tau(end+1, :) = [actual(3)*1000, res(i,3)];
            
        end
    elseif (length(spkinds) < spknum)
        
            res(i,:) = [length(spkinds)./(len) length(spkinds)./(len) cur(i) ...
                        length(spkinds)./(len) length(spkinds)./(len)];
        
        if (abs(res(i,3))>5)
            
            Rm(end+1, 1) = 1e3*(mean(one_step) - one_step(1))/res(i,3);
            Rm(end, 2) = res(i,3);
            
        end
    else    
        res(i, :) = [length(spkinds)./(len) fs./median(diff(spkinds)) cur(i) ...
             fs./median(diff(spkinds(1:spknum))) fs./median(diff(spkinds(end-spknum+1:end)))];
    end;
   
end

if isempty(Rm)
    Rm = [1 1];
end
if isempty(Tau)
    Tau = [1 1];
end


%% plot
plotpos('w');

subplot(2,4,1:4); hold on;

for i = 1:length(cur)
    i1 = 1+(i-1)*(length(t)+gap);
    i2 = i1+length(t)-1;
    plot(tempt(i1:i2), vm(:,i), 'b');
end
clear tempt 
axis tight;


%plot(t, vm);
title(['Rm = ' num2str(mean(Rm(:,1))) ' +/- ' num2str(std(Rm(:,1))) ...
    ' MOhms'], 'interpreter', 'none'); ylabel('Voltage (mV)');
xlabel('Time (s)');

subplot(2,4,5);
plot(cur, 'bo-');
axis tight;
ylabel('Current (pA)');


subplot(2,4,6);
plot(Rm(:,2), Rm(:,1), 'r.-');
hold on;
plot(Tau(:,2), Tau(:,1), 'b.-');
ylim([0 max(200, max(Rm(:,1)))]);


legend('R_{in} (MOhms)', 'Tau (ms)', 'location', 'Best');
xlabel('Current (pA)');
%axis tight;

subplot(2,4,7);
plot(res(:,3), res(:,1), 'ro-',res(:,3), res(:,2), 'b.-'); axis tight;
legend('<rate>', 'Median ISI', 'Location', 'NorthWest');

hold off;
xlabel('Current (pA)');ylabel('Frequency (Hz)');
%title('Frequency averaged over a current step');

subplot(2,4,8);
plot(res(:,3), res(:,4), 'ro-', res(:,3), res(:,5), 'b.-'); axis tight;
legend(['First ' num2str(spknum) ' ISIs'], ['Last ' num2str(spknum) ' ISIs'], 'Location', 'NorthWest');

hold off;
xlabel('Current (pA)');ylabel('Frequency (Hz)');
%title('Frequency calculated from median ISI');









function error = ErrFun(params, t, v)
curve = params(1) + params(2).*(1-exp(-t./params(3)));
error = mean((curve-v).^2);



