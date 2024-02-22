function ah_burst_trial_average_plotter(twdb, neuron_ids, evt_cols, evt_locs, thresholds, numBins, smoothing_coeff, colorFunct)

figure; hold all;

numRows = length(neuron_ids);


for i = 1:numRows
    idx = str2num(neuron_ids{i});
    bins = ah_fill_burst_plotting_bins(twdb(idx).trial_bursts, {twdb(idx).trial_evt_timings}, ...
        [1 100 twdb(idx).baseline_firing_rate_data], {}, {}, [numBins evt_cols evt_locs 0], [0 0], thresholds);
    
    bins = smooth(bins(:,1), smoothing_coeff);

    
    for bin = 1:length(bins) 
        hold on; patch([bin bin bin-1 bin-1], [i-1 i i i-1], colorFunct(bins(bin)), 'EdgeColor', 'none');
    end
end

end