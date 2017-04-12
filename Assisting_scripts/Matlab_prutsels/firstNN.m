load('D:/Thesis/Data/matlab/NN/trainingsdata_landes_500_samples.mat');

inputs = trainings_set(:,5:12);
targets = trainings_set(:,13);

inputs = inputs';
targets = targets';


% Create a Pattern Recognition Network
hiddenLayerSize = [10, 8];
net = patternnet(hiddenLayerSize);


% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;
net.trainParam.max_fail = 1000;

% Train the Network
[net,tr] = train(net,inputs,targets,'useParallel','no');

% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs);

% 
% % View the Network
view(net)
% 
% % Plots
% % Uncomment these lines to enable various plots.
% figure, plotperform(tr)
% figure, plottrainstate(tr)
% figure, plotconfusion(targets,outputs)
% figure, ploterrhist(errors)