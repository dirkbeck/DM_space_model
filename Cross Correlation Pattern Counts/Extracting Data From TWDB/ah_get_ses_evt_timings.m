function ses_evt_timings = ah_get_ses_evt_timings(events, response_events, alignment_event, trial_marker)
%AH_GET_SES_EVT_TIMINGS gets the timing in each trial of one of each set of
%some given set of sets of events. We assume that each set of events is
%mutually exclusive; e.g., [lick right, lick left] for we do not expect to
%see lick right in the same trial as lick left and vice versa. Outputs an
%array with one row for each trial and two columns for each set of events.
%First entry is the event index, and the second is the timing of the event
%in the trial relative to the alignment event. If none of the events in a
%given set occur in a given trial, then both spots are left as 0 - no event
%IDs are 0 so this can easily be searched for. 
%Inputs are:
% EVENTS - sorted two column array of every event occuring in the session
%   and its timing
% RESPONSE_EVENTS - a cell array in which each entry is either a singular
%   event ID or a one-dimensional array of mutually exclusive event IDs.
% ALIGNMENT_EVENT - the event ID of the event to which we align our other
%   events. If not found in a given trial, all entries of that row will be
%   0.
% TRIAL_MARKER - the event we use as the start of each trial (e.g. end of
%   baseline event)

tmp_trial_starts = events(events(:,2)==trial_marker,1); %all instances of trial_marker
real_trials = 1;                                    %to help deal with degenerate trials
for trial_idx = 2:length(tmp_trial_starts)          %looping through all trials
    if tmp_trial_starts(trial_idx) - tmp_trial_starts(trial_idx - 1) > 1
        real_trials(end+1) = trial_idx;             %trial not considered real if too soon after previous trial
    end
end
trial_starts = tmp_trial_starts(real_trials);       %the trial starts with degernate trials removed
trial_starts(end + 1) = trial_starts(end) + 100;    %fake last trial start after last trial to avoid errors/extra if statements

num_trials = length(trial_starts) - 1;              %number of trials
num_response_events = length(response_events);      %number of events to track times of
ses_evt_timings = zeros(num_trials,2*num_response_events); %output array

for trial_idx = 1:num_trials
    tmp1 = events(events(:,2)==alignment_event,1);    %find all instances of event we are aligning to
    tmp2 = tmp1(tmp1 < trial_starts(trial_idx + 1));  %find all instances before end of current trial
    t_align_events = tmp2(tmp2 >= trial_starts(trial_idx));    %find all instances at or after start of current trial
    if ~isempty(t_align_events)                             %to avoid error in case of degenerate trial
        t_align_event = mean(t_align_events);               %to avoid error in case of multiple instances of alignment_event - should not happen in general
        for event_idx = 1:num_response_events               %loop through all sets of response events
            for event = response_events{event_idx}          %loop through all events in set of response events. By assumption, these events are mutually exclusive (e.g. lick right vs. lick left)
                tmp1 = events(events(:,2)==event,1);  %find all instances of event we are aligning to
                tmp2 = tmp1(tmp1 < trial_starts(trial_idx + 1));      %find all instances before end of current trial
                t_events = tmp2(tmp2 >= trial_starts(trial_idx));     %find all instances at or after start of current trial
                if ~isempty(t_events)                       %if this event occured in trial
                    t_event = mean(t_events);               %to avoid error in case of multiple instances of alignment_event - should not happen in general  
                    ses_evt_timings(trial_idx,2*event_idx-1:2*event_idx) = [event, t_event - t_align_event]; %update output array if event occurs
                    break;  %by assumption, if one event in a given set occurs, no others will occur, so we can move onto the next set of response events
                end
            end
        end
    end
end
