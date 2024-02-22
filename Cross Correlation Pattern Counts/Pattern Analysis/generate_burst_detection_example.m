%% This script generates a visualization showing how bursts are detected.
%  It shows two steps:
%   1. Calculation of distribution of neuron ISIs, from which we can
%   determine a threshold ISI. Consectuive spikes with ISIs below the
%   threshold ISI are considred bursts. 
%   2. Plots showing the thresholding process descrbied in (1).


%look for where find_phasic_periods
%look for generate_time_delay

% Setup some parameters for the burst detection algorithm.
debug_thresholds = true;
fig_dir = [ROOT_DIR 'Algorithm Visualizations/'];
min_ISIs_per_neuron = 15;          % minimum number of ISIs needed to find phasic periods
min_time = -3; max_time = 2.5;     % (Trial time period) to look for time delays; ie. look from -3s to 2.5s for pls bursts and striosome bursts after those pls bursts    
db = 3; pair_num = 7;
twdb = twdbs{db};
pls_id = all_pairs{db}(pair_num,1);
strio_id = all_pairs{db}(pair_num,2);
pls_spikes = twdb(pls_id).trial_spikes;        ah_pls_bursts = twdb(pls_id).trial_bursts;
strio_spikes = twdb(strio_id).trial_spikes;    ah_strio_bursts = twdb(strio_id).trial_bursts;

% Find and visualize burst detection
smooth_factor = 3; % For finding thresholds
pls_bursts = find_phasic_periods(pls_spikes, smooth_factor, min_ISIs_per_neuron, min_time, max_time, ah_pls_bursts, method, debug_thresholds, fig_dir);
