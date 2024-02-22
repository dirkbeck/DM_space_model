%% This script analyzes the probability of a striosomal burst in response to
%  a PLs Neuron burst as a function of SWN firing rate. Specifically, it
%  analyzes the behaviour in 3 different time periods - baseline, in task,
%  and lick for a particular triplet of neurons. The triplet of neurons was
%  identified by looking at all possible triplets, and seeing if any
%  triplet exhibited a difference in response probability as a function of
%  SWN firing rate.
ROOT_DIR = '../Final Stress Figures/';

% twdbs_dir = ['C:\Users\ldd77' filesep 'Downloads' filesep 'twdbs.mat'];
% twdbs = load(twdbs_dir);
% 
% twdb_control = twdbs.twdb_control;
% twdb_stress = twdbs.twdb_stress;
% twdb_stress2 = twdbs.twdb_stress2;
% 
% 
% dbs = {'control', 'stress', 'stress2'}; twdbs = {twdb_control, twdb_stress, twdb_stress2}; % Databases to loop through

[cb_pls_ids, cb_plNotS_ids, cb_strio_ids, cb_matrix_ids, ...
           cb_swn_ids, cb_swn_not_hfn_ids, cb_hfn_ids] ...
           = find_neuron_ids(twdbs, 'CB', [-Inf,-Inf,-Inf,-Inf,1]);

%% Find all sessions
sessionDirs = cell(1,length(dbs));
sessionDir_neurons = cell(1,length(dbs)); % Neurons #s for each session
for db = 1:length(dbs)
    sessionDirs{db} = {twdbs{db}.sessionDir};
    
    [~,unique_sessionDir_idxs,~] = unique(sessionDirs{db});
    sessionDir_neurons{db} = cell(1,length(unique_sessionDir_idxs));
    for idx = 1:length(unique_sessionDir_idxs)
        sessionDir_neurons{db}{idx} = ...
            find(strcmp({twdbs{db}.sessionDir},sessionDirs{db}{unique_sessionDir_idxs(idx)}));
    end
    
    sessionDirs{db} = sessionDirs{db}(unique_sessionDir_idxs);
    for session_num = 1:length(sessionDirs{db})
        sessionDirs{db}{session_num} = strrep(sessionDirs{db}{session_num},'/Users/Seba/Dropbox/UROP/stress_project','C:/Users/TimT5/Dropbox (MIT)/cell');
        sessionDirs{db}{session_num} = strrep(sessionDirs{db}{session_num},'D:\UROP','C:/Users/TimT5/Dropbox (MIT)/cell/Cell Figures and Data/Data');
    end
end
%% Triplets
pls_neurons = cell(1,length(dbs));
strio_neurons = cell(1,length(dbs));
swn_neurons = cell(1,length(dbs));
for db = 1:length(dbs)
    pls_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    strio_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    swn_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        pls_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},cb_pls_ids{db});
        strio_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},cb_strio_ids{db});
        swn_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},cb_swn_ids{db});
    end
end
%%
periods = {'Baseline', 'In Task', 'Lick'};
for db = 1:length(dbs)
    for sessionDir_idx = 1:length(pls_neurons{db})
        pls_neuron_ids = pls_neurons{db}{sessionDir_idx};
        strio_neuron_ids = strio_neurons{db}{sessionDir_idx};
        swn_neuron_ids = swn_neurons{db}{sessionDir_idx};
        
        for pls_idx = 1:length(pls_neuron_ids)
            for strio_idx = 1:length(strio_neuron_ids)
                for swn_idx = 1:length(swn_neuron_ids)
                    pls_id = pls_neuron_ids(pls_idx);
                    strio_id = strio_neuron_ids(strio_idx);
                    swn_id = swn_neuron_ids(swn_idx);
                    disp(db);
                    for period_idx = 1:length(periods)
                        period = periods{period_idx};
                        if strcmp(period, 'Baseline')
                            min_time = -10; max_time = -3;
                        elseif strcmp(period, 'In Task')
                            min_time = -3; max_time = 2.5;
                        elseif strcmp(period, 'Lick')
                            min_time = 2.5; max_time = 10;
                        end
                        
                        % Identify ISIs
                        smooth_factor = 3;
                        min_ISIs_per_neuron = 0;
                        method = 'Tim';
                        debug_thresholds = false;
                        min_delay = .004; max_delay = .5;
                        debug = false;
                        probability_FRs = [];
                        sizes = [47 ,242, 204];
                        
                        % Identify bursts per trial
                        pls_spikes = twdbs{db}(pls_id).trial_spikes;
                        strio_spikes = twdbs{db}(strio_id).trial_spikes;
                        swn_spikes = twdbs{db}(swn_id).trial_spikes;
                        for trial_idx = 1:length(pls_spikes)
                            pls_bursts = find_phasic_periods(pls_spikes(trial_idx), smooth_factor, min_ISIs_per_neuron, min_time, max_time, false, method, debug_thresholds);
                            strio_bursts = find_phasic_periods(strio_spikes(trial_idx), smooth_factor, min_ISIs_per_neuron, min_time, max_time, false, method, debug_thresholds);
                            
                            if ~iscell(pls_bursts) || ~iscell(strio_bursts)
                                continue;
                            end
                            
                            [phasic_time_delays, FR_pairs, response_probability] = find_phasic_time_delays(pls_spikes(trial_idx), strio_spikes(trial_idx), pls_bursts, strio_bursts, ...
                                min_delay, max_delay, min_time, max_time, debug);
                            
                            if isnan(response_probability)
                                continue;
                            end
                            
                            swn_FR = sum(swn_spikes{trial_idx} > min_time & swn_spikes{trial_idx} < max_time) / (max_time - min_time);
                            probability_FRs = [probability_FRs; response_probability, swn_FR];
                        end
                        %% Figure Directory
                        fig_dir = [ROOT_DIR '/Temp/' period '/'];
                        if ~exist(fig_dir, 'dir')
                            mkdir(fig_dir);
                        end
                        %% Make figure
                        f = figure;
                        num_bins = 10;
                        if isempty(probability_FRs)
                            continue;
                        end
                        m = min(probability_FRs(:,2)); M = max(probability_FRs(:,2));
                        bin_size = (M-m)/num_bins;
                        bin_start = m; bin_end = bin_start + bin_size;
                        mean_resp_p = [];
                        for bin_idx = 1:num_bins
                            total = 0;
                            count = 0;
                            for idx = 1:size(probability_FRs,1)
                                if probability_FRs(idx,2) >= bin_start && probability_FRs(idx,2) < bin_end
                                    if ~isnan(probability_FRs(idx,1))
                                        total = total + probability_FRs(idx,1);
                                        count = count + 1;
                                    end
                                end
                            end
                            mean_resp_p = [mean_resp_p, total/count];
                            
                            bin_start = bin_start + bin_size;
                            bin_end = bin_end + bin_size;
                        end
                        bins = linspace(m,M,num_bins+1);
                        bins = bins(1:end-1) + bin_size/2;
                        hold on;
                        plot(bins, mean_resp_p, 'blue', 'LineWidth',1);
                        scatter(bins, mean_resp_p, 'blue', 'filled');
                        hold off;
%                         xlim([10 22]); ylim([0 .7]);
                        xlabel('SWN Firing Rate (Hz)'); ylabel('Probability of Striosome Burst Given PLS Burst');
                        title([period ' Triplet']);
                        saveas(f, [fig_dir num2str(db) ' _' num2str(pls_id) '_' num2str(strio_id) '_' num2str(swn_id)], 'fig');
                        saveas(f, [fig_dir num2str(db) ' _' num2str(pls_id) '_' num2str(strio_id) '_' num2str(swn_id)], 'epsc2');
                        saveas(f, [fig_dir num2str(db) ' _' num2str(pls_id) '_' num2str(strio_id) '_' num2str(swn_id)], 'jpg');
                        close all;
                    end
                end
            end
        end
    end
end