% Date: 06/23/2023
% This script finds the doublets for input database between FSI/SWN,
% Striosom, and PLS neurons

function differentNeuronPairsInDatabase(dataTable)

% Example usage
% differentNeuronPairsInDatabase('twdb_control')

% All dataTable = 'twdb_control', 'twdb_stress', 'twdb_stress2'

% load database
twdbs = load("twdbs.mat");
data = twdbs.(sprintf('%s', dataTable));

% Query for FSI neurons
fsiIndx = twdb_lookup(data, 'index', ...
        'key', 'tetrodeType', 'dms', ...
        'key', 'neuron_type', 'SWN', ...
        'grade', 'final_michael_grade', 1, 5, ...
        'grade', 'firing_rate', 0, 60);
fsiIndx = cellfun(@str2num, fsiIndx);

% Query for Striosom neurons
strioIndx = twdb_lookup(data, 'index', 'key', 'tetrodeType', 'dms', ...
    'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 4, 5, ...
    'grade', 'final_michael_grade', 3, 5, 'grade', 'sqr_neuron_type', 3, 5);
strioIndx = cellfun(@str2num, strioIndx);

% Query for Matrix neurons
matrixIndx = twdb_lookup(data, 'index', 'key', 'tetrodeType', 'dms', ...
    'key', 'neuron_type', 'SWN', 'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 0, ...
    'grade', 'final_michael_grade', 1, 5);
matrixIndx = cellfun(@str2num, matrixIndx);

% Query for PLS neurons
plsIndx = twdb_lookup(data, 'index', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5, ...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
plsIndx = cellfun(@str2num, plsIndx);

% Query for PL neurons
plIndx = twdb_lookup(data, 'index', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5);
plIndx = cellfun(@str2num, plIndx);

% Create a placeholder for all Indexes OTHER than fsiIndx
allIndexes = [{strioIndx}, {matrixIndx}, {plsIndx}, {plIndx}];
pairsTable = cell(1,numel(allIndexes));

% Find FSI and other pairs
for neuronType = 1:numel(allIndexes)
    fsiPairIndexes = [];
    otherPairIndexes = [];
    for i = 1:length(fsiIndx)
        fsiData = data(fsiIndx(i));

        for j = 1:length(allIndexes{neuronType})
            otherNeuronData = data(allIndexes{neuronType}(j));

            % What makes these 2 indexes pair
            sessionIDfilter = strcmp(fsiData.sessionID, otherNeuronData.sessionID);
            ratIDfilter = strcmp(fsiData.ratID, otherNeuronData.ratID);

            if sessionIDfilter && ratIDfilter
                fsiPairIndexes = [fsiPairIndexes; fsiIndx(i)];
                otherPairIndexes = [otherPairIndexes; allIndexes{neuronType}(j)];
            end
        end
    end

    % Remove same indexes in both FSIpairs and StrioPairs array
    for k = numel(fsiPairIndexes):-1:1
        if fsiPairIndexes(k) == otherPairIndexes(k)
            fsiPairIndexes(k) = [];
            otherPairIndexes(k) = [];
        end
    end
pairsTable{neuronType} = table(fsiPairIndexes, otherPairIndexes);
end

% Assign column names to the existing columns
pairsTable{1}.Properties.VariableNames = {'fsiIndex', 'striosomeIndex'};
pairsTable{2}.Properties.VariableNames = {'fsiIndex', 'matrixIndex'};
pairsTable{3}.Properties.VariableNames = {'fsiIndex', 'plsIndex'};
pairsTable{4}.Properties.VariableNames = {'fsiIndex', 'plIndex'};

match = regexp(dataTable, 'twdb_(\w+)', 'tokens', 'once');
firstLetter = upper(match{1}(1));
restOfString = match{1}(2:end);
capitalizedString = [firstLetter, restOfString];
fileName = sprintf('pairsTable%s.mat', capitalizedString);

if exist(fileName, 'file') == 0
    fileName = matfile(fileName, 'Writable', true);
    fileName.pairsTable = pairsTable;
else
    save(fileName, 'pairsTable', '-append');
end
end