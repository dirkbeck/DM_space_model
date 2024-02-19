function pairs = pair_counting(twdb,hfn_ids,strio_ids, plot)
% PAIR_COUNTING finds pairs of neurons, one from hfn_ids, and another from
% strio_ids that are recorded during the same session. Note that the
% hfn_ids does not have to contain the neurons that are HFNs. Likewise for
% strio_ids.
%
% Inputs are:
% TWDB       - the database that the ids in hfn_ids and strio_ids refer to
% HFN_IDS    - the idicies in twdb of the first set of neuonrns
% STRIO_IDS  - the idicies in twdb of the second set of neurons
% PLOT       - if true, will generate a figure showing the average trace of
%            neurons in hfn_ids and neurons in strio_ids in two separate 
%            plots. If false, makes not plot
%
% Outputs are:
% PAIRS      - a matrix of pairs of idicies in twdb. Each row represents a
%            pair. Column 1 contains neurons in hfn_ids, and column 2
%            contains neurons in strio_ids.

if ~iscell(hfn_ids)
    hfn_ids = arrayfun(@num2str,hfn_ids,'uni',false);
end
if ~iscell(strio_ids)
    strio_ids = arrayfun(@num2str,strio_ids,'uni',false);
end

count = 0;
fsi_list = [];
msn_list = [];

for i = 1:length(hfn_ids)
    hfn_idx = str2double(hfn_ids{i});
    sesh = twdb(hfn_idx).sessionID;
    tetrode = twdb(hfn_idx).tetrodeID;
    
    ses_evt_timings = twdb(hfn_idx).trial_evt_timings;
    hfn_spikes_array = twdb(hfn_idx).trial_spikes;
    hfn_neuron_idsAndData = [1, length(hfn_spikes_array), twdb(hfn_idx).baseline_firing_rate_data];
    [hfn_bins, evt_times_distribution, timeOfBins, numTrials] = ah_fill_spike_plotting_bins(hfn_spikes_array, ...
                {ses_evt_timings}, hfn_neuron_idsAndData, {}, {}, [600, 1, 2, .3, .7], [0 0], 1);

    for j = 1:length(strio_ids)
        strio_idx = str2double(strio_ids{j});
        
        if isequal(twdb(strio_idx).sessionID, sesh) && isequal(twdb(strio_idx).tetrodeID, tetrode)
            % Insert code here for analysis
            fsi_list = [fsi_list hfn_idx];
            msn_list = [msn_list strio_idx];
            
            count = count + 1;
            
            strio_spikes_array = twdb(strio_idx).trial_spikes;
            strio_neuron_idsAndData = [1, length(strio_spikes_array), twdb(strio_idx).baseline_firing_rate_data];
            strio_bins = ah_fill_spike_plotting_bins(strio_spikes_array, ...
                {ses_evt_timings}, strio_neuron_idsAndData, {}, {}, [600, 1, 2, .3, .7], [0 0], 1);
            
            if plot
                figure; hold all;
                subplot(1,2,1);
                ah_plot_double_aligned_population_analysis(hfn_bins, evt_times_distribution, timeOfBins, numTrials, [1 2], .5, 15, 0, [1 0 0]);
                subplot(1,2,2);
                ah_plot_double_aligned_population_analysis(strio_bins, evt_times_distribution, timeOfBins, numTrials, [1 2], .5, 15, 0, [1 0 0]);
            end
        end
    end
end
pairs = [fsi_list;msn_list]';
end