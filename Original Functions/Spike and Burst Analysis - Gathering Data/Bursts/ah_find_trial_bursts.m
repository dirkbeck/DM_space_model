function [bursts, indices] = ah_find_trial_bursts(trial_spikes, baseline_firing_rate)
%AH_FIND_TRIAL_BURSTS finds all of the bursts in a given trial. Bursts are
%defined as any collection of spikes such that any two adjacent are no
%more than a certain amount of time apart. In general, this time will be
%the mean interspike-interval from the baseline (equal to the inverse of
%the baseline firing rate). Inputs are the spikes in a given trial (just a
%one-dimensional array of spike times), and the baseline firing rate of the
%given neuron (or whatever value we wish to be the inverse of the maximum
%time between spikes of the same burst.

n_spikes = length(trial_spikes);  %number of spikes being considered
burst_length = 1;           %number of spikes in the burst currently being considered
bursts = [];                %output array. For each burst, we keep start time, end time, and number of spikes
indices = [];

for spike_idx = 2:n_spikes      %start at index 2 (don't need to process first spike; it's automatically part of the first burst)
    if trial_spikes(spike_idx) - trial_spikes(spike_idx - 1) < 1/baseline_firing_rate
        burst_length = burst_length + 1;    %mean inter-spike interval = 1/baseline_firing_rate,
        %if two spikes within mean-ISI distance of each other, we consider
        %them part of the same burst
    else    %otherwise, we process the current burst and move on to the next one
        if burst_length > 1     %if we have a single isolated spike, we skip it
            end_idx = spike_idx - 1;                %index of end of burst
            start_idx = spike_idx - burst_length;   %index of start of burst
            start_time = trial_spikes(start_idx);   %start time of burst
            end_time = trial_spikes(end_idx);       %end time of burst
            bursts(end+1,:) = [start_time, end_time, burst_length]; %add burst to output array
            indices(end+1,:) = [start_idx end_idx];
            burst_length = 1;                       %reset burst length for next spike/burst
        end     %note that we need not deal with isolated spike case; burst_length need not be updated and nothing is being added to output array
    end
end
%If we have a burst ending at the last spike of a trial, we need to process it as well.
if burst_length > 1     %if we have a single isolated spike, we skip it
    end_idx = spike_idx;                        %index of end of burst
    start_idx = spike_idx - burst_length + 1;   %index of start of burst
    start_time = trial_spikes(start_idx);       %start time of burst
    end_time = trial_spikes(end_idx);           %end time of burst
    bursts(end+1,:) = [start_time, end_time, burst_length]; %add burst to output array
    indices(end+1,:) = [start_idx end_idx];
end     %note that we need not deal with isolated spike case; burst_length need not be updated and nothing is being added to output array