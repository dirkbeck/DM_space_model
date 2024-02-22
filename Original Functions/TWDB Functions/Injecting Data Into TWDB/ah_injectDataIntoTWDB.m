function ah_injectDataIntoTWDB(base_twdbfile, new_twdbfile, laser)
%AH_INJECTDATAINTOTWDB injects, for all neurons in base_twdbfile (except
%for those that could cause errors), various data relevant to the
%burst-based and spike-based analysis, and saves the new twdb file as
%new_twdbfile. Note that it is CRUCIAL that we preserve a base twdbfile -
%for the sake of debugging and such it might be necessary to recreate the
%twdbfile again and again, and it always should be built from the base
%twdbfile to avoid (1) errors (2) confusion and (3) giant twdbfiles (as it
%is, the data being injected takes up a lot of space). Inputs are
%self-explanatory; this function has no outputs, it merely saves the new
%twdbfile in the specified location.
% Laser input tells functions whether or not this is a laser TWDB file, and
% that we should look for the post laser block.
if ~exist('laser', 'var')
    laser = 0;
end

twdb = load(base_twdbfile); %load base twdb file
twdb = twdb.twdb;
count = 0;                  %to keep track of our progress
for neuron_idx = 1:length(twdb)     %loop through all neurons
    twdb(neuron_idx).index = num2str(neuron_idx);               %set index of neuron in twdb
    evtFileLoc = [twdb(neuron_idx).sessionDir, '\events6.EVTSAV'];  %events file location
    load(evtFileLoc, '-mat')                                    %load event file
    if twdb(neuron_idx).laser
        idx = find(lfp_save_events(:,2)==97);
        if laser
            events = lfp_save_events(idx:end,:);
        else
            events = lfp_save_events(1:idx,:);
        end
    else
        events = lfp_save_events;
    end
    unitnum = str2num(twdb(neuron_idx).neuronN);                %unit number in tetrode of current neuron
    load(twdb(neuron_idx).clusterDataLoc)                       %load spike data
    spikes = output(output(:,2)==unitnum,1);                    %spikes array
    %array of spikes that we wish to save
    spikes_array = ah_build_spikes_array(spikes, events, 8, [-20 20], 31);
    %relevant firing rate data from the baseline
    [~,baseline_mean_firing_rate,baseline_std_firing_rate] = ah_build_spikes_array(spikes, events, 31, [-20 0], 31);
    %array of all bursts that we wish to save as well as baseline firing rate data
    [bursts_array, baseline_burst_mean_firing_rate, baseline_burst_std_firing_rate] = ah_build_bursts_array(spikes, events, 8, 31, [-20 20], 20);
    %timings of events within session. Technically need only be computed
    %once per session, but computation time is trivial in comparison to
    %other functions, thus it shouldn't really matter. In particular, there
    %are other inefficiencies built into this code that are much more
    %difficult to eliminate that are also much more costly
    ses_evt_timings = ah_get_ses_evt_timings(events, {8, [1010 2020], [2011 1001], [557 558 559], 31}, 8, 31);
    if length(spikes)
        first_spike_time = spikes(1);  %timing of first spike of neuron
        last_spike_time = spikes(end); %timing of last spike of neuron
        numSpikes = length(spikes);    %number of spikes in neuron
    else
        numSpikes = 0;
    end
    neuron_firing_rate = numSpikes/(last_spike_time - first_spike_time);    %firing rate of neuron
    
    twdb(neuron_idx).trial_spikes = spikes_array;                                   %add spikes to twdb
    twdb(neuron_idx).trial_bursts = bursts_array;                                   %add bursts to twdb
    twdb(neuron_idx).trial_evt_timings = ses_evt_timings;                           %add timings of events within session to twdb
    twdb(neuron_idx).baseline_firing_rate_data = ...                                %add firing rate data to twdb
        [baseline_mean_firing_rate, baseline_std_firing_rate, baseline_burst_mean_firing_rate, baseline_burst_std_firing_rate, neuron_firing_rate];
    neuron_idx
    
    if ~mod(neuron_idx,1000)    %every so often (this line can be changed to the user's content), saves twdbfile. Thus, if the code runs into an error, we need not start back from the beginning
        save(new_twdbfile, 'twdb')
        1;              %in case we want to check on progress, this gives us a spot to put a debug point.
    end
    
end
save(new_twdbfile, 'twdb')  %save twdbfile after this function is done running
end



