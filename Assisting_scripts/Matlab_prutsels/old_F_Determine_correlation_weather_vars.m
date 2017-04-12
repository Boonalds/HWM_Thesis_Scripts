%%%%%%%%%%%%       F_Determine_correlation_weather_vars       %%%%%%%%%%%
% Script for correlation cloud formation times with ERA Interim weather
% data to potentially find a relation between a weather variable and the
% additional clouds. This script will only focus on the correlation for
% Landes and Sologne forests (orleans).

%%% INPUT %%%
disk = 'D';         % Disk that contains Thesis folder (set as working directory).

cl_t = '10';       % 
cl_diff_t = 0.6;   % the difference in cloud fraction between forest and 
                   % non-forest that needs to be exceeded to have that 
                   % timestep labeled as additional cloud formation.
np = 10;           % Number of random points that are sampled to represent the weather.
regionname = 'landes';


% Running selective parts of the script (1 = yes/0 = no)

preproc = 0;        % Preprocessing
step_1 = 0;         % Step 1  - Date transformation
step_2 = 0;         % Step 2  - Variable extraction
step_3 = 0;         % Step 3  - Calculate wind direction
step_4 = 1;         % Step 4  - Regression
postproc = 0;       % Post processing (plotting etc) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% STEP 0  %%%
                        %%% Preprocessing  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if preproc == 1
    %%% IMPORT DATA %%%
    % ERA Interim netcdf
    ncfile = [disk ':\Thesis\Data\ERA_Interim\era_interim_2004_2013_time0_6_12_18_step0_3_9.nc']; % ncdisp(ncfile);
    
    box_lims       
    
    % load ERA vars
    tempData = ncread(ncfile, 't2m');  % 2m temperature for making the RefMat
    latData = ncread(ncfile, 'latitude');
    lonData = ncread(ncfile, 'longitude');
    
    % Cloud timestamps
    load([disk ':\Thesis\Data\matlab\cloud_formation_times\cloud_form_dates_merged_' num2str(cl_diff_t*100) '_' cl_t]);
    
    %%%%%%%%%%%%%%%
    %%%  CORE  %%%%
    %%%%%%%%%%%%%%%
    
    % Set up variables
    datenames = {'d_landes','d_orleans'};
    var_names = {'t2m', 'd2m', 'u10', 'v10', 'cp', 'e', 'msl', 'tcw'};
    a = 1;
    
    cloud_vars = cell(length(cloud_form_dates_merged.(datenames{a})), length(var_names)+3);
    
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
    
    % Create Refmat for ERA Interim image
    rasterSize_RM = [size(tempData,1) size(tempData,2)];
    latLim_RM = double([min(latData) max(latData)]);
    lonLim_RM = double([min(lonData) max(lonData)]);
    Refmat = makerefmat('RasterSize', rasterSize_RM, 'Latlim', latLim_RM, 'Lonlim', lonLim_RM);
    
    clear latData lonData tempData rasterSize_RM europelims forest1lims forest2lims forest3lims landeslims orleanslims...
        latLim_RM lonLim_RM
    
    tt = length(var_names);
    ct = 0;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% STEP 1  %%%
                  %%% Transform dates to ERA format  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if step_1 ==1

    for i=1:length(cloud_form_dates_merged.(datenames{a}));
        %%% Transform hhhh-dd-mm-yyyy to era timestep format
        % years
        val = 914544 + (cloud_form_dates_merged.(datenames{a})(i,1)-2004)*8760;
        if cloud_form_dates_merged.(datenames{a})(i,1) >= 2008 && cloud_form_dates_merged.(datenames{a})(i,1) <= 2011
            val = val+24;
        elseif cloud_form_dates_merged.(datenames{a})(i,1) >= 2012
            val = val+48;
        end
        % months
        val = val + (cloud_form_dates_merged.(datenames{a})(i,2)-5)*744;
        if cloud_form_dates_merged.(datenames{a})(i,2) >= 7
            val = val-24;  % Correct for 30 days in June
        end
        % days
        val = val + (cloud_form_dates_merged.(datenames{a})(i,3)-1)*24;
        % hours, rounded to 0600, 0900, 1200, 1500 or 1800 hrs
        if cloud_form_dates_merged.(datenames{a})(i,4) < 730   % 0600
            val = val+6;
        elseif cloud_form_dates_merged.(datenames{a})(i,4) >= 730 && cloud_form_dates_merged.(datenames{a})(i,4) < 1030 % 0900
            val = val+9;
        elseif cloud_form_dates_merged.(datenames{a})(i,4) >= 1030 && cloud_form_dates_merged.(datenames{a})(i,4) < 1330 % 1200
            val = val+12;
        elseif cloud_form_dates_merged.(datenames{a})(i,4) >= 1330 && cloud_form_dates_merged.(datenames{a})(i,4) < 1630 % 1500
            val = val+15;
        elseif cloud_form_dates_merged.(datenames{a})(i,4) >= 1630  % 1800
            val = val+18;
        end
        
        % Write times in data matrix
        cloud_vars{i,2} = val;
        cloud_vars{i,1} = datestr((double(val)/24 + datenum('1900-01-01 00:00:00')),'dd-mm-yyyy HH:MM:SS');
        cloud_vars{i,3} = cloud_form_dates_merged.(datenames{a})(i,5);
    end
    disp('Finished step 1. Starting step 2..');   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% STEP 2  %%%
                     %%% Extract weather variables  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if step_2 == 1
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
        disp(['Progress: ' num2str(ct) '/' num2str(tt) ' steps completed (' num2str(ct/tt*100) '%).']);
    end
    clear tmp_var
    table_headings = {'date', 'ERA timestep', 'cloud flag', '2m T', '2m dewT', '5m u', '5m v', 'conv P', 'E', 'press', 'Water column'};
    cloud_vars = cat(1, table_headings, cloud_vars);
    save(['Data\matlab\results\Weather_variables_table_' regionname '_' cl_t ],'cloud_vars');
end


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% STEP 3  %%%
    %%% Calculate wind direction and wind speed from u and v fields  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if step_3 == 1
    if exist('cloud_vars', 'var') ~= 1
        load([disk ':\Thesis\Data\matlab\results\Weather_variables_table_' regionname '_' cl_t '.mat']);
    end
    for i = 2:size(cloud_vars,1)
        % Absolute windspeed
        cloud_vars{i,12} = sqrt((cloud_vars{i,6})^2 + (cloud_vars{i,7})^2);
        
        % Wind direction (of the angle the wind is blowing to)
        cloud_vars{i,13} = atan2(cloud_vars{i,6}, cloud_vars{i,7});  % radians
        cloud_vars{i,14} = cloud_vars{i,13} * 180/pi;                % degrees
        
        % Convert wind direction to angle the wind is coming from (meteorological convention)
        cloud_vars{i,13} = cloud_vars{i,13} + pi;
        cloud_vars{i,14} = cloud_vars{i,14} + 180;
    end
    table_headings = {'date', 'ERA timestep', 'cloud flag', '2m T', '2m dewT', '5m u', '5m v', 'conv P', 'E', 'press', 'Water column', 'Wind speed', 'Wind dir (rad)','Wind dir (deg)'};
    cloud_vars(1,:) = [];
    cloud_vars = cat(1, table_headings, cloud_vars);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% STEP 4  %%%
        %%% Regression and how to correlate wind direction  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if step_4 == 1
    if exist('cloud_vars', 'var') ~= 1
        load([disk ':\Thesis\Data\matlab\results\Weather_variables_table_' regionname '_' cl_t '.mat']);
    end
    
    %%% Subset creation
    % Create two datasets, one with only data of additional cloud formation
    % moments, and one set with the remaining data. This makes sure there
    % are as many 1's as 0's in the response dataset.
    
    
    %%% Create two datasets, one with only data of additional cloud formation
    % moments, and one set with the remaining data.
    only_zeros = cloud_vars;
    only_zeros(1,:) = [];
    only_zeros(:,1) = [];
    only_zeros = cell2mat(only_zeros);
    only_zeros(only_zeros(:,2) == 1,:) = [];

    only_ones = cloud_vars;
    only_ones(1,:) = [];
    only_ones(:,1) = [];
    only_ones = cell2mat(only_ones);
    only_ones(only_ones(:,2) == 0,:) = [];
    
    %%% Independent T-Test (Welch Test)
    % Checking if the means of the weather variables are significantly
    % different between the two samples
    
    % Select which variables to test
    var_sel = [3 4 11];
    
    % Create sample 1
    no_cloud_sample = only_zeros(:,var_sel);
    
    % Create sample 2
    add_cloud_sample = only_ones(:,var_sel);
    
    % T-test itself
    [h, p, ci, stats] = ttest2(no_cloud_sample, add_cloud_sample,'Vartype','unequal');
    
    %%%%%%%%%%% Weather variables to chose from %%%%%%%%
    %2  cloud flag
    %3  2m Temperature
    %4  2m dewpoint temperature
    %5  10 metre U wind component
    %6  10 metre V wind component
    %7  Convective precipitation
    %8  Evaporation
    %9  Mean sea level pressure
    %10 Total water column
    %11 abs wind speed
    %12 wind direction (radians)
    %13 wind direction (degrees)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    %%% Regression
    lmvr = 0;  % logistical multivariate regression
    
    if lmvr == 1
        % Select randomly the same amount of no-cloud moments as there are
        % cloud-moments
        max_r = size(only_zeros,1);
        n = size(only_ones,1);
        p = randperm(max_r,n);
        only_zeros_sel = only_zeros(p,:);
        clear only_zeros
        
        % Paste the subset together
        cloud_vars_subset = cat(1, only_ones, only_zeros_sel);
        
        
        %%% Create prediction dataset (X)
        pred = cloud_vars_subset(:,11);
        %pred = cat(2, cloud_vars_subset(:,5),cloud_vars_subset(:,11));
        %predc = cloud_vars(2:end,12)));
        
        %%% Create response dataset (Y)
        resp = categorical(cloud_vars_subset(:,2)+1);
        
        %%% Logistical regression
        [B, dev, stats] = mnrfit(pred, resp);
        
        
    end
    
    %%% Circular
    %[alpha, x] = circ_corrcl(predc, resp);

end

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
