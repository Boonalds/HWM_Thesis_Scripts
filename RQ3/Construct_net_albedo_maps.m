function [] = I_Construct_net_albedo_maps(regionname,yr_idx)

disk = 'D';
check_exist = 1;    % Carry out a check to see if the file already exist,
                    % so the remainder of the script can be skipped.
                    % Put to 0 if something changed, so the file needs to
                    % be recreated.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
daysp{1} = 1:10;
daysp{2} = 11:20;
daysp{3} = 21:31;

%%%%%%%%%%%%%%%%%%%%% CHECK EXISTENCE %%%%%%%%%%%%%%%%%%%%%%%%

if check_exist == 1
    
    checkfile = [disk ':\Thesis\Data\matlab\net_albedo_maps\net_albedo_map_' regionname '_' years{yr_idx(1)} '_' ...
        years{yr_idx(end)} '.mat'];
    if exist(checkfile, 'file') == 2
        disp('I: Albedo map already exists, not running script.');
        quitvar = 1;
    else
        disp('I: No albedo map exists yet, running script.');
        quitvar = 2;
    end
else
    quitvar = 2;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                              %%% CORE %%%
                          %%% Map creation %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if quitvar == 2
    
    switch regionname
        case 'landes'
            % index for landes cutout
            idx_region_r = 220:416;
            idx_region_c = 69:186;
        case 'orleans'
            % index for orleans cutout
            idx_region_r = 40:233;
            idx_region_c = 274:382;
        otherwise
            warning('Unknown regionname.')
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%   Define surface reflectance   %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    surfrefl = int16(zeros(length(months),3,12,length(idx_region_r),length(idx_region_c)));
    
    %read in data matrix and determine surface reflectance
    ts = 0;
    tt = 4*3*12;  % 4 months, 3 decades, 12 hours per day.
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
                        mean_refl = mean(squeeze(ch12sel(x,y,:)));
                        surfrefl(m,dec,(h+3)/4,x,y) = mean_refl;
                    end
                end
                ts = ts+1;
                ct = ts/tt*100;
                disp(['Progress: finished step ' num2str(ts) '/' num2str(tt) ' (' num2str(ct) '%).']);
            end
        end
    end
    
    % save reflectance
    save(['Data\matlab\net_albedo_maps\net_albedo_map_' regionname '_' years{yr_idx(1)} '_' ...
        years{yr_idx(end)}],'surfrefl')
    
end
end
                          
                          
                          
                          
