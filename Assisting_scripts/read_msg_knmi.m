function [] = read_msg_knmi()

disk = 'D';

box_lims
% ot_lim = 15;
% ot_lim = 30;
ot_lim = 60;

% cloud flag 0 2 3 'clear cloud_contaminated cloud_filled'

% case Landes

casename = 'landes';
filenames  = {[disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20040101_20041231_0001_landes.h5'];...
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20050101_20051231_0001_landes.h5'];...
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20060101_20061231_0001_landes.h5'];...
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20070101_20071231_0001_landes.h5'];...
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20080101_20081231_0001_landes.h5'];...
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20090101_20091231_0001_landes.h5'];...
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20100101_20101231_0001_landes.h5'];...
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20110101_20111231_0001_landes.h5'];...
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20120101_20121231_0001_landes.h5'];
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20130101_20131231_0001_landes.h5']};
% hinfo = hdf5info([disk, ':\Data\SEVIRI_MSG\SEVIR_OPER_R___MSGCPP__L2__20110101_20111231_0001_landes.h5']);
years = 2004:2013;

for c = 1:10
    hinfo = hdf5info(filenames{c});

    data_cc = double(hdf5read(hinfo.GroupHierarchy.Datasets(1))); % cloud mask
    data_ot = single(hdf5read(hinfo.GroupHierarchy.Datasets(2))); % optical depth
    %data_cth = single(hdf5read(hinfo.GroupHierarchy.Datasets(3))); % cloud height
    time = hdf5read(hinfo.GroupHierarchy.Datasets(4));
    landes.lat = hdf5read(hinfo.GroupHierarchy.Datasets(5));
    landes.lon = hdf5read(hinfo.GroupHierarchy.Datasets(6));
    mask_region = landes.lon > landes.regionbox.lonlim(1) & ...
        landes.lon <= landes.regionbox.lonlim(2) & ...
        landes.lat > landes.regionbox.latlim(1) & ...
        landes.lat <= landes.regionbox.latlim(2);
    mask_forest = landes.lon > landes.forestbox.lonlim(1) & ...
        landes.lon <= landes.forestbox.lonlim(2) & ...
        landes.lat > landes.forestbox.latlim(1) & ...
        landes.lat <= landes.forestbox.latlim(2);
    mask_forestklaus = landes.lon > landes.forestboxklaus.lonlim(1) & ...
        landes.lon <= landes.forestboxklaus.lonlim(2) & ...
        landes.lat > landes.forestboxklaus.latlim(1) & ...
        landes.lat <= landes.forestboxklaus.latlim(2);
    mask_nonfor1 = landes.lon > landes.nonforbox1.lonlim(1) & ...
        landes.lon <= landes.nonforbox1.lonlim(2) & ...
        landes.lat > landes.nonforbox1.latlim(1) & ...
        landes.lat <= landes.nonforbox1.latlim(2);
    mask_nonfor2 = landes.lon > landes.nonforbox2.lonlim(1) & ...
        landes.lon <= landes.nonforbox2.lonlim(2) & ...
        landes.lat > landes.nonforbox2.latlim(1) & ...
        landes.lat <= landes.nonforbox2.latlim(2);
    [landes.cc,landes.ot,landes.time,landes.isday] = ...
        get_cc(data_cc,data_ot,time,ot_lim);
    
    landes.cc_region = get_cc_region(landes.cc,mask_region);
    landes.cc_forest = get_cc_region(landes.cc,mask_forest);
    landes.cc_forestklaus = get_cc_region(landes.cc,mask_forestklaus);
    landes.cc_nonfor1 = get_cc_region(landes.cc,mask_nonfor1);
    landes.cc_nonfor2 = get_cc_region(landes.cc,mask_nonfor2);
    
%     landes.cth_forest = get_cth_region(landes.cc,data_cth,mask_forest);
%     landes.cth_nonfor1 = get_cth_region(landes.cc,data_cth,mask_nonfor1);
%     landes.cth_nonfor2 = get_cth_region(landes.cc,data_cth,mask_nonfor2);
%     landes.cth_nonfor3 = get_cth_region(landes.cc,data_cth,mask_nonfor3);
    
    landes.ccmat = make_cc_plot(landes.cc_forest,...
        landes.cc_nonfor1,landes.cc_nonfor2,[casename num2str(years(c))]);
    save(['Data\matlab\landes_cc_' int2str(years(c)) '_' int2str(ot_lim) '.mat'],'landes', '-v7.3')
    
end

% case orleans

casename = 'orleans';
filenames  = {[disk, ':\Thesis\Data\MSGCPP\SEVIRI_MSG\SEVIR_OPER_R___MSGCPP__L2__20040101_20041231_0001_orleans.h5'];...
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20050101_20051231_0001_orleans.h5'];
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20060101_20061231_0001_orleans.h5'];
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20070101_20071231_0001_orleans.h5'];
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20080101_20081231_0001_orleans.h5'];
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20090101_20091231_0001_orleans.h5'];
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20100101_20101231_0001_orleans.h5'];
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20110101_20111231_0001_orleans.h5'];
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20120101_20121231_0001_orleans.h5'];
    [disk, ':\Thesis\Data\MSGCPP\SEVIR_OPER_R___MSGCPP__L2__20130101_20131231_0001_orleans.h5']};
% hinfo = hdf5info([disk, ':\Data\SEVIRI_MSG\SEVIR_OPER_R___MSGCPP__L2__20110101_20111231_0001_landes.h5']);
years = 2004:2013;

for c = 1:10
    hinfo = hdf5info(filenames{c});

    data_cc = double(hdf5read(hinfo.GroupHierarchy.Datasets(1))); % cloud mask
    data_ot = single(hdf5read(hinfo.GroupHierarchy.Datasets(2))); % optical depth
%     data_cth = single(hdf5read(hinfo.GroupHierarchy.Datasets(3))); % cloud height
    time = hdf5read(hinfo.GroupHierarchy.Datasets(4));
    orleans.lat = hdf5read(hinfo.GroupHierarchy.Datasets(5));
    orleans.lon = hdf5read(hinfo.GroupHierarchy.Datasets(6));
    mask_region = orleans.lon > orleans.regionbox.lonlim(1) & ...
        orleans.lon <= orleans.regionbox.lonlim(2) & ...
        orleans.lat > orleans.regionbox.latlim(1) & ...
        orleans.lat <= orleans.regionbox.latlim(2);
    mask_forest = orleans.lon > orleans.forestbox.lonlim(1) & ...
        orleans.lon <= orleans.forestbox.lonlim(2) & ...
        orleans.lat > orleans.forestbox.latlim(1) & ...
        orleans.lat <= orleans.forestbox.latlim(2);
    mask_nonfor1 = orleans.lon > orleans.nonforbox1.lonlim(1) & ...
        orleans.lon <= orleans.nonforbox1.lonlim(2) & ...
        orleans.lat > orleans.nonforbox1.latlim(1) & ...
        orleans.lat <= orleans.nonforbox1.latlim(2);
    mask_nonfor2 = orleans.lon > orleans.nonforbox2.lonlim(1) & ...
        orleans.lon <= orleans.nonforbox2.lonlim(2) & ...
        orleans.lat > orleans.nonforbox2.latlim(1) & ...
        orleans.lat <= orleans.nonforbox2.latlim(2);
    [orleans.cc,orleans.ot,orleans.time,orleans.isday] = ...
        get_cc(data_cc,data_ot,time,ot_lim);
    
    orleans.cc_region = get_cc_region(orleans.cc,mask_region);
    orleans.cc_forest = get_cc_region(orleans.cc,mask_forest);
    orleans.cc_nonfor1 = get_cc_region(orleans.cc,mask_nonfor1);
    orleans.cc_nonfor2 = get_cc_region(orleans.cc,mask_nonfor2);
    
%     orleans.cth_forest = get_cth_region(orleans.cc,data_cth,mask_forest);
%     orleans.cth_nonfor1 = get_cth_region(orleans.cc,data_cth,mask_nonfor1);
%     orleans.cth_nonfor2 = get_cth_region(orleans.cc,data_cth,mask_nonfor2);
%     orleans.cth_nonfor3 = get_cth_region(orleans.cc,data_cth,mask_nonfor3);

    orleans.ccmat = make_cc_plot(orleans.cc_forest,...
        orleans.cc_nonfor1,orleans.cc_nonfor2,[casename num2str(years(c))]);
    save(['Data\matlab\orleans_cc_' int2str(years(c)) '_' int2str(ot_lim) '.mat'],'orleans', '-v7.3')
    
end



function [cc,data_ot,time,isday] = get_cc(data_cc,data_ot,time,ot_lim)

%idx_leapy = ~(time(:,2)==2 & time(:,3)==29);
idx_leapy = [1:96*365];
time = time(idx_leapy,:);
data_cc = data_cc(:,:,idx_leapy);
data_ot = data_ot(:,:,idx_leapy);
% data_cth = data_cth(:,:,idx_leapy);
cc = single(zeros(size(data_cc)));
isday = logical(ones(size(data_cc,3),1));
for n = 1:size(data_cc,3)
    tmp1 = squeeze(data_cc(:,:,n));
    tmp2 = squeeze(data_ot(:,:,n));
    cc(:,:,n) = ((tmp1 == 2 | tmp1 == 3) & tmp2 > ot_lim); %% change cloud flag 
    if sum(tmp1(:) == -1) > 0
        cc(:,:,n) = NaN;
        isday(n) = 0;
    else
    end
end

function [cc_reg] = get_cc_region(cc,mask)

cc_reg = zeros(size(cc,3),1);
for n = 1:size(cc,3)
    tmp = squeeze(cc(:,:,n));
    tmp_ = tmp(mask);
    cc_reg(n) = mean(tmp_);
end

function [cth_reg] = get_cth_region(cc,cth,mask)

cth_reg = zeros(size(cc,3),1);
for n = 1:size(cc,3)
    tmp1 = squeeze(cc(:,:,n));
    tmp2 = squeeze(cth(:,:,n));
    tmp1_ = tmp1(mask);
    tmp2_ = tmp2(mask);
    cth_reg(n) = mean(tmp2_(tmp1_==1));
end

function [cc_diff] = make_cc_plot(cc_forest,cc_nonfor1,cc_nonfor2,filename)

cmap = [127 59 8;
179 88 6;
224 130 20;
253 184 99;
254 224 182;
247 247 247;
216 218 235;
178 171 210;
128 115 172;
84 39 136;
45 0 75]./255;


cc_diff1 = reshape(cc_forest-cc_nonfor1,96,365);
cc_diff2 = reshape(cc_forest-cc_nonfor2,96,365);
cc_diff = (cc_diff1 + cc_diff2)./2;
%cc_diff(abs(sign(cc_diff1) + sign(cc_diff2) + sign(cc_diff3)) < 3) = 0;
%cc_diff(isnan(cc_diff)) = 0;


% figure
% imagesc(cc_diff)
% set(gca,'CLim',[-1 1])
% colormap(cmap)
% colorbar
% print(gcf,'-dpdf','-painters','-loose',['figs\' filename]);
% close(gcf)