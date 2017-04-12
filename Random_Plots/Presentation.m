%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%
%'landes',4,2,8,31
%%% good data: 4-2-8-30 %'landes',4,2,8,31
%%% good data animation: 3-3-15-18 +++
%function [] = Plot_raw_images(regionname, year, month, day, hour) 

regionname = 'landes';
year = 4;
month = 2;
day =  8;
hour = 31;
cl_t = 27;

disk = 'G';     % Disk that contains Matlab Path
% regionname = 'orleans';

%Indexes
% year = 3;        % index (1-10) for {'2004';'2005';'2006';'2007';'2008';...
%                     % '2009';'2010';'2011';'2012';'2013'}
% month =  3;     % index (1-4) for {'05';'06';'07';'08'};
% day = 15;        % day = day of month
% hour = 28;       % index (1-48) for {'0600';'0615';'0630';'0645';'0700';'0715';'0730';'0745';...
%                    %'0800';'0815';'0830';'0845';'0900';'0915';'0930';'0945';...
%                    %'1000';'1015';'1030';'1045';'1100';'1115';'1130';'1145';...
%                    %'1200';'1215';'1230';'1245';'1300';'1315';'1330';'1345';...
%                    %'1400';'1415';'1430';'1445';'1500';'1515';'1530';'1545';...
%                    %'1600';'1615';'1630';'1645';'1700';'1715';'1730';'1745'};
%                    
%%% For conversion to full (string) names;
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

%%% Select right decade 
if day < 11
    dec = 1;
  elseif day >= 11 && day < 21
    dec = 2;
  else
    dec = 3;
end


%%%%%%%%%%%%%%%
%%% LOADING %%%
%%%%%%%%%%%%%%%

load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell
shore = load('Data\matlab\france_shore.dat');   % Shoreline file
box_lims
cmap = gray;

switch regionname
    case 'landes'
        % index for landes cutout
        region_lat = landeslims.regionbox.latlim;
        region_lon = landeslims.regionbox.lonlim;
        hrv_lat = landes.hrv_lat;
        hrv_lon = landes.hrv_lon;
        idx_region_r = 220:416;
        idx_region_c = 69:186;
    case 'orleans'
        % index for orleans cutout
        region_lat = orleanslims.regionbox.latlim;
        region_lon = orleanslims.regionbox.lonlim;
        hrv_lat = orleans.hrv_lat;
        hrv_lon = orleans.hrv_lon;
        idx_region_r = 40:233;
        idx_region_c = 274:382;
    otherwise
        warning('Unknown regionname.')
end


%%%%%%%%%%%%
%%% CORE %%%
%%%%%%%%%%%%

ch12 = [];
%%% Importing file
filename = [disk, ':\Thesis\Data\ch12\', years{year}, '\', months{month}, '\', ...
    years{year}, months{month}, days{day}, hours{hour}, '.gra'];
fileID = fopen(filename,'r','l');
A = fread(fileID,inf,'int16=>int16');
fclose(fileID);
ch12 = reshape(A,440,417);

% idx_region_r_s = 289:335;
% idx_region_c_s = 147:173;
% 
% for i=idx_region_r_s(1):idx_region_r_s(end)
%     ch12(i,idx_region_c_s,:) = 250;
% end

ch12sel = ch12(idx_region_r,idx_region_c,:);  % Selecting right area

ch12sel(ch12sel > 350) = 350;
ch12sel(ch12sel < 100) = 100;



%%%%%%%%%%%%%%%%% 1s and 0s MAP   %%%%%%%%%%%%%%%%%
if day < 11
    p = 1;
elseif day >= 11 && day < 21
    p = 2;
else
    p = 3;
end

hridx = ceil(hour/4);


filename_bg = [disk, ':\Thesis\Data\matlab\reflectance\surface_reflectance_landes_2004_2008_no_outliers.mat'];
Reflstructure = load(filename_bg);
surfrefl = squeeze(Reflstructure.surfrefl(month,p,hridx,:,:));

cloud_map = zeros(size(ch12sel),'int8');
cloud_map(ch12sel > (surfrefl+cl_t)) = 1;



%%%% Figure and Axes
close all

%%% Raw Image
figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',region_lat,...
    'MapLonLimit',region_lon,...
    'FLineWidth',.5);

% Actual plot
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,ch12sel);

% Add shoreline
linem(shore(:,2),shore(:,1),'y');   

% Colorbar to the right
h = colorbar;    
h.Label.Position = [1.9 187 0];
ylabel(h, 'Reflectance (-)');




%%% Background surface reflectance
figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',region_lat,...
    'MapLonLimit',region_lon,...
    'FLineWidth',.5);

% Actual plot
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,surfrefl);
caxis([100,350])

% Add shoreline
linem(shore(:,2),shore(:,1),'y');   

% Colorbar to the right
h = colorbar;    
h.Label.Position = [1.9 187 0];
ylabel(h, 'Reflectance (-)');
add_study_areas_to_plot


%%% Classified image
figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',region_lat,...
    'MapLonLimit',region_lon,...
    'FLineWidth',.5);

% Actual plot
colormap(cmap);
pcolorm(hrv_lat,hrv_lon,cloud_map);

% Add shoreline
linem(shore(:,2),shore(:,1),'y');   
add_study_areas_to_plot

