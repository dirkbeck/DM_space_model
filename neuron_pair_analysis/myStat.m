% Date: 10/12/2023
% Author: Atanu Giri
% This function performs ttest2 between control and 2 other databases

function myStat(coeffientData, averageData, databaseDataLabel)

% Perform two-sample t-tests and print on the figure
[~, pValue1] = ttest2(coeffientData{1}, coeffientData{2});
[~, pValue2] = ttest2(coeffientData{1}, coeffientData{3});

text(2, 0.9*max(averageData), ['p = ', num2str(pValue1)], 'Interpreter', 'latex', ...
    'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'Rotation', 45, 'Color', [0.8 0 0]);
text(3, 0.9*max(averageData), ['p = ', num2str(pValue2)], 'Interpreter', 'latex', ...
    'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'Rotation', 45, 'Color', [0.8 0 0]);

xticks(1:numel(databaseDataLabel));
xticklabels(databaseDataLabel);
xtickangle(45);

text(3.5, max(averageData), sprintf('n_{Control} = %d\n n_{Stress} = %d\n n_{Stress2} = %d', ...
    numel(coeffientData{1}), numel(coeffientData{2}), numel(coeffientData{3})), ...
    'FontSize', 30, 'FontWeight', 'bold');

end