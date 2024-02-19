% ah_striosomality2_grade_twdb_stress2 gives every neuron in a given database
%   three parameters to determine the strength of its response to DMS
%   stimulation. Input is the location of the twdb_stress2 file, function will
%   open, update, and save twdb_stress2 file.
for i = 1:length(twdb_stress2)
    evtFileLoc = [twdb_stress2(i).sessionDir, '\events6.EVTSAV'];  %Location of event file
    evtFileLoc = strrep(evtFileLoc,'/Users/Seba/Dropbox/UROP/stress_project','C:/Users/TimT5/Dropbox (MIT)/cell');

    if exist(evtFileLoc, 'file')
        load(evtFileLoc, '-mat')                            %Load events file
        training_data = 0;
    else
        evtFileLoc = [twdb_stress2(i).sessionDir, '\events2.nev'];
        if exist(evtFileLoc, 'file')
            [TS, TTLS] = dg_readEvents(evtFileLoc);
            TS = TS/1000000;
            lfp_save_events = [TS' TTLS'];
            training_data = 1;
        else
            twdb_stress2(i).striosomality2_type = -1;          %update twdb_stress2
            twdb_stress2(i).striosomality2_grade = NaN;
            twdb_stress2(i).striosomality2_data = [];
            continue;
        end
    end
    if ~training_data
        block_idx = find(lfp_save_events(:,2)==42);             %Find PL stimulation block; if not found, skip neuron
        if ~isempty(block_idx)
            block_end = find(lfp_save_events(block_idx+2:end,2)==100,1,'first') + block_idx - 1;    %End of PL stimulation block
            events = lfp_save_events(block_idx:block_end,:);            %events array
        else
            events = lfp_save_events;
        end
        stim_event = 4;
    else
        events = lfp_save_events;
        stim_event = 301;
    end
    unitnum = str2double(twdb_stress2(i).neuronN);                      %neuron number
    
    clusterDataLocation = twdb_stress2(i).clusterDataLoc;
    clusterDataLocation = strrep(clusterDataLocation,'/Users/Seba/Dropbox/UROP/stress_project','C:/Users/TimT5/Dropbox (MIT)/cell');
    load(clusterDataLocation)                                %load tetrode spikes
    spikes = output(output(:,2)==unitnum,1);                    %isolate neuron spikes
    
    try
        resp_spikes = ah_build_spikes_array(spikes,events,stim_event,[-1 1],stim_event);   %stimulation response spikes
        [~,baseline_firing_rate] = ah_build_spikes_array(spikes,events,stim_event,[-1 0],stim_event); %get baseline firing rate
    catch               % No stimulation trials
        twdb_stress2(i).striosomality2_type = -1;         
        twdb_stress2(i).striosomality2_grade = NaN;
        twdb_stress2(i).striosomality2_data = [];
        twdb_stress2(i).striosomality2_spikes_array= []; 
        continue;
    end
    [type, grade, data] = ah_striosomality2(cell2mat(resp_spikes),baseline_firing_rate*length(resp_spikes));    %run spikes through striosomality grade function
    twdb_stress2(i).striosomality2_type = type;          %update twdb_stress2
    twdb_stress2(i).striosomality2_grade = grade;
    twdb_stress2(i).striosomality2_data = data;
    twdb_stress2(i).striosomality2_spikes_array= resp_spikes;
    disp(i);
%     disp(twdb_stress2(i).striosomality2_spikes_array);
end