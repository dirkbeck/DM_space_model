function firing_rate = baseline_firing_rate(twdb, neuron_id)
% BASELINE_FIRING_RATE finds the baseline firing rate of the neuron in twdb
% with index neuron_id.
%
% Inputs are:
%  TWDB        - the database of neurons
%  NEURON_ID   - the index of the neuron in twdb
%
% Outputs are:
%  FIRING_RATE - the baseline firing rate of the (neuron_id)th neuron in
%              twdb

    neuron_id = {num2str(neuron_id)};
    [~, ~, ~, spikes_array, ~, ses_evt_timings, neuronidsAndData] = ah_extractDataFromTWDB(twdb, neuron_id);
    [bins, ~, ~, ~] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0]);
    bins = bins(:,1);
    firing_rate = mean(bins(60:240));
end