load('D:/Thesis/Data/matlab/NN/trainingsdata_landes_10000_samples.mat');

trainings_set(972,13) = 1;
trainings_set(998,13) = 1;
trainings_set(3529,13) = 1;
trainings_set(5649,13) = 1;
trainings_set(6195,13) = 0;
trainings_set(6849,13) = 1;
trainings_set(7392,13) = 1;

save('Data\matlab\NN\trainingsdata_landes_10000_samples_fixed.mat','trainings_set');
