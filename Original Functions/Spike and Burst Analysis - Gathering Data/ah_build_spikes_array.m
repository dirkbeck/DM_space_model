function [spikes_array, mean_firing_rate, std_firing_rate] = ah_build_spikes_array(spikes, events, alignment_event, window, trial_marker, numBins)
%AH_BUILD_SPIKES_ARRAY creates a cell array of spike times for each trial,
%in a given window about some alignment event. Also computes the mean
%firing rate and an approximation of the standard deviation of
%the firing rate.
%Inputs are:
% SPIKES - sorted array of times of every spike recorded at the given
%   neuron in the given session.
% EVENTS - sorted two column array of every event occuring in the session
%   and its timing
% ALIGNMENT_EVENT - the event we are aligning all spikes to
% WINDOW - the window about the event in which we wish to record all spikes
% TRIAL_MARKER - the event we use as the start of each trial (e.g. end of
%   baseline event)
% NUMBINS - number of bins we are using for computation of standard
%   deviation firing rate. If not specified, initialized as 40.
if ~exist('numBins')
    numBins = 40;
end

tmp_trial_starts = events(find(events(:,2)==trial_marker),1); %all instances of trial_marker
real_trials = 1;                                    %to help deal with degenerate trials
for trial_idx = 2:length(tmp_trial_starts)          %looping through all trials
    if tmp_trial_starts(trial_idx) - tmp_trial_starts(trial_idx - 1) > 1
        real_trials(end+1) = trial_idx;             %trial not considered real if too soon after previous trial
    end
end
trial_starts = tmp_trial_starts(real_trials);       %the trial starts with degernate trials removed
trial_starts(end + 1) = trial_starts(end) + 100;    %fake last trial start after last trial to avoid errors/extra if statements

num_trials = length(trial_starts) - 1;              %number of trials
spikes_array = cell(num_trials,1);                  %output array
allSpikeBins = [];                                  %array of firing rate bins; will have one set of numBins bins for each trial we include
binWidth = (window(2) - window(1))/numBins;         %width of each bin
binCenters = window(1)+binWidth/2:binWidth:window(2)-binWidth/2; %center of each bin

for trial_idx = 1:num_trials
    tmp1 = events(find(events(:,2)==alignment_event),1);    %find all instances of event we are aligning to
    tmp2 = tmp1(find(tmp1 < trial_starts(trial_idx + 1)));  %find all instances before end of current trial
    t_align_events = tmp2(find(tmp2 >= trial_starts(trial_idx)));    %find all instances at or after start of current trial
    if ~isempty(t_align_events)                             %to avoid error in case of degenerate trial
        t_align_event = mean(t_align_events);               %to avoid error in case of multiple instances of alignment_event - should not happen in general
        t_start = t_align_event + window(1);                %start time of window in this trial
        t_end = t_align_event + window(2);                  %end time of window in this trial
        start_idx = find(spikes >= t_start, 1, 'first');    %index of first spike in window
        end_idx = find(spikes <= t_end, 1, 'last');         %index of last spike in window
        if length([start_idx, end_idx]) == 2                %removing the degenerate case (no spikes before or after trial)
            spikes_array{trial_idx} = spikes(start_idx:end_idx) - t_align_event;
            %adding the spikes for the current trial,
            %aligned to the alignment event
            allSpikeBins(end+1:end+numBins) = hist(spikes_array{trial_idx}, binCenters)/binWidth; %add spike counts to bins and divide by bin width to convert to firing rate
        end
    end
end

if isempty(allSpikeBins)
    mean_firing_rate = 0;
    std_firing_rate = 0;
else
    mean_firing_rate = mean(allSpikeBins);
    std_firing_rate = std(allSpikeBins);
end
