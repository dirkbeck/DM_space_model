function[tableOfAll] = formatCountsAsTable(satisfactoryRsquaredCount,...
    satisfactorySignificance,...
    totalFiguresCount,...
    totalNegativeFiguresCount,...
    totalPositiveFiguresCount,...
    totalPositiveRSquaredSatisfactory,...
    totalPositiveSignificance)
%this file takes the counts created in countingEverything.m and turns
%formats it into a table for easy reading

taskAndConcentration = keys(satisfactoryRsquaredCount).';
taskAndConcentration = string(taskAndConcentration);
totalFigures = cell2mat(values(totalFiguresCount).');
totalNegativeFigures = cell2mat(values(totalNegativeFiguresCount).');
satisfactoryRsquaredFigures = cell2mat(values(satisfactoryRsquaredCount).');
satisfactorySignificanceFigures = cell2mat(values(satisfactorySignificance).');
totalPositiveFigures = cell2mat(values(totalPositiveFiguresCount).');
totalPositiveThatMeetRSquaredThreshold = cell2mat(values(totalPositiveRSquaredSatisfactory).');
totalPositiveThatMeetSignificanceThreshold = cell2mat(values(totalPositiveSignificance).');


totalNegativePercentage = totalNegativeFigures./totalFigures;
% totalNegativePercentage = totalNegativePercentage(:,8);
NegativeThresholdMeetingPercentage = satisfactoryRsquaredFigures./totalFigures;
% totalThresholdMeetingPercentage = totalThresholdMeetingPercentage(:,8);
totalPositivePercentage = totalPositiveFigures./totalFigures;
% totalPositivePercentage = totalPositivePercentage(:,8);
PositiveThresholdMeetingPercentage = totalPositiveThatMeetRSquaredThreshold ./ totalFigures;


tableOfAll = table(taskAndConcentration,totalFigures,totalNegativePercentage,NegativeThresholdMeetingPercentage,totalPositivePercentage,PositiveThresholdMeetingPercentage);
display(tableOfAll)
end
