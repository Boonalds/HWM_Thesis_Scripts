%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                % Input%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
disk = 'D';
val_val = 1;  % Do calibration or validation (0 = calibration, 1 = validation)

% Insert 3 thresholds 
cl_t_1 = 10;
cl_t_2 = 30;
cl_t_3 = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           % Date conversion %
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % List of useful cloudy moments %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dates of good cloudy conditions for visual determination of cl_t
%%%%%%%%%%%%   landes   %%%%%%%%%%%%%%%%%%
        %%% year, month, day, hour
%  CALIBRATION          % VALIDATION
%1  4,2,9,7             %1  10,1,4,30
%2  2,1,8,32            %2  9,4,25,45
%3  1,3,13,10           %3  9,2,3,35
%4  1,2,14,30           %4  2,3,15,20
%5  3,2,15,35           %5  4,4,3,3
%6  5,3,25,15           %6  5,1,29,33
%7  6,3,25,24           %7  6,2,1,38
%8  8,1,15,18           %8  7,3,15,23
%9  8,4,16,8            %9  7,4,15,24
%10 10,3,4,30           %10 1,2,15,27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Put useful moments in list so they can be used
regionname = 'landes';

if val_val == 0
    year_list = [4 2 1 1 3 5 6 8 8 10];
    month_list = [2 1 3 2 2 3 3 1 4 3];
    day_list = [9 8 13 14 15 25 25 15 16 4];
    hour_list = [7 32 10 30 35 15 24 18 8 30];
elseif val_val == 1
    year_list = [10 9 9 2 4 5 6 7 7 1];
    month_list = [1 4 2 3 4 1 2 3 4 2];
    day_list = [4 25 3 15 3 29 1 15 15 15];
    hour_list = [30 45 35 22 3 33 38 23 24 27];
end

cl_t_list = [cl_t_1 cl_t_2 cl_t_3];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                             % Pre processing %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load external script that contain necessary information
load Data\hrv_grid\hrv_grid;     % Contains lat and lon data for each cell
box_lims

% Define region-dependent variables
switch regionname
    case 'landes'
        % index for landes cutout
        idx_region_r = 220:416;
        idx_region_c = 69:186;
        region_lat = landeslims.regionbox.latlim;
        region_lon = landeslims.regionbox.lonlim;
        hrv_lat = landes.hrv_lat;
        hrv_lon = landes.hrv_lon;
    case 'orleans'
        % index for orleans cutout
        idx_region_r = 40:233;
        idx_region_c = 274:382;
        region_lat = orleanslims.regionbox.latlim;
        region_lon = orleanslims.regionbox.lonlim;
        hrv_lat = orleans.hrv_lat;
        hrv_lon = orleans.hrv_lon;
    otherwise
        warning('Unknown regionname.')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Cloud classification %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create empty structures
full = zeros(length(year_list),length(idx_region_r),length(idx_region_c),'int16');
cloud = zeros(length(year_list),3,length(idx_region_r),length(idx_region_c),'int16');
noncloud = zeros(length(year_list),3,length(idx_region_r),length(idx_region_c),'int16');
caxis_ll_l = zeros(length(year_list));
caxis_ul_l = zeros(length(year_list));


% Load reflectance maps into memory
filenamea = [disk, ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_2004_2008_no_outliers.mat'];
filenameb = [disk, ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_2009_2013_no_outliers.mat'];
Reflstructurea = load(filenamea);  % 2004 - 2008
Reflstructureb = load(filenameb);  % 2009 - 2013

% Do the cloud classification for the different thresholds
for i = 1:length(year_list)
    
    %%% Load correct background map
    if year_list(i) <= 5
        Reflstructure = Reflstructurea;
    else
        Reflstructure = Reflstructureb;
    end
        
    % determine decade nr and whole hour number to load the correct
    % backgroundmap.
    if day_list(i) < 11
        p = 1;
    elseif day_list(i) >= 11 && day_list(i) < 21
        p = 2;
    else
        p = 3;
    end
    hridx = ceil(hour_list(i)/4);
                   
    %%% Load MSG image
    filename = [disk, ':\Thesis\Data\ch12\' years{year_list(i)} '\' months{month_list(i)} '\' ...
        years{year_list(i)} months{month_list(i)} days{day_list(i)} hours{hour_list(i)} '.gra'];
    
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
    

    %%% Do the classification
    tmp_s = squeeze(Reflstructure.surfrefl(month_list(i),p,hridx,:,:));
    full(i,:,:) = ch12sel;
    
    for j = 1:length(cl_t_list)
        tmp_c = ch12sel;
        tmp_nc = ch12sel;
        
        tmp_c(tmp_c < (tmp_s+cl_t_list(j))) = NaN;
        tmp_nc(tmp_nc >= (tmp_s+cl_t_list(j))) = NaN;
        
        cloud(i,j,:,:) = tmp_c;
        noncloud(i,j,:,:) = tmp_nc;
    end
    ch12sel_dbl = double(ch12sel);
    caxis_ll_l(i) = mean(ch12sel_dbl(:))-2*std(ch12sel_dbl(:));
    caxis_ul_l(i) = mean(ch12sel_dbl(:))+2*std(ch12sel_dbl(:));
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Create comparison plots %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot inputs
cmap = gray;
close all

% Image

for k = 1:length(year_list)
figure

caxis_ll = caxis_ll_l(k);
caxis_ul = caxis_ul_l(k);

%%%%%%%%%%% Full image plot %%%%%%%%%%%%%
subplot(2,4,[1 5]);
axis image;
axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
plotimg = squeeze(full(k,:,:));
pcolorm(hrv_lat,hrv_lon,plotimg);
caxis([caxis_ll caxis_ul]);
imgtitle = {'Raw satellite image', [days{day_list(k)} '/' months{month_list(k)} '/' years{year_list(k)} ' - ' hours{hour_list(k)} 'h']};
title(imgtitle);

%%%%%%%%%% Non cloud plots %%%%%%%%%%%%
subplot(2,4,2);
axis image;
axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);    
plotimg = squeeze(noncloud(k,1,:,:));
pcolorm(hrv_lat,hrv_lon,plotimg);
caxis([caxis_ll caxis_ul]);
imgtitle = ['cl\_t = ' num2str(cl_t_1)];
title(imgtitle);

subplot(2,4,3);
axis image;
axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
plotimg = squeeze(noncloud(k,2,:,:));
pcolorm(hrv_lat,hrv_lon,plotimg);
caxis([caxis_ll caxis_ul]);
imgtitle = {'Pixels classified as non-cloud', ['cl\_t = ' num2str(cl_t_2)]};
title(imgtitle);

subplot(2,4,4);
axis image;
axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
plotimg = squeeze(noncloud(k,3,:,:));
pcolorm(hrv_lat,hrv_lon,plotimg);
caxis([caxis_ll caxis_ul]);
imgtitle = ['cl\_t = ' num2str(cl_t_3)];
title(imgtitle);

%%%%%%%%%%%% Cloud plots %%%%%%%%%%
subplot(2,4,6);
axis image;
axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
plotimg = squeeze(cloud(k,1,:,:));
pcolorm(hrv_lat,hrv_lon,plotimg);
caxis([caxis_ll caxis_ul]);
imgtitle = ['cl\_t = ' num2str(cl_t_1)];
title(imgtitle);

subplot(2,4,7);
axis image;
axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
plotimg = squeeze(cloud(k,2,:,:));
pcolorm(hrv_lat,hrv_lon,plotimg);
caxis([caxis_ll caxis_ul]);
imgtitle = {'Pixels classified as cloud', ['cl\_t = ' num2str(cl_t_2)]};
title(imgtitle);


subplot(2,4,8);
axis image;
axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
plotimg = squeeze(cloud(k,3,:,:));
pcolorm(hrv_lat,hrv_lon,plotimg);
caxis([caxis_ll caxis_ul]);
imgtitle = ['cl\_t = ' num2str(cl_t_3)];
title(imgtitle);

tightfig;
MaximizeFigureWindow;
end









