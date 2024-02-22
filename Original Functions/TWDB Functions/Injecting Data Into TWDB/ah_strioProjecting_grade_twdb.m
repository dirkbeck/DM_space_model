function ah_strioProjecting_grade_twdb(twdbfile)
% ah_strioProjecting_grade_twdb gives every neuron in a given database
%   three parameters to determine the strength of its response to DMS
%   stimulation. Input is the location of the twdb file, function will
%   open, update, and save twdb file.

twdb = load(twdbfile);
twdb = twdb.twdb;                   %Load TWDB file
for i = 1:length(twdb)              %Loop through neurons
    evtFileLoc = [twdb(i).sessionDir, '\events6.EVTSAV'];   %Location of event file
    evt_id = 0;                                             
    if ismember(twdb(i).ratID, {'matrix13', 'rat1', 'rat2', 'rat4'})
        evt_id = 4;                                         %With these rats, stimulation event is 4
    elseif ismember(twdb(i).ratID, {'rat5', 'rat11', 'rat13'})
        evt_id = 6;                                         %With these rats, stimulation event is 6
    end
    load(evtFileLoc, '-mat')                                %Load events file
    block_idx = find(lfp_save_events(:,2)==43);             %Locate DMS stimulation block
    if isempty(block_idx) || ~evt_id                        %Skip if no DMS stimulation block, insert -1s as filler
        twdb(i).strio_projecting_spikes = -1;
        twdb(i).strio_projecting_area = -1;
        twdb(i).strio_projecting_grade = -1;
        continue;
    end
    block_end = find(lfp_save_events(block_idx+2:end,2)==100,1,'first') + block_idx + 1;    %End of DMS stimulation block
    events = lfp_save_events(block_idx:block_end,:);                                        %events array to use
    unitnum = str2double(twdb(i).neuronN);              %unit number
    
    load(twdb(i).clusterDataLoc)                        %load tetrode spikes
    spikes = output(output(:,2)==unitnum,1);            %select neuron spikes
    
    pls_spikes = ah_build_spikes_array(spikes,events,evt_id,[.001 .01],evt_id);     %create spikes array aligned to DMS stimulation event
    numTrials = length(pls_spikes);                     %number of stimulations
    pls_spikes = sort(cell2mat(pls_spikes));            %just need array of spikes, don't care about trials
    [~,baseline_firing_rate] = ah_build_spikes_array(spikes,events,evt_id,[-1 0],evt_id);   %get baseline firing rate
    
    numSpikes = length(pls_spikes);                     %number of spikes
    area = numSpikes - baseline_firing_rate*numTrials*.009; %area of response in 1-10ms window
    grade = numSpikes/(baseline_firing_rate*numTrials*.009);%grade response (relative to baseline firing rate
    if grade > 1000                                         %limit size of grade
        grade = 1000;
    elseif grade < 0 || isnan(grade)
        grade = 0;
    end
    twdb(i).strio_projecting_spikes = numSpikes;        %update TWDB
    twdb(i).strio_projecting_area = area;
    twdb(i).strio_projecting_grade = grade;
    %To keep track of progress of function
    i
end
save(twdbfile, 'twdb')
end