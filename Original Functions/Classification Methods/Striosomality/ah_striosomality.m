function [type, grade, response_data] = ah_striosomality(spikes, baseline_firing_rate)
% AH_STRIOSOMALITY analyzes data 

%% Setup
spikes = sort(spikes);      %Just in case spikes array is not sorted
type = 0;                   %Set type to 0 - case that we observed no response at all
grade = 0;                  %Set grade to 0
response_data = [0 0 0 0];      %data we want to keep about the striosomal peak - start time, end time, peak time, number of spikes

%% Find peak
start_idx = find(spikes > .003, 1, 'first');        %index of first spike of 0 - 50 ms window
end_idx = find(spikes < .05, 1, 'last');            %index of last spike of 0 - 50 ms window
peak_spikes = spikes(start_idx:end_idx);            %spikes of peak window
peak_endpoints = ah_find_peakOrValley(peak_spikes, baseline_firing_rate, 1); %find peak in window
if peak_endpoints(2)
    baseline_dist = ah_baseline_bootstrapping(baseline_firing_rate, .05, 1, 1000);  %baseline bootstrapping to get distribution of peaks of fake baseline data
    mean_area = mean(baseline_dist);                %mean area of peak
    std_area = std(baseline_dist);                  %std area of peak
    
    start_time = peak_spikes(peak_endpoints(1));    %start time of peak
    end_time = peak_spikes(peak_endpoints(2));      %end time of peak
    peak_area = diff(peak_endpoints) - baseline_firing_rate*(end_time - start_time);  %area under peak
    
    if peak_area > mean_area + std_area           %if significant
        type = 1;                                   %Set type to 1; function is done
        grade = (peak_area - mean_area)/std_area;   %Set grade to z-score
        bins = hist(peak_spikes, .0005:.001:.0495); %1 ms bins of peak window (for computation of peak time)
        weighted_bins = conv(bins, [1 2 3 2 1]);    %convolution so that we have a weight mean of bins to try to find the max peak time
        weighted_bins = weighted_bins(3:end-2);     %remove excess terms of convolution
        [~, bin_idx] = max(weighted_bins);          %index of maximal weighted bin
        peak_time = (bin_idx-1/2)*.001;             %time of max of peak
        numSpikes = diff(peak_endpoints) + 1;       %number of spikes
        response_data = [start_time, end_time, peak_time, numSpikes];   %data we want to keep about the initial peak
        return;
    end
end

%% If no peak found, search instead for inhibition + rebound
end_idx = find(spikes < .2, 1, 'last');         %update index of last allowable spike
inhib_spikes = [0;spikes(start_idx:end_idx)];   %spikes of inhibition window
inhib_endpoints = ah_find_peakOrValley(inhib_spikes, baseline_firing_rate, -1); %find inhibition in window; add 0 spike so that if start of inhibition is first spike, it will be at 0 not some arbitrary later point
if inhib_endpoints(2)
    start_idx = inhib_endpoints(2);             %update index of first allowable spike
    end_idx = find(spikes < .25, 1, 'last');    %update index of last allowable spike
    rebound_spikes = spikes(start_idx:end_idx); %spikes of rebound window
    rebound_endpoints = ah_find_peakOrValley(rebound_spikes, baseline_firing_rate, 1);   %find rebound in window
    if rebound_endpoints(2)
        inhib_start_time = inhib_spikes(inhib_endpoints(1));  %start time of inhibition
        inhib_end_time = inhib_spikes(inhib_endpoints(2));    %end time of inhibition
        inhib_area = baseline_firing_rate*(inhib_end_time - inhib_start_time) - diff(inhib_endpoints);  %area above valley
        rebound_start_time = rebound_spikes(rebound_endpoints(1));      %start time of rebound
        rebound_end_time = rebound_spikes(rebound_endpoints(2));        %end time of rebound
        rebound_area = diff(rebound_endpoints) - baseline_firing_rate*(rebound_end_time - rebound_start_time);  %area under rebound
        tot_area = inhib_area + rebound_area;           %total area above valley and under rebound
        
        baseline_valley_dist = ah_baseline_bootstrapping(baseline_firing_rate, .2, -1, 1000);   %baseline bootstrapping to get distribution of valleys of fake baseline data
        mean_valley_area = mean(baseline_valley_dist);      %mean area of valley from bootstrapping
        std_valley_area = std(baseline_valley_dist);        %std area of valley from bootstrapping
        baseline_peak_dist = ah_baseline_bootstrapping(baseline_firing_rate, .25 - inhib_end_time, 1, 1000);      %baseline bootstrapping to get distribution of peaks of fake baseline data
        mean_peak_area = mean(baseline_peak_dist);          %mean area of peak from bootstrapping
        std_peak_area = std(baseline_peak_dist);            %std are of peak from bootstrapping
        mean_tot_area = mean_valley_area + mean_peak_area;  %mean combined area of peak and valley (note that distributions are independent - they were computed completely independently
        std_tot_area = (std_valley_area^2 + std_peak_area^2)^(1/2); %std combined area of peak and valley - formula assumes independence of distributions, which is clearly true
        
        if tot_area > mean_tot_area + std_tot_area    %if significant
            type = 2;                                   %Set type to 2
            grade = (tot_area - mean_tot_area)/std_tot_area;    %Set grade to z-score
            rebound_numSpikes = diff(rebound_endpoints)+1;      %number of spikes in rebound (inhib numspikes probably not important
            response_data = [inhib_start_time, inhib_end_time, rebound_end_time, rebound_numSpikes];    %data we want to keep about the inhibition...probably not important
        end
    end
end
end