% Date: 10/11/2023
% Author: Atanu Giri
% This function plots the fitting parameters of pairs between two
% different types of neuron in PLS-FSI-Strio triplet.

twdbs = load("twdbs.mat");
close all;
databaseDataLabel = {'control Data', 'stress Data', 'stress2 Data'};

% Invoke function extractPairedNeuronsInTriplet
pairsInTriplet = extractPairedNeuronsInTriplet;

% Invoke function extarctFitParameters
[coeffA, coeffB, allGOF] = extractLinearFitParameters(pairsInTriplet, twdbs);

[aData, avgA, sdErrA] = extractPlotValues(coeffA);
[bData, avgB, sdErrB] = extractPlotValues(coeffB);
[gofData, avgGof, sdErrGof] = extractPlotValues(allGOF);

pairsTypeLabel = {'fsiPlsPair', 'fsiStrioPair', 'plsStrioPair'};

aDataSorted = sortData(aData);
bDataSorted = sortData(bData);
gofDataSorted = sortData(gofData);

avgAsorted = sortData(avgA);
avgBsorted = sortData(avgB);
avgGOFsorted = sortData(avgGof);

sdErrAsorted = sortData(sdErrA);
sdErrBsorted = sortData(sdErrB);
sdErrGOFsorted = sortData(sdErrGof);


% a, b plot 
for pairType = 1:1 %3
    figure(pairType);
    set(gcf, 'Windowstyle', 'docked');
    subplot(1,2,1);
    bar(avgAsorted{pairType});
    hold on;
    errorbar(1:3, avgAsorted{pairType}, sdErrAsorted{pairType}, ...
        'k.', 'LineWidth', 1.5);
    % Perform two-sample t-tests and print on the figure
    myStat(aDataSorted{pairType}, avgAsorted{pairType}, databaseDataLabel);
    hold off;

    subplot(1,2,2);
    bar(avgBsorted{pairType});
    hold on;
    errorbar(1:3, avgBsorted{pairType}, sdErrBsorted{pairType}, ...
        'k.', 'LineWidth', 1.5);
    myStat(bDataSorted{pairType}, avgBsorted{pairType}, databaseDataLabel);
    hold off;
    sgtitle(pairsTypeLabel{pairType}, 'FontSize', 20);

end

% R^2 plot
for pairType = 1:1 %3
    figure(pairType+3);
    set(gcf, 'Windowstyle', 'docked');
    bar(avgGOFsorted{pairType});
    ylim([0 1]);
    hold on;
    errorbar(1:3, avgGOFsorted{pairType}, sdErrGOFsorted{pairType}, ...
        'k.', 'LineWidth', 1.5);
    myStat(gofDataSorted{pairType}, avgGOFsorted{pairType}, databaseDataLabel);
    hold off;
    title(pairsTypeLabel{pairType}, 'FontSize', 20);

end

% Histogram
% for pairType = 1:3
%     figure(pairType+6);
%     set(gcf, 'Windowstyle', 'docked');
%     for group = 1:3
%         subplot(1,3,group);
%         histogram(aDataSorted{pairType}{group}, 10);
%         title(databaseDataLabel{group}, 'FontSize', 15);
%     end
%     sgtitle(pairsTypeLabel{pairType}, 'FontSize', 20);
% end


%% Description of sortData
function sortedData = sortData(data)
sortedData = cell(1,3);
if iscell(data{1})
    for pairType = 1:3
        for group = 1:3
            sortedData{pairType}{group} = data{group}{pairType};
        end
    end

elseif isa(data{1}, 'double')
    for pairType = 1:3
        for group = 1:3
            sortedData{pairType}(group) = data{group}(pairType);
        end
    end

else
    fprintf('Check input data');
end

end

%% Description of extractPlotValues
function [cleanedData, avg, sdErr] = extractPlotValues(rawData)

cleanedData = cell(1,3);
avg = cell(1,3);
sdErr = cell(1,3);

for group = 1:3
    for pair = 1:3
        cleanedData{group}{pair} = rawData{group}{pair}(isfinite(rawData{group}{pair}));
        avg{group}(pair) = mean(cleanedData{group}{pair});
        sdErr{group}(pair) = std(cleanedData{group}{pair})/sqrt(numel(cleanedData{group}{pair}));
    end

end
end