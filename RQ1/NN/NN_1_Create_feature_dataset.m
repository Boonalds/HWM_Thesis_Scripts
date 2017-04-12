%%% Script to determine the threshold that labels a timestep as a moment of
%%% additional cloud formation. Doing analysis for landes.

%%%% INPUT %%%%
disk = 'D';

% % Load external script that contain necessary information
% load Data\hrv_grid\hrv_grid;     % Contains lat and lon data for each cell
% box_lims



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

rgnnames = {'landes', 'orleans', 'forest1', 'forest2', 'forest3'};

numfeat = 8;
feature_dataset = zeros(10*4*31*48,numfeat+4);
ct = 0;  % progress tracker

for a = 1:1
    regionname = rgnnames{a};
    tt = a(end)*10*4*31;
    
        switch regionname
            case 'landes'
                % index for landes cutout
                idx_region_r = 220:416;
                idx_region_c = 69:186;
                idx_for_r = 282:328;
                idx_for_c = 107:133;
                idx_nf1_r = 259:305;
                idx_nf1_c =  74:100;
                idx_nf2_r = 289:335;
                idx_nf2_c = 147:173;
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
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %%%%   Fill up the dataset   %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        i = 0;
        for yr = 1:10;
            for m = 1:4
                for d = 1:31
                    for h = 1:48
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%   Cutout the sub regions   %%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        i = i+1;
                        filename = [disk, ':\Thesis\Data\ch12\' years{yr} '\' months{m} '\' ...
                            years{yr} months{m} days{d} hours{h} '.gra'];
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
                            disp(['Missing image: ' filename]);
                        end
                        
                        % Rescale images to have values between 0 and 1.
                        ch12_gs = mat2gray(ch12);
                        ch12_adj = imadjust(ch12_gs);
                        T = graythresh(ch12_adj);
                        clear ch12_adj
                        
                        % Cut out the study areas
                        img_forest = ch12(idx_for_r,idx_for_c);
                        img_nonfor1 = ch12(idx_nf1_r,idx_nf1_c);
                        img_nonfor2 = ch12(idx_nf2_r,idx_nf2_c);
                        
                        % Cut out the study areas from the grayscale image 
                        img_forest_gs = ch12_gs(idx_for_r,idx_for_c);
                        img_nonfor1_gs = ch12_gs(idx_nf1_r,idx_nf1_c);
                        img_nonfor2_gs = ch12_gs(idx_nf2_r,idx_nf2_c);                        
                       
                        img_forest_gs_dbl = double(img_forest_gs);
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                      %%% Create features %%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Add date
                        [year, month, day, hour] = Calculate_date_from_timestep(i);
                        feature_dataset(i,1) = year; feature_dataset(i,2) = month;
                        feature_dataset(i,3) = day; feature_dataset(i,4) = hour;                        
                        
                        %%%%  FEATURE 1 - Difference mean pixel value between forest and nonforest  %%%%%
                        feature_dataset(i,5) = nanmean(img_forest_gs(:))-((nanmean(img_nonfor1_gs(:))+nanmean(img_nonfor2_gs(:)))/2);
                        
                        %%%%  FEATURE 2 - Variance within forest region  %%%%%
                        feature_dataset(i,6) = nanvar(img_forest_gs_dbl(:));
                        
                        %%%%  FEATURE 3 - Entropy within forest region  %%%%%
                        feature_dataset(i,7) = entropy(img_forest_gs);
                        
                        %%%%  Clusters part  %%%%%
                        BW_f = im2bw(img_forest_gs,T);
                        BW_nf1 = im2bw(img_nonfor1_gs,T);
                        BW_nf2 = im2bw(img_nonfor2_gs,T);
                        
                        cc_f = bwconncomp(BW_f, 4);
                        cc_nf1 = bwconncomp(BW_nf1, 4);
                        cc_nf2 = bwconncomp(BW_nf2, 4);
                        
                        props_f = regionprops(cc_f, 'basic');
                        props_nf1 = regionprops(cc_nf1, 'basic');
                        props_nf2 = regionprops(cc_nf2, 'basic');
                        
                        %%%%  FEATURE 4 - Average cloud/cluster-size within forest area  %%%%%
                        cluster_areas_f = [props_f.Area];
                        feature_dataset(i,8) = nanmean(cluster_areas_f);
                        if isnan(feature_dataset(i,8))
                            feature_dataset(i,8) = 0;
                        end
                        
                        
                        %%%%  FEATURE 5 - Amount of clouds/clusters in forest  %%%%%
                        feature_dataset(i,9) = length(cluster_areas_f);
                        
                        %%%%  FEATURE 6 - Difference amount of cloud-classified pixels between forest and nonforest  %%%%%
                        cluster_areas_nf1 = [props_nf1.Area];
                        cluster_areas_nf2 = [props_nf2.Area];
                        feature_dataset(i,10) = sum(cluster_areas_f)-((sum(cluster_areas_nf1)+sum(cluster_areas_nf2))/2);
                        
                        %%%%  FEATURE 7 - Covariance between nonfor1-forest  %%%%%
                        c1 = cov(img_forest_gs(:), img_nonfor1_gs(:));
                        feature_dataset(i,11) = c1(1,2);
                        
                        %%%%  FEATURE 8 - Covariance between nonfor2-forest  %%%%%
                        c2 = cov(img_forest_gs(:), img_nonfor2_gs(:));
                        feature_dataset(i,12) = c2(1,2);
                        
                    end
                    ct = ct+1;
                    disp(['Script A - Progress: ' num2str(ct) '/' num2str(tt) ' steps completed (' num2str(ct/tt*100,3) '%).']);  
                end
            end
        end
        
  
        save(['Data\matlab\NN\feature_dataset_' regionname], 'feature_dataset');
end


