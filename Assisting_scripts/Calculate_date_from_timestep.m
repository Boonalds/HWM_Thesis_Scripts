function [year, month, day, hour] = Calculate_date_from_timestep(i)
%%% This function converts timestep i to a date. Outputs are the years,
%%% month, day and hour as a number. Add or remove the years, months, days
%%% or hours to consider below:
years = {'2004';'2005';'2006';'2007';'2008';'2009';'2010';'2011';'2012';'2013'};
months = {'05';'06';'07';'08'};
days = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';...
    '13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';...
    '25';'26';'27';'28';'29';'30';'31'};
hours  = {'0600';'0615';'0630';'0645';'0700';'0715';'0730';'0745';...
    '0800';'0815';'0830';'0845';'0900';'0915';'0930';'0945';...
    '1000';'1015';'1030';'1045';'1100';'1115';'1130';'1145';...
    '1200';'1215';'1230';'1245';'1300';'1315';'1330';'1345';...
    '1400';'1415';'1430';'1445';'1500';'1515';'1530';'1545';...
    '1600';'1615';'1630';'1645';'1700';'1715';'1730';'1745'};

i = i-1;  % To prevent shift of 1 timestep due to modulus computation
hour_i = mod(i, length(hours));
hour = str2num(hours{hour_i+1});
day_t = (i-hour_i)/length(hours);
day = str2num(days{mod(day_t,length(days))+1});
month_t = (day_t-mod(day_t,length(days)))/length(days);
month = str2num(months{mod(month_t, length(months))+1});
year_t = (month_t - mod(month_t,length(months)))/length(months);
year = str2num(years{year_t+1});


end