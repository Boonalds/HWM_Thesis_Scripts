disk = 'D';
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

box_lims
load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell
cmap = hot;

ch12 = [];
%%% Importing file
filename = [disk, ':\Thesis\Data\ch12\', years{year}, '\', months{month}, '\', ...
    years{year}, months{month}, days{day}, hours{hour}, '.gra'];
fileID = fopen(filename,'r','l');
A = fread(fileID,inf,'int16=>int16');
fclose(fileID);
ch12 = cat(3,ch12,reshape(A,440,417));
ch12filtered = ch12;
ch12filtered(ch12filtered > 250) = 250;
ch12filtered(ch12filtered < 100) = 100;
 
hrv_lat = full.hrv_lat;
hrv_lon = full.hrv_lon;

%%%% Figure and Axes
close all

axis image;

axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',europelims.regionbox.latlim,...
    'MapLonLimit',europelims.regionbox.lonlim,...
    'FLineWidth',.5);

% Actual plot
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,ch12filtered);

% Colorbar to the right
h = colorbar;      
ylabel(h, 'Reflectance (-)');

hold on
add_study_areas_to_plot_f('landes')

hold on
add_study_areas_to_plot_f('orleans')

%%% ADDING ADDITIONAL FOREST FOR DIFFERENT SIZES
hold on
add_study_areas_to_plot_f('forest1')

hold on
add_study_areas_to_plot_f('forest2')

hold on
add_study_areas_to_plot_f('forest3')


