function trial = tw_sessionid(filename)
% given filename, returns session ID - used in TW_lookup
filename = strrep(filename, '\','/'); % may need to comment out on windows - depends on slash type
[~,session,~] = fileparts(filename);
trial = session(1:19);
% trial = strrep(trial,'-',''); not sure if trial ID includes symbols; can
% uncomment if not
% trial = strrep(trial,'_','');