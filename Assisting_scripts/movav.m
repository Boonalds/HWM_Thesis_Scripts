function [out] = movav(in,window,type)

% Moving average for vectors
% [OUT] = MOVAV(IN,WINDOW,TYPE) returns vector OUT with moving average of 
% size WINDOW centered around each point. WINDOW is an uneven number.
% The option TYPE can be:
%   'outer': values are returned with at least one number to calculate
%       mean. OUT is longer than IN. 
%   'inner': only values are returned with WINDOW number of values used 
%       to calculate mean. (the default)

if nargin == 2 || strcmp(type,'inner') == 1
    
    out = NaN*zeros(size(in));

    halfwin = (window - 1)/2;

    for i = 1+halfwin:length(in)-halfwin
        out(i) = mean(in(i-halfwin:i+halfwin));
    end
    
    out(isnan(in)==1) = NaN;
    
elseif strcmp(type,'outer') == 1

    out = NaN*zeros(length(in)+2*(window-1),1);

    for i = 1:length(in)+2*(window-1)
        out(i) = nanmean(in(i:i+window-1));
    end

elseif strcmp(type,'equal') == 1

    out = NaN*zeros(size(in));

    halfwin = (window - 1)/2;

    for i = 1:length(in)
        out(i) = nanmean(in(max(1,i-halfwin):min(i+halfwin,length(in))));
    end

else
    
    out = [];
    disp('No output produced')
    
end