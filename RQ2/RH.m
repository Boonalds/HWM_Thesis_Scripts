%%% Calculate relative humidity and add to weather_vars
disk = 'D';         % Disk that contains Thesis folder (set as working directory).
load([disk, ':\Thesis\Data\matlab\results\Weather_variables_table_trainings_set_10000.mat']);

%%% Prepare data
cloud_vars_raw = cloud_vars;
cloud_vars_raw(1,:) = [];
cloud_vars_raw(:,1) = [];
cloud_vars_raw = cell2mat(cloud_vars_raw);
RH = zeros(size(cloud_vars_raw,1)+1,1);

%%% August-Roche-Magnus approximation

% Set constants
a = 17.625;
b = 243.04;

% Loop through dataset
for i = 2:size(cloud_vars_raw,1)
    T = cloud_vars_raw(i,3)-272.15;
    Td = cloud_vars_raw(i,4)-272.15;
    RH(i) = 100 * (exp((a*Td)/(b+Td))/exp((a*T)/(b+T)));
end

