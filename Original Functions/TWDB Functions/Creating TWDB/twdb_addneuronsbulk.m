function twdb_addneuronsbulk(dbfile, parentdir)
% Given a twdb file <dbfile> and a parent directory <parentdir>, adds
% multiple sessions of neurons to twdb that are contained in parentdir.
% Example: twdb_addneuronsbulk(dbfile, parentdir)
dirfiles = dir(parentdir);

twdb = [];

for f = 1:length(dirfiles)
    if isequal(dirfiles(f).name,'.') || isequal(dirfiles(f).name,'..') || isequal(dirfiles(f).name,'.DS_Store')
        continue
    end
    if exist(fullfile(parentdir,dirfiles(f).name),'dir') == 7 
        if isempty(twdb)
            twdb = twdb_addneurons(fullfile(parentdir,dirfiles(f).name));
        else
            twdb = [twdb twdb_addneurons(fullfile(parentdir,dirfiles(f).name))];
        end
    end
    
end
if exist(dbfile,'file')
    twdb1 = load(dbfile);
    twdb1 = twdb1.twdb;
    twdb = [twdb1 twdb];
end
save(dbfile, 'twdb')
end