

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

% order=[2;1; 3; 4; 5; 7; 8; 6; 9; 18; 11; 12; 13; 10; 14; 15; 16; 17]; %control group order
% order = [1;2;11;3;4;5;6;7;8;9;10]; %stress order
% order = [1;2;3;4;7;5;6]; %stress 2 order
tableOfAll = table(taskAndConcentration,totalFigures,totalNegativePercentage,NegativeThresholdMeetingPercentage,totalPositivePercentage,PositiveThresholdMeetingPercentage);
display(tableOfAll)

% sortedTable = sortrows(tableOfAll);
% display(sortedTable);

