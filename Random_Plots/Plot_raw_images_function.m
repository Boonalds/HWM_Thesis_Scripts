function [] = Plot_raw_images_function(year,month,day,hour)

%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%

%%% good data: 4-2-8-30
%%% good data animation: 3-3-15-18 +++

disk = 'D';     % Disk that contains Matlab Path

%Indexes
% year = 3;        % index (1-10) for {'2004';'2005';'2006';'2007';'2008';...
%                     % '2009';'2010';'2011';'2012';'2013'}
% month =  3;     % index (1-4) for {'05';'06';'07';'08'};
% day = 15;        % day = day of month
% hour = 28;       % index (1-48) for {'0600';'0615';'0630';'0645';'0700';'0715';'0730';'0745';...
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


ch12 = [];
box_lims
cmap = gray;
idx_region_r = 220:416;
idx_region_c = 69:186;
        

load Data\hrv_grid\hrv_grid;                    % Contains lat and lon data for each cell
shore = load('Data\matlab\france_shore.dat');   % Shoreline file

filename = [disk, ':\Thesis\Data\ch12\', years{year}, '\', months{month}, '\', ...
    years{year}, months{month}, days{day}, hours{hour}, '.gra'];
% filename = 'D:\Thesis\Data\ch12\2007\06\200706081400.gra';
fileID = fopen(filename,'r','l');
A = fread(fileID,inf,'int16=>int16');
fclose(fileID);
ch12 = cat(3,ch12,reshape(A,440,417));
ch12sel = ch12(idx_region_r,idx_region_c,:);  % Figure 1

%%plot
close all
axis image;

axesm('MapProjection','lambert','Frame','on','grid','on',...
    'MapLatLimit',landeslims.regionbox.latlim,...
    'MapLonLimit',landeslims.regionbox.lonlim,...
    'FLineWidth',.5);


colormap(cmap);
pcolorm(landes.hrv_lat,landes.hrv_lon,ch12sel);

end



% refl = squeeze(filenameload.surfrefl(month,dec,hridx,:,:));