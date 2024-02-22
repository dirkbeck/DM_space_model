function sqr_neuronType_grade_twdb(twdbfile, neuronTypeDataFile)

load(twdbfile)
for neuron_idx = 1:length(twdb)
    sessionDir = twdb(neuron_idx).sessionDir;
    tetrode = twdb(neuron_idx).tetrodeID;
    cellnum = str2double(twdb(neuron_idx).neuronN);
    neuron_type = sqr_singleNeuronType(sessionDir, tetrode, cellnum, neuronTypeDataFile);
    twdb(neuron_idx).sqr_neuron_type = neuron_type;
end
save(twdbfile, 'twdb')
end