% Script that adds the study areas in a plot.

function [] = add_study_areas_to_plot_f(regionname) 

box_lims                                       % Contains lat and lon limits for plotting areas

switch regionname
    case 'landes'
        % landes study areas
        forest_lat = landeslims.forestbox.latlim;
        forest_lon = landeslims.forestbox.lonlim;
        nonfor1_lat = landeslims.nonforbox1.latlim;
        nonfor1_lon = landeslims.nonforbox1.lonlim;
        nonfor2_lat = landeslims.nonforbox2.latlim;
        nonfor2_lon = landeslims.nonforbox2.lonlim;
    case 'orleans'
        % orleans study areas
        forest_lat = orleanslims.forestbox.latlim;
        forest_lon = orleanslims.forestbox.lonlim;
        nonfor1_lat = orleanslims.nonforbox1.latlim;
        nonfor1_lon = orleanslims.nonforbox1.lonlim;
        nonfor2_lat = orleanslims.nonforbox2.latlim;
        nonfor2_lon = orleanslims.nonforbox2.lonlim;
    case 'forest1'
        % additional smaller forest 1
        forest_lat = forest1lims.forestbox.latlim;
        forest_lon = forest1lims.forestbox.lonlim;
        nonfor1_lat = forest1lims.nonforbox1.latlim;
        nonfor1_lon = forest1lims.nonforbox1.lonlim;
        nonfor2_lat = forest1lims.nonforbox2.latlim;
        nonfor2_lon = forest1lims.nonforbox2.lonlim;
    case 'forest2'
        % additional smaller forest 2
        forest_lat = forest2lims.forestbox.latlim;
        forest_lon = forest2lims.forestbox.lonlim;
        nonfor1_lat = forest2lims.nonforbox1.latlim;
        nonfor1_lon = forest2lims.nonforbox1.lonlim;
        nonfor2_lat = forest2lims.nonforbox2.latlim;
        nonfor2_lon = forest2lims.nonforbox2.lonlim;
    case 'forest3'
        % additional smaller forest 3
        forest_lat = forest3lims.forestbox.latlim;
        forest_lon = forest3lims.forestbox.lonlim;
        nonfor1_lat = forest3lims.nonforbox1.latlim;
        nonfor1_lon = forest3lims.nonforbox1.lonlim;
        nonfor2_lat = forest3lims.nonforbox2.latlim;
        nonfor2_lon = forest3lims.nonforbox2.lonlim;        
    otherwise
        warning('Unknown regionname.')
end

%%%%%%%%%%%%%%%%
%%% Plotting %%%
%%%%%%%%%%%%%%%%

%%% Figure 1 - Surface reflectance 2004-2008
% Setting Axes and Projection

%forestbox:
box1 = linem([max(forest_lat); min(forest_lat);...
    min(forest_lat); max(forest_lat);...
    max(forest_lat)], [min(forest_lon);...
    min(forest_lon); max(forest_lon);...
    max(forest_lon); min(forest_lon)],...
    'Color',[0.2 0.85 0.4], 'LineWidth', 2, 'LineStyle', ':');

% nonforest1:
box2 = linem([max(nonfor1_lat); min(nonfor1_lat);...
    min(nonfor1_lat); max(nonfor1_lat);...
    max(nonfor1_lat)], [min(nonfor1_lon);...
    min(nonfor1_lon); max(nonfor1_lon);...
    max(nonfor1_lon); min(nonfor1_lon)],...
    'Color',[0 0.8 0.8], 'LineWidth', 2);

% nonforest2:
box3 = linem([max(nonfor2_lat); min(nonfor2_lat);...
    min(nonfor2_lat); max(nonfor2_lat);...
    max(nonfor2_lat)], [min(nonfor2_lon);...
    min(nonfor2_lon); max(nonfor2_lon);...
    max(nonfor2_lon); min(nonfor2_lon)],...
    'Color',[0 0.4 0.8], 'LineWidth', 2);

l = legend([box1 box2 box3], 'Forest','Nonforest1', 'Nonforest2', 'Location','southeastoutside');

end
