%Before running: 
    %Ensure that you run createSkewnessBarChart.m and have the variable sortedTableOfSkews in your workspace
    %ensure that you have AllStressMaps & allStress2Maps in your current directory
%% Load the map
% load("AllStress2Maps.mat")
% allStress2Maps = allMaps;
% 
% load("AllStressMaps.mat") 
% allStressMaps = allMaps;

load("AllControlMapsByTaskType.mat")
allStressMaps = allMaps;

% load("AllStress 1MapsByTaskType.mat")
% allStressMaps = allMaps;
% 
% load("AllStress 2MapsByTaskType.mat")
% allStressMaps = allMaps;
%% Format skews table
taskTypeAndConcentration = split(sortedTableOfSkews.task_type_and_concentration,"Concentration");
% disp(taskTypeAndConcentration)
justConcentration = taskTypeAndConcentration(:,2);
%disp(justConcentration)
taskType = taskTypeAndConcentration(:,1);
%disp(taskType)
splitConcentrationBounds = split(justConcentration(:),"To");
%disp(splitConcentrationBounds)
firstHalfOfBound = str2double(strtrim(splitConcentrationBounds(:,1)));
%disp(firstHalfOfBound)
secondHalfOfBound = str2double(strtrim(splitConcentrationBounds(:,2)));
%disp(secondHalfOfBound)

reworkedTableOfSkewness = table(taskType,firstHalfOfBound,secondHalfOfBound,sortedTableOfSkews.skews,'VariableNames',{'Task Type','Lower Bound','Upper Bound','Skews'});
%disp(reworkedTableOfSkewness)

%% Actually cycle through the pattern Counts
allTitles =["Paired Short Excited Excited","Paired Short Excited Inhibited","Paired Short Inhibited Excited","Paired Short Inhibited Inhibited", "Paired Short No Pattern",...
    "","","","", "",...
    "Paired Long Excited Excited","Paired Long Excited Inhibited","Paired Long Inhibited Excited","Paired Long Inhibited Inhibited", "Paired Long No Pattern",...
    "","","","", ""] ;
databases = ["Control","Stress ","Stress2"];
currentDB = 1;
allShortConcentrationsPatternCounts = containers.Map('KeyType','char','ValueType','any');
allLongConcentrationsPatternCounts = containers.Map('KeyType','char','ValueType','any');
for i=1:length(allStressMaps)
    disp(allTitles(i))
%     disp([keys(allStressMaps{i}).',values(allStressMaps{i}).'])
   disp(keys(allStressMaps{i}).')
   tableOfCurrentPatterns = table(strtrim(string(char(keys(allStressMaps{i}).'))),cell2mat(values(allStressMaps{i}).'),'VariableNames',{'Task Type','Pattern Count'});
   tableOfCurrentPatterns.("Task Type") = strcat(tableOfCurrentPatterns.("Task Type")," Concentration 50");
%    disp(tableOfCurrentPatterns)
%    tableOfCurrentPatterns{1,1} = "Task Type CB Concentration 75";
%    display(tableOfCurrentPatterns)
   taskTypeAndConcentration = split(tableOfCurrentPatterns(:,1).("Task Type")," Concentration");
%    disp(taskTypeAndConcentration)
   taskType = taskTypeAndConcentration(:,1);
%    disp(taskType)
   concentration = str2double(taskTypeAndConcentration(:,2));
%    disp(concentration)
   oldPatternCounts = tableOfCurrentPatterns.("Pattern Count");
   reworkedTableOfPatternCounts = table(taskType,concentration,oldPatternCounts,'VariableNames',{'Task Type','Concentration','Pattern Count'});
%    disp(reworkedTableOfPatternCounts);
    associatedSkewness = zeros(1,height(reworkedTableOfPatternCounts)) - 100000;
    for currentRowOfTableOfPC = 1:height(reworkedTableOfPatternCounts)
        currentTaskType = reworkedTableOfPatternCounts{currentRowOfTableOfPC,1};
        currentConcentration = reworkedTableOfPatternCounts{currentRowOfTableOfPC,2};
        
        nearestBin = NaN;
        distanceFromClosestBin = 10000000;
       % disp(strcat(string(currentTaskType)," Concentration: ",string(currentConcentration)))
       % disp("----------------------------------------------------------------------------------")
        liesInsideBin = false;
        for currentRowOfSkewnessTable = 1:height(reworkedTableOfSkewness)
            skewnessTaskType = strtrim(reworkedTableOfSkewness{currentRowOfSkewnessTable,1});
            concentrationLowerBound = reworkedTableOfSkewness{currentRowOfSkewnessTable,2};
            concentrationUpperBound = reworkedTableOfSkewness{currentRowOfSkewnessTable,3};
            skewOfCurrentRow = reworkedTableOfSkewness{currentRowOfSkewnessTable,4};
            if strcmpi(currentTaskType,skewnessTaskType)
                if currentConcentration >= concentrationLowerBound && currentConcentration <= concentrationUpperBound
                   % disp(strcat("The current concentration: ",string(currentConcentration)," Lies Between ",string(concentrationLowerBound)," And ",string(concentrationUpperBound)))
                    liesInsideBin = true;
                    associatedSkewness(currentRowOfTableOfPC) = skewOfCurrentRow;
                    %disp(strcat("The associated Skewness is: ",string(skewOfCurrentRow)))
                elseif currentConcentration >= concentrationUpperBound && ~liesInsideBin
                    %check how close this concentration lies to the current bin
                    %disp(strcat("The current concentration: ",string(currentConcentration)," Is greater than or equal to ",string(concentrationUpperBound)))
                    distanceFromCurrentBin = currentConcentration - concentrationUpperBound;
                    %disp(strcat("The Distance from the current Bin is: ",string(distanceFromCurrentBin)))
                    if distanceFromCurrentBin < distanceFromClosestBin
                        distanceFromClosestBin = distanceFromCurrentBin;
                        nearestBin = currentRowOfSkewnessTable;
                     %   disp(strcat("The Closest Bin has been updated to row: ",string(nearestBin)))
                    end
                elseif currentConcentration <= concentrationLowerBound && ~liesInsideBin
                    %disp(strcat("The current concentration: ",string(currentConcentration)," Is Less than or equal to ",string(concentrationLowerBound)))
                    distanceFromCurrentBin = concentrationLowerBound - currentConcentration;
                    %disp(strcat("The Distance from the current Bin is: ",string(distanceFromCurrentBin)))
                    if distanceFromCurrentBin < distanceFromClosestBin
                        distanceFromClosestBin = distanceFromCurrentBin;
                        nearestBin = currentRowOfSkewnessTable;
                     %   disp(strcat("The Closest Bin has been updated to row: ",string(nearestBin)))
                    end
                end

            end
        end
        if ~liesInsideBin
            %disp(strcat("Task Type: ", string(currentTaskType)," With Concentration: ",string(currentConcentration)," Does Not Lie inside a Bin."))
            %disp(strcat("Its distance to its nearest Bin is: ",string(distanceFromClosestBin)))
            %disp(strcat("The row of the nearest Bin in reworked table of skewness is: ",string(nearestBin)))
            %disp(strcat("The associated Skewness is: ",string(reworkedTableOfSkewness{nearestBin,4})))
            associatedSkewness(currentRowOfTableOfPC) = reworkedTableOfSkewness{nearestBin,4};
        end
    end
    reworkedTableOfPatternCounts.associated_skewness = associatedSkewness.';
    tableOfPatternCountsSortedByAssociatedSkewness = sortrows(reworkedTableOfPatternCounts,"associated_skewness");
%     disp(tableOfPatternCountsSortedByAssociatedSkewness);
    
    taskTypeAndConcentrationUnified = strcat(tableOfPatternCountsSortedByAssociatedSkewness.("Task Type")," ",string(tableOfPatternCountsSortedByAssociatedSkewness.("Concentration")));
%     disp(taskTypeAndConcentrationUnified)

    finalPatternCountTable = table(taskTypeAndConcentrationUnified,tableOfPatternCountsSortedByAssociatedSkewness.("Pattern Count"),tableOfPatternCountsSortedByAssociatedSkewness.("associated_skewness"),'VariableNames',{'Task Type and Concentration','Pattern Count','Skewness'});
%     disp(finalPatternCountTable)
    finalPatternCountTable = sortrows(finalPatternCountTable,"Skewness");
%     disp(finalPatternCountTable)

    for currentRowInPatternCountTable =1: height(finalPatternCountTable)
        if contains(allTitles(i),"Paired Short")
            if ~isKey(allShortConcentrationsPatternCounts,finalPatternCountTable{currentRowInPatternCountTable,1})
                allShortConcentrationsPatternCounts(finalPatternCountTable{currentRowInPatternCountTable,1}) = finalPatternCountTable{currentRowInPatternCountTable,2};
            else
                allShortConcentrationsPatternCounts(finalPatternCountTable{currentRowInPatternCountTable,1}) = [allShortConcentrationsPatternCounts(finalPatternCountTable{currentRowInPatternCountTable,1}),finalPatternCountTable{currentRowInPatternCountTable,2}];
            end
            
        end
        if contains(allTitles(i),"Paired Long")
            if ~isKey(allLongConcentrationsPatternCounts,finalPatternCountTable{currentRowInPatternCountTable,1})
                allLongConcentrationsPatternCounts(finalPatternCountTable{currentRowInPatternCountTable,1}) = finalPatternCountTable{currentRowInPatternCountTable,2};
            else
                allLongConcentrationsPatternCounts(finalPatternCountTable{currentRowInPatternCountTable,1}) = [allLongConcentrationsPatternCounts(finalPatternCountTable{currentRowInPatternCountTable,1}),finalPatternCountTable{currentRowInPatternCountTable,2}];
            end
        end
    end
    x = categorical(finalPatternCountTable.("Task Type and Concentration"));
    x = reordercats(x,finalPatternCountTable.("Task Type and Concentration"));
    y = finalPatternCountTable.("Pattern Count");
    figure
    bar(x,y)
    xlabel("Task Type and Concentration")
    ylabel("Pattern Counts Divided By Total Pairs Observed")
    text(1:length(y(:,1).'),y(:,1).',num2str(round(y(:,1),2)),'vert','bottom','horiz','center')
    xtickangle(0)
    title(strcat(databases(currentDB)," ",allTitles(i)))
    close(gcf)

    
end

%% Now Create a bar chart where pattern counts are grouped by their task type and concentration  SHORT TRIALS
tableOfPatternCounts = table(strtrim(string(keys(allShortConcentrationsPatternCounts).')),cell2mat(values(allShortConcentrationsPatternCounts).'),'VariableNames',{'Task Type and Concentration','Pattern Counts'});
% disp(tableOfPatternCounts)
tableOfPatternCounts = join(tableOfPatternCounts,finalPatternCountTable,'Keys',"Task Type and Concentration");
tableOfPatternCounts = sortrows(tableOfPatternCounts,"Skewness");
tableOfPatternCounts.("Pattern Count") = [];
% disp(tableOfPatternCounts);
allTheTaskTypes = [" TR "," CB "," Rev CB "," EQR "];
for i=1:length(allTheTaskTypes)
    tableOfPatternCountswithJust1TaskType = tableOfPatternCounts(contains(tableOfPatternCounts.("Task Type and Concentration"),allTheTaskTypes(i)),:);
    display(tableOfPatternCountswithJust1TaskType)
    tableOfPatternCountswithJust1TaskType = sortrows(tableOfPatternCountswithJust1TaskType,"Skewness");
    y = tableOfPatternCountswithJust1TaskType{:,"Pattern Counts"};
    y = y(:,1:4);
    x = categorical(strcat(tableOfPatternCountswithJust1TaskType.("Task Type and Concentration")," Skewness: ",string(tableOfPatternCountswithJust1TaskType.Skewness)));
    x = reordercats(x,strcat(tableOfPatternCountswithJust1TaskType.("Task Type and Concentration")," Skewness: ",string(tableOfPatternCountswithJust1TaskType.Skewness)));
    % disp(x,y)
    figure
    bar(x,y)
    xtickangle(00)
    title(strcat("Task Type: ",allTheTaskTypes(i)," Sorted By Skewness"))
    legend("Excited Excited","Excited Inhibited","Inhibited Excited", "Inhibited Inhibited")
    xlabel("Task Type and Concentration")
    ylabel("Pattern Counts Divided By Number of Pairs Observed")
    close(gcf)
end


%% Now Create a bar chart where pattern counts are grouped by their task type and concentration LONG TRIALS
tableOfPatternCounts = table(strtrim(string(keys(allLongConcentrationsPatternCounts).')),cell2mat(values(allLongConcentrationsPatternCounts).'),'VariableNames',{'Task Type and Concentration','Pattern Counts'});
% disp(tableOfPatternCounts)
tableOfPatternCounts = join(tableOfPatternCounts,finalPatternCountTable,'Keys',"Task Type and Concentration");
tableOfPatternCounts = sortrows(tableOfPatternCounts,"Skewness");
tableOfPatternCounts.("Pattern Count") = [];
% disp(tableOfPatternCounts);
allTheTaskTypes = [" TR "," CB "," Rev CB "," EQR "];
for i=1:length(allTheTaskTypes)
    tableOfPatternCountswithJust1TaskType = tableOfPatternCounts(contains(tableOfPatternCounts.("Task Type and Concentration"),allTheTaskTypes(i)),:);
    display(tableOfPatternCountswithJust1TaskType)
    tableOfPatternCountswithJust1TaskType = sortrows(tableOfPatternCountswithJust1TaskType,"Skewness");
    y = tableOfPatternCountswithJust1TaskType{:,"Pattern Counts"};
    y = y(:,1:4);
    x = categorical(strcat(tableOfPatternCountswithJust1TaskType.("Task Type and Concentration")," Skewness: ",string(tableOfPatternCountswithJust1TaskType.Skewness)));
    x = reordercats(x,strcat(tableOfPatternCountswithJust1TaskType.("Task Type and Concentration")," Skewness: ",string(tableOfPatternCountswithJust1TaskType.Skewness)));
    % disp(x,y)
    figure
    bar(x,y)
    xtickangle(0)
    title(strcat("Task Type: ",allTheTaskTypes(i)," Sorted By Skewness"))
    legend("Excited Excited","Excited Inhibited","Inhibited Excited", "Inhibited Inhibited")
    xlabel("Task Type and Concentration")
    ylabel("Pattern Counts Divided By Number of Pairs Observed")
    ylim([0,1.2])
    close(gcf)
end

%% Create Line Graphs

longOrShort = allLongConcentrationsPatternCounts;
longOrShort = allShortConcentrationsPatternCounts;

tableOfPatternCounts = table(strtrim(string(keys(longOrShort).')),cell2mat(values(longOrShort).'),'VariableNames',{'Task Type and Concentration','Pattern Counts'});
% disp(tableOfPatternCounts)
tableOfPatternCounts = join(tableOfPatternCounts,finalPatternCountTable,'Keys',"Task Type and Concentration");
tableOfPatternCounts = sortrows(tableOfPatternCounts,"Skewness");
tableOfPatternCounts.("Pattern Count") = [];
disp(tableOfPatternCounts)
x = tableOfPatternCounts.Skewness;
allys = tableOfPatternCounts.("Pattern Counts");
patternNames = ["Excited Excited","Excited Inhibited","Inhibited Excited", "Inhibited Inhibited"];
eey= allys(:,1);
eiy =allys(:,2);
iey =allys(:,3);
iiy =allys(:,4);
figure 
hold on
plot(x,eey,'-o')
plot(x,eiy,'-o')
plot(x,iey,'-o')
plot(x,iiy,'-o')
% text(x(1),eey(1),"Rev CB")
% text(x(2),eey(2),"EQR")
text(x(1),eey(1),"TR")
text(x(2),eey(2),"CB")
title("Stress 2 Short Pattern Chart")
xlabel("Skewness")
ylabel("Pattern Count")
legend(patternNames)
