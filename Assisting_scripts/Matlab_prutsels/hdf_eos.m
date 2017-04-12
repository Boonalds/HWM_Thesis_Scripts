
clear

% Open the file.
FILE_NAME='D:\Thesis\Data\Albedo\MODIS\hdf\landes\MCD43A3.A2006201.h17v04.005.2008142053635.hdf';

file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from the file. 
GRID_NAME='MOD_Grid_BRDF';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='Albedo_BSA_Band1';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Convert the data to double type for plot.
data=data1;
data=double(data);

% Transpose the data to match the map projection.
data=data';

% Retrieve grid dimension size information.
[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the Grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

