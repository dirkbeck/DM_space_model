%PURPOSE: this file is meant to take the pattern counts found in generate_patterns_by_concentrations.m and display them as line graphs instead

%BEFORE RUNNING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!:
%Ensure that you run createSkewnessBarChart.m and have the variable sortedTableOfSkews in your workspace
%ensure that you have AllStressMaps & allStress2Maps in your current directory

binSize = 1;

strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn = table(nan,nan,nan,nan,nan,nan,nan,nan,...
            'VariableNames',{'Task Type and Concentration','Excited Excited','Excited Inhibited','Inhibited Excited','Inhibited Inhibited','Skewness','trial_length','database'});

%% All file names
%each item in this string array is the name of the file which contains 10 maps, each of which contains a set of maps which do pattern counts for task types and concentrations
%each file is for a different database
%these files in have their maps split by task type and concentration, but you could change them to different maps which are only split by task type instead
allFilesToLoad = ["AllControlMapsByTaskTypeAndConcentrations.mat","AllStress1MapsByTaskTypeAndConcentrations.mat","AllStress2MapsByTaskTypeAndConcentrations.mat"];

filesWithTrialCounts = ["AllControlTrialCountsByTaskTypeAndConcentration.mat","AllStress1TrialCountsByTaskTypeAndConcentration.mat","AllStress2TrialCountsByTaskTypeAndConcentrations.mat"];

% allFilesToLoad = ["AllControlMapsByTaskType.mat","AllStress1MapsByTaskType.mat","AllStress2MapsByTaskType.mat"];

taskTypeAndConcentration = split(sortedTableOfSkews.task_type_and_concentration,"Concentration"); %get task type and concentration of the sorted table of skews
% disp(taskTypeAndConcentration)
justConcentration = taskTypeAndConcentration(:,2);%store just the concentration
%disp(justConcentration)
taskType = taskTypeAndConcentration(:,1);% store just the task type
%disp(taskType)
splitConcentrationBounds = split(justConcentration(:),"To"); %split the concentration boundaries
%disp(splitConcentrationBounds)
firstHalfOfBound = str2double(strtrim(splitConcentrationBounds(:,1))); %get the lower concentration bound
%disp(firstHalfOfBound)
secondHalfOfBound = str2double(strtrim(splitConcentrationBounds(:,2))); %get the higher concentration bound
%disp(secondHalfOfBound)

reworkedTableOfSkewness = table(taskType,firstHalfOfBound,secondHalfOfBound,sortedTableOfSkews.skews,'VariableNames',{'Task Type','Lower Bound','Upper Bound','Skews'}); %reformat table of skewness so that the task type, lower bound of concentration, upper bound of concentration, and skews each have their own column



rowWithEQRInIt =0;
for i=1:height(reworkedTableOfSkewness)
    if strcmpi(reworkedTableOfSkewness{i,1},"Task Type EQR ")
        rowWithEQRInIt = i;
        break
    end
end
reworkedTableOfSkewness{rowWithEQRInIt,2} = 0; %Replace the NaN located in the same row which has EQR with a 0
reworkedTableOfSkewness{rowWithEQRInIt,3} = 100;% replace the NaN located in the row which has EQR with a 100
%disp(reworkedTableOfSkewness)

%each item in allTitles indicates what map in the variable allMaps we might be looking at
%because we do not care about the unpaired which are also stored in allMaps we leave those blank
%this is to indicate that they should be skipped 
allTitles =["Paired Short Excited Excited","Paired Short Excited Inhibited","Paired Short Inhibited Excited","Paired Short Inhibited Inhibited", "Paired Short No Pattern",...
    "","","","", "",...
    "Paired Long Excited Excited","Paired Long Excited Inhibited","Paired Long Inhibited Excited","Paired Long Inhibited Inhibited", "Paired Long No Pattern",...
    "","","","", ""] ;
databases = ["Control","Stress ","Stress2"]; %all the databases we will be used
hasConcentrations = true;   %this boolean is used to tell the function whether the task types in the current map have concentrations attached to them or not
                            %if they do not then we must add an concentration value
                            %this concentration value does not reflect the actual concentration
                            %it is only used so that we can classify the row's skewness 
for currentFile =1:length(allFilesToLoad)
    disp(databases(currentFile))
    %homeDir = cd("allMaps\");
    load(allFilesToLoad(currentFile))
    load(filesWithTrialCounts(currentFile))
    %cd(homeDir)
    %allMaps has the following structure
    %{paired Short EE, paired short EI, paired short IE, paired short II, paired short NP,
    %unpaired short EE, unpaired short EI, unpaired short IE, unpaired short II, unpaired short NP,
    %paired long EE, paired long EI, paired long IE, paired long II, paired long NP,
    %unpaired long EE, unpaired long EI, unpaired long IE, unpaired long II, paired long NP}
    %where each value in the array is a map for the specific pattern count 
    %the keys of each map is the the task type and concentration
    %the values of each map is that particular pattern count
    allStressMaps = allMaps; %store the desired map in a temp variable to be used 
    allTrialCounts = trialCounts;
    currentDB = currentFile; %store the int representing the current file also represent the current database
    allShortConcentrationsPatternCounts = containers.Map('KeyType','char','ValueType','any'); % keep track of all pattern counts of Short Trials
        %this variable is important because it contains all the pattern counts we will find for each task type and concentration
        %the keys of this map will be the task type and concentration
        %the values will be an array of doubles in the following format 
        %[value1,value2,value3,value4,value5]
        %value 1 is the Pattern count for EE
        %value 2 is the Pattern Count for EI
        %value 3 is the Pattern Count for IE
        %value 4 is the pattern count for II
        %value 5 is the pattern count for NP
        %these values will be used later when we try to convert the bar graph values to line plots
    allLongConcentrationsPatternCounts = containers.Map('KeyType','char','ValueType','any');  % keep track of all pattern counts of Long Trials

    for i=1:length(allStressMaps) %this loop will be referred to as the MapLoop
%         disp(allTitles(i)) %show which pattern you are currently looking at 
        %     disp([keys(allStressMaps{i}).',values(allStressMaps{i}).'])
%         disp(keys(allStressMaps{i}).') %show all the pattern counts in the current map 
        %table of current Patterns is a table where each row is the 
        tableOfCurrentPatterns = table(strtrim(string(char(keys(allStressMaps{i}).'))),cell2mat(values(allStressMaps{i}).'),'VariableNames',{'Task Type','Pattern Count'}); %create a table from the values and keys of the current map
        if ~hasConcentrations %if the current data has no concentration attached to it, we simply add a concentration of 50 to each row
                              %this is used to ensure that we can add a skewness to the data
                              %this doesn't alter data in any way, it just enables us to assign it a skewness
            tableOfCurrentPatterns.("Task Type") = strcat(tableOfCurrentPatterns.("Task Type")," Concentration 50");
        end
        
        %    disp(tableOfCurrentPatterns)
        if currentDB == 2
            %in database 2 (stress) CB's concentration is all NA, but in actuality it was 75 as per Alexander Friedman, so I replace the Nan with this info 
            %this is soley done, so we can split the data later
           tableOfCurrentPatterns{1,1} = "Task Type CB Concentration 75";
        end     
        %    display(tableOfCurrentPatterns)
        
        taskTypeAndConcentration = split(tableOfCurrentPatterns(:,1).("Task Type")," Concentration",2); %get the task type and concentration from tableOfCurrentPatterns
%            disp(taskTypeAndConcentration)
        taskType = taskTypeAndConcentration(:,1);%get the task type by itself
        %    disp(taskType)
        concentration = str2double(taskTypeAndConcentration(:,2));%get the concentration by itself 
        %    disp(concentration)
        oldPatternCounts = tableOfCurrentPatterns.("Pattern Count");%get the pattern counts for each task type and concentration by themselves 
        reworkedTableOfPatternCounts = table(taskType,concentration,oldPatternCounts,'VariableNames',{'Task Type','Concentration','Pattern Count'}); %create a new table where the task stype, concentration, and pattern counts are each in their own column
        
        for rowWithEQR =1:height(reworkedTableOfPatternCounts) %this for loop servs to add an concentration to EQR as by default it has none
            if strcmpi(reworkedTableOfPatternCounts{rowWithEQR,1},"Task Type EQR")
                reworkedTableOfPatternCounts{rowWithEQR,2} = 50; 
                break
            end
        end

        %    disp(reworkedTableOfPatternCounts);
        associatedSkewness = zeros(1,height(reworkedTableOfPatternCounts)) - 100000; %each item in this array will be populated with the associated skewness found in reworked table of skewness
                                                                                     %by default they are -100000, but this is only to indicate error
                                                                                     %the idea is that each row of reworkedTableOfPatternCounts has a task type and concentration
                                                                                     %with this info we can find its associated skewness by looking at the reworkedTableOfSkewness
                                                                                     %we must simpy
                                                                                     %check the task type and concentration
                                                                                     %look at reworkedTableOfSkewness to find 
                                                                                            %i) an equivalent task type
                                                                                            %ii) a range where the current concentration falls within
                                                                                    %if the current concentration does not fall within the bounds of concentrations found in reworkedTableOfSkewness
                                                                                    %then find the nearest bin and assign it the current concentration instead 
        for currentRowOfTableOfPC = 1:height(reworkedTableOfPatternCounts)
            currentTaskType = reworkedTableOfPatternCounts{currentRowOfTableOfPC,1}; %get task type of current row
            currentConcentration = reworkedTableOfPatternCounts{currentRowOfTableOfPC,2};%get concentration of current row 

            nearestBin = NaN; %make sure there is no nearest bin by default to avoid errors, but everything should have a nearest bin 
            distanceFromClosestBin = 10000000; %this variable will be used to evaluate which bin is the closest to the current concentration
            % disp(strcat(string(currentTaskType)," Concentration: ",string(currentConcentration)))
            % disp("----------------------------------------------------------------------------------")
            liesInsideBin = false; %boolean to indicate whether current row falls within a bin
            for currentRowOfSkewnessTable = 1:height(reworkedTableOfSkewness) %loop through all rows of the reworkedTableOfSkewnesss table to find the associated skewness of the currentRow in the tableOfPatternCounts
                skewnessTaskType = strtrim(reworkedTableOfSkewness{currentRowOfSkewnessTable,1}); %get the skewness task type 
                concentrationLowerBound = reworkedTableOfSkewness{currentRowOfSkewnessTable,2}; %get the lower bound of the skewness bin
                concentrationUpperBound = reworkedTableOfSkewness{currentRowOfSkewnessTable,3}; %get the upper bound of the skewness bin 
                skewOfCurrentRow = reworkedTableOfSkewness{currentRowOfSkewnessTable,4}; %get the skew of the current row of reworkedTableOfSkewness
                if strcmpi(currentTaskType,skewnessTaskType) %check if the task type 
                    if currentConcentration >= concentrationLowerBound && currentConcentration <= concentrationUpperBound %if the currentConcentration is within the bounds of the bin then we assign it an associatedSkewness
                        % disp(strcat("The current concentration: ",string(currentConcentration)," Lies Between ",string(concentrationLowerBound)," And ",string(concentrationUpperBound)))
                        liesInsideBin = true;
                        associatedSkewness(currentRowOfTableOfPC) = skewOfCurrentRow;
                        %disp(strcat("The associated Skewness is: ",string(skewOfCurrentRow)))
                    elseif currentConcentration >= concentrationUpperBound && ~liesInsideBin %if the currentConcentration is greater than the Bin's upper bound and the currentRow does not already lie inside a bin then we can update
                        %check how close this concentration lies to the current bin
                        %disp(strcat("The current concentration: ",string(currentConcentration)," Is greater than or equal to ",string(concentrationUpperBound)))
                        distanceFromCurrentBin = currentConcentration - concentrationUpperBound;
                        %disp(strcat("The Distance from the current Bin is: ",string(distanceFromCurrentBin)))
                        if distanceFromCurrentBin < distanceFromClosestBin 
                            distanceFromClosestBin = distanceFromCurrentBin;
                            nearestBin = currentRowOfSkewnessTable;
                            %   disp(strcat("The Closest Bin has been updated to row: ",string(nearestBin)))
                        end
                    elseif currentConcentration <= concentrationLowerBound && ~liesInsideBin %if the currentConcentration is less than the bin's lower bound and the currentRow does not already lie inside a bin, then we can update 
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
            if ~liesInsideBin %if we did not find a bin that the currentRow lies inside of then we its associatedSkewness is the skewness of the bin it is closest to
                %disp(strcat("Task Type: ", string(currentTaskType)," With Concentration: ",string(currentConcentration)," Does Not Lie inside a Bin."))
                %disp(strcat("Its distance to its nearest Bin is: ",string(distanceFromClosestBin)))
                %disp(strcat("The row of the nearest Bin in reworked table of skewness is: ",string(nearestBin)))
                %disp(strcat("The associated Skewness is: ",string(reworkedTableOfSkewness{nearestBin,4})))
                associatedSkewness(currentRowOfTableOfPC) = reworkedTableOfSkewness{nearestBin,4};
            end
        end
        reworkedTableOfPatternCounts.associated_skewness = associatedSkewness.'; %all a column of associatedSkewness in reworkedTableOfPatternCounts
        tableOfPatternCountsSortedByAssociatedSkewness = sortrows(reworkedTableOfPatternCounts,"associated_skewness"); %sort reworkedTableOfPatternCounts by associated_skewness column and store this new table in tableOfPatternCountsSortedByAssociatedSkewness
        %     disp(tableOfPatternCountsSortedByAssociatedSkewness);

        taskTypeAndConcentrationUnified = strcat(tableOfPatternCountsSortedByAssociatedSkewness.("Task Type")," ",string(tableOfPatternCountsSortedByAssociatedSkewness.("Concentration")));
        %     disp(taskTypeAndConcentrationUnified)

        finalPatternCountTable = table(taskTypeAndConcentrationUnified,tableOfPatternCountsSortedByAssociatedSkewness.("Pattern Count"),tableOfPatternCountsSortedByAssociatedSkewness.("associated_skewness"),'VariableNames',{'Task Type and Concentration','Pattern Count','Skewness'}); %format table
        %     disp(finalPatternCountTable)
        finalPatternCountTable = sortrows(finalPatternCountTable,"Skewness"); %sort rows of finalPatternCountTable, should be unnecessary, but just in case
        %     disp(finalPatternCountTable)

        for currentRowInPatternCountTable =1: height(finalPatternCountTable)
            if contains(allTitles(i),"Paired Short") %check if the current map is a paired short map
                if ~isKey(allShortConcentrationsPatternCounts,finalPatternCountTable{currentRowInPatternCountTable,1}) %check if the current task type and concentration has already been put into the map 
                    allShortConcentrationsPatternCounts(finalPatternCountTable{currentRowInPatternCountTable,1}) = finalPatternCountTable{currentRowInPatternCountTable,2};%if it does not then we add it to the map, with the associated pattern count
                else
                    allShortConcentrationsPatternCounts(finalPatternCountTable{currentRowInPatternCountTable,1}) = [allShortConcentrationsPatternCounts(finalPatternCountTable{currentRowInPatternCountTable,1}),finalPatternCountTable{currentRowInPatternCountTable,2}];%if it does already exist, the append the current pattern count to the end of the previously recorded pattern count
                end

            end
            if contains(allTitles(i),"Paired Long") %check if the current map is a paired long map 
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
%         figure
%         bar(x,y)
%         xlabel("Task Type and Concentration")
%         ylabel("Pattern Counts Divided By Total Pairs Observed")
%         text(1:length(y(:,1).'),y(:,1).',num2str(round(y(:,1),2)),'vert','bottom','horiz','center')
%         xtickangle(0)
%         title(strcat(databases(currentDB)," ",allTitles(i)))
%         close(gcf)


    end

    bothPatternCountMapsTogether = {allLongConcentrationsPatternCounts,allShortConcentrationsPatternCounts};
    longOrShortTitles = ["Long", "Short"];

    for longOrShort =1:length(bothPatternCountMapsTogether)
        tableOfPatternCounts = table(strtrim(string(keys(bothPatternCountMapsTogether{longOrShort}).')),cell2mat(values(bothPatternCountMapsTogether{longOrShort}).'),'VariableNames',{'Task Type and Concentration','Pattern Counts'});
        %tableOfPatternCounts
        %column 1 is the task type and concentration
        %column 2 is the associated pattern counts for that row in the followin format
        %[value1,value2,value3,value4,value5]
        %value1 = EE pattern count
        %value2 = EI pattern count
        %value3 = IE pattern count
        %value4 = II pattern count
        %value5 = NP count
        % disp(tableOfPatternCounts)
        tableOfPatternCounts = join(tableOfPatternCounts,finalPatternCountTable,'Keys',"Task Type and Concentration"); 
        %the joining done above, is to get the associated skewness, 
        % which was already found for each task type and concentration higher in this code
        %for each row of the tableOfPatternCounts
        %they are the same because the tableOfPatternCounts has they same task type and concentration column as finalPatternCountTable
        %and recall that skewness is consistent as long as the task type and concentration remain the same
        tableOfPatternCounts = sortrows(tableOfPatternCounts,"Skewness"); %sort tableOfPatternCounts by skewness 
        tableOfPatternCounts.("Pattern Count") = []; %don't confuse "Pattern Count" with "Pattern Counts" as "Pattern Counts contains the info we need "
        % disp(tableOfPatternCounts);
        allTheTaskTypes = [" TR "," CB "," Rev CB "," EQR "]; %a list of all possible task types in the database
        for i=1:length(allTheTaskTypes)
            tableOfPatternCountswithJust1TaskType = tableOfPatternCounts(contains(tableOfPatternCounts.("Task Type and Concentration"),allTheTaskTypes(i)),:);
            %get all the rows from tableOfPatternCounts which contain the current task type
            %we do this as to be able to look at how the pattern counts change in the current task type as the concentration changes 
            if height(tableOfPatternCountswithJust1TaskType) ==0 %if the table is empty skip it 
                continue
            end
%             display(tableOfPatternCountswithJust1TaskType)
            tableOfPatternCountswithJust1TaskType = sortrows(tableOfPatternCountswithJust1TaskType,"Skewness");
            y = tableOfPatternCountswithJust1TaskType{:,"Pattern Counts"}; %get the pattern counts from all the rows in tableOfPatternCountsWithJust1TaskType
            y = y(:,1:4); %remove the final column of y, because it just contains NP which we don't care about
            x = categorical(strcat(tableOfPatternCountswithJust1TaskType.("Task Type and Concentration")," Skewness: ",string(tableOfPatternCountswithJust1TaskType.Skewness)));
            x = reordercats(x,strcat(tableOfPatternCountswithJust1TaskType.("Task Type and Concentration")," Skewness: ",string(tableOfPatternCountswithJust1TaskType.Skewness)));
            % disp(x,y)
%             figure
%             bar(x,y)
%             xtickangle(00)
%             title(strcat(longOrShortTitles(longOrShort)," Task Type: ",allTheTaskTypes(i)," Sorted By Skewness"))
%             legend("Excited Excited","Excited Inhibited","Inhibited Excited", "Inhibited Inhibited")
%             xlabel("Task Type and Concentration")
%             ylabel("Pattern Counts Divided By Number of Pairs Observed")
%             close(gcf)
        end


        tableOfPatternCounts = table(strtrim(string(keys(bothPatternCountMapsTogether{longOrShort}).')),cell2mat(values(bothPatternCountMapsTogether{longOrShort}).'),'VariableNames',{'Task Type and Concentration','Pattern Counts'});
        tableOfPatternCounts = join(tableOfPatternCounts,finalPatternCountTable,'Keys',"Task Type and Concentration");
        tableOfPatternCounts = sortrows(tableOfPatternCounts,"Skewness");
        tableOfPatternCounts.("Pattern Count") = [];
        tableOfPatternCounts{:,2}(isnan(tableOfPatternCounts{:,2})) = 0;
%         disp(tableOfPatternCounts)

        allPatternCounts = tableOfPatternCounts{:,2};
        longOrShortRepeatedNTimes= cell(height(tableOfPatternCounts),1);
        longOrShortRepeatedNTimes(:) = {longOrShortTitles(longOrShort)};
        longOrShortRepeatedNTimes = string(longOrShortRepeatedNTimes);

        databaseRepeatedNTimes = cell(height(tableOfPatternCounts),1);
        databaseRepeatedNTimes(:) = {dbs{currentFile}};
        databaseRepeatedNTimes = string(databaseRepeatedNTimes);

        strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn = [strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn;...
            table(tableOfPatternCounts.("Task Type and Concentration"),allPatternCounts(:,1),allPatternCounts(:,2),allPatternCounts(:,3),allPatternCounts(:,4),tableOfPatternCounts.("Skewness"),longOrShortRepeatedNTimes,databaseRepeatedNTimes,...
            'VariableNames',{'Task Type and Concentration','Excited Excited','Excited Inhibited','Inhibited Excited','Inhibited Inhibited','Skewness','trial_length','database'})];





    end




end

theSaveNameAsMat = strcat("Strio Matrix Pattern Counts Table.mat");
theSaveNameAsXLSX = strcat("Strio Matrix Pattern Counts Table.xlsx");
save(theSaveNameAsMat,"strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn")
writetable(strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn,theSaveNameAsXLSX)