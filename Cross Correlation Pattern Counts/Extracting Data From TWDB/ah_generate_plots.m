function bar_graph_vals = ah_generate_plots(twdb, neuron_ids, fig_dir, filename, fig_title, varargin)
%AH_GENERATE_PLOTS - function to generate a whole bunch of plots relating
%to a specific set of neurons that we input.
%   Inputs:
%       TWDB: twdb file for the experiment
%       NEURON_IDS: ids in twdb of neurons we are plotting
%       FIG_DIR: directory in which we save figures
%       FILENAME: beginning of desired filename for figures (e.g. pls_cb)
%       FIG_TITLE: title to put on figure (e.g. PFC-PLs Neurons in Cost
%           Benefit)
%       VARARGIN: Options indicating the plots we want. Specify as many as
%       desired:
%           ah_generate_plots(twdb, neuron_ids, fig_dir, filename, fig_title, 'trace')
%           ah_generate_plots(twdb, neuron_ids, fig_dir, filename, fig_title, 'trace (bursts)')
%           ah_generate_plots(twdb, neuron_ids, fig_dir, filename, fig_title, 'unsplit maze', stds)
%           ah_generate_plots(twdb, neuron_ids, fig_dir, filename, fig_title, 'unsplit maze (bursts)', stds)
%           ah_generate_plots(twdb, neuron_ids, fig_dir, filename, fig_title, 'split maze', stds)
%           ah_generate_plots(twdb, neuron_ids, fig_dir, filename, fig_title, 'split maze (bursts)', stds)
%                   stds = number of stds we have +- in color scale.
%           ah_generate_plots(twdb, neuron_ids, fig_dir, filename, fig_title, 'bar', type, vals)
%                   type = 'burst' or 'spike',
%                   vals = [#bins, click location, lick location, baseline start id, baseline end id,
%                           period of interest start id, period of interest end id]
%           ah_generate_plots(twdb, neuron_ids, fig_dir, filename, fig_title, 'bursts plot', vals)
%                   vals = [lower threshold, upper threshold, plot width, dot size]
%   Outputs:
%       BAR_GRAPH_VALS: values from this neuron population to later go into
%           a bar graph - e.g. mean and std relative to baseline of a
%           period of interest. Will be [NaN NaN] unless bar is one of the
%           specified options. Warning: if multiple 'bar' options are
%           called, will only keep latest.



id = 1;
N = num2str(length(neuron_ids));
closeFigs = false;
[~, ~, ~, spikes_array, bursts_array, ses_evt_timings, neuronidsAndData] = ah_extractDataFromTWDB(twdb, neuron_ids);
bar_graph_vals = [NaN NaN];

if ~exist(fig_dir, 'dir')
    mkdir(fig_dir)
end

while id <= length(varargin)
    if isequal(varargin{id},'trace')
        plot_stds = varargin{id+1};
        id = id+2;

        [bins, evt_dist, ts, nTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0]);
        smoothing_coeff = 15;
        ah_plot_double_aligned_population_analysis(bins,evt_dist,ts,nTrials,[1 2], .55, smoothing_coeff, 1, [1 0 0], plot_stds)
        title([fig_title ', N = ', N])
        saveas(gca, [fig_dir, '\', filename, '_spikes_trace'], 'fig')
        saveas(gca, [fig_dir, '\', filename, '_spikes_trace'], 'epsc2')
        saveas(gca, [fig_dir, '\', filename, '_spikes_trace'], 'jpg')
    elseif isequal(varargin{id},'trace (bursts)')
        id = id+1;

        [bins, evt_dist, ts, nTrials] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [0 0], [12 0 5]);
        smoothing_coeff = 15;
        ah_plot_double_aligned_population_analysis(bins,evt_dist,ts,nTrials,[1 2], .55, smoothing_coeff, 1, [1 0 0], false)
        if strcmp(N, '1')
            title({[fig_title ', N = ', N], ['ratID: ' twdb(str2num(neuron_ids{1})).ratID], ['neuronRef: ' twdb(str2num(neuron_ids{1})).neuronRef]})
        else
            title([fig_title ', N = ', N])
        end
        saveas(gca, [fig_dir, '\', filename, '_bursts_trace'], 'fig')
        saveas(gca, [fig_dir, '\', filename, '_bursts_trace'], 'epsc2')
        saveas(gca, [fig_dir, '\', filename, '_bursts_trace'], 'jpg')
    elseif isequal(varargin{id},'unsplit maze')
        stds = varargin{id+1};
        id = id+2;

        [bins, ~, ~, nTrials2] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0]);
        [bins2,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0]);
        m = mean(smooth(bins(60:240,1),1))*nTrials2/numTrials; s = std(smooth(bins(60:240,1),1))*nTrials2/numTrials;
        tmp = conv(bins2(:,1), ones(1,25)/25); tmp1 = smooth(bins2(:,1),25); bins2 = [tmp1(1:24); tmp(25:600)];
        ah_plot_unsplit_maze(bins2,bins2,bins2,1,[54 33 8 33 54 1 1 m-stds*s m+stds*s .5 .6])
        title([fig_title ', N = ', N])
        text(58.8,0,['-', num2str(stds), ' stds'],'VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, ['+', num2str(stds), ' stds'],'VerticalAlignment','top');
        saveas(gca, [fig_dir, '\', filename, '_spikes_maze_unsplit'], 'fig')
        saveas(gca, [fig_dir, '\', filename, '_spikes_maze_unsplit'], 'epsc2')
        saveas(gca, [fig_dir, '\', filename, '_spikes_maze_unsplit'], 'jpg')
    elseif isequal(varargin{id},'unsplit maze (bursts)')
        stds = varargin{id+1};
        id = id+2;
        [bins, ~, ~, ~] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [0 0], [12 0 5]);
        m = mean(bins(60:240,1)); s = std(bins(60:240,1));
        tmp = conv(bins(:,1), ones(1,25)/25); bins2 = tmp(181:480);
        ah_plot_unsplit_maze(bins2,bins2,bins2,1,[54 33 8 33 54 1 1 m-stds*s m+stds*s .4 .6])
        title([fig_title ', N = ', N])
        text(58.8,0,['-', num2str(stds), ' stds'],'VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, ['+', num2str(stds), ' stds'],'VerticalAlignment','top');
        saveas(gca, [fig_dir, '\', filename, '_bursts_maze_unsplit'], 'fig')
        saveas(gca, [fig_dir, '\', filename, '_bursts_maze_unsplit'], 'epsc2')
        saveas(gca, [fig_dir, '\', filename, '_bursts_maze_unsplit'], 'jpg')
    elseif isequal(varargin{id},'split maze')
        stds = varargin{id+1};
        id = id+2;

        [bins, ~, ~, nTrials2] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0]);
        [~,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
        [binsL,~,~,~] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {[5 1001]}, {}, [500, 1, 2, .35, .65], [0 0]);
        tmp = conv(binsL(:,1), ones(1,43)/43); tmp1 = smooth(binsL(:,1),43); binsL = [tmp1(1:42); tmp(43:500)];
        [binsR,~,~,~] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {[5 2011]}, {}, [500, 1, 2, .35, .65], [0 0]);
        tmp = conv(binsR(:,1), ones(1,43)/43); tmp1 = smooth(binsR(:,1),43); binsR = [tmp1(1:42); tmp(43:500)];
        m = mean(bins(60:240,1))*nTrials2/numTrials; s = std(bins(60:240,1))*nTrials2/numTrials;
        ah_plot_split_maze(binsL,binsR,1,[54 33 8 33 54 1 1 m-stds*s m+stds*s .36 .72])
        title([fig_title ', N = ', N])
        saveas(gca, [fig_dir, '\', filename, '_spikes_maze_split'], 'fig')
        saveas(gca, [fig_dir, '\', filename, '_spikes_maze_split'], 'epsc2')
        saveas(gca, [fig_dir, '\', filename, '_spikes_maze_split'], 'jpg')
    elseif isequal(varargin{id},'split maze (bursts)')%doesn't work, don't use this option.
        stds = varargin{id+1};
        id = id+2;

        [bins, ~, ~, ~] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .3, .6, 0], [1 0], [12 0 5]);
        m = mean(bins(60:240,1)); s = std(bins(60:240,1));
        [binsL, ~, ~, ~] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuronidsAndData, {[5 1001]}, {}, [600, 1, 2, .3, .6, 0], [1 0], [12 0 5]);
        tmp = conv(binsL(:,1), ones(1,31)/31); binsL = tmp(231:430);
        [binsR, ~, ~, ~] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuronidsAndData, {[5 2011]}, {}, [600, 1, 2, .3, .6, 0], [1 0], [12 0 5]);
        tmp = conv(binsR(:,1), ones(1,31)/31); binsR = tmp(231:430);
        ah_plot_split_maze(binsL,binsR,1,[54 33 8 33 54 1 1 m-stds*s m+stds*s .35 .65])
        title([fig_title ', N = ', N])
        saveas(gca, [fig_dir, '\', filename, '_bursts_maze_split'], 'fig')
        saveas(gca, [fig_dir, '\', filename, '_bursts_maze_split'], 'epsc2')
        saveas(gca, [fig_dir, '\', filename, '_bursts_maze_split'], 'jpg')
    elseif isequal(varargin{id}, 'bar')
        type = varargin{id+1};
        vals = varargin{id+2};
        numBins = vals(1);
        click = vals(2);
        lick = vals(3);
        BLstartID = vals(4);
        BLendID = vals(5);
        PoIstartID = vals(6);
        PoIendID = vals(7);
        id = id+3;

        if isequal(type, 'burst')
            bins = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuronidsAndData, {}, {}, [numBins, 1, 2, click, lick, 0], [1 0], [12 0 5]);
        elseif isequal(type, 'spike')
            bins = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuronidsAndData, {}, {}, [numBins, 1, 2, click, lick], [0 0]);
        else
            error('invalid plot type - must be burst or spike')
        end
        BL_mean = mean(bins(BLstartID:BLendID,1)); BL_std = std(bins(BLstartID:BLendID,1));
        bar_graph_vals(1) = (mean(bins(PoIstartID:PoIendID,1)) - BL_mean)/BL_std;
        bar_graph_vals(2) = 1/sqrt(PoIendID - PoIstartID + 1)*std(bins(PoIstartID:PoIendID,1))/BL_std;

    elseif isequal(varargin{id}, 'bursts plot')
        vals = varargin{id+1};
        low_threshold = vals(1);
        high_threshold = vals(2);
        width = vals(3);
        dotsize = vals(4);
        id = id+2;

        allBursts = [];
        for iter = 1:length(neuron_ids)
            index = str2double(neuron_ids{iter});
            bursts = twdb(index).trial_bursts;
            evt_times = twdb(index).trial_evt_timings;
            for trial = 1:length(bursts)
                click = evt_times(trial,2);
                lick = evt_times(trial,4);
                if lick-click > 0
                    for burst = 1:size(bursts{trial},1)
                        burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                        burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                        burst_size = (bursts{trial}(burst,3))/(lick-click);
                        burstFR = burst_size/(burst_end - burst_start);
                        allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
                    end
                end
            end
        end

        selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), low_threshold, 0, 1, 1, 1);
        ah_plot_bursts(selectedBursts, [low_threshold, high_threshold, width, 9, length(neuron_ids), dotsize, 0, 1, 0.5, 0, 0]);
        title([fig_title ', N = ', N]);
        saveas(gca, [fig_dir, '\', filename, '_bursts_plot'], 'fig')
        saveas(gca, [fig_dir, '\', filename, '_bursts_plot'], 'epsc2')
        saveas(gca, [fig_dir, '\', filename, '_bursts_plot'], 'jpg')
    elseif isequal(varargin{id}, 'close')
        closeFigs = true;
        id = id+1;
    else
        error('Invalid plot name')
    end
end

% if closeFigs
%     close all;
% end

end
