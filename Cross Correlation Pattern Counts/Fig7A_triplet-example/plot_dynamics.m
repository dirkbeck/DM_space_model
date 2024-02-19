function plot_dynamics(spikes_swn, spikes_msnstrio, spikes_msnmatrix, ...
    bintime_strio, bintime_matrix)

all_swnstrio_counts = [];
all_swnmatrix_counts = [];
all_msnstrio_counts = [];
all_msnmatrix_counts = [];
for spike_idx = 1: length(spikes_swn)
    % Get strio counts
    [swnstrio_N, swnstrio_edges] = ...
        histcounts(cell2mat(spikes_swn(spike_idx)), floor(40/bintime_strio));
    display(strcat("About to print ",))
    msnstrio_N = histcounts(cell2mat(spikes_msnstrio(spike_idx)), swnstrio_edges);
    all_swnstrio_counts = [all_swnstrio_counts swnstrio_N/bintime_strio];
    all_msnstrio_counts = [all_msnstrio_counts msnstrio_N/bintime_strio];
    
    % Get matrix counts
    [swnmatrix_N, swnmatrix_edges] = ...
        histcounts(cell2mat(spikes_swn(spike_idx)), floor(40/bintime_matrix));
    msnmatrix_N = histcounts(cell2mat(spikes_msnmatrix(spike_idx)), swnmatrix_edges);
    all_swnmatrix_counts = [all_swnmatrix_counts swnmatrix_N/bintime_matrix];
    all_msnmatrix_counts = [all_msnmatrix_counts msnmatrix_N/bintime_matrix];
end

[xmean_strio, ynew_strio] = y_mean(all_swnstrio_counts, all_msnstrio_counts);
[xmean_matrix, ynew_matrix] = y_mean(all_swnmatrix_counts, all_msnmatrix_counts);

% Start Fitting to linear line or sigmoid function, and get rsquare error
fitType = fittype('a+(b-a)/(1+exp(c-d*x))', 'independent', 'x', 'dependent', 'y');
opts = fitoptions( 'Method', 'NonlinearLeastSquares');
opts.StartPoint = [1 0 5 2];
opts.Display = 'Off';

[fitobj_strio, gof_strio] = fit(xmean_strio, ynew_strio, fitType, opts);
[fitobj_matrix, gof_matrix] = fit(xmean_matrix, ynew_matrix, fitType, opts);

hold on;
yyaxis left;
plot(fitobj_strio, xmean_strio, ynew_strio, '*');
ylabel('SWN Firing Rate (Hz) - strio');
yyaxis right;
plot(fitobj_matrix, xmean_matrix, ynew_matrix, 'o');
ylabel('SWN Firing Rate (Hz) - matrix');
xlabel('SWN Firing Rate in Hz');
title(sprintf('bin strio=%.2f, bin matrix=%.2f, R^2 strio=%.3f, R^2 matrix=%.3f', ...
    bintime_strio, bintime_matrix, gof_strio.rsquare, gof_matrix.rsquare));
b = gca; legend(b,'off');
end