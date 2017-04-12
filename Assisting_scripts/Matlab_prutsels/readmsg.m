% function [] = read_msg_hrv(regionname,yr_idx)

regionname = 'orleans';
yr_idx = 1:4;

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
% monthsp = {'07';'07';'07';'08';'08';'08'};
months = {'05';'06';'07';'08'};
daysp{1} = 1:10;
daysp{2} = 11:20;
daysp{3} = 21:31;

refllim = [5 10 20];

switch regionname
    case 'landes'
        % index for landes cutout
        idx_region_r = 220:416;
        idx_region_c = 69:186;
    case 'orleans'
        % index for orleans cutout
        idx_region_r = 40:233;
        idx_region_c = 274:382;
    otherwise
        warning('Unknown regionname.')
end
        


%idx_orleans = 

surfrefl = int16(zeros(length(months),3,12,length(idx_region_r),length(idx_region_c)));
ts = 0;
tt = 144;

% read in data matrix and determine surface reflectance
t = 0;
for m = 1:length(months)
    for dec = 1:3
        for h = 1:4:48
            ch12 = [];
            for yr = 1:length(yr_idx);
                for d = daysp{dec}
                    for hh = h:h+3
                        filename = ['D:\Thesis\Data\ch12\' years{yr_idx(yr)} '\' months{m} '\' ...
                            years{yr_idx(yr)} months{m} days{d} hours{hh} '.gra'];
                        if exist(filename, 'file') == 2
                            fileID = fopen(filename,'r','l');
                            A = fread(fileID,inf,'int16=>int16');
                            fclose(fileID);
                            ch12 = cat(3,ch12,reshape(A,440,417));
                        else
                            ch12 = cat(3,ch12,nan(440,417));
                        end
                    end
                end
            end
            ch12sel = ch12(idx_region_r,idx_region_c,:);
            for x = 1:length(idx_region_r)
                for y = 1:length(idx_region_c)
                    [ydata,xdata] = ecdf(squeeze(ch12sel(x,y,:)));
                    xdata(xdata > 280) = 0;
                    slope = [diff(double(ydata))./diff(double(xdata)); 0];
                    slope_av = movav(slope,11);
                    slope_av(isfinite(slope_av)==0) = 0;
                    [tmp,I] = max(slope_av);
                    surfrefl(m,dec,(h+3)/4,x,y) = xdata(I);
    %                 dslope_av = diff(slope_av);
    %                 [tmp,I] = min(dslope_av);
    %                 cloud_lim(x,y) = xdata(I);
                end
            end
            ts = ts+1;
            ct = ts/tt*100;
            disp(['Constructing albedo map.. Progress: ' num2str(ct) '%'])
        end
        disp(dec);
    end
end

% save reflectance
save(['matlab\surface_reflectance_' regionname '_' years{yr_idx(1)} '_' ...
    years{yr_idx(end)}],'surfrefl')

% cloudflag_5 = zeros(length(yr_idx),length(months),31,48,...
%     length(idx_region_r),length(idx_region_c),'int8');
% 
% cloudflag_10 = zeros(length(yr_idx),length(months),31,48,...
%     length(idx_region_r),length(idx_region_c),'int8');
% 
% cloudflag_20 = zeros(length(yr_idx),length(months),31,48,...
%     length(idx_region_r),length(idx_region_c),'int8');
% 
% for y = 1:length(yr_idx)
%     for m = 1:length(months)
%         for d = 1:31;
%             for h = 1:48
%                 % read in data files
%                 filename = ['E:\ch12\' years{yr_idx(y)} '\' months{m} '\' ...
%                     years{yr_idx(y)} months{m} days{d} hours{h} '.gra'];
%                 if exist(filename, 'file') == 2
%                     fileID = fopen(filename,'r','l');
%                     A = fread(fileID,inf,'int16=>int16');
%                     fclose(fileID);
%                     ch12 = reshape(A,440,417);
%                 else
%                     ch12 = nan(440,417);
%                 end
%                 % cut out selected region
%                 ch12sel = ch12(idx_region_r,idx_region_c,:);
%                 % determine decade nr
%                 if d < 11
%                     p = 1;
%                 elseif d >= 11 & d < 21
%                     p = 2;
%                 else
%                     p = 3;
%                 end
%                 % determine hour idx
%                 hridx = ceil(h/4);
%                 % get background surface reflectance
%                 tmp_surfrefl = squeeze(surfrefl(m,p,hridx,:,:));
%                 tmp = zeros(size(ch12sel),'int8');
%                 tmp(ch12sel > (tmp_surfrefl+5)) = 1;
%                 tmp(ch12sel < (tmp_surfrefl-5)) = 2;
%                 tmp(isnan(ch12sel)) = 3;
%                 cloudflag_5(y,m,d,h,:,:) = tmp;
%                 tmp = zeros(size(ch12sel),'int8');
%                 tmp(ch12sel > (tmp_surfrefl+10)) = 1;
%                 tmp(ch12sel < (tmp_surfrefl-10)) = 2;
%                 tmp(isnan(ch12sel)) = 3;
%                 cloudflag_10(y,m,d,h,:,:) = tmp;
%                 tmp = zeros(size(ch12sel),'int8');
%                 tmp(ch12sel > (tmp_surfrefl+20)) = 1;
%                 tmp(ch12sel < (tmp_surfrefl-20)) = 2;
%                 tmp(isnan(ch12sel)) = 3;
%                 cloudflag_20(y,m,d,h,:,:) = tmp;
%             end
%         end
%     end
% end
% 
% save(['matlab\hrv_cloudflag_' regionname '_' years{yr_idx(1)} '_' ...
%     years{yr_idx(end)} '_5'],'cloudflag_5')
% save(['matlab\hrv_cloudflag_' regionname '_' years{yr_idx(1)} '_' ...
%     years{yr_idx(end)} '_10'],'cloudflag_10')
% save(['matlab\hrv_cloudflag_' regionname '_' years{yr_idx(1)} '_' ...
%     years{yr_idx(end)} '_20'],'cloudflag_20')
% % save(['matlab\hrv_missingdata_' regionname '_' years{yr_idx(1)} '_' ...
% %     years{yr_idx(end)}],'missingdata')
% % % save(['matlab\hrv_shadeflag_' regionname '_' years{yr_idx(1)} '_' ...
% % %     years{yr_idx(end)} '_5'],'shadeflag_5')
% % save(['matlab\hrv_shadeflag_' regionname '_' years{yr_idx(1)} '_' ...
% %     years{yr_idx(end)} '_10'],'shadeflag_10')
% % % save(['matlab\hrv_shadeflag_' regionname '_' years{yr_idx(1)} '_' ...
% % %     years{yr_idx(end)} '_20'],'shadeflag_20')
% 
% box_lims
% 
% landes.hrv_forestbox = landes.hrv_lat >= landes.forestbox.latlim(1) & ...
% landes.hrv_lat <= landes.forestbox.latlim(2) & ...
% landes.hrv_lon >= landes.forestbox.lonlim(1) & ...
% landes.hrv_lon <= landes.forestbox.lonlim(2);
% 
% landes.hrv_nonforbox1 = landes.hrv_lat >= landes.nonforbox1.latlim(1) & ...
% landes.hrv_lat <= landes.nonforbox1.latlim(2) & ...
% landes.hrv_lon >= landes.nonforbox1.lonlim(1) & ...
% landes.hrv_lon <= landes.nonforbox1.lonlim(2);
% 
% landes.hrv_nonforbox2 = landes.hrv_lat >= landes.nonforbox2.latlim(1) & ...
% landes.hrv_lat <= landes.nonforbox2.latlim(2) & ...
% landes.hrv_lon >= landes.nonforbox2.lonlim(1) & ...
% landes.hrv_lon <= landes.nonforbox2.lonlim(2);
% 
% orleans.hrv_forestbox = orleans.hrv_lat >= orleans.forestbox.latlim(1) & ...
% orleans.hrv_lat <= orleans.forestbox.latlim(2) & ...
% orleans.hrv_lon >= orleans.forestbox.lonlim(1) & ...
% orleans.hrv_lon <= orleans.forestbox.lonlim(2);
% 
% orleans.hrv_nonforbox1 = orleans.hrv_lat >= orleans.nonforbox1.latlim(1) & ...
% orleans.hrv_lat <= orleans.nonforbox1.latlim(2) & ...
% orleans.hrv_lon >= orleans.nonforbox1.lonlim(1) & ...
% orleans.hrv_lon <= orleans.nonforbox1.lonlim(2);
% 
% orleans.hrv_nonforbox2 = orleans.hrv_lat >= orleans.nonforbox2.latlim(1) & ...
% orleans.hrv_lat <= orleans.nonforbox2.latlim(2) & ...
% orleans.hrv_lon >= orleans.nonforbox2.lonlim(1) & ...
% orleans.hrv_lon <= orleans.nonforbox2.lonlim(2);


% cc_diff.landes = mean(cloudflag(:,:,:,:,landes.hrv_forestbox),5) - ...
%     (mean(cloudflag(:,:,:,:,landes.hrv_nonforbox1),5) + ...
%     mean(cloudflag(:,:,:,:,landes.hrv_nonforbox2),5))./2;
% 
% cc_diff.orleans = mean(cloudflag(:,:,:,:,orleans.hrv_forestbox),5) - ...
%     (mean(cloudflag(:,:,:,:,orleans.hrv_nonforbox1),5) + ...
%     mean(cloudflag(:,:,:,:,orleans.hrv_nonforbox2),5))./2;
