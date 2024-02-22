function [neurons,idxs] = twdb_lookup(dbfile,field,varargin)
% Given a twdb file <dbfile> returns all neurons satisfying the conditions
% in varargin. If the search field is a key lookup, input "key" then the
% appropriate key/field. If the search is a grade threshold search, input
% "grade" then th appropriate field/threshold.
% EXAMPLE: for all dms neurons with snr between .5 and .7:
% twdb_lookup('twdbFileNew.mat','neuronRef','key','tetrodeType','dms','grade','snr',.5,.7)
% disp("Makes it into twdb_lookup")
% disp(dbfile)
% disp(field)
% disp(varargin)

if ~isequal(class(dbfile),'struct')
    twdb = load(dbfile);
    twdb = twdb.twdb;
else
    twdb = dbfile;
end
len = length(varargin);
neurons = {twdb.neuronRef};
a = 1;
if len ~= 0
    while a < len
        if isequal(varargin{a},'key')
            nComp = twdb_keylookup(twdb, 'neuronRef', varargin{a+1}, varargin{a+2});
            a = a+3;
        elseif isequal(varargin{a},'grade')
            nComp = twdb_thresholdlookup(twdb, 'neuronRef', varargin{a+1}, varargin{a+2}, varargin{a+3});
            a = a+4;
        else
            error('Must have key or grade identifier.');
        end
        neurons = intersect(neurons, nComp);
    end
end
idxs = [];
for n = 1:length(neurons)
    nIndex = find(strcmp({twdb.neuronRef},neurons{n}));
    idxs(n) = nIndex(1);
end
ns = {twdb.(field)};
neurons = ns(idxs);