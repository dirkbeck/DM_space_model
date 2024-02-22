%% Inject neuron type data into database
%% Load databases if necessary
if ~exist('loaded','var')
    addpath(genpath('./'),'-end');
    load('twdbs.mat');
    fig_dir = './Control figures/';
    dbs = {'control', 'stress', 'stress2'};
    loaded = true;
end
dbs = {'control', 'stress', 'stress2'}; twdbs = {twdb_control, twdb_stress, twdb_stress2}; % Databases to loop through
clearvars -except min_num twdb_control twdb_stress twdb_stress2 fig_dir dbs loaded dbs twdbs

for db = 1:length(dbs)
    [types, valley_widths, half_peak_widths, peakToValley_lengths, sqr_neuron_types] = ...
        arrayfun(@(x) neuron_type(twdbs{db},x), 1:length(twdbs{db}),'uni',false);
    
    for neuron_idx = 1:length(twdbs{db})
        twdbs{db}(neuron_idx).neuron_type = types{neuron_idx};
        twdbs{db}(neuron_idx).valley_width = valley_widths{neuron_idx};
        twdbs{db}(neuron_idx).half_peak_width = half_peak_widths{neuron_idx};
        twdbs{db}(neuron_idx).peakToValley_length = peakToValley_lengths{neuron_idx};
    end
end
twdb_control = twdbs{1}; twdb_stress = twdbs{2}; twdb_stress2 = twdbs{3};

save('twdbs.mat','twdb_control', 'twdb_stress', 'twdb_stress2');