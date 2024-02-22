function [inhib_times, phasic_FR_pairs, tonic_FR_pairs] = find_phasic_time_delays_inhib(spikes_type1, spikes_type2, bursts_type1, ~, ...
                                                                        ~, max_delay, min_time, max_time, normalization, debug)
% FIND_PHASIC_TIME_DELAYS finds bursts in one neuron that are correlated 
% with periods of low activity in another neuron, and reports the
% distribution of the length of periods of low activity in the other
% neuron. Additionally reports the firing rate of during the associated
% time windows found.
%
% Inputs are:
%  SPIKES_TYPE1         - cell array with spikes of the first neuron. The
%                       spikes of the nth trial are in the nth entry.
%  SPIKES_TYPE2         - cell array with spikes of the second neuron. The
%                       spikes of the nth trial are in the nth entry.
%  TYPE1_BURSTS         - cell array with burst time windows of the first 
%                       neuron. The spikes of the nth trial are in the nth
%                       entry.
%  MAX_DELAY            - the maximum amount of time of the inhibition
%                       period that a burst in the first neuron can be
%                       correlated with
%  MIN_TIME             - the minimum time from which we should look for
%                       correlated activity. Option implemented for
%                       algorithmic efficiency reasons.
%  MAX_TIME             - the maximum time to which we should look for
%                       correlated activity. Option implemented for
%                       algorithmic efficiency reasons.
%  NORMALIZATION        - either 'FR' or 'zscore'. If 'FR', the function
%                       reports pairs of firing rate as plain firing rates.
%                       If 'zscore', the function reports pairs of firing
%                       rates as zscore of firing rate relative to firing
%                       rate during a baseline time period.
%  DEBUG                - if true, will make a debug plot showing how
%                       phasic time periods are identified. If false, makes
%                       no plot.
%
% Outputs are:
%  INHIB_TIMES          - vector with the distribution of time delays
%                       between correlated time windows.
%  PHASIC_FR_PAIRS      - matrix with the firing rate of correlated time
%                       windows in which the first time window represents a
%                       burst time window for the first neuron, and the
%                       second time window represents a time window in
%                       which the second neuron is inhibited
%  TONIC_FR_PAIRS       - like phasic_FR_pairs, but the first time window
%                       is a period of time during which the first neuron 
%                       is in the tonic state.

    inhib_times = [];
    phasic_FR_pairs = [];
    tonic_FR_pairs = [];
    % Bin spikes to calculate mean and std of firing rate
    window = .1;
    time_bins = -20:window:20;
    hfn_spikes_binned = histcounts(cell2mat(spikes_type1), time_bins);
    strio_spikes_binned = histcounts(cell2mat(spikes_type2), time_bins);
    mean_hfn_FR = mean(hfn_spikes_binned / window / length(hfn_spikes_binned));
    std_hfn_FR = std(hfn_spikes_binned / window / length(hfn_spikes_binned));
    mean_strio_FR = mean(strio_spikes_binned / window / length(spikes_type2));
    std_strio_FR = std(strio_spikes_binned / window / length(spikes_type2));
    
    mean_strio_ISIs = mean(cell2mat(cellfun(@(x) diff(x(x<2.5)),spikes_type2,'uni',false)));
    
    spikes_type1 = cellfun(@(x) x(x > min_time & x < max_time),spikes_type1,'uni',false);
    spikes_type2 = cellfun(@(x) x(x > min_time & x < max_time),spikes_type2,'uni',false);
    
    num_trials = length(spikes_type1);
    for trial_num = 1:num_trials
        %% Get trial spikes and bursts
        hfn_trial_spikes = spikes_type1{trial_num};
        hfn_trial_bursts = bursts_type1{trial_num};
        strio_trial_spikes = spikes_type2{trial_num};
        %% Find phasic time delays and phasic firing rate pairs
        if isempty(hfn_trial_bursts)
            continue
        end
        
        for hfn_burst_idx = 1:size(hfn_trial_bursts,1)
            hfn_start_time = hfn_trial_bursts(hfn_burst_idx, 1);
            hfn_end_time = hfn_trial_bursts(hfn_burst_idx,2);
            hfn_mid_time = (hfn_start_time + hfn_end_time) / 2;
            hfn_num_spikes = hfn_trial_bursts(hfn_burst_idx,3);
            
            % Find striosome active periods after hfn burst
            strio_trial_spikes_tmp = strio_trial_spikes(strio_trial_spikes >= hfn_end_time);
            active_regions = regionprops(diff(strio_trial_spikes_tmp) <= mean_strio_ISIs, 'PixelIdxList','Area');
            active_regions = active_regions([active_regions.Area]>=2);
            
            % Next hfn burst start
            if hfn_burst_idx < size(hfn_trial_bursts,1)
                next_hfn_start_time = hfn_trial_bursts(hfn_burst_idx+1,1);
                if isempty(active_regions)
                    inhib_end_time = next_hfn_start_time;
                else
                    % First active region
                    active_region_start_idx = active_regions(1).PixelIdxList(1);
                    active_region_start_time = strio_trial_spikes_tmp(active_region_start_idx);
                    inhib_end_time = min(next_hfn_start_time,active_region_start_time);
                end
            elseif ~isempty(active_regions)
                active_region_start_idx = active_regions(1).PixelIdxList(1);
                active_region_start_time = strio_trial_spikes_tmp(active_region_start_idx);
                inhib_end_time = active_region_start_time;
            else
                continue
            end
            % Maximum inhibition time
            inhib_end_time = min(hfn_end_time+max_delay,inhib_end_time);
            
            % Calculate inhibtion time and firing rate during
            % inhibition
            hfn_FR = hfn_num_spikes / (hfn_end_time - hfn_start_time);
            strio_FR = sum(strio_trial_spikes >= hfn_mid_time & strio_trial_spikes < inhib_end_time) / (inhib_end_time-hfn_mid_time);
            if ~isinf(hfn_FR) && ~isinf(strio_FR)
                inhib_times = [inhib_times; inhib_end_time - hfn_mid_time];
                if strcmp(normalization,'FR')
                    phasic_FR_pairs = [phasic_FR_pairs; hfn_FR strio_FR];
                elseif strcmp(normalization,'zscore')
                    phasic_FR_pairs = [phasic_FR_pairs; hfn_FR (strio_FR-mean_strio_FR)/std_strio_FR];
                else
                    disp('Error: Normalization type not recognized');
                end
            end
        end
        %% For tonic
        hfn_tonic_start_time = min_time + .1; % 100ms clearance from phasic period to be considered tonic
        for hfn_burst_idx = 1:size(hfn_trial_bursts,1)
            hfn_start_time = hfn_trial_bursts(hfn_burst_idx, 1);
            hfn_tonic_end_time = hfn_start_time - .1;
            hfn_tonic_num_spikes = sum(hfn_trial_spikes >= hfn_tonic_start_time & hfn_trial_spikes <= hfn_tonic_end_time);
            
            if hfn_tonic_end_time - hfn_tonic_start_time > .1
                strio_tonic_num_spikes = sum(strio_trial_spikes >= hfn_tonic_start_time & strio_trial_spikes < hfn_tonic_end_time + .1);
                hfn_FR = hfn_tonic_num_spikes / (hfn_tonic_end_time - hfn_tonic_start_time);
                strio_FR = strio_tonic_num_spikes / (hfn_tonic_end_time + .1 - hfn_tonic_start_time);
                
                if strcmp(normalization,'FR')
                    tonic_FR_pairs = [tonic_FR_pairs; hfn_FR, strio_FR];
                elseif strcmp(normalization,'zscore')
                    tonic_FR_pairs = [tonic_FR_pairs; hfn_FR, (strio_FR-mean_strio_FR)/std_strio_FR];
                else
                    disp('Error: Normalization type not recognized');
                end
            end
            
            hfn_end_time = hfn_trial_bursts(hfn_burst_idx, 2);
            hfn_tonic_start_time = hfn_end_time + .1;
        end
        %% Debug
        if debug && ~isempty(hfn_trial_bursts) && trial_num <= debug
            %             subplot(2,1,1);
            hold on;
            % Line for each spike
            line([hfn_trial_spikes, hfn_trial_spikes]', repmat([trial_num-.4; trial_num-.1],[1,length(hfn_trial_spikes)]),'Color','black');
            line([strio_trial_spikes, strio_trial_spikes]', repmat([trial_num-.9; trial_num-.6],[1,length(strio_trial_spikes)]),'Color','black');
            
            % Patch for each phasic period
            patch([hfn_trial_bursts(:,1), hfn_trial_bursts(:,2), hfn_trial_bursts(:,2), hfn_trial_bursts(:,1)]', ...
                repmat([trial_num-.49;trial_num-.49;trial_num-.4;trial_num-.4],[1, size(hfn_trial_bursts,1)]),...
                'red','EdgeColor','none');
            
            %             subplot(2,1,2);
            %             plot(strio_trial_spikes(1:end-1),diff(strio_trial_spikes));
            %             line([min_time, max_time], [mean_strio_ISIs, mean_strio_ISIs],'Color','black');
            
            %             subplot(2,1,1);
            % Inhib period
            for hfn_burst_idx = 1:size(hfn_trial_bursts,1)
                hfn_start_time = hfn_trial_bursts(hfn_burst_idx, 1);
                hfn_end_time = hfn_trial_bursts(hfn_burst_idx,2);
                hfn_mid_time = (hfn_start_time + hfn_end_time) / 2;
                hfn_num_spikes = hfn_trial_bursts(hfn_burst_idx,3);
                
                % Find striosome active periods after hfn burst
                strio_trial_spikes_tmp = strio_trial_spikes(strio_trial_spikes >= hfn_end_time);
                active_regions = regionprops(diff(strio_trial_spikes_tmp) <= mean_strio_ISIs, 'PixelIdxList','Area');
                active_regions = active_regions([active_regions.Area]>=2);
                
                % Next hfn burst start
                if hfn_burst_idx < size(hfn_trial_bursts,1)
                    next_hfn_start_time = hfn_trial_bursts(hfn_burst_idx+1,1);
                    if isempty(active_regions)
                        inhib_end_time = next_hfn_start_time;
                    else
                        % First active region
                        active_region_start_idx = active_regions(1).PixelIdxList(1);
                        active_region_start_time = strio_trial_spikes_tmp(active_region_start_idx);
                        inhib_end_time = min(next_hfn_start_time,active_region_start_time);
                        
                    end
                elseif ~isempty(active_regions)
                    active_region_start_idx = active_regions(1).PixelIdxList(1);
                    active_region_start_time = strio_trial_spikes_tmp(active_region_start_idx);
                    inhib_end_time = active_region_start_time;
                else
                    continue
                end
                % Maximum inhibition time
                inhib_end_time = min(hfn_end_time+max_delay,inhib_end_time);
                patch([(hfn_start_time+hfn_end_time)/2, inhib_end_time, inhib_end_time, (hfn_start_time+hfn_end_time)/2], ...
                    [trial_num-.6;trial_num-.6;trial_num-.51;trial_num-.51],'blue','EdgeColor','none','FaceAlpha',.6);
                
            end
            % Tonic
            hfn_tonic_start_time = min_time + .1; % 100ms clearance from phasic period to be considered tonic
            for hfn_burst_idx = 1:size(hfn_trial_bursts,1)
                hfn_start_time = hfn_trial_bursts(hfn_burst_idx, 1);
                hfn_tonic_end_time = hfn_start_time - .1;
                hfn_tonic_num_spikes = sum(hfn_trial_spikes >= hfn_tonic_start_time & hfn_trial_spikes <= hfn_tonic_end_time);
                
                if hfn_tonic_end_time - hfn_tonic_start_time > .1
                    strio_tonic_num_spikes = sum(strio_trial_spikes >= hfn_tonic_start_time & strio_trial_spikes <= hfn_tonic_end_time + .1);
                    
                    patch([hfn_tonic_start_time, hfn_tonic_end_time + .1, hfn_tonic_end_time + .1, hfn_tonic_start_time], ...
                        [trial_num-.6;trial_num-.6;trial_num-.51;trial_num-.51],'yellow','EdgeColor','none','FaceAlpha',.6);
                end
                
                hfn_end_time = hfn_trial_bursts(hfn_burst_idx, 2);
                hfn_tonic_start_time = hfn_end_time + .1;
            end
            hold off;
        end
    end
end
