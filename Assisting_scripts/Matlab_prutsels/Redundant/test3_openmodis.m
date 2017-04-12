clear


np = 10;  % number of validation points

disk = 'D';     % Disk that contains Matlab Path
month =  2;     % index (1-4) for {'05';'06';'07';'08'};
dec =  1;       % index (1-3)for {'01';'02';'03'};
hour = 1;       % index (1-12) for {'0600';'0700';'0800';'0900';'1000';'1100';...


%%%%%%%%%%%%%%%%%%%% 
%%% LOADING DATA %%%
%%%%%%%%%%%%%%%%%%%%
box_lims                                       % Contains lat and lon limits for plotting areas
load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell
shore = load('Data\matlab\france_shore.dat');   % Shoreline file

%%% Own albedo

% Load in data
filename = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2004_2008.mat'];
Reflstructure = load(filename);
A = Reflstructure.surfrefl(month,dec,hour,:,:);
B = squeeze(A);
B = rot90(B,3);

% Make refmat
own_rasterSize = size(B);
own_latLim = landeslims.regionbox.latlim;
own_lonLim = landeslims.regionbox.lonlim;
Refmat = makerefmat('RasterSize', own_rasterSize, 'Latlim', own_latLim, 'Lonlim', own_lonLim);

% Write geotiff
outfilename = filename(1:end-3);
outfilename = [outfilename, 'tif'];

geotiffwrite(outfilename,B,Refmat);

%%% Testing
[albedo, R] = geotiffread(outfilename);

worldmap(albedo, Refmat);
meshm(albedo, Refmat);
title('own Albedo')
