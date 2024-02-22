function neurons = twdb_thresholdlookup(dbfile, field, varargin)
% Given a twdb file <dbfile>, returns any neurons corresponding to 
% thresholds in varargin. The appropriate fields to use  are Lratio, snr, 
% percentisi (smaller better), PercentCutByThreshold, IsolationDistance,
% and PercentDelayedSpikes.
% Example: to get Lratio between .1 and .4 - TW_getNeuronThresholds(
% twdbfile, 'Lratio', .1, .4)
% to get snr above .1 - TW_getNeuronThresholds(twdbfile, 'snr', .1, NaN)
% to get snr below .7 - TW_getNeurons(twdbfile, 'snr', NaN, .7)
% NOTE: use NaN for any thresholds you don't want to be confined between 2
% numbers.
if ~isequal(class(dbfile),'struct')
    twdb = load(dbfile);
    twdb = twdb.twdb;
else
    twdb = dbfile;
end
allNeurons = {twdb.(field)};
neurons = {};
if ~isempty(varargin)
    args = reshape(varargin,3,[]);
    argstype = args(1,:);
end
if ~isempty(varargin)
    thresh = 0;
    checkMat = zeros(length(allNeurons),1);
    for i = 1:length(argstype)
        if isfield(twdb,argstype(i))
            thresh = thresh+1;
            for f = 1:length(allNeurons)
                if f == 10283
                    1;
                end
                grade = twdb(f).(cell2mat(argstype(i)));
                if isempty(grade)
                    continue;
                end
                if ~isnan(args{3,i}) && isnan(args{2,i})
                    if grade <= args{3,i}
                        checkMat(f,1) = checkMat(f,1) + 1;
                    end
                elseif ~isnan(args{2,i}) && isnan(args{3,i})
                    if grade >= args{2,i}
                        checkMat(f,1) = checkMat(f,1) + 1;
                    end
                elseif ~isnan(args{2,i}) && ~isnan(args{3,i})
                    if grade >= args{2,i} && grade <= args{3,i}
                        checkMat(f,1) = checkMat(f,1) + 1;
                    end
                end
            end
        end
    end
    for i = 1:length(allNeurons)
        if isequal(thresh,checkMat(i,1))
            neurons{end+1} = allNeurons(i);
            neurons(end) = neurons{end};
        end
    end
else
    neurons = allNeurons;
end