function [stimulated_ids, inhibited_ids, ps_more_extreme, zscores, peakToValley_lengths, firing_rates, peak_heights, MSWs] = ...
    find_responders_simple(twdb, neuron_ids, type, computer, ...
                           p_threshold, dendritic_filter, min_firing_rate, min_peak_height, min_final_michael_grade, debug, ROOT_DIR)

    if debug
        f = figure;
    end
    
    if strcmp(neuron_ids, 'all')
        neuron_ids = 1:length(twdb);
    end
    
    stimulated_ids = [];
    inhibited_ids = [];
    ps_more_extreme = [];
    zscores = [];
    peakToValley_lengths = [];
    firing_rates = [];
    peak_heights = [];
    MSWs = [];
    for idx = neuron_ids
        %% Set up spikes array
        unitnum = str2double(twdb(idx).neuronN);
        sessionDir = twdb(idx).clusterDataLoc;
        if strcmp(computer,'Seba')
            continue;
        elseif strcmp(computer,'Tim')
            sessionDir = strrep(sessionDir, '/Users/Seba/Dropbox (MIT)/UROP/volume_experiment/', '../Final Stress Data/PV Experiment/');
            sessionDir = strrep(sessionDir, 'C:\Users\TimT5\Dropbox (MIT)\cell\Volume Codes\', '../Final Stress Data/PV Experiment/');
        else
            disp('Incorrect user entered; either Seba or Tim');
        end
        spikes = load(sessionDir);
        spikes = spikes.output;
        spikes = spikes(spikes(:,2)==unitnum,1);

        sessionDir = twdb(idx).sessionDir;
        if strcmp(computer,'Seba')
            continue;
        elseif strcmp(computer,'Tim')
            sessionDir = strrep(sessionDir, '/Users/Seba/Dropbox (MIT)/UROP/volume_experiment/', '../Final Stress Data/PV Experiment/');
            sessionDir = strrep(sessionDir, 'C:\Users\TimT5\Dropbox (MIT)\cell\Volume Codes\', '../Final Stress Data/PV Experiment/');
        else
            disp('Incorrect user entered; either Seba or Tim');
        end
        events = load([sessionDir, '/events5third.EVTSAV'], '-mat');
        events = events.lfp_save_events;

        blocks = [];

        %6mv
        block_idx = find(events(:,2)==42);
        if ~isempty(block_idx)
            block_idx = block_idx(end);
            block_end = find(events(block_idx+2:end,2)==100,1,'first') + block_idx + 1;
            events_6mv = events(block_idx:block_end,:);
            events_6mv(events==6)=4;
            stim_spikes_6mv = ah_build_spikes_array(spikes,events_6mv,4,[-2 1],4);
            numTrials_6mv = length(stim_spikes_6mv);
            blocks = [blocks 6];
        end

        %4mv
        block_idx = find(events(:,2)==41);
        if ~isempty(block_idx)
            block_idx = block_idx(end);
            block_end = find(events(block_idx+2:end,2)==100,1,'first') + block_idx + 1;
            events_4mv = events(block_idx:block_end,:);
            events_4mv(events==6)=4;
            stim_spikes_4mv = ah_build_spikes_array(spikes,events_4mv,4,[-2 1],4);
            numTrials_4mv = length(stim_spikes_4mv);
            blocks = [blocks 4];
        end

        %2mv
        block_idx = find(events(:,2)==44);
        if ~isempty(block_idx)
            block_idx = block_idx(end);
            block_end = find(events(block_idx+2:end,2)==100,1,'first') + block_idx + 1;
            events_2mv = events(block_idx:block_end,:);
            events_2mv(events==6)=4;
            stim_spikes_2mv = ah_build_spikes_array(spikes,events_2mv,4,[-2 1],4);
            numTrials_2mv = length(stim_spikes_2mv);
            blocks = [blocks 2];
        end

        %1mv
        block_idx = find(events(:,2)==43);
        if ~isempty(block_idx)
            block_idx = block_idx(end);
            block_end = find(events(block_idx+2:end,2)==100,1,'first') + block_idx + 1;
            events_1mv = events(block_idx:block_end,:);
            events_1mv(events==6)=4;
            stim_spikes_1mv = ah_build_spikes_array(spikes,events_1mv,4,[-2 1],4);
            numTrials_1mv = length(stim_spikes_1mv);
            blocks = [blocks 1];
        end
        
        %% Get and sort spikes
        spike_6mv = sort(cell2mat(stim_spikes_6mv));
%         spike_4mv = sort(cell2mat(stim_spikes_4mv));
%         spike_2mv = sort(cell2mat(stim_spikes_2mv));
%         spike_1mv = sort(cell2mat(stim_spikes_1mv));
        
        all_spikes = {0, 0, 0, spike_6mv};
%         num_trials = [numTrials_1mv, numTrials_2mv, numTrials_4mv, numTrials_6mv];

        %% Begin analysis
        trial_start_time = -2;
        stim_start_time = 0;
        baseline_duration = stim_start_time - trial_start_time;
        window_start = 0;
        window_end = .5;
        window_duration = window_end - window_start;
        for spikes_idx = 4 %1:length(all_spikes)
            spikes = all_spikes{spikes_idx};   
            num_trials = length(stim_spikes_6mv);
            baseline_firing_rate = sum(spikes >= -2 & spikes < stim_start_time) / baseline_duration / num_trials;
            overall_firing_rate = length(spikes) / 3 / num_trials;

            %% MSW
            MSW = twdb(idx).mean_spike_waveform;
            dif = zeros(1,size(MSW,1));
            for i=1:size(MSW,1)
                dif(i) = max(MSW(i,:)) - min(MSW(i,:));%Highest difference between peak and valley
            end
            [~,I] = max(dif);%Index for closest recording
            MSW = MSW(I,:);
            
            % Calculate peak to valley length normally
            [~, I_M] = max(MSW);
            [~, I_m] = min(MSW(I_M:end)); I_m = I_M + I_m;
            normal_peakToValley_length = (I_m-I_M)/150;
            % Calculate peak to valley length of neuron with dendritic spike
            [~, I_m] = min(MSW(1:I_M));
            if MSW(I_m) > -5
                abnormal_peakToValley_length = NaN;
            else
                abnormal_peakToValley_length = (I_M-I_m)/150;
            end
            
            %% SNR
            % Process dendritic spikes?
            if dendritic_filter
                % Calculate true peak to valley length
                if ~isnan(normal_peakToValley_length) && abnormal_peakToValley_length < normal_peakToValley_length
                    peakToValley_length = abnormal_peakToValley_length;
                else
                    peakToValley_length = normal_peakToValley_length;
                end
            else
                peakToValley_length = normal_peakToValley_length;
            end
            
            % Max peak height filter
            if max(MSW) < min_peak_height
                continue;
            end
            
            % Final michael grade filter
            if ~(twdb(idx).final_michael_grade >= min_final_michael_grade)
                continue;
            end
            
            % Firing rate filter
            if overall_firing_rate < min_firing_rate && baseline_firing_rate < min_firing_rate
                continue;
            end
            %% Find stimulated ids
            if strcmp(type, 'peak')
                baseline_spikes_in_stimulation_time = sum(spikes >= -2 & spikes < stim_start_time) * window_duration / baseline_duration;
                stimulation_spikes = sum(spikes >= window_start & spikes <= window_end);
                p = poisscdf(stimulation_spikes,baseline_spikes_in_stimulation_time,'upper');
                
                if p < p_threshold
                    peakToValley_lengths = [peakToValley_lengths peakToValley_length];
                    firing_rates = [firing_rates baseline_firing_rate];
                    peak_heights = [peak_heights max(MSW)];
                    MSWs = [MSWs; MSW];
                    stimulated_ids = [stimulated_ids idx];
                end
            end
            %% Find inhibited ids
            if strcmp(type, 'trough')
                baseline_spikes_in_stimulation_time = sum(spikes >= -2 & spikes < stim_start_time) * window_duration / baseline_duration;
                stimulation_spikes = sum(spikes >= window_start & spikes <= window_end);
                p = poisscdf(stimulation_spikes,baseline_spikes_in_stimulation_time);
                
                if p < p_threshold
                    peakToValley_lengths = [peakToValley_lengths peakToValley_length];
                    firing_rates = [firing_rates baseline_firing_rate];
                    peak_heights = [peak_heights max(MSW)];
                    MSWs = [MSWs; MSW];
                    inhibited_ids = [inhibited_ids idx];
                end
            end
            
            %% Debug plot
            if debug
                figure(f); subplot(2,2,1);
                bin_size = .005;
                bins = -2:bin_size:1;
                binned_spikes = histcounts(spikes, bins) / bin_size / num_trials;
                bar(bins(1:end-1)+bin_size/2, binned_spikes);
                line([0 0], [0 max(binned_spikes)], 'LineWidth', 2, 'Color', 'black');
                xlim([-.1 .1]);
                
                figure(f); subplot(2,2,2);
                bin_size = .05;
                bins = -2:bin_size:1;
                binned_spikes = histcounts(spikes, bins) / bin_size / num_trials;
                bar(bins(1:end-1)+bin_size/2, binned_spikes);
                line([0 0], [0 max(binned_spikes)], 'LineWidth', 2, 'Color', 'black');
                line([.5 .5], [0 max(binned_spikes)], 'LineWidth', 2, 'Color', 'black');                
                xlim([-1 1]);
                
                subplot(2,2,3); plot(MSW);
                supertitle({['idx: ' num2str(idx)], ...
                    ['sessionID: ' twdb(idx).sessionID], ...
                    ['peak to valley length: ' num2str(peakToValley_length)], ...
                    ['firing rate: ' num2str(baseline_firing_rate)]});
                
                fig_dir = [ROOT_DIR 'PV Experiment/Examples/'];
                if ~exist(fig_dir, 'dir')
                    mkdir(fig_dir);
                end
                saveas(f, [fig_dir type], 'fig');
                saveas(f, [fig_dir type], 'epsc2');
                saveas(f, [fig_dir type], 'jpg');
            end
        end
        
        disp(idx);
    end
end