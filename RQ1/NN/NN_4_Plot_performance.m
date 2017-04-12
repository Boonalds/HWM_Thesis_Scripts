load('G:/Thesis/Data/matlab/NN/NN_training_performance_500_samples.mat');
%load('D:/Thesis/Data/matlab/NN/NN_training_performance_10000_samples.mat');

box_data = (perf_overview(:,2:end-1))';

%%%%%%%%%%%%%
datalabels = num2cell(perf_overview(:,1)');
ylimit = [-0.5 20];
xlimit = [0.3 12];
tx = 0.15;   % transpose text positions
ty = 0;
%%%%%%%%%%%%%





close all
figure
boxplot(box_data, 'Labels',datalabels,'OutlierSize',18,'Symbol','k.');

xlabel('Number of Neurons')
ylabel('True Positive Rate [%]')
ylim(ylimit)
xlim(xlimit)

%%% Yellow boxplots:
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),'y','FaceAlpha',.5);
end

%%% Max values in boxplot
for i = 1:size(perf_overview,1)
    xl = i;
    yl = max(perf_overview(i,2:end-1));
    if yl > 10
        text((xl+tx),(yl+ty),num2str(yl,3),'fontsize',10);
    else
        text((xl+tx),(yl+ty),num2str(yl,2),'fontsize',10);
    end
end

%%% Change median thickness
g = findobj(gca,'Tag','Median');
set(g,'linew',2);
set(g,'Color','k');

