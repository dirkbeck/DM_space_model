%% load databases
home = cd("..\Pattern Analysis");
[dbs,twdbs] = loadData;
cd(home)
%% Create Skewness table
clc;
binSize = 100;
logOrNot = false;
allTaskTypesAndConcentrationsPairedWithSkewness = containers.Map('KeyType','char','ValueType','any');
namesOfDatabases = ["Control", "Stress 1","Stress 2"];
dictionary_of_edges = containers.Map('KeyType','char','ValueType','any');
dictionary_of_bin_counts = containers.Map('KeyType','char','ValueType','any');
for i=1:2%length(twdbs)
    disp(strcat("Database: ",namesOfDatabases(i)));
    currentDatabase = twdbs{i};
    t = struct2table(currentDatabase);
    uniqueTaskType = unique(t.taskType);
    currentTaskTypes = uniqueTaskType;
    allSkews = [];
    for currentTaskType=1:length(currentTaskTypes)
        tableWithJust1TaskType = t((strcmp(string(t.taskType),string(currentTaskTypes(currentTaskType)))),:);



        

        old_striosomality2_type_col = tableWithJust1TaskType.striosomality2_type;

        updated_striosomality2_type_col = zeros(size(old_striosomality2_type_col,1),1) ./ NaN;
        for p=1:size(old_striosomality2_type_col,1)
            if ~isempty(old_striosomality2_type_col{p})
                updated_striosomality2_type_col(p) = old_striosomality2_type_col{p};
            else
            end
        end
        % cell2mat(tableWithJust1TaskType.striosomality2_type
        
        tableWithJust1TaskType.striosomality2_type = updated_striosomality2_type_col; 

        table_of_just_strio = tableWithJust1TaskType(strcmpi(string(tableWithJust1TaskType.tetrodeType),"dms") & strcmpi(string(tableWithJust1TaskType.neuron_type),"MSN") & (tableWithJust1TaskType.striosomality2_type ==4 | tableWithJust1TaskType.striosomality2_type == 5),:);
           
        % all_strio_ids{db} = twdb_lookup(twdbs{db}, 'index', ...
           %      'key', 'tetrodeType', 'dms', ...
           %      'key', 'taskType', taskType, ...
           %      'grade', 'striosomality2_type', 4, 5, ...
           %      'key', 'neuron_type', 'MSN', ...
           %      'grade', 'removable', 0, 0, ...
           %      'grade', 'final_michael_grade', min_final_michael_grades(3), 5, ...
           %      'grade', 'conc', conc-1, conc+1);

        number_of_strio_neurons = height(table_of_just_strio);

        table_of_just_matrix =tableWithJust1TaskType(strcmpi(string(tableWithJust1TaskType.tetrodeType),"dms") & strcmpi(string(tableWithJust1TaskType.neuron_type),"MSN") & tableWithJust1TaskType.striosomality2_type == 0,:);
        % all_matrix_ids1 = twdb_lookup(twdbs{db}, 'index', ...
        %         'key', 'tetrodeType', 'dms', ...
        %         'key', 'taskType', taskType, ...
        %         'grade', 'striosomality2_type', 0, 0,...
        %         'grade', 'sqr_neuron_type', 3, 3, ...
        %         'grade', 'final_michael_grade', min_final_michael_grades(4), 5, ...
        %         'key', 'neuron_type', 'MSN', ...
        %         'grade', 'conc', conc-1, conc+1);
        number_of_matrix_neurons = height(table_of_just_matrix);
        number_of_rats = size(unique(tableWithJust1TaskType.ratID),1);
        if strcmpi("CB",currentTaskTypes(currentTaskType))
            disp("CBC________________")
        elseif strcmpi("TR",currentTaskTypes(currentTaskType))
            disp("BB______________________")
        elseif strcmpi("Rev CB",currentTaskTypes(currentTaskType))
            disp("NCB_______________")
        elseif strcmpi("EQR",currentTaskTypes(currentTaskType))
            disp("CC_________________________________")
        end
        disp(strcat("Number Of Rats:",string(number_of_rats)))
        % number_of_trials = height(tableWithJust1TaskType);
        % disp(strcat("Number Of trials:",string(number_of_trials))); 
        disp(strcat("Number Of sessions:",string(size(unique(tableWithJust1TaskType.sessionID),1))));
        disp(strcat("Number of Matrix neurons:",string(number_of_matrix_neurons)))
        disp(strcat("Number of Strio neurons:",string(number_of_strio_neurons)))

        
 
        number_of_cells = 0;
        just_mean_spike_wave_form_array = tableWithJust1TaskType.mean_spike_waveform;
        for k=1:height(tableWithJust1TaskType)
            current_mean_spike_wave_form_array = just_mean_spike_wave_form_array{i};
            number_of_cells = number_of_cells + size(current_mean_spike_wave_form_array,1);
        end
        disp(strcat("Number of trials:",string(number_of_cells)));
    end
    disp("/////////////////////////////////////")
end