function [phasic_time_delays, FR_pairs, response_probability] = find_phasic_time_delays(spikes_type1, spikes_type2, bursts_type1, bursts_type2, ...
                                                    min_delay, max_delay, min_time, max_time, debug)
% FIND_PHASIC_TIME_DELAYS finds correlated pairs of bursts between two
% neurons and reports distribution of time delays between the pairs of 
% bursts. A burst in a neuron is correlated with a burst in another neuron
% if the burst of the other neuron occurs within a certain time after the
% burst of the first neuron. Note that the relationship is NOT symmetric - 
% if a burst of neuron A is correlated with a burst of neuron B, the burst
% of neuron B is not necessarily correlated with the burst of neuron A.
%
% Inputs are:
%  SPIKES_TYPE1         - cell array with spikes of the first neuron. The
%                       spikes of the nth trial are in the nth entry.
%  SPIKES_TYPE2         - cell array with spikes of the second neuron. The
%                       spikes of the nth trial are in the nth entry.
%  TYPE1_BURSTS         - cell array with burst time windows of the first 
%                       neuron. The spikes of the nth trial are in the nth
%                       entry.
%  TYPE2_BURSTS         - cell array with burst time windows of the first 
%                       neuron. The spikes of the nth trial are in the nth
%                       entry.
%  MIN_DELAY            - the minimum amount of time between correlated
%                       bursts
%  MAX_DELAY            - the maximum amount of time between correalted
%                       bursts
%  MIN_TIME             - the minimum time from which we should look for
%                       correlated activity. Option implemented for
%                       algorithmic efficiency reasons.
%  MAX_TIME             - the maximum time to which we should look for
%                       correlated activity. Option implemented for
%                       algorithmic efficiency reasons.
%  DEBUG                - if true, will make a debug plot showing how
%                       phasic time periods are identified. If false, makes
%                       no plot.
%
% Outputs are:
%  PHASIC_TIME_DELAYS   - vector with the distribution of time delays
%                       between correlated pairs.
%  FR_PAIRS             - matrix with the firing rate of correlated bursts
%  RESPONSE_PROBABILITY - number representing the proportion of bursts of
%                       the first neuron that are correlated with at least
%                       one burst in the second neuron.

    spikes_type1 = cellfun(@(x) x(x > min_time & x < max_time),spikes_type1,'uni',false);
    spikes_type2 = cellfun(@(x) x(x > min_time & x < max_time),spikes_type2,'uni',false);
    
    phasic_time_delays = [];
    FR_pairs = [];
    % Bin spikes to calculate mean and std of firing rate
    window = .1;
    time_bins = -20:window:20;
    pls_spikes_binned = histcounts(cell2mat(spikes_type1), time_bins);
    strio_spikes_binned = histcounts(cell2mat(spikes_type2), time_bins);
    mean_pls_FR = mean(pls_spikes_binned / window / length(pls_spikes_binned));
    std_pls_FR = std(pls_spikes_binned / window / length(pls_spikes_binned));
    mean_strio_FR = mean(strio_spikes_binned / window / length(spikes_type2));
    std_strio_FR = std(strio_spikes_binned / window / length(spikes_type2));
            
    total_pls_bursts = 0;
    num_pls_bursts_with_response = 0;
    num_trials = length(spikes_type1);
    for trial_num = 1:num_trials
        %% Get trial spikes and bursts
        pls_trial_spikes = spikes_type1{trial_num};
        pls_trial_bursts = bursts_type1{trial_num};
        strio_trial_spikes = spikes_type2{trial_num};
        strio_trial_bursts = bursts_type2{trial_num};
        
        %% Find phasic time delays and phasic firing rate pairs
        if isempty(pls_trial_bursts) || isempty(strio_trial_bursts)
            continue
        end
        
        for pls_burst_idx = 1:size(pls_trial_bursts,1)
            total_pls_bursts = total_pls_bursts + 1;
            
            pls_start_time = pls_trial_bursts(pls_burst_idx, 1);
            pls_end_time = pls_trial_bursts(pls_burst_idx,2);
            pls_num_spikes = pls_trial_bursts(pls_burst_idx,3);
            strio_responded = false; % for each pls burst, keep track of whether or not there was a striosome burst in response
            
            next_strio_phasic_start_idxs = find(strio_trial_bursts(:,1)>pls_end_time);
            for next_strio_phasic_start_idx = next_strio_phasic_start_idxs'
                strio_start_time = strio_trial_bursts(next_strio_phasic_start_idx,1);
                strio_end_time = strio_trial_bursts(next_strio_phasic_start_idx,2);
                strio_num_spikes = strio_trial_bursts(next_strio_phasic_start_idx,3);
                
                phasic_time_delay = strio_start_time - pls_end_time;
                if phasic_time_delay >= min_delay && phasic_time_delay <= max_delay
                    phasic_time_delays = [phasic_time_delays, phasic_time_delay];
                    % Get firing rate of phasic period
                    pls_FR = pls_num_spikes / (pls_end_time - pls_start_time);
                    pls_zscore = (pls_FR - mean_pls_FR) / std_pls_FR;
                    strio_FR = strio_num_spikes / (strio_end_time - strio_start_time);
                    strio_zscore = (strio_FR - mean_strio_FR) / std_strio_FR;
                    FR_pairs = [FR_pairs; pls_FR strio_FR];
                    if phasic_time_delay <= max_delay
                        strio_responded = true;
                    end
                end
            end
            
            % For simulataneuous phasic time periods
            for strio_burst_idx = 1:size(strio_trial_bursts,1)
                strio_start_time = strio_trial_bursts(strio_burst_idx,1);
                strio_end_time = strio_trial_bursts(strio_burst_idx,2);
                strio_num_spikes = strio_trial_bursts(strio_burst_idx,3);
                if (strio_start_time < pls_end_time && strio_end_time > pls_end_time) || (strio_start_time < pls_start_time && strio_end_time > pls_start_time) || (strio_start_time > pls_start_time && strio_end_time < pls_end_time)
                    phasic_time_delays = [phasic_time_delays, 0];
                    % Get firing rate of phasic period
                    pls_FR = pls_num_spikes / (pls_end_time - pls_start_time);
                    pls_zscore = (pls_FR - mean_pls_FR) / std_pls_FR;
                    strio_FR = strio_num_spikes / (strio_end_time - strio_start_time);
                    strio_zscore = (strio_FR - mean_strio_FR) / std_strio_FR;
                    FR_pairs = [FR_pairs; pls_FR strio_FR];
                    strio_responded = true;
                end
            end
            
            if strio_responded
                num_pls_bursts_with_response = num_pls_bursts_with_response + 1;
            end
        end
        
        %% Debug
        if debug && trial_num <= debug
            hold on;
            % Line for each spike
            line([pls_trial_spikes, pls_trial_spikes]', repmat([trial_num-.4; trial_num-.1],[1,length(pls_trial_spikes)]),'Color','black');
            line([strio_trial_spikes, strio_trial_spikes]', repmat([trial_num-.9; trial_num-.6],[1,length(strio_trial_spikes)]),'Color','black');
            
            if isempty(pls_trial_bursts) || isempty(strio_trial_bursts)
                continue
            end
            
            patch([pls_trial_bursts(:,1), pls_trial_bursts(:,2), pls_trial_bursts(:,2), pls_trial_bursts(:,1)]', ...
                repmat([trial_num-.49;trial_num-.49;trial_num-.4;trial_num-.4],[1, size(pls_trial_bursts,1)]),...
                'blue','EdgeColor','none');
            patch([strio_trial_bursts(:,1), strio_trial_bursts(:,2), strio_trial_bursts(:,2), strio_trial_bursts(:,1)]', ...
                repmat([trial_num-.6;trial_num-.6;trial_num-.51;trial_num-.51],[1, size(strio_trial_bursts,1)]),...
                'red','EdgeColor','none');
            % Connect
            for pls_burst_idx = 1:size(pls_trial_bursts,1)
                pls_start_time = pls_trial_bursts(pls_burst_idx, 1);
                pls_end_time = pls_trial_bursts(pls_burst_idx,2);
                pls_num_spikes = pls_trial_bursts(pls_burst_idx,3);
                
                next_strio_phasic_start_idxs = find(strio_trial_bursts(:,1)>pls_end_time);
                for next_strio_phasic_start_idx = next_strio_phasic_start_idxs'
                    strio_start_time = strio_trial_bursts(next_strio_phasic_start_idx,1);
                    strio_end_time = strio_trial_bursts(next_strio_phasic_start_idx,2);
                    strio_num_spikes = strio_trial_bursts(next_strio_phasic_start_idx,3);
                    
                    phasic_time_delay = strio_start_time - pls_end_time;
                    if phasic_time_delay >= min_delay && phasic_time_delay <= max_delay
                        line([pls_end_time, strio_start_time], [trial_num-.49, trial_num-.51],'Color','green');
                    end
                end
                
                % For simulataneuous phasic time periods
                for strio_burst_idx = 1:size(strio_trial_bursts,1)
                    strio_start_time = strio_trial_bursts(strio_burst_idx,1);
                    strio_end_time = strio_trial_bursts(strio_burst_idx,2);
                    strio_num_spikes = strio_trial_bursts(strio_burst_idx,3);
                    if (strio_start_time < pls_end_time && strio_end_time > pls_end_time) || (strio_start_time < pls_start_time && strio_end_time > pls_start_time) || (strio_start_time > pls_start_time && strio_end_time < pls_end_time)
                        line([pls_end_time, pls_end_time], [trial_num-.49, trial_num-.51],'Color','green');
                    end
                end
            end

            hold off;
        end
    end
    response_probability = num_pls_bursts_with_response/total_pls_bursts;
end