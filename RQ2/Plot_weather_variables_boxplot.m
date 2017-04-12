var_sel = [4 5 6 8 10 12];

% Load in data
load('G:\Thesis\Data\matlab\results\Weather_variables_table_trainings_set_10000.mat');
flagdata = cell2mat(cloud_vars(2:end,3));
boxdata_raw = cell2mat(cloud_vars(2:end,var_sel));


% Create normalized data (all values between [0 1]
boxdata_norm = zeros(size(boxdata_raw));
for i = 1:size(boxdata_raw,2)
    boxdata_norm(:,i) = (boxdata_raw(:,i) - min(boxdata_raw(:,i)))/(max(boxdata_raw(:,i))-min(boxdata_raw(:,i)));
end

%%% Prepare data for grouped boxplots, 
% The normalized data itself
boxdata = boxdata_norm(:);      

% The grouping variable and positions
box_groups = [];                
positions_tmp = [1 1.25];
tickpos_tmp = mean(positions_tmp(1:2));
for j = 1:length(var_sel)
    if j == 1
        box_groups = flagdata;
        positions = positions_tmp;
        tickpos = tickpos_tmp;
    else
        flagdata = flagdata + 2;
        box_groups = cat(1,box_groups,flagdata);
        positions_tmp = positions_tmp + 1;
        tickpos_tmp = mean(positions_tmp);
        positions = cat(2,positions, positions_tmp);
        tickpos = cat(2, tickpos,tickpos_tmp);
    end
end


%%%%%%%%%%%%%%%%%% Create plot %%%%%%%%%%%%%%%%%%%
boxplot(boxdata, box_groups, 'positions', positions,'OutlierSize',18,'Symbol','k.');
xlabel('Weather variables');
ylabel('Normalized Y [-]');


%%% Setup x-axis
% Labels
set(gca,'xtick',tickpos)

ticklabels_x = cell(1,length(var_sel));
for k = 1:length(var_sel)
    ticklabels_x{k} = cloud_vars{1,var_sel(k)};
end
% Or set x-labels manually:
% ticklabels_x = {'Temperature','Pressure', 'Wind speed'};
set(gca,'xticklabel',ticklabels_x)

%%% Boxes 
color = repmat(['y', 'k'],1,length(var_sel));
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end

% Median
g = findobj(gca,'Tag','Median');
set(g,'linew',2);
set(g,'Color','k');

%%% Legend
c = get(gca, 'Children');
hleg1 = legend(c(1:2), 'Regular', 'Additional clouds' );
