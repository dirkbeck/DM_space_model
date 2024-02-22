function ah_striosomality2_grade_twdb(twdbfile)
% ah_striosomality2_grade_twdb gives every neuron in a given database
%   three parameters to determine the strength of its response to DMS
%   stimulation. Input is the location of the twdb file, function will
%   open, update, and save twdb file.
twdb = load(twdbfile);      %Load TWDB file
twdb = twdb.twdb;
for i = 1:length(twdb)
    evtFileLoc = [twdb(i).sessionDir, '\events6.EVTSAV'];  %Location of event file
    if exist(evtFileLoc, 'file')
        load(evtFileLoc, '-mat')                            %Load events file
        training_data = 0;
    else
        evtFileLoc = [twdb(i).sessionDir, '\events2.nev'];
        if exist(evtFileLoc, 'file')
            [TS, TTLS] = dg_readEvents(evtFileLoc);
            TS = TS/1000000;
            lfp_save_events = [TS' TTLS'];
            training_data = 1;
        else
            twdb(i).striosomality2_type = -1;          %update TWDB
            twdb(i).striosomality2_grade = NaN;
            twdb(i).striosomality2_data = [];
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
    unitnum = str2double(twdb(i).neuronN);                      %neuron number
    
    load(twdb(i).clusterDataLoc)                                %load tetrode spikes
    spikes = output(output(:,2)==unitnum,1);                    %isolate neuron spikes
    
    try
        resp_spikes = ah_build_spikes_array(spikes,events,stim_event,[-1 1],stim_event);   %stimulation response spikes
        [~,baseline_firing_rate] = ah_build_spikes_array(spikes,events,stim_event,[-1 0],stim_event); %get baseline firing rate
    catch               % No stimulation trials
        twdb(i).striosomality2_type = -1;         
        twdb(i).striosomality2_grade = NaN;
        twdb(i).striosomality2_data = [];
        continue;
    end
    [type, grade, data] = ah_striosomality2(cell2mat(resp_spikes),baseline_firing_rate*length(resp_spikes));    %run spikes through striosomality grade function
    twdb(i).striosomality2_type = type;          %update TWDB
    twdb(i).striosomality2_grade = grade;
    twdb(i).striosomality2_data = data;
    i
end
save(twdbfile, 'twdb')
end