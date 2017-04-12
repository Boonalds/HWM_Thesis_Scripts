function [] = loop_E_Deduct_cloud_formation_times(cl_diff_t)
% Function returns a structure with tables with the timestamps and dates of the additional
% cloud formation for each study area. 
%%% Requires for intput: cl_diff_t, which is the difference 
% in cloud fraction between forest and non-forest that needs to be exceeded
% to have that timestep labeled as additional cloud formation.


%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%
disk = 'D';         % Disk that contains Thesis folder (set as working directory).
rgnnames = {'landes', 'orleans', 'forest1', 'forest2', 'forest3'};
datenames = {'d_landes','d_orleans', 'd_forest1', 'd_forest2', 'd_forest3'};
yrs = [1,5,6,10];
cl = {'5','10','20'};

%%%%%%%%%%%%%%%%%
%%%   CORE    %%%
%%%%%%%%%%%%%%%%%
% Progress tracker
ct = 0;
total_steps = 3*5;    % 3 cloud thresholds, 5 regions

for c = 1:3
    cl_t = cl{c};
    for a = 1:5
        regionname = rgnnames{a};
        for b = 1:2
            yr_idx = yrs(b*2-1):yrs(b*2);

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
            if b == 1
                add_cloud_date_1 = add_cloud_date;
            elseif b == 2
                cloud_form_dates.(datenames{a}) = cat(1, add_cloud_date_1, add_cloud_date);
            end
        end % yrs
        ct = ct+1;
        disp(['Progress: ' num2str(ct) '/' num2str(total_steps) ' steps completed (' num2str(ct/total_steps*100) '%).']);
    end     % regions
    save(['Data\matlab\cloud_formation_times\cloud_form_dates_' num2str(cl_diff_t*100) '_' cl_t], 'cloud_form_dates');
end         % cl_t
