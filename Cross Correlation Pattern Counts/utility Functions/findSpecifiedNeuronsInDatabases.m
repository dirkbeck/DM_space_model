function [matrix_neurons,strio_neurons] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,neuron_1_ids,neuron_2_ids)
matrix_neurons = cell(1,length(dbs));
strio_neurons = cell(1,length(dbs));
for db = 1:length(dbs)
    matrix_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    strio_neurons{db} = cell(1,length(sessionDir_neurons{db}));

    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        matrix_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[neuron_1_ids{db}]);
        strio_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[neuron_2_ids{db}]);
    end
end

end