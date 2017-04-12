disk = 'D';         % Disk that contains Thesis folder (set as working directory).
var_sel = [4 10 12];  % Table to chose at bottom of script
wind_dir_analysis = 0;  % Perform wind direction analysis, 1=y/0=no


%%%%%%%% Weather variable correlation %%%%%%%%

%%%  Load and prepare data
load([disk, ':\Thesis\Data\matlab\results\Weather_variables_table_trainings_set_10000.mat']);

% Create two datasets, one with only data of additional cloud formation
% moments, and one set with the remaining data.
var_sel = cat(2, 3, var_sel);

vars_zeros = cell2mat(cloud_vars(2:end,var_sel));
vars_ones = cell2mat(cloud_vars(2:end,var_sel));

vars_zeros(vars_zeros(:,1) == 1,:) = [];
vars_ones(vars_ones(:,1) == 0,:) = [];

vars_zeros(:,1) = [];
vars_ones(:,1) = [];

%%% Statistics
% Independent T-Test (Welch Test) h0: means = equal

vars_zeros(:,1) = vars_zeros(:,1) - 272.15;
vars_ones(:,1) = vars_ones(:,1) - 272.15;

[h, p, ci, stats] = ttest2(vars_zeros, vars_ones, 'Vartype', 'unequal');

ws_mean_reg = mean(vars_zeros(:,3));
ws_mean_cl = mean(vars_ones(:,3));
ws_std_reg = std(vars_zeros(:,3));
ws_std_cl = std(vars_ones(:,3));

%%%%%%%% Wind direction analysis correlation %%%%%%%%

if wind_dir_analysis == 1
    % Extract wind direction in radians
    circ_zeros = cell2mat(cloud_vars(2:end,[3 13]));
    circ_ones = cell2mat(cloud_vars(2:end,[3 13]));
    
    circ_zeros(circ_zeros(:,1) == 1,:) = [];
    circ_ones(circ_ones(:,1) == 0,:) = [];
    
    circ_zeros(:,1) = [];
    circ_ones(:,1) = [];
    
    [U2, p_circ] = watson1962(circ_zeros, circ_ones);    
    
    %%%%% Plot
   
    % Bin limits, so the bins are centered around N, NW, W, SW etc..
    bin_limits_list = [pi*1/8 pi*3/8 pi*5/8 pi*7/8 pi*9/8 pi*11/8 pi*13/8 pi*15/8 pi*17/8];    %%% For different bins only change this and..
    bin_labels_list = {'NE'; 'E'; 'SE'; 'S'; 'SW'; 'W'; 'NW'; 'N'};                            %%% This.. 
    bin_labels_loc_list = bin_limits_list(1:end-1)+(pi*1/8);
    
    
    % Create relative frequency bin values
    pol_reg_values = zeros(1,length(bin_limits_list)-1);
    pol_cloud_values = zeros(1,length(bin_limits_list)-1);
    
    for i = 1:length(pol_reg_values)
        pol_reg_values(i) = ((sum(circ_zeros(:) > bin_limits_list(i) & circ_zeros(:) <= bin_limits_list(i+1)))/size(circ_zeros,1))*100;
        pol_cloud_values(i) = ((sum(circ_ones(:) > bin_limits_list(i) & circ_ones(:) <= bin_limits_list(i+1)))/size(circ_ones,1))*100;
    end
    
    % R axis limits and labels
    rlim_max = 10*ceil((max(max(pol_reg_values(:)), max(pol_cloud_values(:))))/10);
    rlabels_list = cell(1,(rlim_max/10));
    
    for i = 10:10:rlim_max
        rlabels_list{i/10} = ['\fontsize{9} ', num2str(i), '%'];
    end
    

    % Plot itself
    close all
    
    
    subplot(1,2,1);  % Regular situation
    polarhistogram('BinEdges',bin_limits_list, 'BinCounts',pol_reg_values);
    rlim([0 rlim_max]);
        
    % Appearance of polarhistogram
    title('Regular situation');
    set(gca,'ThetaDir','clockwise',...
            'ThetaZeroLocation','top',...
            'ThetaTickMode', 'manual',...
            'ThetaAxisUnits', 'radians',...
            'ThetaTick', bin_labels_loc_list,...
            'ThetaTickLabelMode', 'manual',...
            'ThetaTickLabel',bin_labels_list,...
            'ThetaGrid','off',...
            'RAxisLocation',2*pi+0.0001,...
            'RTick',10:10:rlim_max,...
            'RTickLabel', rlabels_list...
        );
    
    % Create theta-axis
    hold on
    for i = 1:(length(bin_limits_list)-1)/2
        polarplot([bin_limits_list(i) bin_limits_list(i+(length(bin_limits_list)-1)/2)], [rlim_max rlim_max],':k', 'LineWidth', 0.25);
    end
    hold off
    
    
    
    subplot(1,2,2);  % Cloud formation
    polarhistogram('BinEdges',bin_limits_list, 'BinCounts',pol_cloud_values);
    rlim([0 rlim_max]);
        
    % Appearance of polarhistogram
    title('      Additional \newline Cloud formation');
    set(gca,'ThetaDir','clockwise',...
            'ThetaZeroLocation','top',...
            'ThetaTickMode', 'manual',...
            'ThetaAxisUnits', 'radians',...
            'ThetaTick', bin_labels_loc_list,...
            'ThetaTickLabelMode', 'manual',...
            'ThetaTickLabel',bin_labels_list,...
            'ThetaGrid','off',...
            'RAxisLocation',2*pi+0.0001,...
            'RTick',10:10:rlim_max,...
            'RTickLabel', rlabels_list...
        );
    
    % Create theta-axis
    hold on
    for i = 1:(length(bin_limits_list)-1)/2
        polarplot([bin_limits_list(i) bin_limits_list(i+(length(bin_limits_list)-1)/2)], [rlim_max rlim_max],':k', 'LineWidth', 0.25);
    end
    hold off
        
end



%%% Weather variables to chose from 
%4  2m Temperature
%5  2m dewpoint temperature
%6  10 metre U wind component
%7  10 metre V wind component
%8  Convective precipitation
%9  Evaporation
%10  Mean sea level pressure
%11 Total water column
%12 abs wind speed