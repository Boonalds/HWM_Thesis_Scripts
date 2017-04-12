function s = fullsummary(x, dim, stdflag)
% WARNING: This function requires the STATISTICS TOOLBOX.
% 
% FULLSUMMARY calculates the min, median, mean, max, lower and upper
% quartiles, standard deviation, and frequencies of each element of a
% vector, matrix or N-D array.  
% 
% FULLSUMMARY(X) returns a structure, with the following fields:
% 
% MIN - For vectors, this is the minimum value of the elements in X.  For 
% matrices, this is a row vector containing the minimum value of each 
% column.  For N-D arrays, this is the minimum value of the elements along 
% the first non-singleton dimension of X.  See the function min for further
% information.
% 
% LOWERQUARTILE - For vectors, this is the lower quartile (25th percentile)
% value of the elements in X.  For matrices, this is a row vector
% containing the lower quartile value of each column.  For N-D arrays, this
% is the lower quartile value of the elements along the first non-singleton
% dimension of X.  See the function prctile for further information.
% 
% MEDIAN - For vectors, this is the median value of the elements in X.  For 
% matrices, this is a row vector containing the median value of each 
% column.  For N-D arrays, this is the median value of the elements along 
% the first non-singleton dimension of X.  See the function median for further
% information.
% 
% MEAN - For vectors, this is the mean value of the elements in X.  For 
% matrices, this is a row vector containing the mean value of each 
% column.  For N-D arrays, this is the mean value of the elements along 
% the first non-singleton dimension of X.  See the function mean for further
% information.
% 
% UPPERQUARTILE - For vectors, this is the upper quartile (25th percentile)
% value of the elements in X.  For matrices, this is a row vector
% containing the upper quartile value of each column.  For N-D arrays, this
% is the upper quartile value of the elements along the first non-singleton
% dimension of X.  See the function prctile for further information.
% 
% MAX - For vectors, this is the maximum value of the elements in X.  For 
% matrices, this is a row vector containing the maximum value of each 
% column.  For N-D arrays, this is the maximum value of the elements along 
% the first non-singleton dimension of X.  See the function max for further
% information.
% 
% STD - For vectors, this is the standard deviation of the elements in X.  For 
% matrices, this is a row vector containing the standard deviation of each 
% column.  For N-D arrays, this is the standard deviation of the elements along 
% the first non-singleton dimension of X.  See the function std for further
% information.
% 
% SIZE -  For vectors, matrices and N-D arrays, this is a vector of the
% sizes of each dimension of X. If X is a scalar, which MATLAB regards as a
% 1-by-1 array, SIZE(X) returns the vector [1 1].
% 
% TABLE - For vectors, matrices and N-D arrays this, is a matrix with 3
% columns.  Matrices and N-D arrays are first reshaped to become a column
% vector.  The first column contains the uniques values of X.  The second
% column contains the number of occurences of the value in the first
% column.  The third column contains the percentage of occurences of the
% value in the first column.  See the function tabulate for further
% information.
% 
% 
% FULLSUMMARY(X, DIM) calculates summary statistics along the dimension DIM
% of X.  A value of 0 for DIM uses the first nonsingleton dimension.  DIM
% does not affect the TABLE field of the returned structure.
% 
% 
% FULLSUMMARY(X, DIM, STDFLAG) calculates summary statistics using a
% normalisation factor for standard deviation determined by STDFLAG. If
% STDFLAG is 0 (default), then the normalisation factor is n-1; if STDFLAG
% is 1, then the normalisation factor is n.  See the function std for
% further information.
% 
% 
% NOTE: Class type checking and error handling are conducted within the
% individual summary statistic calculation functions.
%
% 
% EXAMPLE: If X = [1 2 3; 1 3 5], then FULLSUMMARY(X) returns
%               min: [1 2 3]
%     lowerquartile: [1 2 3]
%            median: [1 2.5000 4]
%              mean: [1 2.5000 4]
%     upperquartile: [1 3 5]
%               max: [1 3 5]
%               std: [0 0.7071 1.4142]
%             table: [5x3 double]
% 
% where the table field has value
%             1.0000    2.0000   33.3333
%             2.0000    1.0000   16.6667
%             3.0000    2.0000   33.3333
%             4.0000         0         0
%             5.0000    1.0000   16.6667
% 
% 
%   Class support for input X:
%      float: double, single
% 
% 
%   See also MIN, MEDIAN, MEAN, MAX, STD, SIZE, PRCTILE, TABULATE.
% 
% $ Author: Richie Cotton $     $ Date: 2006/03/16 $


% If the dimension was not specified, find the first nonsingleton
% dimension.
if nargin == 1 || dim == 0
    dim = find(size(x)~=1,1);
        if isempty(dim)
        dim = 1;
    end
end

% If no flag was specified for standard deviation, default to 0.
if nargin < 3
   stdflag = 0; 
end

% Calculate summary statistics.    
% If the stats toolbox isn't there, just use summary
if license('test', 'statistics_toolbox')
    s.min = min(x, [], dim);
    s.lowerquartile = prctile(x, 25, dim);
    s.median = median(x, dim);
    s.mean = mean(x, dim);
    s.upperquartile = prctile(x, 75, dim);
    s.max = max(x, [], dim);
    s.std = std(x, stdflag, dim);
    s.size = size(x);
    s.table = tabulate(reshape(x, numel(x),1));
else
    warning('MATLAB:noStatsToolbox', 'Statistics toolbox not present.  Not all fields returned.')
    s = summary(x, dim, stdflag);
end