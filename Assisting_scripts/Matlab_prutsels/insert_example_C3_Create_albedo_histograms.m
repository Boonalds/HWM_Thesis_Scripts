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
shore = load('Data\matlab\france_shore.dat');


%%%%%%%%%%%%%%%
%%% LOADING %%%
%%%%%%%%%%%%%%%
box_lims                                       % Contains lat and lon limits for plotting areas
load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell


switch regionname
    case 'landes'
        % Landes properties
        filenameb = [disk, ':\Thesis\Data\Albedo\MODIS\hdf\landes\MCD43A3.A2006201.h17v04.005.2008142053635.hdf'];
        r_lat = landeslims.regionbox.latlim;
        r_lon = landeslims.regionbox.lonlim;
        f_lat = landeslims.forestbox.latlim;
        f_lon = landeslims.forestbox.lonlim;
        nf1_lat = landeslims.nonforbox1.latlim;
        nf1_lon = landeslims.nonforbox1.lonlim;
        nf2_lat = landeslims.nonforbox2.latlim;
        nf2_lon = landeslims.nonforbox2.lonlim;
        hrv_lat = landes.hrv_lat;
        hrv_lon = landes.hrv_lon;
    case 'orleans'
        % Orleans properties
        filenameb = [disk, ':/Thesis/Data/Albedo/MODIS/orleans/2009/vis_actual/MCD43A.A2009161.h18v04.005.2009183134812_vis_actual.tif'];
        r_lat = orleanslims.regionbox.latlim;
        r_lon = orleanslims.regionbox.lonlim;
        f_lat = orleanslims.forestbox.latlim;
        f_lon = orleanslims.forestbox.lonlim;
        nf1_lat = orleanslims.nonforbox1.latlim;
        nf1_lon = orleanslims.nonforbox1.lonlim;
        nf2_lat = orleanslims.nonforbox2.latlim;
        nf2_lon = orleanslims.nonforbox2.lonlim;
        hrv_lat = orleans.hrv_lat;
        hrv_lon = orleans.hrv_lon;
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

%%% MODIS
% file_id = hdfgd('open', filenameb, 'rdonly');
% 
% % Read data from the file. 
% GRID_NAME='MOD_Grid_BRDF';
% grid_id = hdfgd('attach', file_id, GRID_NAME);
% 
% DATAFIELD_NAME='Albedo_BSA_Band1';
% 
% [data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);
% 
% % Convert the data to double type for plot.
% data=data1;
% data=double(data);
% 
% % Transpose the data to match the map projection.
% data=data';
% 
% % Retrieve grid dimension size information.
% [xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);
% 
% % Detach from the Grid object.
% hdfgd('detach', grid_id);
% 
% % Close the file.
% hdfgd('close', file_id);
% 
% % Read attributes from the data field.
% SD_id = hdfsd('start',filenameb, 'rdonly');
% sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
% sds_id = hdfsd('select',SD_id, sds_index);
% 
% 
% % Read fill value attribute.
% fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
% [fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);
% 
% % Read valid_range attribute. 
% range_index = hdfsd('findattr', sds_id, 'valid_range');
% [range, status] = hdfsd('readattr',sds_id, range_index);
% 
% % Read units attribute.
% units_index = hdfsd('findattr', sds_id, 'units');
% [units, status] = hdfsd('readattr',sds_id, units_index);
% 
% % Read scale_factor attribute.
% scale_index = hdfsd('findattr', sds_id, 'scale_factor');
% [scale, status] = hdfsd('readattr',sds_id, scale_index);
% 
% % Read add_offset attribute. 
% offset_index = hdfsd('findattr', sds_id, 'add_offset');
% [offset, status] = hdfsd('readattr',sds_id, offset_index);
% 
% % Terminate access to the data set.
% hdfsd('endaccess', sds_id);
% 
% % Close the file.
% hdfsd('end', SD_id);
% 
% % Replace the fill value with NaN.
% data(data==fillvalue) = NaN;
% 
% % Replace values outside of valid_range with NaN.
% data(data>range(2)) = NaN;
% data(data<range(1)) = NaN;
% 
% % Apply scale and offset, the equation is scale*(data-offset).
% data = scale*(data-offset);
% 
% % Plot the data using mapping toolbox.
% min_data=min(min(data));
% max_data=max(max(data));
% data_range=max_data-min_data;
% 
% 
% % latlim lonlim
% latlim = [39.82 50.00];
% lonlim = [-15.56 50.01];
% 
% 
% %%% Ploat
% 
% figure('Name', filenameb, 'Renderer', 'zbuffer', 'visible', 'on');
% axesm('MapProjection','sinusoid','Frame','on','Grid','on', ...
%       'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
%       'MeridianLabel','on','ParallelLabel','on', ...
%       'MLabelLocation', 4,'PLabelLocation', 1, ...
%       'MLineLocation', 4,'PLineLocation', 1);
% surfacem(latlim,lonlim,data);

% albedo=albedo1;
% albedo=double(albedo);
% 
% albedo=albedo';
% 
% %%% Remove fill values 
% albedo(albedo==32767) = NaN;
% % 
% % % Replace values outside of valid_range with NaN.
% albedo(albedo>32766) = NaN;
% albedo(albedo<0) = NaN;
% % 
% % % Apply scale and offset (according to  scale*(data-offset)  ).
% albedo = 0.001*(albedo-0);


%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%    Extracting albedo values for just study areas    %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%




    % %%%%%%%%% REFMATS & Progress tracker  %%%%%%%%%
    
    box_lims
    
%     mod_rasterSize = R.RasterSize;
%     mod_latLim = R.LatitudeLimits;
%     mod_lonLim = R.LongitudeLimits;
%     Refmat = makerefmat('RasterSize', mod_rasterSize, 'Latlim', mod_latLim, 'Lonlim', mod_lonLim);
    
    own_rasterSize = size(K);
    own_latLim = r_lat;
    own_lonLim = r_lon;
    Refmat2 = makerefmat('RasterSize', own_rasterSize, 'Latlim', own_latLim, 'Lonlim', own_lonLim);
    
    %cellsizes
    dx = (mod_lonLim(2)-mod_lonLim(1))/size(albedo,2);
    dy = (mod_latLim(2)-mod_latLim(1))/size(albedo,1);
    
    dxo = (own_lonLim(2)-own_lonLim(1))/size(K,2);  %dx own
    dyo = (own_latLim(2)-own_latLim(1))/size(K,1);  %dy own
    
    % Progress tracker:
    tt = ((((f_lat(2)-f_lat(1))/dy)*((f_lon(2)-f_lon(1))/dx))+...
        (((nf1_lat(2)-nf1_lat(1))/dy)*((nf1_lon(2)-nf1_lon(1))/dx))+...
        (((nf2_lat(2)-nf2_lat(1))/dy)*((nf2_lon(2)-nf2_lon(1))/dx)))+...
        ((((f_lat(2)-f_lat(1))/dyo)*((f_lon(2)-f_lon(1))/dxo))+...
        (((nf1_lat(2)-nf1_lat(1))/dyo)*((nf1_lon(2)-nf1_lon(1))/dxo))+...
        (((nf2_lat(2)-nf2_lat(1))/dyo)*((nf2_lon(2)-nf2_lon(1))/dxo)));
    ts = 1;
    
    
    if quitvar == 2
    %%%%%%% MODIS ALBEDO EXTRACTION %%%%%%%%%%
    mod_for_albedo = [];
    mod_nonfor1_albedo = [];
    mod_nonfor2_albedo = [];
    
    % forest
    l = 1;
    for i = f_lat(1):dy:f_lat(2)
        for j = f_lon(1):dx:f_lon(2)
            mod_for_albedo(l) = ltln2val(albedo, Refmat, i, j);
            l=l+1;
            ts = ts+1;
        end
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end
    
    %nonforest1
    l = 1;
    for i = nf1_lat(1):dy:nf1_lat(2)
        for j = nf1_lon(1):dx:nf1_lon(2)
            mod_nonfor1_albedo(l) = ltln2val(albedo, Refmat, i, j);
            l=l+1;
            ts = ts+1;
        end
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end
    
    % nonforest2
    l = 1;
    for i = nf2_lat(1):dy:nf2_lat(2)
        for j = nf2_lon(1):dx:nf2_lon(2)
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
    for i = f_lat(1):dyo:f_lat(2)
        for j = f_lon(1):dxo:f_lon(2)
            own_for_albedo(l) = ltln2val(K, Refmat2, i, j);
            l=l+1;
            ts = ts+1;
        end
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end
    
    %nonforest1
    l = 1;
    for i = nf1_lat(1):dyo:nf1_lat(2)
        for j = nf1_lon(1):dxo:nf1_lon(2)
            own_nonfor1_albedo(l) = ltln2val(K, Refmat2, i, j);
            l=l+1;
            ts = ts+1;
        end
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end
    
    % nonforest2
    l = 1;
    for i = nf2_lat(1):dyo:nf2_lat(2)
        for j = nf2_lon(1):dxo:nf2_lon(2)
            own_nonfor2_albedo(l) = ltln2val(K, Refmat2, i, j);
            l=l+1;
            ts = ts+1;
        end
        ct = ts/tt*100;
        disp(['Extracting albedo values.. Progress: ' num2str(ct) '%']);
    end
    
    
    %%% Adding the different albedo values together  ***
    mod_albedo_study = cat(2,mod_for_albedo,mod_nonfor1_albedo, mod_nonfor2_albedo);
    own_albedo_study = cat(2,own_for_albedo,own_nonfor1_albedo, own_nonfor2_albedo);
    
    %%% Saving the albedo values
    save(['Data\matlab\albedo_values\albedo_values_studyareas_' regionname '_modis_' num2str(month) '_' num2str(dec) '_' num2str(hour)
        ],'mod_albedo_study');
    save(['Data\matlab\albedo_values\albedo_values_studyareas_' regionname '_own_' num2str(month) '_' num2str(dec) '_' num2str(hour)],'own_albedo_study');
    
end

load([disk ':\Thesis\Data\matlab\albedo_values\albedo_values_studyareas_' regionname '_modis_' num2str(month) '_' num2str(dec) '_' num2str(hour) '.mat']);
load([disk ':\Thesis\Data\matlab\albedo_values\albedo_values_studyareas_' regionname '_own_' num2str(month) '_' num2str(dec) '_' num2str(hour) '.mat']);

% 
% 
% 
% min_data=min(min(albedo));
% max_data=max(max(albedo));
% data_range=max_data-min_data;
% 
% 
% f=figure('Name', filenameb, 'Renderer', 'zbuffer', 'visible', 'on');
% 
% axesm('MapProjection','sinusoid','Frame','on','Grid','on', ...
%       'MapLatLimit',r_lat,'MapLonLimit',r_lon, ...
%       'MeridianLabel','on','ParallelLabel','on', ...
%       'MLabelLocation', 4,'PLabelLocation', 1, ...
%       'MLineLocation', 4,'PLineLocation', 1);
% 
% surfacem(hrv_lat,hrv_lon,albedo);
% colormap('Jet');
% caxis([min_data max_data]); 
% colorbar('YTick', min_data:data_range/10.0:max_data);
% 
% % coast = load('france_shore.mat');
% % % plotm(coast.lat,coast.long,'k')
% % linem(shore(:,2),shore(:,1),'k')
% 
% 
% title({FILE_NAME;DATAFIELD_NAME}, 'Interpreter', 'None', ...
%     'FontSize',12,'FontWeight','bold');
% 
% % Change the value if you want to have more than 10 tick marks.
% ntickmarks = 10;
% granule = (max_data - min_data) / ntickmarks;
% h = colorbar('YTick', min_data:granule:max_data);
% 
% %%%%%%%%%%%%
% %%% PLOT %%%
% %%%%%%%%%%%%
% % close all
% % figure
% % 
% % subplot(2,2,1);
% % worldmap(K,Refmat2);
% % meshm(K, Refmat2);
% % title('Own Albedo map')
% % add_study_areas_to_plot_f(regionname)
% % 
% % subplot(2,2,2);
% % 
% % % Plot the data using mapping toolbox.
% % min_data=min(min(albedo));
% % max_data=max(max(albedo));
% % data_range=max_data-min_data;
% % 
% % 
% % f=figure('Name', filenameb, 'Renderer', 'zbuffer', 'visible', 'off');
% % 
% % axesm('MapProjection','sinusoid','Frame','on','Grid','on', ...
% %       'MapLatLimit',r_lat,'MapLonLimit',r_lon, ...
% %       'MeridianLabel','on','ParallelLabel','on', ...
% %       'MLabelLocation', 4,'PLabelLocation', 1, ...
% %       'MLineLocation', 4,'PLineLocation', 1);
% % 
% % surfacem(hrv_lat,hrv_lon,albedo);
% % colormap('Jet');
% % caxis([min_data max_data]); 
% % colorbar('YTick', min_data:data_range/10.0:max_data);
% % 
% % worldmap(albedoud, Refmat);
% % meshm(albedoud, Refmat);
% % title('MODIS Albedo map')
% % add_study_areas_to_plot_f(regionname)
% % 
% % hist(subplot(2,2,3),own_albedo_study,30)
% % title('Own map - Albedo values of study areas combined')
% % xlabel('Albedo value')
% % ylabel('count')
% % 
% % hist(subplot(2,2,4),mod_albedo_study,50)
% % title('MODIS map - Albedo values of study areas combined')
% % xlabel('Albedo value')
% % ylabel('count')
% % 
% % 
% % 
% % figure
% % 
% % hist(subplot(2,3,1), own_albedo_study(1:(length(own_albedo_study)/3)),20)
% % title('Own map - Albedo values of forest')
% % xlabel('Albedo value')
% % ylabel('count')
% % 
% % hist(subplot(2,3,2), own_albedo_study((length(own_albedo_study)/3)+1:2*(length(own_albedo_study)/3)),20)
% % title('Own map - Albedo values of non forest1')
% % xlabel('Albedo value')
% % ylabel('count')
% % 
% % hist(subplot(2,3,3), own_albedo_study(2*(length(own_albedo_study)/3)+1:end),20)
% % title('Own map - Albedo values of non forest2')
% % xlabel('Albedo value')
% % ylabel('count')
% % 
% % hist(subplot(2,3,4), mod_albedo_study(1:(length(mod_albedo_study)/3)),20)
% % title('MODIS map - Albedo values of forest')
% % xlabel('Albedo value')
% % ylabel('count')
% % 
% % hist(subplot(2,3,5), mod_albedo_study((length(mod_albedo_study)/3)+1:2*(length(mod_albedo_study)/3)),20)
% % title('MODIS map - Albedo values of non forest1')
% % xlabel('Albedo value')
% % ylabel('count')
% % 
% % hist(subplot(2,3,6), mod_albedo_study(2*(length(mod_albedo_study)/3)+1:end),20)
% % title('MODIS map - Albedo values of non forest2')
% % xlabel('Albedo value')
% % ylabel('count')