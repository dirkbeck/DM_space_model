%% load databases
[dbs,twdbs] = loadData;
%% test
namesOfDatabases = ["Control","Stress1","Stress2"];
for currentDB = 1:1.5%length(twdbs)
    currentDatabase = twdbs{currentDB};
    t = struct2table(currentDatabase);
    uniqueTaskType = unique(t.taskType);
%     disp(uniqueTaskType)

    for ttCounter = 1:length(uniqueTaskType)
        allTheFirstStriosomeActivityByTaskType = [];
        currentTaskType = uniqueTaskType{ttCounter};
        disp(strcat("Current Task Type:", currentTaskType))
        tableWithOnlyCurrentTaskType =  t((strcmp(string(t.taskType),string(uniqueTaskType(ttCounter)))),:);

        cd("..\Pattern Analysis")
        [cb_strio_ids, cb_matrix_ids] = find_matrix_striosome_ids(twdbs,currentTaskType,[-Inf,-Inf,-Inf,-Inf,1],NaN); %find neuron Ids
        %         disp(cb_strio_ids{1})
        %         disp(cb_matrix_ids{1})
        cd("..\Pattern Analysis")
        [~,sessionDir_neurons] = findAllSessions(twdbs,dbs);
        % cd("..\Pattern Analysis")

        cd("C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Pattern Analysis")
        [neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids);  %%IMPORTANT
                                                                                              %by changing it you can look for strio-strio or matrix-matrix pairs as well
        all_matrix_strio_pairs = getPairs(dbs,neuron_1_ids,neuron_2_ids,sessionDir_neurons);
        %         all_matrix_strio_pairs = cutDownPairsToNPairs(50,all_matrix_strio_pairs);
        all_matrix_strio_pairs = remove_neurons_connected_to_themselves(all_matrix_strio_pairs);
        nlags=1;
        currentDatabasePairs = all_matrix_strio_pairs{currentDB};
        currentDatabase = twdbs{currentDB};

        array_of_z_scores_for_strio = [];
        array_of_z_scores_for_matrix = []; 
        for currentPair=1:height(currentDatabasePairs)
            cd("..\Pattern Analysis")
            [result,pairedCountCurr,array_of_firsts,neuron_1_z_score,neuron_2_z_score]  = runGrangerCausalityOnlyToGetDistOfAvgActWithinRange(currentPair,currentDatabase,currentDatabasePairs,nlags,currentDB,dbs);
            %update firstRecordedInstancesOfStrio after pattern is detected
            allTheFirstStriosomeActivityByTaskType = [allTheFirstStriosomeActivityByTaskType,array_of_firsts];
            disp(strcat("Finished Pair Number ", string(currentPair), "/",string(size(all_matrix_strio_pairs{currentDB},1))))

            array_of_z_scores_for_matrix = [array_of_z_scores_for_matrix,neuron_1_z_score];
            array_of_z_scores_for_strio = [array_of_z_scores_for_strio,neuron_2_z_score];
        end

        currentDatabase =currentDB;


        %create histogram of first recorded activity when pattern is detected
        figure;
        hold on;
        h = histogram(array_of_z_scores_for_strio,'Normalization','probability');
        xlim([-0.6,1.2])
        ylim([0,1])
%         a = h.Values;
%         a = a/sum(a,"all");
%         histogram(a);

%         histogram(array_of_z_scores_for_matrix);
        title(strcat(namesOfDatabases(currentDB), " Histogram of Z-Scores of Strio and Matrix Activity for ",string(currentTaskType)," Size of Data:",string(size(array_of_z_scores_for_matrix,2)),".fig"))
        name = strcat(namesOfDatabases(currentDB), " Histogram of Z-Scores of Strio and Matrix Activity for ",string(currentTaskType),".fig");
        legend("Strio Activity", "Matrix Activity")
        xlabel("Z-Score")
        ylabel("Bin Count")
        subtitle("created by create\_hist\_of\_avg\_strio\_mat\_act\_by\_task\_type\_by\_range.m")
%         saveas(gcf,name);
        hold off; 
%         close all;

    end
end