function [inRun_firing_rate] = calculate_inRun_firing_rate_within_range(range, neuron_spikes)
   for i=1:size(neuron_spikes,1)
       current_trial_data = neuron_spikes{i};
       disp(current_trial_data)
   end
end