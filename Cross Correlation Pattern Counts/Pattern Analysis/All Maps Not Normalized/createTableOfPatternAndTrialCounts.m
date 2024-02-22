clc;

%the purpose of this file is to combine the information contained in the files stored in the allFilesToLoad and filesWithTrialCounts variables

%allFilesToLoad is a list of 3 files which should already be in the current directory path
    %each file has contains 20 maps  
    %the key to each map is the task type and concentration
    %the value of each map is an int which represents a pattern count for the specified pattern 
    %the maps appear in the following order
    %{paired Short EE, paired short EI, paired short IE, paired short II, paired short NP,
    %unpaired short EE, unpaired short EI, unpaired short IE, unpaired short II, unpaired short NP,
    %paired long EE, paired long EI, paired long IE, paired long II, paired long NP,
    %unpaired long EE, unpaired long EI, unpaired long IE, unpaired long II, paired long NP}
    %The names of the maps are important
    %paired/unpaired - indicates whether the pattern count came from a paired or unpaired set of neurons
    %short/long - indicates whether the trials which were recorded from the neuron pairs were short or long 
    %EE - Excited Strio Excited Matrix
    %EI - Excited Strio Inhibited Matrix
    %IE - Inhibited Strio Excited Matrix
    %II - Inhibited Strio Inhibited Matrix
    %NP - No Pattern 
    %we only care about the maps which have paired in their names
    %all maps have the same set of keys, but differing values 
    

%filesWithTrialCounts is a list of 3 files which should already be in the current directory path
    %each file contains 4 maps 
    %the key to each map is the task type and concentration
    %the value of each map is the number of trials which were recorded for the specific task type and concentration
    %the maps appear in the following order
    %{unpairedNumberOfLongTrials,unpairedNumberOfShortTrials,pairedNumberOfShortTrials,pairedNumberOfLongTrials}
    %each 1 of these maps corresponds to 4 maps in the file specified in allFilesToLoad
    %they can correspond by names
    %paired short goes with paired short, paired long with paired long, etc. 

%the data contained in these files should be organized so that they are in a table with the following headers
%task_type__and_concentration__|__EE_Pattern_Count__||__EI_Pattern_Count__||__IE_Pattern_Count__||__II_Pattern_Count__||__Long_Or_Short__||__Trial_Count__|



allFilesToLoad = ["AllControlMapsByTaskTypeAndConcentrationsNotNormalized.mat","AllStress1MapsByTaskTypeAndConcentrationsNotNormalized.mat","AllStress2MapsByTaskTypeAndConcentrationsNotNormalized.mat"];

filesWithTrialCounts = ["AllControlTrialCountsByTaskTypeAndConcentrationNotNormalized.mat","AllStress1TrialCountsByTaskTypeAndConcentrationNotNormalized.mat","AllStress2TrialCountsByTaskTypeAndConcentrationNotNormalized.mat"];

strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn = table(nan,nan,nan,nan,nan,nan,nan,nan,...
            'VariableNames',{'Task Type and Concentration','Excited Excited','Excited Inhibited','Inhibited Excited','Inhibited Inhibited','trial_length','database','trial_counts'});


for i = 1:length(allFilesToLoad)
    load(allFilesToLoad(i))
    load(filesWithTrialCounts(i))
    for j=1:5:length(allMaps)
        if j==6 || j == 16
            continue
        end
%         disp(j)
        task_type_and_concentration = keys(allMaps{j}).';
        %disp(task_type_and_concentration)
        task_type_and_concentration = string(task_type_and_concentration);
        %disp(task_type_and_concentration)
        if isequal(task_type_and_concentration,string(keys(allMaps{j+1}).')) && isequal(task_type_and_concentration,string(keys(allMaps{j+2}).')) && isequal(task_type_and_concentration,string(keys(allMaps{j+3}).'))
%             disp("All Keys are matching")

            EE_Pattern_Count = cell2mat(values(allMaps{j}).');
            EI_Pattern_Count = cell2mat(values(allMaps{j+1}).');
            IE_Pattern_Count = cell2mat(values(allMaps{j+2}).');
            II_Pattern_Count = cell2mat(values(allMaps{j+3}).');

            if j==1
                long_or_short = cell(height(EE_Pattern_Count),1);
                long_or_short(:) = {"Short"};
                long_or_short = string(long_or_short);
                trial_counts = cell2mat(values(trialCounts{3}).');
                
            elseif j==11
                long_or_short = cell(height(EE_Pattern_Count),1);
                long_or_short(:) = {"Long"};
                long_or_short = string(long_or_short);
                trial_counts = cell2mat(values(trialCounts{4}).');
                
            end
            database = cell(height(EE_Pattern_Count),1);
            if i==1
                database(:) = {"control"};
                database=string(database);
            elseif i==2
                database(:) = {"stress"};
                database=string(database);
            elseif i==3
                database(:) = {"stress2"};
                database=string(database);
            end
%             disp([patternCountTaskTypeAndConcentration,task_type_and_concentration])
            
            currentTable = table(task_type_and_concentration,EE_Pattern_Count,EI_Pattern_Count,IE_Pattern_Count,II_Pattern_Count,long_or_short,database,trial_counts,...
                'VariableNames',...
                {'Task Type and Concentration','Excited Excited','Excited Inhibited','Inhibited Excited','Inhibited Inhibited','trial_length','database','trial_counts'});
%             disp(currentTable)
            strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn = [strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn;currentTable];
        else
            disp(strcat(allFilesToLoad(i), " has keys that don't match"))
        end
    end
end
strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn = rmmissing(strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn);
% disp(strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn);

%i will now merge skewness into this table by reading from Strio Matrix Pattern Counts Table.xlsx which has the skewness
a = readtable("Strio Matrix Pattern Counts Table.xlsx",'VariableNamingRule','preserve');
a.("Task Type and Concentration") = string(a.("Task Type and Concentration"));
justTaskTypeAndConcentrationTable = table(a.("Task Type and Concentration"),a.("Skewness"),string(a.("database")),string(a.("trial_length")),'VariableNames',{'Task Type and Concentration','Skewness','database','trial_length'});
justTaskTypeAndConcentrationTable{11,1} = "Task Type EQR NaN";
justTaskTypeAndConcentrationTable{50,1} = "Task Type CB NaN";
justTaskTypeAndConcentrationTable{61,1} = "Task Type CB NaN";

%disp(justTaskTypeAndConcentrationTable)

strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn.("Task Type and Concentration") = strrep(strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn.("Task Type and Concentration")," Concentration","");
% disp(strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn)

b = sortrows(strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn,[1,6,3]);
justTaskTypeAndConcentrationTable = sortrows(justTaskTypeAndConcentrationTable,[1,4,3]);
% disp(strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn);
% disp(justTaskTypeAndConcentrationTable);
% disp([strio_matrix_tableOfPatternCountsWithPatternsInOwnColumn.("Task Type and Concentration"),justTaskTypeAndConcentrationTable.("Task Type and Concentration")])
finalTable = table(b.("Task Type and Concentration"),b.("Excited Excited"),b.("Excited Inhibited"),b.("Inhibited Excited"),b.("Inhibited Inhibited"), b.("trial_length"),b.("database"),b.("trial_counts"),justTaskTypeAndConcentrationTable.("Skewness"), ...
    'VariableNames',....
    {'Task Type and Concentration','Excited Excited','Excited Inhibited','Inhibited Excited','Inhibited Inhibited','trial_length','database','trial_counts','Skewness'});

writetable(finalTable,"table_of_skewness_pattern_counts_and_trial_counts.xlsx")
save("table_of_skewness_pattern_counts_and_trial_counts.mat","finalTable");