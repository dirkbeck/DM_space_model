function sqr_responder_twdb(twdbfile)

twdb = load(twdbfile);
twdb = twdb.twdb;
for neuron_idx = 1:length(twdb)
    unitnum = str2double(twdb(neuron_idx).neuronN);
    output = load(twdb(neuron_idx).clusterDataLoc);
    output = output.output;
    spikes = output(output(:,2)==unitnum,1);
    evtFileLoc = [twdb(neuron_idx).sessionDir, '\events2.nev'];  %events file location
    try
        [TS, TTL] = dg_readEvents(evtFileLoc);
    catch
        twdb(neuron_idx).laser_stimulation_trend = 'None';
        twdb(neuron_idx).laser_stimulation_pValue = -1;
        twdb(neuron_idx).sqr_neuron_type = -1;
        twdb(neuron_idx).FiringRate = -1;
        twdb(neuron_idx).MeanMedianRatio = -1;
        twdb(neuron_idx).HalfPeakTime = -1;
    end
    events = [TS', TTL'];
    block1_spikes_array = ah_build_spikes_array(spikes, events, 301, [.003 .02], 301);
    numTrials = length(block1_spikes_array);
    block1_dist = zeros(numTrials,1);
    block3_spikes_array = ah_build_spikes_array(spikes, events, 303, [.003 .02], 303);
    block3_dist = zeros(numTrials,1);
    
    if numTrials == length(block3_spikes_array)
        for trial_idx = 1:numTrials
            block1_dist(trial_idx) = length(block1_spikes_array{trial_idx});
            block3_dist(trial_idx) = length(block3_spikes_array{trial_idx});
        end
    end
    
    if sum(block1_dist) > sum(block3_dist)
        trend = 'Down';
    elseif sum(block1_dist) < sum(block3_dist)
        trend = 'Up';
    else
        trend = 'None';
    end
    
    [~,pValue] = ttest2(block1_dist, block3_dist);
    
    twdb(neuron_idx).laser_stimulation_trend = trend;
    twdb(neuron_idx).laser_stimulation_pValue = pValue;
    
    sessionDir = twdb(neuron_idx).sessionDir;
    tetrodeLoc = twdb(neuron_idx).clusterDataLoc;
    tetrodeID = tetrodeLoc(length(sessionDir)+2:length(tetrodeLoc)-4);
    [Type, HalfPeakTime, MeanMedianRatio, FiringRate]=sqr_singleNeuronType(sessionDir, tetrodeID, unitnum, 'D:\UROP\ah_lib\FINAL_FUNCTIONS\interneurons\neuronTypeData.mat');
    twdb(neuron_idx).sqr_neuron_type=Type;
    twdb(neuron_idx).FiringRate=FiringRate;
    twdb(neuron_idx).MeanMedianRatio=MeanMedianRatio;
    twdb(neuron_idx).HalfPeakTime=HalfPeakTime;
end
save(twdbfile, 'twdb')

