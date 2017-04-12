function [] = D2_Extract_cloud_pixels_study_areas(disk, cl_t)
disp('Script D2 started running.');
% Extracting cloud pixel data for the study areas. This script is purely
% for extracting the data from all the timesteps in 5 years for an area.
% cl_t = Cloud threshold, difference in reflectance between cloud and background before it is classified as cloud.

statistics = 0;     % Add statistics   (1 = yes/0 = no)
plotting = 0;       % Add plots   (1 = yes/0 = no)
check_exist = 1;

%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%

%%% For conversion to full (string) names;
years = {'2004';'2005';'2006';'2007';'2008';'2009';'2010';'2011';'2012';'2013'};
% for looping through all areas
rgnnames = {'landes', 'orleans', 'forest1', 'forest2', 'forest3'};
yrs = [1,5,6,10];


%%% loading

box_lims                                       % Contains lat and lon limits for plotting areas
load Data\hrv_grid\hrv_grid;                   % Contains lat and lon data for each cell


ct=0; % Progress counter
tt = 5*2; % 5 regions, 2 periods of time
for a = 1:5
    regionname = rgnnames{a};
    for b = 1:2
        yr_idx = yrs(b*2-1):yrs(b*2);
        
        %%%%%%%%%%%%% CHECK EXISTENCE %%%%%%%%%%%
        if check_exist == 1
            
            checkfile = [disk ':\Thesis\Data\matlab\cloud_data\' regionname '\cloud_data_forest_' regionname '_' years{yr_idx(1)} '_' years{yr_idx(end)} '_' num2str(cl_t) '.mat'];
            if exist(checkfile, 'file') == 2
                quitvar = 1;
                show_p = 0;
                disp(['Script D2 - Map of ' regionname ' (' years{yr_idx(1)} '-' years{yr_idx(end)} ') processed, skipping this step']);
            else
                show_p = 1;
                quitvar = 2;
            end
        else
            quitvar = 2;
        end
        
        if quitvar == 2
            
            %%%% Load in region specifics
            switch regionname
                case 'landes'
                    % landes study area
                    hrv_lat = landes.hrv_lat;
                    hrv_lon = landes.hrv_lon;
                    forestlim_lat = landeslims.forestbox.latlim;
                    forestlim_lon = landeslims.forestbox.lonlim;
                    nonfor1lim_lat = landeslims.nonforbox1.latlim;
                    nonfor1lim_lon = landeslims.nonforbox1.lonlim;
                    nonfor2lim_lat = landeslims.nonforbox2.latlim;
                    nonfor2lim_lon = landeslims.nonforbox2.lonlim;
                    regionlim_lat = landeslims.regionbox.latlim;
                    regionlim_lon = landeslims.regionbox.lonlim;
                case 'orleans'
                    % orleans study areas
                    hrv_lat = orleans.hrv_lat;
                    hrv_lon = orleans.hrv_lon;
                    forestlim_lat = orleanslims.forestbox.latlim;
                    forestlim_lon = orleanslims.forestbox.lonlim;
                    nonfor1lim_lat = orleanslims.nonforbox1.latlim;
                    nonfor1lim_lon = orleanslims.nonforbox1.lonlim;
                    nonfor2lim_lat = orleanslims.nonforbox2.latlim;
                    nonfor2lim_lon = orleanslims.nonforbox2.lonlim;
                    regionlim_lat = orleanslims.regionbox.latlim;
                    regionlim_lon = orleanslims.regionbox.lonlim;
                case 'forest1'
                    % additional smaller forest 1
                    hrv_lat = forest1.hrv_lat;
                    hrv_lon = forest1.hrv_lon;
                    forestlim_lat = forest1lims.forestbox.latlim;
                    forestlim_lon = forest1lims.forestbox.lonlim;
                    nonfor1lim_lat = forest1lims.nonforbox1.latlim;
                    nonfor1lim_lon = forest1lims.nonforbox1.lonlim;
                    nonfor2lim_lat = forest1lims.nonforbox2.latlim;
                    nonfor2lim_lon = forest1lims.nonforbox2.lonlim;
                    regionlim_lat = forest1lims.regionbox.latlim;
                    regionlim_lon = forest1lims.regionbox.lonlim;
                case 'forest2'
                    % additional smaller forest 2
                    hrv_lat = forest2.hrv_lat;
                    hrv_lon = forest2.hrv_lon;
                    forestlim_lat = forest2lims.forestbox.latlim;
                    forestlim_lon = forest2lims.forestbox.lonlim;
                    nonfor1lim_lat = forest2lims.nonforbox1.latlim;
                    nonfor1lim_lon = forest2lims.nonforbox1.lonlim;
                    nonfor2lim_lat = forest2lims.nonforbox2.latlim;
                    nonfor2lim_lon = forest2lims.nonforbox2.lonlim;
                    regionlim_lat = forest2lims.regionbox.latlim;
                    regionlim_lon = forest2lims.regionbox.lonlim;
                case 'forest3'
                    % additional smaller forest 3
                    hrv_lat = forest3.hrv_lat;
                    hrv_lon = forest3.hrv_lon;
                    forestlim_lat = forest3lims.forestbox.latlim;
                    forestlim_lon = forest3lims.forestbox.lonlim;
                    nonfor1lim_lat = forest3lims.nonforbox1.latlim;
                    nonfor1lim_lon = forest3lims.nonforbox1.lonlim;
                    nonfor2lim_lat = forest3lims.nonforbox2.latlim;
                    nonfor2lim_lon = forest3lims.nonforbox2.lonlim;
                    regionlim_lat = forest3lims.regionbox.latlim;
                    regionlim_lon = forest3lims.regionbox.lonlim;
                otherwise
                    warning('Unknown regionname.')
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%
            %%% CORE - PART 1 %%%  Extracting cloud pixels from the study areas
            %%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% 1.1 Determine which of the cloudflag cells correspond to the lat/lon %
            %%% coordinates of the study boxes, using the first timestep.            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Import cloudflag data
            % Load reflectance data for refl extraction3
            filename = [disk, ':\Thesis\Data\matlab\cloudflags\hrv_cloudflag_' regionname '_' years{yr_idx(1)} '_' years{yr_idx(end)} '_' num2str(cl_t), '.mat'];
            cloudstruct = load(filename);
            cloud_data = double(squeeze(cloudstruct.cloudflag(1,1,1,1,:,:)));
            
            %%% Concatenate the cloudflag data on top of the hrv lat and lon grid
            cloud_data_hrv = cat(3, hrv_lat, hrv_lon, cloud_data);
            
            %%%%%% EXTRACTION %%%%%
            
            %%% Forest area
            k=0;
            j=1;
            m=1;
            
            forest_cells_x = [];
            forest_cells_y = [];
            forest_lat = [];
            forest_lon = [];
            
            for i = 1:size(cloud_data,1)
                if cloud_data_hrv(i,j,2) >= forestlim_lon(1) && cloud_data_hrv(i,j,2) <= forestlim_lon(2)
                    k=k+1;
                    l=0;
                    forest_cells_y(m) = i;  % Writing the y valaues of the cloudflag cells within the forest box
                    for j = 1:size(cloud_data,2)
                        if cloud_data_hrv(i,j,1) >= forestlim_lat(1) && cloud_data_hrv(i,j,1) <= forestlim_lat(2)
                            l=l+1;
                            forest_lat(k,l) = cloud_data_hrv(i,j,1);  % storing lat/lon coordinates for plotting
                            forest_lon(k,l) = cloud_data_hrv(i,j,2);  % storing lat/lon coordinates for plotting
                            forest_cells_x(l) = j;                      % Writing the x valaues of the cloudflag cells within the forest box
                        end
                    end
                    m = m+1;
                end
            end
            
            %%% Nonforest1 %%%
            k=0;
            j=1;
            m=1;
            
            nonfor1_cells_x = [];
            nonfor1_cells_y = [];
            nonfor1_lat = [];
            nonfor1_lon = [];
            
            for i = 1:size(cloud_data,1)
                if cloud_data_hrv(i,j,2) >= nonfor1lim_lon(1) && cloud_data_hrv(i,j,2) <= nonfor1lim_lon(2)
                    k=k+1;
                    l=0;
                    nonfor1_cells_y(m) = i;  % Writing the y valaues of the cloudflag cells within the non forest1 box
                    for j = 1:size(cloud_data,2)
                        if cloud_data_hrv(i,j,1) >= nonfor1lim_lat(1) && cloud_data_hrv(i,j,1) <= nonfor1lim_lat(2)
                            l=l+1;
                            nonfor1_lat(k,l) = cloud_data_hrv(i,j,1);  % storing lat/lon coordinates for plotting
                            nonfor1_lon(k,l) = cloud_data_hrv(i,j,2);  % storing lat/lon coordinates for plotting
                            nonfor1_cells_x(l) = j;                      % Writing the x valaues of the cloudflag cells within the nonforest1 box
                        end
                    end
                    m = m+1;
                end
            end
            
            %%% Nonforest2 %%%
            k=0;
            j=1;
            m=1;
            
            nonfor2_cells_x = [];
            nonfor2_cells_y = [];
            nonfor2_lat = [];
            nonfor2_lon = [];
            
            for i = 1:size(cloud_data,1)
                if cloud_data_hrv(i,j,2) >= nonfor2lim_lon(1) && cloud_data_hrv(i,j,2) <= nonfor2lim_lon(2)
                    k=k+1;
                    l=0;
                    nonfor2_cells_y(m) = i;  % Writing the y valaues of the cloudflag cells within the non forest2 box
                    for j = 1:size(cloud_data,2)
                        if cloud_data_hrv(i,j,1) >= nonfor2lim_lat(1) && cloud_data_hrv(i,j,1) <= nonfor2lim_lat(2)
                            l=l+1;
                            nonfor2_lat(k,l) = cloud_data_hrv(i,j,1);  % storing lat/lon coordinates for plotting
                            nonfor2_lon(k,l) = cloud_data_hrv(i,j,2);  % storing lat/lon coordinates for plotting
                            nonfor2_cells_x(l) = j;                      % Writing the x valaues of the cloudflag cells within the nonforest 2
                        end
                    end
                    m = m+1;
                end
            end
            
            
            %%% Outlines study areas
            % forest
            f_x1 = min(forest_cells_x);
            f_x2 = max(forest_cells_x);
            f_y1 = min(forest_cells_y);
            f_y2 = max(forest_cells_y);
            
            % nonforest1
            nf1_x1 = min(nonfor1_cells_x);
            nf1_x2 = max(nonfor1_cells_x);
            nf1_y1 = min(nonfor1_cells_y);
            nf1_y2 = max(nonfor1_cells_y);
            
            % nonforest2
            nf2_x1 = min(nonfor2_cells_x);
            nf2_x2 = max(nonfor2_cells_x);
            nf2_y1 = min(nonfor2_cells_y);
            nf2_y2 = max(nonfor2_cells_y);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% 1.2 Retreive the cloudflag data from the study area cells using the %
            %%% lat/lon coordinates retrieved in the previes section.               %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            cloud_data_forest = int8([]);
            cloud_data_nonfor1 = int8([]);
            cloud_data_nonfor2 = int8([]);
            
            for y = 1:5 % years
                for m = 1:4 % months
                    for d = 1:31 % days
                        for h = 1:48   % hours
                            % forest
                            if cl_t == 5
                                tmp = squeeze(cloudstruct.cloudflag(y,m,d,h,f_y1:f_y2,f_x1:f_x2));
                            elseif cl_t == 10
                                tmp = squeeze(cloudstruct.cloudflag_10(y,m,d,h,f_y1:f_y2,f_x1:f_x2));
                            elseif cl_t == 20
                                tmp = squeeze(cloudstruct.cloudflag_20(y,m,d,h,f_y1:f_y2,f_x1:f_x2));
                            else
                                tmp = squeeze(cloudstruct.cloudflag(y,m,d,h,f_y1:f_y2,f_x1:f_x2));
                            end
                            cloud_data_forest = cat(3, cloud_data_forest,tmp);
                            
                            % nonfor1
                            if cl_t == 5
                                tmp = squeeze(cloudstruct.cloudflag_5(y,m,d,h,nf1_y1:nf1_y2,nf1_x1:nf1_x2));
                            elseif cl_t == 10
                                tmp = squeeze(cloudstruct.cloudflag_10(y,m,d,h,nf1_y1:nf1_y2,nf1_x1:nf1_x2));
                            elseif cl_t == 20
                                tmp = squeeze(cloudstruct.cloudflag_20(y,m,d,h,nf1_y1:nf1_y2,nf1_x1:nf1_x2));
                            else
                                tmp = squeeze(cloudstruct.cloudflag(y,m,d,h,nf1_y1:nf1_y2,nf1_x1:nf1_x2));
                            end
                            cloud_data_nonfor1 = cat(3, cloud_data_nonfor1,tmp);
                            
                            % nonfor2
                            if cl_t == 5
                                tmp = squeeze(cloudstruct.cloudflag_5(y,m,d,h,nf2_y1:nf2_y2,nf2_x1:nf2_x2));
                            elseif cl_t == 10
                                tmp = squeeze(cloudstruct.cloudflag_10(y,m,d,h,nf2_y1:nf2_y2,nf2_x1:nf2_x2));
                            elseif cl_t == 20
                                tmp = squeeze(cloudstruct.cloudflag_20(y,m,d,h,nf2_y1:nf2_y2,nf2_x1:nf2_x2));
                            else
                                tmp = squeeze(cloudstruct.cloudflag(y,m,d,h,nf2_y1:nf2_y2,nf2_x1:nf2_x2));
                            end
                            cloud_data_nonfor2 = cat(3, cloud_data_nonfor2,tmp);
                            ct=ct+1;
                        end
                    end
                end
            end
            
            
            save(['Data\matlab\cloud_data\' regionname '\cloud_data_forest_' regionname '_' years{yr_idx(1)} '_' ...
                years{yr_idx(end)} '_' num2str(cl_t)],'cloud_data_forest');
            save(['Data\matlab\cloud_data\' regionname '\cloud_data_nonfor1_' regionname '_' years{yr_idx(1)} '_' ...
                years{yr_idx(end)} '_' num2str(cl_t)],'cloud_data_nonfor1');
            save(['Data\matlab\cloud_data\' regionname '\cloud_data_nonfor2_' regionname '_' years{yr_idx(1)} '_' ...
                years{yr_idx(end)} '_' num2str(cl_t)],'cloud_data_nonfor2');
        end
        ct = ct+1;
        if show_p == 1
            disp(['Script D2 - Progress: ' num2str(ct) '/' num2str(tt) ' steps completed (' num2str(ct/tt*100) '%).']);
        end
    end
end








%%%%%%%%%%%%%%%%%%%%%
%%% CORE - PART 2 %%%  Some basic numbers
%%%%%%%%%%%%%%%%%%%%%
if statistics == 1
    fs = (sum(cloud_data_forest(:) == 1))/((f_x2-f_x1)*(f_y2-f_y1));
    nf1s = (sum(cloud_data_nonfor1(:) == 1))/((nf1_x2-nf1_x1)*(nf1_y2-nf1_y1));
    nf2s = (sum(cloud_data_nonfor2(:) == 1))/((nf2_x2-nf2_x1)*(nf2_y2-nf2_y1));
    
    disp(' ');
    disp(' ');
    disp('Sum of cloud pixels, divided by total amount of pixels in said areas:')
    msg = ['Forest: ', num2str(fs)];
    disp(msg);
    msg = ['Non forest 1: ', num2str(nf1s)];
    disp(msg);
    msg = ['Non forest 2: ', num2str(nf2s)];
    disp(msg);
end

%%%%%%%%%%%%%%%%%%%%%
%%% TEST PLOTTING %%%
%%%%%%%%%%%%%%%%%%%%%
if plotting == 1
    
    close all
    
    cloudpxlvalue = max(refl(:))*1.1;   % assigning clouds to be 10% brighter than max bg refl
    
    forclouds = squeeze(forest_clouds(:,:,3));
    nonfor1clouds = squeeze(nonfor1_clouds(:,:,3));
    nonfor2clouds = squeeze(nonfor2_clouds(:,:,3));
    
    forest_clouds_refl(forclouds == 2) = cloudpxlvalue;
    nonfor1_clouds_refl(forclouds == 2) = cloudpxlvalue;
    nonfor2_clouds_refl(forclouds == 2) = cloudpxlvalue;
    
    
    
    figure
    
    axis image;
    
    axesm('MapProjection','lambert','Frame','on','grid','on',...
        'MapLatLimit',regionlim_lat,...
        'MapLonLimit',regionlim_lon,...
        'FLineWidth',.5);
    cmap = gray;
    colormap(cmap);
    pcolorm(hrv_lat,hrv_lon,refl);
    title('Pixels classified as clouds masked out');
    colorbar;
    
    hold on
    
    pcolorm(forest_clouds(:,:,1),forest_clouds(:,:,2),forest_clouds_refl);  % add forest
    pcolorm(nonfor1_clouds(:,:,1),nonfor1_clouds(:,:,2),nonfor1_clouds_refl);  % add non forest1
    pcolorm(nonfor2_clouds(:,:,1),nonfor2_clouds(:,:,2),nonfor2_clouds_refl);  % add non forest2
    
    add_study_areas_to_plot_f(regionname)
end
disp('Script D2 finished running.');
end


