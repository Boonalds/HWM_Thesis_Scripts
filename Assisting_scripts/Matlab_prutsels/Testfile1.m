num_samples = 69;

for q = 1:ceil(num_samples/10)
    min_nr = (10*q-10)+1;
    max_nr = (10*q-10)+min(10,num_samples-(q*10-10));
    
    for i = min_nr:max_nr
        img_nr = i+1-min_nr;
        disp(img_nr);
    end

end
