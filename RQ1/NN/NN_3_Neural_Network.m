% load('D:/Thesis/Data/matlab/NN/trainingsdata_landes_10000_samples_fixed.mat');
load('D:/Thesis/Data/matlab/NN/trainingsdata_landes_500_samples.mat');

inputs = trainings_set(:,5:12);
targets = trainings_set(:,13);

inputs = inputs';
targets = targets';

layersizes = 5:15;
amount_runs = 20;

total_performances = zeros(length(layersizes),amount_runs);
test_performances = zeros(length(layersizes),amount_runs);
mean_per_size = zeros(length(layersizes),1);
opt_net = [];

ct = 0;
tt = length(layersizes)*amount_runs;

for i = 1:length(layersizes)
    for j = 1:amount_runs; 
        % Create a Pattern Recognition Network
        hiddenLayerSize = layersizes(i);  % Amount of neurons per layer, list for more hidden layers
        net = patternnet(hiddenLayerSize);
        
        
        % Set up Division of Data for Training, Validation, Testing
        net.divideParam.trainRatio = 60/100;
        net.divideParam.valRatio = 15/100;
        net.divideParam.testRatio = 25/100;
        net.trainParam.max_fail = 500;
        
        % Train the Network
        [net,tr] = train(net,inputs,targets,'useParallel','no');
        
        % Test the Network
        outputs = net(inputs);
        errors = gsubtract(targets,outputs);
        performance = perform(net,targets,outputs);
        
        % Confusion matrix
        tsOut = outputs(tr.testInd);
        tsTarg = targets(tr.testInd);
        
        [c,cm,ind,per] = confusion(tsTarg,tsOut);
        
        cur_tst_perf = (cm(2,2)/nansum(tsTarg))*100;
        total_performances(i,j) = performance;
        
        if cur_tst_perf > max(test_performances(:))
            opt_net = net;
        elseif (max(test_performances(:)) == 0) && (cur_tst_perf == 0)
            if performance >= max(total_performances(:))
                opt_net = net;
            end
        end
        
        test_performances(i,j) = cur_tst_perf;
        
        
        ct = ct+1;
        disp(['Progress: ' num2str(ct) '/' num2str(tt) ' steps completed (' num2str(ct/tt*100) '%).']);
    end
end

for k = 1:length(layersizes)
    mean_per_size(k) = mean(test_performances(k,:));
end

perf_overview = cat(2,layersizes',test_performances, mean_per_size);


save('Data\matlab\NN\NN_training_performance_500_samples','perf_overview');
save('Data\matlab\NN\NN_opt_net_500s','opt_net');
