% load databases
%[dbs,twdbs] = loadData;

% Create Skewness table

allTaskTypesAndConcentrationsPairedWithSkewness = containers.Map('KeyType','char','ValueType','any');
namesOfDatabases = ["Control", "Stress 1","Stress 2"];
for i=beginning_to_end_indexes(1):beginning_to_end_indexes(2)%length(twdbs)
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

%         figure
%         histogram(allCol6InModifedTable)
%         theSkew = skewness(allCol6InModifedTable);
%         title(strcat(string(currentTaskTypes(currentTaskType)), string(theSkew)))
    end
end


% display the bar charts for skewness
task_type_and_concentration = keys(allTaskTypesAndConcentrationsPairedWithSkewness).';
task_type_and_concentration = char(task_type_and_concentration);
task_type_and_concentration = strtrim(string(task_type_and_concentration));
% disp(task_type_and_concentration(2))
skews = values(allTaskTypesAndConcentrationsPairedWithSkewness).';
skews = cell2mat(skews);
% disp(skews(2));
tableOfSkewness = table(task_type_and_concentration,skews);
% disp(tableOfSkewness)
sortedTableOfSkews = sortrows(tableOfSkewness,"skews");
sortedTableOfSkews = sortedTableOfSkews(~contains(sortedTableOfSkews.task_type_and_concentration,"50"),:);
disp(sortedTableOfSkews)
figure
x = categorical(sortedTableOfSkews.task_type_and_concentration);
x = reordercats(x,sortedTableOfSkews.task_type_and_concentration);
y = sortedTableOfSkews.skews;
bar(x,y)
title(strcat(namesOfDatabases(i)," Skewness by Concentration and Task Type"))
subtitle("Created by createSkewnessBarChart.m")

