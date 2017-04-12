load('G:\Thesis\Data\matlab\NN\trainingsdata_landes_10000_samples_fixed.mat');

%%% Variables to refer to
month_numbers = 5:8;
hour_numbers = 6:17;

% Quarters
k = 1;
quart_numbers = zeros(4*length(hour_numbers),1);
for i = 1:length(hour_numbers)
    for j = 1:4
        quart_numbers(k) = (hour_numbers(i)*100)+((j-1)*15);
        k = k+1;
    end
end

% Create subsets
only_zeros = trainings_set;
only_ones = trainings_set;

only_zeros(only_zeros(:,13) == 1,:) = [];
only_ones(only_ones(:,13) == 0,:) = [];

% Empty datasets
total_months = zeros(length(month_numbers),1);
cloud_months = zeros(length(month_numbers),1);
total_months_perc = zeros(length(month_numbers),1);
cloud_months_perc = zeros(length(month_numbers),1);

%%% Months
for i = 1:4
    % Absolute numbers
    total_months(i) = sum(trainings_set(:,2) == month_numbers(i));
    cloud_months(i) = sum(only_ones(:,2) == month_numbers(i));
    
    % Percentage
    total_months_perc(i) = (total_months(i)/size(trainings_set,1))*100;
    cloud_months_perc(i) = (cloud_months(i)/size(only_ones,1))*100;
end

%%% Hour of day
% Empry datasets
freq_per_hour = cat(2,hour_numbers',zeros(length(hour_numbers),1));
freq_per_quart = cat(2,quart_numbers,zeros(length(quart_numbers),1));

% Round down to whole hours
rounded_per_hour = floor((only_ones(:,4)/100));

% Fill dataset with number of occurances per whole hour
for i = 1:length(hour_numbers)
    freq_per_hour(i,2) = (sum(rounded_per_hour == hour_numbers(i))/size(only_ones,1))*100;
end

for i = 1:length(quart_numbers)
    freq_per_quart(i,2) = (sum(only_ones(:,4) == quart_numbers(i))/size(only_ones,1))*100;
end

% Center scatter dots
freq_per_hour(:,1) = freq_per_hour(:,1)+0.5;

% Plot
c = [0 0 0];
sz = 38;


% Plot for binned hours
close all

scatter(freq_per_hour(:,1),freq_per_hour(:,2),sz,'filled','MarkerFaceColor',c);
ylim([0 ceil(max(freq_per_hour(:,2)))]);
xlim([hour_numbers(1) hour_numbers(end)+1]);

xticknumbers = cat(2, hour_numbers,hour_numbers(end)+1);
set(gca,'XTick',xticknumbers)

xlabel('Time (UTC)');
ylabel('Relative frequency [%]');

% Plot for each quarter
figure

scatter(freq_per_quart(:,1),freq_per_quart(:,2),sz,'filled','MarkerFaceColor',c);
xlabel('Hour');
ylabel('Relative frequency [%]');

