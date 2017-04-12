% function [] = E_Deduct_cloud_formation_times(disk, cl_t, cl_diff_t)

disk = 'D';
cl_t = '27';

cl_diff = '47';
% disp('Script E started running.');
% Function returns a structure with tables with the timestamps and dates of
% all the images. Behind the date there is a 1 or 0, depicting whether or
% not there is additional cloud formation.

%%% Requires for intput: cl_diff_t, which is the difference
% in cloud fraction between forest and non-forest that needs to be exceeded
% to have that timestep labeled as additional cloud formation.


%%%%%%%%%%%%%%%%%
%%%   Input   %%%
%%%%%%%%%%%%%%%%%
check_exist = 0;
rgnnames = {'landes', 'orleans', 'forest1', 'forest2', 'forest3'};
datenames = {'d_landes','d_orleans', 'd_forest1', 'd_forest2', 'd_forest3'};
years = {'2004';'2005';'2006';'2007';'2008';'2009';'2010';'2011';'2012';'2013'};
yrs = [1,5,6,10];

warning('off', 'MATLAB:warn_r14_stucture_assignment');

%%%%%%%%%%%%% CHECK EXISTENCE %%%%%%%%%%%
if check_exist == 1
    
    checkfile = [disk ':\Thesis\Data\matlab\cloud_formation_times\cloud_form_dates_merged_' num2str(cl_diff_t*100) '_' num2str(cl_t) '.mat'];
    if exist(checkfile, 'file') == 2
        quitvar = 1;
        disp('Script E - Additional cloud formation times already deducted.');
        disp('Skipping this script...')
    else
        quitvar = 2;
    end
else
    quitvar = 2;
end

if quitvar == 2
    
    %%%%%%%%%%%%%%%%%
    %%%   CORE    %%%
    %%%%%%%%%%%%%%%%%
    
    % Progress tracker
    ct = 0;
    tt = 5*2;    % 5 regions, 2 timeperiods
    
    
    for a = 1:1
        regionname = rgnnames{a};
        for b = 1:2
            yr_idx = yrs(b*2-1):yrs(b*2);
            
            
            % Load reflectance data for refl extraction
            forest_filename = [disk, ':\Thesis\Data\matlab\cloud_data\' regionname '\cloud_data_forest_' regionname '_' years{yr_idx(1)} '_' years{yr_idx(end)} '_' num2str(cl_t) '.mat'];
            nonfor1_filename = [disk, ':\Thesis\Data\matlab\cloud_data\' regionname '\cloud_data_nonfor1_' regionname '_' years{yr_idx(1)} '_' years{yr_idx(end)} '_' num2str(cl_t) '.mat'];
            nonfor2_filename = [disk, ':\Thesis\Data\matlab\cloud_data\' regionname '\cloud_data_nonfor2_' regionname '_' years{yr_idx(1)} '_' years{yr_idx(end)} '_' num2str(cl_t) '.mat'];
            
            forest_clouddata = load(forest_filename);
            nonfor1_clouddata = load(nonfor1_filename);
            nonfor2_clouddata = load(nonfor2_filename);
            
            
            %%% Calculate area of study areas, so the results can be normalized. Also
            %%% the total number of timesteps stored in the dataset is calculated.
            area_f = length(forest_clouddata.cloud_data_forest(:,1,1))*length(forest_clouddata.cloud_data_forest(1,:,1));
            area_nf1 = length(nonfor1_clouddata.cloud_data_nonfor1(:,1,1))*length(nonfor1_clouddata.cloud_data_nonfor1(:,1,1));
            area_nf2 = length(nonfor2_clouddata.cloud_data_nonfor2(:,1,1))*length(nonfor2_clouddata.cloud_data_nonfor2(:,1,1));
            tot_s = length(forest_clouddata.cloud_data_forest(1,1,:));
            
            %%% Extract data
            % Create empty datasets
            pxls_forest = [];
            pxls_nonfor1 = [];
            pxls_nonfor2 = [];
            
            add_cloud_date = [];
            add_cloud_flag = zeros(tot_s,1);
            
            for i = 1:tot_s
                % forest
                pxl_f = double(forest_clouddata.cloud_data_forest(:,:,i));
                pxls_forest = sum(pxl_f(:) == 1)/area_f;
                
                % nonforest1
                pxl_nf1 = double(nonfor1_clouddata.cloud_data_nonfor1(:,:,i));
                pxls_nonfor1 = sum(pxl_nf1(:) == 1)/area_nf1;
                % nonforest2
                pxl_nf2 = double(nonfor2_clouddata.cloud_data_nonfor2(:,:,i));
                pxls_nonfor2 = sum(pxl_nf2(:) == 1)/area_nf2;
                
                %%% CL_DIFF_PART - first selection
                if (pxls_forest - pxls_nonfor1) >= cl_diff_t && (pxls_forest - pxls_nonfor2) >= cl_diff_t;
                    %%% CLUSTER ANALYSIS - second selection
                    
                
                    
                % Calculating date from timestep
                [year, month, day, hour] = Calculate_date_from_timestep(i, yr_idx);
                add_cloud_date = [add_cloud_date; year month day hour];         % Store timestamps and dates in one matrix
                % Determine if timestep contains more cloudpixels above forests than nonforest
                
                    add_cloud_flag(i,1) = 1;
                else
                    add_cloud_flag(i,1) = 0;
                end
            end
            cloud_form_dates_m = cat(2, add_cloud_date, add_cloud_flag);
            if b == 1
                cloud_form_dates_m_1 = cloud_form_dates_m;
            elseif b == 2
                cloud_form_dates_merged.(datenames{a}) = cat(1, cloud_form_dates_m_1, cloud_form_dates_m);
            end
            ct = ct+1;
            disp(['Script E - Progress: ' num2str(ct) '/' num2str(tt) ' steps completed (' num2str(ct/tt*100) '%).']);
            
        end % yrs
    end     % regions
    
    
    %%%%%%%%%%%%%%% CLUSTER ANALYSIS %%%%%%%%%%%%%%%
    
    
    for a = 1:1;
    cloud_form_dates_merged.(datenames{a});
    
    
    end
    
    save(['Data\matlab\cloud_formation_times\cloud_form_dates_merged_' num2str(cl_diff_t*100) '_' num2str(cl_t)], 'cloud_form_dates_merged');
end
%disp('Script E finished running.');
end


