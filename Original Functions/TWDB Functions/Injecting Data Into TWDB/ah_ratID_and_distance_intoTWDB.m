function ah_ratID_and_distance_intoTWDB(twdbfile)
twdb = load(twdbfile);
twdb = twdb.twdb;
dists = {};
dists{1} = nan(1,24);
dists{2} = [30, NaN, 59, NaN, NaN, NaN, 30, 33, 27, NaN, NaN, NaN,...
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN];
dists{3} = [NaN, NaN, 41, 43, 131, 34, -34, 93, 65, NaN, 53, NaN,...
    NaN, 48, 38, 99, 53, NaN, 104, 57, NaN, 17, NaN, NaN];
dists{4} = [NaN, NaN, 78, NaN, 41, 12, NaN, 60, NaN, 110, 52, -31, ...
    98, 110, 91, 15, 49, NaN, 71, 67, NaN, 41, 8, NaN];
dists{5} = nan(1,24);
dists{6} = [38, 74, 65, 14, 16, 109, 71, 0, 23, NaN, 57, 119,...
    0, 9, 6, 95, 36, 11, 0, 57, NaN, NaN, 69, 18];
dists{7} = [NaN, NaN, NaN, NaN, NaN, NaN, 60, 99, 80, NaN, NaN, NaN, ...
    27, 60, NaN, NaN, NaN, 21, 34, NaN, NaN, NaN, -11, -14];
dists{8} = [NaN, 120, -29, 30, 114, 107, 41, 34, 94, 39, NaN, NaN, ...
    NaN, NaN, 37, NaN, 8, 76, 8, NaN, NaN, 41, NaN, NaN];
dists{10} = [58, 86, 53, 38, 31, NaN, -35, 61, NaN, NaN, NaN, NaN,...
    32, 23, NaN, -30, 49, 61, 44, 18, -52, 18, 29, 90];
dists{11} = [NaN, NaN, 47, 62, 20, 5, NaN, NaN, 98, NaN, NaN, NaN,...
    NaN, NaN, NaN, 8, NaN, 25, NaN, 69, 72, NaN, NaN, 17];

for i = 1:length(twdb)
    id = strfind(twdb(i).sessionDir, 'strio');
    ratNum = str2double(twdb(i).sessionDir(id(1)+5:id(1)+6));
    if isnan(ratNum)
        ratNum = str2double(twdb(i).sessionDir(id(1)+5));
    end
    ttnum = str2double(twdb(i).tetrodeN);
    twdb(i).ratID = strcat('strio', num2str(ratNum));
    twdb(i).distanceFromStriosome = dists{ratNum}(ttnum);
end
save(twdbfile, 'twdb')
end