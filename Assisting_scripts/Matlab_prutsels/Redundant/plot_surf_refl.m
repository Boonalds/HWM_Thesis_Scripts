% Script that plots the surface reflectance based on the months, 10day
% period within a month and the hour. Currently based on data of the years
% 2004-2008. Only for the landes area.

%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%

disk = 'D';     % Disk that contains Matlab Path
month =  2;     % index (1-4) for {'05';'06';'07';'08'};
dec =  1;       % index (1-3)for {'01';'02';'03'};
hour = 1;       % index (1-12) for {'0600';'0700';'0800';'0900';'1000';'1100';...
                    % '1200';'1300';'1400';'1500';'1600';'1700';'1800'};

                    
%%%%%%%%%%%%%%%
%%% LOADING %%%
%%%%%%%%%%%%%%%
box_lims                                       % Contains lat and lon limits for plotting areas
load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell
shore = load('Data\matlab\france_shore.dat');   % Shoreline file



%%%%%%%%%%%%%
%%% CORE  %%%
%%%%%%%%%%%%%

% Loading in reflectance files and extracting reflectance values
%2004-2008
filename = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2004_2008.mat'];
Reflstructure = load(filename);
A = Reflstructure.surfrefl(month,dec,hour,:,:);
B = squeeze(A);

% 2009-2013
filename = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2009_2013.mat'];
Reflstructure = load(filename);
C = Reflstructure.surfrefl(month,dec,hour,:,:);
D = squeeze(C);


%%%%%%%%%%%%%%%%
%%% Plotting %%%
%%%%%%%%%%%%%%%%
close all

%%% Figure 1 - Surface reflectance 2004-2008
% Setting Axes and Projection
figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);

cmap = gray;
colormap(cmap);

% Actual plot
pcolorm(landes.hrv_lat,landes.hrv_lon,B);
title('Reflectance 2004-2008')

linem(shore(:,2),shore(:,1),'k');   % Add shoreline
colorbar;                           % Colorbar to the right

hold on

add_study_areas_to_plot

%%% Figure 2 - Surface reflectance 2009-2013
% Setting Axes and Projection
figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);

% Actual plot
pcolorm(landes.hrv_lat,landes.hrv_lon,D);
title('Reflectance 2009-2013')

linem(shore(:,2),shore(:,1),'k');   % Add shoreline
colorbar;                           % Colorbar to the right