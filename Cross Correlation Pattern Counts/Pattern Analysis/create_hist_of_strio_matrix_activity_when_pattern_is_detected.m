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
        array_exc_strio_patt_times = [];
        array_inh_strio_patt_times = [];
        array_exc_mat_patt_times = [];
        array_inh_mat_patt_times = [];


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
                ~,~,pairedCountCurr,...
                array_exc_strio_patt_times_new,array_inh_strio_patt_times_new,array_exc_mat_patt_times_new,array_inh_mat_patt_times_new]  = gcModified4_create_hist_of_strio_mat_act_when_pat_is_det(currentPair,currentDatabase,currentDatabasePairs,nlags,currentDB,dbs);
           %update the first recorded times 
           array_exc_strio_patt_times = [array_exc_strio_patt_times,array_exc_strio_patt_times_new];
           array_inh_strio_patt_times = [array_inh_strio_patt_times,array_inh_strio_patt_times_new];
           array_exc_mat_patt_times = [array_exc_mat_patt_times,array_exc_mat_patt_times_new];
           array_inh_mat_patt_times = [array_inh_mat_patt_times,array_inh_mat_patt_times_new];
            disp(strcat("Finished Pair Number ", string(currentPair), "/",string(size(all_matrix_strio_pairs{currentDB},1))))
        end

        currentDatabase =currentDB;


        %create histogram of strio and matrix's first recorded time whenever an excited pattern is detected in both  
        figure;
        subplot(2,1,1);
        hold on;
        histogram(array_exc_strio_patt_times,100,'Normalization','probability');
        xlabel('First Recorded Spike IF pattern was detected')
        ylabel('Bin Counts')
        ylim([0,1])
        title(strcat(namesOfDatabases(currentDB), " Histogram of First Recorded Strio Activity When Exc Pattern is detected ",string(currentTaskType)," Size of Data:",string(size(array_exc_strio_patt_times,2))))
        name = strcat(namesOfDatabases(currentDB), " Histogram of First Strio Matrix Activity When Exc Pattern is Detected for ",string(currentTaskType),".fig");
        subtitle("created by create_hist_of_strio_matrix_activity_when_pattern_is_detected.m")

        subplot(2,1,2);
        hold on;
        histogram(array_exc_mat_patt_times,100,'Normalization','probability');
        xlabel('First Recorded Spike IF pattern was detected')
        ylabel('Bin Counts')
        ylim([0,1])
        title(strcat(namesOfDatabases(currentDB), " Histogram of First Recorded Matrix Activity When Exc Pattern is detected ",string(currentTaskType)," Size of Data:",string(size(array_exc_mat_patt_times,2))))
        subtitle("created by create_hist_of_strio_matrix_activity_when_pattern_is_detected.m")
        saveas(gcf,name);
        hold off; 
        close all;


        %create histogram of strio and matrix's first recorded time whenever an inh pattern is detected in both  
        figure;
        subplot(2,1,1);
        hold on;
        histogram(array_inh_strio_patt_times,100,'Normalization','probability');
        xlabel('First Recorded Spike IF pattern was detected')
        ylabel('Bin Counts')
        ylim([0,1])
        title(strcat(namesOfDatabases(currentDB), " Histogram of First Recorded Strio Activity When Inh Pattern is detected ",string(currentTaskType)," Size of Data:",string(size(array_inh_strio_patt_times,2))))
        name = strcat(namesOfDatabases(currentDB), " Histogram of First Strio Matrix Activity When Inh Pattern is Detected for ",string(currentTaskType),".fig");
        subtitle("created by create_hist_of_strio_matrix_activity_when_pattern_is_detected.m")

        subplot(2,1,2);
        hold on;
        histogram(array_inh_mat_patt_times,100,'Normalization','probability');
        xlabel('First Recorded Spike IF pattern was detected')
        ylabel('Bin Counts')
        ylim([0,1])
        title(strcat(namesOfDatabases(currentDB), " Histogram of First Recorded Matrix Activity When Inh Pattern is detected ",string(currentTaskType)," Size of Data:",string(size(array_inh_mat_patt_times,2))))
        subtitle("created by create_hist_of_strio_matrix_activity_when_pattern_is_detected.m")
        saveas(gcf,name);
        hold off; 
        close all;

        %create histogram of strio and matrix's first recorded time whenever an inhibited pattern is detected in both  

    end
end