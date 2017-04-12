%%%%%%%%%%%%%%%%%%   STEP A - Creating background albedo maps   %%%%%%%%%%
%%%%%% This script removes uses all the MSG images to create a background
%%%%%% albedo map for every hour, every decade of the months may till
%%%%%% august.


rgnnames = {'forest1', 'forest2', 'forest2', 'forest3', 'forest3'};
yrs = [6,10,1,5,6,10,1,5,6,10];

for a = 1:5
    regionname = rgnnames{a};
    yr_idx = yrs(a*2-1):yrs(a*2);
    
    disk = 'D';
    
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
    % monthsp = {'07';'07';'07';'08';'08';'08'};
    months = {'05';'06';'07';'08'};
    daysp{1} = 1:10;
    daysp{2} = 11:20;
    daysp{3} = 21:31;
    
    switch regionname
        case 'landes'
            % index for landes cutout
            idx_region_r = 220:416;
            idx_region_c = 69:186;
        case 'orleans'
            % index for orleans cutout
            idx_region_r = 40:233;
            idx_region_c = 274:382;
        case 'forest1'
            % index for additional forest1 cutout
            idx_region_r = 20:150;
            idx_region_c = 330:415;
        case 'forest2'
            % index for additional forest2 cutout
            idx_region_r = 130:240;
            idx_region_c = 250:310;
        case 'forest3'
            % index for additional forest3 cutout
            idx_region_r = 290:325;
            idx_region_c = 220:270;
        otherwise
            warning('Unknown regionname.')
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%   Define surface reflectance   %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    surfrefl = int16(zeros(length(months),3,12,length(idx_region_r),length(idx_region_c)));
    
    %read in data matrix and determine surface reflectance
    ts = 0;
    tt = length(months)*3*12;
    disp('Started constructing albedo map, this may take a while..');
    for m = 1:length(months)
        for dec = 1:3
            for h = 1:4:48
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
                for x = 1:length(idx_region_r)
                    for y = 1:length(idx_region_c)
                        [ydata,xdata] = ecdf(squeeze(ch12sel(x,y,:)));
                        xdata(xdata > 280) = 0;
                        slope = [diff(double(ydata))./diff(double(xdata)); 0];
                        slope_av = movav(slope,11);
                        slope_av(isfinite(slope_av)==0) = 0;
                        [tmp,I] = max(slope_av);
                        surfrefl(m,dec,(h+3)/4,x,y) = xdata(I);
                        %                 dslope_av = diff(slope_av);
                        %                 [tmp,I] = min(dslope_av);
                        %                 cloud_lim(x,y) = xdata(I);
                    end
                end
                ts = ts+1;
                ct = ts/tt*100;
                disp(['Progress: finished step ' num2str(ts) '/' num2str(tt) ' (' num2str(ct) '%).']);
            end
        end
    end
    
    % save reflectance
    save(['Data\matlab\reflectance\surface_reflectance_' regionname '_' years{yr_idx(1)} '_' ...
        years{yr_idx(end)}],'surfrefl')
    
end

