disk = 'D';
regionname = 'landes';
yr_idx = 1:5;
cmap = gray;

%%% Select timestep
% m, dec, hour, x, y
m = 2;
dec = 3;
hour = 6;


load Data\hrv_grid\hrv_grid;     % Contains lat and lon data for each cell
box_lims

hrv_lat = landes.hrv_lat;
hrv_lon = landes.hrv_lon;
region_lat = landeslims.regionbox.latlim;
region_lon = landeslims.regionbox.lonlim;


years = {'2004';'2005';'2006';'2007';'2008';'2009';'2010';'2011';'2012';'2013'};

filename = [disk ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_' years{yr_idx(1)} '_' years{yr_idx(end)} '.mat'];
reg_albedo_map = load(filename);
reg_map = squeeze(reg_albedo_map.surfrefl(m,dec,hour,:,:));



close all
figure

axis image;
axesm('MapProjection','lambert','Frame','on','grid','on', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,reg_map);
%title('Regular albedo map');
h = colorbar;    
% h.Label.Position = [1.9 187 0];
h.Label.Position
ylabel(h, 'Reflectance (-)', 'FontSize',11);