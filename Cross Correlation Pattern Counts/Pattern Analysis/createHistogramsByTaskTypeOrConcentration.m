%% Description
%this code can be used to create histograms of the distribution of selection 
%for each task type and concentration 2 histograms will be produced
%1st will be for the rat choosing left
%2nd will be for rat choosing right
%by adjusting the binSize variable you can specify whether you want to look at data on a task type level or concentration level or something in between
%binSize=100 will automatically look at taskType level
%binSize=1 will look at things on an individual concentration level 
%binSize=2 will pair 2 adjacent concentrations together
%binSize=n will put n concentrations together
%if there are not enough concentrations to split evenly between bins the last bin will have the fewest number of concentrations in it

% load databases
%[dbs,twdbs] = loadData;
% Create Skewness table
%binSize = 100;
logOrNot = false;
allTaskTypesAndConcentrationsPairedWithSkewness = containers.Map('KeyType','char','ValueType','any');
namesOfDatabases = ["Control", "Stress 1","Stress 2"];
for i=1:1.5%length(twdbs)
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
                allCol5In1ConcentrationTable = [];
                for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
                    currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
                    allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
                    allCol5In1ConcentrationTable = [allCol5In1ConcentrationTable,currentTimingArray(:,5).'];
                end
                %             disp(allCol6InModifedTable)
                if ~isempty(allCol6InModifedTable)
                    allTaskTypesAndConcentrationsPairedWithSkewness(strcat("Task Type ",string(currentTaskTypes(currentTaskType))," Concentration ",string(concentrationsWithinCurrentBin(1))," To ", string(concentrationsWithinCurrentBin(end)))) =skewness(allCol6InModifedTable);
                end
                approachesToMixture = allCol6InModifedTable(allCol6InModifedTable ~=0  & allCol5In1ConcentrationTable==1001);
                approachesToChoc = allCol6InModifedTable(allCol6InModifedTable ~=0  & allCol5In1ConcentrationTable==2011);
                figure;hold on;
                if logOrNot
                    histogram(log(abs(approachesToMixture)),linspace(0,max(log(abs(allCol6InModifedTable)),[],'all'),30))
                    histogram(log(abs(approachesToChoc)),linspace(0,max(log(abs(allCol6InModifedTable)),[],'all'),30))
                    xlabel("Log(Abs(Time to Decision))")
                    xlim([0,10])
                else
                    histogram(approachesToMixture,linspace(0,600,6000))
                    histogram(approachesToChoc,linspace(0,600,6000))
                    xlabel("Time to Decision")
                    xlim([0,10])
                end
                
                theMixtureSkew = skewness(approachesToMixture);
                theChocSkew = skewness(approachesToChoc);
                title(strcat(string(currentTaskTypes(currentTaskType)), " Mixture Skewness:",string(theMixtureSkew), " Choc Skewness:",string(theChocSkew)))
                legend('Approach Mixture','Approach Choc')

                ylabel("Bin Count")
                hold off
            end
        else
            modifiedTable = tableWithJust1TaskType;
            allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
            %             disp(size(allTimingsInsideModifiedTable,1))
            allCol6InModifedTable = [];
            allCol5In1ConcentrationTable = [];
            for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
                currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
                allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
                allCol5In1ConcentrationTable = [allCol5In1ConcentrationTable,currentTimingArray(:,5).'];
            end
            %             disp(allCol6InModifedTable)
            allTaskTypesAndConcentrationsPairedWithSkewness(strcat("Task Type ",string(currentTaskTypes(currentTaskType))," Concentration NA To Na")) =skewness(allCol6InModifedTable);
            approachesToMixture = allCol6InModifedTable(allCol6InModifedTable ~=0  & allCol5In1ConcentrationTable==1001);
            approachesToChoc = allCol6InModifedTable(allCol6InModifedTable ~=0  & allCol5In1ConcentrationTable==2011);
            figure;hold on;
            if logOrNot
                histogram(log(abs(approachesToMixture)),linspace(0,max(log(abs(allCol6InModifedTable)),[],'all'),30))
                histogram(log(abs(approachesToChoc)),linspace(0,max(log(abs(allCol6InModifedTable)),[],'all'),30))
                xlim([0,10])
                xlabel("Log(Abs(Time to Decision))")
            else
                histogram(approachesToMixture,linspace(0,600,6000))
                histogram(approachesToChoc,linspace(0,600,6000))
                xlim([0,10])
                xlabel("Time to Decision")
            end
            
            theMixtureSkew = skewness(approachesToMixture);
            theChocSkew = skewness(approachesToChoc);
            title(strcat(string(currentTaskTypes(currentTaskType)), " Mixture Skewness:",string(theMixtureSkew), " Choc Skewness:",string(theChocSkew)))
            legend('Approach Mixture','Approach Choc')
            
            ylabel("Bin Count")
            hold off
        end


    end
end



