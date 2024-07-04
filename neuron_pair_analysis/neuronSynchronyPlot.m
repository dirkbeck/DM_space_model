% Date: 02/20/2024
% Author: Atanu Giri
% This function takes matrix of all neurons in same session for
% cross-correlation calculation

function neuronSynchronyPlot(varargin)
% Example usage:
% neuronSynchronyPlot('PL', 'FSI', 'Matrix', 'Striosome');

sprintf("Neurons type\n");
sprintf("PL, FSI, Matrix, Striosome\n");

allData = cell(1, numel(varargin));

for i = 1:numel(varargin)
    loadFile = load(sprintf("sessionDataOf%sneuronsINcontrol.mat", varargin{i}));
    binCtMatrixData = loadFile.binCountMatrixWoNorm;
    binCtMatrixData = binCtMatrixData(~cellfun(@isempty, binCtMatrixData));

    % Cross-correlation container
    crossCorrelationResults = cell(numel(binCtMatrixData), 1);

    % Calculate cross-correlation for pairs of neurons within each session
    maxLag = 5;  % Maximum lag for cross-correlation

    for session = 1:numel(binCtMatrixData)
        sessionData = binCtMatrixData{session};
        numNeurons = size(sessionData, 1);

        crossCorrelationMatrix = zeros(numNeurons);

        for neuron1 = 1:numNeurons
            for neuron2 = neuron1:numNeurons
                timeSeries1 = sessionData(neuron1, :);
                timeSeries2 = sessionData(neuron2, :);

                crossCorr = xcorr(timeSeries1, timeSeries2, maxLag, 'coeff');

                crossCorrelationMatrix(neuron1, neuron2) = max(crossCorr);
                crossCorrelationMatrix(neuron2, neuron1) = max(crossCorr);
            end
        end

        crossCorrelationResults{session} = crossCorrelationMatrix;
    end

    allData{i} = crossCorrelationResults;
end

% place holder for average data and standard error
avgDet = zeros(1,numel(varargin));
stdErr = zeros(1,numel(varargin));
allDet = cell(1,numel(varargin));

for i = 1:numel(varargin)
    determinantArray = zeros(numel(allData{i}), 1);
    % Calculate Determinant
    for session = 1:numel(allData{i})
        n_neurons = width(allData{i}{session});
        determinantArray(session) = det(allData{i}{session})^(1/n_neurons);
    end

    % Obtain average and standard error
    determinantArray = determinantArray(isfinite(determinantArray));
    determinantArray = 1 - determinantArray;
    allDet{i} = determinantArray;
    avgDet(i) = mean(determinantArray);
    stdErr(i) = std(determinantArray)/sqrt(numel(determinantArray));
end

% Plot
Colors = parula(numel(varargin));
hBars = zeros(1, numel(varargin));
for i = 1:numel(varargin)
    hBars(i) = bar(i, avgDet(i), 'FaceColor', Colors(i,:));
    hold on;
end

for i = 1:numel(varargin)
    errorbar(i, avgDet(i),stdErr(i),'LineStyle', 'none', ...
        'LineWidth', 1.5, 'CapSize', 0, 'Color','k');
end

legend_labels = varargin;
legend(hBars, legend_labels, 'Location', 'best');

% Statistics
p_value = zeros(1, numel(varargin) - 1);
for i = 2:numel(varargin)
    [~, p_value(i-1)] = ttest2(allDet{1}, allDet{i});
    text(i, 0.7*max(ylim), sprintf("p = %.4e", p_value(i-1)));
end

for i = 1:numel(varargin)
    text(i, 0.4*max(ylim), sprintf('n = %d', numel(allDet{i})), ...
        "Rotation",90, "VerticalAlignment",'middle');
end
end