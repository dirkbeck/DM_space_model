function significance = dg_chi2test2(N, userules, varargin)
%significance = dg_chi2test2(N, userules)
%  N is a histogram row vector with equal bin widths for all bins.  Returns
%  the statistical significance level, i.e. the probability that the
%  differences from the mean in counts among the columns would be greater
%  than or equal to the given values if the identity of the bin doesn't
%  matter. If userules is true, then the following rules of thumb are
%  applied and cause NaN to be returned if they are violated:
%  ·	no expected value for a category should be less than 1 (it does not
%  matter what the observed values are)
%  ·	no more than one-fifth of expected values should be less than 5
%  Since all bins are assumed to be of equal width, these two rules reduce
%  to the single rule that the expected value must be at least 5.
%OPTIONS
% 'binwidths', binwidths - allows you to override the assumption that the
%   bin widths are equal.  <binwidths> must have the same number of columns
%   as <N>.
%
% Based on material of The Really Easy Statistics Site (TRESS) at:
% "Chi-squared test for categories of data".
% http://archive.bio.ed.ac.uk/jdeacon/statistics/tress9.html#Chi-squared%20test

%$Rev: 255 $
%$Date: 2016-12-19 16:48:11 -0500 (Mon, 19 Dec 2016) $
%$Author: dgibson $

if any(any(isnan(N)))
    significance = NaN;
    return
end
if nargin < 2
    userules = false;
end
argnum = 0;
binwidths = ones(size(N));
while true
    argnum = argnum + 1;
    if argnum > length(varargin)
        break
    end
    if ~ischar(varargin{argnum})
        continue
    end
    switch varargin{argnum}
        case 'binwidths'
            argnum = argnum + 1;
            binwidths = varargin{argnum};
        otherwise
            error('funcname:badoption', ...
                'The option %s is not recognized.', ...
                dg_thing2str(varargin{argnum}));
    end
end

Ntot = sum(N);
binfracs = binwidths / sum(binwidths);
expected = Ntot * binfracs;
if userules && (any(isnan(expected)) || any(expected < 5))
    warning('dg_chi2test2:lt5', ...
        'The expected count per bin is less than 5.' );
    significance = NaN;
    return
end
df = length(N) - 1;
if df == 1
    % Use Yates correction
    chi2 = sum((abs(N - expected) - 0.5 ).^2 ./ expected);
else
    % No Yates correction
    chi2 = sum((N - expected).^2 ./ expected);
end
significance = chi2cdf(chi2,df,'upper');
