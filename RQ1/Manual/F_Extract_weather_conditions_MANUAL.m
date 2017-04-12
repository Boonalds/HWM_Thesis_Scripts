disp('Script F started running.');
%%%%%%%%%%%%       F_Determine_correlation_weather_vars       %%%%%%%%%%%
% Script for correlation cloud formation times with ERA Interim weather
% data to potentially find a relation between a weather variable and the
% additional clouds. This script will only focus on the correlation for
% Landes and Sologne forests (orleans).

%%% INPUT %%%
check_exist = 0;
np = 10;           % Number of random points that are sampled to represent the weather.
postproc = 0;       % Post processing (plotting etc)

regionname = 'landes';
disk = 'D';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                              %%% STEP 0  %%%
                           %%% Preprocessing  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% IMPORT DATA %%%
% ERA Interim netcdf
ncfile = [disk ':\Thesis\Data\ERA_Interim\era_interim_2004_2013_time0_6_12_18_step0_3_9.nc']; % ncdisp(ncfile);
box_lims

% load ERA vars
tempData = ncread(ncfile, 't2m');  % 2m temperature for making the RefMat
latData = ncread(ncfile, 'latitude');
lonData = ncread(ncfile, 'longitude');

% Cloud timestamps
load([disk ':\Thesis\Data\matlab\NN\trainingsdata_landes_10000_samples.mat'])

%%%%%%%%%%%%%%%
%%%  CORE  %%%%
%%%%%%%%%%%%%%%

% Set up variables
datenames = {'d_landes','d_orleans'};
rgnnames = {'landes', 'orleans'};
var_names = {'t2m', 'd2m', 'u10', 'v10', 'cp', 'e', 'msl', 'tcw'};



% Create Refmat for ERA Interim image
rasterSize_RM = [size(tempData,1) size(tempData,2)];
latLim_RM = double([min(latData) max(latData)]);
lonLim_RM = double([min(lonData) max(lonData)]);
Refmat = makerefmat('RasterSize', rasterSize_RM, 'Latlim', latLim_RM, 'Lonlim', lonLim_RM);

clear latData lonData tempData rasterSize_RM europelims forest1lims forest2lims forest3lims latLim_RM lonLim_RM

tt = length(var_names);
ct = 0;
        
% Create empty cell array
cloud_vars = cell(length(trainings_set), length(var_names)+3);


switch regionname
    case 'landes'
        latLim_ext = landeslims.forestbox.latlim;
        lonLim_ext = landeslims.forestbox.lonlim;
    case 'orleans'
        latLim_ext = orleanslims.forestbox.latlim;
        lonLim_ext = orleanslims.forestbox.lonlim;
    otherwise
        warning('Unknown regionname.')
end

% Determine random lat and lon coordinates within the forestbox for weather
% variable extraction

% Point selection
pointsLat = latLim_ext(1) + (latLim_ext(2)-latLim_ext(1)).*rand(np,1);
pointsLon = lonLim_ext(1) + (lonLim_ext(2)-lonLim_ext(1)).*rand(np,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 1  %%%
%%% Transform dates to ERA format  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for i=1:length(trainings_set);
    %%% Transform hhhh-dd-mm-yyyy to era timestep format
    % years
    val = 914544 + (trainings_set(i,1)-2004)*8760;
    if trainings_set(i,1) >= 2008 && trainings_set(i,1) <= 2011
        val = val+24;
    elseif trainings_set(i,1) >= 2012
        val = val+48;
    end
    % months
    val = val + (trainings_set(i,2)-5)*744;
    if trainings_set(i,2) >= 7
        val = val-24;  % Correct for 30 days in June
    end
    % days
    val = val + (trainings_set(i,3)-1)*24;
    % hours, rounded to 0600, 0900, 1200, 1500 or 1800 hrs
    if trainings_set(i,4) < 730   % 0600
        val = val+6;
    elseif trainings_set(i,4) >= 730 && trainings_set(i,4) < 1030 % 0900
        val = val+9;
    elseif trainings_set(i,4) >= 1030 && trainings_set(i,4) < 1330 % 1200
        val = val+12;
    elseif trainings_set(i,4) >= 1330 && trainings_set(i,4) < 1630 % 1500
        val = val+15;
    elseif trainings_set(i,4) >= 1630  % 1800
        val = val+18;
    end
    
    % Write times in data matrix
    cloud_vars{i,2} = val;
    cloud_vars{i,1} = datestr((double(val)/24 + datenum('1900-01-01 00:00:00')),'dd-mm-yyyy HH:MM:SS');
    cloud_vars{i,3} = trainings_set(i,13);
end
disp('Script F: Finished step 1. Starting step 2..');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 2  %%%
%%% Extract weather variables  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load in all the ERA Interim timesteps
netcdf_time = ncread(ncfile, 'time'); % time
for i = 1:length(var_names)
    tmp_var = ncread(ncfile, var_names{i});
    for j = 1:size(cloud_vars,1)
        % Index of ERA data where additional cloud formation occurs
        era_idx = find(netcdf_time == cloud_vars{j,2});
        
        % Extraction
        cloud_vars{j,i+3} = nanmean(ltln2val(tmp_var(:,:,era_idx), Refmat, pointsLat, pointsLon));
    end
    % Progress
    ct = ct+1;
    disp(['Script F -  Progress: ' num2str(ct) '/' num2str(tt) ' steps completed (' num2str(ct/tt*100) '%).']);
end
clear tmp_var





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 3  %%%
%%% Calculate wind direction and wind speed from u and v fields  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:size(cloud_vars,1)
    % Absolute windspeed
    cloud_vars{i,12} = sqrt((cloud_vars{i,6})^2 + (cloud_vars{i,7})^2);
    
    % Wind direction (of the angle the wind is blowing to)
    cloud_vars{i,13} = atan2(cloud_vars{i,6}, cloud_vars{i,7});  % radians
    cloud_vars{i,14} = cloud_vars{i,13} * 180/pi;                % degrees
    
    % Convert wind direction to angle the wind is coming from (meteorological convention)
    cloud_vars{i,13} = cloud_vars{i,13} + pi;
    cloud_vars{i,14} = cloud_vars{i,14} + 180;
end

table_headings = {'date', 'ERA timestep', 'cloud flag', '2m T', '2m dewT', '5m u', '5m v', 'conv P', 'E', 'press', 'Water column', 'abs windspeed', 'wind dir rad', 'wind dir deg'};

cloud_vars = cat(1, table_headings, cloud_vars);
save('Data\matlab\results\Weather_variables_table_trainings_set_10000','cloud_vars');





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 4  %%%
%%% Regression and how to correlate wind direction  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%  Cloud_vars content  %%%%%
%col# (NOTE: in the cloud_vars_subset, the colnumber is reduced by 1)
%3  cloud flag
%4  2m Temperature
%5  2m dewpoint temperature
%6  10 metre U wind component
%7  10 metre V wind component
%8  Convective precipitation
%9  Evaporation
%10  Mean sea level pressure
%11 Total water column
%12 abs wind speed
%13 wind direction (radians)
%14 wind direction (degrees)
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP X  %%%
%%% Post processing  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if postproc == 1
    
    %%%% PLOTTING %%%%
    cmap = hot;
    testdata = squeeze(tempData(:,:,195));
    
    % latLim = double([min(latData) max(latData)]);
    % lonLim = double([min(lonData) max(lonData)]);
    
    close all
    axis image;
    
    axesm('MapProjection','lambert','Frame','on','grid','on',...
        'MapLatLimit',landeslims.regionbox.latlim,...
        'MapLonLimit',landeslims.regionbox.lonlim,...
        'FLineWidth',.5);
    
    % Actual plot
    colormap(cmap);
    pcolorm(landeslims.regionbox.latlim, landeslims.regionbox.lonlim, testdata);
    
    
    shore = load('Data\matlab\france_shore.dat');   % Shoreline file
    linem(shore(:,2),shore(:,1),'k');   % Add shoreline
end

disp('Script F finished running.');
