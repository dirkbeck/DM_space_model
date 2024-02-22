function [plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_burst_plotting_bins(large_bursts_array, ses_evt_timings, neuron_idsAndData, selection_criteria, selected_trials, plotting_parameters, normalization_type, thresholds, keep_allData)
%AH_FILL_SPIKE_PLOTTING_BINS creates bins that can be plotted by either
%ah_double_aligned_population_analysis or ah_plot_maze (both versions).
%Once data has been extracted from twdb in the appropriate form, this
%function allows us to convert it into a plottable form. This function is
%specifically for plotting spikes; use ah_fill_burst_plotting_bins for the
%equivalent function that works on bursts. Also has a second column of data
%with the average bin values squared. This allows us to easily compute the
%standard error of each bin.
%Inputs are:
% LARGE_SPIKES_ARRAY - a cell array where each entry is a list of the
%   spikes within a given window in that trial. Trials must be in order
%   within their neuron, and clumped together with trials for neuron 1
%   ahead of trials for neuron 2 if and only if neuron 1 is indexed before
%   neuron 2. Otherwise this function won't work and might run into errors.
% SES_EVT_TIMINGS - a cell array where each entry is an array of the
%   timings of all the events we care about for each trial. Also includes
%   the event number so that we can distinguish between such things as left
%   decision versus right decision and chocolate decision versus mixture
%   decision.
% NEURON_IDSaNDdATA - an array with a row for each neuron containing
%   pertinent information: the index of the session it belongs to, the
%   index of the last trial in large_spikes_array belonging to that neuron,
%   and various properties of the neuron as needed for both this function
%   and its equivalent with bursts (baseline data/firing rates)
% SELECTION_CRITERIA - a cell array with selection criteria for trials
%   pertaining to events which might or might have occured. Each entry
%   first lists the column number of the ses_evt_timings of the current
%   session and afterwards the event IDs of the allowable events. This
%   allows us to select, for instance, only chocolate trials or only
%   mixture trials. If unspecified, then by assumption all trials are used
%   and variable initialized as empty cell.
if ~exist('selection_criteria')
    selection_criteria = {};
end
% SELECTED_TRIALS - a cell array that allows us to select exactly which
%   trials of each neuron we wish to include. Can also be used to deselect
%   full neurons if in the appropriate index we have an array full of
%   zeros. Each entry is an array of zeros or ones; if the array is not as
%   long as the number of trials, all additional trials are considered
%   selected. If cell array is not long enough, all trials of additional
%   neurons are considered selected. If not given as an input, this
%   variable is initialized as an empty cell (all trials selected)
if ~exist('selected_trials', 'var')
    selected_trials = {};
end
% PLOTTING_PARAMETERS - 6 parameters pertaining to how we fill/define the
%   bins and thus how we plot. The entries are, in order, as follows:
%       - the number of bins to plot
%       - the index in the events array of our first alignment event
%       - the index in the events array of our second alignment event
%       - the location (on a scale of 0 to 1) where we want our first event
%           to fall. This helps us define explicitly our bins
%       - the location (on a scale of 0 to 1) where we want our second
%           event to fall. This helps us explicitly define our bins.
%       - the number of standard deviations above the mean we wish to set
%           our baseline significance parameter
%   If not given as an input, variable is initialized as [200, 1, 2, .3,
%   .6, 0] which specifies: 200 bins, first alignment event is (usually)
%   click, second alignment event is (usually) lick, with click located 30%
%   of the way through the bins, and lick 60 (e.g. click at bin 60 and
%   lick at bin 120), and finally 0 standard deviations above the baseline
%   mean burst firing rate for our baseline significance parameter
if ~exist('plotting_parameters', 'var')
    plotting_parameters = [200, 1, 2, .3, .6, 0];
end
% NORMALIZATION_TYPE - A marker indicating the type of normalization we
%   wish to use. See comments below for types of normalization. If not
%   specified, variable will be initialized as [0 0] (raw data, not
%   normalized). Second entry determines whether we are doing a trial by
%   trial or neuron by neuron type of analysis.
if ~exist('normalization_type', 'var')
    normalization_type = [0 0];
end
%THRESHOLDS - 3 different thresholds used for deciding whether or not to
%   plot a given burst. One is based on firing rate, the second on
%   significance. The third threshold is based on neuronal firing rate - we
%   wish our bursts to be at least some scalar multiple of the neuronal
%   firing rate.
if ~exist('thresholds')
    thresholds = [0 0 0];
end
% KEEP_ALL_DATA - A marker indicating whether we wish to keep all the data
% on a trial by trial/neuron by neuron level. Not for general use; creates
% a giant array.
if ~exist('keep_allData', 'var')
    keep_allData = 0;
end

current_trial = 0;                              %pointer for trial within neuron/session
current_neuron = 1;                             %pointer for neuron of current trial
current_session = neuron_idsAndData(1,1);       %pointer for session of current neuron
numBins = plotting_parameters(1);               %number of plotting bins
firstAlignEvent = plotting_parameters(2);       %index of pair of columns in ses_evt_timings of first alignment event
secondAlignEvent = plotting_parameters(3);      %index of pair of columns in ses_evt_timings of second alignment event
firstAlignEventLoc = plotting_parameters(4);    %where, on a scale of 0 to 1, we wish to fix the first alignment event
secondAlignEventLoc = plotting_parameters(5);   %where, on a scale of 0 to 1, we wish to fix the second alignment event
numberSTDs = plotting_parameters(6);
baseline_sig_param = neuron_idsAndData(current_neuron,5) + numberSTDs*neuron_idsAndData(current_neuron,6);

burst_normalization_type = normalization_type(1);   %type of normalization for each trial/neuron relative to itself
neuron_normalization = normalization_type(2);       %determines whether or not we are doing trial-by-trial or neuron-by-neuron normalization

plotting_bins = zeros(numBins,2);               %the output array.
tmp_bins = zeros(numBins,1);                    %temporary bins - bins for each trial; after each trial we normalize and add this to the plotting bins and then reset it
num_events = size(ses_evt_timings{1},2)/2;      %number of events we have timings for
evt_times_distribution = cell(num_events,1);    %cell array with a distribution of timings for each event
numTrials = 0;                                  %counter for number of trials being used
neuronTrials = 0;                               %counter for number of trial in current neuron (if relevant)
if keep_allData && neuron_normalization
    fullData = -ones(size(neuron_idsAndData,1),numBins+1);
elseif keep_allData
    fullData = -ones(length(large_bursts_array),numBins+1);
end
for trial_idx = 1:length(large_bursts_array)    %loop through every trial
    old_neuron = current_neuron;    %pointer for neuron of previous trial
    while trial_idx > neuron_idsAndData(current_neuron,2) %augment current neuron until trial index matches
        current_neuron = current_neuron + 1;
    end
    if old_neuron == current_neuron     %if neuron unchanged, augment trial #
        current_trial = current_trial + 1;
    else        %otherwise, recompute baseline significance parameter, reset trial pointer, add trials selected array for neuron, and update session pointer
        baseline_sig_param = neuron_idsAndData(current_neuron,5) + numberSTDs*neuron_idsAndData(current_neuron,6);
        %recompute baseline significance parameter
        current_trial = 1;                                      %reset trial pointer
        current_session = neuron_idsAndData(current_neuron,1);  %update session pointer
        tmp_bins = zeros(numBins,1);                            %reset temporary bins
    end
    
    skip_trial = 0;     %boolean to update if we need to skip a given trial
    if length(selected_trials) >= current_neuron && length(selected_trials{current_neuron}) >= current_trial ...
            &&~selected_trials{current_neurons}(current_trial)
        skip_trial = 1;     %to skip a trial if it is not selected in selected_trials
    end
    for crit_idx = 1:length(selection_criteria)
        if ~ismember(ses_evt_timings{current_session}(current_trial,...
                selection_criteria{crit_idx}(1)),selection_criteria{crit_idx}(2:end))
            skip_trial = 1;     %if our trial does not have one of the desired events in the given column (e.g. event does not occur in trial), we skip trial
            break;              %Example: rat goes left and we want only trials where rat goes right.
        end
    end
    if ~skip_trial   %if we updated skip_trial, then we want to skip the trial, so we skip update of tmp_bins
        
        
        
        t_first_align_event = ses_evt_timings{current_session}(current_trial,2*firstAlignEvent);      %time of first align event in this trial
        t_second_align_event = ses_evt_timings{current_session}(current_trial,2*secondAlignEvent);    %time of second align event in this trial
        if ~(t_second_align_event - t_first_align_event <= 0 || t_second_align_event - t_first_align_event > 5) %Removing bad trials
            for evt_idx = 1:num_events      %add event times to distributions for the sake of having some sort of time scale
                if ses_evt_timings{current_session}(current_trial,2*evt_idx-1) %if the event exists (entry is non-zero), we add it to the distribution
                    evt_times_distribution{evt_idx}(end+1) = ses_evt_timings{current_session}(current_trial,2*evt_idx);
                end
            end
            neuronTrials = neuronTrials+1;

            num_bursts = size(large_bursts_array{trial_idx},1); %number of bursts in given trial
            for burst_idx = 1:num_bursts                        %loop through bursts of trial
                burst_start_time = large_bursts_array{trial_idx}(burst_idx,1);  %start time of burst
                burst_end_time = large_bursts_array{trial_idx}(burst_idx,2);   %end time of burst
                burst_num_spikes = large_bursts_array{trial_idx}(burst_idx,3); %number of spikes in burst
                burst_length = burst_end_time - burst_start_time;               %time-width of burst
                burst_firing_rate = burst_num_spikes/burst_length;              %firing rate of burst
                burst_significance = exp(-baseline_sig_param*burst_length)*...  %significance of burst relative to the baseline
                    (baseline_sig_param*burst_length)^burst_num_spikes/factorial(burst_num_spikes);
                if isnan(burst_significance)        %if significance is NaN, this indicates that the baseline mean/std evaluated to NaN,
                    burst_significance = 0;         %thus there were no baseline bursts, so the significance of any burst should be very high.
                end
                %If no threshold set for significance, we skip that check.
                %Otherwise, we need to check not only that significance is
                %sufficiently small, but also that the burst falls on the RIGHT
                %side of the distribution rather than the left.
                if burst_firing_rate < thresholds(1) || (thresholds(2) && (burst_significance > thresholds(2) || burst_firing_rate < baseline_sig_param))
                    continue    %if thresholds not met, skip burst
                end
                
                if burst_firing_rate < thresholds(3)*neuron_idsAndData(current_neuron,7)
                    continue
                end
                
                burst_start_loc = firstAlignEventLoc + (secondAlignEventLoc - firstAlignEventLoc)*(burst_start_time - ...
                    t_first_align_event)/(t_second_align_event - t_first_align_event);  %transformed location of start of burst
                burst_end_loc = firstAlignEventLoc + (secondAlignEventLoc - firstAlignEventLoc)*(burst_end_time - ...
                    t_first_align_event)/(t_second_align_event - t_first_align_event);  %transformed location of end of burst
                
                if burst_end_loc <= 0 || burst_start_loc > 1
                    continue;   %if burst falls outside of our window, we skip it
                end
                burst_start_loc = max(.0000001, burst_start_loc);
                burst_end_loc = min(1, burst_end_loc);  %to avoid index out of bounds errors
                
                start_bin = ceil(burst_start_loc*numBins);  %bin of start of burst
                end_bin = ceil(burst_end_loc*numBins);      %bin of end of burst
                if start_bin == end_bin     %if burst in a single bin, augment that bin as appropriate (scaled by firing rate)
                    tmp_bins(start_bin) = tmp_bins(start_bin) + (burst_end_loc - burst_start_loc)*burst_firing_rate*numBins;
                else %otherwise, augment all appropriate bins
                    burst_bins = burst_firing_rate*ones(end_bin - start_bin + 1,1);           %setting up an array to add to tmp_bins for this burst
                    burst_bins(1) = burst_bins(1)*(start_bin - numBins*burst_start_loc);    %scaling down the first and last bins since the burst doesn't fully cover them
                    burst_bins(end) = burst_bins(end)*(1 + numBins*burst_end_loc - end_bin);
                    tmp_bins(start_bin:end_bin) = tmp_bins(start_bin:end_bin) + burst_bins;      %augmenting the neuron bins
                end
            end
        end
    end
    if neuron_normalization && neuron_idsAndData(current_neuron, 2) > trial_idx
        continue;   %if we are doing a neuron-by-neuron analysis, we skip normalization until entire neuron is processed
    end
    nonzero_indices = tmp_bins > 0;         %indices of non-zero indices of tmp_bins - we only wish to include these/normalize based on these
    min_bin = min(tmp_bins(nonzero_indices));   %smallest size of bin
    max_bin = max(tmp_bins(nonzero_indices));   %largest size of bin
    mean_bin = mean(tmp_bins(nonzero_indices)); %mean size of bin
    std_bin = std(tmp_bins(nonzero_indices));   %std size of bin
    
    %after adding all spikes to bins, normalize relative to trial/neuron
    if sum(tmp_bins)    %to skip case in which there are no spikes in the trial
        switch burst_normalization_type         %minimax normalization in trial
            case 0; %no normalization (raw data) - no action needed
                if neuronTrials
                    tmp_bins = tmp_bins/neuronTrials;
                end
            case 1; %minimax normalization on a trial level
                if max_bin - min_bin
                    tmp_bins(nonzero_indices) = (tmp_bins(nonzero_indices) - min_bin)/(max_bin - min_bin);
                else
                    tmp_bins(nonzero_indices) = 1;
                end
            case 2; %z-score normalization
                tmp_bins(nonzero_indices) = (tmp_bins(nonzero_indices) - mean_bin)/std_bin;
            case 3; %other z-score normalization
                tmp_bins(nonzero_indices) = (tmp_bins(nonzero_indices) - mean_bin)/mean_bin;
        end
        
        plotting_bins([nonzero_indices, nonzero_indices]) = plotting_bins([nonzero_indices, nonzero_indices]) + ...
            [tmp_bins(nonzero_indices); tmp_bins(nonzero_indices).^2];   %updating plotting bins
        numTrials = numTrials + 1;                  %incrementing number of trials
        if keep_allData && neuron_normalization
            fullData(current_neuron,:) = [current_neuron; tmp_bins]';
        elseif keep_allData
            fullData(trial_idx,:) = [current_neuron; tmp_bins]';
        end
        tmp_bins = zeros(numBins,1);                %resetting the variable tmp_bins
        neuronTrials = 0;
    end
end

%Computation of average time of each bin center:
avgFirstEventTime = mean(evt_times_distribution{firstAlignEvent});
avgSecondEventTime = mean(evt_times_distribution{secondAlignEvent});
windowStartTime = avgFirstEventTime - firstAlignEventLoc/(secondAlignEventLoc - firstAlignEventLoc)*(avgSecondEventTime - avgFirstEventTime);
windowEndTime = avgSecondEventTime + (1-secondAlignEventLoc)/(secondAlignEventLoc - firstAlignEventLoc)*(avgSecondEventTime - avgFirstEventTime);
tmp_timeOfBins = linspace(windowStartTime,windowEndTime,numBins+1); %this gives us the start/end times of all the bins; we want the middle of each bin
tmp_timeOfBins = conv(tmp_timeOfBins, [.5 .5]);                     %this averages every pair of adjacent values, thus giving us the middle of every bin with a couple extra values
timeOfBins = tmp_timeOfBins(2:numBins+1);                           %this array has the middle of every bin.
if numTrials
    plotting_bins = plotting_bins/numTrials;                            %average bins across all trials
end
end
