function r = myran(idum)

iset = 0;
gset = 0.0;
fac=0; rsq=0; v1=0; v1=0;

if (idum < 0)
    iset = 0;
end
if (iset == 0) 
    
    v1 = 2.0 * rand(1) - 1.0;
    v2 = 2.0 * rand(1) - 1.0;
    rsq = v1 * v1 + v2 * v2;
    
    while (rsq >= 1.0 || rsq == 0) 
        v1 = 2.0 * rand(1) - 1.0;
        v2 = 2.0 * rand(1) - 1.0;
        rsq = v1 * v1 + v2 * v2;
    end
    
    fac = sqrt (-2.0 * log(rsq) / rsq);
    gset = v1 * fac;
    iset = 1;
    r = v2 * fac;
else 
    iset = 0;
    r = gset;
end
