load('D:\Thesis\Data\matlab\results\Weather_variables_table_trainings_set_10000.mat');

test_set = cell2mat(cloud_vars(2:end,[6 7 12 13]));
test_set = cat(2,test_set,zeros(size(test_set,1),1));

% 1: uwind      2: vwind     3: abs wind      4: dir_old (rad)  5:dir_new


for i = 1:size(test_set,1);
    test_set(i,5) = atan2((test_set(i,1)/test_set(i,3)),(test_set(i,2)/test_set(i,3)));

    % Convert wind direction to angle the wind is coming from (meteorological convention)
    test_set(i,5) = test_set(i,5) + pi;
end


% cloud_vars{i,13} = atan2(cloud_vars{i,6}, cloud_vars{i,7});  % radians
% cloud_vars{i,14} = cloud_vars{i,14} + 180;