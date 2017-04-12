disk = 'G';         % Disk that contains Thesis folder (set as working directory).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                              %%% RQ 2 %%%
                   %%% Weather variable correlation %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 load([disk, ':\Thesis\Data\matlab\results\Weather_variables_table_trainings_set_10000.mat']);

    
    %%% Subset creation
    % Create two datasets, one with only data of additional cloud formation
    % moments, and one set with the remaining data. This makes sure there
    % are as many 1's as 0's in the response dataset.
    
    
    %%% Create two datasets, one with only data of additional cloud formation
    % moments, and one set with the remaining data.
    only_zeros = cloud_vars;
    only_zeros(1,:) = [];
    only_zeros(:,1) = [];
    only_zeros = cell2mat(only_zeros);
    only_zeros(only_zeros(:,2) == 1,:) = [];
    
    only_ones = cloud_vars;
    only_ones(1,:) = [];
    only_ones(:,1) = [];
    only_ones = cell2mat(only_ones);
    only_ones(only_ones(:,2) == 0,:) = [];
    
    %%% Independent T-Test (Welch Test)
    % Checking if the means of the weather variables are significantly
    % different between the two samples
    
    % Select which variables to test - See table below for right column-numbers
    var_sel = [3 4 5 6 7 8 9 10 11];
    
    % Create sample 1
    no_cloud_sample = only_zeros(:,var_sel);
    
    % Create sample 2
    add_cloud_sample = only_ones(:,var_sel);
    
       
    % T-test itself
    [h, p, ci, stats] = ttest2(no_cloud_sample, add_cloud_sample,'Vartype','unequal');
    
    
    

%     % Circ stats
%     circzeros = only_zeros(:,12);
%     circones =  only_ones(:,12);
%     
%     max_r = length(circzeros);
%     n_s = length(circones);
%     p_r = randperm(max_r,n_s);
%     circzeros_sel = circzeros(p_r);
%     
%     [pval, table] = circ_wwtest(circzeros_sel,circones);
    
    %%%%%%%%%%% Weather variables to chose from %%%%%%%%
    %2  cloud flag
    %3  2m Temperature
    %4  2m dewpoint temperature
    %5  10 metre U wind component
    %6  10 metre V wind component
    %7  Convective precipitation
    %8  Evaporation
    %9  Mean sea level pressure
    %10 Total water column
    %11 abs wind speed
    %12 wind direction (radians)
    %13 wind direction (degrees)
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           %%%   PLOTS    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Boxplots
% Just T



