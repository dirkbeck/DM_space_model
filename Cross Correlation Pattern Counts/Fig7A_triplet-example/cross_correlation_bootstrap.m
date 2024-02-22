%% load databases
[dbs,twdbs] = loadData;
%% run cross correlation
namesOfDatabases = ["Control","Stress1","Stress2"];
list_of_which_tasks_should_be_split = ["TR"];
where_to_split = 50;
all_the_percentages = []; 
rsquaredThreshold = 0.4;
significanceThreshold = 0.05; 


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


    name_of_database_folder = strcat(namesOfDatabases(currentDB), " split Random"); %get name of current database
    mkdir(name_of_database_folder) %make a directory with the same name as the current database
    og_dir = cd(name_of_database_folder); %movve into the folder with the name of the current database
    path_of_database_folder = cd(og_dir);
    cd(path_of_database_folder);
    



%     currentTaskType = uniqueTaskType{ttCounter};%get the task type
%     disp(strcat("Current Task Type:", currentTaskType)) %display the task type


    name_of_task_type_folder = 'Random'; %get name of the current task type
    mkdir(name_of_task_type_folder)
    cd(name_of_task_type_folder) %move into the folder with the name of the current task type
    path_of_task_type_folder = cd(path_of_database_folder);
    cd(path_of_task_type_folder);


    [cb_strio_ids, cb_matrix_ids] = find_matrix_striosome_ids_random(twdbs,[-Inf,-Inf,-Inf,-Inf,1],nan);


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


    all_matrix_strio_pairs = getPairs_random(dbs,neuron_1_ids,neuron_2_ids,sessionDir_neurons);                %find all POSSIBLE pairs between striosome and matrix
    %         all_matrix_strio_pairs = cutDownPairsToNPairs(50,all_matrix_strio_pairs);
%     all_matrix_strio_pairs = remove_neurons_connected_to_themselves(all_matrix_strio_pairs);            %remove any neurons which may be connected to themselves


    striosome_matrix_pairs = all_matrix_strio_pairs{currentDB};   %the pairs which will be checked for connectivity using granger causality, and have their trials examined for patterns
    %the variable all_matrix_strio_pairs is a cell array of the following structure {...,...,...}
    %where each "..." represents pairs of matrix-strio neurons for a database
    %however only the pairs belonging to the current database are examined in each of the outer-most loops
    %for instance on the first loop only the control pairs are examined
    %in the second loop only the stress pairs are examined
    %in the third loop only the stress 2 pairs are examined
    %striosome matrix pair a nx2 array where column 1 is the index of a matrix neuron and column 2 is the index of a striosome neuron
    original_striosome_matrix_pairs = striosome_matrix_pairs;

    %by default striosome_matrix_pairs won't have the same session
    %but they may belong to the same rat
    %so I'm going to filter out any pairs which belong to the same rat 
    for currentRow=1:height(striosome_matrix_pairs)
        strio_info = currentDatabase(striosome_matrix_pairs(currentRow,2)); %the row in the current database which contains the striosome
        strio_rat = strio_info.ratID; %the rat which the info was recorded from
        strio_sessionID = strio_info.sessionID; %date the info was recorded


        mat_info = currentDatabase(striosome_matrix_pairs(currentRow,1)); %the row in the current Database which contains the matrix
        mat_rat = mat_info.ratID;
        mat_sessionID = mat_info.sessionID;

        %remove the pair if the either SessionID or ratID match
        if (strcmp(mat_sessionID,strio_sessionID) || strcmp(mat_rat,strio_rat) )
            striosome_matrix_pairs(currentRow,1) = nan;
            striosome_matrix_pairs(currentRow,2) = nan;
        end

    end

    %now to get a reasonable bootstrap we'll want to get the % of fits which meet the r-squared and signifiance threshold 
    %I'll start by running it a thousand times and cut down as necessary
    for bootstrap_number = 1:1000
        %first I'll declare a variable to store every instance of "thename" variable as it holds the signifiance and r-squared value inside it
        all_the_names = [];

        %Now take a random subset of all the strio-matrix pairs, use approximately 20% of the data each time, with replacement
        number_of_random_values_needed = ceil(length(striosome_matrix_pairs)/20);
        random_indexes = randsample(length(striosome_matrix_pairs),number_of_random_values_needed,true);
        striosome_matrix_pairs = striosome_matrix_pairs(random_indexes,:); 

        %now run cross correlation
        currentIndex=1;
        striosome_bin_time = 1;
        currentTaskType = "Random";
        while currentIndex <= height(striosome_matrix_pairs) %cycle through all the found pairs
            %             try
            %         figure %create a figure to plot things on later
            if isnan(striosome_matrix_pairs(currentIndex,1)) || isnan(striosome_matrix_pairs(currentIndex,2))
                currentIndex = currentIndex+1;
                continue;
            end
            spikes_matrix=currentDatabase(striosome_matrix_pairs(currentIndex,1)).trial_spikes; %get the spikes of the current matrix neuron
            spikes_strio=currentDatabase(striosome_matrix_pairs(currentIndex,2)).trial_spikes; %get the spikes of the current striosome neuron
            cd(og_dir)
            [gof,significance,slope] = matrix_strio_plot_dynamics_random(spikes_strio,spikes_matrix,striosome_bin_time); %creates a figure of cross correlation between strio and matrix

            thename = strcat("TT ", string(currentTaskType), ...
                " Pair Row ",num2str(currentIndex), ...
                " RSq ", num2str(gof),...
                " Sig ", num2str(significance), ...
                '.fig');
            %            thename = strcat(pwd,thename);
            all_the_names = [all_the_names;thename];

            currentIndex=currentIndex+1;
            %         close(given_fig)
        end
        cd(path_of_database_folder)
        cd(og_dir)

        %Now I count how many times the titles have meet r-squared and significance threshold
        met_r_sq_and_sig = 0; 
        for name_counter=1:length(all_the_names)
            the_current_name = all_the_names(name_counter);
%             disp(the_current_name);
            the_current_name = split(the_current_name, " ");
            rsquared = the_current_name(7);
            rsquared = str2double(rsquared);
            significance = the_current_name(9); 
            significance = strrep(significance,".fig","");
            significance = str2double(significance);
            if significance <= significanceThreshold
                if rsquared >=rsquaredThreshold
                    met_r_sq_and_sig = met_r_sq_and_sig +1;
                end
            end
        end

        %now I calculate the % of all_the_names which met both
        percentage_which_met_both = met_r_sq_and_sig/length(all_the_names);
        all_the_percentages = [all_the_percentages,percentage_which_met_both]; 

        striosome_matrix_pairs = original_striosome_matrix_pairs ;

        disp(strcat(string(bootstrap_number),"/1000"))
    end

end


%% create histograms of all the percentages
figure; hold on;
histogram(all_the_percentages);
xline(mean(all_the_percentages),'LineStyle', '--', 'Color', 'r','Label',"Mean")


xline((mean(all_the_percentages) + std(all_the_percentages)),'LineStyle', '--', 'Color', 'b','Label',strcat("+1 Std deviation ",string((mean(all_the_percentages) + std(all_the_percentages)))))
xline((mean(all_the_percentages) + 2*std(all_the_percentages)),'LineStyle', '--', 'Color', 'b','Label',strcat("+2 Std deviation ",string((mean(all_the_percentages) + 2*std(all_the_percentages)))))
xline((mean(all_the_percentages) + 3*std(all_the_percentages)),'LineStyle', '--', 'Color', 'b','Label',strcat("+3 Std deviation ",string((mean(all_the_percentages) + 3*std(all_the_percentages)))))


xline((mean(all_the_percentages) - std(all_the_percentages)),'LineStyle', '--', 'Color', 'b','Label',strcat("-1 Std deviation ",string((mean(all_the_percentages) - std(all_the_percentages)))))
xline((mean(all_the_percentages) - 2*std(all_the_percentages)),'LineStyle', '--', 'Color', 'b','Label',strcat("-2 Std deviation ",string((mean(all_the_percentages) - 2*std(all_the_percentages)))))
xline((mean(all_the_percentages) - 3*std(all_the_percentages)),'LineStyle', '--', 'Color', 'b','Label',strcat("-3 Std deviation ",string((mean(all_the_percentages) - 3*std(all_the_percentages)))))

ylabel('Bin Counts')
xlabel('Percentage which meets both')
title("Distribution of Random Cross Correlation which meet R-Squared and Significance Threshold")
subtitle("Created by cross\_correlation\_bootstrap.m")
