% Load the 'twdb_control.mat' data file.

PAIRS_MATRIX_IDX = 20;
PAIRS_STRIO_IDX = 1;
BIN_TIME = 1;

pairs_matrix = load('selected_matrix_pairs');
pairs_strio = load('selected_strio_pairs');
pairs_matrix = pairs_matrix.T;
pairs_strio = pairs_strio.T;

pair_matrix = pairs_matrix(PAIRS_MATRIX_IDX,:);
swn_idx = pair_matrix.swn_index;
connected_strio = pairs_strio([pairs_strio.swn_index] == swn_idx,:);
msn_idx_strio = connected_strio{PAIRS_STRIO_IDX, 'msn_index'};

swn_spikes = twdb_control(swn_idx).trial_spikes;
msn_spikes_matrix = twdb_control(pair_matrix.msn_index).trial_spikes;
msn_spikes_strio = twdb_control(msn_idx_strio).trial_spikes;

figure
plot_dynamics(swn_spikes, msn_spikes_strio, msn_spikes_matrix, BIN_TIME, BIN_TIME);


