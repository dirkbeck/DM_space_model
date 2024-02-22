% Specify the folder where the files live.
% myFolder = "C:\Users\ldd77\OneDrive\Desktop\Friedman-Hueske-2020\Fig7A_triplet-example\Automated";
myFolder = ".\Stress Lines";
% myFolder = "C:\Users\ldd77\OneDrive\Desktop\Friedman-Hueske-2020\Fig7A_triplet-example\Stress 2 Lines";

myFolder = "C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Fig7A_triplet-example\Control";
myFolder = "C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Fig7A_triplet-example\Control split";
% 
% myFolder = "C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Fig7A_triplet-example\Control split with filter updated michael";
% myFolder = "C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Fig7A_triplet-example\Control split with filter updated michael for EQR"; 

myFolder = "C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Fig7A_triplet-example\Control split with filter updated michael for EQR, neg inf micheal for everything else";
myFolder = "C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Fig7A_triplet-example\Control split with filter updated michael for EQR and rev cb, neg inf micheal for everything else";
myFolder = "C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Fig7A_triplet-example\Stress1 split";
rsquaredThreshold = 0.4;
significanceThreshold = 0.05; 


total_Figures_Count = containers.Map('KeyType','char','ValueType','any');

met_r_squared_and_significance = containers.Map('KeyType','char','ValueType','any');
met_r_squared_only = containers.Map('KeyType','char','ValueType','any');
met_significance_only = containers.Map('KeyType','char','ValueType','any');






% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '**/*.fig'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for a=1: length(theFiles)
    baseFileName = theFiles(a).name;
    fullFileName = fullfile(theFiles(a).folder, baseFileName);
    
    splitFileName = split(fullFileName,'\');
%     disp(string(splitFileName(9)))
    total_Figures_Count(string(splitFileName(9)))= 0;
    met_r_squared_and_significance(string(splitFileName(9))) = 0;
    met_r_squared_only(string(splitFileName(9))) = 0;
    met_significance_only(string(splitFileName(9))) = 0; 

end

all_the_keys = string(keys(total_Figures_Count));
if sum(contains(all_the_keys,"TR")) > 1
    hasBeenSplit = true;
else
    hasBeenSplit = false;
end

for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    splitFileName = split(fullFileName,'\');
%     display(splitFileName)
%     fprintf(1, 'Now reading %s\n', fullFileName);
    currentTitle = string(splitFileName(11));
    currentTitle = split(currentTitle," ");
%     disp(currentTitle)
    %use a loop to determine where r squared is in the current title
    for location_of_r_squared=1:length(currentTitle)
        if strcmpi(currentTitle(location_of_r_squared),"rsq")
            break;
        end
    end
    rsquared = currentTitle(location_of_r_squared+1);
    rsquared = str2double(rsquared);
    %use a loop to determine where r squared is  in the current title
    for location_of_sig=1:length(currentTitle)
        if strcmpi(currentTitle(location_of_sig),"sig")
            break;
        end
    end    
    significance = currentTitle(location_of_sig +1);
    significance = strrep(significance,".fig","");
    significance = str2double(significance);
    %     display(currentTitle)
    %     disp(rsquared)
    %     disp(significance)

    total_Figures_Count(string(splitFileName(9))) = total_Figures_Count(string(splitFileName(9)))+1;
    if significance <= significanceThreshold
        if rsquared >=rsquaredThreshold
%             total_Figures_Count((string(splitFileName(9)))) = total_Figures_Count((string(splitFileName(9)))) +1;
            met_r_squared_and_significance((string(splitFileName(9)) )) = met_r_squared_and_significance((string(splitFileName(9)) ))+1;
        else
            met_significance_only((string(splitFileName(9)))) = met_significance_only((string(splitFileName(9)))) +1;
%             total_Figures_Count((string(splitFileName(9)))) = total_Figures_Count((string(splitFileName(9)))) +1;
        end
    else
        if rsquared >= rsquaredThreshold
%             total_Figures_Count((string(splitFileName(9)))) = total_Figures_Count((string(splitFileName(9)))) +1;
            met_r_squared_only((string(splitFileName(9)))) = met_r_squared_only((string(splitFileName(9)))) +1;

        else
%             total_Figures_Count((string(splitFileName(9)))) = total_Figures_Count((string(splitFileName(9)))) +1;
        end


    end
end

% I hard coded a solution to ensure that TR 0 to 49 and TR 50 to 100 use the same total figure count instead of having their own figure count
% just to clarify, originally TR 0 to 49 and TR 50 to 100 each have their own figure count
% but I realize that because they're the same task type I should probably combine their figure counts
% instead of implementing a dynamic solution in countingEverything_updated.m I'm going to hard code a solution below
% if we need them to have their own figure counts again I can uncomment the following lines

if hasBeenSplit
    total_Figures_Count('TR 0 to 49') = total_Figures_Count('TR 0 to 49') + total_Figures_Count('TR 50 to 100');
    total_Figures_Count('TR 50 to 100') = total_Figures_Count('TR 0 to 49');
end

%% format the counts as a table 
figure; hold on
theFileNAmeNonsense = split(myFolder,"\");
disp(theFileNAmeNonsense{end})
formatted_table = table(keys(total_Figures_Count).',...
    cell2mat(values(total_Figures_Count).'),...
    cell2mat(values(met_r_squared_and_significance).') ./ cell2mat(values(total_Figures_Count).'), ...
    'VariableNames',{'TT and Conc','Total Figure Count', '% of all figures that met both'}); 
disp(formatted_table)

bar(categorical(formatted_table.("TT and Conc")), formatted_table.("% of all figures that met both"))
title("Percentages of Fittings By Task Type which had r-squared >= 0.4 and significance < 0.05")
xlabel("Task Type")
ylabel("Percentages")
subtitle("Created by countingEverything\_updated\_dont\_split\_by\_pos\_neg.m")

%% Add std dvn lines
yline(0.050571,"Label","1 std dvn above the mean")
yline(0.074893,"Label","1 std dvn above the mean")
yline(0.099214,"Label","1 std dvn above the mean")