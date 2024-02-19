function [zscore, stderr, BLmean, BLstd, FR, FR_std] = quantify_neuron_activity(twdb,neuron_ids,type,BLstart,BLend,window_start,window_end,varargin)
% QUANTIFY_NEURON_ACTIVTY finds, for a given set of neurons, the firing
% rate and zscore of the activity of the neurons during a time window. The
% zscore is calculated relative to the firing rate during the baseline
% period.
%                         
% Inputs are:
%  TWDB             - the database containing neuron data
%  NEURON_IDS       - the set of neurons in the database to consider in
%                     calculations
%  TYPE             - determines the type of activity being measured. Can
%                     be one of the following:
%                       1. 'spikes' - considers all neuron activity
%                       2. 'bursts' - considers only neuron activty during
%                       a burst
%  BLSTART          - the bin index corresponding to the start of the
%                   baseline period
%  BLEND            - the bin index corresponding to the end of the
%                   baseline period
%  WINDOW_START     - the bin index corresponding to the beginning of the
%                   period we are intertested in
%  WINDOW_END       - the bin index corresponding to the end of the period
%                   we are interested in
%  VARARGIN         - if 1, will plot the average trace of the neurons
%                   under consideration (specified by neuron ids)
% Outputs are:
%  ZSCORE           - the zscore of the firing rate of the neurons during 
%                   the period under consideration relative to the firing
%                   rate of the neurons during the baseline
%  STDERR           - the corresponding standard error of the above measure
%  BLMEAN           - the mean firing rate of the neurons during the
%                   baseline period
%  BLSTD            - the standard deviation of the firing rate of the
%                   neurons during the baseline period
%  FR               - the mean firing rate of the neurons during the
%                   specified time window
%  FR_STD           - the standard deviation of the firing rate of the
%                   neurons during the specified time window

    % Convert neuron ids to strings to use as input to Adam functions
    neuron_ids = arrayfun(@num2str, neuron_ids,'uni',false);
    [~, ~, ~, spikes_array, bursts_array, ses_evt_timings, neuronidsAndData] = ah_extractDataFromTWDB(twdb, neuron_ids);
    
    if strcmp(type,'spikes')
        [bins, ~, ~, ~] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0]);
        bins = bins(:,1);
        if ~isempty(varargin) && varargin{1} == 1
            figure;
            plot(bins);
        end
        
        BLmean = mean(bins(BLstart:BLend)); FR = mean(bins(window_start:window_end));
        BLstd = std(bins(BLstart:BLend));	FR_std = std(bins(window_start:window_end));
        bins = (bins - BLmean) / BLstd;
        if ~isempty(varargin) && varargin{1} == 1
            disp([BLmean BLstd mean(bins(window_start:window_end))])
        end
        
        bins = bins(window_start:window_end);
        zscore = mean(bins);
        stderr = std(bins)/sqrt(length(bins));
    elseif strcmp(type, 'bursts')
        [bins, ~, ~, ~] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [0 0], [12 0 5]);
        bins = bins(:,1);
        
        BLmean = mean(bins(BLstart:BLend)); FR = mean(bins(window_start:window_end));
        BLstd = std(bins(BLstart:BLend));   FR_std = std(bins(window_start:window_end));
        bins = (bins - BLmean) / BLstd;
        
        bins = bins(window_start:window_end);
        zscore = mean(bins);
        stderr = std(bins)/sqrt(length(bins));
    elseif strcmp(type,'intra-burst FR') && length(neuron_ids) == 1
        neuron_id = str2num(neuron_ids{1});
        bursts = twdb(neuron_id).trial_bursts;
        burst_FRs = [];
        
        for trial_num = 1:length(bursts)
            if isempty(bursts{trial_num})
                continue
            end
            burst_starts = bursts{trial_num}(:,1);
            burst_ends = bursts{trial_num}(:,2);
            burst_lengths = bursts{trial_num}(:,3);
            
            burst_FRs = [burst_FRs; burst_lengths ./ (burst_ends - burst_starts)];
        end
        FR = mean(burst_FRs);
        FR_std = std(burst_FRs);
        zscore = NaN; stderr = NaN; BLmean = NaN; BLstd = NaN;
    else
        error('Incorrect data type - spikes or bursts');
    end
end