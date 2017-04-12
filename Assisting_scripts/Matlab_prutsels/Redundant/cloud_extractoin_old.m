% Extracting cloud data and doing basic statistics

%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%

disk = 'D';     % Disk that contains Matlab Path

%Indexes
year = 2;        % index (1-10) for {'2004';'2005';'2006';'2007';'2008';...
                    % '2009';'2010';'2011';'2012';'2013'}
month =  1;     % index (1-4) for {'05';'06';'07';'08'};
day = 31;        % day = day of month
hour = 1;       % index (1-48) for {'0600';'0615';'0630';'0645';'0700';'0715';'0730';'0745';...
                   %'0800';'0815';'0830';'0845';'0900';'0915';'0930';'0945';...
                   %'1000';'1015';'1030';'1045';'1100';'1115';'1130';'1145';...
                   %'1200';'1215';'1230';'1245';'1300';'1315';'1330';'1345';...
                   %'1400';'1415';'1430';'1445';'1500';'1515';'1530';'1545';...
                   %'1600';'1615';'1630';'1645';'1700';'1715';'1730';'1745'};
                   
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
box_lims                                       % Contains lat and lon limits for plotting areas
load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell

%%% Load reflectance data for refl extraction
filename = [disk, ':\Thesis\Data\matlab\reflectance\surface_reflectance_forest3_2004_2008.mat'];
filenameload = load(filename);
refl = squeeze(filenameload.surfrefl(month,dec,hour,:,:));

%%%%%%%%%%%%%%%%%%%%%
%%% CORE - PART 1 %%%  Extracting data from those areas
%%%%%%%%%%%%%%%%%%%%%

%%% Load in clouds
filename = [disk, ':\Thesis\Data\matlab\cloudflags\hrv_cloudflag_forest3_2004_2008_10.mat'];
filenameload = load(filename);

clouds = squeeze(filenameload.cloudflag_10(year,month,day,hour,:,:));
clouds = double(clouds);

%%% Concatenate hrv grid with cloud data
clouds_hrv = cat(3, landes.hrv_lat, landes.hrv_lon, clouds);

%%% Extract data


%clouds_hrv(i,j,1) >= landeslims.forestbox.latlim(1) && clouds_hrv(i,j,1) <= landeslims.forestbox.latlim(2)
%clouds_hrv(i,j,2) >= landeslims.forestbox.lonlim(1) && clouds_hrv(i,j,2) <= landeslims.forestbox.lonlim(2)

forest_clouds_refl=[];
forest_clouds=[];
k=0;
l=0;
j=1;

%%% FOREST REGION %%%
for i = 1:size(clouds,1)
    if clouds_hrv(i,j,2) >= landeslims.forestbox.lonlim(1) && clouds_hrv(i,j,2) <= landeslims.forestbox.lonlim(2)
        k=k+1;
        l=0;
        for j = 1:size(clouds,2)
            if clouds_hrv(i,j,1) >= landeslims.forestbox.latlim(1) && clouds_hrv(i,j,1) <= landeslims.forestbox.latlim(2)
                l=l+1;           
                forest_clouds(k,l,1) = clouds_hrv(i,j,1);
                forest_clouds(k,l,2) = clouds_hrv(i,j,2);
                forest_clouds(k,l,3) = clouds_hrv(i,j,3);
                forest_clouds_refl(k,l,1) = refl(i,j);
            end
        end
    end
end


%%% NON FOREST REGION 1 %%%

nonfor1_clouds_refl=[];
nonfor1_clouds=[];
k=0;
l=0;
j=1;

for i = 1:size(clouds,1)
    if clouds_hrv(i,j,2) >= landeslims.nonforbox1.lonlim(1) && clouds_hrv(i,j,2) <= landeslims.nonforbox1.lonlim(2)
        k=k+1;
        l=0;
        for j = 1:size(clouds,2)
            if clouds_hrv(i,j,1) >= landeslims.nonforbox1.latlim(1) && clouds_hrv(i,j,1) <= landeslims.nonforbox1.latlim(2)
                l=l+1;           
                nonfor1_clouds(k,l,1) = clouds_hrv(i,j,1);
                nonfor1_clouds(k,l,2) = clouds_hrv(i,j,2);
                nonfor1_clouds(k,l,3) = clouds_hrv(i,j,3);
                nonfor1_clouds_refl(k,l,1) = refl(i,j);
            end
        end
    end
end

%%% NON FOREST REGION 2 %%%

nonfor2_clouds_refl=[];
nonfor2_clouds=[];
k=0;
l=0;
j=1;

for i = 1:size(clouds,1)
    if clouds_hrv(i,j,2) >= landeslims.nonforbox2.lonlim(1) && clouds_hrv(i,j,2) <= landeslims.nonforbox2.lonlim(2)
        k=k+1;
        l=0;
        for j = 1:size(clouds,2)
            if clouds_hrv(i,j,1) >= landeslims.nonforbox2.latlim(1) && clouds_hrv(i,j,1) <= landeslims.nonforbox2.latlim(2)
                l=l+1;           
                nonfor2_clouds(k,l,1) = clouds_hrv(i,j,1);
                nonfor2_clouds(k,l,2) = clouds_hrv(i,j,2);
                nonfor2_clouds(k,l,3) = clouds_hrv(i,j,3);
                nonfor2_clouds_refl(k,l,1) = refl(i,j);
            end
        end
    end
end


% %%%%%%%%%%%%%%%%%%%%%
% %%% TEST PLOTTING %%%
% %%%%%%%%%%%%%%%%%%%%%
% close all
% 
% cloudpxlvalue = max(refl(:))*1.1;   % assigning clouds to be 10% brighter than max bg refl
% 
% forclouds = squeeze(forest_clouds(:,:,3));
% nonfor1clouds = squeeze(nonfor1_clouds(:,:,3));
% nonfor2clouds = squeeze(nonfor2_clouds(:,:,3));
% 
% forest_clouds_refl(forclouds == 2) = cloudpxlvalue;
% nonfor1_clouds_refl(forclouds == 2) = cloudpxlvalue;
% nonfor2_clouds_refl(forclouds == 2) = cloudpxlvalue;
% 
% 
% 
% figure
% 
% axis image;
% 
% axesm('MapProjection','lambert','Frame','on','grid','on',...
%     'MapLatLimit',landeslims.regionbox.latlim,...
%     'MapLonLimit',landeslims.regionbox.lonlim,...
%     'FLineWidth',.5);
% cmap = gray;
% colormap(cmap);
% pcolorm(landes.hrv_lat,landes.hrv_lon,refl);
% title('Pixels classified as clouds masked out');
% colorbar;
% 
% hold on
% 
% pcolorm(forest_clouds(:,:,1),forest_clouds(:,:,2),forest_clouds_refl);  % add forest
% pcolorm(nonfor1_clouds(:,:,1),nonfor1_clouds(:,:,2),nonfor1_clouds_refl);  % add non forest1
% pcolorm(nonfor2_clouds(:,:,1),nonfor2_clouds(:,:,2),nonfor2_clouds_refl);  % add non forest2
% 
% add_study_areas_to_plot
% 
% 
% %%%%%%%%%%%%%%%%%%%%%
% %%% CORE - PART 2 %%%  Statistics
% %%%%%%%%%%%%%%%%%%%%%