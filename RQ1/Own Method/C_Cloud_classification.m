%%%%%%%%%%%%%%%%%%   STEP D - Cloud Classification   %%%%%%%%%%
%%%%%% This script determines for each pixel of each image whether it is a
%%%%%% cloud or not, based on its albedo difference with the background
%%%%%% map. The classified pixels are stored as a different file for eacho
%%%%%% fthe maximum tolerable difference.


% function [] = D1_Cloud_classification(disk, cl_t)
disp('Script D1 started running.');
%%% input
disk = 'G';
cl_t = 27;

check_exist =1;

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

rgnnames = {'landes', 'orleans', 'forest1', 'forest2', 'forest3'};
yrs = [1,5,6,10];


ct=0; % Progress counter
tt = 5*2; % 5 regions, 2 periods of time
for a = 1:5
    regionname = rgnnames{a};
    for b = 1:2
        yr_idx = yrs(b*2-1):yrs(b*2);
        
        
        %%%%%%%%%%%%% CHECK EXISTENCE %%%%%%%%%%%
        if check_exist == 1
            
            checkfile = [disk ':\Thesis\Data\matlab\cloudflags\hrv_cloudflag_' regionname '_' years{yr_idx(1)} '_'  years{yr_idx(end)} '_' num2str(cl_t) '.mat'];
            if exist(checkfile, 'file') == 2
                show_p = 0;
                quitvar = 1;
                disp(['Script D1 - Map of ' regionname ' (' years{yr_idx(1)} '-' years{yr_idx(end)} ') already classified, skipping this step']);
            else
                show_p = 1;
                quitvar = 2;
            end
        else
            quitvar = 2;
        end
        
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
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%   Flag pixels as clouds   %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            % Load in albedo maps
            filename = [disk, ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_' years{yr_idx(1)} '_' years{yr_idx(end)} '_no_outliers.mat'];
            Reflstructure = load(filename);
            
            % Create empty structures
            cloudflag = zeros(length(yr_idx),length(months),31,48,...
                length(idx_region_r),length(idx_region_c),'int8');
            
            
            for y = 1:length(yr_idx)
                for m = 1:length(months)
                    for d = 1:31
                        for h = 1:48
                            % read in data files
                            filename = [disk, ':\Thesis\Data\ch12\' years{yr_idx(y)} '\' months{m} '\' ...
                                years{yr_idx(y)} months{m} days{d} hours{h} '.gra'];
                            if exist(filename, 'file') == 2
                                fileID = fopen(filename,'r','l');
                                A = fread(fileID,inf,'int16=>int16');
                                fclose(fileID);
                                if size(A,1) == 183480
                                    ch12 = reshape(A,440,417);
                                else
                                    ch12 = nan(440,417);
                                    disp(['Corrupt image: ' filename]);
                                end
                            else
                                ch12 = nan(440,417);
                            end
                            % cut out selected region
                            ch12sel = ch12(idx_region_r,idx_region_c,:);
                            % determine decade nr
                            if d < 11
                                p = 1;
                            elseif d >= 11 && d < 21
                                p = 2;
                            else
                                p = 3;
                            end
                            % determine hour idx
                            hridx = ceil(h/4);
                            % get background surface reflectance
                            tmp_surfrefl = squeeze(Reflstructure.surfrefl(m,p,hridx,:,:));
                            tmp = zeros(size(ch12sel),'int8');
                            tmp(ch12sel > (tmp_surfrefl+cl_t)) = 1;
                            tmp(isnan(ch12sel)) = 2;
                            cloudflag(y,m,d,h,:,:) = tmp;
                        end
                    end
                    ct = ct+1;
                    disp(['Progress: ' num2str(ct) '/' num2str(tt) ' steps completed (' num2str(ct/tt*100) '%).']);
                end
            end
            
            save(['Data\matlab\cloudflags\hrv_cloudflag_' regionname '_' years{yr_idx(1)} '_' ...
                years{yr_idx(end)} '_' num2str(cl_t)],'cloudflag')
            
        end
        ct = ct+1;
        if show_p == 1
            disp(['Script D1 - Progress: ' num2str(ct) '/' num2str(tt) ' steps completed (' num2str(ct/tt*100) '%).']);
        end
        
    end
    
end
disp('Script D1 finished running.');
% end


% save(['matlab\hrv_missingdata_' regionname '_' years{yr_idx(1)} '_' ...
%     years{yr_idx(end)}],'missingdata')
% % save(['matlab\hrv_shadeflag_' regionname '_' years{yr_idx(1)} '_' ...
% %     years{yr_idx(end)} '_5'],'shadeflag_5')
% save(['matlab\hrv_shadeflag_' regionname '_' years{yr_idx(1)} '_' ...
%     years{yr_idx(end)} '_10'],'shadeflag_10')
% % save(['matlab\hrv_shadeflag_' regionname '_' years{yr_idx(1)} '_' ...
% %     years{yr_idx(end)} '_20'],'shadeflag_20')