function connectivities = pairs_gc(twdbs, dbs, comparison_type, all_pairs, min_time, max_time, bin_size, window_size, window_shift_size, type)

%% Calculate GC connectivities...
num_windows = floor(((max_time-window_size) - min_time) / window_shift_size);
%by default num_windows = 37
connectivities = cell(1,num_windows+1);
%connectivities is 1x38
for window_idx = 0:num_windows
    disp(window_idx);
    % Get bins
    window_start = min_time;
    window_start = window_start + window_idx*window_shift_size;
    window_end = window_start + window_size;
    bins = window_start:bin_size:window_end;
    
    connectivities{window_idx+1} = cell(1,length(dbs));
    gcs = cell(1,length(dbs));
    for db = 1:length(dbs)
        gcs{db} = zeros(1,size(all_pairs{db},1));
        for pair_num = 1:size(all_pairs{db},1)
            % Get spikes
            pls_idx = all_pairs{db}(pair_num,1);
            strio_idx = all_pairs{db}(pair_num,2);
            if strcmp(type,'spikes')
                pls_spikes = twdbs{db}(pls_idx).trial_spikes;
                strio_spikes = twdbs{db}(strio_idx).trial_spikes;
            elseif strcmp(type, 'bursts')
                smooth_factor = 3;
                min_ISIs_per_neuron = 15;
                min_time_tmp = window_start; max_time_tmp = window_end;
                ah_bursts = [];
                method = 'Tim';
                debug_thresholds = false;
                
                pls_spikes_tmp = twdbs{db}(pls_idx).trial_spikes;
                num_trials = length(pls_spikes_tmp);
                pls_phasic_periods = find_phasic_periods(pls_spikes_tmp, smooth_factor, min_ISIs_per_neuron, min_time_tmp, max_time_tmp, ah_bursts, method, debug_thresholds);
                if ~iscell(pls_phasic_periods)
                    pls_spikes = cell(num_trials,1);
                else
                    pls_spikes = cell(num_trials,1); 
                    for trial_num = 1:num_trials
                        if isempty(pls_phasic_periods{trial_num})
                            continue;
                        else
                            burst_window = pls_phasic_periods{trial_num};
                            trial_spikes = pls_spikes_tmp{trial_num};
                            pls_spikes{trial_num} = trial_spikes(trial_spikes >= burst_window(1) & trial_spikes <= burst_window(2));
                        end
                    end
                    
                end
                
                strio_spikes_tmp = twdbs{db}(strio_idx).trial_spikes;
                num_trials = length(strio_spikes_tmp);
                strio_phasic_periods = find_phasic_periods(strio_spikes_tmp, smooth_factor, min_ISIs_per_neuron, min_time_tmp, max_time_tmp, ah_bursts, method, debug_thresholds);
                if ~iscell(strio_phasic_periods)
                    strio_spikes = cell(num_trials,1);
                else
                    strio_spikes = cell(num_trials,1); 
                    for trial_num = 1:num_trials
                        if isempty(strio_phasic_periods{trial_num})
                            continue;
                        else
                            burst_window = strio_phasic_periods{trial_num};
                            trial_spikes = strio_spikes_tmp{trial_num};
                            strio_spikes{trial_num} = trial_spikes(trial_spikes >= burst_window(1) & trial_spikes <= burst_window(2));
                        end
                    end
                    
                end
            end
            
            % Bin spikes in bins
            pls_spikes_binned = cell2mat(cellfun(@(x) histcounts(x,bins),pls_spikes,'uni',false)');
            strio_spikes_binned = cell2mat(cellfun(@(x) histcounts(x,bins),strio_spikes,'uni',false)');
            
            % Get connectivity
            X = [pls_spikes_binned;strio_spikes_binned];
            GC = granger_causality(X,false);
            connectivity = GC(1,2);
            gcs{db}(pair_num) = connectivity;
        end
        connectivities{window_idx+1}{db} = [connectivities{window_idx+1}{db}; gcs{db}];
    end
end
fig_dir = ['./Granger Causality/' comparison_type '/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir);
end
save([fig_dir 'T_' comparison_type '_BS_' num2str(bin_size*1000) '_WS_' num2str(window_size*1000) '_WSS_' num2str(window_shift_size*1000) '_' type '.mat'], 'connectivities');

%% Get means
threshold = 0.005;
means = cell(1,length(dbs));
for window_idx = 0:num_windows
    for db = 1:length(dbs)
%         means{db} = [means{db} mean(connectivities{window_idx+1}{db})];
        means{db} = [means{db} sum(connectivities{window_idx+1}{db}>threshold)/length(connectivities{window_idx+1}{db})];
    end
end
%% Plot
means = cell2mat(means');
f=figure;
plot(min_time:min_time+window_shift_size*num_windows,smooth(means(1,:),1),...
     min_time:min_time+window_shift_size*num_windows,smooth(means(2,:),1),...
     min_time:min_time+window_shift_size*num_windows,smooth(means(3,:),1),'LineWidth',2);
legend('Control','Stress','Stress2');
line([-3 -3],[0 1],'Color','black','LineWidth',2);
title(comparison_type);
saveas(f, [fig_dir 'T_' comparison_type '_BS_' num2str(bin_size*1000) '_WS_' num2str(window_size*1000) '_WSS_' num2str(window_shift_size*1000) '_' type],'fig');
saveas(f, [fig_dir 'T_' comparison_type '_BS_' num2str(bin_size*1000) '_WS_' num2str(window_size*1000) '_WSS_' num2str(window_shift_size*1000) '_' type],'epsc2');
saveas(f, [fig_dir 'T_' comparison_type '_BS_' num2str(bin_size*1000) '_WS_' num2str(window_size*1000) '_WSS_' num2str(window_shift_size*1000) '_' type],'jpg');
end