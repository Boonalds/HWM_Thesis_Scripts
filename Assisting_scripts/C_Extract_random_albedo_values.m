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

%%% MODIS Albedo
filename = [disk, ':\Thesis\Data\Albedo\2009\MCD43A.A2009209.h17v04.005.2009229030813_vis_actual.tif'];
[albedo, R] = geotiffread(filename);

albedo = double(albedo);
albedo(albedo >= 0.1 | albedo <= 0) = 0.001;
albedo = albedo*100;
albedo = flipud(albedo);


mod_rasterSize = R.RasterSize;
mod_latLim = R.LatitudeLimits;
mod_lonLim = R.LongitudeLimits;

Refmat = makerefmat('RasterSize', mod_rasterSize, 'Latlim', mod_latLim, 'Lonlim', mod_lonLim);

%%% Own albedo
filenamea = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2004_2008_no_outliers.mat'];
Reflstructure = load(filenamea);
A = Reflstructure.surfrefl(month,dec,hour,:,:);
B = squeeze(A);
B = rot90(B,3);

% Refmat
own_rasterSize = size(B);
own_latLim = landeslims.regionbox.latlim;
own_lonLim = landeslims.regionbox.lonlim;
Refmat2 = makerefmat('RasterSize', own_rasterSize, 'Latlim', own_latLim, 'Lonlim', own_lonLim);

%%% Value extraction

% Point selection
latLim = [max(own_latLim(1),mod_latLim(1)) min(own_latLim(2),mod_latLim(2))];
lonLim = [max(own_lonLim(1),mod_lonLim(1)) min(own_lonLim(2),mod_lonLim(2))];

pointsLat = latLim(1) + (latLim(2)-latLim(1)).*rand(np,1);
pointsLon = lonLim(1) + (lonLim(2)-lonLim(1)).*rand(np,1);

% Extraction
OwnValues = ltln2val(B, Refmat2, pointsLat, pointsLon); 
ModValues = ltln2val(albedo, Refmat, pointsLat, pointsLon);

% Comparison
ratioValues = [];
ratioValues = OwnValues./ModValues;


%%%%%%%%%%%%%%%%
%%% PLOTTING %%%
%%%%%%%%%%%%%%%%

close all

figure

%plot1
subplot(2,2,1);   
worldmap(albedo, Refmat);
meshm(albedo, Refmat);
title('MODIS Albedo')

geoshow(pointsLat, pointsLon, 'DisplayType', 'Point', 'Marker', 'o', 'Color', 'm', 'LineWidth', 3);
textm(pointsLat, pointsLon+0.08, num2str((1:np)'), 'FontSize',10, 'Color', 'w')

%plot2
subplot(2,2,2);     
worldmap(B,Refmat2);
meshm(B, Refmat2);
title('Own Albedo')

geoshow(pointsLat, pointsLon, 'DisplayType', 'Point', 'Marker', 'o', 'Color', 'm', 'LineWidth', 3);
textm(pointsLat, pointsLon+0.08, num2str((1:np)'), 'FontSize',10, 'Color', 'w')

%plot3
subplot(2,2,[3,4]);

plot(ratioValues);