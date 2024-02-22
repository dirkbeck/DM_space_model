function twdb = twdb_addsingleneuron(sessionDir, tetrode, neuronNum)
% Takes in a twdb database file <dbfile>, a session directory containing
% clustered data <sessionDir>, a tetrode ID <tetrode> and the number of the
% neuron <neuronNum> and adds appropriate data to twdb from _info.mat
% files.
% EXAMPLE: twdb_addSingleNeuron(dbfile, sessionDir, 'tt1pl1', 1) returns
% proper info for the 1st neuron recorded in tetrode corresponding to
% tt1pl1.

twdb = [];
twdb(end+1).sessionID = tw_sessionid(sessionDir);
twdb(end).sessionDir = sessionDir;
str = regexp(sessionDir, 'strio[0-9]*','match','once');
mtx = regexp(sessionDir, 'matrix[0-9]*','match','once');
rat = regexp(sessionDir, 'rat[0-9]*', 'match','once');
ratID = [str mtx rat];
twdb(end).ratID = ratID;
twdb(end).tetrodeID = tetrode;
twdb(end).neuronN = num2str(neuronNum);
matFile = fullfile(sessionDir, strcat(tetrode,'.mat'));
[~, tetrode, ~] = fileparts(matFile);
infoFile = fullfile(sessionDir, strcat(tetrode,'_info.mat'));
if isempty(regexp(tetrode,'tt\d+[a-zA-Z]+\d+','once'))
    keys = regexp(tetrode,'tt(\d+)','tokens','ignorecase');
    twdb(end).tetrodeN = keys{1}{1};
    if strcmp(ratID,'strio13')
        ttTypes = {'vta', 'vta', 'vta', 'vta', 'vta', 'pl', 'pl', 'pl', 'pl', 'pl', 'pl', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dls', 'dls', 'dls', 'dls', 'dls', 'dls', 'vta'};
    elseif strcmp(ratID,'matrix13')
        ttTypes = {'dms', 'dms', '', 'dms', 'dms', 'dms', '', 'dms', '', 'dms', 'dms', 'dms', 'pl', 'pl', 'pl', '', 'pl', 'pl', 'pl', 'pl', 'pl', 'pl', 'pl', 'pl'};
    else
        ttTypes = {'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms', 'dms'};
    end
    twdb(end).tetrodeType = ttTypes{str2double(keys{1}{1})};
else
    keys = regexp(tetrode,'tt(\d+)([a-zA-Z]+)(\d+)','tokens');
    twdb(end).tetrodeN = keys{1}{1};
    twdb(end).tetrodeType = keys{1}{2};
end
twdb(end).neuronRef = strcat(tw_sessionid(sessionDir),{' '}, tetrode,{' unit '}, num2str(neuronNum));
twdb(end).neuronRef = cell2mat(twdb(end).neuronRef);
if exist(matFile,'file')
    twdb(end).clusterDataLoc = matFile;
end
if exist(infoFile,'file')
    infoMat = load(infoFile);
    twdb(end).final_michael_grade = infoMat.final_grades(neuronNum);
    twdb(end).mean_spike_waveform = infoMat.means{neuronNum};
end

rcb = regexp(sessionDir, 'negacomb[0-9]*', 'match');
if ~isempty(rcb)
    rcb = rcb{1};
    twdb(end).taskType = 'Rev CB';
    twdb(end).conc = str2double(rcb(9:end));
else
    cb = regexp(sessionDir, 'comb[0-9]*', 'match');
    if ~isempty(cb)
        cb = cb{1};
        twdb(end).taskType = 'CB';
        twdb(end).conc = str2double(cb(5:end));
    else
        eqr = regexp(sessionDir, 'eqr', 'match');
        if ~isempty(eqr)
            eqr = eqr{1};
            twdb(end).taskType = 'EQR';
            twdb(end).conc = NaN;
        else
            tr = regexp(sessionDir, 'tr[0-9]*', 'match');
            if ~isempty(tr)
                twdb(end).taskType = 'TR';
                twdb(end).conc = NaN;                
                for i = 1:length(tr)
                    if length(tr{i})>2
                        twdb(end).conc = str2double(tr{i}(3:end));
%                         break;
                    end
                end
            else
                twdb(end).taskType = 'unknown';
                twdb(end).conc = NaN;
            end
        end
    end
end

laser = strfind(sessionDir, 'laser');
if isempty(laser)
    twdb(end).laser = 0;
else
    twdb(end).laser = 1;
end
