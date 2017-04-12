disk = 'D';
month = 1;
year = 1;
day = 15;
hour = 28;

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

load Data\hrv_grid\hrv_grid;     % Contains lat and lon data for each cell
box_lims

idx_region_r = 220:416;
idx_region_c = 69:186;
region_lat = landeslims.regionbox.latlim;
region_lon = landeslims.regionbox.lonlim;
hrv_lat = landes.hrv_lat;
hrv_lon = landes.hrv_lon;


% Cloudflags
load('D:\Thesis\Data\matlab\cloudflags\hrv_cloudflag_landes_2004_2008_27.mat');
A = squeeze(cloudflag(year,month,day,hour,:,:));
A = rot90(A,3);
A = flipud(A);
I = mat2gray(A);
CC = bwconncomp(I,4);

% graindata = regionprops(CC,'basic');
% graindata(50).Area

grain = false(size(I));
grain(CC.PixelIdxList{175}) = true;
imshow(grain);

% % MSG images
% filename = [disk, ':\Thesis\Data\ch12\' years{year} '\' months{month} '\' ...
%                                         years{year} months{month} days{day} hours{hour} '.gra'];
% fileID = fopen(filename,'r','l');
% B = fread(fileID,inf,'int16=>int16');
% fclose(fileID);
% if size(B,1) == 183480
%     ch12 = reshape(B,440,417);
% else
%     ch12 = nan(440,417);
%     disp(['Corrupt image: ' filename]);
% end
% 
% ch12sel = ch12(idx_region_r,idx_region_c,:);
% 
% ch12sel_dbl = double(ch12sel);
% caxis_ll = mean(ch12sel_dbl(:))-2*std(ch12sel_dbl(:));
% caxis_ul = mean(ch12sel_dbl(:))+2*std(ch12sel_dbl(:));
% 
% 
% 
% 
% 
% 
% %%% PLOT %%%
% cmap = gray;
% 
% close all
% figure
% 
% subplot(1,2,1)
% imshow(I2);
% 
% subplot(1,2,2)
% axis image;
% axesm('MapProjection','lambert','Frame','on','grid','off', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
% colormap(cmap);
% pcolorm(hrv_lat,hrv_lon,ch12sel);
% caxis([caxis_ll caxis_ul]);



