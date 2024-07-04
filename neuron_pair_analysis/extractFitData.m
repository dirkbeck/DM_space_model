% Date: 09/07/2023
% This function extracts fitting parameters of doublets for each doublets
% in PLS, FSI, and Striosome triplets.

% Invokes plotDynamicsDoublet function

function extractFitData(dataTable, fitType)

% Example usage
% extractFitData('twdb_control', 'PLSvsFSI')

% All dataTable = 'twdb_control', 'twdb_stress', 'twdb_stress2'
% All fitType = 'PLSvsFSI', 'PLSvsSTRIO'

twdbs = load("twdbs.mat");
data = twdbs.(sprintf('%s', dataTable));

if strcmpi(dataTable, 'twdb_control')
    loadFile = load('pairsTableControl.mat');
    [~, fileName] = fileparts('pairsTableControl');
elseif strcmpi(dataTable, 'twdb_stress')
    loadFile = load('pairsTableStress.mat');
    [~, fileName] = fileparts('pairsTableStress');
else
    loadFile = load('pairsTableStress2.mat');
    [~, fileName] = fileparts('pairsTableStress2');
end

fsiPlsPairs = loadFile.pairsTable{3};
fsiStriosomePairs = loadFile.pairsTable{1};

% Get the triplets
fsiPlsStrioTriplets = innerjoin(fsiPlsPairs, fsiStriosomePairs, 'Keys', 'fsiIndex');

% load best bin size
bestBin = (1.33)*ones(size(fsiPlsStrioTriplets, 1),1);

if strcmpi(fitType, 'PLSvsFSI')
    fitresultArray_PLSvsFSI = cell(size(fsiPlsStrioTriplets, 1), 1);
    gofArray_PLSvsFSI = cell(size(fsiPlsStrioTriplets, 1), 1);
    xValArray_PLSvsFSI = cell(size(fsiPlsStrioTriplets, 1), 1);
    yValArray_PLSvsFSI = cell(size(fsiPlsStrioTriplets, 1), 1);
    rValArray_PLSvsFSI = zeros(size(fsiPlsStrioTriplets, 1), 1);
    pValArray_PLSvsFSI = zeros(size(fsiPlsStrioTriplets, 1), 1);

    fitTypeChoice = 1;
    for row = 1:size(fsiPlsStrioTriplets,1)
        FSIindex = fsiPlsStrioTriplets.fsiIndex(row);
        PLSindex = fsiPlsStrioTriplets.plsIndex(row);

        FSIspikes = data(FSIindex).trial_spikes;
        PLSspikes = data(PLSindex).trial_spikes;

        % Get the output values
        try
            [fitresult_PLSvsFSI, gof_PLSvsFSI, xnew_PLSvsFSI, ynew_PLSvsFSI, ...
                Rval_PLSvsFSI, Pval_PLSvsFSI] = plotDynamicsDoublet( ...
                PLSspikes, FSIspikes, bestBin(row), fitTypeChoice);

            % Store the result in the array
            fitresultArray_PLSvsFSI{row} = fitresult_PLSvsFSI;
            gofArray_PLSvsFSI{row} = gof_PLSvsFSI;
            xValArray_PLSvsFSI{row} = xnew_PLSvsFSI;
            yValArray_PLSvsFSI{row} = ynew_PLSvsFSI;
            rValArray_PLSvsFSI(row) = Rval_PLSvsFSI;
            pValArray_PLSvsFSI(row) = Pval_PLSvsFSI;

        catch
            fprintf('Skipping iteration %d due to an error.\n', row);
        end
    end
    fitData = table;
    fitData.plsIndex = fsiPlsStrioTriplets.plsIndex;
    fitData.fsiIndex = fsiPlsStrioTriplets.fsiIndex;
    fitData.fitresultArray_PLSvsFSI = fitresultArray_PLSvsFSI;
    fitData.xValArray_PLSvsFSI = xValArray_PLSvsFSI;
    fitData.yValArray_PLSvsFSI = yValArray_PLSvsFSI;
    fitData.gofArray_PLSvsFSI = gofArray_PLSvsFSI;
    fitData.rValArray_PLSvsFSI = rValArray_PLSvsFSI;
    fitData.pValArray_PLSvsFSI = pValArray_PLSvsFSI;
    save(fileName, 'fitData', '-append');

elseif strcmpi(fitType, 'PLSvsSTRIO')
    t = loadFile.fitData;
    fitResultArray_PLSvsSTRIO = cell(size(fsiPlsStrioTriplets, 1), 1);
    gofArray_PLSvsSTRIO = cell(size(fsiPlsStrioTriplets, 1), 1);
    xValArray_PLSvsSTRIO = cell(size(fsiPlsStrioTriplets, 1), 1);
    yValArray_PLSvsSTRIO = cell(size(fsiPlsStrioTriplets, 1), 1);
    rValArray_PLSvsSTRIO = zeros(size(fsiPlsStrioTriplets, 1), 1);
    pValArray_PLSvsSTRIO = zeros(size(fsiPlsStrioTriplets, 1), 1);

    fitTypeChoice = 2;
    % Check the plot shape with current bin time
    for row = 1:size(fsiPlsStrioTriplets,1)
        try
            PLSindex = fsiPlsStrioTriplets.plsIndex(row);
            striosomeIndex = fsiPlsStrioTriplets.striosomeIndex(row);

            PLSspikes = data(PLSindex).trial_spikes;
            striosomespikes = data(striosomeIndex).trial_spikes;

            fitResult = t.fitresultArray_PLSvsFSI{row};
            a = fitResult.a;
            b = fitResult.b;

            % Get the output values
            %             [fitresult_PLSvsSTRIO, gof_PLSvsSTRIO, ...
            %                 xnew_PLSvsSTRIO, ynew_PLSvsSTRIO] = plotDynamicsDoublet( ...
            %                 PLSspikes, striosomespikes, bestBin(row), fitTypeChoice, a, b);

            [fitresult_PLSvsSTRIO, gof_PLSvsSTRIO, xnew_PLSvsSTRIO, ...
                ynew_PLSvsSTRIO, Rval_PLSvsSTRIO, Pval_PLSvsSTRIO] ...
            = plotDynamicsDoublet(PLSspikes, striosomespikes, bestBin(row), fitTypeChoice);

            % Store the result in the array
            fitResultArray_PLSvsSTRIO{row} = fitresult_PLSvsSTRIO;
            gofArray_PLSvsSTRIO{row} = gof_PLSvsSTRIO;
            xValArray_PLSvsSTRIO{row} = xnew_PLSvsSTRIO;
            yValArray_PLSvsSTRIO{row} = ynew_PLSvsSTRIO;
            rValArray_PLSvsSTRIO(row) = Rval_PLSvsSTRIO;
            pValArray_PLSvsSTRIO(row) = Pval_PLSvsSTRIO;
        catch
            fprintf('Skipping iteration %d due to an error.\n', row);
        end
    end

    % Change table column name based on the fit (fitResult, gof)
    fitData.striosomeIndex = fsiPlsStrioTriplets.striosomeIndex;
    fitData.fitResultArray_PLSvsSTRIO = fitResultArray_PLSvsSTRIO;
    fitData.xValArray_PLSvsSTRIO = xValArray_PLSvsSTRIO;
    fitData.yValArray_PLSvsSTRIO = yValArray_PLSvsSTRIO;
    fitData.gofArray_PLSvsSTRIO = gofArray_PLSvsSTRIO;
    fitData.rValArray_PLSvsSTRIO = rValArray_PLSvsSTRIO;
    fitData.pValArray_PLSvsSTRIO = pValArray_PLSvsSTRIO;

    save(fileName, 'fitData', '-append');
end

end