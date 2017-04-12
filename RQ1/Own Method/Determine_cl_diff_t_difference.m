%%% Script to determine the threshold that labels a timestep as a moment of
%%% additional cloud formation. Doing analysis for landes.

%%%% INPUT %%%%
disk = 'G';
cl_t = 27;

cl_diff_t_1 = 0.28;
cl_diff_t_2 = 0.29;

cmap = gray;
num_samples = 15;

% Load external script that contain necessary information
load Data\hrv_grid\hrv_grid;     % Contains lat and lon data for each cell
box_lims

%%% Set up variables - currently for landes
region_lat = landeslims.regionbox.latlim;
region_lon = landeslims.regionbox.lonlim;
hrv_lat = landes.hrv_lat;
hrv_lon = landes.hrv_lon;
idx_region_r = 220:416;
idx_region_c = 69:186;


forest_lat = landeslims.forestbox.latlim;
forest_lon = landeslims.forestbox.lonlim;
nonfor1_lat = landeslims.nonforbox1.latlim;
nonfor1_lon = landeslims.nonforbox1.lonlim;
nonfor2_lat = landeslims.nonforbox2.latlim;
nonfor2_lon = landeslims.nonforbox2.lonlim;




%%%%%%%%%%%%%%%%%%%%%% Core %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if cl_diff_t_2 <= cl_diff_t_1
    disp('cl_diff_t2 must be greater than cl_diff_t1!');
    return
end


E_Deduct_cloud_formation_times(disk, cl_t, cl_diff_t_1)
E_Deduct_cloud_formation_times(disk, cl_t, cl_diff_t_2)


cl_t1_data_full = load([disk, ':\Thesis\Data\matlab\cloud_formation_times\cloud_form_dates_merged_' num2str(cl_diff_t_1*100) '_' num2str(cl_t) '.mat']);
cl_t2_data_full = load([disk, ':\Thesis\Data\matlab\cloud_formation_times\cloud_form_dates_merged_' num2str(cl_diff_t_2*100) '_' num2str(cl_t) '.mat']);


cl_t1_data = cl_t1_data_full.cloud_form_dates_merged.d_landes;
cl_t2_data = cl_t2_data_full.cloud_form_dates_merged.d_landes;


clear cl_t1_data_full cl_t2_data_full forest1 forest1lims forest2 forest2lims forest3 forest3lims

%%% basic stats
sum_t1_ts = sum(cl_t1_data(:,5));
sum_t2_ts = sum(cl_t2_data(:,5));

perc_t1 = sum_t1_ts/size(cl_t1_data,1)*100;
perc_t2 = sum_t2_ts/size(cl_t2_data,1)*100;

%%% Create dataset with moments that were added by lowering the
% Only positive moments
t1_only_ones = cl_t1_data;
t1_only_ones(t1_only_ones(:,5) == 0,:) = [];
t2_only_ones = cl_t2_data;
t2_only_ones(t2_only_ones(:,5) == 0,:) = [];

% Timesteps added by the difference in cl_diff_t
t2_to_t1 = setdiff(t1_only_ones,t2_only_ones,'rows');

%%% Make sure there are enough timestamps to plot
if size(t2_to_t1,1) >= num_samples
    
    % Select random timestamps that are added by the differences
    rand_ts_t2_t1 = datasample(t2_to_t1, num_samples, 'Replace', false);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Create dataset that contains the images of the random timestamps
    % Create empty dataset
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    diff_images = int16(zeros(num_samples, length(idx_region_r), length(idx_region_c)));
    
    for i=1:num_samples
        % Make sure the hours and days are inserted as hhhh and dd
        % respectively
        if rand_ts_t2_t1(i,4) < 1000
            f_hour = ['0' num2str(rand_ts_t2_t1(i,4))];
        else
            f_hour = num2str(rand_ts_t2_t1(i,4));
        end
        
        if rand_ts_t2_t1(i,3) < 10
            f_day = ['0' num2str(rand_ts_t2_t1(i,3))];
        else
            f_day = num2str(rand_ts_t2_t1(i,3));
        end
        
        filename = [disk, ':\Thesis\Data\ch12\' num2str(rand_ts_t2_t1(i,1)) '\0' num2str(rand_ts_t2_t1(i,2)) '\' ...
            num2str(rand_ts_t2_t1(i,1)) '0' num2str(rand_ts_t2_t1(i,2)) f_day f_hour '.gra'];
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
            disp([filename ' does not exist']);
        end
        diff_images(i,:,:) = ch12(idx_region_r,idx_region_c,:);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create comparison plots %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
    close all
    
    % Image
    img_n = 1;
    for a=1:5
        figure
        for b = 1:15
            subplot(3,5,b);
            
            axis image;
            axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
            colormap(cmap);
            plotimg = squeeze(diff_images(img_n,:,:));
            pcolorm(hrv_lat,hrv_lon,plotimg);
            if b == 3
                imgtitle = {['Situations that are accepted when chosing ' num2str(cl_diff_t_1) ' over ' num2str(cl_diff_t_2) ' for cl\_diff\_t.'], ['Image ' num2str(img_n)]};
            else
                imgtitle = ['Image ' num2str(img_n)];
            end
            title(imgtitle);
            img_n = img_n+1;
 
            
            box1 = linem([max(forest_lat); min(forest_lat);...
                min(forest_lat); max(forest_lat);...
                max(forest_lat)], [min(forest_lon);...
                min(forest_lon); max(forest_lon);...
                max(forest_lon); min(forest_lon)],...
                'Color',[0.4 0.8 0.4], 'LineWidth', 2);
            
            % nonforest1:
            box2 = linem([max(nonfor1_lat); min(nonfor1_lat);...
                min(nonfor1_lat); max(nonfor1_lat);...
                max(nonfor1_lat)], [min(nonfor1_lon);...
                min(nonfor1_lon); max(nonfor1_lon);...
                max(nonfor1_lon); min(nonfor1_lon)],...
                'Color',[1 0.8 0.2], 'LineWidth', 2);
            
            % nonforest2:
            box3 = linem([max(nonfor2_lat); min(nonfor2_lat);...
                min(nonfor2_lat); max(nonfor2_lat);...
                max(nonfor2_lat)], [min(nonfor2_lon);...
                min(nonfor2_lon); max(nonfor2_lon);...
                max(nonfor2_lon); min(nonfor2_lon)],...
                'Color',[0.8 0.2 1.0], 'LineWidth', 2);
            
            
        end
        tightfig;
        MaximizeFigureWindow;
    end
    
else
    disp('Not enough timestamps for the difference between cl_diff_t1 and cl_diff_t2, must be more than 100.');
end