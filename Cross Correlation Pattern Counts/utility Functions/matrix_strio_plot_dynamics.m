function [fig_handle,goodnessOfFit, significance,slope] =matrix_strio_plot_dynamics(spikes_msnstrio, spikes_msnmatrix, ...
    bintime_strio)
allPossibleGoodnessOfFit = [0 0 0 0 0];
for i=1:5
    all_striosome_counts = [];
    all_msnmatrix_counts = [];
    for spike_idx = 1: length(spikes_msnstrio)
    % Get matrix & striosome counts
        %get the number of spikes in each bin, and the edges of each bin
        %for striosome neurons
        [striosome_N, striosome_edges] =    histcounts(cell2mat(spikes_msnstrio(spike_idx)), i);
        %get the number of spikes in each bin for matrix neurons
        %we use the same number of edges that were found in the striosome
        %histcounts call
        msnmatrix_N =                       histcounts(cell2mat(spikes_msnmatrix(spike_idx)), striosome_edges);
        %store the spike counts in some arrays
        %also divide their value by the striosome bin time
        all_striosome_counts = [all_striosome_counts striosome_N/i];
        all_msnmatrix_counts = [all_msnmatrix_counts msnmatrix_N/i];
    end


    %get the average spike value of the matrix neurons for each value of the
    %striosome neurons
    [xmean_matrix, ynew_matrix] = y_mean(all_striosome_counts, all_msnmatrix_counts);
    

    % Start Fitting to linear line and get rsquare error
    fitType = fittype('a*x+b', 'independent', 'x', 'dependent', 'y');
    opts = fitoptions( 'Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';

    if length(xmean_matrix) < 2 || length(ynew_matrix) < 2
        slope = nan;
        significance = nan; 
        allPossibleGoodnessOfFit(i) =nan; 
    else
        [fitobj_matrix, gof_matrix] = fit(xmean_matrix, ynew_matrix, fitType);

        slope=fitobj_matrix.a;

        %find the significance between x and y
        [~,significance] = corrcoef([xmean_matrix, ynew_matrix]);

        significance = significance(1,2);
        allPossibleGoodnessOfFit(i) = gof_matrix.rsquare;
    end

end
[M,I] = max(allPossibleGoodnessOfFit);
if isnan(I)
    fig_handle = gcf; 
    goodnessOfFit = nan;
    significance = nan;
    slope = nan;
else
    all_striosome_counts = [];
    all_msnmatrix_counts = [];
    for spike_idx = 1: length(spikes_msnstrio)
        % Get matrix & striosome counts
        %get the number of spikes in each bin, and the edges of each bin
        %for striosome neurons
        [striosome_N, striosome_edges] =    histcounts(cell2mat(spikes_msnstrio(spike_idx)), I);
        %get the number of spikes in each bin for matrix neurons
        %we use the same number of edges that were found in the striosome
        %histcounts call
        msnmatrix_N =                       histcounts(cell2mat(spikes_msnmatrix(spike_idx)), striosome_edges);
        %store the spike counts in some arrays
        %also divide their value by the striosome bin time
        all_striosome_counts = [all_striosome_counts striosome_N/I];
        all_msnmatrix_counts = [all_msnmatrix_counts msnmatrix_N/I];
    end


    %get the average spike value of the matrix neurons for each value of the
    %striosome neurons
    [xmean_matrix, ynew_matrix] = y_mean(all_striosome_counts, all_msnmatrix_counts);


    % Start Fitting to linear line and get rsquare error
    fitType = fittype('a*x+b', 'independent', 'x', 'dependent', 'y');
    opts = fitoptions( 'Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';

    [fitobj_matrix, gof_matrix] = fit(xmean_matrix, ynew_matrix, fitType);

    slope=fitobj_matrix.a;

    %find the significance between x and y
    [~,significance] = corrcoef([xmean_matrix, ynew_matrix]);

    significance = significance(1,2);
    allPossibleGoodnessOfFit(i) = gof_matrix.rsquare;

    hold on;
    plot(fitobj_matrix, xmean_matrix, ynew_matrix, 'o');
    ylabel('SWN Firing Rate (Hz) - matrix');
    xlabel('SWN Firing Rate (Hz) - striosome');
    title(sprintf('bin strio=%.2f, bin matrix=%.2f, R^2 Matrix=%.3f, Significance=%.3f', ...
        I, I, gof_matrix.rsquare,significance));
    b = gca; legend(b,'off');
    fig_handle = gcf;

    goodnessOfFit=gof_matrix.rsquare;

end
end