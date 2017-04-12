%%% This script just plots the 2m temperature, if a different variable is
%%% wanted, change this at line 12.

% SETUP VARIABLES
np = 10;
i = 1400;  % Timestep to plot, between 1 and 59520
cmap = hot;

skipvar = 0;

if skipvar == 0
    % Load in data
    ncfile = 'G:\Thesis\Data\ERA_Interim\era_interim_2006_July_time12_step0.nc';   % Just for plot

    % ncfile = 'G:\Thesis\Data\ERA_Interim\era_interim_2004_2013_time0_6_12_18_step0_3_9.nc'; % real file
    tempData = ncread(ncfile, 't2m');  % 2m temperature
    latData = ncread(ncfile, 'latitude');
    lonData = ncread(ncfile, 'longitude');
    shore = load('Data\matlab\france_shore.dat');   % Shoreline file
    % {'t2m' 'd2m' 'u10' 'v10' 'cp' 'e' 'msl' 'tcw'}
    
    % Region limits and timestamps
    box_lims
    load Data\hrv_grid\hrv_grid;     % Contains lat and lon data for each cell
    load('G:\Thesis\Data\matlab\cloud_formation_times\cloud_form_dates_merged_20_27.mat');
    
    
    %%% Core
    % Create Refmat for ERA Interim image
    rasterSize_RM = [size(tempData,1) size(tempData,2)];
    latLim_RM = double([min(latData) max(latData)]);
    lonLim_RM = double([min(lonData) max(lonData)]);
    Refmat = makerefmat('RasterSize', rasterSize_RM, 'Latlim', latLim_RM, 'Lonlim', lonLim_RM);
    
    clear latData lonData rasterSize_RM europelims forest1lims forest2lims forest3lims latLim_RM lonLim_RM
    
    % Create empty cell array
    cloud_vars = cell(1,1+3);
    
    latLim_ext = landeslims.forestbox.latlim;
    lonLim_ext = landeslims.forestbox.lonlim;
    
    % Determine random lat and lon coordinates within the forestbox for weather
    % variable extraction
    pointsLat = latLim_ext(1) + (latLim_ext(2)-latLim_ext(1)).*rand(np,1);
    pointsLon = lonLim_ext(1) + (lonLim_ext(2)-lonLim_ext(1)).*rand(np,1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% STEP 1  %%%
    %%% Transform dates to ERA format  %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%% Transform hhhh-dd-mm-yyyy to era timestep format
    % years
    val = 914544 + (cloud_form_dates_merged.d_landes(i,1)-2004)*8760;
    if cloud_form_dates_merged.d_landes(i,1) >= 2008 && cloud_form_dates_merged.d_landes(i,1) <= 2011
        val = val+24;
    elseif cloud_form_dates_merged.d_landes(i,1) >= 2012
        val = val+48;
    end
    % months
    val = val + (cloud_form_dates_merged.d_landes(i,2)-5)*744;
    if cloud_form_dates_merged.d_landes(i,2) >= 7
        val = val-24;  % Correct for 30 days in June
    end
    % days
    val = val + (cloud_form_dates_merged.d_landes(i,3)-1)*24;
    % hours, rounded to 0600, 0900, 1200, 1500 or 1800 hrs
    if cloud_form_dates_merged.d_landes(i,4) < 730   % 0600
        val = val+6;
    elseif cloud_form_dates_merged.d_landes(i,4) >= 730 && cloud_form_dates_merged.d_landes(i,4) < 1030 % 0900
        val = val+9;
    elseif cloud_form_dates_merged.d_landes(i,4) >= 1030 && cloud_form_dates_merged.d_landes(i,4) < 1330 % 1200
        val = val+12;
    elseif cloud_form_dates_merged.d_landes(i,4) >= 1330 && cloud_form_dates_merged.d_landes(i,4) < 1630 % 1500
        val = val+15;
    elseif cloud_form_dates_merged.d_landes(i,4) >= 1630  % 1800
        val = val+18;
    end
    
    % Write times in data matrix
    cloud_vars{1,2} = val;
    cloud_vars{1,1} = datestr((double(val)/24 + datenum('1900-01-01 00:00:00')),'dd-mm-yyyy HH:MM:SS');
    cloud_vars{1,3} = cloud_form_dates_merged.d_landes(i,5);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% STEP 2  %%%
    %%% Extract weather variables  %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Load in all the ERA Interim timesteps
    netcdf_time = ncread(ncfile, 'time'); % time
    
    % Index of ERA data where additional cloud formation occurs
    era_idx = find(netcdf_time == cloud_vars{1,2});
    
    % Forcing idx for plot, doesnt necesarily contain add cloud formation
    era_idx = 18; % 18 juli
    
    % Extraction
    cloud_vars{1,4} = nanmedian(ltln2val(tempData(:,:,era_idx), Refmat, pointsLat, pointsLon));
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% STEP 3  %%%
    %%% Plot ERA Data and random latlon points  %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot_era_map = double(squeeze(tempData(:,:,era_idx)));
    plot_era_map = plot_era_map - 273.15;  % Plot in Centigrade
    
end

close all
figure

axis image;
axesm('MapProjection','lambert','Frame','on','grid','on', 'MapLatLimit',landeslims.regionbox.latlim,'MapLonLimit',landeslims.regionbox.lonlim,'FLineWidth',.5,'MLineLocation',1,'PLineLocation',1);
colormap(cmap);
pcolorm(landes.hrv_lat,landes.hrv_lon,plot_era_map);

title('ERA Interim 2m-temperature map');
ylabel('Latitude')
xlabel('Longitude')

h = colorbar;
s = sprintf('Temperature [%cC]', char(176));
ylabel(h,s,'FontSize',10);

mlabel('on')
plabel('on')

linem(shore(:,2),shore(:,1),'k')

hold on
sp = geoshow(pointsLat,pointsLon,'DisplayType','point','MarkerEdgeColor','k','Marker', '.','MarkerSize',20);

hold on
forbox = linem([max(landeslims.forestbox.latlim); min(landeslims.forestbox.latlim);...
    min(landeslims.forestbox.latlim); max(landeslims.forestbox.latlim);...
    max(landeslims.forestbox.latlim)], [min(landeslims.forestbox.lonlim);...
    min(landeslims.forestbox.lonlim); max(landeslims.forestbox.lonlim);...
    max(landeslims.forestbox.lonlim); min(landeslims.forestbox.lonlim)],...
    'Color','k', 'LineWidth', 2);


legend([sp forbox], {'Random Sampling \newlinePoints','Forest Study Area'});



