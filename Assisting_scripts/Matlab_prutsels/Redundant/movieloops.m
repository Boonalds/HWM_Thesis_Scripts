m_i = 1:4;
d_i = 1:31;

t=0;
tot = length(m_i)*length(d_i);

for m = 1:length(m_i);
    for d = 1:length(d_i);
        make_msg_hrv_movie('landes',1,m_i(m),d_i(d));
        t=t+1;
        pr = ['Progress: ', num2str((t/tot)*100), '% completed.'];
        disp(pr);
    end
end
