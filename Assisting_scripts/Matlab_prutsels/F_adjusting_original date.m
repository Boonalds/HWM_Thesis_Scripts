%%%%%%%%%%%%       F_Determine_correlation_weather_vars       %%%%%%%%%%%
% Script for correlation cloud formation times with ERA Interim weather
% data to potentially find a relation between a weather variable and the
% additional clouds. This script will only focus on the correlation for
% Landes and Sologne forests (orleans).


%%% INPUT %%%
disk = 'D';         % Disk that contains Thesis folder (set as working directory).
plot_v = 0;         % Plot results (1 = yes/0 = no)

cl_t = '10';       % 
cl_diff_t = 0.6;   % the difference in cloud fraction between forest and 
                   % non-forest that needs to be exceeded to have that 
                   % timestep labeled as additional cloud formation.
            
               
                   
                   


%%% IMPORT DATA %%%
% ERA Interim netcdf
ncfile = 'D:\Thesis\Data\ERA_Interim\era_interim_2004_2013_time0_6_12_18_step0_3_9.nc'; % ncdisp(ncfile);

% load ERA vars
netcdf_time = ncread(ncfile, 'time'); % time

% Cloud timestamps
load([disk ':\Thesis\Data\matlab\cloud_formation_times\cloud_form_dates_' num2str(cl_diff_t*100) '_' cl_t]);

%%%%%%%%%%%%%%%
%%%  CORE  %%%%
%%%%%%%%%%%%%%%

% Set up variables
datenames = {'d_landes','d_orleans'};
a = 1;
add_cloud_moments = cloud_form_dates.d_landes;

%%% 1 Select right ERA timestep for cloud timestamp %%%
for i=1:length(cloud_form_dates.(datenames{a}));
    val = [];
    %%% Transform hhhh-dd-mm-yyyy to era timestep format
    % years
    val = 914544 + (cloud_form_dates.(datenames{a})(i,2)-2004)*8760;
    if cloud_form_dates.(datenames{a})(i,2) >= 2008 && cloud_form_dates.(datenames{a})(i,2) <= 2011
        val = val+24;
    elseif cloud_form_dates.(datenames{a})(i,2) >= 2012
        val = val+48;
    end
    % months
    val = val + (cloud_form_dates.(datenames{a})(i,3)-5)*744;
    if cloud_form_dates.(datenames{a})(i,3) >= 7
        val = val-24;  % Correct for 30 days in June
    end
    % days
    val = val + (cloud_form_dates.(datenames{a})(i,4)-1)*24;
    % hours, rounded to 0600, 0900, 1200, 1500 or 1800 hrs
    if cloud_form_dates.(datenames{a})(i,5) < 730   % 0600
        val = val+6;
    elseif cloud_form_dates.(datenames{a})(i,5) >= 730 && cloud_form_dates.(datenames{a})(i,5) < 1030 % 0900
        val = val+9;
    elseif cloud_form_dates.(datenames{a})(i,5) >= 1030 && cloud_form_dates.(datenames{a})(i,5) < 1330 % 1200
        val = val+12;
    elseif cloud_form_dates.(datenames{a})(i,5) >= 1330 && cloud_form_dates.(datenames{a})(i,5) < 1630 % 1500
        val = val+15;
    elseif cloud_form_dates.(datenames{a})(i,5) >= 1630  % 1800
        val = val+18;
    end
    test_set(i,6) = val;
end

find(netcdf_time == 914559)

%%%%%%%%%%%%%%%%%%%
        
        
% timeData = double(netcdf_time)/24 + datenum('1900-01-01 00:00:00');
% datestr(timeData(1:7,1),'dd-mm-yyyy HH:MM:SS') % For testing


%%% 2 Derive representative value for each variable %%%
%%% 3 Calculate wind direction and wind speed from u and v fields %%%
%%% 4 Regression and how to correlate wind direction %%%



% % Lat and Lon data
% latData = ncread(ncfile, 'latitude');
% lonData = ncread(ncfile, 'longitude');
% 
% % Weather variable data
tempData = ncread(ncfile, 't2m');
% dtempData = ncread(ncfile, 'd2m');
% u10Data = ncread(ncfile, 'u10');
% v10Data = ncread(ncfile, 'v10');
% 

%%%% PLOTTING %%%%
if plot_v == 1
    
    cmap = hot;
    testdata = squeeze(tempData(:,:,188));
    
    latLim = double([min(latData) max(latData)];
    lonLim = double([min(lonData) max(lonData)]);
    
    close all
    axis image;
    
    axesm('MapProjection','lambert','Frame','on','grid','on',...
        'MapLatLimit',landeslims.regionbox.latlim,...
        'MapLonLimit',landeslims.regionbox.lonlim,...
        'FLineWidth',.5);
    
    % Actual plot
    colormap(cmap);
    pcolorm(landeslims.regionbox.latlim, landeslims.regionbox.lonlim, testdata);
end
