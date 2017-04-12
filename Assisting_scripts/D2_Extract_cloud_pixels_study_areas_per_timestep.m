%function [] = cloud_extraction_function(year,month,day,hour)
% Extracting cloud data and doing basic statistics, currently only for case
% 'landes' and for cloud threshold 10.


yr_idx = 1:5;
month = 1:4;
day = 1:31;
hour = 1:48;

regionname = 'landes';
statistics = 0;     % Add statistics   (1 = yes/0 = no)
plotting = 0;       % Add plots   (1 = yes/0 = no)

%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%

disk = 'D';     % Disk that contains Thesis folder (set as working directory).
cl_t = '10';      % Cloud threshold, difference in reflectance between cloud and background before it is classified as cloud.

% year = index of year in 2004:2013
% month = idx of month in May, June, July, August
% day = day of month
% hour = idx of time between 0600 and 1745, with intervals of 15 minutes

%%% For conversion to full (string) names;
years = {'2004';'2005';'2006';'2007';'2008';'2009';'2010';'2011';'2012';'2013'};
months = {'05';'06';'07';'08'};
days = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';...
    '13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';...
    '25';'26';'27';'28';'29';'30';'31'};
hours  = {'0600';'0615';'0630';'0645';'0700';'0715';'0730';'0745';...
    '0800';'0815';'0830';'0845';'0900';'0915';'0930';'0945';...
    '1000';'1015';'1030';'1045';'1100';'1115';'1130';'1145';...
    '1200';'1215';'1230';'1245';'1300';'1315';'1330';'1345';...
    '1400';'1415';'1430';'1445';'1500';'1515';'1530';'1545';...
    '1600';'1615';'1630';'1645';'1700';'1715';'1730';'1745'};


%%%%%%%%%%%%%%%%%
%%%  Loading  %%%
%%%%%%%%%%%%%%%%%

box_lims                                       % Contains lat and lon limits for plotting areas
load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell

% Load reflectance data for refl extraction
if year <= 5
    filename = [disk, ':\Thesis\Data\matlab\hrv_cloudflag_landes_2004_2008_', cl_t, '.mat'];
else
    filename = [disk, ':\Thesis\Data\matlab\hrv_cloudflag_landes_2009_2013_', cl_t, '.mat'];
end
load(filename);

%%%%%%%%%%%%%%%%%%%%%
%%% CORE - PART 1 %%%  Extracting cloud pixels from the study areas
%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1.1 Determine which of the cloudflag cells correspond to the lat/lon %
%%% coordinates of the study boxes, using the first timestep.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cloud_data = squeeze(cloudflag_10(year(1),month(1),day(1),hour(1),:,:));
cloud_data = double(cloud_data);

cloud_data_hrv = cat(3, landes.hrv_lat, landes.hrv_lon, cloud_data);


%%% Forest area %%%
k=0;
j=1;
m=1;

cloud_data_forest = [];
forest_cells_x = [];
forest_cells_y = [];
forest_lat = [];
forest_lon = [];

for i = 1:size(cloud_data,1)
    if cloud_data_hrv(i,j,2) >= landeslims.forestbox.lonlim(1) && cloud_data_hrv(i,j,2) <= landeslims.forestbox.lonlim(2)
        k=k+1;
        l=0;
        forest_cells_y(m) = i;  % Writing the y valaues of the cloudflag cells within the forest box
        for j = 1:size(cloud_data,2)
            if cloud_data_hrv(i,j,1) >= landeslims.forestbox.latlim(1) && cloud_data_hrv(i,j,1) <= landeslims.forestbox.latlim(2)
                l=l+1;           
                forest_lat(k,l) = cloud_data_hrv(i,j,1);  % storing lat/lon coordinates for plotting
                forest_lon(k,l) = cloud_data_hrv(i,j,2);  % storing lat/lon coordinates for plotting
                cloud_data_forest(k,l) = cloud_data_hrv(i,j,3);
                forest_cells_x(l) = j;                      % Writing the x valaues of the cloudflag cells within the forest box
            end
        end
        m = m+1;
    end
end

%%% Nonforest1 %%%
k=0;
j=1;
m=1;

cloud_data_nonfor1 = [];
nonfor1_cells_x = [];
nonfor1_cells_y = [];
nonfor1_lat = [];
nonfor1_lon = [];

for i = 1:size(cloud_data,1)
    if cloud_data_hrv(i,j,2) >= landeslims.nonforbox1.lonlim(1) && cloud_data_hrv(i,j,2) <= landeslims.nonforbox1.lonlim(2)
        k=k+1;
        l=0;
        nonfor1_cells_y(m) = i;  % Writing the y valaues of the cloudflag cells within the non forest1 box
        for j = 1:size(cloud_data,2)
            if cloud_data_hrv(i,j,1) >= landeslims.nonforbox1.latlim(1) && cloud_data_hrv(i,j,1) <= landeslims.nonforbox1.latlim(2)
                l=l+1;           
                nonfor1_lat(k,l) = cloud_data_hrv(i,j,1);  % storing lat/lon coordinates for plotting
                nonfor1_lon(k,l) = cloud_data_hrv(i,j,2);  % storing lat/lon coordinates for plotting
                cloud_data_nonfor1(k,l) = cloud_data_hrv(i,j,3);
                nonfor1_cells_x(l) = j;                      % Writing the x valaues of the cloudflag cells within the nonforest1 box
            end
        end
        m = m+1;
    end
end

%%% Nonforest2 %%%
k=0;
j=1;
m=1;

cloud_data_nonfor2 = [];
nonfor2_cells_x = [];
nonfor2_cells_y = [];
nonfor2_lat = [];
nonfor2_lon = [];

for i = 1:size(cloud_data,1)
    if cloud_data_hrv(i,j,2) >= landeslims.nonforbox2.lonlim(1) && cloud_data_hrv(i,j,2) <= landeslims.nonforbox2.lonlim(2)
        k=k+1;
        l=0;
        nonfor2_cells_y(m) = i;  % Writing the y valaues of the cloudflag cells within the non forest2 box
        for j = 1:size(cloud_data,2)
            if cloud_data_hrv(i,j,1) >= landeslims.nonforbox2.latlim(1) && cloud_data_hrv(i,j,1) <= landeslims.nonforbox2.latlim(2)
                l=l+1;           
                nonfor2_lat(k,l) = cloud_data_hrv(i,j,1);  % storing lat/lon coordinates for plotting
                nonfor2_lon(k,l) = cloud_data_hrv(i,j,2);  % storing lat/lon coordinates for plotting
                cloud_data_nonfor2(k,l) = cloud_data_hrv(i,j,3);
                nonfor2_cells_x(l) = j;                      % Writing the x valaues of the cloudflag cells within the nonforest 2
            end
        end
        m = m+1;
    end
end


%%% Outlines study areas
% forest
f_x1 = min(forest_cells_x);
f_x2 = max(forest_cells_x);
f_y1 = min(forest_cells_y);
f_y2 = max(forest_cells_y);

% nonforest1
nf1_x1 = min(nonfor1_cells_x);
nf1_x2 = max(nonfor1_cells_x);
nf1_y1 = min(nonfor1_cells_y);
nf1_y2 = max(nonfor1_cells_y);

% nonforest2
nf2_x1 = min(nonfor2_cells_x);
nf2_x2 = max(nonfor2_cells_x);
nf2_y1 = min(nonfor2_cells_y);
nf2_y2 = max(nonfor2_cells_y);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1.2 Retreive the cloudflag data from the study area cells using the %
%%% lat/lon coordinates retrieved in the previes section.               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cloud_data_forest = int8(cloud_data_forest);

%Progress counter
tt = length(year)*length(month)*length(day)*length(hour);
disp('Started data extraction loop');

ct=0; % First extraction already done in section 1.1, so skipping that to save computation time.
for y = 1:length(year)
    for m = 1:length(month)
        for d = 1:length(day)
            for h = 1:length(hour)
                if ct>0
                    tmp = squeeze(cloudflag_10(year(y),month(m),day(d),hour(h),f_y1:f_y2,f_x1:f_x2));
                    cloud_data_forest = cat(3, cloud_data_forest,tmp);
                    tmp = squeeze(cloudflag_10(year(y),month(m),day(d),hour(h),nf1_y1:nf1_y2,nf1_x1:nf1_x2));
                    cloud_data_nonfor1 = cat(3, cloud_data_nonfor1,tmp);
                    tmp = squeeze(cloudflag_10(year(y),month(m),day(d),hour(h),nf2_y1:nf2_y2,nf2_x1:nf2_x2));
                    cloud_data_nonfor2 = cat(3, cloud_data_nonfor2,tmp);
                end
                ct=ct+1;
            end
        end
        disp(['Progress: ' num2str(ct) '/' num2str(tt) ' steps completed (' num2str(ct/tt*100) '%).']);
    end
end               


save(['Data\matlab\cloud_data\cloud_data_forest_' regionname '_' years{year(1)} '_' ...
    years{year(end)} '_' cl_t],'cloud_data_forest');
save(['Data\matlab\cloud_data\cloud_data_nonfor1_' regionname '_' years{year(1)} '_' ...
    years{year(end)} '_' cl_t],'cloud_data_nonfor1');
save(['Data\matlab\cloud_data\cloud_data_nonfor2_' regionname '_' years{year(1)} '_' ...
    years{year(end)} '_' cl_t],'cloud_data_nonfor2');


%%%%%%%%%%%%%%%%%%%%%
%%% CORE - PART 2 %%%  Some basic numbers
%%%%%%%%%%%%%%%%%%%%%
if statistics == 1
    fs = (sum(cloud_data_forest(:) == 1))/((f_x2-f_x1)*(f_y2-f_y1));
    nf1s = (sum(cloud_data_nonfor1(:) == 1))/((nf1_x2-nf1_x1)*(nf1_y2-nf1_y1));
    nf2s = (sum(cloud_data_nonfor2(:) == 1))/((nf2_x2-nf2_x1)*(nf2_y2-nf2_y1));
    
    disp(' ');
    disp(' ');
    disp('Sum of cloud pixels, divided by total amount of pixels in said areas:')
    msg = ['Forest: ', num2str(fs)];
    disp(msg);
    msg = ['Non forest 1: ', num2str(nf1s)];
    disp(msg);
    msg = ['Non forest 2: ', num2str(nf2s)];
    disp(msg);
end

%%%%%%%%%%%%%%%%%%%%%
%%% TEST PLOTTING %%%
%%%%%%%%%%%%%%%%%%%%%
if plotting == 1
    
    close all
    
    cloudpxlvalue = max(refl(:))*1.1;   % assigning clouds to be 10% brighter than max bg refl
    
    forclouds = squeeze(forest_clouds(:,:,3));
    nonfor1clouds = squeeze(nonfor1_clouds(:,:,3));
    nonfor2clouds = squeeze(nonfor2_clouds(:,:,3));
    
    forest_clouds_refl(forclouds == 2) = cloudpxlvalue;
    nonfor1_clouds_refl(forclouds == 2) = cloudpxlvalue;
    nonfor2_clouds_refl(forclouds == 2) = cloudpxlvalue;
    
    
    
    figure
    
    axis image;
    
    axesm('MapProjection','lambert','Frame','on','grid','on',...
        'MapLatLimit',landeslims.regionbox.latlim,...
        'MapLonLimit',landeslims.regionbox.lonlim,...
        'FLineWidth',.5);
    cmap = gray;
    colormap(cmap);
    pcolorm(landes.hrv_lat,landes.hrv_lon,refl);
    title('Pixels classified as clouds masked out');
    colorbar;
    
    hold on
    
    pcolorm(forest_clouds(:,:,1),forest_clouds(:,:,2),forest_clouds_refl);  % add forest
    pcolorm(nonfor1_clouds(:,:,1),nonfor1_clouds(:,:,2),nonfor1_clouds_refl);  % add non forest1
    pcolorm(nonfor2_clouds(:,:,1),nonfor2_clouds(:,:,2),nonfor2_clouds_refl);  % add non forest2
    
    add_study_areas_to_plot_f(regionname)
end
