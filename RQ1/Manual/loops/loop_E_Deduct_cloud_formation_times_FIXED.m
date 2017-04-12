%%% SCRIPT TO create a lot of additional cloud formation flag tables for
%%% different cl_diff_t
disk = 'D';
cl_t = 27;

% for cl_diff_t=0.20:0.01:0.80
%     disp(['Starting script E for a cl_diff_t value of: ' num2str(cl_diff_t)]);
%     E_Deduct_cloud_formation_times(disk, cl_t, cl_diff_t)
% end




%%% Make a list of the amount of cloud pixels
moments_flagged = zeros(61,1);
i = 1;
for cl_diff_t=0.42:0.01:0.42
cl_diff_t_data_full = load([disk, ':\Thesis\Data\matlab\cloud_formation_times\cloud_form_dates_merged_' num2str(cl_diff_t*100) '_' num2str(cl_t) '.mat']);
cl_diff_t_data = cl_diff_t_data_full.cloud_form_dates_merged.d_landes;

moments_flagged(i,1) = sum(cl_diff_t_data(:,5));
disp(['Step ' num2str(i) '/61 done']);
i = i+1;
end