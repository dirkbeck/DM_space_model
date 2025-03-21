function [dbs,twdbs] = loadData(twdbs_dir)

%IMPORTANT INFO
%MODIFY twdbs_dir to point to the file which contains the twdbs file for this function to work

twdbs = load(twdbs_dir);

twdb_control = twdbs.twdb_control;
twdb_stress = twdbs.twdb_stress;
twdb_stress2 = twdbs.twdb_stress2;

dbs = {'control', 'stress', 'stress2'}; twdbs = {twdb_control, twdb_stress, twdb_stress2}; % Databases to loop through
end