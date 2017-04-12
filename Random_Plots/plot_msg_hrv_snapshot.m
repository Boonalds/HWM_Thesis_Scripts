function [] = plot_msg_hrv_snapshot(regionname,year,month,day,hour)

disk = 'D';

% regionname = 'landes' or 'orleans'
% year = index of year in 2004:2013
% month = idx of month in July, August
% day = day of month

years = {'2004';'2005';'2006';'2007';'2008';'2009';'2010';'2011';'2012';'2013'};
months = {'05';'06';'07';'08'};
days = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';...
    '13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';...
    '25';'26';'27';'28';'29';'30';'31'};
hours  = {'0600';'0615';'0630';'0645';'0700';'0715';'0730';'0745';...
    '0800';'0815';'0830';'0845';'0900';'0915';'0930';'0945';...
    '1000';'1015';'1030';'1045';'1100';'1115';'1130';'1145';...
    '1200';'1215';'1230';'1245';'1300';'1315';'1330';'1345';...
    '1400';'1415';'1430';'1445';'1500';'1515';'1530';'1545';...
    '1600';'1615';'1630';'1645';'1700';'1715';'1730';'1745'};

power = .5;
offset = 70;

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


filename = [disk, ':\Thesis\Data\ch12\', years{year}, '\', months{month}, '\', ...
    years{year}, months{month}, days{day}, hours{hour}, '.gra'];
if exist(filename, 'file') == 2
    fileID = fopen(filename,'r','l');
    A = fread(fileID,inf,'int16=>int16');
    fclose(fileID);
    ch12 = reshape(A,440,417);
else
    warning('File not found');
end
ch12sel = ch12(idx_region_r,idx_region_c,:);

if year <= 5
    switch regionname
        case 'landes'
            load Data\matlab\hrv_cloudflag_landes_2004_2008_10.mat
        case 'orleans'
            load Data\matlab\hrv_cloudflag_orleans_2004_2008_10.mat
        otherwise
            warning('Unknown regionname.')
    end
elseif year >= 6
    switch regionname
        case 'landes'
            load Data\matlab\hrv_cloudflag_landes_2009_2013_10.mat
        case 'orleans'
            load Data\matlab\hrv_cloudflag_orleans_2009_2013_10.mat
        otherwise
            warning('Unknown regionname.')
    end
else
end

if year <= 5
    yearadj = year;
elseif year >= 6
    yearadj = year - 5;
else
end

ch12selcloudmask = ch12sel;
ch12selcloudmask(squeeze(cloudflag_10(yearadj,month,day,hour,:,:)==2)) = 0;



shore = load('Data\matlab\france_shore.dat');

load Data\hrv_grid\hrv_grid


% figure of raw signal
for c = 1
    makefigure(8,6); delete(gca)
    cmap = gray;

    hltxt = axes('Position',[0 0 1 1]);
    text(1-.05*.8,.5,'Count (-)','fontsize',8,...
        'Rotation',90,'HorizontalAlignment','Center',...
        'VerticalAlignment','Bottom')
    set(hltxt,'visible','off')

    hlc = axes('Position',[.79 .05 .03 .9]);
%     boxLim = [50:50:500];
    boxLim = [2 22];
    boxTick = [(100:50:550)-offset].^power;
    boxLims = linspace(boxLim(1),boxLim(end),length(cmap)+1);
    hold on
    for n = 1:length(cmap)
        fill([0 1 1 0 0],[boxLims(n) boxLims(n) boxLims(n+1) boxLims(n+1) ...
            boxLims(n)],cmap(n,:),'EdgeColor','None')
    end
    set(hlc,'YTick',boxTick,'XTick',[],'XLim',[0 1],'Layer','Top',...
        'YLim',boxLim([1 end]),'YAxisLocation','Right','fontsize',8,...
        'Box','On','YTickLabel',{'100';'150';'200';'250';'300';...
        '350';'400';'450';'500';'550'})

    axes('Position',[.05*.8 .05 .8-(2*.05*.8) .9]); hold on

    box_lims
    switch regionname
        case 'landes'
            axesm('MapProjection','lambert','Frame','on','grid','off',...
                'MapLatLimit',landes.regionbox.latlim,...
                'MapLonLimit',landes.regionbox.lonlim,...
                'FLineWidth',.5)
        case 'orleans'
            axesm('MapProjection','lambert','Frame','on','grid','off',...
                'MapLatLimit',orleans.regionbox.latlim,...
                'MapLonLimit',orleans.regionbox.lonlim,...
                'FLineWidth',.5)
    end

    tightmap

    colormap(cmap)
    if c == 1
        switch regionname
            case 'landes'
                hl = pcolorm(landes.hrv_lat,landes.hrv_lon,...
                    (double(ch12sel)-offset).^power);
            case 'orleans'
                hl = pcolorm(orleans.hrv_lat,orleans.hrv_lon,...
                    (double(ch12sel)-offset).^power);
        end
    elseif c == 2
        switch regionname
            case 'landes'
                hl = pcolorm(landes.hrv_lat,landes.hrv_lon,...
                    (double(ch12selcloudmask)-offset).^power);
            case 'orleans'
                hl = pcolorm(orleans.hrv_lat,orleans.hrv_lon,...
                    (double(ch12selcloudmask)-offset).^power);
        end
    else
    end

    linem(shore(:,2),shore(:,1),'k')
    set(gca,'layer','top','color','none','clim',boxLim([1 end]),'visible','off')

    plot_box_lims(regionname)
    
    if c == 1
        print(gcf,'-dpng','-painters','-loose',['Data\animations\hrv_' regionname ...
            '_' years{year} '_' months{month} '_' days{day} ...
            '_' hours{hour} '.png']);
    elseif c == 2
        print(gcf,'-dpng','-painters','-loose',['Data\animations\hrv_cloudmask' regionname ...
            '_' years{year} '_' months{month} '_' days{day} ...
            '_' hours{hour} '.png']);
    else
    end

    % print(gcf,'-dpng','-r300','-loose',['animations\' regionname ...
    %     '_' int2str(year) '_' num2str(month,'%02d') '_' num2str(day,'%02d') ...
    %     '_' num2str(hour,'%02d') '_' num2str(minute,'%02d') ...
    %     '.png']);
    close(gcf)
end



