
filename = 'MSG_locations_low_res.gra';
fileID = fopen(filename,'r','l');
A = fread(fileID,inf,'float');
fclose(fileID);
loc_c = reshape(A,146,139,2);
lat_c = squeeze(loc_c(:,:,2));
lon_c = squeeze(loc_c(:,:,1));
idx_lat_c = repmat([3:3:440]',1,139);
idx_lon_c = repmat([2:3:417],146,1);
idx_lat_f = repmat([1:440]',1,417);
idx_lon_f = repmat([1:417],440,1);

lat_hrv = interp2(idx_lon_c,idx_lat_c,lat_c,idx_lon_f,idx_lat_f);
lon_hrv = interp2(idx_lon_c,idx_lat_c,lon_c,idx_lon_f,idx_lat_f);

landes.hrv_lat = lat_hrv(220:416,69:186);
landes.hrv_lon = lon_hrv(220:416,69:186);

orleans.hrv_lat = lat_hrv(40:233,274:382);
orleans.hrv_lon = lon_hrv(40:233,274:382);

full.hrv_lat = lat_hrv(1:end,1:end);
full.hrv_lon = lon_hrv(1:end,1:end);

forest1.hrv_lat = lat_hrv(20:150,330:415);
forest1.hrv_lon = lon_hrv(20:150,330:415);

forest2.hrv_lat = lat_hrv(130:240,250:310);
forest2.hrv_lon = lon_hrv(130:240,250:310);

forest3.hrv_lat = lat_hrv(290:325,220:270);
forest3.hrv_lon = lon_hrv(290:325,220:270);

save 'Data\hrv_grid\hrv_grid' landes orleans full forest1 forest2 forest3