%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%
disk = 'D';     % Disk that contains Matlab Path
rerun = 0;      % Rerun the entire albedo extraction from the study areas (1 = yes, 0 = no)


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
        filenameb = [disk, ':/Thesis/Data/Albedo/2009/MCD43A.A2009121.h17v04.005.2009140014504_vis_actual.tif'];
        r_lat = landeslims.regionbox.latlim;
        r_lon = landeslims.regionbox.lonlim;
        f_lat = landeslims.forestbox.latlim;
        f_lon = landeslims.forestbox.lonlim;
        nf1_lat = landeslims.nonfor1.latlim;
        nf1_lon = landeslims.nonfor1.lonlim;
        nf2_lat = landeslims.nonfor2.latlim;
        nf2_lon = landeslims.nonfor2.lonlim;
    case 'orleans'
        % Orleans properties
        filenameb = [disk, ':/Thesis/Data/Albedo/MODIS/orleans/2009/vis_actual/MCD43A.A2009161.h18v04.005.2009183134812_vis_actual.tif'];
        r_lat = orleanslims.regionbox.latlim;
        r_lon = orleanslims.regionbox.lonlim;
        f_lat = orleanslims.forestbox.latlim;
        f_lon = orleanslims.forestbox.lonlim;
        nf1_lat = orleanslims.nonfor1.latlim;
        nf1_lon = orleanslims.nonfor1.lonlim;
        nf2_lat = orleanslims.nonfor2.latlim;
        nf2_lon = orleanslims.nonfor2.lonlim;
    otherwise
        warning('Unknown regionname.')
end

%%%%%%%%%%%%%
%%% CORE  %%%
%%%%%%%%%%%%%

%%% OWN
% 2009-2013
filenamea = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2009_2013_no_outliers.mat'];
Reflstructure = load(filenamea);
A = Reflstructure.surfrefl(month,dec,hour,:,:);
B = squeeze(A);
C = double(B(:));
K = rot90(B,3);

%%% MODIS
[albedo, R] = geotiffread(filenameb);

albedo = double(albedo);
albedo(albedo >= 0.1 | albedo <= 0) = 0.01;
albedo = albedo*1000;
D = albedo(:);
D(D < 20) = [];
albedoud = flipud(albedo);

%%%%%%%%%%%%
%%% PLOT %%%
%%%%%%%%%%%%

close all
figure

hist(subplot(1,2,1),C,50)
title('Own map - albedo values of entire area')
xlabel('Albedo value')
ylabel('count')
        
hist(subplot(1,2,2),D,80)
title('MODIS map - albedo values of entire area')
xlabel('Albedo value')
ylabel('count')

%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%    Extracting albedo values for just study areas    %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% 

% %%%%%%%%% REFMATS & Progress tracker  %%%%%%%%%

if rerun == 1
    box_lims

    mod_rasterSize = R.RasterSize;
    mod_latLim = R.LatitudeLimits;
    mod_lonLim = R.LongitudeLimits;
    Refmat = makerefmat('RasterSize', mod_rasterSize, 'Latlim', mod_latLim, 'Lonlim', mod_lonLim);

    own_rasterSize = size(K);
    own_latLim = landeslims.regionbox.latlim;
    own_lonLim = landeslims.regionbox.lonlim;
    Refmat2 = makerefmat('RasterSize', own_rasterSize, 'Latlim', own_latLim, 'Lonlim', own_lonLim);

    %cellsizes
    dx = (mod_lonLim(2)-mod_lonLim(1))/size(albedo,2);
    dy = (mod_latLim(2)-mod_latLim(1))/size(albedo,1);

    dxo = (own_lonLim(2)-own_lonLim(1))/size(K,2);  %dx own
    dyo = (own_latLim(2)-own_latLim(1))/size(K,1);  %dy own

    % Progress tracker:
    tt = ((((landeslims.forestbox.latlim(2)-landeslims.forestbox.latlim(1))/dy)*...
        ((landeslims.forestbox.lonlim(2)-landeslims.forestbox.lonlim(1))/dx))+...
        (((landeslims.nonforbox1.latlim(2)-landeslims.nonforbox1.latlim(1))/dy)*...
        ((landeslims.nonforbox1.lonlim(2)-landeslims.nonforbox1.lonlim(1))/dx))+...
        (((landeslims.nonforbox2.latlim(2)-landeslims.nonforbox2.latlim(1))/dy)*...
        ((landeslims.nonforbox2.lonlim(2)-landeslims.nonforbox2.lonlim(1))/dx)))+...
        ((((landeslims.forestbox.latlim(2)-landeslims.forestbox.latlim(1))/dyo)*...
        ((landeslims.forestbox.lonlim(2)-landeslims.forestbox.lonlim(1))/dxo))+...
        (((landeslims.nonforbox1.latlim(2)-landeslims.nonforbox1.latlim(1))/dyo)*...
        ((landeslims.nonforbox1.lonlim(2)-landeslims.nonforbox1.lonlim(1))/dxo))+...
        (((landeslims.nonforbox2.latlim(2)-landeslims.nonforbox2.latlim(1))/dyo)*...
        ((landeslims.nonforbox2.lonlim(2)-landeslims.nonforbox2.lonlim(1))/dxo)));
    ts = 1;

    %%%%%%% MODIS ALBEDO EXTRACTION %%%%%%%%%%
    mod_for_albedo = [];
    mod_nonfor1_albedo = [];
    mod_nonfor2_albedo = [];

    % forest
    l = 1;
    for i = landeslims.forestbox.latlim(1):dy:landeslims.forestbox.latlim(2)
        for j = landeslims.forestbox.lonlim(1):dx:landeslims.forestbox.lonlim(2)
            mod_for_albedo(l) = ltln2val(albedo, Refmat, i, j);
            l=l+1;
            ts = ts+1;
        end 
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end

    %nonforest1
    l = 1;
    for i = landeslims.nonforbox1.latlim(1):dy:landeslims.nonforbox1.latlim(2)
        for j = landeslims.nonforbox1.lonlim(1):dx:landeslims.nonforbox1.lonlim(2)
            mod_nonfor1_albedo(l) = ltln2val(albedo, Refmat, i, j);
            l=l+1;
            ts = ts+1;
        end 
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end

    % nonforest2
    l = 1;
    for i = landeslims.nonforbox2.latlim(1):dy:landeslims.nonforbox2.latlim(2)
        for j = landeslims.nonforbox2.lonlim(1):dx:landeslims.nonforbox2.lonlim(2)
            mod_nonfor2_albedo(l) = ltln2val(albedo, Refmat, i, j);
            l=l+1;
            ts = ts+1;
        end 
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end


    %%%%%%%% OWN ALBEDO EXTRACTION %%%%%%%%%
    own_for_albedo = [];
    own_nonfor1_albedo = [];
    own_nonfor2_albedo = [];

    % forest
    l = 1;
    for i = landeslims.forestbox.latlim(1):dyo:landeslims.forestbox.latlim(2)
        for j = landeslims.forestbox.lonlim(1):dxo:landeslims.forestbox.lonlim(2)
            own_for_albedo(l) = ltln2val(K, Refmat2, i, j);
            l=l+1;
            ts = ts+1;
        end 
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end

    %nonforest1
    l = 1;
    for i = landeslims.nonforbox1.latlim(1):dyo:landeslims.nonforbox1.latlim(2)
        for j = landeslims.nonforbox1.lonlim(1):dxo:landeslims.nonforbox1.lonlim(2)
            own_nonfor1_albedo(l) = ltln2val(K, Refmat2, i, j);
            l=l+1;
            ts = ts+1;
        end 
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end

    % nonforest2
    l = 1;
    for i = landeslims.nonforbox2.latlim(1):dyo:landeslims.nonforbox2.latlim(2)
        for j = landeslims.nonforbox2.lonlim(1):dxo:landeslims.nonforbox2.lonlim(2)
            own_nonfor2_albedo(l) = ltln2val(K, Refmat2, i, j);
            l=l+1;
            ts = ts+1;
        end 
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end
end


%%% Adding the different albedo values together  ***
mod_albedo_study = cat(2,mod_for_albedo,mod_nonfor1_albedo, mod_nonfor2_albedo);
own_albedo_study = cat(2,own_for_albedo,own_nonfor1_albedo, own_nonfor2_albedo);

%%% Saving the albedo values
save(['Data\matlab\albedo_values_studyareas_' regionname '_modis_' num2str(month) '_' num2str(dec) '_' num2str(hour)
],'mod_albedo_study');
save(['Data\matlab\albedo_values_studyareas_' regionname '_own_' num2str(month) '_' num2str(dec) '_' num2str(hour)],'own_albedo_study');

%%%%%%%%%%%%
%%% PLOT %%%
%%%%%%%%%%%%
close all
figure

subplot(2,2,1);
worldmap(K,Refmat2);
meshm(K, Refmat2);
title('Own Albedo map')
add_study_areas_to_plot

subplot(2,2,2);   
worldmap(albedoud, Refmat);
meshm(albedoud, Refmat);
title('MODIS Albedo map')
add_study_areas_to_plot

hist(subplot(2,2,3),own_albedo_study,30)
title('Own map - Albedo values of study areas combined')
xlabel('Albedo value')
ylabel('count')
        
hist(subplot(2,2,4),mod_albedo_study,50)
title('MODIS map - Albedo values of study areas combined')
xlabel('Albedo value')
ylabel('count')



figure

hist(subplot(2,3,1), own_albedo_study(1:(length(own_albedo_study)/3)),20)
title('Own map - Albedo values of forest')
xlabel('Albedo value')
ylabel('count')

hist(subplot(2,3,2), own_albedo_study((length(own_albedo_study)/3)+1:2*(length(own_albedo_study)/3)),20)
title('Own map - Albedo values of non forest1')
xlabel('Albedo value')
ylabel('count')

hist(subplot(2,3,3), own_albedo_study(2*(length(own_albedo_study)/3)+1:end),20)
title('Own map - Albedo values of non forest2')
xlabel('Albedo value')
ylabel('count')

hist(subplot(2,3,4), mod_albedo_study(1:(length(mod_albedo_study)/3)),20)
title('MODIS map - Albedo values of forest')
xlabel('Albedo value')
ylabel('count')

hist(subplot(2,3,5), mod_albedo_study((length(mod_albedo_study)/3)+1:2*(length(mod_albedo_study)/3)),20)
title('MODIS map - Albedo values of non forest1')
xlabel('Albedo value')
ylabel('count')

hist(subplot(2,3,6), mod_albedo_study(2*(length(mod_albedo_study)/3)+1:end),20)
title('MODIS map - Albedo values of non forest2')
xlabel('Albedo value')
ylabel('count')