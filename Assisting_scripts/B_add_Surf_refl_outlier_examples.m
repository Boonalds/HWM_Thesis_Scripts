%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%

disk = 'D';     % Disk that contains Matlab Path
month =  2;     % index (1-4) for {'05';'06';'07';'08'};
dec =  3;       % index (1-3)for {'01';'02';'03'};
hour = 7;       % index (1-12) for {'0600';'0700';'0800';'0900';'1000';'1100';...
                    % '1200';'1300';'1400';'1500';'1600';'1700';'1800'};
bp = 20;        % breakpoint for difference between good data and outliers                    

                    
%%%%%%%%%%%%%%%
%%% LOADING %%%
%%%%%%%%%%%%%%%
box_lims                                       % Contains lat and lon limits for plotting areas
load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell
shore = load('Data\matlab\france_shore.dat');   % Shoreline file


%%%%%%%%%%%%%
%%% CORE  %%%
%%%%%%%%%%%%%

%%% Loading in reflectance files and extracting reflectance values

% 2004-2008
filenamea = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2004_2008_no_outliers.mat'];
Reflstructure = load(filenamea);
A = Reflstructure.surfrefl(month,dec,hour,:,:);
B = squeeze(A);

% 2009-2013
filenameb = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2009_2013_no_outliers.mat'];
Reflstructure = load(filenameb);
C = Reflstructure.surfrefl(month,dec,hour,:,:);
D = squeeze(C);

%%% Subtracting datasets
E = double(D-B);

% outliers
F = E(:);
G = F;

F(F >= bp) = [];      % normal data
G(G >= -bp & G <= bp) = [];      % outliers; removing all data between -bp and bp


% dataset with outliers set to 40
H = D;
H(E >= bp | E <= -bp) = 40;       


%%% Replace outlier values of 2009-2013 with the values of 2003-2008
I = D;
msize =[];
msize = size(B);
for i = 1:(msize(1)*msize(2))
    if E(i) >= bp || E(i) <= -bp
        I(i) = B(i);
    end
end




%%%%%%%%%%%%%%%%
%%% Plotting %%%
%%%%%%%%%%%%%%%%
close all

%%% Figure 1 - Statistics %%%
figure
ax1 = subplot(4,2,[1,2]);
plot(ax1,B(:))
ylim([1 250])
title('Reflectance 2004-2008')

ax2 = subplot(4,2,[3,4]);
plot(ax2,D(:))
ylim([1 250])
title('Reflectance 2009-2013')

ax3 = subplot(4,2,[5,6]);
plot(ax3,E(:))
title('Difference')

ax4 = subplot(4,2,7);
hist(ax4,F,20)
title(['Histogram of difference value <' num2str(bp)])
xlabel('difference')
ylabel('count')

ax4 = subplot(4,2,8);
hist(ax4,G,20)
title(['Histogram of difference value >' num2str(bp)])
xlabel('difference')
ylabel('count')

%%% Figure 2 - Plot with outliers %%%

% Setting Axes and Projection
figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);

% Actual plot
pcolorm(landes.hrv_lat,landes.hrv_lon,E);
title('Image with outliers')

linem(shore(:,2),shore(:,1),'k');   % Add shoreline
colorbar;                           % Colorbar to the right
add_study_areas_to_plot;


%%% Figure 3 - Plot with outliers set to 40 %%%

% Setting Axes and Projection
figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);

% Actual plot
pcolorm(landes.hrv_lat,landes.hrv_lon,H);
title('Image with outliers set to 40')

linem(shore(:,2),shore(:,1),'k');   % Add shoreline
colorbar;                           % Colorbar to the right

%%% Figure 4 - Plot with outliers replaced by old values %%%

% Setting Axes and Projection
figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);

% Actual plot
pcolorm(landes.hrv_lat,landes.hrv_lon,I);
title('Image with outliers replaced by old values')

linem(shore(:,2),shore(:,1),'k');   % Add shoreline
colorbar;                           % Colorbar to the right

