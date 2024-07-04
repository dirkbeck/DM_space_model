% Date: 09/07/2023
% This function analyzes the fit between doublets of FSI, Striosome, and
% PLS neurons

%% fitTypeChoice: PLS vs FSI (1), FSI vs Srio (2), PLS vs Strio (3)

function [fitresult, gof, xnew, ynew, varargout] = plotDynamicsDoublet( ...
    xArray, yArray, bintime, fitTypeChoice, varargin)

% This is for test
% loadFile1 = load('spikesData.mat');
% xArray = loadFile1.MATRIXspikes;
% yArray = loadFile1.FSIspikes;
% bintime = 1.33;
% fitTypeChoice = 1;

all_counts_of_xArray = [];
all_counts_of_yArray = [];

for spike_idx = 1:length(xArray)
    % Get Yarray counts
    [X_N, X_edges] = histcounts(cell2mat(xArray(spike_idx)), floor(40/bintime));
    Y_N = histcounts(cell2mat(yArray(spike_idx)), X_edges);
    all_counts_of_xArray = [all_counts_of_xArray X_N/bintime];
    all_counts_of_yArray = [all_counts_of_yArray Y_N/bintime];
end

% Get all yArray corresponding to unique xArray
[xnew, ynew] = y_mean(all_counts_of_xArray, all_counts_of_yArray);

% Remove data with entries ynew = 0, xnew = 0
dataFilter = xnew == 0 | ynew == 0;
xnew(dataFilter) = []; 
ynew(dataFilter) = [];

% Start Fitting to linear line or sigmoid function, and get rsquare error
try
    switch fitTypeChoice
        case 1 % PLS vs FSI
            fitType = @(a,b,x) a*x+b;
            [fitresult, gof] = fit(xnew, ynew, fitType, 'StartPoint', [1, 0]);
            [R, P] = corrcoef(xnew, ynew);
            varargout{1} = R(1,2);
            varargout{2} = P(1,2);

        case 2 % PLS vs Strio
%             a = varargin{1};
%             b = varargin{2};
%             fitType = @(c, d, g, h, x) c./(1 + exp(d - (g*x+h)./(a*x+b)));
            fitType = @(c, d, x) c*x + d;
            [fitresult, gof] = fit(xnew, ynew, fitType, 'Startpoint', [1, 0]);
            [R, P] = corrcoef(xnew, ynew);
            varargout{1} = R(1,2);
            varargout{2} = P(1,2);
%             varargout = {};

        otherwise
            error('Invalid fitTypeChoice.\n');

    end
catch
    fprintf("Fitting error\n");
end


%% Description of y_mean
    function [xnew, ynew] = y_mean(x,y)
        xnew = [];
        ynew = [];

        uniqx = unique(x);
        for ix = uniqx
            xnew = [xnew; ix];
            ynew = [ynew; mean(y(ix == x))];
        end
    end

end