%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%
disk = 'D';     % Disk that contains Matlab Path
check_exist = 1;      % Rerun the entire albedo extraction from the study areas (1 = yes, 0 = no)


month =  1;     % index (1-4) for {'05';'06';'07';'08'};
dec =  1;       % index (1-3)for {'01';'02';'03'};
hour = 8;       % index (1-12) for {'0600';'0700';'0800';'0900';'1000';'1100';...
% '1200';'1300';'1400';'1500';'1600';'1700';'1800'};

regionname = 'landes';



%%%%%%%%%%%%%%%
%%% LOADING %%%
%%%%%%%%%%%%%%%
box_lims                                       % Contains lat and lon limits for plotting areas
load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell


switch regionname
    case 'landes'
        % Landes properties
        filenameb = [disk, ':\Thesis\Data\Albedo\MODIS\geotiff\landes\2008_209\MCD43A4.A2008209.h17v04.005.2008239234554_Nadir_Reflectance_Band4'];
        r_lat = landeslims.regionbox.latlim;
        r_lon = landeslims.regionbox.lonlim;
        f_lat = landeslims.forestbox.latlim;
        f_lon = landeslims.forestbox.lonlim;
        nf1_lat = landeslims.nonforbox1.latlim;
        nf1_lon = landeslims.nonforbox1.lonlim;
        nf2_lat = landeslims.nonforbox2.latlim;
        nf2_lon = landeslims.nonforbox2.lonlim;
    case 'orleans'
        % Orleans properties
        filenameb = [disk, ':\Thesis\Data\Albedo\MODIS\hdf\landes\modis_test_mosaiced_2006201.Albedo_WSA_vis'];
        r_lat = orleanslims.regionbox.latlim;
        r_lon = orleanslims.regionbox.lonlim;
        f_lat = orleanslims.forestbox.latlim;
        f_lon = orleanslims.forestbox.lonlim;
        nf1_lat = orleanslims.nonforbox1.latlim;
        nf1_lon = orleanslims.nonforbox1.lonlim;
        nf2_lat = orleanslims.nonforbox2.latlim;
        nf2_lon = orleanslims.nonforbox2.lonlim;
    otherwise
        warning('Unknown regionname.')
end


if check_exist == 1
    
    checkfile = [disk ':\Thesis\Data\matlab\albedo_values\albedo_values_studyareas_' regionname '_modis_' num2str(month) '_' num2str(dec) '_' num2str(hour) '.mat'];
    checkfile2 = [disk ':\Thesis\Data\matlab\albedo_values\albedo_values_studyareas_' regionname '_own_' num2str(month) '_' num2str(dec) '_' num2str(hour) '.mat'];
    
    if (exist(checkfile, 'file')) == 2 && (exist(checkfile2, 'file'))
        quitvar = 1;
    else
        disp('Script C2: Albedo value extraction not yet done.. running script..');
        quitvar = 2;
    end
else
    quitvar = 2;
end






%%%%%%%%%%%%%
%%% CORE  %%%
%%%%%%%%%%%%%

%%% OWN
% 2009-2013
filenamea = [disk, ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_2009_2013_no_outliers.mat'];
Reflstructure = load(filenamea);
A = Reflstructure.surfrefl(month,dec,hour,:,:);
B = squeeze(A);
C = double(B(:));
K = rot90(B,3);
own_rasterSize = size(K);
Refmat2 = makerefmat('RasterSize', own_rasterSize, 'Latlim', r_lat, 'Lonlim', r_lon);


%%% MODIS
[albedo, R] = geotiffread(filenameb);
albedo = double(albedo);
albedo(albedo == 32767) = NaN;  % fill values
albedo(albedo > 32767) = NaN;    % valid range
albedo(albedo < 0) = NaN;    % valid range
albedo = albedo*(0.0001);     % Scale factor & conversion from DN to percentage
albedo(albedo > 0.32767) = NaN;    % valid range
albedo = flipud(albedo);

mod_rasterSize = R.RasterSize;
mod_latLim = R.LatitudeLimits;
mod_lonLim = R.LongitudeLimits;
Refmat = makerefmat('RasterSize', mod_rasterSize, 'Latlim', mod_latLim, 'Lonlim', mod_lonLim);

% Plot Modis
cmap = 'pink';

close all
figure

worldmap(albedo,Refmat);
meshm(albedo, Refmat);
colormap(cmap);
colorbar;



%%% CREATE MAPS FOR COMPARISON
albedo_c = albedo;
albedo_c(albedo_c < 0.03) = 0;
albedo_c(albedo_c >= 0.03 & albedo_c < 0.06) =0.04;
albedo_c(albedo_c >= 0.06) = 0.08;


% PLOT modis classified
cmap1 = [0.0, 0.0, 0.4;
    0.0, 0.2, 0.0;
    0.0, 1.0 0.4];

figure

% modis
worldmap(albedo_c,Refmat);
meshm(albedo_c, Refmat);
colormap(cmap1);
labels = {'Water','Forest','Non-forest'};
lcolorbar(labels,'fontweight','bold');








