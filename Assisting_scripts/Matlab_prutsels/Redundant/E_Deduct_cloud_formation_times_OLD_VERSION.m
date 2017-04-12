function [] = E_Deduct_cloud_formation_times(regionname, cl_t, yr_idx)
% Function returns a table with the timestamps and dates of the additional
% cloud formation. Requires for intput: regionname, cl_t ('5', '10' or
% '20') and yr_idx (1:5 or 6:10)


%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%
cl_diff_t = 0.6;    % Difference in cloud fraction between forest and non-forest that needs to be exceeded ..
% .. to have that timestep labeled as additional cloud formation

disk = 'D';         % Disk that contains Thesis folder (set as working directory).


%%%%%%%%%%%%%%%%%
%%%  Loading  %%%
%%%%%%%%%%%%%%%%%

% Load reflectance data for refl extraction

if yr_idx(1) >= 1 && yr_idx(end) <= 5
    forest_filename = [disk, ':\Thesis\Data\matlab\cloud_data\' regionname '\cloud_data_forest_' regionname '_2004_2008_', cl_t, '.mat'];
    nonfor1_filename = [disk, ':\Thesis\Data\matlab\cloud_data\' regionname '\cloud_data_nonfor1_' regionname '_2004_2008_', cl_t, '.mat'];
    nonfor2_filename = [disk, ':\Thesis\Data\matlab\cloud_data\' regionname '\cloud_data_nonfor2_' regionname '_2004_2008_', cl_t, '.mat'];
elseif yr_idx(1) >= 6 && yr_idx(end) <= 10
    forest_filename = [disk, ':\Thesis\Data\matlab\cloud_data\' regionname '\cloud_data_forest_' regionname '_2009_2013_', cl_t, '.mat'];
    nonfor1_filename = [disk, ':\Thesis\Data\matlab\cloud_data\' regionname '\cloud_data_nonfor1_' regionname '_2009_2013_', cl_t, '.mat'];
    nonfor2_filename = [disk, ':\Thesis\Data\matlab\cloud_data\' regionname '\cloud_data_nonfor2_' regionname '_2009_2013_', cl_t, '.mat'];
else
    warning('Invalid range of years, must be between or equal to 1:5 or 6:10.')
end


forest_clouddata = load(forest_filename);
nonfor1_clouddata = load(nonfor1_filename);
nonfor2_clouddata = load(nonfor2_filename);

%%%%%%%%%%%%%%%%%%%%%
%%% CORE - PART 1 %%%
%%%%%%%%%%%%%%%%%%%%%

%%% Calculate area of study areas, so the results can be normalized. Also
%%% the total number of timesteps stored in the dataset is calculated.
area_f = length(forest_clouddata.cloud_data_forest(:,1,1))*length(forest_clouddata.cloud_data_forest(1,:,1));
area_nf1 = length(nonfor1_clouddata.cloud_data_nonfor1(:,1,1))*length(nonfor1_clouddata.cloud_data_nonfor1(:,1,1));
area_nf2 = length(nonfor2_clouddata.cloud_data_nonfor2(:,1,1))*length(nonfor2_clouddata.cloud_data_nonfor2(:,1,1));
tt = length(forest_clouddata.cloud_data_forest(1,1,:));

%%% Extract data
% Create empty datasets
pxls_forest = [];
pxls_nonfor1 = [];
pxls_nonfor2 = [];
add_cloud_date = [];

t = [];
for i = 1:tt
    % forest
    pxl = double(forest_clouddata.cloud_data_forest(:,:,i));
    pxls_forest(i) = sum(pxl(:) == 1)/area_f;
    % nonforest1
    pxl = double(nonfor1_clouddata.cloud_data_nonfor1(:,:,i));
    pxls_nonfor1(i) = sum(pxl(:) == 1)/area_nf1;
    % nonforest2
    pxl = double(nonfor2_clouddata.cloud_data_nonfor2(:,:,i));
    pxls_nonfor2(i) = sum(pxl(:) == 1)/area_nf2;
    
    % Determine if timestep contains more cloudpixels above forests than
    % nonforest
    if (pxls_forest(i) - pxls_nonfor1(i)) >= cl_diff_t ...
            && (pxls_forest(i) - pxls_nonfor2(i)) >= cl_diff_t;
        t = t+1;
        [year, month, day, hour] = Calculate_date_from_timestep(i, yr_idx); % Calculating date from timestep
        add_cloud_date = [add_cloud_date; t i year month day hour];         % Store timestamps and dates in one matrix
    end
end

save(['Data\matlab\cloud_formation_times\' regionname '_' years{yr_idx(1)} '_' ...
    years{yr_idx(end)} '_' num2str(cl_t)],'add_cloud_date');

end