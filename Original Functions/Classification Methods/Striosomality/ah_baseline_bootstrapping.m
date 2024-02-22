function baseline_bootstrapping_dist = ah_baseline_bootstrapping(baseline_firing_rate, baseline_width, type, numSamples)

baseline_bootstrapping_dist = zeros(numSamples,1);
for sample = 1:numSamples
    numSpikes = poissrnd(baseline_firing_rate*baseline_width);
    fake_spikes = sort(baseline_width*rand(numSpikes,1));
    endpts = ah_find_peakOrValley(fake_spikes, baseline_firing_rate, type);
    if endpts(2) > endpts(1)
        baseline_sample_time = diff(fake_spikes(endpts));
        baseline_bootstrapping_dist(sample) = type*(diff(endpts)-baseline_firing_rate*baseline_sample_time);
    end
end
end