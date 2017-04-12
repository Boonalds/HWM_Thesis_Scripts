% Variables:
disk = 'G';
cmap = gray;

%%% Load required data
box_lims
region_lat = landeslims.regionbox.latlim;
region_lon = landeslims.regionbox.lonlim;

load Data\hrv_grid\hrv_grid;
hrv_lat = landes.hrv_lat;
hrv_lon = landes.hrv_lon;

%%% Strings to loop from 2004-2014
yrs_list = {'2004','2008','2009','2013'};


%%% CORE - extraction of albedo values from every albedo map and storing
%%% the relative difference between forest and non-forest


% 2004-2008
net_albedo_map = load([disk ':\Thesis\Data\matlab\net_albedo_maps\net_albedo_map_landes_2004_2008.mat']);
reg_albedo_map = load([disk ':\Thesis\Data\matlab\reflectance\surface_reflectance_landes_2004_2008.mat']);

albedo_diff_values_1 = zeros(4*3*12,4);
i = 1;
for m = 1:4
    for dec = 1:3
        for h = 1:12
            
            % Load in maps
            reg_map = double(squeeze(reg_albedo_map.surfrefl(m,dec,h,:,:)));
            net_map = double(squeeze(net_albedo_map.surfrefl(m,dec,h,:,:)));
            
            % Normalize
            reg_map_norm = (reg_map - min([min(reg_map(:)) min(net_map(:))]))/(max([max(reg_map(:)) max(net_map(:))])-min([min(reg_map(:)) min(net_map(:))]))*100;
            net_map_norm = (net_map - min([min(reg_map(:)) min(net_map(:))]))/(max([max(reg_map(:)) max(net_map(:))])-min([min(reg_map(:)) min(net_map(:))]))*100;
            
            % Extract mean albedo f and nf for regular and net situation
            
            %%% regular
            reg_f = mean2(reg_map_norm(64:107,40:65));
            reg_nf1 = mean2(reg_map_norm(40:84,5:32));
            reg_nf2 = mean2(reg_map_norm(71:114,79:104));
            
            %%% net
            net_f = mean2(net_map_norm(64:107,40:65));
            net_nf1 = mean2(net_map_norm(40:84,5:32));
            net_nf2 = mean2(net_map_norm(71:114,79:104));
            
            %%% Calculate differences
            albedo_diff_values_1(i,1) = ((reg_nf1 - reg_f)/reg_f)*100;
            albedo_diff_values_1(i,2) = ((reg_nf2 - reg_f)/reg_f)*100;
            albedo_diff_values_1(i,3) = ((net_nf1 - net_f)/net_f)*100;
            albedo_diff_values_1(i,4) = ((net_nf2 - net_f)/net_f)*100;
            
            %%% After analysis
            % Checking normalization
            reg_f_raw(i) = mean2(reg_map(64:107,40:65));
            reg_nf1_raw(i) = mean2(reg_map(40:84,5:32));
            reg_nf2_raw(i) = mean2(reg_map(71:114,79:104));
            net_f_raw(i) = mean2(net_map(64:107,40:65));
            net_nf1_raw(i) = mean2(net_map(40:84,5:32));
            net_nf2_raw(i) = mean2(net_map(71:114,79:104));
            
          
            net_f_1(i) = net_f;
            net_nf1_1(i) = net_nf1;
            net_nf2_1(i) = net_nf2;
            reg_f_1(i) = reg_f;
            reg_nf1_1(i) = reg_nf1;
            reg_nf2_1(i) = reg_nf2;

            
            i = i+1;
        end
    end
end

albedo_diff_values_1 = albedo_diff_values_1(3:end,:);


% 2009-2013
net_albedo_map = load([disk ':\Thesis\Data\matlab\net_albedo_maps\net_albedo_map_landes_2009_2013.mat']);
reg_albedo_map = load([disk ':\Thesis\Data\matlab\reflectance\surface_reflectance_landes_2009_2013.mat']);

albedo_diff_values_2 = zeros(4*3*12,4);
i = 1;
for m = 1:4
    for dec = 1:3
        for h = 1:12
            
            % Load in maps
            reg_map = double(squeeze(reg_albedo_map.surfrefl(m,dec,h,:,:)));
            net_map = double(squeeze(net_albedo_map.surfrefl(m,dec,h,:,:)));
            
            % Normalize
            reg_map_norm = (reg_map - min([min(reg_map(:)) min(net_map(:))]))/(max([max(reg_map(:)) max(net_map(:))])-min([min(reg_map(:)) min(net_map(:))]))*100;
            net_map_norm = (net_map - min([min(reg_map(:)) min(net_map(:))]))/(max([max(reg_map(:)) max(net_map(:))])-min([min(reg_map(:)) min(net_map(:))]))*100;
            
            % Extract mean albedo f and nf and calc difference percentage
            % for regular and net albedo
            
            % Extract mean albedo f and nf for regular and net situation
            
            %%% regular
            reg_f = mean2(reg_map_norm(64:107,40:65));
            reg_nf1 = mean2(reg_map_norm(40:84,5:32));
            reg_nf2 = mean2(reg_map_norm(71:114,79:104));
            
            %%% net
            net_f = mean2(net_map_norm(64:107,40:65));
            net_nf1 = mean2(net_map_norm(40:84,5:32));
            net_nf2 = mean2(net_map_norm(71:114,79:104));
            
            %%% Calculate differences
            albedo_diff_values_2(i,1) = ((reg_nf1 - reg_f)/reg_f)*100;
            albedo_diff_values_2(i,2) = ((reg_nf2 - reg_f)/reg_f)*100;
            albedo_diff_values_2(i,3) = ((net_nf1 - net_f)/net_f)*100;
            albedo_diff_values_2(i,4) = ((net_nf2 - net_f)/net_f)*100;
           
            i = i+1;
        end
    end
end



%%% PLOT GRAPHS
color_blue = [0 0.45 0.75];
color_orange = [0.85 0.325 0.1];


close all
figure

subplot(1,2,1)   % 2004-2008
p1_1 = plot(albedo_diff_values_1(:,1),'-','Color',color_blue);
hold on
p2_1 = plot(albedo_diff_values_1(:,2),'-','Color',color_orange);
hold on
p3_1 = plot(albedo_diff_values_1(:,3),'--','Color',color_blue);
hold on
p4_1 = plot(albedo_diff_values_1(:,4),'--','Color',color_orange);

% lims
xlim([0 size(albedo_diff_values_1,1)]);

% Shade area
xlims = [34 46];
ylims = get(gca, 'ylim');
%patch([xlims(1) xlims(2) xlims(2) xlims(1)], [ylims(1) ylims(1) ylims(2) ylims(2)],'k','FaceAlpha',.5,'EdgeColor','none');

%%% Labels etc
legend([p1_1 p2_1 p3_1 p4_1],{'Non-forest 1, clear sky','Non-forest 2, clear sky','Non-forest 1, average','Non-forest 2, average'})
ylabel('Reflectance difference [%]');
% xlabel('Timestep');

%%% Xlabels - months
x_labels_months = {'May','June','July','August'};
x_ticks_months = 34:36:142;
x_tick_diff = x_ticks_months(2) - x_ticks_months(1);
x_tick_label_positions = x_ticks_months - 0.6*x_tick_diff;

xticks(x_ticks_months);
set(gca,'tickdir','out')

% Use text to display months at right loc
for i=1:length(x_tick_label_positions)
    text(x_tick_label_positions(i),ylims(1)-1,x_labels_months(i)); 
end

set(gca,'XTickLabel',{}); % make old labels invis

%%% Xlabels - draw lines as ticks for dec
x_ticks_dec = 10:12:274;

for i=1:length(x_ticks_dec)
    line([x_ticks_dec(i) x_ticks_dec(i)], [ylims(1) ylims(1)+0.5],'Color','k');
end

%%% Xlabels - years
xlabel('2004-2008','FontSize',11,'FontWeight','bold');
xlab = get(gca,'XLabel');
set(xlab,'Position',get(xlab,'Position')-[0 ((ylims(2)-ylims(1))/50) 0])




subplot(1,2,2)   % 2009-2013
p1_2 = plot(albedo_diff_values_2(:,1),'-','Color',color_blue);
hold on
p2_2 = plot(albedo_diff_values_2(:,2),'-','Color',color_orange);
hold on
p3_2 = plot(albedo_diff_values_2(:,3),'--','Color',color_blue);
hold on
p4_2 = plot(albedo_diff_values_2(:,4),'--','Color',color_orange);

% lims
xlim([0 size(albedo_diff_values_2,1)]);
ylim(ylims);

%%% Labels etc
legend([p1_2 p2_2 p3_2 p4_2],{'Non-forest 1, clear sky','Non-forest 2, clear sky','Non-forest 1, average','Non-forest 2, average'})
ylabel('Reflectance difference [%]');
% xlabel('Timestep');

%%% Xlabels - months
x_labels_months = {'May','June','July','August'};
x_ticks_months = 36:36:144;
x_tick_diff = x_ticks_months(2) - x_ticks_months(1);
x_tick_label_positions = x_ticks_months - 0.6*x_tick_diff;

xticks(x_ticks_months);
set(gca,'tickdir','out')

% Use text to display months at right loc
for i=1:length(x_tick_label_positions)
    text(x_tick_label_positions(i),ylims(1)-1,x_labels_months(i)); 
end

set(gca,'XTickLabel',{}); % make old labels invis

%%% Xlabels - draw lines as ticks for dec
x_ticks_dec = 12:12:276;

for i=1:length(x_ticks_dec)
    line([x_ticks_dec(i) x_ticks_dec(i)], [ylims(1) ylims(1)+0.5],'Color','k');
end


%%% Xlabels - years
xlabel('2009-2013','FontSize',11,'FontWeight','bold');
xlab = get(gca,'XLabel');
ylims = get(gca, 'ylim');
set(xlab,'Position',get(xlab,'Position')-[0 ((ylims(2)-ylims(1))/50) 0])


 

% 
% 
% % 
% % %%%%%%%%%%%%%%%%%%%%%% PLOT REFLECTANCES   FOR AFTER ANALYSIS   %%%%%%%%%%%%
% % 
% % Dit gaat in de eerste loop hierboven:
% 
%             %loop1
% % % Extra plots for reflectance check
% % net_f_1(i) = net_f;
% % net_nf1_1(i) = net_nf1;
% % net_nf2_1(i) = net_nf2;
% % reg_f_1(i) = reg_f;
% % reg_nf1_1(i) = reg_nf1;
% % reg_nf2_1(i) = reg_nf2;
% 
% % reg_f_raw(i) = mean2(reg_map(64:107,40:65));
% % reg_nf1_raw(i) = mean2(reg_map(40:84,5:32));
% % reg_nf2_raw(i) = mean2(reg_map(71:114,79:104));
% % net_f_raw(i) = mean2(net_map(64:107,40:65));
% % net_nf1_raw(i) = mean2(net_map(40:84,5:32));
% % net_nf2_raw(i) = mean2(net_map(71:114,79:104));
% 
% 
% 
% 
%   % dit blijft hier
% reg_f_1 = reg_f_1(3:end);
% reg_nf1_1 = reg_nf1_1(3:end);
% reg_nf2_1 = reg_nf2_1(3:end);
% net_f_1 = net_f_1(3:end);
% net_nf1_1 = net_nf1_1(3:end);
% net_nf2_1 = net_nf2_1(3:end);
% 
% reg_f_raw = reg_f_raw(3:end);
% reg_nf1_raw = reg_nf1_raw(3:end);
% reg_nf2_raw = reg_nf2_raw(3:end);
% net_f_raw = net_f_raw(3:end);
% net_nf1_raw = net_nf1_raw(3:end);
% net_nf2_raw = net_nf2_raw(3:end);
% 
% 
% figure
% 
% subplot(1,2,1)
% title('Raw reflectance values per region 2004--2008')
% p1_1 = plot(reg_f_raw,'-','Color','k');
% hold on
% p2_1 = plot(reg_nf1_raw,'-','Color',color_orange);
% hold on
% p3_1 = plot(reg_nf2_raw,'-','Color',color_blue);
% hold on
% p4_1 = plot(net_f_raw,'--','Color','k');
% hold on
% p5_1 = plot(net_nf1_raw,'--','Color',color_orange);
% hold on
% p6_1 = plot(net_nf2_raw,'--','Color',color_blue);
% 
% 
% subplot(1,2,2)
% title('Normalized reflectance values per region per region 2004--2008')
% p1_2 = plot(reg_f_1,'-','Color','k');
% hold on
% p2_2 = plot(reg_nf1_1,'-','Color',color_orange);
% hold on
% p3_2 = plot(reg_nf2_1,'-','Color',color_blue);
% hold on
% p4_2 = plot(net_f_1,'--','Color','k');
% hold on
% p5_2 = plot(net_nf1_1,'--','Color',color_orange);
% hold on
% p6_2 = plot(net_nf2_1,'--','Color',color_blue);
% legend([p1_2 p2_2 p3_2 p4_2 p5_2 p6_2],{'reg f','reg nf1','reg nf2','net f','net nf1','net nf2'})
% 
% 
% %%%%%% PLOT MAPS %%%%
% %%%%%%
% % %%% Plot the two maps together
% y_p = 1;    % 1 for 2004-2008, 2 for 2009-2013
% m_p = 1;    % month
% dec_p = 2;  % decade
% h_p = 8;    % hour
% 
% forest_lat = landeslims.forestbox.latlim;
% forest_lon = landeslims.forestbox.lonlim;
% nonfor1_lat = landeslims.nonforbox1.latlim;
% nonfor1_lon = landeslims.nonforbox1.lonlim;
% nonfor2_lat = landeslims.nonforbox2.latlim;
% nonfor2_lon = landeslims.nonforbox2.lonlim;
% 
% % To help find a plot
% timestep = (y_p-1)*144 + (m_p-1)*36 + (dec_p-1)*12 + h_p;
% 
% net_albedo_map = load([disk ':\Thesis\Data\matlab\net_albedo_maps\net_albedo_map_landes_' yrs_list{2*y_p-1} '_' yrs_list{2*y_p} '.mat']);
% reg_albedo_map = load([disk ':\Thesis\Data\matlab\reflectance\surface_reflectance_landes_' yrs_list{2*y_p-1} '_' yrs_list{2*y_p} '.mat']);
% p_reg_map = double(squeeze(reg_albedo_map.surfrefl(m_p,dec_p,h_p,:,:)));
% p_net_map = double(squeeze(net_albedo_map.surfrefl(m_p,dec_p,h_p,:,:)));
% 
% figure
% 
% subplot(1,2,1);
% axis image;
% axesm('MapProjection','lambert','Frame','on','grid','on', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
% colormap(cmap);
% pcolorm(hrv_lat,hrv_lon,p_reg_map);
% title('Clear-sky Reflectance');
% colorbar
% 
% %forestbox:
% box1 = linem([max(forest_lat); min(forest_lat);...
%     min(forest_lat); max(forest_lat);...
%     max(forest_lat)], [min(forest_lon);... 
%     min(forest_lon); max(forest_lon);...
%     max(forest_lon); min(forest_lon)],...
%     'Color',[0.2 0.85 0.4], 'LineWidth', 3, 'LineStyle', ':');
% box2 = linem([max(nonfor1_lat); min(nonfor1_lat);...
%     min(nonfor1_lat); max(nonfor1_lat);...
%     max(nonfor1_lat)], [min(nonfor1_lon);...
%     min(nonfor1_lon); max(nonfor1_lon);...
%     max(nonfor1_lon); min(nonfor1_lon)],...
%     'Color',[0 0.8 0.8], 'LineWidth', 3);
% box3 = linem([max(landeslims.nonforbox2.latlim); min(landeslims.nonforbox2.latlim);...
%     min(landeslims.nonforbox2.latlim); max(landeslims.nonforbox2.latlim);...
%     max(landeslims.nonforbox2.latlim)], [min(landeslims.nonforbox2.lonlim);...
%     min(landeslims.nonforbox2.lonlim); max(landeslims.nonforbox2.lonlim);...
%     max(landeslims.nonforbox2.lonlim); min(landeslims.nonforbox2.lonlim)],...
%     'Color',[0.8 0.2 1.0], 'LineWidth', 3);
% l = legend([box1 box2 box3], 'Forest','Non-forest1','Non-forest2', 'Location','northeast');
% h = colorbar;    
% ylabel(h, 'Reflectance (-)');
% 
% 
% subplot(1,2,2);
% axis image;
% axesm('MapProjection','lambert','Frame','on','grid','on', 'MapLatLimit',region_lat,'MapLonLimit',region_lon,'FLineWidth',.5);
% colormap(cmap);
% pcolorm(hrv_lat,hrv_lon,p_net_map);
% title('Average Reflectance');
% colorbar
% box1 = linem([max(forest_lat); min(forest_lat);...
%     min(forest_lat); max(forest_lat);...
%     max(forest_lat)], [min(forest_lon);...
%     min(forest_lon); max(forest_lon);...
%     max(forest_lon); min(forest_lon)],...
%     'Color',[0.2 0.85 0.4], 'LineWidth', 3, 'LineStyle', ':');
% box2 = linem([max(nonfor1_lat); min(nonfor1_lat);...
%     min(nonfor1_lat); max(nonfor1_lat);...
%     max(nonfor1_lat)], [min(nonfor1_lon);...
%     min(nonfor1_lon); max(nonfor1_lon);...
%     max(nonfor1_lon); min(nonfor1_lon)],...
%     'Color',[0 0.8 0.8], 'LineWidth', 3);
% box3 = linem([max(landeslims.nonforbox2.latlim); min(landeslims.nonforbox2.latlim);...
%     min(landeslims.nonforbox2.latlim); max(landeslims.nonforbox2.latlim);...
%     max(landeslims.nonforbox2.latlim)], [min(landeslims.nonforbox2.lonlim);...
%     min(landeslims.nonforbox2.lonlim); max(landeslims.nonforbox2.lonlim);...
%     max(landeslims.nonforbox2.lonlim); min(landeslims.nonforbox2.lonlim)],...
%     'Color',[0.8 0.2 1.0], 'LineWidth', 3);
% h = colorbar;    
% ylabel(h, 'Reflectance (-)');
% 
% 
% 






