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

%% load databases
home = cd("..\Pattern Analysis");
[dbs,twdbs] = loadData;
cd(home)
%% Create Skewness table
binSize = 1;
logOrNot = false;
allTaskTypesAndConcentrationsPairedWithSkewness = containers.Map('KeyType','char','ValueType','any');
namesOfDatabases = ["Control", "Stress 1","Stress 2"];
dictionary_of_edges = containers.Map('KeyType','char','ValueType','any');
dictionary_of_bin_counts = containers.Map('KeyType','char','ValueType','any');
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
                else

                    histogram(approachesToMixture,linspace(0,600,6000))
                    
                    [N,edges] = histcounts(approachesToMixture,linspace(0,600,6000));
                    dictionary_of_bin_counts(strcat(string(currentTaskTypes(currentTaskType)),num2str(currentConcentrations(currentConcentration)), " Approach To Mixture")) = N;
                    dictionary_of_edges(strcat(string(currentTaskTypes(currentTaskType)), num2str(currentConcentrations(currentConcentration))," Approach To Mixture")) = edges;
                    y1 =pdf('Normal',N(1:100),mean(N(1:100)),std(N(1:100)));
%                     plot(N(1:100),y1,'LineWidth',2)
                    xlim([0,10])

                    histogram(approachesToChoc,linspace(0,600,6000))
                    [N,edges] = histcounts(approachesToChoc,linspace(0,600,6000));
                    dictionary_of_bin_counts(strcat(string(currentTaskTypes(currentTaskType)),num2str(currentConcentrations(currentConcentration)), " Approach To Choc")) = N;
                    dictionary_of_edges(strcat(string(currentTaskTypes(currentTaskType)), num2str(currentConcentrations(currentConcentration)), " Approach To Choc")) = edges;
                    y2 =pdf('Normal',N(1:100),mean(N(1:100)),std(N(1:100)));
%                     plot(N(1:100),y2,'LineWidth',2)
                    xlim([0,10])
                    xlabel("Time to Decision")
                end
                
                theMixtureSkew = skewness(approachesToMixture);
                theChocSkew = skewness(approachesToChoc);
                title(strcat(string(currentTaskTypes(currentTaskType)), " Mixture Skewness:",num2str(theMixtureSkew), " Choc Skewness:",num2str(theChocSkew)," Concentration:", num2str(currentConcentrations(currentConcentration))))
                legend(strcat('Approach Mixture',num2str(mean(approachesToMixture))),strcat('Approach to Choc',num2str(mean(approachesToChoc))))
                subtitle("Created by createHistogramsByTaskTypeOrConcentration.m")
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
            histogram(approachesToMixture,linspace(0,600,6000))
            histogram(approachesToChoc,linspace(0,600,6000))
            xlim([0,10])
            title(strcat(string(currentTaskTypes(currentTaskType)), " Mixture Skewness:",string(theMixtureSkew), " Choc Skewness:",string(theChocSkew)))
            subtitle("Created by createHistogramsByTaskTypeOrConcentration.m")
            legend(strcat('Approach Mixture ',string(mean(approachesToMixture))),strcat('Approach Choc ',string(mean(approachesToChoc))))
            ylabel("clc" + ...
                "Bin Count")
            xlabel("Time To Decision")


            [N,edges] = histcounts(approachesToMixture,linspace(0,600,6000));
            dictionary_of_bin_counts(strcat(string(currentTaskTypes(currentTaskType)), " Approach To Mixture")) = N;
            dictionary_of_edges(strcat(string(currentTaskTypes(currentTaskType)),  " Approach To Mixture")) = edges;
            y1 =pdf('Normal',1:0.1:1000,mean(N(1:1000)),std(N(1:1000)));
           % figure; hold on;
%             plot(1:0.1:1000,y1,'LineWidth',2)
%             xlim([0,10])
            title(strcat(string(currentTaskTypes(currentTaskType)), " Mixture PDF"))
            subtitle("Created by createHistogramsByTaskTypeOrConcentration.m")
            xlabel("Time To Decision")
            ylabel("Bin Size")

           % figure; hold on;
            [N,edges] = histcounts(approachesToChoc,linspace(0,600,6000));
            dictionary_of_bin_counts(strcat(string(currentTaskTypes(currentTaskType)), " Approach To Choc")) = N;
            dictionary_of_edges(strcat(string(currentTaskTypes(currentTaskType)),  " Approach To Choc")) = edges;
            y2 =pdf('Normal',1:0.1:1000,mean(N(1:1000)),std(N(1:1000)));
%             plot(1:0.1:1000,y2,'LineWidth',2)
%             xlim([0,10])
            title(strcat(string(currentTaskTypes(currentTaskType)), " Chocolate PDF"))
            subtitle("Created by createHistogramsByTaskTypeOrConcentration.m")
            xlabel("Time to Decision")
            ylabel("Bin Size")


            theMixtureSkew = skewness(approachesToMixture);
            theChocSkew = skewness(approachesToChoc);



            
            hold off
        end


    end
end



