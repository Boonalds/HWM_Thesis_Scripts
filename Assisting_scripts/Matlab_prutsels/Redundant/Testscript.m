j = 80;
for i = 1:size(clouds_hrv,1)
    if clouds_hrv(i,j,1) >= landeslims.forestbox.latlim(2)
        display('in forest latittude')
        disp(i)
    else
        display('buiten forest region')
    end
end


