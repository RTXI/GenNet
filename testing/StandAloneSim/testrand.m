
res = []

for i=1:1000
r = rand(2,1);

x = sqrt(-2 * log(r(1))) * cos(2 * pi * r(2));
y = sqrt(-2 * log(r(1))) * sin(2 * pi * r(2));

res(end+1) = x;
res(end+1) = y;

end

hist(res,100)