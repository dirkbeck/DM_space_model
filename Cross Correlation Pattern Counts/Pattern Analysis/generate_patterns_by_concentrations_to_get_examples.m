% load databases
%[dbs,twdbs] = loadData;
% test
namesOfDatabases = ["Control","Stress1","Stress2"];
for currentDB = 1:length(twdbs) %cycle through the databases (AKA the Outer Loop in future comments)
    currentDatabase = twdbs{currentDB}; %get the database
    t = struct2table(currentDatabase); %turn it into a table for reading
    uniqueTaskType = unique(t.taskType); %get the unique task types within the current database
    %     disp(uniqueTaskType)

    
    %all of the following containers(maps) uses the task type and concentration as a key and pattern counts as a value
    %each container however keeps track of different things
    %paired refers to paired by granger causality which occurs in runGrangerCausality.m
    %unpaired indicates they were not paired by Granger Causality
    %EE indicated excited excited pattern
    %EI indicates Excited inhibited pattern
    %IE indicates an Inhibited Excited Pattern
    %II indicates an Inhibited Inhibited Pattern
    %NP indicates No Pattern Detected
        %The first pattern always refers to the striosome
        %the second pattern always refers to the matrix
        %Patterns are identified in plotBins.m
    %short/long indicates whether or not a trial was classified to be long or short based on the distribution of decision times of ALL data in control
    %the classification is a hard coded value found in plotBins.m and can be changed if you wish to change what is considered a long/short trial
    paired_short_ttAndCMappedToEE = containers.Map('KeyType','char','ValueType','any'); %paired short EE
    paired_short_ttAndCMappedToEI = containers.Map('KeyType','char','ValueType','any'); %paired short EI
    paired_short_ttAndCMappedToIE = containers.Map('KeyType','char','ValueType','any'); %paired short IE
    paired_short_ttAndCMappedToII = containers.Map('KeyType','char','ValueType','any'); %paired short II
    paired_short_ttAndCMappedToNP = containers.Map('KeyType','char','ValueType','any'); %paired short NP

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

    %the following containers/maps keep track of how many trials were looked at in the data set in case we ever need to un normalize the pattern counts 
    unpairedNumberOfLongTrials = containers.Map('KeyType','char','ValueType','any');
    unpairedNumberOfShortTrials = containers.Map('KeyType','char','ValueType','any');
    pairedNumberOfShortTrials = containers.Map('KeyType','char','ValueType','any');
    pairedNumberOfLongTrials =containers.Map('KeyType','char','ValueType','any');


    for ttCounter = 1:length(uniqueTaskType)                                                                    %cycle through all the taks types in the current database
        currentTaskType = uniqueTaskType{ttCounter};                                                            %get the task type
        disp(strcat("Current Task Type:", currentTaskType))                                                     %display the task type
        tableWithOnlyCurrentTaskType =  t((strcmp(string(t.taskType),string(uniqueTaskType(ttCounter)))),:);    %create a new table with the rows of the current database which contain the current task type
        concentrationsForCurrentTaskType = rmmissing(unique(tableWithOnlyCurrentTaskType.conc));                %get the a list of unique concentrations for the current task type 
        if currentDB==1 && strcmpi(currentTaskType,"EQR")                                                       %all EQR in control(database 1) are NaN, so we create this special if case to account for this
            concentrationsForCurrentTaskType = [nan];
        end
        if currentDB==2 && strcmpi(currentTaskType,"CB")                                                        %in stress 1 (database 2), CB is mostly NaN, but there are a few which are 100, we correct and make them all NaN
            concentrationsForCurrentTaskType = [nan];
        end
        disp(concentrationsForCurrentTaskType.')                                                                %disp all concentrations for the current task type

        for concCounter =1:length(concentrationsForCurrentTaskType)
            disp(strcat("Current Concentration: ", string(concentrationsForCurrentTaskType(concCounter))))      %disp the current concentration

            cd("..\Pattern Analysis")                                                                           %move into the Pattern Analysis Folder
            [cb_strio_ids, cb_matrix_ids] = find_matrix_striosome_ids(twdbs,currentTaskType,[-Inf,-Inf,-Inf,-Inf,1],concentrationsForCurrentTaskType(concCounter)); 
                                                                                                                %find neuron Ids
                                                                                                                %specificially matrix and striosome ids
                                                                                                                %a more general form of this function can be found in find_neuron_ids.m
            %         disp(cb_strio_ids{1})
            %         disp(cb_matrix_ids{1})
            cd("..\Pattern Analysis")                                                                           %move into Pattern Analysis Folder
            [~,sessionDir_neurons] = findAllSessions(twdbs,dbs);                                                %find all the session dates
            % cd("..\Pattern Analysis")

            cd("..\Pattern Analysis")                    %move back into the Pattern Analysis Folder
            [neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids); %%IMPORTANT CHANGING THIS LINE ALLOWS YOU TO DO MAKE IT MATRIX-Strio pairs, matrix matrix pairs, or strio strio pairs
                                                                                                                % by default it is set to matrix strio pairs 
                                                                                                                %OG LINE [neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids); 
                                                                                                                %get the indexes of the desired neurons in the database
            all_matrix_strio_pairs = getPairs(dbs,neuron_1_ids,neuron_2_ids,sessionDir_neurons);                %find all POSSIBLE pairs between striosome and matrix
            %         all_matrix_strio_pairs = cutDownPairsToNPairs(50,all_matrix_strio_pairs);
            all_matrix_strio_pairs = remove_neurons_connected_to_themselves(all_matrix_strio_pairs);            %remove any neurons which may be connected to themselves
            nlags=1;                                                                                            %IMPORTANT!!!!! This tells granger causality how far to look ahead, increasing this number makes it look ahead further and can chage results

            % I still need to keep track of Patterns,
            %but now I need to specify where each count is going
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

            %the following variables are intended to keep track of which patterns are being counted in which each database
            %they are cell arrays with the following structure
            %{{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}}
            %the first item in the cell array (AKA the outer cell array), is a cell array of 0s (AKA the "inner cell array")
                %the first 0 in the inner cell array will be incremented for each Excited Excited Pattern found
                %the second 0 in the innter cell array will be incremeneted for each Excited Inhibited Pattern found
                %the third 0 in the inner cell array will be incremented for each Inhibited Excited Pattern found
                %the fourth 0 in the innter cell array will be incremented for each Inhibited Inhibited Pattern found
                %the fifth 0 in the inner cell array will be incremented for each no pattern found
            %the second item in the cell array is the same as the first, but for stress 1
            %the third item in the cell array is the same as the first, but for stress 2
            %while these variables were originally built with the idea to keep track of all pattern counts across all the databases they now only ever update the current database 
                %for instance in the first run of the Outer For Loop, only the first inner cell array is updated for control
                %in the second run of the outer for loop, only the second inner cell array is updated for stress 1
                %in the third run of the outer for loop, only the third inner cell array is updated for stress 2
            %this design may change in later versions, but has been upheld due to legacy code making it too difficult to remove 
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

            currentDatabasePairs = all_matrix_strio_pairs{currentDB};   %the pairs which will be checked for connectivity using granger causality, and have their trials examined for patterns
                                                                        %the variable all_matrix_strio_pairs is a cell array of the following structure {...,...,...}
                                                                        %where each "..." represents pairs of matrix-strio neurons for a database 
                                                                        %however only the pairs belonging to the current database are examined in each of the outer-most loops
                                                                        %for instance on the first loop only the control pairs are examined
                                                                        %in the second loop only the stress pairs are examined
                                                                        %in the third loop only the stress 2 pairs are examined

            currentDatabase = twdbs{currentDB};

            for currentPair=1:height(currentDatabasePairs) %cycle through each of the potential pairs in currentDatabasePairs, this loop will be known as the "Pair Loop" in future comments 
                cd("..\Pattern Analysis") %move into pattern analysis folder
                [result,pairedLongTrialCounterCurrent,pairedShortTrialCounterCurrent,pairedWeirdlyLongTrialCounterCurrent,...
                    unpairedLongTrialCounterCurrent,unpairedShortTrialCounterCurrent,unpairedWeirdlyLongTrialCounterCurrent,...
                    pairedOrUnpaired,unpairedCountCurr,pairedCountCurr]  = runGrangerCausality_to_get_examples(currentPair,currentDatabase,currentDatabasePairs,nlags,currentDB,dbs); %
                % UPDATE THE TOTAL COUNTS
                pairedLongTrialCounter{currentDB}{1} = pairedLongTrialCounter{currentDB}{1} + pairedLongTrialCounterCurrent{currentDB}{1}; %update excited excited pattern count for paired long trials
                pairedLongTrialCounter{currentDB}{2} = pairedLongTrialCounter{currentDB}{2} + pairedLongTrialCounterCurrent{currentDB}{2}; %update excited inhibited pattern count for paired  long trials
                pairedLongTrialCounter{currentDB}{3} = pairedLongTrialCounter{currentDB}{3} + pairedLongTrialCounterCurrent{currentDB}{3}; %update inhibited excited pattern count for paired long trials
                pairedLongTrialCounter{currentDB}{4} = pairedLongTrialCounter{currentDB}{4} + pairedLongTrialCounterCurrent{currentDB}{4}; %update inhibited inhibited pattern count for paired long trials
                pairedLongTrialCounter{currentDB}{5} = pairedLongTrialCounter{currentDB}{5} + pairedLongTrialCounterCurrent{currentDB}{5}; %update no pattern count for paired long trials


                pairedShortTrialCounter{currentDB}{1} = pairedShortTrialCounter{currentDB}{1} + pairedShortTrialCounterCurrent{currentDB}{1}; %updated excited excited pattern count for paired short trials
                pairedShortTrialCounter{currentDB}{2} = pairedShortTrialCounter{currentDB}{2} + pairedShortTrialCounterCurrent{currentDB}{2}; %updated excited inhibited pattern count for paired short trials
                pairedShortTrialCounter{currentDB}{3} = pairedShortTrialCounter{currentDB}{3} + pairedShortTrialCounterCurrent{currentDB}{3}; %updated inhibited excited pattern count for paired short trials
                pairedShortTrialCounter{currentDB}{4} = pairedShortTrialCounter{currentDB}{4} + pairedShortTrialCounterCurrent{currentDB}{4}; %updated inhibited inhibited pattern count for paired short trials
                pairedShortTrialCounter{currentDB}{5} = pairedShortTrialCounter{currentDB}{5} + pairedShortTrialCounterCurrent{currentDB}{5}; %updated no pattern count for paired short trials

                pairedWeirdlyLongTrialCounter{currentDB}{1} = pairedWeirdlyLongTrialCounter{currentDB}{1} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{1}; %updated excited excited pattern count for paired weiredly long trials
                pairedWeirdlyLongTrialCounter{currentDB}{2} = pairedWeirdlyLongTrialCounter{currentDB}{2} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{2}; %updated excited inhibited pattern count for paired weiredly long trials
                pairedWeirdlyLongTrialCounter{currentDB}{3} = pairedWeirdlyLongTrialCounter{currentDB}{3} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{3}; %updated inhibited excited pattern count for paired weiredly long trials
                pairedWeirdlyLongTrialCounter{currentDB}{4} = pairedWeirdlyLongTrialCounter{currentDB}{4} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{4}; %updated inhibited inhibited pattern count for paired weiredly long trials
                pairedWeirdlyLongTrialCounter{currentDB}{5} = pairedWeirdlyLongTrialCounter{currentDB}{5} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{5}; %updated pattern count for paired weiredly long trials

                %         disp(unpairedLongTrialCounter{currentDB}{1})
                %         disp(unpairedLongTrialCounterCurrent{currentDB}{1})

                %Lines 185-202 are the same as 162-179, but for unpaired patterns
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

                pairedShortAndLongCount{currentDB}{1} = pairedShortAndLongCount{currentDB}{1} + pairedCountCurr{currentDB}{1}; %update how many short trials were found
                pairedShortAndLongCount{currentDB}{2} = pairedShortAndLongCount{currentDB}{2} + pairedCountCurr{currentDB}{2}; %update how many long trials were found

                unpairedShortAndLongCount{currentDB}{1} = unpairedShortAndLongCount{currentDB}{1} + unpairedCountCurr{currentDB}{1};
                unpairedShortAndLongCount{currentDB}{2} = unpairedShortAndLongCount{currentDB}{2} + unpairedCountCurr{currentDB}{2};

                disp(strcat("Finished Pair Number ", string(currentPair), "/",string(size(all_matrix_strio_pairs{currentDB},1))))

            end

            currentDatabase =currentDB; %switch currentDatabase from the actual table of data to just an int indicating which database we are on 1,2,3


            %all the patterns we may find
            categories = {'Strio Excited, Matrix Excited';'';'Strio Excited Matrix Inhibited';'';'Strio Inhibited, Matrix Excited';'';'Strio Inhibited, Matrix Inhibited';'';'No Pattern Detected'};

            figure
            hold on
            %all of the long pattern counts
            %first column of lcounts is the pattern counts gotten from pairs identified by granger causality
            %second column of lcounts is the pattern counts gotten from pairs not identified by granger causality 
            lcounts = [pairedLongTrialCounter{currentDatabase}{1},unpairedLongTrialCounter{currentDatabase}{1};...%first row of lcounts is excited excited patterns
                pairedLongTrialCounter{currentDatabase}{2},unpairedLongTrialCounter{currentDatabase}{2};...%second row of lcounts in excited inhibited patterns
                pairedLongTrialCounter{currentDatabase}{3},unpairedLongTrialCounter{currentDatabase}{3};... %third row of lcounts is inhibited excited patterns
                pairedLongTrialCounter{currentDatabase}{4},unpairedLongTrialCounter{currentDatabase}{4};... %fourth row of lcounts in inhibited inhibited patterns
                pairedLongTrialCounter{currentDatabase}{5},unpairedLongTrialCounter{currentDatabase}{5}]; %fifth row of lcounts is no patterns
            %         disp(lcounts)
            lcountsCol1Normalized = lcounts(:,1) ./ pairedShortAndLongCount{currentDatabase}{2}; %divide all pattern counts in first column by total number of long trials detected
            lcountsCol2Normalized = lcounts(:,2) ./ unpairedShortAndLongCount{currentDatabase}{2}; %divide all pattern counts in second column by total number of long trials detected
            lcounts = [lcountsCol1Normalized,lcountsCol2Normalized]; %put the newly normalized lcounts back together
            %         disp(lcounts)


            paired_long_ttAndCMappedToEE(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = lcounts(1,1);
            paired_long_ttAndCMappedToEI(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = lcounts(2,1);
            paired_long_ttAndCMappedToIE(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = lcounts(3,1);
            paired_long_ttAndCMappedToII(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = lcounts(4,1);
            paired_long_ttAndCMappedToNP(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = lcounts(5,1);
            pairedNumberOfLongTrials(strcat("Task Type",string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = pairedShortAndLongCount{currentDatabase}{2};


            unpaired_long_ttAndCMappedToEE(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = lcounts(1,2);
            unpaired_long_ttAndCMappedToEI(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = lcounts(2,2);
            unpaired_long_ttAndCMappedToIE(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = lcounts(3,2);
            unpaired_long_ttAndCMappedToII(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = lcounts(4,2);
            unpaired_long_ttAndCMappedToNP(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = lcounts(5,2);
            unpairedNumberOfLongTrials(strcat("Task Type",string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = unpairedShortAndLongCount{currentDatabase}{2};

            %the code below is just used to create, and format the bar chart of pattern counts for long trials
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
            %scounts is same as lcounts, but for short trials
            scounts = [pairedShortTrialCounter{currentDatabase}{1},unpairedShortTrialCounter{currentDatabase}{1};...
                pairedShortTrialCounter{currentDatabase}{2},unpairedShortTrialCounter{currentDatabase}{2};...
                pairedShortTrialCounter{currentDatabase}{3},unpairedShortTrialCounter{currentDatabase}{3};...
                pairedShortTrialCounter{currentDatabase}{4},unpairedShortTrialCounter{currentDatabase}{4};...
                pairedShortTrialCounter{currentDatabase}{5},unpairedShortTrialCounter{currentDatabase}{5}];
            scountsCol1Normalized = scounts(:,1) ./ pairedShortAndLongCount{currentDatabase}{1};
            scountsCol2Normalized = scounts(:,2) ./ unpairedShortAndLongCount{currentDatabase}{1};
            scounts = [scountsCol1Normalized,scountsCol2Normalized];


            paired_short_ttAndCMappedToEE(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = scounts(1,1);
            paired_short_ttAndCMappedToEI(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = scounts(2,1);
            paired_short_ttAndCMappedToIE(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = scounts(3,1);
            paired_short_ttAndCMappedToII(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = scounts(4,1);
            paired_short_ttAndCMappedToNP(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = scounts(5,1);
            pairedNumberOfShortTrials(strcat("Task Type",string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = pairedShortAndLongCount{currentDatabase}{1};
            unpairedNumberOfShortTrials(strcat("Task Type",string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = unpairedShortAndLongCount{currentDatabase}{1};

            unpaired_short_ttAndCMappedToEE(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = scounts(1,2);
            unpaired_short_ttAndCMappedToEI(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = scounts(2,2);
            unpaired_short_ttAndCMappedToIE(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = scounts(3,2);
            unpaired_short_ttAndCMappedToII(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = scounts(4,2);
            unpaired_short_ttAndCMappedToNP(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)))) = scounts(5,2);


            %the code below is used to create, format, save, and close the bar chart of short trial pattern counts
            bar(scounts)
            text(1:length(scounts(:,1).'),scounts(:,1).',num2str(round(scounts(:,1),2)),'vert','bottom','horiz','right')
            text(1:length(scounts(:,2).'),scounts(:,2).',num2str(round(scounts(:,2),2)),'vert','bottom','horiz','left')
            xticklabels(categories)
            title(strcat(namesOfDatabases(currentDB)," Database Pattern Counts Short Trials, paired by Granger Causality"))
            subtitle(strcat("Task Type ", string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter))))
            legend("Paired","Unpaired")

            ylim([0,5.5])

            name = strcat(namesOfDatabases(currentDB),"Short Trial Pattern Counts Task Type ",string(currentTaskType)," Concentration ", num2str(concentrationsForCurrentTaskType(concCounter)),".fig");

            %         disp(name)
            saveas(gcf,name)
            hold off
            close all
        end
    end


    %allMaps has the following structure
    %{paired Short EE, paired short EI, paired short IE, paired short II, paired short NP,
    %unpaired short EE, unpaired short EI, unpaired short IE, unpaired short II, unpaired short NP,
    %paired long EE, paired long EI, paired long IE, paired long II, paired long NP,
    %unpaired long EE, unpaired long EI, unpaired long IE, unpaired long II, paired long NP}

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


    fileSaveName = strcat("All",namesOfDatabases(currentDB),"MapsByTaskTypeAndConcentrations");
    save(fileSaveName,"allMaps")

    trialCountsFileName = strcat("All",namesOfDatabases(currentDB),"TrialCountsByTaskTypeAndConcentration");
    save(trialCountsFileName,"trialCounts")

    allTitles =["Paired Short Excited Excited","Paired Short Excited Inhibited","Paired Short Inhibited Excited","Paired Short Inhibited Inhibited", "Paired Short No Pattern",...
        "Unpaired Short Excited Excited","Unpaired Short Excited Inhibited","Unpaired Short Inhibited Excited","Unpaired Short Inhibited Inhibited", "Unaired Short No Pattern",...
        "Paired Long Excited Excited","Paired Long Excited Inhibited","Paired Long Inhibited Excited","Paired Long Inhibited Inhibited", "Paired Long No Pattern",...
        "Unpaired Long Excited Excited","Unpaired Long Excited Inhibited","Unpaired Long Inhibited Excited","Unpaired Long Inhibited Inhibited", "Unpaired Long No Pattern"
        ] ;
end