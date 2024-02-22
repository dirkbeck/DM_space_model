function [goodnessOfFit, significance,slope] =matrix_strio_plot_dynamics_random(spikes_msnstrio, spikes_msnmatrix, ...
    bintime_strio)
    all_striosome_counts = [];
    all_msnmatrix_counts = [];
    for spike_idx = 1: min(length(spikes_msnmatrix),length(spikes_msnstrio))
        % Get matrix & striosome counts
        %get the number of spikes in each bin, and the edges of each bin
        %for striosome neurons
        [striosome_N, striosome_edges] =    histcounts(cell2mat(spikes_msnstrio(spike_idx)), 1);
        %get the number of spikes in each bin for matrix neurons
        %we use the same number of edges that were found in the striosome
        %histcounts call
        msnmatrix_N =                       histcounts(cell2mat(spikes_msnmatrix(spike_idx)), striosome_edges);
        %store the spike counts in some arrays
        %also divide their value by the striosome bin time
        all_striosome_counts = [all_striosome_counts striosome_N/1];
        all_msnmatrix_counts = [all_msnmatrix_counts msnmatrix_N/1];
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
    goodnessOfFit=gof_matrix.rsquare;

end
