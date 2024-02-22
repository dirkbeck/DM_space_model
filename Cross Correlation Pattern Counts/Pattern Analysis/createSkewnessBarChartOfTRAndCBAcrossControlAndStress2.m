%% load databases
[dbs,twdbs] = loadData;

%% Create Skewness table
binSize = 100;
allTaskTypesAndConcentrationsPairedWithSkewness = containers.Map('KeyType','char','ValueType','any');
namesOfDatabases = ["Control", "Stress 1","Stress 2"];
for i=1:3.5%length(twdbs)
    currentDatabase = twdbs{i};
    t = struct2table(currentDatabase);
    uniqueTaskType = unique(t.taskType);
%     uniqueTaskType = ["TR"];
    currentTaskTypes = uniqueTaskType;
    allSkews = [];
    for currentTaskType=1:length(currentTaskTypes)
        tableWithJust1TaskType = t((strcmp(string(t.taskType),string(currentTaskTypes(currentTaskType)))),:);
        currentConcentrations = unique(tableWithJust1TaskType.conc);
        currentConcentrations = rmmissing(currentConcentrations);
        disp(strcat("Task Type: ",currentTaskTypes(currentTaskType)))
        disp(strcat("All Concentrations"))
        disp(currentConcentrations.')
        
        if isempty(currentConcentrations)
            concentrationsWithinCurrentBin = [];
        end
        if length(currentConcentrations) > 1
            for currentConcentration=1:binSize:length(currentConcentrations)
                if ~(((currentConcentration) + (binSize)) > length(currentConcentrations))
                    disp("Concentrations Within Current Bin (full): ")
                    concentrationsWithinCurrentBin = currentConcentrations(currentConcentration:((binSize-1) + (currentConcentration)));
                    disp(concentrationsWithinCurrentBin)
                else
                    disp("Concentrations Within Current Bin (Shorted): ")
                    concentrationsWithinCurrentBin = currentConcentrations((currentConcentration):end);
                    disp(concentrationsWithinCurrentBin)
                end
                disp(concentrationsWithinCurrentBin.')
                concentrationsWithinCurrentBin(concentrationsWithinCurrentBin == 50) =[];
                disp(concentrationsWithinCurrentBin.')
                modifiedTable = tableWithJust1TaskType(ismember(tableWithJust1TaskType.conc,concentrationsWithinCurrentBin),:);

                allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
                %             disp(size(allTimingsInsideModifiedTable,1))
                allCol6InModifedTable = [];
                for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
                    currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
                    allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
                end
                %             disp(allCol6InModifedTable)
                if ~isempty(allCol6InModifedTable)
                    allTaskTypesAndConcentrationsPairedWithSkewness(strcat(dbs{i}," Task Type ",string(currentTaskTypes(currentTaskType))," Concentration ",string(concentrationsWithinCurrentBin(1))," To ", string(concentrationsWithinCurrentBin(end)))) =skewness(allCol6InModifedTable);
                end
            end
        else
            modifiedTable = tableWithJust1TaskType;
            allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
            %             disp(size(allTimingsInsideModifiedTable,1))
            allCol6InModifedTable = [];
            for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
                currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
                allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
            end
            %             disp(allCol6InModifedTable)
            allTaskTypesAndConcentrationsPairedWithSkewness(strcat(dbs{i}," Task Type ",string(currentTaskTypes(currentTaskType))," Concentration NA To Na")) =skewness(allCol6InModifedTable);
        end

%         figure
%         histogram(allCol6InModifedTable)
%         theSkew = skewness(allCol6InModifedTable);
%         title(strcat(string(currentTaskTypes(currentTaskType)), string(theSkew)))
    end
end


%% display the bar charts for skewness
table_of_skew = table(string(keys(allTaskTypesAndConcentrationsPairedWithSkewness).'),...
    cell2mat(values(allTaskTypesAndConcentrationsPairedWithSkewness).'),...
    'VariableNames',{'Task Type and Conc','Skewness'});

disp(table_of_skew)
table_of_only_CB_and_TR = table_of_skew( ...
    contains(table_of_skew.("Task Type and Conc"),"TR") | ...
    (contains(table_of_skew.("Task Type and Conc"),"CB") ...
    & ~contains(table_of_skew.("Task Type and Conc"),"v CB")) ,:);
disp(table_of_only_CB_and_TR)
table_of_only_CB_and_TR = sortrows(table_of_only_CB_and_TR,"Skewness");
disp(table_of_only_CB_and_TR)

x = categorical(table_of_only_CB_and_TR.("Task Type and Conc"));
x = reordercats(x,table_of_only_CB_and_TR.("Task Type and Conc"));
bar(x,table_of_only_CB_and_TR.Skewness)

xlabel("Task Type, Concentration, and Database");
ylabel("Skeweness")
title("CB and TR Skewness across Control and Stress 2")
subtitle("Created by createSkewnessBarchartOfTRAndCBAcrossControlAndStress2.m")

%% create bar chart with only CB and TR in control and Stress 2
table_of_only_control_and_stress_2 = table_of_only_CB_and_TR(contains(table_of_only_CB_and_TR.("Task Type and Conc"), "control") | ...
    contains(table_of_only_CB_and_TR.("Task Type and Conc"), "stress2"),:);
disp(table_of_only_control_and_stress_2)
table_of_only_control_and_stress_2 = sortrows(table_of_only_control_and_stress_2,"Skewness");
x = categorical(table_of_only_control_and_stress_2.("Task Type and Conc"));
x = reordercats(x,table_of_only_control_and_stress_2.("Task Type and Conc"));
bar(x,table_of_only_control_and_stress_2.Skewness)
xlabel("Database and Skewness")
ylabel("Skewness")
title("TR and CB Across Control and Stress 2")
subtitle("Created by createSkewnessBarChartOfTRAndCBAcrossControlAndStress2.m")