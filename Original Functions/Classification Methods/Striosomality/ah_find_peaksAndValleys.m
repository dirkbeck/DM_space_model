function endpoints = ah_find_peaksAndValleys(trial_spikes, baseline_firing_rate, initial_type)

endpoints = ah_find_peakOrValley(trial_spikes, baseline_firing_rate, initial_type);

curr_ind = 1;
while curr_ind < length(endpoints)
    newEndPts = ah_find_peakOrValley(trial_spikes(endpoints(curr_ind):endpoints(curr_ind+1)), baseline_firing_rate, initial_type*(-1)^curr_ind);
    if newEndPts(2) && newEndPts(1) > endpoints(curr_ind) && newEndPts(2) < endpoints(curr_ind+1) && (mod(curr_ind-1,2) || newEndPts(2) - newEndPts(1) > 2)
        endpoints = [endpoints(1:curr_ind), endpoints(curr_ind) - 1 + newEndPts, endpoints(curr_ind+1:end)];
    else
        curr_ind = curr_ind + 1;
    end
end

end