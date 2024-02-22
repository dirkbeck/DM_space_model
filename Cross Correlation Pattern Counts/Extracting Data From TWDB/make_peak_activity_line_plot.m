function [time_of_max, event_times] = make_peak_activity_line_plot(twdb, neuron_ids, ...
                                                                sig_stds, num_samples, max_ylim, neuron_type, plot, type)
% MAKE_PEAK_ACTIVITY_LINE_PLOTS make a line plot showing time of peak
% activity for each neuron in a given set of neurons. It is a good way to
% visualize the activity of many neurons as a function of time; it is more
% informative than simply averaging the traces of a group of neurons, as
% even within a group of neurons of the same type, the behaviour of
% individual neurons can vary greatly.
%
% Inputs are:
%  TWDB         - the database of neurons
%  NEURON_IDS   - the indicies of the neurons to consider. The indicies are
%               indicies of the database TWDB.
%  SIG_STDS     - a 1 by 2 matrix. The first entry specifies the standard
%               deviation that should be considered high, if we are looking
%               for excitation. The second entry specifies the standard
%               deviation that should be considered low, if we are looking
%               for inhibition. If we are just looking for excitations, the
%               first entry must be correct, and the second entry can be
%               anything. Likewise if we are looking for inhibitions. If we
%               are looking for both, then both entries must be correct.
%  NUM_SAMPLES  - the maximum number of neurons to show in a line plot
%  MAX_YLIM     - the maximum value of the y axis of the line plot.
%               Typically between num_samples+3 and num_samples+5.
%  NEURON_TYPE  - the type, as a string, of the neuron the line plot is 
%               being made for
%  PLOT         - if true, makes an actual figure with the line plot. If
%               false, does not actually make the figure.
%  TYPE         - the type of peak to look for. Valid options are
%               'excitation', 'inhibition', and 'both'.
%
% Outputs are:
%  TIME_OF_MAX  - a vector of times of peaks for the set of neurons
%               analyzed.
%  EVENT_TIMES  - a matrix of times of events for the set of neurons
%               analyzed (time of click, turn, lick, baseline start, and
%               baseline end).

    % Determine what standard deviation should be considered high, based on
    % the type of peak we are looking for.
    if strcmp(type, 'excitation')
        high_sig_std = sig_stds(1);
        low_sig_std = -Inf;
        high_peak_color = 'black';
        low_peak_color = NaN;
    elseif strcmp(type, 'inhibition')
        high_sig_std = Inf;
        low_sig_std = sig_stds(2);
        high_peak_color = NaN;
        low_peak_color = 'black';
    elseif strcmp(type, 'both')
        high_sig_std = sig_stds(1);
        low_sig_std = sig_stds(2);
        high_peak_color = rgb('Salmon');
        low_peak_color = rgb('DodgerBlue');
    end

    % Initiliaze variables
    time_of_max = [];
    event_times = [];
    
    for neuron_idx = 1:length(neuron_ids)
        % Find firing rate of neuron over time
    	[~, ~, ~, spikes_array, ~, ses_evt_timings, neuronidsAndData] = ah_extractDataFromTWDB(twdb, {num2str(neuron_ids(neuron_idx))});
        click_r = .5;
        lick_r = .6;
        turn_r = (click_r+lick_r)/2;
        preclick_bins = 60;
        [bins, ~, ts, ~] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, click_r, lick_r], [0 0]);
        bins = bins(:,1);
        % Smooth and normalize by zscore
        bins = smooth(bins,25);
        BLmean = mean(bins(preclick_bins:600*click_r-preclick_bins)); BLstd = std(bins(30:600*click_r-30));
        zscores = (bins - BLmean)/BLstd;
        
        % Low and high activity regions
        high_activity = regionprops(zscores >= high_sig_std, zscores, 'PixelIdxList', 'MaxIntensity','PixelValues');
        low_activity = regionprops(zscores <= low_sig_std, zscores, 'PixelIdxList', 'MaxIntensity','PixelValues');
        
        if plot
            hold on;
            % Green background
            patch([ts(1), ts(end), ts(end), ts(1)], ...
                    [neuron_idx, neuron_idx, neuron_idx+1, neuron_idx+1],'green','EdgeColor','none');
            hold off;
        end
        
        % For low activty
        to_remove = [];
        for region_idx = 1:length(low_activity)
            region_idxlist = low_activity(region_idx).PixelIdxList;
            region_start_idx = region_idxlist(1);
            region_end_idx = region_idxlist(end);
            if ts(region_start_idx) <= ts(600*click_r-preclick_bins) || ts(region_start_idx) >= ts(600*lick_r+preclick_bins)
                to_remove = [to_remove, region_idx];
                continue
            end
            if plot
                patch([ts(region_start_idx), ts(region_end_idx), ts(region_end_idx), ts(region_start_idx)], ...
                    [neuron_idx, neuron_idx, neuron_idx+1,neuron_idx+1],rgb('DeepSkyBlue'),'EdgeColor','none');
            end
        end
        low_activity(to_remove) = [];
        
        % Max -> black dot for point of max intensity greater than
        % threshold before turn if it exists. If not, then find point of
        % max intensity greater than threshold after turn, if it exists. If
        % not, no black dot.
        [m1,idx1] = min(zscores(600*click_r-preclick_bins:600*turn_r));
        [m,idx] = min(zscores(600*click_r-preclick_bins:600*lick_r+preclick_bins));
        if plot
            if m1 <= low_sig_std
                patch([ts(idx1+600*click_r-preclick_bins-1)-.1, ts(idx1+600*click_r-preclick_bins-1+1)+.1, ts(idx1+600*click_r-preclick_bins-1+1)+.1, ts(idx1+600*click_r-preclick_bins-1)-.1], [neuron_idx, neuron_idx, neuron_idx+1, neuron_idx+1], low_peak_color); % rgb('DodgerBlue')
            elseif m <= low_sig_std
                patch([ts(idx+600*click_r-preclick_bins-1)-.1, ts(idx+600*click_r-preclick_bins-1+1)+.1, ts(idx+600*click_r-preclick_bins-1+1)+.1, ts(idx+600*click_r-preclick_bins-1)-.1], [neuron_idx, neuron_idx, neuron_idx+1, neuron_idx+1], low_peak_color); % rgb('DodgerBlue')
            end
        end
        if m1 <= low_sig_std
            time_of_max = [time_of_max ts(idx1+600*click_r-preclick_bins-1)];
        elseif m <= low_sig_std
            time_of_max = [time_of_max ts(idx+600*click_r-preclick_bins-1)];
        elseif strcmp(type,'inhibition')
            time_of_max = [time_of_max NaN];
        end
        
        % For high activity
        to_remove = [];
        for region_idx = 1:length(high_activity)
            region_idxlist = high_activity(region_idx).PixelIdxList;
            region_start_idx = region_idxlist(1);
            region_end_idx = region_idxlist(end);
            if ts(region_start_idx) <= ts(600*click_r-preclick_bins) || ts(region_start_idx) >= ts(600*lick_r+preclick_bins)
                to_remove = [to_remove, region_idx];
                continue
            end
            if plot
                patch([ts(region_start_idx), ts(region_end_idx), ts(region_end_idx), ts(region_start_idx)], ...
                    [neuron_idx, neuron_idx, neuron_idx+1,neuron_idx+1],rgb('LightSalmon'),'EdgeColor','none');
            end
        end
        high_activity(to_remove) = [];
        
        % Max -> black dot for point of max intensity greater than
        % threshold before turn if it exists. If not, then find point of
        % max intensity greater than threshold after turn, if it exists. If
        % not, no black dot.
        [m1,idx1] = max(zscores(600*click_r-preclick_bins:600*turn_r));
        [m,idx] = max(zscores(600*click_r-preclick_bins:600*lick_r+preclick_bins));
        if plot
            if m1 >= high_sig_std
                patch([ts(idx1+600*click_r-preclick_bins-1)-.1, ts(idx1+600*click_r-preclick_bins-1+1)+.1, ts(idx1+600*click_r-preclick_bins-1+1)+.1, ts(idx1+600*click_r-preclick_bins-1)-.1], [neuron_idx, neuron_idx, neuron_idx+1, neuron_idx+1], high_peak_color);
            elseif m >= high_sig_std
                patch([ts(idx+600*click_r-preclick_bins-1)-.1, ts(idx+600*click_r-preclick_bins-1+1)+.1, ts(idx+600*click_r-preclick_bins-1+1)+.1, ts(idx+600*click_r-preclick_bins-1)-.1], [neuron_idx, neuron_idx, neuron_idx+1, neuron_idx+1], high_peak_color);
            end
        end
        if m1 >= high_sig_std
            time_of_max = [time_of_max ts(idx1+600*click_r-preclick_bins-1)];
        elseif m >= high_sig_std
            time_of_max = [time_of_max ts(idx+600*click_r-preclick_bins-1)];
        elseif strcmp(type,'excitation')
            time_of_max = [time_of_max NaN];
        end

        event_times = [event_times; ts(600*click_r) ts(600*turn_r) ts(600*lick_r) ts(600*click_r-preclick_bins) ts(600*lick_r+preclick_bins)];
    end
    
    if plot
        mean_event_times = mean(event_times);
        line([mean_event_times(1) mean_event_times(1)], [0 num_samples+1], 'Color', [0 0 0], 'LineWidth', 1);
        line([mean_event_times(2) mean_event_times(2)], [0 num_samples+1], 'Color', [0 0 0], 'LineWidth', 1);
        line([mean_event_times(3) mean_event_times(3)], [0 num_samples+1], 'Color', [0 0 0], 'LineWidth', 1);
        xlabel('Time (s)'); ylabel('Neuron #'); xlim([mean_event_times(4) mean_event_times(5)]); ylim([0 max_ylim]);
        title({['Zscore relative to baseline for each neuron ' neuron_type], ...
                '*Red: zscore >= 3', ...
                '*Green: -3 < zscore < 3', ...
                '*Blue: zscore <= -3', ...
                'Black: (First) Time of Max Zscore', ...
                ['Mean time = ' num2str(mean(time_of_max)) ', Std = ' num2str(std(time_of_max))]});
    end
end