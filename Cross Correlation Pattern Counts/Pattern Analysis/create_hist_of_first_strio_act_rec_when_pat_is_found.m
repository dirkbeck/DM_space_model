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
                                                                                                                          %%LINE 62 tells you what specifically you are looking for
                                                                                                                          % by changing what ids you are putting in you change what pairs you are looking at
                                                                                                                          %the original line is the following
                                                                                                                          %[neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids);
                                                                                                                          %it looks for matrix-striosome pairs
                                                                                                                          %by changing it you can look for strio-strio or matrix-matrix pairs as well
        all_matrix_strio_pairs = getPairs(dbs,neuron_1_ids,neuron_2_ids,sessionDir_neurons);
        %         all_matrix_strio_pairs = cutDownPairsToNPairs(50,all_matrix_strio_pairs);
        all_matrix_strio_pairs = remove_neurons_connected_to_themselves(all_matrix_strio_pairs);
        nlags=1;

  

        currentDatabasePairs = all_matrix_strio_pairs{currentDB};
        currentDatabase = twdbs{currentDB};

        for currentPair=1:height(currentDatabasePairs)
            cd("..\Pattern Analysis")
            [result,~,~,~,...
                ~,~,~,...
                ~,~,pairedCountCurr,array_of_firsts]  = runGrangerCausality(currentPair,currentDatabase,currentDatabasePairs,nlags,currentDB,dbs);
            %update firstRecordedInstancesOfStrio after pattern is detected
            allTheFirstStriosomeActivityByTaskType = [allTheFirstStriosomeActivityByTaskType,array_of_firsts];
            disp(strcat("Finished Pair Number ", string(currentPair), "/",string(size(all_matrix_strio_pairs{currentDB},1))))
        end

        currentDatabase =currentDB;


        %create histogram of first recorded activity when pattern is detected
        figure;
        hold on;
        histogram(allTheFirstStriosomeActivityByTaskType,'Normalization','probability');
        title(strcat(namesOfDatabases(currentDB), " Histogram of First Strio Activity for ",string(currentTaskType)," Size of Data:",string(size(allTheFirstStriosomeActivityByTaskType,2)),".fig"))
        name = strcat(namesOfDatabases(currentDB), " Histogram of First Strio Activity for ",string(currentTaskType),".fig");
        subtitle("created by create\_hist\_of\_first\_strio\_act\_rec\_when\_pat\_is\_found.m")
        xlabel("First Recorded Spike of Strio When Pattern Is Detected")
        saveas(gcf,name);
        hold off; 
        close all;

    end
end