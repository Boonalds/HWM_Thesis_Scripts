function [] = B_Outlier_Removal(disk, nstd)
disp('Script B started running.');
%%%%%%%%%%%%%%%%%%   STEP B - Removing outliers   %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% This script removes the outliers in the background albedo map by
%%%%%% comparing the values with the mean values. If the difference is more
%%%%%% than the set amount of standard deviations (nstd), the pixel is
%%%%%% flagged as an uitlier. The pixel is then replaced by the pixelvalue
%%%%%% from the albedo of 5 years earlier/later. If both the earlier and
%%%%%% later pixel is flagged as an outlier, the pixelvalue of the
%%%%%% neighbouring cell will be assigned to the outlier.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INPUT %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_exist = 1;    % Carry out a check to see if the file already exist,
% so the remainder of the script can be skipped.
% Put to 0 if something changed, so the file needs to
% be recreated.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rgnnames = {'landes', 'orleans', 'forest1', 'forest2', 'forest3'};

for a = 1:5
    regionname = rgnnames{a};
    
    
    if check_exist == 1
        
        checkfile = [disk ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_2004_2008_no_outliers.mat'];
        checkfile2 = [disk ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_2009_2013_no_outliers.mat'];
        
        if (exist(checkfile, 'file')) == 2 && (exist(checkfile2, 'file'))
            quitvar = 1;
        else
            disp(['Script B: Outlier removal not yet done for' regionname '. Removing outliers..']);
            quitvar = 2;
        end
    else
        quitvar = 2;
    end
    
    
    if quitvar == 2
          
            
            %%%%%%%%%%%%
            %%% CORE %%%
            %%%%%%%%%%%%
            
            %%% Load in the bg albedo maps
            % 2004-2008
            filename = [disk, ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_2004_2008.mat'];
            Reflstructurea = load(filename);
            
            % 2009-2013
            filenameb = [disk, ':\Thesis\Data\matlab\reflectance\surface_reflectance_' regionname '_2009_2013.mat'];
            Reflstructureb = load(filenameb);
            
            surfreflB = [];
            surfreflD = [];
            
            %%% Looping through every albedo map, correcting for outliers..
            for month=1:4
                for dec=1:3
                    for hour=1:12
                        A = Reflstructurea.surfrefl(month,dec,hour,:,:);
                        B = squeeze(A);
                        msize = size(B);
                        
                        C = Reflstructureb.surfrefl(month,dec,hour,:,:);
                        D = squeeze(C);
                        
                        % Compute limits for acceptable values
                        stdB = std(double(B(:)));
                        llB = mean(B(:))-nstd*stdB;  %lower limit
                        ulB = mean(B(:))+nstd*stdB;  %upper limit
                        
                        stdD = std(double(D(:)));
                        llD = mean(D(:))-nstd*stdD;  %lower limit
                        ulD = mean(D(:))+nstd*stdD;  %upper limit
                        
                        for i = 1:(msize(1)*msize(2))
                            if B(i) >= ulB || B(i) <= llB
                                B(i) = D(i);
                            end
                            if D(i) >= ulD || D(i) <= llD
                                D(i) = B(i);
                            end
                            if (B(i) >= ulB || B(i) <= llB) && (D(i) >= ulD || D(i) <= llD)
                                B(i) = B(i-1);
                                D(i) = D(i-1);
                            end
                        end
                        
                        surfreflB(month,dec,hour,:,:) = B;
                        surfreflD(month,dec,hour,:,:) = D;
                    end
                end
            end
            
            surfrefl = surfreflB;
            save(['Data\matlab\reflectance\surface_reflectance_' regionname '_2004_2008_no_outliers'],'surfrefl');
            surfrefl = surfreflD;
            save(['Data\matlab\reflectance\surface_reflectance_' regionname '_2009_2013_no_outliers'],'surfrefl');

    end
end
disp('Script B finished running.');
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% plot for visual confirmation %%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% % 2004-2008
% filename = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2004_2008_no_outliers.mat'];
% Reflstructurea = load(filename);
% A = Reflstructurea.surfrefl(2,1,1,:,:);
% B = squeeze(A);
%
%
% % 2009-2013
% filenameb = [disk, ':\Thesis\Data\matlab\surface_reflectance_landes_2009_2013_no_outliers.mat'];
% Reflstructureb = load(filenameb);
% C = Reflstructureb.surfrefl(2,1,1,:,:);
% D = squeeze(C);
%
% box_lims                                       % Contains lat and lon limits for plotting areas
% load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell
% shore = load('Data\matlab\france_shore.dat');   % Shoreline file
%
%
% close all
% figure
%
% %%% plot B
% axis image;
% axesm('MapProjection','lambert','Frame','on','grid','on',...
%     'MapLatLimit',landeslims.regionbox.latlim,...
%     'MapLonLimit',landeslims.regionbox.lonlim,...
%     'FLineWidth',.5);
%
% % Actual plot
% pcolorm(landes.hrv_lat,landes.hrv_lon,B);
% title('Albedo map of 2004-2008, outliers removed')
%
% linem(shore(:,2),shore(:,1),'k');   % Add shoreline
% colorbar;                           % Colorbar to the right
%
% %%% plot D
% figure
%
% axis image;
% axesm('MapProjection','lambert','Frame','on','grid','on',...
%     'MapLatLimit',landeslims.regionbox.latlim,...
%     'MapLonLimit',landeslims.regionbox.lonlim,...
%     'FLineWidth',.5);
%
% % Actual plot
% pcolorm(landes.hrv_lat,landes.hrv_lon,D);
% title('Albedo map of 2009-2013, outliers removed')
%
% linem(shore(:,2),shore(:,1),'k');   % Add shoreline
% colorbar;                           % Colorbar to the right
