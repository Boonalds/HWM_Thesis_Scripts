regionname = 'landes';
box_lims


switch regionname
    case 'landes'
        % index for landes cutout
        idx_region_r = 220:416;
        idx_region_c = 69:186;
        regionlim_lat = landeslims.regionbox.latlim;
        regionlim_lon = landeslims.regionbox.lonlim;
    case 'orleans'
        % index for orleans cutout
        idx_region_r = 40:233;
        idx_region_c = 274:382;
        regionlim_lat = orleanslims.regionbox.latlim;
        regionlim_lon = orleanslims.regionbox.lonlim;
    case 'forest1'
        % index for additional forest1 cutout
        idx_region_r = 20:150;
        idx_region_c = 330:415;
        regionlim_lat = forest1lims.regionbox.latlim;
        regionlim_lon = forest1lims.regionbox.lonlim;
    case 'forest2'
        % index for additional forest2 cutout
        idx_region_r = 130:240;
        idx_region_c = 250:310;
        regionlim_lat = forest2lims.regionbox.latlim;
        regionlim_lon = forest2lims.regionbox.lonlim;
    case 'forest3'
        % index for additional forest3 cutout
        idx_region_r = 290:325;
        idx_region_c = 220:270;
        regionlim_lat = forest3lims.regionbox.latlim;
        regionlim_lon = forest3lims.regionbox.lonlim;
    otherwise
        warning('Unknown regionname.')
end


filename = 'MSG_locations_low_res.gra';
fileID = fopen(filename,'r','l');
A = fread(fileID,inf,'float');
fclose(fileID);
loc_c = reshape(A,146,139,2);
lat_c = squeeze(loc_c(:,:,2));
lon_c = squeeze(loc_c(:,:,1));
idx_lat_c = repmat([3:3:440]',1,139);
idx_lon_c = repmat([2:3:417],146,1);
idx_lat_f = repmat([1:440]',1,417);
idx_lon_f = repmat([1:417],440,1);

lat_hrv = interp2(idx_lon_c,idx_lat_c,lat_c,idx_lon_f,idx_lat_f);
lon_hrv = interp2(idx_lon_c,idx_lat_c,lon_c,idx_lon_f,idx_lat_f);

hrv_lat = lat_hrv(idx_region_r, idx_region_c);
hrv_lon = lon_hrv(idx_region_r, idx_region_c);

disk = 'G';
year = 3;
month = 3;
day = 1;
hour = 10;

years = {'2004';'2005';'2006';'2007';'2008';'2009';'2010';'2011';'2012';'2013'};
days = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';...
    '13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';...
    '25';'26';'27';'28';'29';'30';'31'};
hours  = {'0600';'0615';'0630';'0645';'0700';'0715';'0730';'0745';...
    '0800';'0815';'0830';'0845';'0900';'0915';'0930';'0945';...
    '1000';'1015';'1030';'1045';'1100';'1115';'1130';'1145';...
    '1200';'1215';'1230';'1245';'1300';'1315';'1330';'1345';...
    '1400';'1415';'1430';'1445';'1500';'1515';'1530';'1545';...
    '1600';'1615';'1630';'1645';'1700';'1715';'1730';'1745'};
months = {'05';'06';'07';'08'};


cmap = hot;
ch12 = [];

%%% Importing file
filename = [disk, ':\Thesis\Data\ch12\', years{year}, '\', months{month}, '\', ...
    years{year}, months{month}, days{day}, hours{hour}, '.gra'];
fileID = fopen(filename,'r','l');
A = fread(fileID,inf,'int16=>int16');
fclose(fileID);
ch12 = cat(3,ch12,reshape(A,440,417));
ch12sel = ch12(idx_region_r,idx_region_c,:);

%%%% Figure and Axes
close all

axis image;

axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',regionlim_lat,...
    'MapLonLimit',regionlim_lon,...
    'FLineWidth',.5);

% Actual plot
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,ch12sel);

% Colorbar to the right
h = colorbar;      
ylabel(h, 'Reflectance (-)');

% hold on
% add_study_areas_to_plot_f('landes')

% hold on
% add_study_areas_to_plot_f('orleans')
% 
% %%% ADDING ADDITIONAL FOREST FOR DIFFERENT SIZES
% hold on
% add_study_areas_to_plot_f('addforest1')
% 
% hold on
% add_study_areas_to_plot_f('addforest2')
% 
hold on
add_study_areas_to_plot_f(regionname)