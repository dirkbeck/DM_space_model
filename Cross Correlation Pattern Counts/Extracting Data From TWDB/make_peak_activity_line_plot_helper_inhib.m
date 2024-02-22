function [time_of_max, event_times] = make_peak_activity_line_plot_helper_inhib(neuron_idx, ts, bins, sig_std, plot)
% MAKE_PEAK_ACTIVITY_LINE_PLOTS_HELPER_INHIB make a line plot showing time 
% of peak activity for the neuron given as input, where peak is
% interpretted as a period of low activity.
% See MAKE_PEAK_ACTIVITY_LINE_PLOTS_HELPER for more information. This function
% differs from MAKE_PEAK_ACTIVITY_LINE_PLOTS_HELPER because it interprets a
% peak as being a period of low activity, rather than a period of high
% activity.
%
% Inputs are:
%  NERUON_IDX   - the index of the neuron being analyzed. A line
%               representing the neuron will be plotted at y=neuron_idx.
%  TS           - the time of the middle of each bin
%  BINS         - the number of spikes in each bin, with the time interval
%               of the bins specified by ts
%  SIG_STD      - specifies the standard deviation that is as considered
%               low
%  PLOT         - if true, makes an actual figure with the line plot. If
%               false, does not actually make the figure.
%
% Outputs are:
%  TIME_OF_MAX  - a vector of times of peak for the neuron analyzed.
%  EVENT_TIMES  - a matrix of times of events for the neuron analyzed
%               (time of click, turn, lick, baseline start, and
%               baseline end).

    time_of_max = [];
    event_times = [];
    
    BL_start = 1; BL_end = 40;
    activity_start = BL_end;
    click = 50;
    turn = 75;
    lick = 100;
    activity_end = 110;
    
    
    % Smooth and normalize by zscore
    bins = smooth(bins,25);
    BLmean = mean(bins(BL_start:BL_end)); BLstd = std(bins(BL_start:BL_end));
    zscores = (bins - BLmean)/BLstd;

    % High activity regions
    high_activity = regionprops(zscores <= -1.5, zscores, 'PixelIdxList', 'MaxIntensity','PixelValues');

    if plot
        hold on;
        % Green background
        patch([ts(1), ts(end), ts(end), ts(1)], ...
            [neuron_idx, neuron_idx, neuron_idx+1, neuron_idx+1],'green','EdgeColor','none');
        hold off;
    end

    to_remove = [];
    for region_idx = 1:length(high_activity)
        region_idxlist = high_activity(region_idx).PixelIdxList;
        region_start_idx = region_idxlist(1);
        region_end_idx = region_idxlist(end);
        if ts(region_start_idx) <= ts(activity_start) || ts(region_start_idx) >= ts(activity_end)
            to_remove = [to_remove, region_idx];
            continue
        end
        if plot
            patch([ts(region_start_idx), ts(region_end_idx), ts(region_end_idx), ts(region_start_idx)], ...
                [neuron_idx, neuron_idx, neuron_idx+1,neuron_idx+1],'blue','EdgeColor','none');
        end
    end
    high_activity(to_remove) = [];

    % Max -> black dot for point of max intensity greater than
    % threshold before turn if it exists. If not, then find point of
    % max intensity greater than threshold after turn, if it exists. If
    % not, no black dot.
    [m1,idx1] = min(zscores(activity_start:turn));
    [m,idx] = min(zscores(activity_start:activity_end));
    if plot
        if m1 <= -1.5
            patch([ts(idx1+activity_start-1)-.1, ts(idx1+activity_start-1+1)+.1, ts(idx1+activity_start-1+1)+.1, ts(idx1+activity_start-1)-.1], [neuron_idx, neuron_idx, neuron_idx+1, neuron_idx+1], [0 0 0]);
        elseif m <= -1.5
            patch([ts(idx+activity_start-1)-.1, ts(idx+activity_start-1+1)+.1, ts(idx+activity_start-1+1)+.1, ts(idx+activity_start-1)-.1], [neuron_idx, neuron_idx, neuron_idx+1, neuron_idx+1], [0 0 0]);
        end
    end
    if m1 <= -1.5
        time_of_max = [time_of_max ts(idx1+activity_start-1)];
    elseif m <= -1.5
        time_of_max = [time_of_max ts(idx+activity_start-1)];
    else
        time_of_max = [time_of_max NaN];
    end


    event_times = [event_times; ts(click) ts(turn) ts(lick) ts(activity_start) ts(activity_end)];

%     if plot
% %         mean_event_times = mean(event_times);
%         line([ts(50) ts(50)], [0 num_samples+1], 'Color', [0 0 0], 'LineWidth', 1);
%         line([ts(75) ts(75)], [0 num_samples+1], 'Color', [0 0 0], 'LineWidth', 1);
%         line([ts(100) ts(100)], [0 num_samples+1], 'Color', [0 0 0], 'LineWidth', 1);
% %         xlabel('Time (s)'); ylabel('Neuron #'); xlim([mean_event_times(4) mean_event_times(5)]); ylim([0 max_ylim]);
%         title({['Zscore relative to baseline for each neuron ' neuron_type], ...
%             '*Red: zscore >= 3', ...
%             '*Green: -3 < zscore < 3', ...
%             '*Blue: zscore <= -3', ...
%             'Black: (First) Time of Max Zscore', ...
%             ['Mean time = ' num2str(mean(time_of_max)) ', Std = ' num2str(std(time_of_max))]});
%     end
end