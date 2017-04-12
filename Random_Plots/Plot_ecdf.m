years = {'2004';'2005';'2006';'2007';'2008';'2009';'2010';'2011';'2012';'2013'};
days = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';...
    '13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';...
    '25';'26';'27';'28';'29';'30';'31'};
hours  = {'0600';'0615';'0630';'0645';'0700';'0715';'0730';'0745';...
    '0800';'0815';'0830';'0845';'0900';'0915';'0930';'0945';...
    '1000';'1015';'1030';'1045';'1100';'1115';'1130';'1145';...
    '1200';'1215';'1230';'1245';'1300';'1315';'1330';'1345';...
    '1400';'1415';'1430';'1445';'1500';'1515';'1530';'1545';...
    '1600';'1615';'1630';'1645';'1700';'1715';'1730';'1745'};
months = {'05';'06';'07';'08'};
disk = 'D';

daysp{1} = 1:10;
daysp{2} = 11:20;
daysp{3} = 21:31;

idx_region_r = 220:416;
idx_region_c = 69:186;

yr_idx = 1:5;
m = 2;
dec = 2;
h = 21;


ch12 = [];
for yr = 1:length(yr_idx);
    for d = daysp{dec}
        for hh = h:h+3
            filename = [disk, ':\Thesis\Data\ch12\' years{yr_idx(yr)} '\' months{m} '\' ...
                years{yr_idx(yr)} months{m} days{d} hours{hh} '.gra'];
            if exist(filename, 'file') == 2
                fileID = fopen(filename,'r','l');
                A = fread(fileID,inf,'int16=>int16');
                fclose(fileID);
                if size(A,1) == 183480
                    ch12 = cat(3,ch12,reshape(A,440,417));
                else
                    ch12 = cat(3,ch12,nan(440,417));
                    disp(['Corrupt image: ' filename]);
                end
            else
                ch12 = cat(3,ch12,nan(440,417));
            end
        end
    end
end
ch12sel = ch12(idx_region_r,idx_region_c,:);

x = 155; 
y =70;
[ydata,xdata] = ecdf(squeeze(ch12sel(x,y,:)));
% xdata(xdata > 280) = 0;

figure()
plot(xdata,ydata);

xlabel('Reflectance value (-)') % x-axis label
ylabel('F(x) (-)') % y-axis label
