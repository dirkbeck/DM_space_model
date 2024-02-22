function [neuronIndices, neurons, sessions, large_spikes_array, large_bursts_array, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb, string_neuronIndices)
%AH_EXTRADATAFROMTWDB extracts data from a given twdbfile into the format
%desired. Input string_neuronIndices is a cell array where each entry is a
%string representation of the index of the given neuron. Generally will
%come from doing a lookup in twdb and outputting the "index" field. We
%accumulate data in order, keeping track of various indices: 
% -neuronIndices: for all intents and purposes the input, but with ints 
%   in place of strings, and sorted. 
% -neurons: the collection of neurons associated with these indices, in the 
%   same order. 
% -sessions: the collection of sessions (without repetitions) of these 
%   neurons, still in the same order.
% -large_spikes_array: one entry for every trial of every neuron with the
%   spikes in that given trial in the window that we wanted to analyze in
%   our other functions/analyses. Ordered in same way as neuronIndices.
% -large_bursts_array: one entry for every trial of every neuron with the
%   bursts in that given trial in the window that we wanted to analysis in
%   our other functions/analyses. Ordered in same way as neuronIndices.
% -ses_evt_timings: one entry for each session with one row for each trial
%   containing the timing of each event within that trial in that session.
%   Ordered the same way as sessions
% -neuron_idsAndData: one row for each neuron containing two indices and 5
%   pieces of neuron-specific data relevant to firing rates. The first
%   index is last entry of large_spikes_array/large_bursts_array that is a
%   trial of that neuron, and the second index is the index of the session
%   that neuron belongs to.

num_neurons = length(string_neuronIndices); %number of neurons we have
neuronIndices = zeros(num_neurons,1);       %array to hold indices of our neuron
neurons = cell(num_neurons,1);              %cell array of our neurons
sessions = {};                              %cell array of our sessions
for neuron_idx = 1:num_neurons              %loop through neurons once to get ints instead of strings for our indices
    neuronIndices(neuron_idx) = str2double(string_neuronIndices{neuron_idx});   %update neuronIndices
end
neuronIndices = sort(neuronIndices);        %sort indices
old_session = '';                           %pointer for previous session
for neuron_idx = 1:num_neurons              %loop through neurons again to get neurons/sessions
    neurons{neuron_idx} = twdb(neuronIndices(neuron_idx)).neuronRef;    %update neuron
    if ~isequal(twdb(neuronIndices(neuron_idx)).sessionID, old_session)                %if session different from previous, add new session
        sessions{end+1} = twdb(neuronIndices(neuron_idx)).sessionID;
        old_session = twdb(neuronIndices(neuron_idx)).sessionID;               %update previous session pointer
    end
end

old_session = '';                           %pointer for previous session
large_spikes_array = {};                    %cell array of spikes per trial
large_bursts_array = {};                    %cell array of bursts per trial
ses_evt_timings = {};                       %session event timings in every trial
neuron_idsAndData = zeros(length(neuronIndices),7); %neuron IDs/data array
for neuron_iterator = 1:num_neurons         %loop through neurons one last time
    neuron_idx = neuronIndices(neuron_iterator);    %index in twdb of neuron
    current_session = twdb(neuron_idx).sessionID;   %current session pointer
    large_spikes_array = [large_spikes_array; twdb(neuron_idx).trial_spikes];   %update spikes array
    large_bursts_array = [large_bursts_array; twdb(neuron_idx).trial_bursts];   %update bursts array
    if ~isequal(old_session, current_session)       %if needed, update session event timings array
        ses_evt_timings = [ses_evt_timings; twdb(neuron_idx).trial_evt_timings];    
    end
    %update neuron indices/data array
    neuron_idsAndData(neuron_iterator,:) = [length(ses_evt_timings), length(large_spikes_array), twdb(neuron_idx).baseline_firing_rate_data];
    old_session = current_session;  %update previous session pointer
end
end