% Date: 07/15/2023
% Author: Atanu Giri
% This script finds all neurons from same session for specified database
% and neuron type.

function extractNeuronsFromSameSession(varargin)

% Example usage
% extractNeuronsFromSameSession('twdb_control', 'PL')

% varargin = {'twdb_control', 'PL'};

twdbs = load("twdbs.mat");

sprintf("All datables\n");
sprintf("twdb_control, twdb_stress, twdb_stress2\n");

sprintf("All neuron types\n");
sprintf("FSI, Striosome, PLS, PL, Matrix\n");

dataTable = twdbs.(sprintf('%s', varargin{1}));

% Select neuron type you want to analyze
neuronType = varargin{2};

if strcmpi(neuronType, 'FSI')
    neuronIdx = twdb_lookup(dataTable, 'index', ...
        'key', 'tetrodeType', 'dms', ...
        'key', 'neuron_type', 'SWN', ...
        'grade', 'final_michael_grade', 1, 5, ...
        'grade', 'firing_rate', 0, 60);

elseif strcmpi(neuronType, 'Striosome')
    neuronIdx = twdb_lookup(dataTable, 'index', 'key', 'tetrodeType', 'dms', ...
        'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 4, 5, ...
        'grade', 'final_michael_grade', 3, 5, 'grade', 'sqr_neuron_type', 3, 5);

elseif strcmpi(neuronType, 'PLS')
    neuronIdx = twdb_lookup(dataTable, 'index', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5, ...
        'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);

elseif strcmpi(neuronType, 'PL')
    neuronIdx = twdb_lookup(dataTable, 'index', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5);

elseif strcmpi(neuronType, 'Matrix')
    neuronIdx = twdb_lookup(dataTable, 'index', 'key', 'tetrodeType', 'dms', ...
        'key', 'neuron_type', 'SWN', 'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 0, ...
        'grade', 'final_michael_grade', 1, 5);

else
    disp("Please check your input.\n");
    return;

end

% Convert to double
neuronIdx = cellfun(@str2num,neuronIdx);

% Add tasktype filter
if numel(varargin) > 2 && strcmpi(varargin{3}, 'y')
    specificTask = varargin{3};
    task = input("Enter the tasktype you want to analyze ('CB', 'EQR', 'Rev CB', 'TR'): ", 's');
    % twdb_lookup function with taskType filter
    neuronIdxByTask = twdb_lookup(dataTable, 'index', 'key', 'taskType', sprintf('%s',task));
    neuronIdxByTask = cellfun(@str2num,neuronIdxByTask);
    % Get common neurons
    neuronIdx = intersect(neuronIdx, neuronIdxByTask);
end

% Add concentration filter
if numel(varargin) > 3 && strcmpi(varargin{4}, 'y')
    concRange = varargin{4};
    lowConc = input("Enter the lower concentration: ");
    highConc = input("Enter the higher concentration ('nan' for no upper limit): ", 's');

    if strcmpi(highConc, 'nan')
        highConc = nan;  % Set highConc to nan
    else
        highConc = str2double(highConc);  % Convert highConc to a numeric value
    end
    % twdb_lookup function with concentration filter
    neuronIdxByConc = twdb_lookup(dataTable, 'index', 'grade', 'conc', lowConc, highConc);
    neuronIdxByConc = cellfun(@str2num,neuronIdxByConc);
    % Get common neurons
    neuronIdx = intersect(neuronIdx, neuronIdxByConc);
end

% Store all sessionID and ratID of all neuronIdx in aray
sessionIDarray = cell(1,numel(neuronIdx));
ratIDarray = cell(1,numel(neuronIdx));

for neuron = 1:numel(neuronIdx)
    neuronData = dataTable(neuronIdx(neuron));
    sessionIDarray{neuron} = neuronData.sessionID;
    ratIDarray{neuron} = neuronData.ratID;
end

% Store unique sessionIDs and ratIDs
uniqueSessions = unique(sessionIDarray);
uniqueRats = unique(ratIDarray);

% Initialize a cell array to store grouped neuronIdx
groupedNeuronIdx = cell(numel(uniqueSessions), numel(uniqueRats));

% Iterate over each neuronIdx
for neuron = 1:numel(neuronIdx)
    sessionID = sessionIDarray{neuron};
    ratID = ratIDarray{neuron};

    % Find the indices of the unique session and rat
    sessionIdx = find(strcmp(uniqueSessions, sessionID));
    ratIdx = find(strcmp(uniqueRats, ratID));

    % Store neuronIdx in the corresponding cell based on session and rat
    groupedNeuronIdx{sessionIdx, ratIdx} = [groupedNeuronIdx{sessionIdx, ratIdx}, neuronIdx(neuron)];
end

% Dynamically generate output file name
parts = strsplit(varargin{1}, 'twdb_');
outputFile = sprintf('sameSession%sneuronsIN%s', neuronType, parts{2});
% save groupedNeuronIdx
save(outputFile, "groupedNeuronIdx");
end