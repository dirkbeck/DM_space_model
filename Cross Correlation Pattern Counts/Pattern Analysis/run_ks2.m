%% load databases
[dbs,twdbs] = loadData;

%% Create Skewness table
binSize = 100;
allTaskTypesAndDatabasePairedWithArrayOfTTD = containers.Map('KeyType','char','ValueType','any');
%TTD stands for time to decision

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
                    allTaskTypesAndDatabasePairedWithArrayOfTTD(strcat(dbs{i}," Task Type ",string(currentTaskTypes(currentTaskType))," ",dbs{i})) =allCol6InModifedTable;
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
            allTaskTypesAndDatabasePairedWithArrayOfTTD(strcat(dbs{i}," Task Type ",string(currentTaskTypes(currentTaskType))," ",dbs{i})) =allCol6InModifedTable;
        end

    end
end


%% display the bar charts for skewness
table_of_TTD = table(string(keys(allTaskTypesAndDatabasePairedWithArrayOfTTD).'),...
    values(allTaskTypesAndDatabasePairedWithArrayOfTTD).',...
    'VariableNames',{'Task Type and Database','Array_of_TTD'});

disp(table_of_TTD)

%% run ks test of control CB vs all other control TT
clc
table_of_only_control = table_of_TTD(contains(table_of_TTD.("Task Type and Database"),'control'),:);
disp(table_of_only_control)
cb_ttd_array = cell2mat(table_of_only_control{1,2});
% disp(cb_ttd_array(1:100).')

for i=2:height(table_of_only_control)
    [h,p] =kstest2(cb_ttd_array,cell2mat(table_of_only_control{i,2}));
    disp(p)
    disp(strcat(table_of_only_control{1,1}, " Compared To ", table_of_only_control{i,1}));
    disp(strcat("h: ",num2str(h), "p: ", num2str(p)))
end

%% run ks test of control CB vs Stress TT
table_of_only_stress_1 = table_of_TTD(contains(table_of_TTD.("Task Type and Database"),'stress1'),:);
for i=1:height(table_of_only_stress_1)
    [h,p] =kstest2(cb_ttd_array,cell2mat(table_of_only_stress_1{i,2}));
    disp(strcat(table_of_only_control{1,1}, " Compared To ", table_of_only_stress_1{i,1}));
    disp(strcat("h: ",num2str(h), " p: ", num2str(p)))
end

%% run ks test of control TR vs all other Control TT
tr_ttd_array = cell2mat(table_of_only_control{4,2});
% disp(cb_ttd_array(1:100).')

for i=1:height(table_of_only_control)-1
    [h,p] =kstest2(tr_ttd_array,cell2mat(table_of_only_control{i,2}));
    disp(strcat(table_of_only_control{4,1}, " Compared To ", table_of_only_control{i,1}));
    disp(strcat("h: ",num2str(h), "p: ", num2str(p)))
end

%% run ks test of control TR vs Stress TT
for i=1:height(table_of_only_stress_1)
    [h,p] =kstest2(tr_ttd_array,cell2mat(table_of_only_stress_1{i,2}));
    disp(strcat(table_of_only_control{4,1}, " Compared To ", table_of_only_stress_1{i,1}));
    disp(strcat("h: ",num2str(h), "p: ", num2str(p)))
end

%% run ks test of control CB vs Stress 2 TT
table_of_only_stress_2 = table_of_TTD(contains(table_of_TTD.("Task Type and Database"),'stress2'),:);
for i=1:height(table_of_only_stress_2)
    [h,p] =kstest2(cb_ttd_array,cell2mat(table_of_only_stress_2{i,2}));
    disp(strcat(table_of_only_control{1,1}, " Compared To ", table_of_only_stress_2{i,1}));
    disp(strcat("h: ",num2str(h), " p: ", num2str(p)))
end

%% run ks test of control TR vs Stress 2 TT
for i=1:height(table_of_only_stress_2)
    [h,p] =kstest2(tr_ttd_array,cell2mat(table_of_only_stress_2{i,2}));
    disp(strcat(table_of_only_control{4,1}, " Compared To ", table_of_only_stress_2{i,1}));
    disp(strcat("h: ",num2str(h), " p: ", num2str(p)))
end