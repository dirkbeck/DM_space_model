%% load databases
[dbs,twdbs] = loadData;
namesOfDatabases = ["Control","Stress1","Stress2"];


%% Get Random pattern Counts
numberOfPairsDesired = 600;
allLongExcitedExcited = [];
allLongExcitedInhibited = [];
allLongInhibitedExcited = [];
allLongInhibitedInhibited = [];

allShortExcitedExcited = [];
allShortExcitedInhibited = [];
allShortInhibitedExcited = [];
allShortInhibitedInhibited = [];

for i=1:1000
    for currentDB = 1:1.5%length(twdbs) %cycle through the databases (AKA the Outer Loop in future comments)
        disp(namesOfDatabases(currentDB))
        currentDatabase = twdbs{currentDB}; %get the database
        t = struct2table(currentDatabase); %turn it into a table for reading
        uniqueTaskType = unique(t.taskType); %get the unique task types within the current database

        randomIndexesFromCurrentDatabase = randperm(height(t),numberOfPairsDesired); %get random indexes from the current database 1x60

        pairs = [randomIndexesFromCurrentDatabase(1:numberOfPairsDesired/2).',randomIndexesFromCurrentDatabase((numberOfPairsDesired/2)+1:end).']; %creaate 2d array of random pairs 30x2
        %     disp(pairs)

        pairedLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
        pairedShortTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
        pairedWeirdlyLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};


        %first number represents short count
        %second number reresents longCount
        %each cell array represents a database
        pairedShortAndLongCount = {{0,0},{0,0},{0,0}};


        paired_short_ttAndCMappedToEE = containers.Map('KeyType','char','ValueType','any'); %paired short EE
        paired_short_ttAndCMappedToEI = containers.Map('KeyType','char','ValueType','any'); %paired short EI
        paired_short_ttAndCMappedToIE = containers.Map('KeyType','char','ValueType','any'); %paired short IE
        paired_short_ttAndCMappedToII = containers.Map('KeyType','char','ValueType','any'); %paired short II
        paired_short_ttAndCMappedToNP = containers.Map('KeyType','char','ValueType','any'); %paired short NP

        paired_long_ttAndCMappedToEE = containers.Map('KeyType','char','ValueType','any');
        paired_long_ttAndCMappedToEI = containers.Map('KeyType','char','ValueType','any');
        paired_long_ttAndCMappedToIE = containers.Map('KeyType','char','ValueType','any');
        paired_long_ttAndCMappedToII = containers.Map('KeyType','char','ValueType','any');
        paired_long_ttAndCMappedToNP = containers.Map('KeyType','char','ValueType','any');

        pairedNumberOfShortTrials = containers.Map('KeyType','char','ValueType','any');
        pairedNumberOfLongTrials =containers.Map('KeyType','char','ValueType','any');



        for currentPairIndex = 1:height(pairs)
            currentPair = pairs(currentPairIndex,:);
            disp(currentPair)
            random_neuron_1_index = currentPair(1,1);
            random_neuron_2_index = currentPair(1,2);

            random_neuron_1 = t(random_neuron_1_index,:);
            random_neuron_2 = t(random_neuron_2_index,:);
            %disp(random_neuron_1)
            %disp(random_neuron_2)

            random_neuron_1_spikes = random_neuron_1.trial_spikes{1};
            random_neuron_2_spikes = random_neuron_2.trial_spikes{1};

            random_neuron_1_timings = random_neuron_1.trial_evt_timings{1};
            random_neuron_2_timings = random_neuron_2.trial_evt_timings{1};

            [pairedLongTrialCounterCurrent,pairedShortTrialCounterCurrent,pairedWeirdlyLongTrialCounterCurrent,...
                unpairedLongTrialCounterCurrent,unpairedShortTrialCounterCurrent,unpairedWeirdlyLongTrialCounterCurrent,...
                unpairedCountCurr,pairedCountCurr] = plotBinsForRandom(random_neuron_2_spikes,random_neuron_1_spikes,...
                random_neuron_2_timings,random_neuron_1_timings,...
                dbs,currentDB,currentPairIndex,...
                random_neuron_2_index,random_neuron_1_index,1);
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

            pairedShortAndLongCount{currentDB}{1} = pairedShortAndLongCount{currentDB}{1} + pairedCountCurr{currentDB}{1}; %update how many short trials were found
            pairedShortAndLongCount{currentDB}{2} = pairedShortAndLongCount{currentDB}{2} + pairedCountCurr{currentDB}{2}; %update how many long trials were found


            disp(strcat("Finished Pair ",string(currentPairIndex),"/",string(height(pairs))))
        end


        currentDatabase =currentDB; %switch currentDatabase from the actual table of data to just an int indicating which database we are on 1,2,3    %all the patterns we may find
        categories = categorical({'Strio Excited, Matrix Excited';'Strio Excited Matrix Inhibited';'Strio Inhibited, Matrix Excited';'Strio Inhibited, Matrix Inhibited';'No Pattern Detected'});
        categories = reordercats(categories,{'Strio Excited, Matrix Excited';'Strio Excited Matrix Inhibited';'Strio Inhibited, Matrix Excited';'Strio Inhibited, Matrix Inhibited';'No Pattern Detected'});

        figure
        hold on
        %all of the long pattern counts
        %first column of lcounts is the pattern counts gotten from pairs identified by granger causality
        %second column of lcounts is the pattern counts gotten from pairs not identified by granger causality
        lcounts = [pairedLongTrialCounter{currentDatabase}{1};...%first row of lcounts is excited excited patterns
            pairedLongTrialCounter{currentDatabase}{2};...%second row of lcounts in excited inhibited patterns
            pairedLongTrialCounter{currentDatabase}{3};... %third row of lcounts is inhibited excited patterns
            pairedLongTrialCounter{currentDatabase}{4};... %fourth row of lcounts in inhibited inhibited patterns
            pairedLongTrialCounter{currentDatabase}{5}]; %fifth row of lcounts is no patterns
        %         disp(lcounts)


        allLongExcitedExcited = [allLongExcitedExcited,lcounts(1)];
        allLongExcitedInhibited = [allLongExcitedInhibited,lcounts(2)];
        allLongInhibitedExcited = [allLongInhibitedExcited,lcounts(3)];
        allLongInhibitedInhibited = [allLongInhibitedInhibited,lcounts(4)];



        %         disp(lcounts)


        paired_long_ttAndCMappedToEE(strcat("Task Type NA Concentration NA")) = lcounts(1,1);
        paired_long_ttAndCMappedToEI(strcat("Task Type NA Concentration NA")) = lcounts(2,1);
        paired_long_ttAndCMappedToIE(strcat("Task Type NA Concentration NA")) = lcounts(3,1);
        paired_long_ttAndCMappedToII(strcat("Task Type NA Concentration NA")) = lcounts(4,1);
        paired_long_ttAndCMappedToNP(strcat("Task Type NA Concentration NA")) = lcounts(5,1);
        pairedNumberOfLongTrials(strcat("Task Type NA Concentration NA")) = pairedShortAndLongCount{currentDatabase}{2};

        bar(categories,lcounts)
        text(1:length(lcounts(:,1).'),lcounts(:,1).',num2str(round(lcounts(:,1),2)),'vert','bottom','horiz','right')
        title(strcat(dbs{currentDB}," Database Random Pattern Counts Long Trials",string(pairedShortAndLongCount{currentDatabase}{2})))

        name = strcat(dbs{currentDB}," Random Long Trial Pattern Counts Task Type NA Concentration NA.fig");
        ylim([0,2.5])
        saveas(gcf,name);
        hold off
        close all

        figure
        hold on
        %scounts is same as lcounts, but for short trials
        scounts = [pairedShortTrialCounter{currentDatabase}{1};...
            pairedShortTrialCounter{currentDatabase}{2};...
            pairedShortTrialCounter{currentDatabase}{3};...
            pairedShortTrialCounter{currentDatabase}{4};...
            pairedShortTrialCounter{currentDatabase}{5}];


        allShortExcitedExcited = [allShortExcitedExcited,scounts(1)];
        allShortExcitedInhibited = [allShortExcitedInhibited,scounts(2)];
        allShortInhibitedExcited = [allShortInhibitedExcited,scounts(3)];
        allShortInhibitedInhibited = [allShortInhibitedInhibited,scounts(4)];

        paired_short_ttAndCMappedToEE("Task Type NA Concentration NA") = scounts(1,1);
        paired_short_ttAndCMappedToEI("Task Type NA Concentration NA") = scounts(2,1);
        paired_short_ttAndCMappedToIE("Task Type NA Concentration NA") = scounts(3,1);
        paired_short_ttAndCMappedToII("Task Type NA Concentration NA") = scounts(4,1);
        paired_short_ttAndCMappedToNP("Task Type NA Concentration NA") = scounts(5,1);
        pairedNumberOfShortTrials("Task Type NA Concentration NA") = pairedShortAndLongCount{currentDatabase}{1};


        bar(categories,scounts)
        text(1:length(scounts(:,1).'),scounts(:,1).',num2str(round(scounts(:,1),2)),'vert','bottom','horiz','right')
        title(strcat(dbs{currentDB}," Database Random Pattern Counts Short Trials"),string(pairedShortAndLongCount{currentDatabase}{2}))

        name = strcat(dbs{currentDB}," Random Short Trial Pattern Counts Task Type NA Concentration NA.fig");

        %         disp(name)
        ylim([0,2.5])
        saveas(gcf,name)
        hold off
        close all

        %allMaps has the following structure
        %{paired Short EE, paired short EI, paired short IE, paired short II, paired short NP,
        %paired long EE, paired long EI, paired long IE, paired long II, paired long NP}

        allMaps = {paired_short_ttAndCMappedToEE,paired_short_ttAndCMappedToEI,paired_short_ttAndCMappedToIE,paired_short_ttAndCMappedToII,paired_short_ttAndCMappedToNP,...
            paired_long_ttAndCMappedToEE,paired_long_ttAndCMappedToEI,paired_long_ttAndCMappedToIE,paired_long_ttAndCMappedToII,paired_long_ttAndCMappedToNP};

        trialCounts = {pairedNumberOfShortTrials,pairedNumberOfLongTrials};

        fileSaveName = strcat("All",dbs{currentDB},"RandomMaps");
        save(fileSaveName,"allMaps")
    end
end