function [plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(large_spikes_array, ses_evt_timings, neuron_idsAndData, selection_criteria, selected_trials, plotting_parameters, normalization_type, keep_allData)
%AH_FILL_SPIKE_PLOTTING_BINS creates bins that can be plotted by either
%ah_double_aligned_population_analysis or ah_plot_maze (both versions).
%Once data has been extracted from twdb in the appropriate form, this
%function allows us to convert it into a plottable form. This function is
%specifically for plotting spikes; use ah_fill_burst_plotting_bins for the
%equivalent function that works on bursts. Inputs are:
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
% PLOTTING_PARAMETERS - 5 parameters pertaining to how we fill/define the
%   bins and thus how we plot. The entries are, in order, as follows:
%       - the number of bins to plot
%       - the index in the events array of our first alignment event
%       - the index in the events array of our second alignment event
%       - the location (on a scale of 0 to 1) where we want our first event
%           to fall. This helps us define explicitly our bins
%       - the location (on a scale of 0 to 1) where we want our second
%           event to fall. This helps us explicitly define our bins.
%   If not given as an input, variable is initialized as [200, 1, 2, .3,
%   .6] which specifies: 200 bins, first alignment event is (usually)
%   click, second alignment event is (usually) lick, with click located 30%
%   of the way through the bins, and lick 60 (e.g. click at bin 60 and
%   lick at bin 120)
if ~exist('plotting_parameters', 'var')
    plotting_parameters = [200, 1, 2, .3, .6];
end
% NORMALIZATION_TYPE - A marker indicating the type of normalization we
%   wish to use. See comments below for types of normalization. If not
%   specified, variable will be initialized as [0 0] (raw data, not
%   normalized). Second entry determines whether we are doing a trial by
%   trial or neuron by neuron type of analysis.
if ~exist('normalization_type', 'var')
    normalization_type = [0 0];
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
firstAlignEvent = plotting_parameters(2);       %column # in ses_evt_timings of first alignment event
secondAlignEvent = plotting_parameters(3);      %column # in ses_evt_timings of second alignment event
firstAlignEventLoc = plotting_parameters(4);    %where, on a scale of 0 to 1, we wish to fix the first alignment event
secondAlignEventLoc = plotting_parameters(5);   %where, on a scale of 0 to 1, we wish to fix the second alignment event
spike_normalization_type = normalization_type(1);   %type of normalization for each trial relative to itself
neuron_normalization = normalization_type(2);       %determines whether or not we are doing trial-by-trial or neuron-by-neuron normalization

plotting_bins = zeros(numBins,2);               %the output array.
tmp_bins = zeros(numBins,1);                    %temporary bins - bins for each trial; after each trial we normalize and add this to the plotting bins and then reset it
num_events = size(ses_evt_timings{1},2)/2;      %number of events we have timings for
evt_times_distribution = cell(num_events,1);    %cell array with a distribution of timings for each event
numTrials = 0;                                  %counter for number of trials being used
neuronTrials = 0;                               %counter for number of trial in current neuron (if relevant)
avgBinWidth = 0;                                %variable to keep track of average bin width of a neuron (if relevant)
if keep_allData && neuron_normalization
    fullData = -ones(size(neuron_idsAndData,1),numBins+1);
elseif keep_allData
    fullData = -ones(length(large_spikes_array),numBins+1);
end
for trial_idx = 1:length(large_spikes_array)    %loop through every trial
    old_neuron = current_neuron;    %pointer for neuron of previous trial
    while trial_idx > neuron_idsAndData(current_neuron,2) %augment current neuron until trial index matches
        current_neuron = current_neuron + 1;
    end
    if old_neuron == current_neuron     %if neuron unchanged, augment trial #
        current_trial = current_trial + 1;
    else        %otherwise update session pointer and reset trial pointer
        current_trial = 1;                                      %reset trial pointer
        current_session = neuron_idsAndData(current_neuron,1);  %update session pointer
    end
    
    skip_trial = 0;     %boolean to update if we need to skip a given trial
    if length(selected_trials) >= current_neuron && length(selected_trials{current_neuron}) >= current_trial ...
            &&~selected_trials{current_neuron}(current_trial)
        skip_trial = 1;     %to skip a trial if it is not selected in selected_trials
    end
    for crit_idx = 1:length(selection_criteria)
        if ~ismember(ses_evt_timings{current_session}(current_trial,...
                selection_criteria{crit_idx}(1)),selection_criteria{crit_idx}(2:end))
            skip_trial = 1;     %if our trial does not have one of the desired events in the given column (e.g. event does not occur in trial), we skip trial
            break;              %Example: rat goes left and we want only trials where rat goes right.
        end
    end
    if ~skip_trial   %if we updated skip_trial, then we want to skip the trial, so we move on to the next trial
        t_first_align_event = ses_evt_timings{current_session}(current_trial,2*firstAlignEvent);      %time of first align event in this trial
        t_second_align_event = ses_evt_timings{current_session}(current_trial,2*secondAlignEvent);    %time of second align event in this trial
        if ~(t_second_align_event - t_first_align_event <= 0 || t_second_align_event > 5) %Removing bad trials
            for evt_idx = 1:num_events      %add event times to distributions for the sake of having some sort of time scale
                if ses_evt_timings{current_session}(current_trial,2*evt_idx-1) %if the event exists (entry is non-zero), we add it to the distribution
                    evt_times_distribution{evt_idx}(end+1) = ses_evt_timings{current_session}(current_trial,2*evt_idx);
                end
            end
            neuronTrials = neuronTrials+1;
            binwidth = (t_second_align_event - t_first_align_event)/(numBins*(secondAlignEventLoc - firstAlignEventLoc));
            avgBinWidth = avgBinWidth + binwidth;
            num_spikes = length(large_spikes_array{trial_idx}); %number of bursts in given trial
            for spike_idx = 1:num_spikes
                spike_time = large_spikes_array{trial_idx}(spike_idx); %time of spike
                spike_loc = firstAlignEventLoc + (secondAlignEventLoc - firstAlignEventLoc)*(spike_time - ...
                    t_first_align_event)/(t_second_align_event - t_first_align_event);  %transformed location of spike
                if spike_loc <= 0 || spike_loc > 1  %if spike outside our window, we skip it
                    continue
                end
                spike_bin = ceil(numBins*spike_loc);    %bin that spike falls in
                tmp_bins(spike_bin) = tmp_bins(spike_bin) + 1;  %augment appropriate trial bin
            end
        end
    end
    if neuron_normalization && neuron_idsAndData(current_neuron, 2) > trial_idx
        continue;   %if we are doing a neuron-by-neuron analysis, we skip normalization until entire neuron is processed
%     elseif skip_trial
%         continue;   %if we skipped the trial in trial-by-trial analysis, we need to skip the normalization step lest we vastly overcount the number of trials
    end
    nonzero_indices = tmp_bins > 0;         %indices of non-zero indices of tmp_bins - we only wish to include these/normalize based on these
    min_bin = min(tmp_bins(nonzero_indices));   %smallest size of bin
    max_bin = max(tmp_bins(nonzero_indices));   %largest size of bin
    mean_bin = mean(tmp_bins(nonzero_indices)); %mean size of bin
    std_bin = std(tmp_bins(nonzero_indices));   %std size of bin
    avgBinWidth = avgBinWidth/neuronTrials;     %average width of bin
    %after adding all spikes to bins, normalize relative to trial/neuron
    if sum(tmp_bins)    %to skip case in which there are no spikes in the trial
        switch spike_normalization_type         %minimax normalization in trial
            case 0; %no normalization (raw data) - convert to firing rate
                if neuronTrials && ~isnan(avgBinWidth)
                    tmp_bins = tmp_bins/(avgBinWidth*neuronTrials);
                else
                    tmp_bins = zeros(numBins,1);
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
        neuronTrials = 0;
        avgBinWidth = 0;
        if keep_allData && neuron_normalization
            fullData(current_neuron,:) = [current_neuron; tmp_bins]';
        elseif keep_allData
            fullData(trial_idx,:) = [current_neuron; tmp_bins]';
        end
        tmp_bins = zeros(numBins,1);                %resetting the variable tmp_bins
    else
        neuronTrials = 0;
        avgBinWidth = 0;
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

plotting_bins = plotting_bins/numTrials;                            %average bins across all trials


end