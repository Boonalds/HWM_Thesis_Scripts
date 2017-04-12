disk = 'G';
cmap = gray;

box_lims
region_lat = landeslims.regionbox.latlim;
region_lon = landeslims.regionbox.lonlim;
forest_lat = landeslims.forestbox.latlim;
forest_lon = landeslims.forestbox.lonlim;
nonfor1_lat = landeslims.nonforbox1.latlim;
nonfor1_lon = landeslims.nonforbox1.lonlim;
nonfor2_lat = landeslims.nonforbox2.latlim;
nonfor2_lon = landeslims.nonforbox2.lonlim;

load Data\hrv_grid\hrv_grid;
hrv_lat = landes.hrv_lat;
hrv_lon = landes.hrv_lon;


albedo_map = load([disk ':\Thesis\Data\matlab\net_albedo_maps\net_albedo_map_landes_2004_2008.mat']);
map_temp = double(squeeze(albedo_map.surfrefl(1,1,1,:,:)));


%
cols = 71:115;
rows = 79:104;
map_temp(cols,rows) = 130;

% plot
close all
figure


axis image;
axesm('MapProjection','lambert','Frame','on','grid','on', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,map_temp);
title('Regular albedo map');
colorbar

%forestbox:
box1 = linem([max(forest_lat); min(forest_lat);...
    min(forest_lat); max(forest_lat);...
    max(forest_lat)], [min(forest_lon);...
    min(forest_lon); max(forest_lon);...
    max(forest_lon); min(forest_lon)],...
    'Color',[0.2 0.85 0.4], 'LineWidth', 2, 'LineStyle', ':');
box2 = linem([max(nonfor1_lat); min(nonfor1_lat);...
    min(nonfor1_lat); max(nonfor1_lat);...
    max(nonfor1_lat)], [min(nonfor1_lon);...
    min(nonfor1_lon); max(nonfor1_lon);...
    max(nonfor1_lon); min(nonfor1_lon)],...
    'Color',[0 0.8 0.8], 'LineWidth', 2);
box3 = linem([max(nonfor2_lat); min(nonfor2_lat);...
    min(nonfor2_lat); max(nonfor2_lat);...
    max(nonfor2_lat)], [min(nonfor2_lon);...
    min(nonfor2_lon); max(nonfor2_lon);...
    max(nonfor2_lon); min(nonfor2_lon)],...
    'Color',[0.8 0.2 0.8], 'LineWidth', 2);

l = legend([box1 box2 box3], 'Forest','Nonforest1','Nonforest2', 'Location','northeast');



