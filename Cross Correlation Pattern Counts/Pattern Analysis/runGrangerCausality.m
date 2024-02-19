function [foundOne,pairedLongTrialCounter,pairedShortTrialCounter,pairedWeirdlyLongTrialCounter,...
    unpairedLongTrialCounter,unpairedShortTrialCounter,unpairedWeirdlyLongTrialCounter,...
    pairedOrUnpaired,unpairedCountCurr,pairedCountCurr,array_of_firsts] = runGrangerCausality(currentPair,currentDatabase,currentDatabasePairs,nlags,currentDB,dbs)

foundOne = 0;
currentNeuronPair = currentDatabasePairs(currentPair,:);
neuron_1_index =currentNeuronPair(1,1) ;
neuron_2_index = currentNeuronPair(1,2);
neuron_1_spikes = currentDatabase(neuron_1_index).trial_spikes;
neuron_2_spikes = currentDatabase(neuron_2_index).trial_spikes;


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
if (strcmpi(summary.Decision(1),"Reject H0"))
    pairedOrUnpaired = 1;
    %IMPORTANT NOTE
    %by default neuron 1 is the matrix neuron
    %and neuron 2 is the striosome neuron
    %we must reverse the order for plotBins
    %as plot bin expects Neuron 1 to be striosome
    %and neuron 2 to be matrix
    %this is because of some hard coding in plotBins which may be undone in a later update, but for now this is necessary
    [pairedLongTrialCounter,pairedShortTrialCounter,pairedWeirdlyLongTrialCounter,...
    unpairedLongTrialCounter,unpairedShortTrialCounter,unpairedWeirdlyLongTrialCounter,...
    unpairedCountCurr,pairedCountCurr,array_of_firsts] = plotBins(neuron_2_spikes,neuron_1_spikes,neuron_2_timings,neuron_1_timings,dbs,currentDB,currentPair,neuron_2_index,neuron_1_index,pairedOrUnpaired);
    foundOne = 1;
else
    pairedOrUnpaired = 0;
    [pairedLongTrialCounter,pairedShortTrialCounter,pairedWeirdlyLongTrialCounter,...
    unpairedLongTrialCounter,unpairedShortTrialCounter,unpairedWeirdlyLongTrialCounter,...
    unpairedCountCurr,pairedCountCurr,array_of_firsts] = plotBins(neuron_2_spikes,neuron_1_spikes,neuron_2_timings,neuron_1_timings,dbs,currentDB,currentPair,neuron_2_index,neuron_1_index,pairedOrUnpaired);
    foundOne = 1;

end
end