filename = 'D:\Thesis\Data\matlab\NN\feature_dataset_landes.mat';                      
load(filename);

for i = 1:length(feature_dataset)
    if isnan(feature_dataset(i,8))
        feature_dataset(i,8) = 0;
    end
end

save(['Data\matlab\NN\feature_dataset_' regionname], 'feature_dataset');