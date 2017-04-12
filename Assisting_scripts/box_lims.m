%%%%% EUROPE %%%%%
europelims.regionbox.latlim = [42 51];
europelims.regionbox.lonlim = [-5 8.5];

%%%%% LANDES %%%%%
landeslims.regionbox.latlim = [43.45 45.2];     % Region
landeslims.regionbox.lonlim = [-1.7 .8];
landeslims.forestbox.latlim = [44 44.4];        % Forest
landeslims.forestbox.lonlim = [-.6 0];
landeslims.nonforbox1.latlim = [43.5 43.9];     % Nonfor1
landeslims.nonforbox1.lonlim = [-.3 .3];
landeslims.nonforbox2.latlim = [44.6 45];       % Nonfor2
landeslims.nonforbox2.lonlim = [-.7 -.1];
% 
% %%%%% ORLEANS %%%%%
% orleanslims.regionbox.latlim = [46.625 48.375]; % Region
% orleanslims.regionbox.lonlim = [.75 3.25];
% orleanslims.forestbox.latlim = [47.3 47.7];     % Forest
% orleanslims.forestbox.lonlim = [1.7 2.3];
% orleanslims.nonforbox1.latlim = [47.3 47.7];    % Nonfor1
% orleanslims.nonforbox1.lonlim = [2.4 3];
% orleanslims.nonforbox2.latlim = [47.1 47.5];    % Nonfor2
% orleanslims.nonforbox2.lonlim = [0.9 1.5];

%%%%% ADDITIONAL FORESTS %%%%%
regionDist = 0.1;       % Buffer area around the three study areas in degrees.

%%% Forest 1
% forest1lims.forestbox.latlim = [48.3 48.55];
% forest1lims.forestbox.lonlim = [2.5 2.9];
% forest1lims.nonforbox1.latlim = [48.35 48.60];
% forest1lims.nonforbox1.lonlim = [3.1 3.5];
% forest1lims.nonforbox2.latlim = [48.05 48.30];
% forest1lims.nonforbox2.lonlim = [2.3 2.7];
% 
% lat_cat = cat(2, forest1lims.forestbox.latlim, forest1lims.nonforbox1.latlim, forest1lims.nonforbox2.latlim);
% lon_cat = cat(2, forest1lims.forestbox.lonlim, forest1lims.nonforbox1.lonlim, forest1lims.nonforbox2.lonlim);
% forest1lims.regionbox.latlim = [min(lat_cat)-regionDist max(lat_cat)+regionDist];
% forest1lims.regionbox.lonlim = [min(lon_cat)-regionDist max(lon_cat)+regionDist];
% 
% %%% Forest 2
% forest2lims.forestbox.latlim = [46.7 46.9];
% forest2lims.forestbox.lonlim = [1.20 1.50];
% forest2lims.nonforbox1.latlim = [46.5 46.7];
% forest2lims.nonforbox1.lonlim = [0.75 1.05];
% forest2lims.nonforbox2.latlim = [46.85 47.05];
% forest2lims.nonforbox2.lonlim = [1.60 1.90];
% 
% lat_cat = cat(2, forest2lims.forestbox.latlim, forest2lims.nonforbox1.latlim, forest2lims.nonforbox2.latlim);
% lon_cat = cat(2, forest2lims.forestbox.lonlim, forest2lims.nonforbox1.lonlim, forest2lims.nonforbox2.lonlim);
% forest2lims.regionbox.latlim = [min(lat_cat)-regionDist max(lat_cat)+regionDist];
% forest2lims.regionbox.lonlim = [min(lon_cat)-regionDist max(lon_cat)+regionDist];
% 
% %%% Forest 3
% forest3lims.forestbox.latlim = [46.1 46.2];
% forest3lims.forestbox.lonlim = [-0.44 -0.34];
% forest3lims.nonforbox1.latlim = [45.95 46.05];
% forest3lims.nonforbox1.lonlim = [-0.37 -0.27];
% forest3lims.nonforbox2.latlim = [46.22 46.32];
% forest3lims.nonforbox2.lonlim = [-0.32 -0.22];
% 
% lat_cat = cat(2, forest3lims.forestbox.latlim, forest3lims.nonforbox1.latlim, forest3lims.nonforbox2.latlim);
% lon_cat = cat(2, forest3lims.forestbox.lonlim, forest3lims.nonforbox1.lonlim, forest3lims.nonforbox2.lonlim);
% forest3lims.regionbox.latlim = [min(lat_cat)-regionDist max(lat_cat)+regionDist];
% forest3lims.regionbox.lonlim = [min(lon_cat)-regionDist max(lon_cat)+regionDist];
% 
% %%% MISC
% landeslims.forestboxklaus.latlim = [43.85 44.25];
% landeslims.forestboxklaus.lonlim = [-1 -.4];

% landeslims.forestbox.lonlim = [-.9 -.3];
% landeslims.nonforbox3.latlim = [44.4 44.8];
% landeslims.nonforbox3.lonlim = [.1 .7];

% orleanslims.nonforbox1.latlim = [46.9 47.3];
% orleanslims.nonforbox1.lonlim = [2.4 3];
% orleanslims.nonforbox2.latlim = [46.8 47.2];
% orleanslims.nonforbox2.lonlim = [1.4 2];
% orleanslims.nonforbox3.latlim = [47.9 48.3];
% orleanslims.nonforbox3.lonlim = [1.3 1.9];

% veluwelims.forestbox.latlim = [52 52.4];
% veluwelims.forestbox.lonlim = [5.6 6];
% veluwelims.nonforbox1.latlim = [52 52.4];
% veluwelims.nonforbox1.lonlim = [6.1 6.5];
% veluwelims.nonforbox2.latlim = [43.3 43.7];
% veluwelims.nonforbox2.lonlim = [-.9 -.3];