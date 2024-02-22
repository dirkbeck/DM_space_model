%use this function to get approach/avoid ratio of trials in the database
%it can be split by concentration or just by task type
function [allTables] = getApproachAvoidRatios(byTaskTypeOrConcentration,twdbs)
% byTaskTypeOrConcentration - an int which tells the function whether to get the ratio of 
    %1 - get the ratio for just task type
    %2 - get the ratio for each task type and concentration
% twdbs - a 1x3 cell array where each item is a database, first is control, second is stress, third is stress2
    %the function loadData.m can create the twdbs array in the expected structure
    %please read the comments in loadData.m to call it successfully, as it needs to be altered depending on your local computer


    function[allTables] = byTaskType(dbs,twdbs)
        allTables = cell(1,3);
        for currentDB = 1:length(twdbs)
            tableOfApproachAvoid = table("nan",nan,nan,nan,nan,'VariableNames',{'task_type_and_concentration','number_of_trials','approach_choc_perc','approach_mix_perc','avoid_perc'});
            currentDatabase = twdbs{currentDB};
            disp(dbs(currentDB))
            t = struct2table(currentDatabase);
            uniqueTaskType = unique(t.taskType);
            for j=1:length(uniqueTaskType)
                disp(uniqueTaskType(j))
                taskTypeAndConcentrationTogether = strcat("Task Type ",uniqueTaskType(j)," Concentration NA");
                tableOfJustOneTaskType = t(strcmpi(t.taskType,string(uniqueTaskType(j))),:);

                allTimingsInsideOf1ConcentrationTable = tableOfJustOneTaskType.trial_evt_timings;
                allCol6In1ConcentrationTable = [];
                allCol5In1ConcentrationTable = [];
                for currentCol6 = 1: size(allTimingsInsideOf1ConcentrationTable)
                    currentTimingArray = allTimingsInsideOf1ConcentrationTable{currentCol6};
                    allCol6In1ConcentrationTable = [allCol6In1ConcentrationTable,currentTimingArray(:,6).'];
                    allCol5In1ConcentrationTable = [allCol5In1ConcentrationTable,currentTimingArray(:,5).'];
                end
                %                     disp(size(allCol6In1ConcentrationTable,2))
                numberOfTrials = size(allCol6In1ConcentrationTable,2);
                percentageOfAvoids = round(sum(allCol6In1ConcentrationTable==0) / numberOfTrials,2);
                percentageOfApproachesToChoc = round(sum(allCol6In1ConcentrationTable ~=0 & allCol5In1ConcentrationTable==2011) / numberOfTrials,2);
                percentageOfApproachesToMixture = round(sum(allCol6In1ConcentrationTable ~=0 & allCol5In1ConcentrationTable==1001) / numberOfTrials,2);
                newRow = table(taskTypeAndConcentrationTogether,numberOfTrials,percentageOfApproachesToChoc,percentageOfApproachesToMixture,percentageOfAvoids,'VariableNames',{'task_type_and_concentration','number_of_trials','approach_choc_perc','approach_mix_perc','avoid_perc'});

                tableOfApproachAvoid = [tableOfApproachAvoid;newRow];
                tableOfApproachAvoid(isnan(tableOfApproachAvoid.number_of_trials),:) = [];


            end
            disp(tableOfApproachAvoid)


        end

    end
    function[allTables] = byTaskTypeAndConcentration(dbs,twdbs)
        allTables = cell(1,3);
        for currentDB = 1:length(twdbs)
            tableOfApproachAvoid = table("nan",nan,nan,nan,nan,'VariableNames',{'task_type_and_concentration','number_of_trials','approach_choc_perc','approach_mix_perc','avoid_perc'});
            currentDatabase = twdbs{currentDB};
            disp(dbs(currentDB))
            t = struct2table(currentDatabase);
            uniqueTaskType = unique(t.taskType);
            for j=1:length(uniqueTaskType)
                disp(uniqueTaskType(j))
                tableOfJustOneTaskType = t(strcmpi(t.taskType,string(uniqueTaskType(j))),:);
                concentrationsForCurrentTaskType = rmmissing(unique(tableOfJustOneTaskType.conc));
                if strcmpi(dbs(currentDB),'control') && strcmpi(string(uniqueTaskType(j)),"EQR")
                    concentrationsForCurrentTaskType = [nan];
                end
                if strcmpi(dbs(currentDB),'stress') && strcmpi(string(uniqueTaskType(j)),"CB")
                    concentrationsForCurrentTaskType = [nan];
                end
                disp(concentrationsForCurrentTaskType.')
                
                for currentConcentration=1:length(concentrationsForCurrentTaskType)
                    taskTypeAndConcentrationTogether = strcat("Task Type ",uniqueTaskType(j)," Concentration ",num2str(concentrationsForCurrentTaskType(currentConcentration))," To ",num2str(concentrationsForCurrentTaskType(currentConcentration)));
                    if strcmpi(uniqueTaskType(j),"EQR")
                        taskTypeAndConcentrationTogether = "Task Type EQR Concentration NA To Na";
                    end
                    if ~isnan(concentrationsForCurrentTaskType(currentConcentration))
                        tableWithJust1Concentration = tableOfJustOneTaskType(tableOfJustOneTaskType.conc == concentrationsForCurrentTaskType(currentConcentration),:);
%                         disp(tableWithJust1Concentration)
                    else
                        tableWithJust1Concentration = tableOfJustOneTaskType;
                    end

                    allTimingsInsideOf1ConcentrationTable = tableWithJust1Concentration.trial_evt_timings;
                    allCol6In1ConcentrationTable = [];
                    allCol5In1ConcentrationTable = [];
                    for currentCol6 = 1: size(allTimingsInsideOf1ConcentrationTable)
                        currentTimingArray = allTimingsInsideOf1ConcentrationTable{currentCol6};
                        allCol6In1ConcentrationTable = [allCol6In1ConcentrationTable,currentTimingArray(:,6).'];
                        allCol5In1ConcentrationTable = [allCol5In1ConcentrationTable,currentTimingArray(:,5).'];
                    end
%                     disp(size(allCol6In1ConcentrationTable,2))
                    numberOfTrials = size(allCol6In1ConcentrationTable,2);
                    percentageOfAvoids = round(sum(allCol6In1ConcentrationTable==0) / numberOfTrials,2);
                    percentageOfApproachesToMixture = round(sum(allCol6In1ConcentrationTable ~=0  & allCol5In1ConcentrationTable==1001) / numberOfTrials,2);
                    percentageOfApproachesToChoc = round(sum(allCol6In1ConcentrationTable ~=0  & allCol5In1ConcentrationTable==2011) / numberOfTrials,2);

                    
                    newRow = table(taskTypeAndConcentrationTogether,numberOfTrials,percentageOfApproachesToChoc,percentageOfApproachesToMixture,percentageOfAvoids,'VariableNames',{'task_type_and_concentration','number_of_trials','approach_choc_perc','approach_mix_perc','avoid_perc'});

                    tableOfApproachAvoid = [tableOfApproachAvoid;newRow];
                    tableOfApproachAvoid(isnan(tableOfApproachAvoid.number_of_trials),:) = [];
                end
                
            end
            disp(tableOfApproachAvoid)
            allTables{currentDB} = tableOfApproachAvoid;


        end
    end

dbs = ["control","stress","stress2"];
if byTaskTypeOrConcentration == 1
    allTables = byTaskType(dbs,twdbs);
elseif byTaskTypeOrConcentration == 2
    allTables = byTaskTypeAndConcentration(dbs,twdbs);
end
end