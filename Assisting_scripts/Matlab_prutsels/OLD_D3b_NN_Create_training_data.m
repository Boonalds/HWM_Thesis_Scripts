%%% Script to determine the threshold that labels a timestep as a moment of
%%% additional cloud formation. Doing analysis for landes.



%%%% INPUT %%%%
num_samples = 6;

disk = 'D';
regionname = 'landes';

% Load external script that contain necessary information
years = {'2004';'2005';'2006';'2007';'2008';'2009';'2010';'2011';'2012';'2013'};


%%% Load in geo-data
load Data\hrv_grid\hrv_grid;     % Contains lat and lon data for each cell
box_lims

idx_region_r = 220:416;
idx_region_c = 69:186;
region_lat = landeslims.regionbox.latlim;
region_lon = landeslims.regionbox.lonlim;
hrv_lat = landes.hrv_lat;
hrv_lon = landes.hrv_lon;

% Load feature dataset for the available dates
filename = [disk, ':\Thesis\Data\matlab\NN\feature_dataset_' regionname '.mat'];
file_load = load(filename);
feature_dataset = file_load.feature_dataset;
dates = feature_dataset(:,1:4);

% taking random dates from the dataset
rand_ts = datasample(dates, num_samples, 'Replace', false);
trainings_features = zeros(length(rand_ts),size(feature_dataset,2));

%%%% Split training and classification data
class_set = feature_dataset;
locs = zeros(1,num_samples);

for i=1:length(rand_ts)
    [~,loc] = ismember(rand_ts(i,:),dates,'rows');
    trainings_features(i,:) = feature_dataset(loc,:);
    locs(i) = loc;
end
class_set(locs,:) = [];
clear feature_dataset
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Extract images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cld_images = zeros(num_samples, length(idx_region_r), length(idx_region_c));
caxis_ll_l = zeros(num_samples,1);
caxis_ul_l = zeros(num_samples,1);

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
    ch12sel = ch12(idx_region_r,idx_region_c,:);
    cld_images(i,:,:) = ch12sel;
    
    ch12sel_dbl = double(ch12sel);
    if isnan(nanmean(ch12sel_dbl)) == 1
        caxis_ll_l(i) = 0;
        caxis_ul_l(i) = 500;
    else
        caxis_ll_l(i) = mean(ch12sel_dbl(:))-2*std(ch12sel_dbl(:));
        caxis_ul_l(i) = mean(ch12sel_dbl(:))+2*std(ch12sel_dbl(:));
    end
end



%%%%%%%%%%%%%%%%%%% Load in images and assign pass_flags %%%%%%%%%%%%%%
pass_flag = zeros(size(rand_ts,1),1);
trainings_set = cat(2,trainings_features, pass_flag);
pf_loc = size(trainings_set,2);

cmap = gray;
close all
figure
MaximizeFigureWindow;

for i=1:num_samples
    titlemsg = ['Image ' num2str(i)];
    subplot(1,3,1) 
    axis image;
    axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
    colormap(cmap);
    plotimg = squeeze(cld_images(i,:,:));
    pcolorm(hrv_lat,hrv_lon,plotimg);
    caxis([caxis_ll_l(i) caxis_ul_l(i)]);
    title(titlemsg);
    
    message = sprintf('Is additional cloud formation visible in this picture?');
    button = questdlg(message, 'Cloud formation?', 'Yes', 'No','Corrupt img', 'Yes');
    
    if strcmpi(button, 'No')
        trainings_set(i,pf_loc) = 0;
    elseif strcmpi(button, 'Yes')
        trainings_set(i,pf_loc) = 1;
    elseif strcmpi(button, 'Corrupt img')
        trainings_set(i,pf_loc) = NaN;
    else
        trainings_set(i,pf_loc) = NaN;
        error('Training session terminated by user!')
    end
end

close all

save(['Data\matlab\NN\classdata_' regionname '_' num2str(num_samples) '_samples'],'class_set');
save(['Data\matlab\NN\trainingsdata_' regionname '_' num2str(num_samples) '_samples'],'trainings_set');
save(['Data\matlab\NN\trainingsimages_' regionname '_' num2str(num_samples) '_samples'],'cld_images');
