% function [pval table] = circ_wwtest(varargin)

alpha1 = circzeros_sel;
alpha2 = circones;
alpha = [alpha1; alpha2];
idx = [ones(size(alpha1)); 2*ones(size(alpha2))];
w = ones(size(alpha));

    
% [pval, table] = circ_wwtest(alpha, idx, [w])
% [pval, table] = circ_wwtest(alpha1, alpha2, [w1, w2])
%   Parametric Watson-Williams multi-sample test for equal means. Can be
%   used as a one-way ANOVA test for circular data.
%
%   H0: the s populations have equal means
%   HA: the s populations have unequal means
%
%   Note: 
%   Use with binned data is only advisable if binning is finer than 10 deg.
%   In this case, alpha is assumed to correspond
%   to bin centers.
%
%   The Watson-Williams two-sample test assumes underlying von-Mises
%   distributrions. All groups are assumed to have a common concentration
%   parameter k.
%
%   Input:
%     alpha   angles in radians
%     idx     indicates which population the respective angle in alpha
%             comes from, 1:s
%     [w      number of incidences in case of binned angle data]
%
%   Output:
%     pval    p-value of the Watson-Williams multi-sample test. Discard H0 if
%             pval is small.
%     table   cell array containg the ANOVA table
%
% PHB 3/19/2009
%
% References:
%   Biostatistical Analysis, J. H. Zar
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html


 
% number of groups
u = unique(idx);
s = length(u);

% number of samples
n = sum(w);

% compute relevant quantitites
pn = zeros(s,1); pr = pn;
for t=1:s
  pidx = idx == u(t);
  pn(t) = sum(pidx.*w);
  pr(t) = circ_r(alpha(pidx),w(pidx));
end

r = circ_r(alpha,w);
rw = sum(pn.*pr)/n;

% make sure assumptions are satisfied
n = mean(pn);

  if n > 10 && rw<.45
    warning('Test not applicable. Average resultant vector length < 0.45.') %#ok<WNTAG>
  elseif n > 6 && rw<.5
    warning('Test not applicable. Average number of samples per population < 11 and average resultant vector length < 0.5.') %#ok<WNTAG>
  elseif n >=5 && rw<.55
    warning('Test not applicable. Average number of samples per population < 7 and average resultant vector length < 0.55.') %#ok<WNTAG>
  elseif n < 5
    warning('Test not applicable. Average number of samples per population < 5.') %#ok<WNTAG>
  end

  
% test statistic
kk = circ_kappa(rw);
beta = 1+3/(8*kk);    % correction factor
A = sum(pr.*pn) - r*n;
B = n - sum(pr.*pn);

F = beta * (n-s) * A / (s-1) / B;
pval = 1 - fcdf(F,s-1,n-s);

na = nargout;
if na < 2
  printTable;
end
if na > 1
    table = {'Source','d.f.','SS','MS','F','P-Value'; ...
        'Columns', s-1 , A, A/(s-1), F, pval; ...
        'Residual ', n-s, B, B/(n-s), [], []; ...
        'Total',n-1,A+B,[],[],[]};
end


%   % function printTable
%     
%     fprintf('\nANALYSIS OF VARIANCE TABLE (WATSON-WILLIAMS TEST)\n\n');
%     fprintf('%s\t\t\t\t%s\t%s\t\t%s\t\t%s\t\t\t%s\n', ' ' ,'d.f.', 'SS', 'MS', 'F', 'P-Value');
%     fprintf('--------------------------------------------------------------------\n');
%     fprintf('%s\t\t\t%u\t\t%.2f\t%.2f\t%.2f\t\t%.4f\n', 'Columns', s-1 , A, A/(s-1), F, pval);
%     fprintf('%s\t\t%u\t\t%.2f\t%.2f\n', 'Residual ', n-s, B, B/(n-s));
%     fprintf('--------------------------------------------------------------------\n');
%     fprintf('%s\t\t%u\t\t%.2f', 'Total   ',n-1,A+B);
%     fprintf('\n\n')
% 
%   %end
% 
%   %function prepareOutput
%     
%     if na > 1
%       table = {'Source','d.f.','SS','MS','F','P-Value'; ...
%                'Columns', s-1 , A, A/(s-1), F, pval; ...
%                'Residual ', n-s, B, B/(n-s), [], []; ...
%                'Total',n-1,A+B,[],[],[]};
%     end
%   end
% %end










