function [xmean_matrix, ynew_matrix,edges] =concatenateFiringRatesOf2Neurons(spikes_neuron_1, spikes_neuron_2)
all_neuron1_times = [];
all_neuron2_times = [];
for spike_idx = 1: min([length(spikes_neuron_1),length(spikes_neuron_2)])
    if length(spikes_neuron_2) ~= length(spikes_neuron_1)
        disp(strcat("The 2 spikes do not have the same length, they differ by: ",string(length(spikes_neuron_2) - length(spikes_neuron_1))))
    end
    s1 = spikes_neuron_1(spike_idx);
    s2 = spikes_neuron_2(spike_idx);
    all_neuron1_times = [all_neuron1_times s1{1}.'];
    all_neuron2_times = [all_neuron2_times s2{1}.'];
end




% scatter(xmean_matrix,ynew_matrix)
[min_neuron1_time,max_neuron1_time] = bounds(all_neuron1_times);
[min_neuron2_time,max_neuron2_time] = bounds(all_neuron2_times);

totalSecondsForNeuron1 = abs(min_neuron1_time) + abs(max_neuron1_time);
totalSecondsForNeuron1 = totalSecondsForNeuron1*1000;

totalSecondsForNeuron2 = abs(min_neuron2_time) + abs(max_neuron2_time);
totalSecondsForNeuron2 = totalSecondsForNeuron2*1000;

if totalSecondsForNeuron2 > totalSecondsForNeuron1
    numberOfBins = totalSecondsForNeuron2/100;
elseif totalSecondsForNeuron1 > totalSecondsForNeuron2
    numberOfBins = totalSecondsForNeuron1/100;
else
    numberOfBins = totalSecondsForNeuron1/100;
end

[xmean_matrix,edges] = histcounts(all_neuron1_times,ceil(numberOfBins));
ynew_matrix = histcounts(all_neuron2_times,edges);
% check to make sure there's actually enough data to fit




end