function plotnet()
clear; clc; close all; plotpos()

fid = fopen('nets/sm.net');
numcells = 0;
numsyn = 0;
conn = [];

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    
    if (isempty(tline)), continue, end
    
    if (tline(1) == '@')
        tline = tline(2:end);
        res = strsplit(',', tline);
        
        numcells = numcells + 1;
    end
    
    if (tline(1) == '>')
        tline = tline(2:end);
        res = strsplit(',', tline);
        conn = [conn; str2double(res{1}), str2double(res{2}), str2double(res{3}), str2double(res{4})];
        
        numsyn = numsyn + 1;
    end
end
fclose(fid);


% adjust indecies from 0 - n   ->   1 - (n+1)  for matlab indexing
conn(:,1) = conn(:,1) + 1;
conn(:,2) = conn(:,2) + 1;


allcells=0:numcells;
postCells = intersect(allcells, conn(:,2)); % >=1 postsynaptic connection
preCells = intersect(allcells, conn(:,1));
Npre = min(postCells);
Npost  = numcells-Npre;

% add an extra cell here to make sure we get right number of points
theta1 = linspace(0, 2*pi, numcells+1);
theta1 = theta1(1:end-1);
length(theta1)
theta2 = linspace(0, 2*pi, numcells);
theta2 = theta2(1:end-1);
theta = [theta1 theta2];

rad1 = (1/(theta1(2)-theta1(1)))/(1/(theta2(2)-theta2(1)));

rho1 = rad1*ones(1,Npre);
rho2 = ones(1,Npost);
rho = [rho1 rho2];

% convert to cartesian coords
xmid1 = -1;  %-1.5
ymid1 = 0;
xmid2 = 1;
ymid2 = 0;

xmid = [xmid1*ones(size(rho1)) xmid2*ones(size(rho2))];
ymid = [ymid1*ones(size(rho1)) ymid2*ones(size(rho2))];

% x = rho .* cos(theta);
% y = rho .* sin(theta);
x = cos(theta1);
y = sin(theta1);

plot(x, y, 'k.');
% plot(x+xmid, y+ymid, 'k.');
set(gcf, 'Color', [0.95 0.95 0.95]);
hold on;
axis image;
% xlim([-1.2 1.2])
% ylim([-1.2 1.2])
myylim = get(gca, 'YLim');
myxlim = get(gca, 'XLim');
myylim = myylim .* 1.2;
myxlim = myxlim .* 1.2;
xlim(myxlim); ylim(myylim);
% axis off;

maxweight = max(conn(:,3));
minweight = min(conn(:,3));

% plot syns
for i = 1:size(conn, 1)
    c = conn(i,1:2)
    sign = (conn(i,4)>-40) - (conn(i,4)<-40);
    weight = conn(i,3);

    % draw normal connections
    line([x(c(1)) x(c(2))], [y(c(1)) y(c(2))]);
    
    % connections with width proportional to the order they were drawn in
    %line([x(c(1)) x(c(2))], [y(c(1)) y(c(2))], 'LineWidth',conn(i,1)/numcells*3+1);
       
    
%     x0 = x(c(1))+xmid(c(1)); x1 = x(c(2))+xmid(c(2));
%     y0 = y(c(1))+ymid(c(1)); y1 = y(c(2))+ymid(c(2));
%     
%     
%     lfo = 0.2;  %Fraction of outgoing lines to plot
%     lfi = 0.2;
%     
%     lw = 0.1 + 2*(weight-minweight)/(maxweight-minweight);
%     if isnan(lw)
%         lw = minweight;
%     end
%     
%     % pre synaptic connections (eg. outgoing)
%     line([x0 ((1-lfo)*x0 + lfo*x1)], [y0 ((1-lfo)*y0 + lfo*y1)], 'Color','k', 'LineWidth',lw);
%     %line([x0 ((1-lf)*x0 + lf*x1)], [y0 ((1-lf)*y0 + lf*y1)], 'Color','r');
%     
%     % post synaptic connections (eg. incoming)
%     color = 'y';
%     if (sign==1)
%         color = 'r';
%     end
%     if (sign==-1)
%         color = 'b';
%     end
%     line([x1 ((1-lfi)*x1 + lfi*x0)], [y1 ((1-lfi)*y1 + lfi*y0)], 'Color',color, 'LineWidth',lw);
end

hold off;


% conmat = zeros(numcells, numcells);
% for i=1:numsyn
%     conmat(conn(i,1)+1, conn(i,2)+1) = 1;
% end
% 
% figure
% hist(sum(conmat, 2),10)

function parts = strsplit(splitstr, str, option)
%STRSPLIT Split string into pieces.
%
%   STRSPLIT(SPLITSTR, STR, OPTION) splits the string STR at every occurrence
%   of SPLITSTR and returns the result as a cell array of strings.  By default,
%   SPLITSTR is not included in the output.
%
%   STRSPLIT(SPLITSTR, STR, OPTION) can be used to control how SPLITSTR is
%   included in the output.  If OPTION is 'include', SPLITSTR will be included
%   as a separate string.  If OPTION is 'append', SPLITSTR will be appended to
%   each output string, as if the input string was split at the position right
%   after the occurrence SPLITSTR.  If OPTION is 'omit', SPLITSTR will not be
%   included in the output.

   nargsin = nargin;
   error(nargchk(2, 3, nargsin));
   if nargsin < 3
      option = 'omit';
   else
      option = lower(option);
   end

   splitlen = length(splitstr);
   parts = {};

   while 1

      k = strfind(str, splitstr);
      if isempty(k)
         parts{end+1} = str;
         break
      end

      switch option
         case 'include'
            parts(end+1:end+2) = {str(1:k(1)-1), splitstr};
         case 'append'
            parts{end+1} = str(1 : k(1)+splitlen-1);
         case 'omit'
            parts{end+1} = str(1 : k(1)-1);
         otherwise
            error(['Invalid option string -- ', option]);
      end


      str = str(k(1)+splitlen : end);

   end
   
   function plotpos()
    set(0, 'DefaultFigureUnits', 'Normalized');
    set(0, 'DefaultFigurePosition', [.05, .05, .9, .9]); % Whole Screen
    set(0, 'DefaultLineMarkerSize',40);
    set(0, 'DefaultAxesFontSize',18);
    set(0, 'DefaultLineLineWidth',2);
