disk = 'G';
regionname = 'landes';
yr_idx = 1:5;
cmap = gray;

%%% Select timestep
% m, dec, hour, x, y
m = 1;
dec = 2;
hour = 8;

%%% Good timesteps:
% 2,3,4



%%% Load in
load Data\hrv_grid\hrv_grid;     % Contains lat and lon data for each cell
box_lims

switch regionname
    case 'landes'
        hrv_lat = landes.hrv_lat;
        hrv_lon = landes.hrv_lon;
        region_lat = landeslims.regionbox.latlim;
        region_lon = landeslims.regionbox.lonlim;
    case 'orleans'
        hrv_lat = orleans.hrv_lat;
        hrv_lon = orleans.hrv_lon;
        region_lat = orleanslims.regionbox.latlim;
        region_lon = orleanslims.regionbox.lonlim;
    otherwise
        warning('Unknown regionname.')
end

years = {'2004';'2005';'2006';'2007';'2008';'2009';'2010';'2011';'2012';'2013'};

% Load albedo maps
filenamea = [disk ':\Thesis\Data\matlab\net_albedo_maps\net_albedo_map_' regionname '_'  years{yr_idx(1)} '_' years{yr_idx(end)} '.mat'];
net_albedo_map = load(filenamea);
filenameb = [disk ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_' years{yr_idx(1)} '_' years{yr_idx(end)} '.mat'];
reg_albedo_map = load(filenameb);

%%% Load net and regular albedo maps
net_map = double(squeeze(net_albedo_map.surfrefl(m,dec,hour,:,:)));
reg_map = double(squeeze(reg_albedo_map.surfrefl(m,dec,hour,:,:)));
dif_map = net_map-reg_map;

%%% Plot the three maps together
close all
figure

subplot(1,3,1);
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,reg_map);
title('Regular albedo map');
colorbar

subplot(1,3,2);
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,net_map);
title('Net albedo map');
colorbar

subplot(1,3,3);
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,dif_map);
title('Difference in albedo (net - regular)');
colorbar

%%% Plots seperate with boxes
figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,reg_map);
title('Clear-sky');
colorbar
add_study_areas_to_plot

figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,net_map);
title('Average');
colorbar
add_study_areas_to_plot
