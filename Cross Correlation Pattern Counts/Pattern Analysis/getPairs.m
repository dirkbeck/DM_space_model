function[all_pairs] = getPairs(dbs,neuron_1,neuron_2,sessionDir_neurons)
all_pairs = cell(1,length(dbs));
for db = 1:length(dbs)
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        all_pairs{db} = [all_pairs{db}; allcomb(neuron_1{db}{sessionDir_idx},neuron_2{db}{sessionDir_idx})];

    end
end
end