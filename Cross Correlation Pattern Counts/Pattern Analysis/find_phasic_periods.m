function phasic_periods = find_phasic_periods(spikes, smooth_factor, min_ISIs_per_neuron, min_time, max_time, ah_bursts, method, debug_thresholds, varargin)
% FIND_PHASIC_PERIODS finds periods of time in which the neuron with the
% given spikes is in the phasic/burst state.
% 
% Inputs are:
%  SPIKES               - cell array with spike timings in the nth trial in
%                       the nth entry
%  SMOOTH_FACTOR        - the amount by which we should smooth the set of 
%                       neuron ISIs during a trial. This helps make clean
%                       the data, but should not be set to a high value, so
%                       as to not corrupt the data.
%  MIN_ISIS_PER_NEURON  - the minimum number of ISIs that exist in the 
%                       spikes array. In order for a threshold to be found,
%                       there must be some minimal amount of data. 
%                       Typically, there should be at least 15 data points.
%  MIN_TIME             - the minimum time from which we should look for
%                       phasic activity periods. Option implemented for
%                       algorithmic efficiency reasons.
%  MAX_TIME             - the maximum time to which we should look for
%                       phasic activity periods. Option implemented for
%                       algorithmic efficiency reasons.
%  AH_BURSTS            - cell array of bursts found using Adam's method.
%                       The nth entry of the cell array contains phasic
%                       activity periods found for the nth trial.
%  METHOD               - determines whether phasic periods will be found
%                       using Adam's method or Tim's method. This value can
%                       either be the string 'Tim' or the string 'AH'.
%  DEBUG_THRESHOLDS     - if true, will make a debug plot showing how
%                       phasic time periods are identified. If false, makes
%                       no plot.
%  VARARGIN             - Contains the figure directory into which the
%                       debug plot should be saved.
%
% Outputs are:
%  PHASIC_PERIODS       - cell array with lists of phasic period start
%                       times and end times. The nth entry of the cell
%                       array contains the phasic period timings of the nth
%                       trial.

    % Set the figure directory, if necessary.
    if ~isempty(varargin)
        fig_dir = varargin{1};
    else
        fig_dir = NaN;
    end
    
    % Find ISI threshold for burst/phasic period detection
    ISI_thresholds = find_ISI_burst_thresholds(spikes,smooth_factor,min_ISIs_per_neuron,debug_thresholds,fig_dir);

    if ~any(isnan(ISI_thresholds))
        if strcmp(method, 'Tim')
            spikes = cellfun(@(x) x(x > min_time & x < max_time),spikes,'uni',false);

            num_trials = length(spikes);
            phasic_periods = cell(num_trials,1);
            for trial_num = 1:num_trials
                % Get spikes in the trial
                trial_spikes = spikes{trial_num};

                % Convert to ISIs and smooth (?)
                smooth_factor = 1; % Don't smooth here!
                ISIs = smooth(diff(trial_spikes),smooth_factor);

                %% Find phasic periods - find regions of ISIs less than the high
                % threshold and start with an ISI less than the low threshold
                    phasic_regions_data = regionprops(ISIs <= ISI_thresholds(2), 'PixelIdxList','Area');
                    to_keep = [];
                    for region_idx = 1:length(phasic_regions_data)
                        for pixel_idx = 1:length(phasic_regions_data(region_idx).PixelIdxList)
                            if ISIs(phasic_regions_data(region_idx).PixelIdxList(pixel_idx)) <= ISI_thresholds(1)
                                phasic_regions_data(region_idx).PixelIdxList = phasic_regions_data(region_idx).PixelIdxList(pixel_idx:end);
                                to_keep = [to_keep, region_idx];
                                break;
                            end
                        end
                    end
                    phasic_regions_data = phasic_regions_data(to_keep);

                    % Find phasic period start and end times
                    phasic_region_start_times = trial_spikes(cellfun(@(x) x(1),{phasic_regions_data.PixelIdxList}));
                    phasic_region_end_times = trial_spikes(cellfun(@(x) x(end),{phasic_regions_data.PixelIdxList}) + 1);
                    phasic_region_areas = [phasic_regions_data.Area]'+1;
                    phasic_periods{trial_num} = [phasic_region_start_times,phasic_region_end_times,phasic_region_areas];
            end
            
            % Visualization
            if debug_thresholds
                trial_num = 19;
                trial_spikes = spikes{trial_num};
                
                f = figure;
                subplot(3,1,1);
                line([trial_spikes, trial_spikes]', repmat([trial_num-.4; trial_num-.1],[1,length(trial_spikes)]),'Color','black');
                ylim([18.5 19]);
                xlim([-1 1]);
                xlabel('Time (s)');
                
                subplot(3,1,2);
                hold on;
                stairs(trial_spikes(1:end-1),log10(diff(trial_spikes)),'LineWidth',1,'Color','red'); 
                
                [xb,yb] = stairs(trial_spikes(1:end-1),log10(diff(trial_spikes)));
                aboveThreshold = (yb >= log10(ISI_thresholds(1)));
                bottomLine = yb;
                topLine = yb;
                bottomLine(aboveThreshold) = NaN;
                topLine(~aboveThreshold) = NaN;
                plot(xb,bottomLine,'r','LineWidth',2);
                plot(xb,topLine,'b','LineWidth',2);
                line([-1 1], log10(ISI_thresholds),'LineWidth',2,'Color','black');
                xlim([-1 1]);
                xlabel('Time (s)'); ylabel('log ISI (s)');
                
                hold off;
                
                subplot(3,1,3);
                hold on;
                line([trial_spikes, trial_spikes]', repmat([trial_num-.4; trial_num-.1],[1,length(trial_spikes)]),'Color','black');
                ylim([18.5 19]);
                xlim([-1 1]);
                xlabel('Time (s)');

                phasic_to_plot = phasic_periods{trial_num};
                whitespace = .005;
                for phasic_idx = 1:size(phasic_to_plot,1)
                    phasic_start = phasic_to_plot(phasic_idx,1) - whitespace;
                    phasic_end = phasic_to_plot(phasic_idx,2) + whitespace;
                    patch([phasic_start, phasic_end, phasic_end, phasic_start], ...
                          [trial_num-.4, trial_num-.4, trial_num-.1, trial_num-.1], ...
                          'white', 'FaceColor', 'none', 'EdgeColor', 'red', 'LineWidth', 2);
                end
                hold off;
                
                saveas(f, [fig_dir 'Burst Detection'], 'fig');
                saveas(f, [fig_dir 'Burst Detection'], 'epsc2');
                saveas(f, [fig_dir 'Burst Detection'], 'jpg');
            end
        elseif strcmp(method,'AH')
            phasic_periods = cell(length(ah_bursts),1);
            for trial_num = 1:length(ah_bursts)
                if ~isempty(ah_bursts{trial_num})
                    phasic_periods{trial_num} = ah_bursts{trial_num}(ah_bursts{trial_num}(:,1)>=min_time&ah_bursts{trial_num}(:,2)<=max_time,:);
                end
            end
        else
            disp('Error; invalid method to find phasic activity.')
        end
    else
        phasic_periods = NaN;
    end
end