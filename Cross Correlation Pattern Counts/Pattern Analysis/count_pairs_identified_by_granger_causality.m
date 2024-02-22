%% load databases
[dbs,twdbs] = loadData;
%% run cross correlation
namesOfDatabases = ["Control","Stress1","Stress2"];
list_of_which_tasks_should_be_split = ["TR"];
where_to_split = 50;


for currentDB = 1:1.5%length(twdbs) %cycle through the databases (AKA the Outer Loop in future comments)
    currentDatabase = twdbs{currentDB}; %get the database
    t = struct2table(currentDatabase); %turn it into a table for reading
    uniqueTaskType = unique(t.taskType); %get the unique task types within the current databaser

    for i =1:length(uniqueTaskType)
        if ismember(string(uniqueTaskType(i)), list_of_which_tasks_should_be_split)
            the_OG_task_type = string(uniqueTaskType(i));
            uniqueTaskType{i} = strcat(the_OG_task_type, " 0 to ",num2str(where_to_split-1));
            uniqueTaskType{end+1} = strcat(the_OG_task_type," ", num2str(where_to_split)," to 100");
        end
    end


    array_of_total_pairs_per_task_type = zeros(1,length(uniqueTaskType));
    array_of_total_pairs_connected_via_gc = zeros(1,length(uniqueTaskType));
    for ttCounter = 1:length(uniqueTaskType) %cycle through all the taks types in the current database


        currentTaskType = uniqueTaskType{ttCounter};%get the task type
        disp(strcat("Current Task Type:", currentTaskType)) %display the task type
        



        if contains(string(currentTaskType),"to") && ~(strcmpi(string(currentTaskType),"eqr")) && ~(strcmpi(string(currentTaskType),'rev cb'))
            the_current_task_type_split = split(string(currentTaskType)," ");
            the_min = str2double(the_current_task_type_split{2});
            the_max = str2double(the_current_task_type_split{4});
            the_task_type = the_current_task_type_split{1};
            [cb_strio_ids,cb_matrix_ids] = find_matrix_striosome_ids_split_for_gc(twdbs,the_task_type,[-Inf,-Inf,-Inf,-Inf,1],[the_min,the_max]);

        elseif ~(strcmpi(string(currentTaskType),"eqr")) && ~(strcmpi(string(currentTaskType),'rev cb'))
            [cb_strio_ids, cb_matrix_ids] = find_matrix_striosome_ids(twdbs,currentTaskType,[-Inf,-Inf,-Inf,-Inf,1],nan);
        end

   
        if strcmpi(string(currentTaskType),"eqr") || strcmpi(string(currentTaskType),'rev cb')
            [cb_strio_ids,cb_matrix_ids] = find_matrix_striosome_ids(twdbs,currentTaskType,[4,4,4,4,1],nan);
        end
        
        %find neuron Ids
        %specificially matrix and striosome ids
        %a more general form of this function can be found in find_neuron_ids.m


        cd("..\Pattern Analysis")
        [~,sessionDir_neurons] = findAllSessions(twdbs,dbs);                                                %find all the session dates


        [neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids); %%IMPORTANT CHANGING THIS LINE ALLOWS YOU TO DO MAKE IT MATRIX-Strio pairs, matrix matrix pairs, or strio strio pairs
        % by default it is set to matrix strio pairs
        %OG LINE [neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids);
        %get the indexes of the desired neurons in the database
        all_matrix_strio_pairs = getPairs(dbs,neuron_1_ids,neuron_2_ids,sessionDir_neurons);                %find all POSSIBLE pairs between striosome and matrix
        %         all_matrix_strio_pairs = cutDownPairsToNPairs(50,all_matrix_strio_pairs);
        all_matrix_strio_pairs = remove_neurons_connected_to_themselves(all_matrix_strio_pairs);            %remove any neurons which may be connected to themselves


        currentDatabasePairs = all_matrix_strio_pairs{currentDB};   
        %the pairs which will be checked for connectivity by making sure they have the same day and rat,
        %the variable all_matrix_strio_pairs is a cell array of the following structure {...,...,...}
        %where each "..." represents pairs of matrix-strio neurons for a database
        %however only the pairs belonging to the current database are examined in each of the outer-most loops
        %for instance on the first loop only the control pairs are examined
        %in the second loop only the stress pairs are examined
        %in the third loop only the stress 2 pairs are examined
        %striosome matrix pair a nx2 array where column 1 is the index of a matrix neuron and column 2 is the index of a striosome neuron


        %now we'll filter the strio-matrix pairs to see if they have the same rat id and date
        %if they match they're left in if they don't match then they're taken out
        for currentRow=1:height(currentDatabasePairs)
            strio_info = currentDatabase(currentDatabasePairs(currentRow,2)); %the row in the current database which contains the striosome
            strio_rat = strio_info.ratID; %the rat which the info was recorded from 
            strio_sessionID = strio_info.sessionID; %date the info was recorded


            mat_info = currentDatabase(currentDatabasePairs(currentRow,1)); %the row in the current Database which contains the matrix
            mat_rat = mat_info.ratID;
            mat_sessionID = mat_info.sessionID;

            %remove the pair if the both SessionID and ratID don't match
            if ~(strcmp(mat_sessionID,strio_sessionID) && strcmp(mat_rat,strio_rat) )
                currentDatabasePairs(currentRow,1) = nan;
                currentDatabasePairs(currentRow,2) = nan;
            end
           
        end
        disp("This is how nans there are ")
        disp(sum(isnan(currentDatabasePairs),'all'))


        %check connection via granger causality
        currentIndex=1;
        striosome_bin_time = 1;


        currentDatabasePairs = all_matrix_strio_pairs{currentDB};
        %the pairs which will be checked for connectivity by making sure they have the same day and rat,
        %the variable all_matrix_strio_pairs is a cell array of the following structure {...,...,...}
        %where each "..." represents pairs of matrix-strio neurons for a database
        %however only the pairs belonging to the current database are examined in each of the outer-most loops
        %for instance on the first loop only the control pairs are examined
        %in the second loop only the stress pairs are examined
        %in the third loop only the stress 2 pairs are examined
        %striosome matrix pair a nx2 array where column 1 is the index of a matrix neuron and column 2 is the index of a striosome neuron
        currentDatabase = twdbs{currentDB};
        connectedCount = 0; %used to tell how many of the pairs are connected
        nlags =1;
        array_of_total_pairs_per_task_type(ttCounter) = height(currentDatabasePairs);
        cd('../Pattern Analysis')
        for currentPair =1:height(currentDatabasePairs)
            if runGrangerCausality_modified_to_count_connected_pairs(currentPair,currentDatabase,currentDatabasePairs,nlags)
                connectedCount = connectedCount+1;
            end
        end
        array_of_total_pairs_connected_via_gc(ttCounter) = connectedCount;

    end

    
    %hardcoded solution to fix possible pairs counts for TR
    array_of_total_pairs_per_task_type(4) = array_of_total_pairs_per_task_type(4) + array_of_total_pairs_per_task_type(5);
    array_of_total_pairs_per_task_type(5) = array_of_total_pairs_per_task_type(4);

    %hard coded solution to avoid /0 errors for rev cb
    array_of_total_pairs_per_task_type(3) = 1;

    table_of_paired_percentages = table(uniqueTaskType,...
        array_of_total_pairs_per_task_type.',...
        array_of_total_pairs_connected_via_gc.' ./ array_of_total_pairs_per_task_type.',...
        'VariableNames',{'TT and Conc','Possible Pairs', '% of connected pairs according to Granger Causality'});

    disp(table_of_paired_percentages);


end