% load databases
%[dbs,twdbs] = loadData;
% Create CDFS
allTaskTypesAndConcentrationsPairedWithSkewness = containers.Map('KeyType','char','ValueType','any');
allTaskTypesAndConcentrationsPairedWith20thPercentiles = containers.Map('KeyType','char','ValueType','any');
allTaskTypesAndConcentrationsPairedWith90thPercentiles = containers.Map('KeyType','char','ValueType','any');
for i=1:1.5%length(twdbs)
    currentDatabase = twdbs{i};
    t = struct2table(currentDatabase);
    uniqueTaskType = unique(t.taskType);
    %     disp(i)
    %     disp(uniqueConcentrations)
    %     disp(uniqueTaskType)
    currentTaskTypes = uniqueTaskType;

    for currentTaskType=1:length(currentTaskTypes)
        figure
        hold on
        tableWithJust1TaskType = t((strcmp(string(t.taskType),string(currentTaskTypes(currentTaskType)))),:);
        currentConcentrations = unique(tableWithJust1TaskType.conc);
        currentConcentrations = rmmissing(currentConcentrations);
        
        if ~isempty(currentConcentrations)
            allSkews = [];
            for currentConcentration=1:length(currentConcentrations)
                modifiedTable = tableWithJust1TaskType(currentConcentrations(currentConcentration) == tableWithJust1TaskType.conc,:);
                %             disp(strcat("Expected Task Type: ",string(currentTaskTypes(currentTaskType))," Expected Concentration",string(currentConcentrations(currentConcentration))))
                %             disp(table(modifiedTable.taskType,modifiedTable.conc))
                allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
                %             disp(size(allTimingsInsideModifiedTable,1))
                allCol6InModifedTable = [];
                for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
                    currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
                    allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
                end
                %             disp(allCol6InModifedTable)
                if ~isempty(allCol6InModifedTable)
                    cdfplot(allCol6InModifedTable)
                    allTaskTypesAndConcentrationsPairedWith90thPercentiles(strcat(string(currentTaskTypes(currentTaskType))," ",string(currentConcentrations(currentConcentration)))) = prctile(allCol6InModifedTable,90);
                    allTaskTypesAndConcentrationsPairedWith20thPercentiles(strcat(string(currentTaskTypes(currentTaskType))," ",string(currentConcentrations(currentConcentration)))) = prctile(allCol6InModifedTable,20);
                    allSkews = [allSkews,skewness(allCol6InModifedTable)];
                end
            end
        else
            modifiedTable = t((strcmp(string(tableWithJust1TaskType.taskType),string(currentTaskTypes(currentTaskType)))),:);
            allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
            %             disp(size(allTimingsInsideModifiedTable,1))
            allCol6InModifedTable = [];
            for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
                currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
                allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
            end
            %             disp(allCol6InModifedTable)
            if ~isempty(allCol6InModifedTable)
                cdfplot(allCol6InModifedTable)
                allTaskTypesAndConcentrationsPairedWith90thPercentiles(strcat(string(currentTaskTypes(currentTaskType)))) = prctile(allCol6InModifedTable,90);
                allTaskTypesAndConcentrationsPairedWith20thPercentiles(strcat(string(currentTaskTypes(currentTaskType)))) = prctile(allCol6InModifedTable,20);
            end
            allSkews = skewness(allCol6InModifedTable);
        end

        allConcentrationsAsStrings = num2str(currentConcentrations);
        allConcentrationsAsStringsPlusSkewness = {};
        if ~isempty(currentConcentrations)
            for currentRow=1:height(allConcentrationsAsStrings)
                allConcentrationsAsStringsPlusSkewness{currentRow} = strcat(string(allConcentrationsAsStrings(currentRow,:))," Skewness: ",string(allSkews(currentRow)));
                allTaskTypesAndConcentrationsPairedWithSkewness(strcat("Task Type ",string(currentTaskTypes(currentTaskType))," Concentration ",string(currentConcentrations(currentRow)))) = allSkews(currentRow);
            end
            legend(allConcentrationsAsStringsPlusSkewness)
        else
            legend(strcat("Skewness: ", string(allSkews)))
            allTaskTypesAndConcentrationsPairedWithSkewness('Task Type EQR') = allSkews;
        end
        

        title(string(currentTaskTypes(currentTaskType)))
        xlim([0,20])
        hold off
    end
end

%% display the bar charts for skewness
% task_type_and_concentration = keys(allTaskTypesAndConcentrationsPairedWithSkewness).';
% task_type_and_concentration = char(task_type_and_concentration);
% task_type_and_concentration = string(task_type_and_concentration);
% % disp(task_type_and_concentration(2))
% skews = values(allTaskTypesAndConcentrationsPairedWithSkewness).';
% skews = cell2mat(skews);
% disp(skews(2));
% tableOfSkewness = table(task_type_and_concentration,skews);
% % disp(tableOfSkewness)
% sortedTableOfSkews = sortrows(tableOfSkewness,"skews");
% disp(sortedTableOfSkews)
% figure
% x = categorical(sortedTableOfSkews.task_type_and_concentration);
% x = reordercats(x,sortedTableOfSkews.task_type_and_concentration);
% y = sortedTableOfSkews.skews;
% bar(x,y)
% title("Skewness by Concentration and Task Type")

%% display the bar charts for cdf
% disp([keys(allTaskTypesAndConcentrationsPairedWith90thPercentiles).',values(allTaskTypesAndConcentrationsPairedWith90thPercentiles).'])
% tt20 = string(char(keys(allTaskTypesAndConcentrationsPairedWith20thPercentiles)));
% percentiles20 = cell2mat(values(allTaskTypesAndConcentrationsPairedWith20thPercentiles).');
% tableOf20thPercentiles = table(tt20,percentiles20);
% sortedTableOf20thPercentiles = sortrows(tableOf20thPercentiles,"percentiles20");
% figure
% x20 = categorical(sortedTableOf20thPercentiles.tt20);
% x20 = reordercats(x20,sortedTableOf20thPercentiles.tt20);
% y20 = sortedTableOf20thPercentiles.percentiles20;
% bar(x20,y20);
% title("20th percentiles by Concentrations and Task Types")
% ylim([0,20])
% 
% tt90 = string(char(keys(allTaskTypesAndConcentrationsPairedWith90thPercentiles)));
% percentiles90 = cell2mat(values(allTaskTypesAndConcentrationsPairedWith90thPercentiles).');
% tableOf90thPercentiles = table(tt90,percentiles90);
% sortedTableOf90thPercentiles = sortrows(tableOf90thPercentiles,"percentiles90");
% figure
% x90 = categorical(sortedTableOf90thPercentiles.tt90);
% x90 = reordercats(x90,sortedTableOf90thPercentiles.tt90);
% y90 = sortedTableOf90thPercentiles.percentiles90;
% bar(x90,y90);
% title("90th Percentiles by Concentrations and Task Types")
% ylim([0,20])

% %% Create histplots
% for i=1:1.5%length(twdbs)
%     currentDatabase = twdbs{i};
%     t = struct2table(currentDatabase);
%     uniqueTaskType = unique(t.taskType);
%     %     disp(i)
%     %     disp(uniqueConcentrations)
%     %     disp(uniqueTaskType)
%     currentTaskTypes = uniqueTaskType;
% 
%     for currentTaskType=1:length(currentTaskTypes)
%         figure
%         hold on
%         tableWithJust1TaskType = t((strcmp(string(t.taskType),string(currentTaskTypes(currentTaskType)))),:);
%         currentConcentrations = unique(tableWithJust1TaskType.conc);
%         currentConcentrations = rmmissing(currentConcentrations);
% 
%         if ~isempty(currentConcentrations)
%             allSkews = [];
%             for currentConcentration=1:length(currentConcentrations)
%                 modifiedTable = tableWithJust1TaskType(currentConcentrations(currentConcentration) == tableWithJust1TaskType.conc,:);
%                 %             disp(strcat("Expected Task Type: ",string(currentTaskTypes(currentTaskType))," Expected Concentration",string(currentConcentrations(currentConcentration))))
%                 %             disp(table(modifiedTable.taskType,modifiedTable.conc))
%                 allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
%                 %             disp(size(allTimingsInsideModifiedTable,1))
%                 allCol6InModifedTable = [];
%                 for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
%                     currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
%                     allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
%                 end
%                 %             disp(allCol6InModifedTable)
%                 if ~isempty(allCol6InModifedTable)
%                     histogram(abs(log(allCol6InModifedTable)),100,'FaceAlpha',0.1)
%                     xlim([0,7])
%                     allSkews = [allSkews,skewness(allCol6InModifedTable)];
%                 end
%             end
%         else
%             modifiedTable = t((strcmp(string(tableWithJust1TaskType.taskType),string(currentTaskTypes(currentTaskType)))),:);
%             allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
%             %             disp(size(allTimingsInsideModifiedTable,1))
%             allCol6InModifedTable = [];
%             for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
%                 currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
%                 allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
%             end
%             %             disp(allCol6InModifedTable)
%             if ~isempty(allCol6InModifedTable)
%                 histogram(abs(log(allCol6InModifedTable)),100,'FaceAlpha',0.1)
%                 xlim([0,7])
%             end
%             allSkews = skewness(allCol6InModifedTable);
%         end
% 
%         allConcentrationsAsStrings = num2str(currentConcentrations);
%         if ~isempty(currentConcentrations)
%             legend(allConcentrationsAsStrings)
%         else
%             legend('EQR')
%         end
% 
% 
%         title(string(currentTaskTypes(currentTaskType)))
%         hold off
%     end
% end
% 
% %% Create histplots, but create 1 plot for each concentration and task type
% for i=1:1.5%length(twdbs)
%     currentDatabase = twdbs{i};
%     t = struct2table(currentDatabase);
%     uniqueTaskType = unique(t.taskType);
%     %     disp(i)
%     %     disp(uniqueConcentrations)
%     %     disp(uniqueTaskType)
%     currentTaskTypes = uniqueTaskType;
% 
%     for currentTaskType=1:length(currentTaskTypes)
%         tableWithJust1TaskType = t((strcmp(string(t.taskType),string(currentTaskTypes(currentTaskType)))),:);
%         currentConcentrations = unique(tableWithJust1TaskType.conc);
%         currentConcentrations = rmmissing(currentConcentrations);
%         figure
%         hold on
%         if ~isempty(currentConcentrations)
%             for currentConcentration=1:length(currentConcentrations)
%                 subplot(ceil(length(currentConcentrations)/2),ceil(length(currentConcentrations)/2),currentConcentration)
%                 modifiedTable = tableWithJust1TaskType(currentConcentrations(currentConcentration) == tableWithJust1TaskType.conc,:);
%                 %             disp(strcat("Expected Task Type: ",string(currentTaskTypes(currentTaskType))," Expected Concentration",string(currentConcentrations(currentConcentration))))
%                 %             disp(table(modifiedTable.taskType,modifiedTable.conc))
%                 allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
%                 %             disp(size(allTimingsInsideModifiedTable,1))
%                 allCol6InModifedTable = [];
%                 for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
%                     currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
%                     allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
%                 end
%                 %             disp(allCol6InModifedTable)
%                 if ~isempty(allCol6InModifedTable)
%                     histogram(abs(log(allCol6InModifedTable)),100,'FaceAlpha',0.1)
%                     xlim([0,7])
%                 end
%                 legend(string(currentTaskTypes(currentTaskType)))
%                 title(string(currentConcentrations(currentConcentration)))
%                 sgtitle(string(currentTaskTypes(currentTaskType)))
%                 hold off
%             end
%         else
%             modifiedTable = t((strcmp(string(tableWithJust1TaskType.taskType),string(currentTaskTypes(currentTaskType)))),:);
%             allTimingsInsideModifiedTable = modifiedTable.trial_evt_timings;
%             %             disp(size(allTimingsInsideModifiedTable,1))
%             allCol6InModifedTable = [];
%             for currentCol6 = 1:size(allTimingsInsideModifiedTable,1)
%                 currentTimingArray = allTimingsInsideModifiedTable{currentCol6};
%                 allCol6InModifedTable = [allCol6InModifedTable,currentTimingArray(:,6).'];
%             end
%             %             disp(allCol6InModifedTable)
%             if ~isempty(allCol6InModifedTable)
%                 histogram(abs(log(allCol6InModifedTable)),100,'FaceAlpha',0.1)
%                 xlim([0,7])
%             end
%             legend(string(currentTaskTypes(currentTaskType)))
%             title(strcat(string(currentTaskTypes(currentTaskType))))
%             hold off
%         end
% 
% 
% 
%     end
% end