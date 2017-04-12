disk = 'D';     % Disk that contains Matlab Path
year = 2009;
regionname = 'orleans';

imgNumber = 6; 

white_sky_analysis = 0;  

%%%%%%%%%%%%%%%
%%% LOADING %%%
%%%%%%%%%%%%%%%
box_lims                                       % Contains lat and lon limits for plotting areas
load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell

%%% yr 2009, day 121 is a good day for orleans
dirContent =  dir([disk, ':/Thesis/Data/Albedo/MODIS/' regionname '/' num2str(year) '/vis_actual/']);  % Saving all folder content

if imgNumber > size(dirContent,1)
    warning(['Image number too high, not that many images available. (Max ' num2str(size(dirContent,1)-2) ').'])
else
    imgName = dirContent(imgNumber+2).name;  % Deducting Imagename
end

filename = [disk, ':/Thesis/Data/Albedo/MODIS/' regionname '/' num2str(year) '/vis_actual/' imgName];
[albedo, R] = geotiffread(filename);

albedo = double(albedo);
albedo(albedo >= 0.1 | albedo <= 0) = 0.01;
albedo = albedo*1000;
albedoud = flipud(albedo);

mod_rasterSize = R.RasterSize;
mod_latLim = R.LatitudeLimits;
mod_lonLim = R.LongitudeLimits;
Refmat = makerefmat('RasterSize', mod_rasterSize, 'Latlim', mod_latLim, 'Lonlim', mod_lonLim);
    
if white_sky_analysis == 1
    
    %%% WHITE SKY
    
    filenamews = [disk, ':/Thesis/Data/Albedo/2009/MCD43A.A2009121.h17v04.005.2009140014504_vis_white.tif'];
    [albedows, Rws] = geotiffread(filenamews);
    
    albedows = double(albedows);
    albedows(albedows >= 0.1 | albedows <= 0) = 0.01;
    albedows = albedows*1000;
    albedowsud = flipud(albedows);
    
    
    %%% DIFFERENCE
    albedodif = albedowsud - albedoud;
    albedodif(albedodif > 50) =  NaN;
    albedodif(albedodif < -50) =  NaN;
    
    %%% PLOT
    close all
    figure
    
    subplot(1,3,1);
    worldmap(albedoud, Refmat);
    meshm(albedoud, Refmat);
    title('MODIS Albedo map - ACTUAL')
    
    subplot(1,3,2);
    worldmap(albedowsud, Refmat);
    meshm(albedowsud, Refmat);
    title('MODIS Albedo map - WHITE SKY')
    
    subplot(1,3,3);
    worldmap(albedodif, Refmat);
    meshm(albedodif, Refmat);
    title('MODIS Albedo map - DIFFERENCE')
    colorbar
else
    close all
    figure
    
    worldmap(albedoud, Refmat);
    meshm(albedoud, Refmat);
    title('MODIS Albedo map')
end

    