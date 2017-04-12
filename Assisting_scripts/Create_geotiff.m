function [] = C1_Create_geotiff(regionname, month, dec, hour)

%%%%%%%%%%%%%%%%%%   STEP C1 - Create geotiff   %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% This script creates a geotiff file from one of the  clean albedo
%%%%%% maps, for future processing.

disk = 'D';     % Disk that contains Matlab Path

month =  2;     % index (1-4) for {'05';'06';'07';'08'};
dec =  1;       % index (1-3)for {'01';'02';'03'};
hour = 1;       % index (1-12) for {'0600';'0700';'0800';'0900';'1000';'1100';...

%%%%%%%%%%%%%%%%%%%% 
%%% LOADING DATA %%%
%%%%%%%%%%%%%%%%%%%%
box_lims                                       % Contains lat and lon limits for plotting areas

switch regionname
    case 'landes'
        % Landes region limits
        latLim = landeslims.regionbox.latlim;
        lonLim = landeslims.regionbox.lonlim;
    case 'orleans'
        % Orleans region limits
        latLim = orleanslims.regionbox.latlim;
        lonLim = orleanslims.regionbox.lonlim;
    case 'forest1'
        % Orleans region limits
        latLim = forest1lims.regionbox.latlim;
        lonLim = forest1lims.regionbox.lonlim;
    case 'forest2'
        % Orleans region limits
        latLim = forest2lims.regionbox.latlim;
        lonLim = forest2lims.regionbox.lonlim;
    case 'forest3'
        % Orleans region limits
        latLim = forest3lims.regionbox.latlim;
        lonLim = forest3lims.regionbox.lonlim;
    otherwise
        warning('Unknown regionname.')
end

%%% Transforming own albedo map to a geotiff

% Load in data
filename = [disk, ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_2004_2008_no_outliers.mat'];
Reflstructure = load(filename);
A = Reflstructure.surfrefl(month,dec,hour,:,:);
B = squeeze(A);
B = rot90(B,3);

% Make refmat
rasterSize = size(B);
Refmat = makerefmat('RasterSize', rasterSize, 'Latlim', latLim, 'Lonlim', lonLim);

% Write geotiff
outfilename = filename(1:end-3);
outfilename = [outfilename, 'tif'];

geotiffwrite(outfilename,B,Refmat);

% %%% Test Plot %%%
% [albedo, R] = geotiffread(outfilename);
% 
% worldmap(albedo, Refmat);
% meshm(albedo, Refmat);
% title('own Albedo')
