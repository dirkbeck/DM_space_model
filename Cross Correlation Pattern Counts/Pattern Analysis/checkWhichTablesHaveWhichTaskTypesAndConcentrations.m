%% test
namesOfDatabases = ["Control","Stress1","Stress2"];
for currentDB = 1:length(twdbs)
    currentDatabase = twdbs{currentDB};
    disp(namesOfDatabases(currentDB))
    t = struct2table(currentDatabase);
    uniqueTaskType = unique(t.taskType);
    for j=1:length(uniqueTaskType)
        disp(uniqueTaskType(j))
        tableOfJustOneTaskType = t(strcmpi(t.taskType,string(uniqueTaskType(j))),:);
        concentrationsForCurrentTaskType = rmmissing(unique(tableOfJustOneTaskType.conc));
        disp(concentrationsForCurrentTaskType.')
    end


end