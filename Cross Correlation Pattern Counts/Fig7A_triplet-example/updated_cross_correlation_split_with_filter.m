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


    name_of_database_folder = strcat(namesOfDatabases(currentDB), " split with filter updated michael for EQR and rev cb, neg inf micheal for everything else"); %get name of current database
    mkdir(name_of_database_folder) %make a directory with the same name as the current database
    og_dir = cd(name_of_database_folder); %movve into the folder with the name of the current database
    path_of_database_folder = cd(og_dir);
    cd(path_of_database_folder);
    number_of_task_type_loops_that_will_be_done = length(uniqueTaskType) + length(list_of_which_tasks_should_be_split); %this is a dynamic way to tell how many loops to do in the case of wanting to split current task type
    for ttCounter = 1:length(uniqueTaskType) %cycle through all the taks types in the current database


        currentTaskType = uniqueTaskType{ttCounter};%get the task type
        disp(strcat("Current Task Type:", currentTaskType)) %display the task type
        

        name_of_task_type_folder = currentTaskType; %get name of the current task type
        mkdir(name_of_task_type_folder)
        cd(name_of_task_type_folder) %move into the folder with the name of the current task type
        path_of_task_type_folder = cd(path_of_database_folder);
        cd(path_of_task_type_folder);

        if contains(string(currentTaskType),"to") && ~(strcmpi(string(currentTaskType),"eqr")) && ~(strcmpi(string(currentTaskType),'rev cb'))
            the_current_task_type_split = split(string(currentTaskType)," ");
            the_min = str2double(the_current_task_type_split{2});
            the_max = str2double(the_current_task_type_split{4});
            the_task_type = the_current_task_type_split{1};
            [cb_strio_ids,cb_matrix_ids] = find_matrix_striosome_ids_split(twdbs,the_task_type,[-Inf,-Inf,-Inf,-Inf,1],[the_min,the_max]);

        elseif ~(strcmpi(string(currentTaskType),"eqr")) && ~(strcmpi(string(currentTaskType),'rev cb'))
            [cb_strio_ids, cb_matrix_ids] = find_matrix_striosome_ids(twdbs,currentTaskType,[-Inf,-Inf,-Inf,-Inf,1],nan);
        end

        cd(path_of_task_type_folder) %move back to the task type folder
        if strcmpi(string(currentTaskType),"eqr") || strcmpi(string(currentTaskType),'rev cb')
            [cb_strio_ids,cb_matrix_ids] = find_matrix_striosome_ids(twdbs,currentTaskType,[4,4,4,4,1],nan);
        end
        
        %find neuron Ids
        %specificially matrix and striosome ids
        %a more general form of this function can be found in find_neuron_ids.m

        cd(path_of_task_type_folder) %move back to the task type folder

        [~,sessionDir_neurons] = findAllSessions(twdbs,dbs);                                                %find all the session dates
        cd(path_of_task_type_folder)

        [neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids); %%IMPORTANT CHANGING THIS LINE ALLOWS YOU TO DO MAKE IT MATRIX-Strio pairs, matrix matrix pairs, or strio strio pairs
        % by default it is set to matrix strio pairs
        %OG LINE [neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids);
        %get the indexes of the desired neurons in the database
        all_matrix_strio_pairs = getPairs(dbs,neuron_1_ids,neuron_2_ids,sessionDir_neurons);                %find all POSSIBLE pairs between striosome and matrix
        %         all_matrix_strio_pairs = cutDownPairsToNPairs(50,all_matrix_strio_pairs);
        all_matrix_strio_pairs = remove_neurons_connected_to_themselves(all_matrix_strio_pairs);            %remove any neurons which may be connected to themselves


        striosome_matrix_pairs = all_matrix_strio_pairs{currentDB};   
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
        for currentRow=1:height(striosome_matrix_pairs)
            strio_info = currentDatabase(striosome_matrix_pairs(currentRow,2)); %the row in the current database which contains the striosome
            strio_rat = strio_info.ratID; %the rat which the info was recorded from 
            strio_sessionID = strio_info.sessionID; %date the info was recorded


            mat_info = currentDatabase(striosome_matrix_pairs(currentRow,1)); %the row in the current Database which contains the matrix
            mat_rat = mat_info.ratID;
            mat_sessionID = mat_info.sessionID;

            %remove the pair if the both SessionID and ratID don't match
            if ~(strcmp(mat_sessionID,strio_sessionID) && strcmp(mat_rat,strio_rat) )
                striosome_matrix_pairs(currentRow,1) = nan;
                striosome_matrix_pairs(currentRow,2) = nan;
            end
           
        end
        disp("This is how nans there are ")
        disp(sum(isnan(striosome_matrix_pairs),'all'))


        

        %check cross correlation


        currentIndex=1;
        striosome_bin_time = 1;
        while currentIndex <= height(striosome_matrix_pairs) %cycle through all the found pairs
            if isnan(striosome_matrix_pairs(currentRow,1))
                continue;
            end
%             try
                figure %create a figure to plot things on later
                spikes_matrix=currentDatabase(striosome_matrix_pairs(currentIndex,1)).trial_spikes; %get the spikes of the current matrix neuron
                spikes_strio=currentDatabase(striosome_matrix_pairs(currentIndex,2)).trial_spikes; %get the spikes of the current striosome neuron

                [given_fig,gof,significance,slope] = matrix_strio_plot_dynamics(spikes_strio,spikes_matrix,striosome_bin_time); %creates a figure of cross correlation between strio and matrix

                thename = strcat("TT ", string(currentTaskType), ...
                    " Pair Row ",num2str(currentIndex), ...
                    " RSq ", num2str(gof),...
                    " Sig ", num2str(significance), ...
                    '.fig');
                %            thename = strcat(pwd,thename);
                subtitle(thename)
                %                display(thename)
                try
                    cd(path_of_task_type_folder)
                    mkdir("Positive Slope")
                    mkdir("Negative Slope")
                    if slope>0
                        cd("Positive Slope");
                        saveas(given_fig,thename)
                        cd(path_of_task_type_folder)
                    elseif slope<0
                        cd("Negative Slope");
                        saveas(given_fig,thename)
                        cd(path_of_task_type_folder)
                    end
                    cd(path_of_task_type_folder)
                catch
                    cd(path_of_task_type_folder)
                    if slope>0
                        cd("Positive Slope");
                        saveas(given_fig,thename)
                        cd(path_of_task_type_folder)
                    elseif slope<0
                        cd("Negative Slope");
                        saveas(given_fig,thename)
                        cd(path_of_task_type_folder)
                    end
                    cd(path_of_task_type_folder)

                end
                currentIndex=currentIndex+1;
                close(given_fig)
                
%             catch
%                 close all
%                 currentIndex=currentIndex+1;
%             end



        end



        cd(path_of_database_folder)
    end

    cd(og_dir)


end

