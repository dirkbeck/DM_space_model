function twdb = twdb_addneurons(sessionDir)
% Takes in a twdb database file <dbfile> and a session directory containing
% clustered data <sessionDir> and adds data from all neuron data in
% sessionDir to twdb.


twdb = [];
dirFiles = dir(sessionDir);
for f = 1:length(dirFiles)
    if ~isempty(regexp(dirFiles(f).name,'tt[0-9]*[lr_]*[adlmpstv]*[1-6]*_done','once'))
        continue
    elseif ~isempty(regexp(dirFiles(f).name,'tt[0-9]*[lr_]*[adlmpstv]*[1-6]*.mat','once','ignorecase'))
        matFile = fullfile(sessionDir, dirFiles(f).name);
        [~,tetrode,~] = fileparts(matFile);
        infoMat = load(fullfile(sessionDir,strcat(tetrode,'_info.mat')));
        numNeurons = length(infoMat.means);
        for n = 1:numNeurons
            twdbN = twdb_addsingleneuron(sessionDir, tetrode, n);
            if isempty(twdb)
                twdb = twdbN;
            else
                twdb = [twdb twdbN];
            end
        end
    end
end
end