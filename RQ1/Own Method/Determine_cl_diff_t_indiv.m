%%% Script to determine the threshold that labels a timestep as a moment of
%%% additional cloud formation. Doing analysis for landes.

%%%% INPUT %%%%
disk = 'D';


cl_diff_t = 0.47;

cmap = gray;
num_samples = 15;
cl_t = 27;
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
E_Deduct_cloud_formation_times(disk, cl_t, cl_diff_t)

cl_diff_t_data_full = load([disk, ':\Thesis\Data\matlab\cloud_formation_times\cloud_form_dates_merged_' num2str(cl_diff_t*100) '_' num2str(cl_t) '.mat']);
cl_diff_t_data = cl_diff_t_data_full.cloud_form_dates_merged.d_landes;

clear cl_diff_t_data_full forest1 forest1lims forest2 forest2lims forest3 forest3lims

%%% basic stats
sum_diff_t_ts = sum(cl_diff_t_data(:,5));
perc_t = sum_diff_t_ts/size(cl_diff_t_data,1)*100;

%%% Create dataset with moments that were added by lowering the
% Only positive moments
t_only_ones = cl_diff_t_data;
t_only_ones(t_only_ones(:,5) == 0,:) = [];

%%% Make sure there are enough timestamps to plot
if size(t_only_ones,1) >= num_samples
    
    % Select random timestamps that are added by the differences
    rand_ts = datasample(t_only_ones, num_samples, 'Replace', false);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Create dataset that contains the images of the random timestamps
    % Create empty dataset
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cld_images = int16(zeros(num_samples, length(idx_region_r), length(idx_region_c)));
    
    for i=1:num_samples
        % Make sure the hours and days are inserted as hhhh and dd
        % respectively
        if rand_ts(i,4) < 1000
            f_hour = ['0' num2str(rand_ts(i,4))];
        else
            f_hour = num2str(rand_ts(i,4));
        end
        
        if rand_ts(i,3) < 10
            f_day = ['0' num2str(rand_ts(i,3))];
        else
            f_day = num2str(rand_ts(i,3));
        end
        
        filename = [disk, ':\Thesis\Data\ch12\' num2str(rand_ts(i,1)) '\0' num2str(rand_ts(i,2)) '\' ...
            num2str(rand_ts(i,1)) '0' num2str(rand_ts(i,2)) f_day f_hour '.gra'];
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
        cld_images(i,:,:) = ch12(idx_region_r,idx_region_c,:);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create comparison plots %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
    close all
    
    % Image
    img_n = 1;
    for a=1:1
        figure
        for b = 1:15
            subplot(3,5,b);
            
            axis image;
            axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
            colormap(cmap);
            plotimg = squeeze(cld_images(img_n,:,:));
            pcolorm(hrv_lat,hrv_lon,plotimg);
            if b == 3
                if a == 7
                    imgtitle = {['Images accepted with cl\_diff\_t: ' num2str(cl_diff_t) ', total moments flagged: ' num2str(sum_diff_t_ts)], ['Image ' num2str(img_n)]};
                else
                    imgtitle = {['Images accepted with cl\_diff\_t: ' num2str(cl_diff_t)], ['Image ' num2str(img_n)]};
                end
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
    disp('Not enough timestamps for cl_diff_t, must be more than 105.');
end