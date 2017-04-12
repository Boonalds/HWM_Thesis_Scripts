ch12 = [];
box_lims
cmap = gray;


load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell
shore = load('Data\matlab\france_shore.dat');   % Shoreline file


filename = 'D:\Thesis\Data\ch12\2004\06\200406121000.gra';
fileID = fopen(filename,'r','l');
A = fread(fileID,inf,'int16=>int16');
fclose(fileID);
ch12 = cat(3,ch12,reshape(A,440,417));


%%plot
figure
axis image;
axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);

% Actual plot
colormap(cmap);
pcolorm(landes.hrv_lat,landes.hrv_lon,ch12);
linem(shore(:,2),shore(:,1),'k');   % Add shoreline
colorbar;                           % Colorbar to the right



% refl = squeeze(filenameload.surfrefl(month,dec,hridx,:,:));