function endpoints = ah_find_peakOrValley(trial_spikes, baseline_firing_rate, type)

small_areas = (1 - baseline_firing_rate*diff(trial_spikes))*type;
idxs = ah_maximize_consec_subset_sum(small_areas);
endpoints = idxs + 1;

end