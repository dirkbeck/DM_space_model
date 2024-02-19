function [h, p , stats] = chi2test(n1,N1,n2,N2,n3,N3)
% CHI2TEST performs the chi square test of independence given the counts
% and totals of up to 3 experimental groups. The implementation is copied
% from the internet.
% See: http://www.mathworks.com/matlabcentral/answers/96572-how-can-i-
%      perform-a-chi-square-test-to-determine-how-statistically-
%      different-two-proportions-are-in
%
% Inputs are:
%  n1        - the observed count of the first experimental group
%  N1        - the total count of the first experimental group
%  n2        - the observed count of the second experimental group
%  N2        - the total count of the second experimental group
%  n3        - the observed count of the third experimental group
%  N3        - the total count of the third experimental group
%
% Ouputs are: 
%  h         - the result, acceptance or rejectance of the null hypothesis
%  p         - the associated p value
%  stats     - extra stats provided by MATLAB chi2gof function
    
    % Pooled estimate of proportion
    p0 = (n1+n2+n3) / (N1+N2+N3);
    % Expected counts under H0 (null hypothesis)
    n10 = N1 * p0;
    n20 = N2 * p0;
    n30 = N3 * p0;
    % Chi-square test, by hand
    observed = [n1 N1-n1 n2 N2-n2 n3 N3-n3];
    expected = [n10 N1-n10 n20 N2-n20 n30 N3-n30];
    [h,p,stats] = chi2gof([1 2 3 4 5 6],'freq',observed,'expected',expected,'ctrs',[1 2 3 4 5 6],'nparams',3);
        
    if n3 == 0 && N3 == 0
        % Pooled estimate of proportion
        p0 = (n1+n2) / (N1+N2);
        % Expected counts under H0 (null hypothesis)
        n10 = N1 * p0;
        n20 = N2 * p0;
        % Chi-square test, by hand
        observed = [n1 N1-n1 n2 N2-n2];
        expected = [n10 N1-n10 n20 N2-n20];
        [h,p,stats] = chi2gof([1 2 3 4],'freq',observed,'expected',expected,'ctrs',[1 2 3 4],'nparams',2);
    end
end