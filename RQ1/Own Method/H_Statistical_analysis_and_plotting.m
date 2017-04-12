disk = 'D';         % Disk that contains Thesis folder (set as working directory).

cl_t = '10';       % 

regionname = 'landes';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% which statistics and plots should be executed?
rq1 = 0;
rq2 = 1;
rq3 = 0;
rq4 = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                              %%% RQ 1 %%%
                         %%% Albedo map anlysis %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if rq1 == 1
    disp('Carrying out rq1');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                              %%% RQ 2 %%%
                   %%% Weather variable correlation %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if rq2 == 1
    if exist('cloud_vars', 'var') ~= 1
        % load([disk ':\Thesis\Data\matlab\results\Weather_variables_table_' regionname '_' cl_t '.mat']);
        load([disk ':\Thesis\Data\matlab\NN\trainingsdata_landes_10000_samples.mat']);
    end
    
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
    var_sel = [3 4 8 9 11];
    
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                              %%% RQ 3 %%%
                       %%% Minimal forest size %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if rq3 == 1
    disp('Carrying out rq3');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                              %%% RQ 4 %%%
                       %%% Implications cloud budget %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if rq4 == 1
    disp('Carrying out rq4');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
