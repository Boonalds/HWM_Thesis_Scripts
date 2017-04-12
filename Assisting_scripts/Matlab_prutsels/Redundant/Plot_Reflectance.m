clear

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
albedo(albedo >= 0.1 | albedo <= 0) = 0;
albedo = albedo*10;

mod_rasterSize = R.RasterSize;
mod_latLim = R.LatitudeLimits;
mod_lonLim = R.LongitudeLimits;

Refmat = makerefmat('RasterSize', mod_rasterSize, 'Latlim', mod_latLim, 'Lonlim', mod_lonLim);

%%% Own albedo
filenamea = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2004_2008_no_outliers.mat'];
Reflstructure = load(filenamea);
A = Reflstructure.surfrefl(month,dec,hour,:,:);
B = squeeze(A);

% Refmat
own_rasterSize = size(B);
own_latLim = landeslims.regionbox.latlim;
own_lonLim = landeslims.regionbox.lonlim;
Refmat2 = makerefmat('RasterSize', own_rasterSize, 'Latlim', own_latLim, 'Lonlim', own_lonLim);

%%% Merging

%%% intersecting

% Cell sizes 
xlength_mod = (mod_latLim(2)-mod_latLim(1))/mod_rasterSize(1);  %Modis
ylength_mod = (mod_lonLim(2)-mod_lonLim(1))/mod_rasterSize(2);

xlength_own = (own_latLim(2)-own_latLim(1))/own_rasterSize(1);  %Own map
ylength_own = (own_lonLim(2)-own_lonLim(1))/own_rasterSize(2);

% Copying cells that overlap
own = B;
mod = albedo;
mod_overlap = [];
own_overlap = [];

l = 0;

% MODIS map
for j = 1:mod_rasterSize(1)
    ycoord = mod_latLim(1)+(j-1)*ylength_mod;
    if ycoord >= own_latLim(1) && ycoord <= own_latLim(2)
        k=0;
        l=l+1;
        for i = 1:mod_rasterSize(2)
            xcoord = mod_lonLim(1)+(i-1)*xlength_mod;
            if xcoord >= own_lonLim(1) && xcoord <= own_lonLim(2)
                k=k+1;           
                mod_overlap(l,k) = mod(j,i);
            end
        end       
    end
end


l = 0;
% Own map
for j = 1:own_rasterSize(1)
    ycoord = own_latLim(1)+(j-1)*ylength_own;
    if ycoord >= mod_latLim(1) && ycoord <= mod_latLim(2)
        k=0;
        l=l+1;
        for i = 1:own_rasterSize(2)
            xcoord = own_lonLim(1)+(i-1)*xlength_own;
            if xcoord >= mod_lonLim(1) && xcoord <= mod_lonLim(2)
                k=k+1;           
                own_overlap(l,k) = own(j,i);
            end
        end       
    end
end



% Refmat
overlap_rasterSize_mod = size(mod_overlap);
overlap_rasterSize_own = size(own_overlap);
overlap_latLim = [max(own_latLim(1),mod_latLim(1)) min(own_latLim(2),mod_latLim(2))];
overlap_lonLim = [max(own_lonLim(1),mod_lonLim(1)) min(own_lonLim(2),mod_lonLim(2))];

Refmat_mod_overlap = makerefmat('RasterSize', overlap_rasterSize_mod, 'Latlim', overlap_latLim, 'Lonlim', overlap_lonLim);
Refmat_own_overlap = makerefmat('RasterSize', overlap_rasterSize_own, 'Latlim', overlap_latLim, 'Lonlim', overlap_lonLim);

% Translate and rotate
mod_overlap = imrotate(mod_overlap, 90);

% resizem()   For resizing grid cells


[C,RC] = imfuse(albedo, own, 'method', 'falsecolor');







%%%%%%%%%%%%%%%%%%%%%%%%%

%%% NEWNEWNEW %%%

close all

worldmap(B,Refmat2);
meshm(B, Refmat2);










%%%%%%%%%%%%%%%%%%%%
%%%   PLOTTING   %%%
%%%%%%%%%%%%%%%%%%%%


%%% Overlap
figure

% Modis
mapshow(mod_overlap, Refmat_mod_overlap);
% set(gca,'YDir','reverse');
title('MODIS map of overlap area')


figure

% Modis

D = (own_overlap-80)/20;
mapshow(D, Refmat_own_overlap);
% set(gca,'YDir','reverse');
title('own map of overlap area')

%%% Full albedo maps
% MODIS Albedo
figure
subplot(1,2,1);

mapshow(albedo, Refmat);
% set(gca,'YDir','reverse');
title('MODIS Albedo')

% Own Albedo
subplot(1,2,2);

axis image
axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);

% Actual plot
pcolorm(landes.hrv_lat,landes.hrv_lon,B);
title('Own Albedo')

linem(shore(:,2),shore(:,1),'k');   % Add shoreline
colorbar;                           % Colorbar to the right

%%% Composite
figure
image(C);
% set(gca,'YDir','reverse');
title('Composite')

%%%%