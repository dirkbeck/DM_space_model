function cdf = histcdf(values, bins)
% HISTCDF converts a set of values into a CDF evaluated at the set of
% points indicates by bins.
%
% Inputs are: 
%  VALUES  - the values of the distribution
%  BINS    - the points at which to calculate the CDF of the distribution
% Outputs are:
%  CDF     - the cdf of values evaluated at bins

    cdf = histcounts(values, bins, 'Normalization', 'cdf');
    if isnan(cdf)
        cdf = zeros(1,length(bins)-1);
    end
end