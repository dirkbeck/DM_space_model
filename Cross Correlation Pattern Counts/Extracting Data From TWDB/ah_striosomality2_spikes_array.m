function [type, grade, data] = ah_striosomality2_spikes_array(spikes, baseline_firing_rate)
% AH_STRIOSOMALITY2 analyzes the response to stimulation (or whatever event
%   is aligned at 0s) for a specific template of response: in particular,
%   peak before 50 ms, inhibition after, and rebound after. Returns any of
%   5 types depending on the response (0 = none, 1 = peak only, 2 =
%   inhibition only, 3 = inhibition and rebound, 4 = peak and inhibition, 
%   5 = all three phases manifest. 
%Inputs are:
% SPIKES - one dimensional vector of all spikes aligned to stimulation.
%   Need not be sorted.
% BASELINE_FIRING_RATE - baseline firing rate of neuron 
%% Setup
spikes = sort(spikes);      %Just in case spikes array is not sorted
type = 0;                   %Set type to 0 - case that we observed no response at all
grade = 0;                  %Set grade to 0
data = zeros(1,12);         %data we want to keep about the striosomal peak: for each phase, 4 values - marker, start time, end time, number of spikes
peak_search = false;        %marker - tells us whether to search for a peak immediately following stimulation
peak_end_idx = 0;           %index of last spike in peak window - set later in function as needed
rebound_search = false;     %marker - tells us whether to search for a peak immediately following inhibition
rebound_start_idx = 0;      %index of start of rebound search window- set later in function as needed
inhib = false;              %marker - tells us whether inhibition occurs
peak = false;               %marker - tells us whether a peak in response to stimulation occurs
rebound = false;            %marker - tells us whether a peak following inhibition occurs
response_area = 0;          %variable to keep track of total area between response and curve
baseline_mean_area = 0;     %variable to keep track of total mean area of baseline bootstrapping
baseline_std_area = 0;      %variable to keep track of total std area of baseline bootstrapping
%% Search for inhibition
start_idx = find(spikes > .003, 1, 'first');        %index of first spike of inhibition window
end_idx = find(spikes < .25, 1, 'last');            %index of last spike of inhibition window
inhib_spikes = [0;spikes(start_idx:end_idx)];       %spikes of inhibition window
inhib_endpoints = ah_find_peakOrValley(inhib_spikes, baseline_firing_rate, -1); %find inhibition in window; add 0 spike so that if start of inhibition is first spike, it will be at 0 not some arbitrary later point
inhib_time = inhib_spikes(inhib_endpoints);         %time of inhibition
% disp('Inhib Time'); disp(inhib_time');
if inhib_time(1) > .05 || diff(inhib_time) < .05    %inhibition much too late to show any sort of response to stimulation
    %search for initial peak
    peak_search = true;                             %set peak search marker to true; index to 50 ms after stim
    peak_end_idx = find(spikes < .05, 1, 'last');
elseif inhib_time(1) > 0    %inhibition slightly delayed - might indicate immediate peak in response to stimulation
    peak_search = true;                             %set peak search marker to true; index to beginning of inhibition
    peak_end_idx = start_idx - 1 + inhib_endpoints(1) - 1;
    rebound_search = true;                          %set rebound search marker to true; index to end of inhibition
    rebound_start_idx = start_idx - 1 + inhib_endpoints(2) - 1;
    inhib = true;                                   %set inhibition marker to true
else
    rebound_search = true;                          %set rebound search marker to true; index to end of inhibition
    rebound_start_idx = start_idx - 1 + inhib_endpoints(2) - 1;
    inhib = true;                                   %set inhibition marker
end
%% Inhibition baseline bootstrapping
if inhib
    inhib_area = baseline_firing_rate*diff(inhib_time) - diff(inhib_endpoints);             %area of inhibition
    baseline_valley_dist = ah_baseline_bootstrapping(baseline_firing_rate, .25, -1, 1000);  %baseline bootstrapping to get distribution of valleys of fake baseline data
    response_area = response_area + inhib_area;                                             %augment response area
    baseline_mean_area = baseline_mean_area + mean(baseline_valley_dist);                   %augment baseline mean
    baseline_std_area = (baseline_std_area^2 + std(baseline_valley_dist)^2)^(1/2);          %augment baseline std
    data(5:8) = [1 diff(inhib_endpoints)+1 inhib_time'];                                     %update data
end
%% Search for initial peak
if peak_search
    peak_spikes = spikes(start_idx:peak_end_idx);                                   %spikes of peak window
    peak_endpoints = ah_find_peakOrValley(peak_spikes, baseline_firing_rate, 1);    %find peak in window
    if diff(peak_endpoints) >= 3
        peak_time = peak_spikes(peak_endpoints);                                    %time of peak
        disp('Peak Time'); disp(peak_time(1)-peak_time(2));
        peak = true;                                                                %set peak marker
        data(1:4) = [1 diff(peak_endpoints)+1 peak_time'];                          %update data
    end
end
%% Peak baseline bootstrapping
if peak
    peak_area = diff(peak_endpoints) - baseline_firing_rate*diff(peak_time);            %area of peak
    baseline_peak_dist = ah_baseline_bootstrapping(baseline_firing_rate, .05, 1, 1000); %baseline bootstrapping to get distribution of peaks of fake baseline
    response_area = response_area + peak_area;                                          %augment response area
    baseline_mean_area = baseline_mean_area + mean(baseline_peak_dist);                 %augment baseline mean
    baseline_std_area = (baseline_std_area^2 + std(baseline_peak_dist)^2)^(1/2);        %augment baseline std
end
%% Search for rebound
if rebound_search && end_idx > rebound_start_idx
    rebound_spikes = spikes(rebound_start_idx:end_idx);                                 %spikes of rebound window
    rebound_endpoints = ah_find_peakOrValley(rebound_spikes, baseline_firing_rate, 1);  %find peak after inhibition
    rebound_time = rebound_spikes(rebound_endpoints);                                   %time of peak after inhibition
    if diff(rebound_endpoints) >= 5 && rebound_time(1) - inhib_time(2) <= .02
        rebound = true;                                                                 %set rebound marker
        data(9:12) = [1 diff(rebound_endpoints)+1 rebound_time'];                       %update data
    end
end
%% Rebound baseline bootstrapping
if rebound
    rebound_area = diff(rebound_endpoints) - baseline_firing_rate*diff(rebound_time);   %area of peak
    baseline_rebound_dist = ah_baseline_bootstrapping(baseline_firing_rate, .05, 1, 1000); %baseline bootstrapping to get distribution of peaks of fake baseline
    response_area = response_area + rebound_area;                                       %augment response area
    baseline_mean_area = baseline_mean_area + mean(baseline_rebound_dist);              %augment baseline mean
    baseline_std_area = (baseline_std_area^2 + std(baseline_rebound_dist)^2)^(1/2);     %augment baseline std
end
%% Type and grade
grade = (response_area - baseline_mean_area)/baseline_std_area;            %striosomality grade
if ~inhib                                                                  %striosomality type:
    if ~peak                                                               %0 = none of the three phases
        type = 0;                                                          %1 = just initial peak
    else                                                                   %2 = just inhibition
        type = 1;                                                          %3 = inhibition and rebound
    end                                                                    %4 = peak and inhibition
elseif ~peak                                                               %5 = all three phases present
    if ~rebound                                                            % Ideally, these are in order of increasing
        type = 2;                                                          % strength/believability of the response,
    else                                                                   % but this is not a guarantee.
        type = 3;
    end
else
    if ~rebound
        type = 4;
    else
        type = 5;
    end
end
end