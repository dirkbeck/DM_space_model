function[all_pairs] = getPairs_random(dbs,neuron_1,neuron_2,sessionDir_neurons)
all_pairs = cell(1,length(dbs));
for db = 1:length(dbs)
    for sessionDir_idx = 1:length(sessionDir_neurons{db})-1
        all_pairs{db} = [all_pairs{db}; allcomb(neuron_1{db}{sessionDir_idx},neuron_2{db}{end-sessionDir_idx})];
        %by doing end-sessionDir_indx in the end of line 5 we ensure that the neurons will not have the same session id

    end
end
end