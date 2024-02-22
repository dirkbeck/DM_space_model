function neurons = twdb_keylookup(dbfile, field, varargin)
% Given a twdb file <dbfile> takes in arguments in varargin and returns the
% files (using <field>) that satisfy the requirements in varargin.
% EXAMPLE: to get all neuronRefs for neurons with tetrode type dms:
% twdb_KeyLookup(twdbfile, "neuronRef", "neuronType", "dms")
if ~isequal(class(dbfile),'struct')
    twdb = load(dbfile);
    twdb = twdb.twdb;
else
    twdb = dbfile;
end
inputFields = reshape(varargin, 2, []);
for f = 1:length(inputFields(1,:))
    fieldName = inputFields{f, 1};
    if ~isfield(twdb, fieldName)
        error('afdb_lookup:nsfield',...
            'Field %s does not exist.', fieldName)
    end
    targetVal = inputFields{2, f};
    lookupVal = {twdb.(fieldName)};
    if ~iscellstr(lookupVal)
        if all(cellfun(@isscalar, lookupVal))
            lookupVal = [twdb.(fieldName)];
        else
            for c = 1:length(lookupVal)
                selectedSessions(c) = any(ismember(lookupVal{c}, targetVal));
            end
            selectedSessionsTemp(f,:)=selectedSessions;
            continue;
        end
    end
    pairs = ismember(lookupVal, targetVal);
    selectedSessions=pairs;
    selectedSessionsTemp(f,:)=selectedSessions;
end
selectedNeuron=all(selectedSessionsTemp, 1);
neurons = {twdb(logical(selectedNeuron)).(field)};
if ~isempty(neurons)
%     if ~isa(neurons{1},'char')
%         neurons = cell2mat(neurons);
%     end
end