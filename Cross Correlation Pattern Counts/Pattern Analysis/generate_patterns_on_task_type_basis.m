%% load databases
[dbs,twdbs] = loadData;
%% test
namesOfDatabases = ["Control","Stress1","Stress2"];
for currentDB = 1:length(twdbs)
    currentDatabase = twdbs{currentDB};
    t = struct2table(currentDatabase);
    uniqueTaskType = unique(t.taskType);
%     disp(uniqueTaskType)


    paired_short_ttAndCMappedToEE = containers.Map('KeyType','char','ValueType','any');
    paired_short_ttAndCMappedToEI = containers.Map('KeyType','char','ValueType','any');
    paired_short_ttAndCMappedToIE = containers.Map('KeyType','char','ValueType','any');
    paired_short_ttAndCMappedToII = containers.Map('KeyType','char','ValueType','any');
    paired_short_ttAndCMappedToNP = containers.Map('KeyType','char','ValueType','any');

    unpaired_short_ttAndCMappedToEE = containers.Map('KeyType','char','ValueType','any');
    unpaired_short_ttAndCMappedToEI = containers.Map('KeyType','char','ValueType','any');
    unpaired_short_ttAndCMappedToIE = containers.Map('KeyType','char','ValueType','any');
    unpaired_short_ttAndCMappedToII = containers.Map('KeyType','char','ValueType','any');
    unpaired_short_ttAndCMappedToNP = containers.Map('KeyType','char','ValueType','any');

    paired_long_ttAndCMappedToEE = containers.Map('KeyType','char','ValueType','any');
    paired_long_ttAndCMappedToEI = containers.Map('KeyType','char','ValueType','any');
    paired_long_ttAndCMappedToIE = containers.Map('KeyType','char','ValueType','any');
    paired_long_ttAndCMappedToII = containers.Map('KeyType','char','ValueType','any');
    paired_long_ttAndCMappedToNP = containers.Map('KeyType','char','ValueType','any');

    unpaired_long_ttAndCMappedToEE = containers.Map('KeyType','char','ValueType','any');
    unpaired_long_ttAndCMappedToEI = containers.Map('KeyType','char','ValueType','any');
    unpaired_long_ttAndCMappedToIE = containers.Map('KeyType','char','ValueType','any');
    unpaired_long_ttAndCMappedToII = containers.Map('KeyType','char','ValueType','any');
    unpaired_long_ttAndCMappedToNP = containers.Map('KeyType','char','ValueType','any');

    unpairedNumberOfLongTrials = containers.Map('KeyType','char','ValueType','any');
    unpairedNumberOfShortTrials = containers.Map('KeyType','char','ValueType','any');
    pairedNumberOfShortTrials = containers.Map('KeyType','char','ValueType','any');
    pairedNumberOfLongTrials =containers.Map('KeyType','char','ValueType','any');


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

        %         %% Get Pairs
% 
%         if isempty(cb_strio_ids{2})
%             continue
%         end
        % display(cb_strio_ids)
        cd("C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Pattern Analysis")
        [neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_matrix_ids);  %%IMPORTANT
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

        %         %% The important part
        % I still need to keep track of Patterns,
        %but now I need to specify where each count is goooooooing
        %it can only be a short trial or a long trial
        %where short is anything less than or equal to 2.49329
        %and long is anything less than or equal to 4.46383 but still greater than the short trial
        %these numbers are hardcoded into plotBins.m and can be changed if the need ever arises
        %the variable shortOrLong tells us which this is
        %shortOrLong=0 : short Trial
        %shortOrLong=1: long trial
        %shortOrLong=2: this is an edge case which indicates that the trial was unusually long, likely due to artifact
        %the variable pairedOrUnpaired tells us whether or not granger causality detected the pairs to be connected or not
        %pairedOrUnpaired =1: paired
        %pairedOrUnpaired =0: unpaired

        %the structure of the following variables is as follows
        %TrialCounter(databaseNumber)(Pattern You are Counting)
        %databaseNumber = 1 - control
        %databaseNumber = 2 - stress
        %databaseNumber = 3 - stress 2
        %Pattern You Are Counting = 1: striosome excited, matrix excited
        %Pattern You Are Counting = 1: striosome excited, matrix inhibited
        %Pattern You Are Counting = 1: striosome inhibited, matrix excited
        %Pattern You Are Counting = 1: striosome inhibited, matrix inhibited

        pairedLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
        pairedShortTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
        pairedWeirdlyLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};

        unpairedLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
        unpairedShortTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
        unpairedWeirdlyLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};

        %first number represents short count
        %second number reresents longCount
        %each cell array represents a database
        pairedShortAndLongCount = {{0,0},{0,0},{0,0}};
        unpairedShortAndLongCount = {{0,0},{0,0},{0,0}};

        currentDatabasePairs = all_matrix_strio_pairs{currentDB};
        currentDatabase = twdbs{currentDB};

        for currentPair=1:height(currentDatabasePairs)
            cd("..\Pattern Analysis")
            [result,pairedLongTrialCounterCurrent,pairedShortTrialCounterCurrent,pairedWeirdlyLongTrialCounterCurrent,...
                unpairedLongTrialCounterCurrent,unpairedShortTrialCounterCurrent,unpairedWeirdlyLongTrialCounterCurrent,...
                pairedOrUnpaired,unpairedCountCurr,pairedCountCurr,array_of_firsts]  = runGrangerCausality(currentPair,currentDatabase,currentDatabasePairs,nlags,currentDB,dbs);
            %update firstRecordedInstancesOfStrio after pattern is detected
            allTheFirstStriosomeActivityByTaskType = [allTheFirstStriosomeActivityByTaskType,array_of_firsts];
            
            % UPDATE THE TOTAL COUNTS
            pairedLongTrialCounter{currentDB}{1} = pairedLongTrialCounter{currentDB}{1} + pairedLongTrialCounterCurrent{currentDB}{1};
            pairedLongTrialCounter{currentDB}{2} = pairedLongTrialCounter{currentDB}{2} + pairedLongTrialCounterCurrent{currentDB}{2};
            pairedLongTrialCounter{currentDB}{3} = pairedLongTrialCounter{currentDB}{3} + pairedLongTrialCounterCurrent{currentDB}{3};
            pairedLongTrialCounter{currentDB}{4} = pairedLongTrialCounter{currentDB}{4} + pairedLongTrialCounterCurrent{currentDB}{4};
            pairedLongTrialCounter{currentDB}{5} = pairedLongTrialCounter{currentDB}{5} + pairedLongTrialCounterCurrent{currentDB}{5};


            pairedShortTrialCounter{currentDB}{1} = pairedShortTrialCounter{currentDB}{1} + pairedShortTrialCounterCurrent{currentDB}{1};
            pairedShortTrialCounter{currentDB}{2} = pairedShortTrialCounter{currentDB}{2} + pairedShortTrialCounterCurrent{currentDB}{2};
            pairedShortTrialCounter{currentDB}{3} = pairedShortTrialCounter{currentDB}{3} + pairedShortTrialCounterCurrent{currentDB}{3};
            pairedShortTrialCounter{currentDB}{4} = pairedShortTrialCounter{currentDB}{4} + pairedShortTrialCounterCurrent{currentDB}{4};
            pairedShortTrialCounter{currentDB}{5} = pairedShortTrialCounter{currentDB}{5} + pairedShortTrialCounterCurrent{currentDB}{5};

            pairedWeirdlyLongTrialCounter{currentDB}{1} = pairedWeirdlyLongTrialCounter{currentDB}{1} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{1};
            pairedWeirdlyLongTrialCounter{currentDB}{2} = pairedWeirdlyLongTrialCounter{currentDB}{2} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{2};
            pairedWeirdlyLongTrialCounter{currentDB}{3} = pairedWeirdlyLongTrialCounter{currentDB}{3} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{3};
            pairedWeirdlyLongTrialCounter{currentDB}{4} = pairedWeirdlyLongTrialCounter{currentDB}{4} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{4};
            pairedWeirdlyLongTrialCounter{currentDB}{5} = pairedWeirdlyLongTrialCounter{currentDB}{5} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{5};

            %         disp(unpairedLongTrialCounter{currentDB}{1})
            %         disp(unpairedLongTrialCounterCurrent{currentDB}{1})
            unpairedLongTrialCounter{currentDB}{1} = unpairedLongTrialCounter{currentDB}{1} + unpairedLongTrialCounterCurrent{currentDB}{1};
            unpairedLongTrialCounter{currentDB}{2} = unpairedLongTrialCounter{currentDB}{2} + unpairedLongTrialCounterCurrent{currentDB}{2};
            unpairedLongTrialCounter{currentDB}{3} = unpairedLongTrialCounter{currentDB}{3} + unpairedLongTrialCounterCurrent{currentDB}{3};
            unpairedLongTrialCounter{currentDB}{4} = unpairedLongTrialCounter{currentDB}{4} + unpairedLongTrialCounterCurrent{currentDB}{4};
            unpairedLongTrialCounter{currentDB}{5} = unpairedLongTrialCounter{currentDB}{5} + unpairedLongTrialCounterCurrent{currentDB}{5};

            unpairedShortTrialCounter{currentDB}{1} = unpairedShortTrialCounter{currentDB}{1} + unpairedShortTrialCounterCurrent{currentDB}{1};
            unpairedShortTrialCounter{currentDB}{2} = unpairedShortTrialCounter{currentDB}{2} + unpairedShortTrialCounterCurrent{currentDB}{2};
            unpairedShortTrialCounter{currentDB}{3} = unpairedShortTrialCounter{currentDB}{3} + unpairedShortTrialCounterCurrent{currentDB}{3};
            unpairedShortTrialCounter{currentDB}{4} = unpairedShortTrialCounter{currentDB}{4} + unpairedShortTrialCounterCurrent{currentDB}{4};
            unpairedShortTrialCounter{currentDB}{5} = unpairedShortTrialCounter{currentDB}{5} + unpairedShortTrialCounterCurrent{currentDB}{5};

            unpairedWeirdlyLongTrialCounter{currentDB}{1} = unpairedWeirdlyLongTrialCounter{currentDB}{1} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{1};
            unpairedWeirdlyLongTrialCounter{currentDB}{2} = unpairedWeirdlyLongTrialCounter{currentDB}{2} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{2};
            unpairedWeirdlyLongTrialCounter{currentDB}{3} = unpairedWeirdlyLongTrialCounter{currentDB}{3} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{3};
            unpairedWeirdlyLongTrialCounter{currentDB}{4} = unpairedWeirdlyLongTrialCounter{currentDB}{4} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{4};
            unpairedWeirdlyLongTrialCounter{currentDB}{5} = unpairedWeirdlyLongTrialCounter{currentDB}{5} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{5};

            pairedShortAndLongCount{currentDB}{1} = pairedShortAndLongCount{currentDB}{1} + pairedCountCurr{currentDB}{1};
            pairedShortAndLongCount{currentDB}{2} = pairedShortAndLongCount{currentDB}{2} + pairedCountCurr{currentDB}{2};

            unpairedShortAndLongCount{currentDB}{1} = unpairedShortAndLongCount{currentDB}{1} + unpairedCountCurr{currentDB}{1};
            unpairedShortAndLongCount{currentDB}{2} = unpairedShortAndLongCount{currentDB}{2} + unpairedCountCurr{currentDB}{2};

            disp(strcat("Finished Pair Number ", string(currentPair), "/",string(size(all_matrix_strio_pairs{currentDB},1))))
        end

        currentDatabase =currentDB;


        categories = {'Strio Excited, Matrix Excited';'';'Strio Excited Matrix Inhibited';'';'Strio Inhibited, Matrix Excited';'';'Strio Inhibited, Matrix Inhibited';'';'No Pattern Detected'};

        figure
        hold on
        lcounts = [pairedLongTrialCounter{currentDatabase}{1},unpairedLongTrialCounter{currentDatabase}{1};...
            pairedLongTrialCounter{currentDatabase}{2},unpairedLongTrialCounter{currentDatabase}{2};...
            pairedLongTrialCounter{currentDatabase}{3},unpairedLongTrialCounter{currentDatabase}{3};...
            pairedLongTrialCounter{currentDatabase}{4},unpairedLongTrialCounter{currentDatabase}{4};...
            pairedLongTrialCounter{currentDatabase}{5},unpairedLongTrialCounter{currentDatabase}{5}];
        %         disp(lcounts)
        lcountsCol1Normalized = lcounts(:,1) ./ pairedShortAndLongCount{currentDatabase}{2};
        lcountsCol2Normalized = lcounts(:,2) ./ unpairedShortAndLongCount{currentDatabase}{2};
        lcounts = [lcountsCol1Normalized,lcountsCol2Normalized];
        %         disp(lcounts)
        longTrialNormalizationFactor = pairedShortAndLongCount{1}{2};
        %         disp(longTrialNormalizationFactor)

        paired_long_ttAndCMappedToEE(strcat("Task Type ", string(currentTaskType))) = lcounts(1,1);
        paired_long_ttAndCMappedToEI(strcat("Task Type ", string(currentTaskType))) = lcounts(2,1);
        paired_long_ttAndCMappedToIE(strcat("Task Type ", string(currentTaskType))) = lcounts(3,1);
        paired_long_ttAndCMappedToII(strcat("Task Type ", string(currentTaskType))) = lcounts(4,1);
        paired_long_ttAndCMappedToNP(strcat("Task Type ", string(currentTaskType))) = lcounts(5,1);
        pairedNumberOfLongTrials(strcat("Task Type",string(currentTaskType))) = pairedShortAndLongCount{currentDatabase}{2};


        unpaired_long_ttAndCMappedToEE(strcat("Task Type ", string(currentTaskType))) = lcounts(1,2);
        unpaired_long_ttAndCMappedToEI(strcat("Task Type ", string(currentTaskType))) = lcounts(2,2);
        unpaired_long_ttAndCMappedToIE(strcat("Task Type ", string(currentTaskType))) = lcounts(3,2);
        unpaired_long_ttAndCMappedToII(strcat("Task Type ", string(currentTaskType))) = lcounts(4,2);
        unpaired_long_ttAndCMappedToNP(strcat("Task Type ", string(currentTaskType))) = lcounts(5,2);
        unpairedNumberOfLongTrials(strcat("Task Type",string(currentTaskType))) = unpairedShortAndLongCount{currentDatabase}{2};

        bar(lcounts)
        text(1:length(lcounts(:,1).'),lcounts(:,1).',num2str(round(lcounts(:,1),2)),'vert','bottom','horiz','right')
        text(1:length(lcounts(:,2).'),lcounts(:,2).',num2str(round(lcounts(:,2),2)),'vert','bottom','horiz','left')
        xticklabels(categories)
        title(strcat(namesOfDatabases(currentDB)," Database Pattern Counts Long Trials, paired by Granger Causality"))
        subtitle(strcat("Task Type ", string(currentTaskType)))
        legend("Paired","Unpaired")
        ylim([0,5.5])
        name = strcat(namesOfDatabases(currentDB)," Long Trial Pattern Counts Task Type ",string(currentTaskType),".fig");
        saveas(gcf,name);
        hold off
        close all

        figure
        hold on
        scounts = [pairedShortTrialCounter{currentDatabase}{1},unpairedShortTrialCounter{currentDatabase}{1};...
            pairedShortTrialCounter{currentDatabase}{2},unpairedShortTrialCounter{currentDatabase}{2};...
            pairedShortTrialCounter{currentDatabase}{3},unpairedShortTrialCounter{currentDatabase}{3};...
            pairedShortTrialCounter{currentDatabase}{4},unpairedShortTrialCounter{currentDatabase}{4};...
            pairedShortTrialCounter{currentDatabase}{5},unpairedShortTrialCounter{currentDatabase}{5}];
        scountsCol1Normalized = scounts(:,1) ./ pairedShortAndLongCount{currentDatabase}{1};
        scountsCol2Normalized = scounts(:,2) ./ unpairedShortAndLongCount{currentDatabase}{1};
        scounts = [scountsCol1Normalized,scountsCol2Normalized];


        paired_short_ttAndCMappedToEE(strcat("Task Type ", string(currentTaskType))) = scounts(1,1);
        paired_short_ttAndCMappedToEI(strcat("Task Type ", string(currentTaskType))) = scounts(2,1);
        paired_short_ttAndCMappedToIE(strcat("Task Type ", string(currentTaskType))) = scounts(3,1);
        paired_short_ttAndCMappedToII(strcat("Task Type ", string(currentTaskType))) = scounts(4,1);
        paired_short_ttAndCMappedToNP(strcat("Task Type ", string(currentTaskType))) = scounts(5,1);
        pairedNumberOfShortTrials(strcat("Task Type",string(currentTaskType))) = pairedShortAndLongCount{currentDatabase}{1};
        unpairedNumberOfShortTrials(strcat("Task Type",string(currentTaskType))) = unpairedShortAndLongCount{currentDatabase}{1};

        unpaired_short_ttAndCMappedToEE(strcat("Task Type ", string(currentTaskType))) = scounts(1,2);
        unpaired_short_ttAndCMappedToEI(strcat("Task Type ", string(currentTaskType))) = scounts(2,2);
        unpaired_short_ttAndCMappedToIE(strcat("Task Type ", string(currentTaskType))) = scounts(3,2);
        unpaired_short_ttAndCMappedToII(strcat("Task Type ", string(currentTaskType))) = scounts(4,2);
        unpaired_short_ttAndCMappedToNP(strcat("Task Type ", string(currentTaskType))) = scounts(5,2);


        bar(scounts)
        text(1:length(scounts(:,1).'),scounts(:,1).',num2str(round(scounts(:,1),2)),'vert','bottom','horiz','right')
        text(1:length(scounts(:,2).'),scounts(:,2).',num2str(round(scounts(:,2),2)),'vert','bottom','horiz','left')
        xticklabels(categories)
        title(strcat(namesOfDatabases(currentDB)," Database Pattern Counts Short Trials, paired by Granger Causality"))
        subtitle(strcat("Task Type ", string(currentTaskType), " Concentration "))
        legend("Paired","Unpaired")

        ylim([0,5.5])

        name = strcat(namesOfDatabases(currentDB),"Short Trial Pattern Counts Task Type ",string(currentTaskType),".fig");

        %         disp(name)
        saveas(gcf,name)
        hold off
        close all
    
        %create histogram of first recorded activity
        figure;
        hold on;
        histogram(allTheFirstStriosomeActivityByTaskType);
        name = strcat(namesOfDatabases(currentDB), " Histogram of First Activity for ",string(currentTaskType),".fig");
        saveas(gcf,name);
        hold off; 
        close all;

    end



    allMaps = {paired_short_ttAndCMappedToEE,paired_short_ttAndCMappedToEI,paired_short_ttAndCMappedToIE,paired_short_ttAndCMappedToII,paired_short_ttAndCMappedToNP,...
        unpaired_short_ttAndCMappedToEE,unpaired_short_ttAndCMappedToEI,unpaired_short_ttAndCMappedToIE,unpaired_short_ttAndCMappedToII,unpaired_short_ttAndCMappedToNP,...
        paired_long_ttAndCMappedToEE,paired_long_ttAndCMappedToEI,paired_long_ttAndCMappedToIE,paired_long_ttAndCMappedToII,paired_long_ttAndCMappedToNP,...
        unpaired_long_ttAndCMappedToEE,unpaired_long_ttAndCMappedToEI,unpaired_long_ttAndCMappedToIE,unpaired_long_ttAndCMappedToII,unpaired_long_ttAndCMappedToNP
        };
    %  unpairedNumberOfLongTrials = containers.Map('KeyType','char','ValueType','any');
    %     unpairedNumberOfShortTrials = containers.Map('KeyType','char','ValueType','any');
    %     pairedNumberOfShortTrials = containers.Map('KeyType','char','ValueType','any');
    %     pairedNumberOfLongTrials =containers.Map('KeyType','char','ValueType','any');
    trialCounts = {unpairedNumberOfLongTrials,unpairedNumberOfShortTrials,pairedNumberOfShortTrials,pairedNumberOfLongTrials};


    fileSaveName = strcat("All",namesOfDatabases(currentDB),"MapsByTaskType");
    save(fileSaveName,"allMaps")

    trialCountsFileName = strcat("All",namesOfDatabases(currentDB),"TrialCountsByTaskType");
    save(trialCountsFileName,"trialCounts")

    allTitles =["Paired Short Excited Excited","Paired Short Excited Inhibited","Paired Short Inhibited Excited","Paired Short Inhibited Inhibited", "Paired Short No Pattern",...
        "Unpaired Short Excited Excited","Unpaired Short Excited Inhibited","Unpaired Short Inhibited Excited","Unpaired Short Inhibited Inhibited", "Unaired Short No Pattern",...
        "Paired Long Excited Excited","Paired Long Excited Inhibited","Paired Long Inhibited Excited","Paired Long Inhibited Inhibited", "Paired Long No Pattern",...
        "Unpaired Long Excited Excited","Unpaired Long Excited Inhibited","Unpaired Long Inhibited Excited","Unpaired Long Inhibited Inhibited", "Unpaired Long No Pattern"
        ] ;
end