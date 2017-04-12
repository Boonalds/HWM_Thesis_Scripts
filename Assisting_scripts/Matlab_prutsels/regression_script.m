

%%% Regression
lmvr = 0;  % logistical multivariate regression

if lmvr == 1
    % Select randomly the same amount of no-cloud moments as there are
    % cloud-moments
    max_r = size(only_zeros,1);
    n = size(only_ones,1);
    p = randperm(max_r,n);
    only_zeros_sel = only_zeros(p,:);
    clear only_zeros
    
    % Paste the subset together
    cloud_vars_subset = cat(1, only_ones, only_zeros_sel);
    
    
    %%% Create prediction dataset (X)
    pred = cloud_vars_subset(:,11);
    %pred = cat(2, cloud_vars_subset(:,5),cloud_vars_subset(:,11));
    %predc = cloud_vars(2:end,12)));
    
    %%% Create response dataset (Y)
    resp = categorical(cloud_vars_subset(:,2)+1);
    
    %%% Logistical regression
    [B, dev, stats] = mnrfit(pred, resp);
    
    
end

%%% Circular
%[alpha, x] = circ_corrcl(predc, resp);