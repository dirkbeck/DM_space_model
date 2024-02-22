function make_line_plots_master(neuron_types, dbs, cb_ids, twdbs, ROOT_DIR, max_samples, neuron_type_idxs, types, save_line_plots, save_cascade, save_results)
% MAKE_LINE_PLOTS_MASTER generates lines plots and plots derived from line
% plots. A line plot shows, for a given set of neurons, the time of peak
% activity* for each neuron. There are two plots derived from line plots -
% cascade plots and entropy plots. Cascade plots visualize, for a given
% group of neurons, the activity of that group of neurons as a function of
% time. It does this by computing an 'entropy' measure for many time
% windows - higher entropies mean more activity, and are marked red/blue,
% lower entropies mean less activity, and are marked yellow/green. The
% entropy plot shows the value of the entropy for the identified time
% windows that have the highest entropy.
% * Peak actitvity may refer to times when neurons have high activity, or
% times when neurons have low activity.
%
% Inputs are:
%  NEURON_TYPES      - cell array of strings of names of neuron types
%  DBS               - cell array of strings of names of databases
%  CB_IDS            - cell array of lists of indicies in the databases
%                    that correspond to each neuron type in neuron_types
%  TWDBS             - cell array of databases
%  ROOT_DIR          - the directory in which to save figures
%  MAX_SAMPLES       - the maximum number of neurons to show in a line plot
%  NEURON_TYPE_IDXS  - the neuron types for which the function should
%                    generate plots for. This is a list of indicies of the
%                    input neuron_types. i.e. If neuron_type_idxs is [1,3],
%                    the function will generate plots for neurons of type
%                    neuron_types{1} and neuron_types{3}.
%  TYPES             - cell array which specifies if line plots should look
%                    for excitation/high activity, inhibition/low activity,
%                    or both. 
%  SAVE_LINE_PLOTS   - if true, saves the line plots and entropy plot. Does
%                    not save otherwise.
%  SAVE_CASCADE      - if true, saves the cascase plots. Does not save
%                    otherwise.
%  SAVE_RESULTS      - if true, saves the the peak times identified by the
%                    line plot algorithm. Does not save otherwise.

% Initilize variables and setup parameters.
sig_stds = [2,2,3,3,3,3];
percentiles = [80,80,80,80,80,80];
all_times_of_max = cell(1,length(neuron_types));
window_starts = cell(1,length(neuron_types));
window_ends = cell(1,length(neuron_types));
all_window_starts = cell(1,length(neuron_types));
all_window_ends = cell(1,length(neuron_types));
entropies = cell(1,length(neuron_types));
all_event_times = cell(1,length(dbs));

% Make line plots
for neuron_type_idx = neuron_type_idxs
    neuron_type_ids = cb_ids{neuron_type_idx};
    fig_dir = [ROOT_DIR '/Time of Peak Activity Line Plots/' neuron_types{neuron_type_idx} '/'];
    if ~exist(fig_dir,'dir')
        mkdir(fig_dir);
    end
    
    % First we do a population analysis; we don't want any of the plots we
    % make here - we just want the data
    fs = [];
    times_of_max = cell(1,length(dbs));
    event_times = cell(1,length(dbs));
    for db = 1:length(dbs)
        twdb = twdbs{db};
        
        num_samples = length(neuron_type_ids{db});
        max_ylim = max(cellfun(@length,neuron_type_ids)) + 3;
        neuron_type_ids{db} = neuron_type_ids{db}(randsample(1:length(neuron_type_ids{db}),num_samples));
        [times_of_max{db}, event_times{db}] = make_peak_activity_line_plot(twdb, neuron_type_ids{db},[sig_stds(neuron_type_idx) -1.5],num_samples,max_ylim,neuron_types{neuron_type_idx},false,types{neuron_type_idx}{db});
    end
    
    % Only keep the event times we need
    for db = 1:length(dbs)
        all_event_times{db} = [all_event_times{db}; event_times{db}(:,1:3)];
    end
        
    % Make plots of just samples; these are the ones we want to save
    for db = 1:length(dbs)
        twdb = twdbs{db};
        
        f = figure;
        fs = [fs, f];
        if isinf(max_samples)
            num_samples = length(neuron_type_ids{db});
        else
            num_samples = min(max_samples,min(cellfun(@length,neuron_type_ids)));
        end
        
        max_ylim = num_samples + 5;
        neuron_type_ids{db} = neuron_type_ids{db}(randsample(1:length(neuron_type_ids{db}),num_samples));
        make_peak_activity_line_plot(twdb, neuron_type_ids{db},[sig_stds(neuron_type_idx) -1.5],num_samples,max_ylim,neuron_types{neuron_type_idx},true,types{neuron_type_idx}{db});
    end
    
    %% Do some analysis to make arrows showing peak activity windows
    % First we do some preprocessing and remove invalid entries from times_of_max
    times_of_max=arrayfun(@(x) times_of_max{x}(~isnan(times_of_max{x}))',1:length(times_of_max),'uni',false);
    times_of_max=arrayfun(@(x) times_of_max{x}(times_of_max{x}>=-3&times_of_max{x}<=6)',1:length(dbs),'uni',false);
    all_times_of_max{neuron_type_idx} = times_of_max;
    
    % Go through all possible time windows (as defined as pairs of times in time_of_max)
    % and calculate the 'intensity' of activity in the time window. The 'intensity'
    % of activity is the proportion of neurons that is active at that time.
    f = figure; fs = [fs, f];
    intensities = cell(length(dbs),1);
    for db = 1:length(dbs)
        times_of_max{db} = sort(times_of_max{db});
        for idx1 = 1:length(times_of_max{db})
            for idx2 = (idx1+1):length(times_of_max{db})
                prop_black_dots = (idx2-idx1+1)/length(event_times{db});
                time = times_of_max{db}(idx2) - times_of_max{db}(idx1);
                if ~isinf(prop_black_dots/time)
                    intensities{db} = [intensities{db}; times_of_max{db}(idx1), times_of_max{db}(idx2), prop_black_dots/time];
                end
            end
        end
    end
    intensities = cellfun(@(x) [x(:,1:2) log(x(:,3))], intensities,'uni',false);
    
    % Based on the set of intensities in all possible time windows,
    % identify the set of time windows with high intensity, defined as time
    % windows with an intensity above a threshold.
    high_intensity_windows = cellfun(@(x) x(x(:,3)>=prctile(x(:,3),percentiles(neuron_type_idx)),1:2),intensities,'uni',false);
    
    % Take the average of the start and end points of time windows that
    % have been identified as 'high intensity'. This is the time window
    % that is shown on the line plots.
    window_starts{neuron_type_idx} = cell(1,length(dbs));
    window_ends{neuron_type_idx} = cell(1,length(dbs));
    all_window_starts{neuron_type_idx} = cell(1,length(dbs));
    all_window_ends{neuron_type_idx} = cell(1,length(dbs));
    for db = 1:length(dbs)
        f = figure(fs(db));
                
        num_samples = length(neuron_type_ids{db});
        
        for window_idx = 1:size(high_intensity_windows{db},1)
            window_start = high_intensity_windows{db}(window_idx,1);
            window_end = high_intensity_windows{db}(window_idx,2);
            % We only average time windows which have at least 25% of all
            % neurons active during the time window.
            if sum(times_of_max{db}>=window_start & times_of_max{db}<=window_end) > .25*length(event_times{db})                
                window_starts{neuron_type_idx}{db} = [window_starts{neuron_type_idx}{db}, window_start];
                window_ends{neuron_type_idx}{db} = [window_ends{neuron_type_idx}{db}, window_end];
            end
        end
        all_window_starts{neuron_type_idx}{db} = window_starts{neuron_type_idx}{db};
        all_window_ends{neuron_type_idx}{db} = window_ends{neuron_type_idx}{db};
        window_starts{neuron_type_idx}{db} = mean(window_starts{neuron_type_idx}{db});
        window_ends{neuron_type_idx}{db} = mean(window_ends{neuron_type_idx}{db});
        min_num_windows = 3;
        if ~isnan(window_starts{neuron_type_idx}{db}) && length(all_window_starts{neuron_type_idx}{db}) >= min_num_windows
            entropy = sum(times_of_max{db}>=window_starts{neuron_type_idx}{db}&times_of_max{db}<=window_ends{neuron_type_idx}{db})/length(event_times{db})/(window_ends{neuron_type_idx}{db}-window_starts{neuron_type_idx}{db});
            arrow([window_starts{neuron_type_idx}{db} num_samples+2], [window_ends{neuron_type_idx}{db}, num_samples+2]);
            entropies{neuron_type_idx}(db) = entropy;
        else
            arrow([0 num_samples+2], [1, num_samples+2],'Color','white');
        end
        
        ylim([0, num_samples+3]);
                
        if save_line_plots
            saveas(f, [fig_dir 'DB ' dbs{db} ' Samples ' num2str(max_samples) ' ' types{neuron_type_idx}{db} ' Line Plot'], 'fig');
            saveas(f, [fig_dir 'DB ' dbs{db} ' Samples ' num2str(max_samples) ' ' types{neuron_type_idx}{db} ' Line Plot'], 'epsc2');
            saveas(f, [fig_dir 'DB ' dbs{db} ' Samples ' num2str(max_samples) ' ' types{neuron_type_idx}{db} ' Line Plot'], 'jpg');
        end
    end
    %close all;
end

% Make cascade plot
f = figure;
count = length(neuron_type_idxs);
window_size = .01;
for neuron_type_idx = neuron_type_idxs
    count = count - 1;
    for db = 1:length(dbs)
        subplot(3,1,db);
        window_start = window_starts{neuron_type_idx}{db};
        window_end = window_ends{neuron_type_idx}{db};
        
        if ~isempty(window_start) && ~isempty(window_end)
            all_window_starts_tmp = all_window_starts{neuron_type_idx}{db};
            all_window_ends_tmp = all_window_ends{neuron_type_idx}{db};
            min_window_start = min(all_window_starts_tmp);
            max_window_end = max(all_window_ends_tmp);
            
            window_bins = min_window_start:window_size:max_window_end;
            window_props = zeros(1,length(window_bins)-1);
            for window_idx = 1:length(all_window_starts_tmp)
                window_start_tmp = all_window_starts_tmp(window_idx);
                window_end_tmp = all_window_ends_tmp(window_idx);
                
                for window_bin_idx = 1:(length(window_bins)-1)
                    window_bin_start = window_bins(window_bin_idx);
                    window_bin_end = window_bins(window_bin_idx+1);
                    
                    if window_bin_start >= window_start_tmp && window_bin_end <= window_end_tmp
                        window_props(window_bin_idx) = window_props(window_bin_idx) + 1;
                    end
                end
            end
            if length(all_window_starts_tmp) < 2
                continue
            end
            window_props = window_props/length(all_window_starts_tmp);
            if (max(window_props) - min(window_props) == 0)
                continue
            end
            window_props = window_props.^3;
            window_props = (window_props - min(window_props)) / (max(window_props) - min(window_props));
 
            if strcmp(types{neuron_type_idx}{db},'inhibition')
                density_colors = winter(50);
            else
                density_colors = autumn(50);
            end
            [~,~,bins] = histcounts(window_props,0:1/50:1); bins = 51-bins;
            prop_colors = density_colors(bins,:);
            for window_bin_idx = 1:(length(window_bins)-1)
                patch([window_bins(window_bin_idx); window_bins(window_bin_idx+1); window_bins(window_bin_idx+1); window_bins(window_bin_idx)], ...
                        [count-.2; count-.2; count+.2; count+.2],prop_colors(window_bin_idx,:),'EdgeColor','none');
            end
            
        end
        
        all_event_times{db}(any(isnan(all_event_times{db}')),:) = [];
        for event_idx = 1:3
            line([mean(all_event_times{db}(:,event_idx)), mean(all_event_times{db}(:,event_idx))], [-1.5 4],'Color','black','LineWidth',2);
        end
        xlim([-1.5 6]); ylim([-1 4]);
    end
end

fig_dir = [ROOT_DIR 'Time of Peak Activity Line Plots/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir);
end
if save_cascade
    saveas(f, [fig_dir num2str(neuron_type_idxs) ' Cascade'], 'fig');
    saveas(f, [fig_dir num2str(neuron_type_idxs) ' Cascade'], 'epsc2');
    saveas(f, [fig_dir num2str(neuron_type_idxs) ' Cascade'], 'jpg');
end

% Make entropy plot
f = figure;
bar(cell2mat({entropies{neuron_type_idxs}}')');
legend('PLS', 'Striosome', 'HFN', 'SWNs','Location','northwest');
strs = {'Control'; 'Stress'; 'Stress2'};
set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
xlabel('Experimental Group'); ylabel('Entropy');
if save_line_plots
    saveas(f, [fig_dir num2str(neuron_type_idxs) ' Entropies'], 'fig');
    saveas(f, [fig_dir num2str(neuron_type_idxs) ' Entropies'], 'epsc2');
    saveas(f, [fig_dir num2str(neuron_type_idxs) ' Entropies'], 'jpg');
end

% Save distribution of time of max
if save_results
    all_times_of_max_real = all_times_of_max;
    save('../Final Stress Data/all_times_of_max_real.mat', 'all_times_of_max_real');
end
end