function [bursts_array, baseline_mean_firing_rate, baseline_std_firing_rate, burst_spikes] = ah_build_bursts_array(spikes, events, response_event, baseline_event, window, baseline_width)
%AH_BUILD_BURSTS_ARRAY builds a cell array with an entry for each trial
%containing every burst in that trial of the given neuron and its
%respective number of spikes. Also outputs a pair of parameters based on
%baseline bursts - mean and standard deviation firing rate of baseline
%bursts in the same neuron. These parameters should be used for
%significance checking as well as general thresholding, as needed.
%Inputs are:
% SPIKES - sorted array of times of every spike recorded at the given
%   neuron in the given session.
% EVENTS - sorted two column array of every event occuring in the session
%   and its timing
% RESPONSE_EVENT - the event we are aligning about
% BASELINE_EVENT - the event marking the end of the baseline in each trial
% WINDOW - the window about the response event in which we search for
%   bursts
% BASELINE_WIDTH - the size of the baseline we are using, measuring back
%   from the end of baseline event

main_spikes_array = ah_build_spikes_array(spikes, events, response_event, window, baseline_event);
%build spikes array for window we are looking at
baseline_spikes_array = ah_build_spikes_array(spikes, events, baseline_event, [-baseline_width 0], baseline_event);
%build spikes array for baseline

num_trials = length(baseline_spikes_array);     %number of trials in neuron
bursts_array = cell(num_trials, 1);             %output array of bursts
burst_spikes = cell(num_trials, 1);
num_baseline_spikes = length(cell2mat(baseline_spikes_array));  %number of baseline spikes
baseline_firing_rate = num_baseline_spikes/(num_trials*baseline_width);

baseline_bursts_FR_dist = [];                   %variable to keep track of firing rates of bursts in baseline
for trial_idx = 1:num_trials                    %looping through trials to make distribution of baselien brust firing rates
    baseline_bursts = ah_find_trial_bursts(baseline_spikes_array{trial_idx},baseline_firing_rate);    %find all bursts in given trial in baseline
    num_baseline_bursts = size(baseline_bursts,1);                               %number of bursts in trial in baseline
    for burst_idx = 1:num_baseline_bursts                %looping through bursts in trial in baseline
        baseline_bursts_FR_dist(end+1) = baseline_bursts(burst_idx,3)/(baseline_bursts(burst_idx,2) - baseline_bursts(burst_idx,1));
        %adding firing rate to distribution
    end
    
    [bursts, indices] = ah_find_trial_bursts(main_spikes_array{trial_idx},baseline_firing_rate);    %find all bursts in response window
    bursts_array{trial_idx} = bursts;           %update output variable of all neuron bursts in response window
    for burst_id = 1:size(bursts,1)
        burst_spikes{trial_idx} = [burst_spikes{trial_idx}; main_spikes_array{trial_idx}(indices(burst_id,1):indices(burst_id,2))];   %update output variable of all spikes participating in a burst in response window
    end
end

baseline_mean_firing_rate = mean(baseline_bursts_FR_dist);      %mean of distribution
baseline_std_firing_rate = std(baseline_bursts_FR_dist);        %standard deviation of distribution
