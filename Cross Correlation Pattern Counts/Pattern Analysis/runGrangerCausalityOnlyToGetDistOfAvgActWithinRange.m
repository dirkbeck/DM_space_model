function [foundOne,pairedCountCurr,array_of_firsts,neuron_1_z_score,neuron_2_z_score] = runGrangerCausalityOnlyToGetDistOfAvgActWithinRange(currentPair,currentDatabase,currentDatabasePairs,nlags,currentDB,dbs,range)

foundOne = 0;
currentNeuronPair = currentDatabasePairs(currentPair,:);
neuron_1_index =currentNeuronPair(1,1) ;
neuron_2_index = currentNeuronPair(1,2);
neuron_1_spikes = currentDatabase(neuron_1_index).trial_spikes;

neuron_1_average_activity = currentDatabase(neuron_1_index).inRun_firing_rate;
neuron_1_array_of_info =  currentDatabase(neuron_1_index).baseline_firing_rate_data;
neuron_1_mean = neuron_1_array_of_info(1) ;
neuron_1_std_dvn =neuron_1_array_of_info(2) ; 

neuron_2_spikes = currentDatabase(neuron_2_index).trial_spikes;
neuron_2_average_activity = currentDatabase(neuron_2_index).inRun_firing_rate;
neuron_2_array_of_info = currentDatabase(neuron_2_index).baseline_firing_rate_data;
neuron_2_mean = neuron_2_array_of_info(1);
neuron_2_std_dvn = neuron_2_array_of_info(2) ; 


neuron_1_timings = currentDatabase(neuron_1_index).trial_evt_timings;
neuron_2_timings = currentDatabase(neuron_2_index).trial_evt_timings;
% display(size(neuron_1_spikes))
% display(size(neuron_2_spikes))
[xmean_matrix, ynew_matrix,~] = concatenateFiringRatesOf2Neurons(neuron_1_spikes,neuron_2_spikes);
Mdl = varm(2,nlags);
Mdl.SeriesNames = {'Matrix FR has no effect','Striosome FR has no effect'};
EstMdl = estimate(Mdl,[xmean_matrix.',ynew_matrix.']);
%             summarize(EstMdl)
[h,summary] = gctest(EstMdl,Display=false);
array_of_firsts = [];
if (strcmpi(summary.Decision(1),"Reject H0"))
    pairedOrUnpaired = 1;
    %IMPORTANT NOTE
    %by default neuron 1 is the matrix neuron
    %and neuron 2 is the striosome neuron
    neuron_1_average_activity = calculate_inRun_firing_rate_within_range(range,neuron_1_spikes);
    neuron_2_average_activity = calculate_inRun_firing_rate_within_range(range,neuron_2_spikes);
    neuron_1_z_score = (neuron_1_average_activity - neuron_1_mean) /neuron_1_std_dvn ;
    neuron_2_z_score = (neuron_2_average_activity - neuron_2_mean) /neuron_2_std_dvn;
    pairedCountCurr = nan;

else
    pairedOrUnpaired = 0;
    neuron_1_average_activity = calculate_inRun_firing_rate_within_range(range,neuron_1_spikes);
    neuron_2_average_activity = calculate_inRun_firing_rate_within_range(range,neuron_2_spikes);
    neuron_1_z_score = (neuron_1_average_activity - neuron_1_mean) /neuron_1_std_dvn ;
    neuron_2_z_score = (neuron_2_average_activity - neuron_2_mean) /neuron_2_std_dvn;
    pairedCountCurr = nan;

end
end