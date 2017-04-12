rgnnames = {'forest1', 'forest2', 'forest2', 'forest3', 'forest3'};
yrs = [6,10,1,5,6,10,1,5,6,10];

for a = 1:5
    regionname = rgnnames(a);
    yr_idx = yrs(a*2-1):yrs(a*2);
    disp(regionname);
    disp(yr_idx);
end