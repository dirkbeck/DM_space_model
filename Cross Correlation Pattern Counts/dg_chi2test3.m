function [significance, colsNotMrgd, finalCols, colsMrgdA, colsMrgdB] = ...
    dg_chi2test3(N, userules)
%[significance, colsMrgdA, colsMrgdB] = dg_chi2test3(N, userules)
%[significance, colsMrgdA, colsMrgdB] = dg_chi2test3(N)
%  <N> is a 2-D array each row of which is a histogram.  Returns
%  the statistical significance level for concluding that there is a
%  difference between the various rows (i.e. the probability that the 
%  differences from the mean histogram for each bin would be greater than
%  or equal to the given values if the row didn't matter). 
%
%  If <userules> is 1, then the following rules of thumb are applied and
%  cause NaN to be returned if they are violated:
%  (a)  no expected value for a category should be less than 1 (it does not
%  matter what the observed values are)
%  (b)  no more than one-fifth of expected values should be less than 5
%  <userules> defaults to false.
%  Note that NaN is also returned if any of the elements of <N> is NaN.
%
%  If <userules> is 2, then categories (i.e. columns) are automatically
%  merged s.t. the rules are met, or if that is impossible, NaN is
%  returned.  If merge was successful, <colsMrgdA> contains the indices of
%  the original input columns that were merged to satisfy rule (a), and
%  <colsMrgdB> is a 2 column matrix containing the pair of columns of the
%  working array merged at each iteration to satisfy rule (b).  In either
%  case, the newly merged column is placed at the end of the array.
%  <colsNotMrgd> contains the original column indices of any columns in the
%  input <N> that did NOT participate in a merge. <finalCols> is a cell row
%  vector with one one element for each bin; each element contains a row
%  vector of the original column numbers that went into the corresponding
%  bin.
%
%  Also note that this does not reduce to a 1-D chi^2 test if you give it a
%  single column; use dg_chi2test2 for that.
%
% Based on material of The Really Easy Statistics Site (TRESS) at:
% "Chi-squared test for categories of data".
% http://archive.bio.ed.ac.uk/jdeacon/statistics/tress9.html#Chi-squared%20test

%$Rev: 255 $
%$Date: 2016-12-19 16:48:11 -0500 (Mon, 19 Dec 2016) $
%$Author: dgibson $

colsMrgdA = [];
colsMrgdB = [];
colsNotMrgd = 1:size(N,2);  % These get deleted in parallel with cols of N
if any(any(isnan(N)))
    significance = NaN;
    return
end
if nargin < 2
    userules = 0;
end
% Ditto, but merged bin lists are also appended in parallel with N:
finalCols = mat2cell(colsNotMrgd, 1, repmat(1,size(colsNotMrgd)));

% Calculate marginal probabilities & expected values:
Ntot = sum(sum(N));
columnP = sum(N,1)/Ntot;
rowP = sum(N,2)/Ntot;
P = repmat(columnP, size(N,1), 1) .* repmat(rowP, 1, size(N,2));
expected = P * Ntot;

% Check for rules violations:
if userules == 1
    % Exit with NaN if violation:
    if any(any(expected < 1))
        [row col] = find(expected < 1);
        warning('dg_chi2test3:lt1', ...
            'The expected count per bin is less than 1 at [row col] = %s', ...
            mat2str([row col]) );
        significance = NaN;
        return
    elseif sum(sum(expected < 5)) > numel(N)/5
        [row col] = find(expected < 5);
        warning('dg_chi2test3:lt5', ...
            'Too many expected counts < 5 at [row col] = %s', ...
            mat2str([row col]) );
        significance = NaN;
        return
    end
elseif userules == 2
    % Merge columns to satisfy rules. First check rule (a):
    toosmall = expected < 1;
    if any(any(toosmall))
        toosmallcols = any(toosmall);   % row vector
        if all(toosmallcols)
            warning('dg_chi2test3:alltoosmall', ...
                'At least one row contains too few counts in all columns.' );
            significance = NaN;
            return
        end
        % Try merging just the "toosmallcols":
        mergedCol = sum(N(:,toosmallcols),2);   % column vector
        if any((sum(mergedCol,1) * rowP) < 1)
            % still too small, must merge with next larger column:
            bigcolidx = find(~toosmallcols);    % row vector
            if length(bigcolidx) < 2
                warning('dg_chi2test3:alltoosmall2', ...
                    'Only one column contains enough counts, cannot merge.' );
                significance = NaN;
                return
            end
            [C, I] = min(columnP(bigcolidx));
            colsMrgdA = [find(toosmallcols) bigcolidx(I)];  % row vector
            mergedCol = sum(N(:,colsMrgdA),2);
            N(:,colsMrgdA) = [];
            N(:,end+1) = mergedCol;
            colsNotMrgd(colsMrgdA(colsMrgdA<=length(colsNotMrgd))) = [];
        else
            % simply merge the "toosmall" columns:
            N(:,toosmallcols) = [];
            N(:,end+1) = mergedCol;
            colsNotMrgd(toosmallcols(1:length(colsNotMrgd))) = [];
            colsMrgdA = find(toosmallcols); % row vector
        end
        finalCols(colsMrgdA) = [];
        finalCols(end+1) = {colsMrgdA};
    end
    % Re-calculate <expected> and check rule (b):
    columnP = sum(N,1)/Ntot;
    P = repmat(columnP, size(N,1), 1) .* repmat(rowP, 1, size(N,2));
    expected = P * Ntot;
    toosmall = expected < 5;
    % If we have violated rule (b), iteratively merge the two smallest columns
    % until rule (b) is satisfied:
    while sum(sum(toosmall)) > numel(N)/5
        if size(N,2) < 3
            warning('dg_chi2test3:alltoosmall3', ...
                'Too few columns, cannot merge.' );
            significance = NaN;
            return
        end
        [B,IX] = sort(columnP);
        ix = IX(1:2);
        colsMrgdB(end+1,:) = ix;
        mergedCol = sum(N(:,ix), 2);
        N(:,ix) = [];
        N(:,end+1) = mergedCol;
        colsNotMrgd(ix(ix<=length(colsNotMrgd))) = [];
        mergedColNums = {[finalCols{ix(1)} finalCols{ix(2)}]};
        finalCols(ix) = [];
        finalCols(end+1) = mergedColNums;
        % Re-calculate:
        columnP = sum(N,1)/Ntot;
        P = repmat(columnP, size(N,1), 1) .* repmat(rowP, 1, size(N,2));
        expected = P * Ntot;
        toosmall = expected < 5;
    end
end

% TRESS gives a lousy description of Degrees of Freedom; a different angle
% is given at http://davidmlane.com/hyperstat/A42408.html as "the number of
% independent scores that go into the estimate minus the number of
% parameters estimated as intermediate steps".  In our case, the parameters
% are the marginal probabilities <rowP> and <columnP>; since the marginals
% along any given axis must always total to 1, the last one is not
% independent, so the number of independent marginals is the number of rows
% minus one plus the number of columns minus one.  To calculate our
% expected counts we also need one further independent parameter calculated
% from the data, which is the grand total number of observations,
% sum(sum(N)).  So our degrees of freedom are:
df = numel(N) - (size(N,1) + size(N,2) - 2) - 1;

% Calculate the chi^2 estimate:
if df == 1
    % Use Yates correction
    diffs = abs(N - expected) - 0.5;
else
    % No Yates correction
    diffs = N - expected;
end
addends = (diffs .^ 2) ./ expected;
chi2 = sum(sum(addends));
significance = chi2cdf(chi2,df,'upper');
