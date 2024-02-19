% files = dir(pwd);
% dirFlags = [files.isdir];
% subfolders = files(dirFlags);
% subFolderNames={subfolders(5:end).name};
% for k = 1 : length(subFolderNames)
% % 	fprintf('Sub folder #%d = %s\n', k, subFolderNames{k});
%     countingEverything(subFolderNames{k},0.2,0.05)
% end
% 
% allExcelFiles = dir("*.xlsx");
% 
% controlKeySet={'Line Task Type CB Concentration 15',...
%     'Line Task Type CB Concentration 30',...
%     'Line Task Type CB Concentration 5',...
%     'Line Task Type CB Concentration 60',...
%     'Line Task Type CB Concentration 70',...
%     'Line Task Type EQR Concentration NA',...
%     'Line Task Type Rev CB Concentration 15',...
%     'Line Task Type Rev CB Concentration 30',...
%     'Line Task Type Rev CB Concentration 5',...
%     'Line Task Type Rev CB Concentration 61',...
%     'Line Task Type Rev CB Concentration 70',...
%     'Line Task Type TR Concentration 100',...
%     'Line Task Type TR Concentration 15',...
%     'Line Task Type TR Concentration 30',...
%     'Line Task Type TR Concentration 45',...
%     'Line Task Type TR Concentration 5',...
%     'Line Task Type TR Concentration 60',...
%     'Line Task Type TR Concentration 65',...
%     'Line Task Type TR Concentration 70',...
%     'Line Task Type TR Concentration 75'};
% 
% stressKeySet = {"Line Task Type CB",...
% "Line Task Type TR Concentration 10",...
% "Line Task Type TR Concentration 30",...
% "Line Task Type TR Concentration 40",...
% "Line Task Type TR Concentration 50",...
% "Line Task Type TR Concentration 60",...
% "Line Task Type TR Concentration 65",...
% "Line Task Type TR Concentration 70",...
% "Line Task Type TR Concentration 75",...
% "Line Task Type TR Concentration 80",...
% "Line Task Type TR Concentration 100"};
% 
% stress2KeySet = {"Line Task Type CB Concentration 100",...
% "Line Task Type CB Concentration 45",...
% "Line Task Type CB Concentration 50",...
% "Line Task Type CB Concentration 55",...
% "Line Task Type CB Concentration 60",...
% "Line Task Type CB Concentration 65",...
% "Line Task Type CB Concentration 70",...
% "Line Task Type TR Concentration 100",...
% "Line Task Type TR Concentration 20",...
% "Line Task Type TR Concentration 30",...
% "Line Task Type TR Concentration 50",...
% "Line Task Type TR Concentration 60",...
% "Line Task Type TR Concentration 65",...
% "Line Task Type TR Concentration 70",...
% "Line Task Type TR Concentration 80"};
% 
% allControlFiles = [];
% allStressFiles = [];
% allStress2Files = [];
% 
% allControlConcentrationsAndTaskTypes =  containers.Map('KeyType','char','ValueType','any');
% allStressConcentrationsAndTaskTypes =   containers.Map('KeyType','char','ValueType','any') ;
% allStress2ConcentrationsAndTaskTypes =  containers.Map('KeyType','char','ValueType','any');
% for i=1:length(controlKeySet)
%     allControlConcentrationsAndTaskTypes(string(controlKeySet(i))) = [];
% end
% for i=1:length(stressKeySet)
%     allStressConcentrationsAndTaskTypes(string(stressKeySet(i))) = [];
% end
% for i=1:length(stress2KeySet)
%     allStress2ConcentrationsAndTaskTypes(string(stress2KeySet(i))) = [];
% end
% 
% for file=1:height(allExcelFiles)
%     currentName = allExcelFiles(file).name;
%     currentTable=readtable(allExcelFiles(file).name);
%     if contains(currentName ,"Control",IgnoreCase=true)
% %         disp(currentName)
% %         display([keys(currentTableContainer).',values(currentTableContainer).'])
%         allControlFiles = [allControlFiles;string(currentName)];
%         for currentUniversalKey=1:length(controlKeySet)
%             foundOrNot = false;
%             for currentRow=1:height(currentTable)
% %                 disp(currentTable.taskAndConcentration(currentRow))
%                 if strcmp(string(currentTable.taskAndConcentration(currentRow)),string(controlKeySet(currentUniversalKey)))
%                     foundOrNot=true;
%                     allControlConcentrationsAndTaskTypes(string(currentTable.taskAndConcentration(currentRow)))=[allControlConcentrationsAndTaskTypes(string(currentTable.taskAndConcentration(currentRow))),...
%                         currentTable.NegativeThresholdMeetingPercentage(currentRow)];
%                 end
%             end
%             if ~foundOrNot
%                 allControlConcentrationsAndTaskTypes(string(controlKeySet(currentUniversalKey)))=[allControlConcentrationsAndTaskTypes(string(controlKeySet(currentUniversalKey))),nan];
%             end
%         end
% 
%     elseif contains(currentName,"stressone",IgnoreCase=true)
%         allStressFiles = [allStressFiles;string(currentName)];
%         for currentUniversalKey=1:length(stressKeySet)
%             foundOrNot = false;
%             for currentRow=1:height(currentTable)
% %                 disp(currentTable.taskAndConcentration(currentRow))
%                 if strcmp(string(currentTable.taskAndConcentration(currentRow)),string(stressKeySet(currentUniversalKey)))
%                     foundOrNot=true;
%                     allStressConcentrationsAndTaskTypes(string(currentTable.taskAndConcentration(currentRow)))=[allStressConcentrationsAndTaskTypes(string(currentTable.taskAndConcentration(currentRow))),...
%                         currentTable.NegativeThresholdMeetingPercentage(currentRow)];
%                 end
%             end
%             if ~foundOrNot
%                 allStressConcentrationsAndTaskTypes(string(stressKeySet(currentUniversalKey)))=[allStressConcentrationsAndTaskTypes(string(stressKeySet(currentUniversalKey))),nan];
%             end            
%         end
%     elseif contains(currentName,"stresstwo",IgnoreCase=true)
%         allStress2Files=[allStress2Files;string(currentName)];
%         for currentUniversalKey=1:length(stress2KeySet)
%             foundOrNot = false;
%             for currentRow=1:height(currentTable)
% %                 disp(currentTable.taskAndConcentration(currentRow))
%                 if strcmp(string(currentTable.taskAndConcentration(currentRow)),string(stress2KeySet(currentUniversalKey)))
%                     foundOrNot=true;
%                     allStress2ConcentrationsAndTaskTypes(string(currentTable.taskAndConcentration(currentRow)))=[allStress2ConcentrationsAndTaskTypes(string(currentTable.taskAndConcentration(currentRow))),...
%                         currentTable.NegativeThresholdMeetingPercentage(currentRow)];
%                 end
%             end
%             if ~foundOrNot
%                 allStress2ConcentrationsAndTaskTypes(string(stress2KeySet(currentUniversalKey)))=[allStress2ConcentrationsAndTaskTypes(string(stress2KeySet(currentUniversalKey))),nan];
%             end            
%         end
%     end
%     
% end
% controlArray = [keys(allControlConcentrationsAndTaskTypes).',values(allControlConcentrationsAndTaskTypes).'];
% stressArray = [keys(allStressConcentrationsAndTaskTypes).',values(allStressConcentrationsAndTaskTypes).'];
% stress2Array = [keys(allStress2ConcentrationsAndTaskTypes).',values(allStress2ConcentrationsAndTaskTypes).'];
% % display(weirdArray)
% 
% simplifiedControlArray = [];
% simplifiedStressArray = [];
% simplifiedStress2Array = [];
% 
% for i=1:height(controlArray)
%     simplifiedControlArray = [simplifiedControlArray;controlArray{i,2}];
% end
% for i=1:height(stressArray)
%     simplifiedStressArray = [simplifiedStressArray;stressArray{i,2}];
% end
% for i=1:height(stress2Array)
%     simplifiedStress2Array=[simplifiedStress2Array;stress2Array{i,2}];
% end
% tableWithJustTaskAndConcentration = table;
% tableWithJustTaskAndConcentration.taskTypeAndConcentration = string(controlKeySet).';
% finalizedControlTable = [tableWithJustTaskAndConcentration,array2table(simplifiedControlArray,"VariableNames",allControlFiles.')];
% 
% tableWithJustTaskAndConcentration = table;
% tableWithJustTaskAndConcentration.taskTypeAndConcentration = string(stressKeySet).';
% finalizedStressTable = [tableWithJustTaskAndConcentration,array2table(simplifiedStressArray,"VariableNames",allStressFiles.')];
% 
% tableWithJustTaskAndConcentration = table;
% tableWithJustTaskAndConcentration.taskTypeAndConcentration = string(stress2KeySet).';
% finalizedStress2Table = [tableWithJustTaskAndConcentration,array2table(simplifiedStress2Array,"VariableNames",allStress2Files.')];

% display(finalizedTable)
% 
for i=2:width(finalizedControlTable)
    figure
    currentData = finalizedControlTable{:,i}.';
    currentData=rmmissing(currentData);
    stdDvn = std(currentData);
    mn= mean(currentData);
    h=histfit(currentData,100);
    grid on;
    hold on;
    xline(mn,'Color','r','LineWidth',3);
    for j=[-1,-2,-3,1,2,3]
        xline(stdDvn *j,'Color','g','LineWidth',3);
    end
    
    y=normpdf(currentData,mn,stdDvn);
    display(y)
    hold off;

%     histfit(currentData,100);
    title(string(allControlFiles(i-1)));
end

% for i=2:width(finalizedStressTable)
%     figure
%     currentData = finalizedStressTable{:,i}.';
%     currentData=rmmissing(currentData);
%     stdDvn = std(currentData);
%     mn= mean(currentData);
%     h=histfit(currentData,100);
%     grid on;
%     hold on;
%     xline(mn,'Color','r','LineWidth',3);
%     for j=[-1,-2,-3,1,2,3]
%         xline(stdDvn *j,'Color','g','LineWidth',3);
%     end
%     
%     y=normpdf(currentData,mn,stdDvn);
%     display(y)
%     hold off;
%     title(string(allStressFiles(i-1)));
% end
% 
% for i=2:width(finalizedStress2Table)
%     figure
%     currentData = finalizedStress2Table{:,i}.';
%     currentData=rmmissing(currentData);
%     stdDvn = std(currentData);
%     mn= mean(currentData);
%     h=histfit(currentData,100);
%     grid on;
%     hold on;
%     xline(mn,'Color','r','LineWidth',3);
%     for j=[-1,-2,-3,1,2,3]
%         xline(stdDvn *j,'Color','g','LineWidth',3);
%     end
%     
%     y=normpdf(currentData,mn,stdDvn);
%     display(y)
%     hold off;
%     title(string(allStress2Files(i-1)));
% end