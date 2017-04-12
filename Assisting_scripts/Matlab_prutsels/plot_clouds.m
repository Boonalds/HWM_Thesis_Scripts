% Plotting 4 images of the  clouds

%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%

disk = 'D';     % Disk that contains Matlab Path

%Indexes
year = 2;        % index (1-10) for {'2004';'2005';'2006';'2007';'2008';...
                    % '2009';'2010';'2011';'2012';'2013'}
month =  3;     % index (1-4) for {'05';'06';'07';'08'};
day = 05;        % day = day of month
hour = 1;       % index (1-48) for {'0600';'0615';'0630';'0645';'0700';'0715';'0730';'0745';...
                   %'0800';'0815';'0830';'0845';'0900';'0915';'0930';'0945';...
                   %'1000';'1015';'1030';'1045';'1100';'1115';'1130';'1145';...
                   %'1200';'1215';'1230';'1245';'1300';'1315';'1330';'1345';...
                   %'1400';'1415';'1430';'1445';'1500';'1515';'1530';'1545';...
                   %'1600';'1615';'1630';'1645';'1700';'1715';'1730';'1745'};

                   
%%% Conversion to full names
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

           
                    
%%%%%%%%%%%%%%%
%%% LOADING %%%
%%%%%%%%%%%%%%%
box_lims                                       % Contains lat and lon limits for plotting areas
load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell
shore = load('Data\matlab\france_shore.dat');   % Shoreline file

idx_region_r = 220:416;
idx_region_c = 69:186;

%%%%%%%%%%%%%%%%
%%% Plotting %%%
%%%%%%%%%%%%%%%%
close all

%%%%% Figure 1 - Clouds %%%

%%%%% GOOD DATA
%2007 06 08 1400


%%% Load reflectance as background
% assign right decade
if day < 11
    dec = 1;
  elseif day >= 11 && day < 21
    dec = 2;
  else
    dec = 3;
end
% round index up to whole hours, needed for refl structure
hridx = ceil(hour/4);

%load in right reflectance file
filename = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2004_2008.mat'];
filenameload = load(filename);
refl = squeeze(filenameload.surfrefl(month,dec,hridx,:,:));

%%% Load in clouds
filename = [disk, ':\Thesis\Data\matlab\hrv_cloudflag_landes_2004_2008_10.mat'];
filenameload = load(filename);

clouds = squeeze(filenameload.cloudflag_10(year,month,day,hour,:,:));
clouds = int16(clouds);
% hist(double(cloud(:)))


filename = [disk, ':\Thesis\Data\ch12\' years{year} '\' months{month} '\' ...
                    years{year} months{month} days{day} hours{hour} '.gra'];
fileID = fopen(filename,'r','l');
A = fread(fileID,inf,'int16=>int16');
fclose(fileID);

ch12 = reshape(A,440,417);
ch12sel = ch12(idx_region_r,idx_region_c,:);  % Figure 1

% Assign higher reflectance value to pixels with that contain a clouds
reflV = refl(:);
cloudsV = clouds(:);
ch12selV = ch12sel(:);

for i = 1:length(reflV);
    if cloudsV(i) == 1;
        reflV(i) = ch12selV(i);
    else
        reflV(i) = reflV(i);
    end
end

reflF = reshape(reflV,197,118);   %%% FIGURE 3

reflF2 = refl;
cloudpxlvaluef3 = max(refl(:))*1.1;   % assigning clouds to be 10% brighter than max bg refl
reflF2(clouds == 1) = cloudpxlvaluef3; %%% FIGURE 2

cloudshad = refl;
shadpixelval = (min(reflV)*0.9);
cloudshad(clouds == 2) = shadpixelval; %%% FIGURE 4


%%%%%%%%%%%%%%%%
%%% Plotting %%%
%%%%%%%%%%%%%%%%
close all

%%% Final plotting

figure

%%Figure 1 - Raw signal
subplot(2,2,1);
axis image;

axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);
cmap = gray;
colormap(cmap);
pcolorm(landes.hrv_lat,landes.hrv_lon,ch12sel);
title('Raw Image');
colorbar;

%%Figure 2 - Cloud assigned pixels removed
subplot(2,2,2);
axis image;

axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);
cmap = gray;
colormap(cmap);
pcolorm(landes.hrv_lat,landes.hrv_lon,reflF2);
title('Pixels classified as clouds masked out');
colorbar;

%%Figure 3 - Cloud assigned pixels with original reflectances
subplot(2,2,3)
axis image;

axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);
cmap = gray;
colormap(cmap);
pcolorm(landes.hrv_lat,landes.hrv_lon,reflF);
title('Original clouds in the masked pixels');
colorbar;

%%Figure 2 - Cloud shadows masked out (to black)
subplot(2,2,4);
axis image;

axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);
cmap = gray;
colormap(cmap);
pcolorm(landes.hrv_lat,landes.hrv_lon,cloudshad);
title('Pixels classified as cloud SHADOW masked out');
colorbar;

%linem(shore(:,2),shore(:,1),'-k', 'LineWidth', .5 );   % Add shoreline
