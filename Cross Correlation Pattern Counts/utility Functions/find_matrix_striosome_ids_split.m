function [all_strio_ids, all_matrix_ids] ...
    = find_matrix_striosome_ids_split(twdbs, taskType, min_final_michael_grades,conc)

% FIND_NEURON_IDS finds all indices in a set of databases corresponding
% to different neuron types.
%
% Inputs are:
%  TWDBS                    - cell array of databases
%  TASKTYPE                 - the task during which the neurons are
%                           recorded. It can be any of the following:
%                               1. 'CB'  - Cost Benefit
%                               2. 'BBS' - Benefit Benefit Similar
%                               3. 'BBD' - Benefit Benefit Dissimilar
%                               4. 'ALL' - Any Task
%  MIN_FINAL_MICHAEL_GRADES - the minimum final michael grade considered
%                             for each neuron type. The order of the values
%                             is the same as the order used in the rest of
%                             the code base (refer to global variable 'neuron_types')
% Outputs are:
%  ALL_STRIO_IDS            - cell array of cell arrays. The ith cell array
%                             within corresponds to the ith database in
%                             twdbs and contains a list of indices in the
%                             ith database corresponding to neurons that
%                             are PLs, recorded during the task TASKTYPE,
%                             and with minimum final michael grade as
%                             specified by MIN_FINAL_MICHAEL_GRADE
%  ALL_MATRIX_IDS           - same as ALL_STRIO_IDS, but for matrix neurons


% Determine min and max concentration of various task types.
%     if strcmp(taskType, 'CB')
%         min_conc = 0;
%         max_conc = 15;
%     elseif strcmp(taskType, 'BBS')
%         min_conc = 51;
%         max_conc = 100;
%         taskType = 'TR';
%     elseif strcmp(taskType, 'BBD')
%         min_conc = 0;
%         max_conc = 50;
%         taskType = 'TR';
%     elseif ~strcmpi(taskType, 'ALL')
%         disp('Task Type Not Supported!');
%     end

% Initilize variables corresponding to outputs

if class(twdbs)=="cell"

    all_strio_ids = cell(1,length(twdbs));
    all_matrix_ids = cell(1,length(twdbs));

    homeDir = cd("../../../Extracting Data From TWDB");
    % Branch based on the task type
    for db = 1:length(twdbs)
        %% For Striosomes
        if ~isnan(conc)
            all_strio_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                'key', 'tetrodeType', 'dms', ...
                'key', 'taskType', taskType, ...
                'grade', 'striosomality2_type', 4, 5, ...
                'key', 'neuron_type', 'MSN', ...
                'grade', 'removable', 0, 0, ...
                'grade', 'final_michael_grade', min_final_michael_grades(3), 5, ...
                'grade', 'conc', conc(1), conc(2));
        else
            all_strio_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                'key', 'tetrodeType', 'dms', ...
                'key', 'taskType', taskType, ...
                'grade', 'striosomality2_type', 4, 5, ...
                'key', 'neuron_type', 'MSN', ...
                'grade', 'removable', 0, 0, ...
                'grade', 'final_michael_grade', min_final_michael_grades(3), 5);
        end
        strio_ids = all_strio_ids{db};
        twdb = twdbs{db};
        tmp = {};
        for iter = 1:length(strio_ids)
            index = str2num(strio_ids{iter});

            spikes_array = twdb(index).trial_spikes;
            ses_evt_timings = twdb(index).trial_evt_timings;
            neuron_idsAndData = [1, length(spikes_array), twdb(index).baseline_firing_rate_data];
            [plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
                {ses_evt_timings}, neuron_idsAndData, {}, {}, [600, 1, 2, .3, .6], [0 0], 1);
            if 5*twdb(index).firing_rate > mean(plotting_bins(361:400, 1))
                tmp{end+1} = strio_ids{iter};
            end
        end
        strio_ids = tmp;
        tmp = {}; threshold = 10;
        for iter = 1:length(strio_ids)
            index = str2num(strio_ids{iter});
            spikes_array = twdb(index).trial_spikes;
            ses_evt_timings = twdb(index).trial_evt_timings;
            neuron_idsAndData = [1, length(spikes_array), twdb(index).baseline_firing_rate_data];
            [plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
                {ses_evt_timings}, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
            if sum(plotting_bins(60:240)>0) > threshold
                tmp{end+1} = strio_ids{iter};
            end
        end
        strio_ids = tmp;
        all_strio_ids{db} = cellfun(@str2num, strio_ids);


        %% For Matrix Neurons
        if ~isnan(conc)
            all_matrix_ids1 = twdb_lookup(twdbs{db}, 'index', ...
                'key', 'tetrodeType', 'dms', ...
                'key', 'taskType', taskType, ...
                'grade', 'striosomality2_type', 0, 0,...
                'grade', 'sqr_neuron_type', 3, 3, ...
                'grade', 'final_michael_grade', min_final_michael_grades(4), 5, ...
                'key', 'neuron_type', 'MSN', ...
                'grade', 'conc', conc(1), conc(2));
            all_matrix_ids2 = twdb_lookup(twdbs{db}, 'index', ...
                'key', 'tetrodeType', 'dms', ...
                'key', 'taskType', taskType, ...
                'grade', 'striosomality2_type', 0, 0, ...
                'grade', 'sqr_neuron_type', 5, 5, ...
                'grade', 'final_michael_grade', min_final_michael_grades(4), 5, ...
                'key', 'neuron_type', 'MSN', ...
                'grade', 'conc', conc(1), conc(2));
        else
            all_matrix_ids1 = twdb_lookup(twdbs{db}, 'index', ...
                'key', 'tetrodeType', 'dms', ...
                'key', 'taskType', taskType, ...
                'grade', 'striosomality2_type', 0, 0,...
                'grade', 'sqr_neuron_type', 3, 3, ...
                'grade', 'final_michael_grade', min_final_michael_grades(4), 5, ...
                'key', 'neuron_type', 'MSN');
            all_matrix_ids2 = twdb_lookup(twdbs{db}, 'index', ...
                'key', 'tetrodeType', 'dms', ...
                'key', 'taskType', taskType, ...
                'grade', 'striosomality2_type', 0, 0, ...
                'grade', 'sqr_neuron_type', 5, 5, ...
                'grade', 'final_michael_grade', min_final_michael_grades(4), 5, ...
                'key', 'neuron_type', 'MSN');
        end
        all_matrix_ids{db} = [all_matrix_ids1 all_matrix_ids2];

        matrx_ids = all_matrix_ids{db};
        twdb = twdbs{db};
        tmp = {};
        for iter = 1:length(matrx_ids)
            index = str2num(matrx_ids{iter});

            spikes_array = twdb(index).trial_spikes;
            ses_evt_timings = twdb(index).trial_evt_timings;
            neuron_idsAndData = [1, length(spikes_array), twdb(index).baseline_firing_rate_data];
            [plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
                {ses_evt_timings}, neuron_idsAndData, {}, {}, [600, 1, 2, .3, .6], [0 0], 1);
            if 5*twdb(index).firing_rate > mean(plotting_bins(361:400, 1))
                tmp{end+1} = matrx_ids{iter};
            end
        end
        matrx_ids = tmp;
        tmp = {}; threshold = 10;
        for iter = 1:length(matrx_ids)
            index = str2num(matrx_ids{iter});
            spikes_array = twdb(index).trial_spikes;
            ses_evt_timings = twdb(index).trial_evt_timings;
            neuron_idsAndData = [1, length(spikes_array), twdb(index).baseline_firing_rate_data];
            [plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
                {ses_evt_timings}, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
            if sum(plotting_bins(60:240)>0) > threshold
                tmp{end+1} = matrx_ids{iter};
            end
        end
        matrx_ids = tmp;
        all_matrix_ids{db} = cellfun(@str2num, matrx_ids);
    end
end
end