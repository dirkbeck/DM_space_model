%% load databases
[dbs,twdbs] = loadData;
%% Create CDFS
binSize = 1;
allTaskTypesAndConcentrationsPairedWithSkewness = containers.Map('KeyType','char','ValueType','any');

for i=1:1.5%length(twdbs)
    currentDatabase = twdbs{i};
    t = struct2table(currentDatabase);
    uniqueTaskType = unique(t.taskType);
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
                    allTaskTypesAndConcentrationsPairedWithSkewness(strcat("Task Type ",string(currentTaskTypes(currentTaskType))," Concentration ",string(concentrationsWithinCurrentBin(1))," To ", string(concentrationsWithinCurrentBin(end)))) =skewness(allCol6InModifedTable);
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
            allTaskTypesAndConcentrationsPairedWithSkewness(strcat("Task Type ",string(currentTaskTypes(currentTaskType))," Concentration NA To Na")) =skewness(allCol6InModifedTable);
        end
    end
end
close all

%% display the bar charts for skewness
task_type_and_concentration = keys(allTaskTypesAndConcentrationsPairedWithSkewness).';
task_type_and_concentration = char(task_type_and_concentration);
task_type_and_concentration = strtrim(string(task_type_and_concentration));
% disp(task_type_and_concentration(2))
skews = values(allTaskTypesAndConcentrationsPairedWithSkewness).';
skews = cell2mat(skews);
disp(skews(2));
tableOfSkewness = table(task_type_and_concentration,skews);
% disp(tableOfSkewness)
sortedTableOfSkews = sortrows(tableOfSkewness,"skews");
disp(sortedTableOfSkews)
% figure
% x = categorical(sortedTableOfSkews.task_type_and_concentration);
% x = reordercats(x,sortedTableOfSkews.task_type_and_concentration);
% y = sortedTableOfSkews.skews;
% bar(x,y)
% title("Skewness by Concentration and Task Type")

%% Create bar charts for each individual task type
allTaskTypes = [" TR ", "e CB "," Rev CB ", " EQR "]; 
for theCurrentTaskType =1:length(allTaskTypes)
    trTable = sortedTableOfSkews(contains(sortedTableOfSkews.task_type_and_concentration,allTaskTypes(theCurrentTaskType)),:);
    figure
    x = categorical(trTable.task_type_and_concentration);
    x = reordercats(x,trTable.task_type_and_concentration);
    y = trTable.skews;
    bar(x,y)
    ylabel("Skews")
    xlabel("Concentration")
    title(allTaskTypes(theCurrentTaskType))
end
