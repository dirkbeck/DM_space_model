function [] = create_histogram_of_time_to_decision(twdbs, logOrNot,putAllPlotsTogether)
%% Create histograms of task to decision by Task Type
binSize = 100;
allTaskTypesAndConcentrationsPairedWithSkewness = containers.Map('KeyType','char','ValueType','any');
namesOfDatabases = ["Control", "Stress 1","Stress 2"];
for i=1:1.5%length(twdbs)
    allTimeToDecisions = {};
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

        end
        allTimeToDecisions{currentTaskType} = allCol6InModifedTable;
        if ~putAllPlotsTogether

            if ~logOrNot
                figure

                subplot(1,2,1)
                histogram(allCol6InModifedTable)
                theSkew = skewness(allCol6InModifedTable);
                meanOfTimeToDecision = mean(allCol6InModifedTable);
                title("Histogram of Time to Decision");
                xlabel("time (in seconds)")
                ylabel("Number of recorded times")

                subplot(1,2,2);
                cdfplot(allCol6InModifedTable);
                title("CDF of time to decision")
                xlabel("Time (seconds)")
                ylabel("Percentage")

                sgtitle(strcat(string(currentTaskTypes(currentTaskType)), " Skewness: ",string(theSkew), " Mean: ", string(meanOfTimeToDecision)));
            else
                figure

                subplot(1,2,1)
                histogram(log(abs(allCol6InModifedTable)))
                theSkew = skewness(allCol6InModifedTable);
                meanOfTimeToDecision = mean(allCol6InModifedTable);
                title("Histogram of Time to Decision");
                xlabel("Log(abs(time (in seconds)))")
                ylabel("Number of recorded times")

                subplot(1,2,2);
                cdfplot(allCol6InModifedTable);
                title("CDF of time to decision")
                xlabel("Time (seconds)")
                ylabel("Percentage")

                sgtitle(strcat(string(currentTaskTypes(currentTaskType)), " Skewness: ",string(theSkew), " Mean: ", string(meanOfTimeToDecision)));
            end
        end
    end

%     disp(allTimeToDecisions)
    if putAllPlotsTogether
        figure; hold on
        if ~logOrNot
            subplot(1,2,1)
            hold on
            histogram(allTimeToDecisions{1})
            histogram(allTimeToDecisions{2})
            histogram(allTimeToDecisions{3})
            histogram(allTimeToDecisions{4})
            title("Histogram of Time to Decision");
            xlabel("time (in seconds)")
            ylabel("Number of recorded times")
            legend("CB","EQR","Rev CB","TR")

            subplot(1,2,2);
            hold on
            cdfplot(allTimeToDecisions{1});
            cdfplot(allTimeToDecisions{2});
            cdfplot(allTimeToDecisions{3});
            cdfplot(allTimeToDecisions{4});
            title("CDF of time to decision")
            xlabel("Time (seconds)")
            ylabel("Percentage")
            legend("CB","EQR","Rev CB","TR")

            sgtitle("All Control Task Types Together");
        else
            subplot(1,2,1)
            hold on
            histogram(log(abs(allTimeToDecisions{1})))
            histogram(log(abs(allTimeToDecisions{2})))
            histogram(log(abs(allTimeToDecisions{3})))
            histogram(log(abs(allTimeToDecisions{4})))
            title("Histogram of Time to Decision");
            xlabel("Log(abs(time (in seconds)))")
            ylabel("Number of recorded times")
            legend("CB","EQR","Rev CB","TR")

            subplot(1,2,2);
            hold on
            cdfplot(allTimeToDecisions{1});
            cdfplot(allTimeToDecisions{2});
            cdfplot(allTimeToDecisions{3});
            cdfplot(allTimeToDecisions{4});

            title("CDF of time to decision")
            xlabel("Time (seconds)")
            ylabel("Percentage")
            legend("CB","EQR","Rev CB","TR")

            sgtitle("All Control Task Types Together");
        end
    end

end


end
