%This file will automatically load the database stored in twdb
%Three separate databases will be created (twdb_control,twdb_stress,twdb_stress2)
%For each database Paired/Unpaired Striosome-Matrix,Striosome-Striosome,and Matrix-Matrix will be identified
%Each pair will be fit using y = m*x +b
%The graphs will then be stored in the specified folder
%please modify twdb_dir variable to point to the location of the twdbs file
%WARNING
%Because of the time consuming fitting process and large amount of data this file could run for days in its entirety
%Because of this I would suggest commenting out any not needed calls to the createTables function.

%MODIFY THIS VARIABLE
% change directory to ensure twdbs loads properly
twdbs_dir = ['C:\Users\ldd77' filesep 'Downloads' filesep 'twdbs.mat'];
twdbs = load(twdbs_dir);
% %
twdb_control = twdbs.twdb_control;
twdb_stress = twdbs.twdb_stress;
twdb_stress2 = twdbs.twdb_stress2;

%get the unique values in the current database
currentDatabase = twdb_control;
t = struct2table(currentDatabase);
uniqueConcentrations = unique(t.conc);
uniqueConcentrations = rmmissing(uniqueConcentrations);
uniqueTaskType = unique(t.taskType);

createTables(currentDatabase,1,"Paired Matrix Striosome Control",1,uniqueTaskType,uniqueConcentrations,1,1)
% createTables(currentDatabase,1,"Unpaired Matrix Striosome Control",0,uniqueTaskType,uniqueConcentrations,1,0)
% 
% createTables(currentDatabase,2,"Paired Matrix Matrix Control",1,uniqueTaskType,uniqueConcentrations,1,0)
% createTables(currentDatabase,2,"Unpaired Matrix Matrix Control",0,uniqueTaskType,uniqueConcentrations,1,0)
% 
% 
% 
% createTables(currentDatabase,3,strcat("Paired Striosome Striosome Control",string(i)),1,uniqueTaskType,uniqueConcentrations,1,0)
% createTables(currentDatabase,3,strcat("Unpaired Striosome Striosome Control",string(i)),0,uniqueTaskType,uniqueConcentrations,1,0)
% 
% createTables(currentDatabase,3,"Paired Striosome Striosome Control",1,uniqueTaskType,uniqueConcentrations,1,0)
% createTables(currentDatabase,3,"Unpaired Striosome Striosome Control",0,uniqueTaskType,uniqueConcentrations,1,0)
% 
% currentDatabase = twdb_stress;
% t = struct2table(currentDatabase);
% uniqueConcentrations = unique(t.conc);
% uniqueConcentrations = rmmissing(uniqueConcentrations);
% uniqueTaskType = unique(t.taskType);
% 
% createTables(currentDatabase,1,"Paired Matrix Striosome StressOne",1,uniqueTaskType,uniqueConcentrations,2,0)
% createTables(currentDatabase,1,"Unpaired Matrix Striosome StressOne",0,uniqueTaskType,uniqueConcentrations,2,0)
% 
% createTables(currentDatabase,2,"Paired Matrix Matrix StressOne",1,uniqueTaskType,uniqueConcentrations,2,0)
% createTables(currentDatabase,2,"Unpaired Matrix Matrix StressOne",0,uniqueTaskType,uniqueConcentrations,2,0)
% 
% createTables(currentDatabase,3,"Paired Striosome Striosome StressOne",1,uniqueTaskType,uniqueConcentrations,2,0)
% createTables(currentDatabase,3,"Unpaired Striosome Striosome StressOne",0,uniqueTaskType,uniqueConcentrations,2,0)
% 
% currentDatabase = twdb_stress2;
% t = struct2table(currentDatabase);
% uniqueConcentrations = unique(t.conc);
% uniqueConcentrations = rmmissing(uniqueConcentrations);
% uniqueTaskType = unique(t.taskType);
% 
% createTables(currentDatabase,1,"Paired Matrix Striosome StressTwo",1,uniqueTaskType,uniqueConcentrations,3,0)
% createTables(currentDatabase,1,"Unpaired Matrix Striosome StressTwo",0,uniqueTaskType,uniqueConcentrations,3,0)
% 
% createTables(currentDatabase,2,"Paired Matrix Matrix StressTwo",1,uniqueTaskType,uniqueConcentrations,3,0)
% createTables(currentDatabase,2,"Unpaired Matrix Matrix StressTwo",0,uniqueTaskType,uniqueConcentrations,3,0)
% 
% createTables(currentDatabase,3,"Paired Striosome Striosome StressTwo",1,uniqueTaskType,uniqueConcentrations,3,0)
% createTables(currentDatabase,3,"Unpaired Striosome Striosome StressTwo",0,uniqueTaskType,uniqueConcentrations,3,0)