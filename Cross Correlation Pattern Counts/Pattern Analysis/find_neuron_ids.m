function [all_pls_ids, all_plNotS_ids, all_strio_ids, all_matrix_ids, ...
            all_swn_ids, all_swn_not_hfn_ids, all_hfn_ids, totals] ...
            = find_neuron_ids(twdbs, taskType, min_final_michael_grades)
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
%  ALL_PLS_IDS              - cell array of cell arrays. The ith cell array
%                             within corresponds to the ith database in
%                             twdbs and contains a list of indices in the
%                             ith database corresponding to neurons that
%                             are PLs, recorded during the task TASKTYPE,
%                             and with minimum final michael grade as
%                             specified by MIN_FINAL_MICHAEL_GRADE
%  ALL_PLNOTS_IDS           - same as ALL_PLS_IDS, but for plNotS neurons
%  ALL_STRIO_IDS            - same as ALL_PLS_IDS, but for striosomes
%  ALL_MATRIX_IDS           - same as ALL_PLS_IDS, but for matrix neurons
%  ALL_SWN_IDS              - same as ALL_PLS_IDS, but for SWNs
%  ALL_SWN_NOT_HFN_IDS      - same as ALL_PLS_IDS, but for SWNs not HFN
%  ALL_HFN_IDS              - same as ALL_PLS_IDS, but for HFNs
%  TOTALS                   - contains the total number of PL and DMS
%                             neurons in each database in TWDBS

    % Determine min and max concentration of various task types.
    if strcmp(taskType, 'CB')
        min_conc = 0;
        max_conc = 15;
    elseif strcmp(taskType, 'BBS')
        min_conc = 51;
        max_conc = 100;
        taskType = 'TR';
    elseif strcmp(taskType, 'BBD')
        min_conc = 0;
        max_conc = 50;
        taskType = 'TR';
    elseif ~strcmpi(taskType, 'ALL')
        disp('Task Type Not Supported!');
    end

    % Initilize variables corresponding to outputs
    all_pls_ids = cell(1,length(twdbs));
    all_plNotS_ids = cell(1,length(twdbs));
    all_strio_ids = cell(1,length(twdbs));
    all_matrix_ids = cell(1,length(twdbs));
    all_swn_ids = cell(1,length(twdbs));
    all_swn_not_hfn_ids = cell(1,length(twdbs));
    all_hfn_ids = cell(1,length(twdbs));
    totals = cell(1,length(twdbs));
    
    homeDir = cd("..\Extracting Data From TWDB");
    % Branch based on the task type
    if strcmp(taskType, 'TR')
        for db = 1:length(twdbs)
            %% For PLS
            all_pls_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'pl', ...
                                        'key', 'taskType', taskType, ...
                                        'grade', 'strio_projecting_spikes', 10, NaN, ...
                                        'grade', 'strio_projecting_grade', 5, NaN, ...
                                        'grade', 'conc', min_conc, max_conc, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(1),5);
            if db == 2 || db == 3 % Remove potential interneurons for stress and stress2; control manually checked
                tmp = {};
                for iter = 1:length(all_pls_ids{db})
                    index = str2num(all_pls_ids{db}{iter});
                    if baseline_firing_rate(twdbs{db},index) < 15
                        tmp{end+1} = all_pls_ids{db}{iter};
                    end
                end
                all_pls_ids{db} = tmp;
            end
            %% For PLnotS
            all_plNotS_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'pl', ...
                                        'key', 'taskType', taskType, ....
                                        'grade', 'inRun_firing_rate', NaN, 20, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(2), 5, ...
                                        'grade', 'conc', min_conc, max_conc);
            all_plNotS_ids{db} = setdiff(all_plNotS_ids{db}, all_pls_ids{db});
            
            all_pls_ids{db} = cellfun(@str2num, all_pls_ids{db});
            all_plNotS_ids{db} = cellfun(@str2num, all_plNotS_ids{db});
            %% For Striosomes
            all_strio_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'taskType', taskType, ...
                                        'grade', 'striosomality2_type', 4, 5, ...
                                        'key', 'neuron_type', 'MSN', ...
                                        'grade', 'removable', 0, 0, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(3), 5, ...
                                        'grade', 'conc', min_conc, max_conc);

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
            
            if min_conc == 51 % If BBS, add NWIs that respond to PL stimulation
                all_strio_ids{1} = [all_strio_ids{1},[13656 13658 13659 13811 6290 6292 7731]];
                all_strio_ids{2} = [all_strio_ids{2}, [10034,11092,11187,11367,12140,12548,12585,5832,6067,6129,6151,6176,6858,7257,7555,7704]];
                all_strio_ids{3} = [all_strio_ids{3}, [241,3518,3645,3681,4556,8599,8658]];
                
                all_strio_ids = cellfun(@unique, all_strio_ids, 'uni', false);
            end

            %% For Matrix Neurons
            all_matrix_ids1 = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ... 
                                        'key', 'taskType', taskType, ...
                                        'grade', 'striosomality2_type', 0, 0,...
                                        'grade', 'sqr_neuron_type', 3, 3, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(4), 5, ...
                                        'key', 'neuron_type', 'MSN', ...
                                        'grade', 'conc', min_conc, max_conc);
            all_matrix_ids2 = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'taskType', taskType, ...
                                        'grade', 'striosomality2_type', 0, 0, ...
                                        'grade', 'sqr_neuron_type', 5, 5, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(4), 5, ...
                                        'key', 'neuron_type', 'MSN', ...
                                        'grade', 'conc', min_conc, max_conc);
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

            %% For SWNs, SWNs not HF, HFNs
            all_swn_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'taskType', taskType, ...
                                        'key', 'neuron_type', 'SWN', ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(5), 5, ...
                                        'grade', 'conc', min_conc, max_conc, ...
                                        'grade', 'firing_rate', 0, 60);
            all_swn_not_hfn_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'taskType', taskType, ...
                                        'key', 'neuron_type', 'SWN', ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(5), 5, ...
                                        'grade', 'firing_rate', -Inf, 6, ...
                                        'grade', 'conc', min_conc, max_conc);
            all_hfn_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'taskType', taskType, ...
                                        'key', 'neuron_type', 'SWN', ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(5), 5, ...
                                        'grade', 'firing_rate', 6, 60, ...
                                        'grade', 'conc', min_conc, max_conc);
            
            all_swn_ids{db} = cellfun(@str2num, all_swn_ids{db});
            all_swn_not_hfn_ids{db} = cellfun(@str2num, all_swn_not_hfn_ids{db});
            all_hfn_ids{db} = cellfun(@str2num, all_hfn_ids{db});
            
            if min_conc == 51 % If BBS, remove NWIs that respond to PL stimulation
                all_swn_ids{1} = setdiff(all_swn_ids{1},[13656 13658 13659 13811 6290 6292 7731]);
                all_swn_ids{2} = setdiff(all_swn_ids{2}, [10034,11092,11187,11367,12140,12548,12585,5832,6067,6129,6151,6176,6858,7257,7555,7704]);
                all_swn_ids{3} = setdiff(all_swn_ids{3}, [241,3518,3645,3681,4556,8599,8658]);
                
                all_swn_not_hfn_ids{1} = setdiff(all_swn_not_hfn_ids{1},[13656 13658 13659 13811 6290 6292 7731]);
                all_swn_not_hfn_ids{2} = setdiff(all_swn_not_hfn_ids{2}, [10034,11092,11187,11367,12140,12548,12585,5832,6067,6129,6151,6176,6858,7257,7555,7704]);
                all_swn_not_hfn_ids{3} = setdiff(all_swn_not_hfn_ids{3}, [241,3518,3645,3681,4556,8599,8658]);
                
                all_hfn_ids{1} = setdiff(all_hfn_ids{1},[13656 13658 13659 13811 6290 6292 7731]);
                all_hfn_ids{2} = setdiff(all_hfn_ids{2}, [10034,11092,11187,11367,12140,12548,12585,5832,6067,6129,6151,6176,6858,7257,7555,7704]);
                all_hfn_ids{3} = setdiff(all_hfn_ids{3}, [241,3518,3645,3681,4556,8599,8658]);
            end

            % Based on task type, remove some HFNs, determined by Alexander
            all_swn_ids{1} = setdiff(all_swn_ids{1}, 7731);
            all_swn_ids{2} = setdiff(all_swn_ids{2}, [6055 6238 7400 8160 10960 11099 11189 11392 11442 11460 11489 11665 12009 12081 12088]);
            all_swn_ids{3} = setdiff(all_swn_ids{3}, [467 979 1082 1185 3492 3647 4342 4791 4851 7318 8147 8626 8695 10460 10556 10880 10881 11779]);

            all_hfn_ids{1} = setdiff(all_hfn_ids{1}, 7731);
            all_hfn_ids{2} = setdiff(all_hfn_ids{2}, [6055 6238 7400 8160 10960 11099 11189 11392 11442 11460 11489 11665 12009 12081 12088]);
            all_hfn_ids{3} = setdiff(all_hfn_ids{3}, [467 979 1082 1185 3492 3647 4342 4791 4851 7318 8147 8626 8695 10460 10556 10880 10881 11779]);
            
            totals{db}(1) = sum(strcmp({twdbs{db}.tetrodeType},'pl') & strcmp({twdbs{db}.taskType},taskType));
            totals{db}(2) = sum(strcmp({twdbs{db}.tetrodeType},'dms') & strcmp({twdbs{db}.taskType},taskType));
        end
    elseif strcmp(taskType, 'CB')
        for db = 1:length(twdbs)
            %% For PLS
            all_pls_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'pl', ...
                                        'key', 'taskType', taskType, ...
                                        'grade', 'strio_projecting_spikes', 10, NaN, ...
                                        'grade', 'strio_projecting_grade', 5, NaN, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(1),5);
            if db == 2 || db == 3 % Remove potential interneurons for stress and stress2; control manually checked
                tmp = {};
                for iter = 1:length(all_pls_ids{db})
                    index = str2num(all_pls_ids{db}{iter});
                    if baseline_firing_rate(twdbs{db},index) < 15
                        tmp{end+1} = all_pls_ids{db}{iter};
                    end
                end
                all_pls_ids{db} = tmp;
            end
            %% For PLnotS
            all_plNotS_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'pl', ...
                                        'key', 'taskType', taskType, ....
                                        'grade', 'inRun_firing_rate', NaN, 20, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(2), 5);
            all_plNotS_ids{db} = setdiff(all_plNotS_ids{db}, all_pls_ids{db});
            
            all_pls_ids{db} = cellfun(@str2num, all_pls_ids{db});
            all_plNotS_ids{db} = cellfun(@str2num, all_plNotS_ids{db});
            % Remove CBC PLS neurons in stress2 with recordings determined
            % to be MUA (multi-unit activity)
            all_pls_ids{3} = setdiff(all_pls_ids{3},[10071,11331,11083,10840,11578,11016,8451,8447,5704,4741,2269]);
            %% For Striosomes
            all_strio_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'taskType', taskType, ...
                                        'grade', 'striosomality2_type', 4, 5, ...
                                        'key', 'neuron_type', 'MSN', ...
                                        'grade', 'removable', 0, 0, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(3), 5);

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

            %% For SWNs, SWNs not HF, HFNs
            all_swn_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'taskType', taskType, ...
                                        'key', 'neuron_type', 'SWN', ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(5), 5, ...
                                        'grade', 'firing_rate', 0, 60);
            all_swn_not_hfn_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'taskType', taskType, ...
                                        'key', 'neuron_type', 'SWN', ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(5), 5, ...
                                        'grade', 'firing_rate', -Inf, 6);
            all_hfn_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'taskType', taskType, ...
                                        'key', 'neuron_type', 'SWN', ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(5), 5, ...
                                        'grade', 'firing_rate', 6, 60);
            
            all_swn_ids{db} = cellfun(@str2num, all_swn_ids{db});
            all_swn_not_hfn_ids{db} = cellfun(@str2num, all_swn_not_hfn_ids{db});
            all_hfn_ids{db} = cellfun(@str2num, all_hfn_ids{db});
            % Based on task type, remove some HFNs, determined by Alexander
            all_swn_ids{2} = setdiff(all_swn_ids{2}, 11219);
            all_swn_ids{3} = setdiff(all_swn_ids{3}, [4224, 5184, 10798, 11865, 12508]);
            all_hfn_ids{2} = setdiff(all_hfn_ids{2}, 11219);
            all_hfn_ids{3} = setdiff(all_hfn_ids{3}, [4224, 5184, 10798, 11865, 12508]);
            
            totals{db}(1) = sum(strcmp({twdbs{db}.tetrodeType},'pl') & strcmp({twdbs{db}.taskType},taskType));
            totals{db}(2) = sum(strcmp({twdbs{db}.tetrodeType},'dms') & strcmp({twdbs{db}.taskType},taskType));
        end
    else
        for db = 1:length(twdbs)
            %% For PLS
            all_pls_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'pl', ...
                                        'grade', 'strio_projecting_spikes', 10, NaN, ...
                                        'grade', 'strio_projecting_grade', 5, NaN, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(1),5);
            if db == 2 || db == 3 % Remove potential interneurons for stress and stress2; control manually checked
                tmp = {};
                for iter = 1:length(all_pls_ids{db})
                    index = str2num(all_pls_ids{db}{iter});
                    if baseline_firing_rate(twdbs{db},index) < 15
                        tmp{end+1} = all_pls_ids{db}{iter};
                    end
                end
                all_pls_ids{db} = tmp;
            end
            %% For PLnotS
            all_plNotS_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'pl', ...
                                        'grade', 'inRun_firing_rate', NaN, 20, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(2), 5);
            all_plNotS_ids{db} = setdiff(all_plNotS_ids{db}, all_pls_ids{db});
            
            all_pls_ids{db} = cellfun(@str2num, all_pls_ids{db});
            all_plNotS_ids{db} = cellfun(@str2num, all_plNotS_ids{db});
            % Remove CBC PLS neurons in stress2 with recordings determined
            % to be MUA (multi-unit activity)
            all_pls_ids{3} = setdiff(all_pls_ids{3},[10071,11331,11083,10840,11578,11016,8451,8447,5704,4741,2269]);
            %% For Striosomes
            all_strio_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'grade', 'striosomality2_type', 4, 5, ...
                                        'key', 'neuron_type', 'MSN', ...
                                        'grade', 'removable', 0, 0, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(3), 5);

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
            all_matrix_ids1 = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ... 
                                        'grade', 'striosomality2_type', 0, 0,...
                                        'grade', 'sqr_neuron_type', 3, 3, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(4), 5, ...
                                        'key', 'neuron_type', 'MSN');
            all_matrix_ids2 = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'grade', 'striosomality2_type', 0, 0, ...
                                        'grade', 'sqr_neuron_type', 5, 5, ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(4), 5, ...
                                        'key', 'neuron_type', 'MSN');
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

            %% For SWNs, SWNs not HF, HFNs
            all_swn_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'neuron_type', 'SWN', ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(5), 5, ...
                                        'grade', 'firing_rate', 0, 60);
            all_swn_not_hfn_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'neuron_type', 'SWN', ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(5), 5, ...
                                        'grade', 'firing_rate', -Inf, 6);
            all_hfn_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
                                        'key', 'tetrodeType', 'dms', ...
                                        'key', 'neuron_type', 'SWN', ...
                                        'grade', 'final_michael_grade', min_final_michael_grades(5), 5, ...
                                        'grade', 'firing_rate', 6, 60);
            
            all_swn_ids{db} = cellfun(@str2num, all_swn_ids{db});
            all_swn_not_hfn_ids{db} = cellfun(@str2num, all_swn_not_hfn_ids{db});
            all_hfn_ids{db} = cellfun(@str2num, all_hfn_ids{db});
            
            % Remove BBS NWIs that respond to stimulation
            all_swn_ids{1} = setdiff(all_swn_ids{1},[13656 13658 13659 13811 6290 6292 7731]);
            all_swn_ids{2} = setdiff(all_swn_ids{2}, [10034,11092,11187,11367,12140,12548,12585,5832,6067,6129,6151,6176,6858,7257,7555,7704]);
            all_swn_ids{3} = setdiff(all_swn_ids{3}, [241,3518,3645,3681,4556,8599,8658]);
            all_swn_not_hfn_ids{1} = setdiff(all_swn_not_hfn_ids{1},[13656 13658 13659 13811 6290 6292 7731]);
            all_swn_not_hfn_ids{2} = setdiff(all_swn_not_hfn_ids{2}, [10034,11092,11187,11367,12140,12548,12585,5832,6067,6129,6151,6176,6858,7257,7555,7704]);
            all_swn_not_hfn_ids{3} = setdiff(all_swn_not_hfn_ids{3}, [241,3518,3645,3681,4556,8599,8658]);
            all_hfn_ids{1} = setdiff(all_hfn_ids{1},[13656 13658 13659 13811 6290 6292 7731]);
            all_hfn_ids{2} = setdiff(all_hfn_ids{2}, [10034,11092,11187,11367,12140,12548,12585,5832,6067,6129,6151,6176,6858,7257,7555,7704]);
            all_hfn_ids{3} = setdiff(all_hfn_ids{3}, [241,3518,3645,3681,4556,8599,8658]);

            % Based on task type, remove some HFNs, determined by Alexander
            % BBS
            all_swn_ids{1} = setdiff(all_swn_ids{1}, 7731);
            all_swn_ids{2} = setdiff(all_swn_ids{2}, [6055 6238 7400 8160 10960 11099 11189 11392 11442 11460 11489 11665 12009 12081 12088]);
            all_swn_ids{3} = setdiff(all_swn_ids{3}, [467 979 1082 1185 3492 3647 4342 4791 4851 7318 8147 8626 8695 10460 10556 10880 10881 11779]);
            all_hfn_ids{1} = setdiff(all_hfn_ids{1}, 7731);
            all_hfn_ids{2} = setdiff(all_hfn_ids{2}, [6055 6238 7400 8160 10960 11099 11189 11392 11442 11460 11489 11665 12009 12081 12088]);
            all_hfn_ids{3} = setdiff(all_hfn_ids{3}, [467 979 1082 1185 3492 3647 4342 4791 4851 7318 8147 8626 8695 10460 10556 10880 10881 11779]);
            % CBC
            all_swn_ids{2} = setdiff(all_swn_ids{2}, 11219);
            all_swn_ids{3} = setdiff(all_swn_ids{3}, [4224, 5184, 10798, 11865, 12508]);
            all_hfn_ids{2} = setdiff(all_hfn_ids{2}, 11219);
            all_hfn_ids{3} = setdiff(all_hfn_ids{3}, [4224, 5184, 10798, 11865, 12508]);
            
            totals{db}(1) = sum(strcmp({twdbs{db}.tetrodeType},'pl'));
            totals{db}(2) = sum(strcmp({twdbs{db}.tetrodeType},'dms'));
            cd(homeDir)
        end
    end
end