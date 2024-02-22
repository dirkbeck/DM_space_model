twdbs_dir = ['C:\Users\ldd77' filesep 'Downloads' filesep 'twdbs.mat'];
twdbs = load(twdbs_dir);
% 
twdb_control = twdbs.twdb_control;
% twdb_stress = twdbs.twdb_stress;
% twdb_stress2 = twdbs.twdb_stress2;


currentDatabaseUsing = twdb_control;


display(height(currentDatabaseUsing(1).taskType))
t = struct2table(currentDatabaseUsing);
uniqueConcentrations = unique(t.conc);
uniqueConcentrations = rmmissing(uniqueConcentrations);
uniqueConcentrations = [uniqueConcentrations;NaN];
uniqueTaskType = unique(t.taskType);

display(uniqueTaskType.')
display(uniqueConcentrations.')

% x = randn(6,1);
% y = randn(6,1);
% A = [x y];
% 
% [R,P] = corrcoef(A);

